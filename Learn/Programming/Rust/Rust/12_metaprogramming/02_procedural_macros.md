## Procedural Macros


Procedural macros in Rust are a powerful metaprogramming feature that allows you to write code that generates other code at compile time. Unlike declarative macros (macro_rules!), procedural macros operate on the abstract syntax tree (AST) of Rust code and can perform complex transformations and code generation.

### Overview of Procedural Macros

Procedural macros are Rust functions that take a token stream as input and produce a token stream as output. They run during compilation and can inspect, modify, or generate Rust code. There are three main types: derive macros, function-like macros, and attribute macros.

**Key Points:**

- Execute at compile time, not runtime
- Work with token streams and AST representations
- Require a separate crate with `proc-macro = true` in Cargo.toml
- Must be defined in a dedicated procedural macro crate
- Can generate complex code patterns automatically

### Derive Macros

Derive macros are the most common type of procedural macro, automatically implementing traits for structs and enums when annotated with `#[derive(TraitName)]`.

#### Creating a Custom Derive Macro

```rust
// In Cargo.toml of the proc-macro crate
[lib]
proc-macro = true

[dependencies]
syn = { version = "2.0", features = ["full"] }
quote = "1.0"
proc-macro2 = "1.0"
```

```rust
use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, DeriveInput};

#[proc_macro_derive(HelloWorld)]
pub fn hello_world_derive(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as DeriveInput);
    let name = input.ident;
    
    let expanded = quote! {
        impl HelloWorld for #name {
            fn hello_world() {
                println!("Hello, World! My name is {}!", stringify!(#name));
            }
        }
    };
    
    TokenStream::from(expanded)
}
```

**Example:**

```rust
#[derive(HelloWorld)]
struct Pancakes;

// This generates:
impl HelloWorld for Pancakes {
    fn hello_world() {
        println!("Hello, World! My name is {}!", stringify!(Pancakes));
    }
}
```

#### Advanced Derive Macro Features

Derive macros can accept helper attributes to customize behavior:

```rust
#[proc_macro_derive(Builder, attributes(builder))]
pub fn derive_builder(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as DeriveInput);
    
    match input.data {
        syn::Data::Struct(ref data_struct) => {
            generate_builder_for_struct(&input.ident, data_struct)
        }
        _ => panic!("Builder can only be derived for structs"),
    }
}

fn generate_builder_for_struct(name: &syn::Ident, data_struct: &syn::DataStruct) -> TokenStream {
    let builder_name = syn::Ident::new(&format!("{}Builder", name), name.span());
    let fields = match data_struct.fields {
        syn::Fields::Named(ref fields) => &fields.named,
        _ => panic!("Builder only supports named fields"),
    };
    
    let field_names: Vec<_> = fields.iter().map(|f| &f.ident).collect();
    let field_types: Vec<_> = fields.iter().map(|f| &f.ty).collect();
    
    let expanded = quote! {
        pub struct #builder_name {
            #(#field_names: Option<#field_types>,)*
        }
        
        impl #builder_name {
            pub fn new() -> Self {
                #builder_name {
                    #(#field_names: None,)*
                }
            }
            
            #(
                pub fn #field_names(mut self, #field_names: #field_types) -> Self {
                    self.#field_names = Some(#field_names);
                    self
                }
            )*
            
            pub fn build(self) -> Result<#name, Box<dyn std::error::Error>> {
                Ok(#name {
                    #(
                        #field_names: self.#field_names
                            .ok_or_else(|| format!("Field {} is required", stringify!(#field_names)))?,
                    )*
                })
            }
        }
        
        impl #name {
            pub fn builder() -> #builder_name {
                #builder_name::new()
            }
        }
    };
    
    TokenStream::from(expanded)
}
```

### Function-like Procedural Macros

Function-like procedural macros are invoked using the familiar `macro_name!()` syntax and can accept arbitrary input tokens.

```rust
#[proc_macro]
pub fn make_answer(_item: TokenStream) -> TokenStream {
    "fn answer() -> u32 { 42 }".parse().unwrap()
}

#[proc_macro]
pub fn sql(input: TokenStream) -> TokenStream {
    let input = input.to_string();
    
    // Parse SQL and generate appropriate Rust code
    let expanded = quote! {
        {
            let query = #input;
            // Generate database query code
            println!("Executing SQL: {}", query);
        }
    };
    
    TokenStream::from(expanded)
}
```

**Example:**

```rust
make_answer!(); // Generates the answer function

sql!(SELECT * FROM users WHERE age > 21); // Generates query code
```

#### Complex Function-like Macros

```rust
#[proc_macro]
pub fn hashmap(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as syn::Expr);
    
    match input {
        syn::Expr::Array(array) => {
            let elements = array.elems;
            let pairs: Vec<_> = elements
                .into_pairs()
                .map(|pair| {
                    let (key_value, _punct) = pair.into_tuple();
                    match key_value {
                        syn::Expr::Tuple(tuple) if tuple.elems.len() == 2 => {
                            let mut iter = tuple.elems.into_iter();
                            let key = iter.next().unwrap();
                            let value = iter.next().unwrap();
                            (key, value)
                        }
                        _ => panic!("Expected (key, value) pairs"),
                    }
                })
                .collect();
            
            let keys: Vec<_> = pairs.iter().map(|(k, _)| k).collect();
            let values: Vec<_> = pairs.iter().map(|(_, v)| v).collect();
            
            let expanded = quote! {
                {
                    let mut map = std::collections::HashMap::new();
                    #(map.insert(#keys, #values);)*
                    map
                }
            };
            
            TokenStream::from(expanded)
        }
        _ => panic!("Expected array syntax"),
    }
}
```

### Attribute Macros

Attribute macros can be applied to various Rust items (functions, structs, modules) and can modify or wrap the annotated item.

```rust
#[proc_macro_attribute]
pub fn route(args: TokenStream, input: TokenStream) -> TokenStream {
    let args = parse_macro_input!(args as syn::LitStr);
    let input_fn = parse_macro_input!(input as syn::ItemFn);
    
    let fn_name = &input_fn.sig.ident;
    let route_path = args.value();
    
    let expanded = quote! {
        #input_fn
        
        inventory::submit! {
            Route {
                path: #route_path,
                handler: #fn_name,
            }
        }
    };
    
    TokenStream::from(expanded)
}

#[proc_macro_attribute]
pub fn timing(_args: TokenStream, input: TokenStream) -> TokenStream {
    let input_fn = parse_macro_input!(input as syn::ItemFn);
    let fn_name = &input_fn.sig.ident;
    let fn_block = &input_fn.block;
    let fn_vis = &input_fn.vis;
    let fn_sig = &input_fn.sig;
    
    let expanded = quote! {
        #fn_vis #fn_sig {
            let start = std::time::Instant::now();
            let result = (|| #fn_block)();
            let duration = start.elapsed();
            println!("{} took {:?}", stringify!(#fn_name), duration);
            result
        }
    };
    
    TokenStream::from(expanded)
}
```

**Example:**

```rust
#[route("/api/users")]
fn get_users() -> String {
    "User list".to_string()
}

#[timing]
fn expensive_operation() -> i32 {
    std::thread::sleep(std::time::Duration::from_millis(100));
    42
}
```

### syn and quote Crates

The `syn` and `quote` crates are essential tools for writing procedural macros, providing parsing and code generation capabilities.

#### syn Crate Features

The `syn` crate parses Rust tokens into a syntax tree:

```rust
use syn::{
    parse_macro_input, parse_quote, parse_str,
    Data, DeriveInput, Fields, FieldsNamed, Ident, Type,
    Expr, Stmt, Item, ItemFn, ItemStruct,
    Attribute, Meta, NestedMeta, Lit, LitStr,
};

// Parsing different input types
#[proc_macro_derive(MyTrait)]
pub fn my_trait_derive(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as DeriveInput);
    
    match &input.data {
        Data::Struct(data_struct) => {
            match &data_struct.fields {
                Fields::Named(FieldsNamed { named, .. }) => {
                    for field in named {
                        let field_name = field.ident.as_ref().unwrap();
                        let field_type = &field.ty;
                        
                        // Process field attributes
                        for attr in &field.attrs {
                            if attr.path.is_ident("skip") {
                                // Handle #[skip] attribute
                                continue;
                            }
                        }
                    }
                }
                Fields::Unnamed(_) => {
                    // Handle tuple structs
                }
                Fields::Unit => {
                    // Handle unit structs
                }
            }
        }
        Data::Enum(data_enum) => {
            for variant in &data_enum.variants {
                let variant_name = &variant.ident;
                // Process enum variants
            }
        }
        Data::Union(_) => {
            panic!("Unions are not supported");
        }
    }
    
    // Generate code...
    TokenStream::new()
}
```

#### quote Crate Usage

The `quote` crate generates Rust code from templates:

```rust
use quote::{quote, format_ident};

// Basic quoting
let name = format_ident!("MyStruct");
let field_count = 3;

let generated = quote! {
    impl #name {
        const FIELD_COUNT: usize = #field_count;
        
        fn new() -> Self {
            Self::default()
        }
    }
};

// Repetition patterns
let field_names = vec![format_ident!("field1"), format_ident!("field2")];
let field_types = vec![parse_quote!(String), parse_quote!(i32)];

let struct_def = quote! {
    struct MyStruct {
        #(#field_names: #field_types,)*
    }
    
    impl MyStruct {
        #(
            fn #field_names(&self) -> &#field_types {
                &self.#field_names
            }
        )*
    }
};

// Conditional generation
let has_debug = true;
let debug_impl = if has_debug {
    quote! {
        impl std::fmt::Debug for MyStruct {
            fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
                f.debug_struct("MyStruct").finish()
            }
        }
    }
} else {
    quote! {}
};
```

### Custom Derive Implementations

Creating robust custom derive macros requires careful handling of generics, where clauses, and edge cases.

#### Advanced Derive Example with Generics

```rust
#[proc_macro_derive(Serialize)]
pub fn derive_serialize(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as DeriveInput);
    let name = &input.ident;
    let generics = &input.generics;
    let (impl_generics, ty_generics, where_clause) = generics.split_for_impl();
    
    let serialize_body = match &input.data {
        Data::Struct(data_struct) => {
            generate_serialize_struct(data_struct)
        }
        Data::Enum(data_enum) => {
            generate_serialize_enum(data_enum)
        }
        Data::Union(_) => {
            return syn::Error::new_spanned(
                input,
                "Serialize cannot be derived for unions"
            ).to_compile_error().into();
        }
    };
    
    let expanded = quote! {
        impl #impl_generics Serialize for #name #ty_generics #where_clause {
            fn serialize(&self) -> String {
                #serialize_body
            }
        }
    };
    
    TokenStream::from(expanded)
}

fn generate_serialize_struct(data_struct: &syn::DataStruct) -> proc_macro2::TokenStream {
    match &data_struct.fields {
        Fields::Named(fields) => {
            let field_serializations = fields.named.iter().map(|field| {
                let field_name = field.ident.as_ref().unwrap();
                let field_name_str = field_name.to_string();
                quote! {
                    format!("\"{}\":{}", #field_name_str, self.#field_name.serialize())
                }
            });
            
            quote! {
                format!("{{{}}}", vec![#(#field_serializations),*].join(","))
            }
        }
        Fields::Unnamed(fields) => {
            let field_serializations = fields.unnamed.iter().enumerate().map(|(i, _)| {
                let index = syn::Index::from(i);
                quote! {
                    self.#index.serialize()
                }
            });
            
            quote! {
                format!("[{}]", vec![#(#field_serializations),*].join(","))
            }
        }
        Fields::Unit => {
            quote! {
                "null".to_string()
            }
        }
    }
}
```

#### Handling Attributes and Configuration

```rust
#[proc_macro_derive(Validate, attributes(validate))]
pub fn derive_validate(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as DeriveInput);
    let name = &input.ident;
    
    let validation_checks = match &input.data {
        Data::Struct(data_struct) => {
            generate_struct_validations(data_struct)
        }
        _ => panic!("Validate can only be derived for structs"),
    };
    
    let expanded = quote! {
        impl Validate for #name {
            fn validate(&self) -> Result<(), ValidationError> {
                #validation_checks
                Ok(())
            }
        }
    };
    
    TokenStream::from(expanded)
}

fn generate_struct_validations(data_struct: &syn::DataStruct) -> proc_macro2::TokenStream {
    let field_validations = data_struct.fields.iter().filter_map(|field| {
        let field_name = field.ident.as_ref()?;
        let validations = extract_validation_attributes(&field.attrs);
        
        if validations.is_empty() {
            return None;
        }
        
        let checks = validations.into_iter().map(|validation| {
            match validation {
                ValidationRule::Range { min, max } => {
                    quote! {
                        if self.#field_name < #min || self.#field_name > #max {
                            return Err(ValidationError::Range {
                                field: stringify!(#field_name),
                                min: #min,
                                max: #max,
                                actual: self.#field_name,
                            });
                        }
                    }
                }
                ValidationRule::Length { min, max } => {
                    quote! {
                        let len = self.#field_name.len();
                        if len < #min || len > #max {
                            return Err(ValidationError::Length {
                                field: stringify!(#field_name),
                                min: #min,
                                max: #max,
                                actual: len,
                            });
                        }
                    }
                }
            }
        });
        
        Some(quote! { #(#checks)* })
    });
    
    quote! {
        #(#field_validations)*
    }
}

#[derive(Debug)]
enum ValidationRule {
    Range { min: i64, max: i64 },
    Length { min: usize, max: usize },
}

fn extract_validation_attributes(attrs: &[Attribute]) -> Vec<ValidationRule> {
    attrs.iter()
        .filter(|attr| attr.path.is_ident("validate"))
        .filter_map(|attr| {
            match attr.parse_meta() {
                Ok(Meta::List(meta_list)) => {
                    meta_list.nested.into_iter().filter_map(|nested| {
                        match nested {
                            NestedMeta::Meta(Meta::NameValue(name_value)) 
                                if name_value.path.is_ident("range") => {
                                // Parse range validation
                                None // Simplified for brevity
                            }
                            _ => None,
                        }
                    }).collect::<Vec<_>>().into_iter().next()
                }
                _ => None,
            }
        })
        .collect()
}
```

### Span Information and Error Reporting

Proper error handling and span information are crucial for creating user-friendly procedural macros.

#### Working with Spans

```rust
use proc_macro2::Span;
use syn::spanned::Spanned;

#[proc_macro_derive(TypedBuilder)]
pub fn derive_typed_builder(input: TokenStream) -> TokenStream {
    match derive_typed_builder_impl(input) {
        Ok(output) => output,
        Err(error) => error.to_compile_error().into(),
    }
}

fn derive_typed_builder_impl(input: TokenStream) -> syn::Result<TokenStream> {
    let input = parse_macro_input!(input as DeriveInput);
    
    let struct_data = match &input.data {
        Data::Struct(data) => data,
        _ => {
            return Err(syn::Error::new_spanned(
                input,
                "TypedBuilder can only be derived for structs"
            ));
        }
    };
    
    let fields = match &struct_data.fields {
        Fields::Named(fields) => &fields.named,
        Fields::Unnamed(_) => {
            return Err(syn::Error::new_spanned(
                struct_data.fields,
                "TypedBuilder requires named fields"
            ));
        }
        Fields::Unit => {
            return Err(syn::Error::new_spanned(
                struct_data.fields,
                "TypedBuilder cannot be used with unit structs"
            ));
        }
    };
    
    let mut errors = Vec::new();
    let mut builder_fields = Vec::new();
    
    for field in fields {
        let field_name = match &field.ident {
            Some(name) => name,
            None => {
                errors.push(syn::Error::new_spanned(
                    field,
                    "All fields must have names"
                ));
                continue;
            }
        };
        
        // Validate field attributes
        for attr in &field.attrs {
            if attr.path.is_ident("builder") {
                match validate_builder_attribute(attr) {
                    Ok(config) => {
                        builder_fields.push((field_name, &field.ty, config));
                    }
                    Err(err) => {
                        errors.push(err);
                    }
                }
            }
        }
    }
    
    if !errors.is_empty() {
        let mut combined_error = errors.into_iter().next().unwrap();
        for error in errors {
            combined_error.combine(error);
        }
        return Err(combined_error);
    }
    
    // Generate builder implementation...
    Ok(TokenStream::new())
}

fn validate_builder_attribute(attr: &Attribute) -> syn::Result<BuilderConfig> {
    let meta = attr.parse_meta()?;
    
    match meta {
        Meta::Path(_) => Ok(BuilderConfig::default()),
        Meta::List(meta_list) => {
            let mut config = BuilderConfig::default();
            
            for nested in meta_list.nested {
                match nested {
                    NestedMeta::Meta(Meta::NameValue(name_value)) => {
                        if name_value.path.is_ident("default") {
                            match &name_value.lit {
                                Lit::Str(lit_str) => {
                                    config.default_value = Some(lit_str.parse()?);
                                }
                                _ => {
                                    return Err(syn::Error::new_spanned(
                                        name_value.lit,
                                        "Expected string literal for default value"
                                    ));
                                }
                            }
                        } else {
                            return Err(syn::Error::new_spanned(
                                name_value.path,
                                format!("Unknown builder option: {}", 
                                    name_value.path.get_ident().unwrap())
                            ));
                        }
                    }
                    _ => {
                        return Err(syn::Error::new_spanned(
                            nested,
                            "Expected name=value pairs in builder attribute"
                        ));
                    }
                }
            }
            
            Ok(config)
        }
        _ => {
            Err(syn::Error::new_spanned(
                attr,
                "Invalid builder attribute format"
            ))
        }
    }
}

#[derive(Default)]
struct BuilderConfig {
    default_value: Option<syn::Expr>,
}
```

#### Custom Error Types and Diagnostics

```rust
use proc_macro_error::{proc_macro_error, emit_error, emit_warning, abort};

#[proc_macro_derive(SafeDerive)]
#[proc_macro_error]
pub fn derive_safe(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as DeriveInput);
    
    // Collect all potential issues
    let mut diagnostics = Vec::new();
    
    match &input.data {
        Data::Struct(data_struct) => {
            validate_struct_safety(&input.ident, data_struct, &mut diagnostics);
        }
        Data::Enum(data_enum) => {
            validate_enum_safety(&input.ident, data_enum, &mut diagnostics);
        }
        Data::Union(_) => {
            emit_error!(
                input.span(),
                "SafeDerive cannot be applied to unions";
                help = "Consider using a struct or enum instead"
            );
        }
    }
    
    // Report all diagnostics
    for diagnostic in diagnostics {
        match diagnostic.level {
            DiagnosticLevel::Error => {
                emit_error!(diagnostic.span, "{}", diagnostic.message);
            }
            DiagnosticLevel::Warning => {
                emit_warning!(diagnostic.span, "{}", diagnostic.message);
            }
        }
    }
    
    // Generate implementation
    let name = &input.ident;
    let expanded = quote! {
        impl SafeDerive for #name {
            fn is_safe() -> bool {
                true
            }
        }
    };
    
    TokenStream::from(expanded)
}

struct Diagnostic {
    span: Span,
    level: DiagnosticLevel,
    message: String,
}

enum DiagnosticLevel {
    Error,
    Warning,
}

fn validate_struct_safety(
    name: &Ident,
    data_struct: &syn::DataStruct,
    diagnostics: &mut Vec<Diagnostic>
) {
    match &data_struct.fields {
        Fields::Named(fields) => {
            for field in &fields.named {
                if let Some(field_name) = &field.ident {
                    // Check for potentially unsafe patterns
                    if field_name.to_string().starts_with('_') {
                        diagnostics.push(Diagnostic {
                            span: field_name.span(),
                            level: DiagnosticLevel::Warning,
                            message: format!(
                                "Field '{}' starts with underscore, which may indicate internal use",
                                field_name
                            ),
                        });
                    }
                    
                    // Check field type safety
                    if let syn::Type::Ptr(_) = &field.ty {
                        diagnostics.push(Diagnostic {
                            span: field.ty.span(),
                            level: DiagnosticLevel::Error,
                            message: "Raw pointers are not allowed in safe derives".to_string(),
                        });
                    }
                }
            }
        }
        _ => {
            diagnostics.push(Diagnostic {
                span: name.span(),
                level: DiagnosticLevel::Warning,
                message: "SafeDerive works best with named fields".to_string(),
            });
        }
    }
}
```

**Key Points:**

- Use `syn::Error` for recoverable errors that should be reported as compilation errors
- Leverage `proc_macro_error` crate for enhanced diagnostic capabilities
- Preserve span information to provide accurate error locations
- Combine multiple errors when validating complex structures
- Provide helpful error messages with context and suggestions

**Conclusion:** Procedural macros in Rust provide powerful metaprogramming capabilities through derive macros, function-like macros, and attribute macros. The `syn` and `quote` crates form the foundation for parsing and generating code, while proper error handling and span management ensure good developer experience. Mastering these concepts enables the creation of sophisticated code generation tools that can significantly reduce boilerplate and enhance API ergonomics.

**Next Steps:**

- Practice implementing custom derive macros for common patterns
- Explore advanced `syn` parsing techniques for complex syntax
- Study existing procedural macro crates for real-world patterns
- Learn about procedural macro debugging techniques and tools

---

