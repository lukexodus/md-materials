## Custom Transformations in TypeScript


### Introduction to TypeScript Transformers

TypeScript's compiler API provides powerful mechanisms for programmatically analyzing and transforming code. Custom transformers allow you to hook into the TypeScript compilation process, enabling code generation, syntax transformation, and static analysis beyond what the built-in language features offer.

**Key Points**

- TypeScript transformers operate on the Abstract Syntax Tree (AST)
- Transformers can generate new code, modify existing code, or perform validation
- They integrate with the TypeScript compilation pipeline
- Transformers make advanced metaprogramming possible without runtime overhead

### Compiler API Fundamentals

Before diving into transformers, it's important to understand the TypeScript Compiler API's core components:

```typescript
import * as ts from "typescript";

// Create a program from source files
const program = ts.createProgram(["./src/file.ts"], {
  target: ts.ScriptTarget.ES2020,
  module: ts.ModuleKind.ESNext
});

// Get the TypeChecker - used for semantic analysis
const typeChecker = program.getTypeChecker();

// Get a specific source file from the program
const sourceFile = program.getSourceFile("./src/file.ts");

// Get diagnostics (errors/warnings)
const diagnostics = ts.getPreEmitDiagnostics(program);
```

### Writing Custom Transformers

Custom transformers are implemented as factory functions that return a transformer function:

```typescript
import * as ts from "typescript";

// A simple transformer factory function
function myTransformerFactory(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
  return (context: ts.TransformationContext) => {
    return (sourceFile: ts.SourceFile) => {
      // The transformation logic
      function visit(node: ts.Node): ts.Node {
        // Modify or replace nodes here
        
        // Example: Add comment to function declarations
        if (ts.isFunctionDeclaration(node) && node.name) {
          const newNode = ts.addSyntheticLeadingComment(
            node,
            ts.SyntaxKind.MultiLineCommentTrivia,
            ` Function: ${node.name.text} `,
            true
          );
          return newNode;
        }
        
        // Continue recursion by visiting each child node
        return ts.visitEachChild(node, visit, context);
      }
      
      // Start the recursive traversal at the source file root
      return ts.visitNode(sourceFile, visit);
    };
  };
}

// Using the transformer
const program = ts.createProgram(["./src/file.ts"], {/*compiler options*/});
const transformationResult = ts.transform(
  program.getSourceFiles(),
  [myTransformerFactory(program)]
);

// Get the transformed source files
const transformedSourceFiles = transformationResult.transformed;
```

### Custom Transformer Configuration with ts-node or ttypescript

For practical usage, transformers are often integrated using tools like `ttypescript` or custom loaders:

```json
// tsconfig.json with ttypescript
{
  "compilerOptions": {
    "target": "es2020",
    "module": "commonjs",
    "plugins": [
      { "transform": "./path/to/my-transformer.js" }
    ]
  }
}
```

Custom transformer registration with `ts-node`:

```typescript
// register.js
const tsNode = require('ts-node');
const myTransformer = require('./my-transformer');

tsNode.register({
  transformers: {
    before: [myTransformer.default]
  }
});
```

### Code Generation

One powerful application of transformers is automatic code generation:

#### Type-Safe Validators Generator

```typescript
// This transformer generates validation functions from interfaces
function validatorGeneratorFactory(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    const typeChecker = program.getTypeChecker();
    
    return sourceFile => {
      const interfacesToProcess: ts.InterfaceDeclaration[] = [];
      
      // First pass: collect interfaces with @validate comment
      function collectInterfaces(node: ts.Node) {
        if (ts.isInterfaceDeclaration(node)) {
          const comments = ts.getLeadingCommentRanges(
            sourceFile.text, 
            node.pos
          );
          
          if (comments && comments.some(c => 
            sourceFile.text.substring(c.pos, c.end).includes('@validate'))) {
            interfacesToProcess.push(node);
          }
        }
        
        ts.forEachChild(node, collectInterfaces);
      }
      
      collectInterfaces(sourceFile);
      
      if (interfacesToProcess.length === 0) {
        return sourceFile;
      }
      
      // Generate validation functions for each interface
      const validatorFunctions = interfacesToProcess.map(interfaceDecl => {
        const interfaceName = interfaceDecl.name.text;
        const validatorName = `validate${interfaceName}`;
        
        const properties: ts.PropertySignature[] = [];
        interfaceDecl.members.forEach(member => {
          if (ts.isPropertySignature(member) && member.name) {
            properties.push(member);
          }
        });
        
        // Generate validation logic for each property
        const validationChecks = properties.map(prop => {
          const propName = prop.name.getText(sourceFile);
          const propType = typeChecker.getTypeAtLocation(prop.type!);
          
          let validationExpression: string;
          if (propType.flags & ts.TypeFlags.String) {
            validationExpression = `typeof obj.${propName} === 'string'`;
          } else if (propType.flags & ts.TypeFlags.Number) {
            validationExpression = `typeof obj.${propName} === 'number'`;
          } else if (propType.flags & ts.TypeFlags.Boolean) {
            validationExpression = `typeof obj.${propName} === 'boolean'`;
          } else {
            // Default fallback
            validationExpression = `obj.${propName} !== undefined`;
          }
          
          const isOptional = prop.questionToken !== undefined;
          if (isOptional) {
            return `(obj.${propName} === undefined || ${validationExpression})`;
          }
          return validationExpression;
        });
        
        // Create the validator function code
        return `
function ${validatorName}(obj: any): obj is ${interfaceName} {
  if (!obj || typeof obj !== 'object') return false;
  return ${validationChecks.join(' && ')};
}`;
      });
      
      // Create a new source file with the original content + validators
      const updatedText = sourceFile.text + '\n\n' + validatorFunctions.join('\n\n');
      const newSourceFile = ts.createSourceFile(
        sourceFile.fileName,
        updatedText,
        sourceFile.languageVersion,
        true
      );
      
      return newSourceFile;
    };
  };
}
```

#### Enum Extensions Generator

```typescript
// This transformer generates utility methods for enums
function enumUtilsTransformerFactory(): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    return sourceFile => {
      // Find all enum declarations
      const enums: ts.EnumDeclaration[] = [];
      
      function collectEnums(node: ts.Node): void {
        if (ts.isEnumDeclaration(node)) {
          enums.push(node);
        }
        ts.forEachChild(node, collectEnums);
      }
      
      collectEnums(sourceFile);
      
      if (enums.length === 0) {
        return sourceFile;
      }
      
      // Generate utility functions for each enum
      const enumUtils = enums.map(enumDecl => {
        const enumName = enumDecl.name.text;
        
        return `
// Utility functions for ${enumName} enum
namespace ${enumName} {
  export function toArray(): Array<{ key: string; value: ${enumName} }> {
    return Object.keys(${enumName})
      .filter(key => isNaN(Number(key)))
      .map(key => ({ key, value: ${enumName}[key] as unknown as ${enumName} }));
  }

  export function toString(value: ${enumName}): string {
    return ${enumName}[value];
  }

  export function fromString(key: string): ${enumName} | undefined {
    const value = ${enumName}[key as keyof typeof ${enumName}];
    return typeof value === 'number' ? value : undefined;
  }
}`;
      });
      
      // Append the utility functions to the source file
      const updatedText = sourceFile.text + '\n\n' + enumUtils.join('\n\n');
      return ts.createSourceFile(
        sourceFile.fileName,
        updatedText,
        sourceFile.languageVersion,
        true
      );
    };
  };
}
```

### Visitors Pattern

The visitor pattern is central to TypeScript transformers. It provides a structured way to traverse and potentially modify an AST:

#### Advanced AST Visitor

```typescript
import * as ts from "typescript";

// A more structured visitor approach
function createVisitor(context: ts.TransformationContext, typeChecker: ts.TypeChecker) {
  const visitor: ts.Visitor = (node: ts.Node): ts.Node => {
    // Handle different node types
    if (ts.isClassDeclaration(node)) {
      return visitClass(node);
    }
    
    if (ts.isInterfaceDeclaration(node)) {
      return visitInterface(node);
    }
    
    if (ts.isFunctionDeclaration(node)) {
      return visitFunction(node);
    }
    
    // Continue traversal
    return ts.visitEachChild(node, visitor, context);
  };
  
  // Specialized visitors for different node types
  function visitClass(node: ts.ClassDeclaration): ts.ClassDeclaration {
    // Process class declaration
    // For example, add a decorator
    if (!node.modifiers?.some(m => m.kind === ts.SyntaxKind.AbstractKeyword)) {
      const newDecorator = ts.factory.createDecorator(
        ts.factory.createCallExpression(
          ts.factory.createIdentifier('Injectable'),
          undefined,
          []
        )
      );
      
      return ts.factory.updateClassDeclaration(
        node,
        [...(node.decorators || []), newDecorator],
        node.modifiers,
        node.name,
        node.typeParameters,
        node.heritageClauses,
        node.members
      );
    }
    
    return node;
  }
  
  function visitInterface(node: ts.InterfaceDeclaration): ts.InterfaceDeclaration {
    // Process interface declaration
    return node;
  }
  
  function visitFunction(node: ts.FunctionDeclaration): ts.FunctionDeclaration {
    // Process function declaration
    return node;
  }
  
  return visitor;
}

function myTransformerFactory(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    const typeChecker = program.getTypeChecker();
    const visitor = createVisitor(context, typeChecker);
    
    return sourceFile => {
      return ts.visitNode(sourceFile, visitor) as ts.SourceFile;
    };
  };
}
```

#### Type-Aware Visitor

```typescript
import * as ts from "typescript";

// A visitor that utilizes TypeScript's type system
function createTypeAwareVisitor(
  context: ts.TransformationContext,
  typeChecker: ts.TypeChecker
) {
  const visitor: ts.Visitor = (node: ts.Node): ts.Node => {
    // Inspect function calls
    if (ts.isCallExpression(node)) {
      const signature = typeChecker.getResolvedSignature(node);
      if (signature) {
        const returnType = typeChecker.getReturnTypeOfSignature(signature);
        const typeString = typeChecker.typeToString(returnType);
        
        // Example: Add type assertion to Promise-returning functions
        if (typeString.includes('Promise<')) {
          return ts.factory.createAsExpression(
            node,
            ts.factory.createTypeReferenceNode(
              ts.factory.createIdentifier(typeString),
              undefined
            )
          );
        }
      }
    }
    
    // Continue traversal
    return ts.visitEachChild(node, visitor, context);
  };
  
  return visitor;
}
```

### Source Code Manipulation

Transformers excel at modifying source code in sophisticated ways:

#### Property Decorator Transformer

```typescript
function propertyDecoratorTransformerFactory(): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    const { factory } = context;
    
    return sourceFile => {
      function visit(node: ts.Node): ts.Node {
        // Find class property with @logger decorator
        if (
          ts.isPropertyDeclaration(node) && 
          node.decorators?.some(d => 
            ts.isIdentifier(d.expression) && 
            d.expression.text === 'logger'
          )
        ) {
          // Get property name
          const propName = node.name.getText(sourceFile);
          
          // Create getter and setter with logging
          const getter = factory.createGetAccessorDeclaration(
            undefined,
            node.modifiers,
            node.name,
            [],
            node.type,
            factory.createBlock([
              factory.createReturnStatement(
                factory.createPropertyAccessExpression(
                  factory.createThis(),
                  factory.createIdentifier(`_${propName}`)
                )
              )
            ])
          );
          
          const setterParam = factory.createParameterDeclaration(
            undefined,
            undefined,
            undefined,
            factory.createIdentifier('value'),
            undefined,
            node.type
          );
          
          const setter = factory.createSetAccessorDeclaration(
            undefined,
            node.modifiers,
            node.name,
            [setterParam],
            factory.createBlock([
              factory.createExpressionStatement(
                factory.createCallExpression(
                  factory.createPropertyAccessExpression(
                    factory.createIdentifier('console'),
                    factory.createIdentifier('log')
                  ),
                  undefined,
                  [
                    factory.createStringLiteral(`Setting ${propName}:`),
                    factory.createIdentifier('value')
                  ]
                )
              ),
              factory.createExpressionStatement(
                factory.createBinaryExpression(
                  factory.createPropertyAccessExpression(
                    factory.createThis(),
                    factory.createIdentifier(`_${propName}`)
                  ),
                  factory.createToken(ts.SyntaxKind.EqualsToken),
                  factory.createIdentifier('value')
                )
              )
            ])
          );
          
          // Create the private backing field
          const backingField = factory.createPropertyDeclaration(
            undefined,
            [factory.createModifier(ts.SyntaxKind.PrivateKeyword)],
            factory.createIdentifier(`_${propName}`),
            undefined,
            node.type,
            node.initializer
          );
          
          // Return an array of nodes to replace the original node
          return [backingField, getter, setter];
        }
        
        return ts.visitEachChild(node, visit, context);
      }
      
      return ts.visitNode(sourceFile, visit);
    };
  };
}
```

#### Import Organizer Transformer

```typescript
function importOrganizerFactory(): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    return sourceFile => {
      // Collect all imports
      const imports: ts.ImportDeclaration[] = [];
      const nonImportNodes: ts.Node[] = [];
      
      // Separate import statements from other nodes
      sourceFile.statements.forEach(node => {
        if (ts.isImportDeclaration(node)) {
          imports.push(node);
        } else {
          nonImportNodes.push(node);
        }
      });
      
      if (imports.length <= 1) {
        return sourceFile; // No need to reorganize
      }
      
      // Sort imports by module specifier
      const sortedImports = [...imports].sort((a, b) => {
        const textA = (a.moduleSpecifier as ts.StringLiteral).text;
        const textB = (b.moduleSpecifier as ts.StringLiteral).text;
        
        // Built-in modules first
        const aIsBuiltin = !textA.startsWith('./') && !textA.startsWith('../');
        const bIsBuiltin = !textB.startsWith('./') && !textB.startsWith('../');
        
        if (aIsBuiltin && !bIsBuiltin) return -1;
        if (!aIsBuiltin && bIsBuiltin) return 1;
        
        // Alphabetical sort
        return textA.localeCompare(textB);
      });
      
      // Create a new source file with sorted imports
      const newStatements = [...sortedImports, ...nonImportNodes];
      
      return ts.factory.updateSourceFile(
        sourceFile,
        newStatements,
        sourceFile.isDeclarationFile,
        sourceFile.referencedFiles,
        sourceFile.typeReferenceDirectives,
        sourceFile.hasNoDefaultLib,
        sourceFile.libReferenceDirectives
      );
    };
  };
}
```

### Practical Transformer Examples

#### JSX Component Analyzer

```typescript
function jsxAnalyzerFactory(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    const typeChecker = program.getTypeChecker();
    
    return sourceFile => {
      // Skip non-JSX files
      if (!sourceFile.fileName.endsWith('.tsx')) {
        return sourceFile;
      }
      
      const componentInfo: {
        name: string;
        props: Array<{ name: string; type: string; required: boolean }>;
      }[] = [];
      
      function visit(node: ts.Node) {
        // Look for function components or class components
        if (ts.isFunctionDeclaration(node) && node.name) {
          analyzeComponent(node.name.text, node);
        } else if (
          ts.isVariableStatement(node) && 
          node.declarationList.declarations.length === 1
        ) {
          const declaration = node.declarationList.declarations[0];
          if (
            ts.isIdentifier(declaration.name) && 
            declaration.initializer && 
            ts.isArrowFunction(declaration.initializer)
          ) {
            analyzeComponent(declaration.name.text, declaration.initializer);
          }
        } else if (
          ts.isClassDeclaration(node) && 
          node.name &&
          node.heritageClauses?.some(clause => 
            clause.types.some(type => {
              const text = type.expression.getText(sourceFile);
              return text.includes('Component') || text.includes('PureComponent');
            })
          )
        ) {
          analyzeComponent(node.name.text, node);
        }
        
        ts.forEachChild(node, visit);
      }
      
      function analyzeComponent(name: string, node: ts.Node) {
        // Find the props parameter/type
        let propsType: ts.Type | undefined;
        
        if (ts.isFunctionLike(node) && node.parameters.length > 0) {
          const propsParam = node.parameters[0];
          if (propsParam.type) {
            propsType = typeChecker.getTypeAtLocation(propsParam.type);
          }
        } else if (ts.isClassDeclaration(node)) {
          // For class components, find the Props generic type
          const heritageClause = node.heritageClauses?.[0];
          if (heritageClause && heritageClause.types.length > 0) {
            const baseType = heritageClause.types[0];
            if (baseType.typeArguments?.[0]) {
              propsType = typeChecker.getTypeAtLocation(baseType.typeArguments[0]);
            }
          }
        }
        
        if (!propsType) return;
        
        // Extract props information
        const props: Array<{ name: string; type: string; required: boolean }> = [];
        
        const properties = typeChecker.getPropertiesOfType(propsType);
        properties.forEach(property => {
          const propType = typeChecker.getTypeOfSymbolAtLocation(
            property, 
            sourceFile
          );
          
          const isOptional = (property.flags & ts.SymbolFlags.Optional) !== 0;
          
          props.push({
            name: property.name,
            type: typeChecker.typeToString(propType),
            required: !isOptional
          });
        });
        
        if (props.length > 0) {
          componentInfo.push({ name, props });
        }
      }
      
      visit(sourceFile);
      
      // Generate documentation as a comment at the end of the file
      if (componentInfo.length > 0) {
        const componentDocs = componentInfo.map(comp => {
          const propsTable = comp.props.map(prop => 
            `| ${prop.name} | ${prop.type} | ${prop.required ? 'Yes' : 'No'} |`
          ).join('\n');
          
          return `
/*
 * Component: ${comp.name}
 * Props:
 * | Name | Type | Required |
 * |------|------|----------|
 ${propsTable}
 */`;
        }).join('\n');
        
        const updatedText = sourceFile.text + '\n\n' + componentDocs;
        return ts.createSourceFile(
          sourceFile.fileName,
          updatedText,
          sourceFile.languageVersion,
          true
        );
      }
      
      return sourceFile;
    };
  };
}
```

#### Runtime Type Check Injector

```typescript
function typeCheckInjectorFactory(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    const typeChecker = program.getTypeChecker();
    const factory = context.factory;
    
    return sourceFile => {
      // Skip declaration files
      if (sourceFile.isDeclarationFile) {
        return sourceFile;
      }
      
      function visit(node: ts.Node): ts.Node {
        // Target function declarations with @typeCheck comment
        if (
          ts.isFunctionDeclaration(node) && 
          node.name &&
          hasTypeCheckComment(node, sourceFile)
        ) {
          return injectTypeChecks(node);
        }
        
        return ts.visitEachChild(node, visit, context);
      }
      
      function hasTypeCheckComment(node: ts.Node, sourceFile: ts.SourceFile): boolean {
        const commentRanges = ts.getLeadingCommentRanges(
          sourceFile.text, 
          node.pos
        );
        
        if (!commentRanges) return false;
        
        return commentRanges.some(range => {
          const comment = sourceFile.text.substring(range.pos, range.end);
          return comment.includes('@typeCheck');
        });
      }
      
      function injectTypeChecks(node: ts.FunctionDeclaration): ts.FunctionDeclaration {
        if (!node.parameters.length || !node.body) {
          return node;
        }
        
        // Generate runtime checks for each parameter
        const typeCheckStatements: ts.Statement[] = [];
        
        node.parameters.forEach(param => {
          if (!param.type || !ts.isIdentifier(param.name)) {
            return;
          }
          
          const paramName = param.name.text;
          const paramType = typeChecker.getTypeAtLocation(param.type);
          
          // Create runtime type checks based on TypeScript types
          if (paramType.flags & ts.TypeFlags.String) {
            typeCheckStatements.push(createTypeCheck(paramName, 'string'));
          } else if (paramType.flags & ts.TypeFlags.Number) {
            typeCheckStatements.push(createTypeCheck(paramName, 'number'));
          } else if (paramType.flags & ts.TypeFlags.Boolean) {
            typeCheckStatements.push(createTypeCheck(paramName, 'boolean'));
          } else if (paramType.flags & ts.TypeFlags.Object) {
            // For objects, check if it's an array or a regular object
            const typeString = typeChecker.typeToString(paramType);
            
            if (typeString.endsWith('[]') || typeString === 'Array<any>') {
              typeCheckStatements.push(createArrayCheck(paramName));
            } else {
              typeCheckStatements.push(createObjectCheck(paramName));
            }
          }
        });
        
        // If no checks were generated, return the original node
        if (typeCheckStatements.length === 0) {
          return node;
        }
        
        // Create a new function body with type checks at the beginning
        const newBody = factory.createBlock(
          [...typeCheckStatements, ...node.body.statements],
          true
        );
        
        return factory.updateFunctionDeclaration(
          node,
          node.decorators,
          node.modifiers,
          node.asteriskToken,
          node.name,
          node.typeParameters,
          node.parameters,
          node.type,
          newBody
        );
      }
      
      function createTypeCheck(paramName: string, expectedType: string): ts.Statement {
        // Create: if (typeof paramName !== 'expectedType') throw new Error(...)
        return factory.createIfStatement(
          factory.createBinaryExpression(
            factory.createTypeOfExpression(
              factory.createIdentifier(paramName)
            ),
            factory.createToken(ts.SyntaxKind.ExclamationEqualsEqualsToken),
            factory.createStringLiteral(expectedType)
          ),
          factory.createThrowStatement(
            factory.createNewExpression(
              factory.createIdentifier('Error'),
              undefined,
              [factory.createStringLiteral(
                `Parameter '${paramName}' must be of type '${expectedType}'`
              )]
            )
          ),
          undefined
        );
      }
      
      function createArrayCheck(paramName: string): ts.Statement {
        // Create: if (!Array.isArray(paramName)) throw new Error(...)
        return factory.createIfStatement(
          factory.createPrefixUnaryExpression(
            ts.SyntaxKind.ExclamationToken,
            factory.createCallExpression(
              factory.createPropertyAccessExpression(
                factory.createIdentifier('Array'),
                factory.createIdentifier('isArray')
              ),
              undefined,
              [factory.createIdentifier(paramName)]
            )
          ),
          factory.createThrowStatement(
            factory.createNewExpression(
              factory.createIdentifier('Error'),
              undefined,
              [factory.createStringLiteral(
                `Parameter '${paramName}' must be an array`
              )]
            )
          ),
          undefined
        );
      }
      
      function createObjectCheck(paramName: string): ts.Statement {
        // Create: if (paramName === null || typeof paramName !== 'object') throw new Error(...)
        return factory.createIfStatement(
          factory.createBinaryExpression(
            factory.createBinaryExpression(
              factory.createIdentifier(paramName),
              factory.createToken(ts.SyntaxKind.EqualsEqualsEqualsToken),
              factory.createNull()
            ),
            factory.createToken(ts.SyntaxKind.BarBarToken),
            factory.createBinaryExpression(
              factory.createTypeOfExpression(
                factory.createIdentifier(paramName)
              ),
              factory.createToken(ts.SyntaxKind.ExclamationEqualsEqualsToken),
              factory.createStringLiteral('object')
            )
          ),
          factory.createThrowStatement(
            factory.createNewExpression(
              factory.createIdentifier('Error'),
              undefined,
              [factory.createStringLiteral(
                `Parameter '${paramName}' must be an object`
              )]
            )
          ),
          undefined
        );
      }
      
      return ts.visitNode(sourceFile, visit);
    };
  };
}
```

### Building a Custom Transformer Pipeline

For complex transformations, it's often useful to build a pipeline of transformers:

```typescript
// transformer-pipeline.ts
import * as ts from "typescript";
import * as path from "path";
import * as fs from "fs";

// Import custom transformers
import { importOrganizerFactory } from "./transformers/import-organizer";
import { propertyDecoratorTransformerFactory } from "./transformers/property-decorator";
import { enumUtilsTransformerFactory } from "./transformers/enum-utils";

export function createTransformerProgram(
  rootFileNames: string[],
  options: ts.CompilerOptions,
  host?: ts.CompilerHost
) {
  // Create the TypeScript program
  const program = ts.createProgram(rootFileNames, options, host);
  
  // Define transformer factories
  const transformerFactories: ts.TransformerFactory<ts.SourceFile>[] = [
    importOrganizerFactory(),
    propertyDecoratorTransformerFactory(),
    enumUtilsTransformerFactory()
  ];
  
  // Create the emit function
  const emit = (writeFile?: ts.WriteFileCallback) => {
    const emitResult = program.emit(
      undefined, // sourceFile - undefined means all files
      writeFile,
      undefined, // cancellationToken
      false,     // emitOnlyDtsFiles
      {
        before: transformerFactories
      }
    );
    
    // Return diagnostics and emitResult
    const diagnostics = ts.getPreEmitDiagnostics(program).concat(emitResult.diagnostics);
    return {
      diagnostics,
      emitResult
    };
  };
  
  return {
    program,
    emit
  };
}

// Usage
const { program, emit } = createTransformerProgram(
  ["./src/index.ts"],
  {
    target: ts.ScriptTarget.ES2020,
    module: ts.ModuleKind.ESNext,
    outDir: "./dist"
  }
);

emit((fileName, text) => {
  fs.mkdirSync(path.dirname(fileName), { recursive: true });
  fs.writeFileSync(fileName, text);
});
```

### Integration with Build Tools

#### Webpack Integration

```typescript
// webpack.config.js
const path = require('path');

module.exports = {
  entry: './src/index.ts',
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: [
          {
            loader: 'ts-loader',
            options: {
              getCustomTransformers: program => ({
                before: [
                  require('./transformers/my-transformer').default(program)
                ]
              })
            }
          }
        ],
        exclude: /node_modules/
      }
    ]
  },
  resolve: {
    extensions: ['.tsx', '.ts', '.js']
  },
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist')
  }
};
```

#### Rollup Integration

```javascript
// rollup.config.js
import typescript from '@rollup/plugin-typescript';
import { defineConfig } from 'rollup';
import path from 'path';
import { myTransformerFactory } from './transformers/my-transformer';

/**
 * Rollup config using a custom TypeScript transformer
 */
export default defineConfig({
  input: 'src/index.ts',
  output: {
    file: 'dist/bundle.js',
    format: 'esm',
    sourcemap: true // optional, but useful for debugging
  },
  plugins: [
    typescript({
      tsconfig: './tsconfig.json',
      transformers: {
        before: [myTransformerFactory]
      },
      // Ensures declaration files are emitted if needed
      declaration: true,
      declarationDir: path.resolve(__dirname, 'dist/types')
    })
  ]
});
```

**Notes:**

- `@rollup/plugin-typescript` uses the TypeScript compiler under the hood and allows customization via transformers.
- The `transformers.before` option hooks into the **TypeScript compiler pipeline**, inserting your transformer **before** the standard ones like type checking.
- `myTransformerFactory` should export a factory function that returns a `ts.TransformerFactory<ts.SourceFile>`.
    

---

**Example Transformer (Optional Reference):**

```ts
// transformers/my-transformer.ts
import * as ts from 'typescript';

export function myTransformerFactory(): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    return sourceFile => {
      // Example: log and return file unmodified
      console.log(`Transforming: ${sourceFile.fileName}`);
      return sourceFile;
    };
  };
}
```

### Debugging Custom Transformers

Debugging TypeScript transformers can be challenging since they operate during the compilation process. Having proper debugging strategies is essential for transformer development.

**Key Points**

- Transformers operate at compile time, making them difficult to debug with regular tools
- Using logging and inspection techniques is crucial
- TypeScript provides diagnostic tools to help debug transformers
- Testing transformers in isolation simplifies debugging

Effective techniques for debugging custom transformers:

1. Console logging approach:
    
    ```typescript
    function createTransformer(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
      return context => {
        return sourceFile => {
          console.log(`Processing file: ${sourceFile.fileName}`);
          // Add more logging as needed
          return ts.visitNode(sourceFile, createVisitor(context, program));
        };
      };
    }
    ```
    
2. Print AST nodes:
    
    ```typescript
    function printNode(node: ts.Node): void {
      console.log({
        kind: ts.SyntaxKind[node.kind],
        pos: node.pos,
        end: node.end,
        text: node.getText(),
        flags: node.flags
      });
    }
    ```
    
3. Using TypeScript's debugging emit feature:
    
    ```typescript
    const result = ts.transform(sourceFile, [myTransformer], {
      debugMode: true
    });
    ```
    
4. Writing AST snapshots to files:
    
    ```typescript
    import * as fs from 'fs';
    
    function debugTransformerOutput(node: ts.Node, stage: string): void {
      const printer = ts.createPrinter({ newLine: ts.NewLineKind.LineFeed });
      const output = printer.printNode(
        ts.EmitHint.Unspecified,
        node,
        node.getSourceFile()
      );
      
      fs.writeFileSync(
        `debug-output-${stage}-${Date.now()}.ts`,
        output,
        'utf8'
      );
    }
    ```
    
5. Creating unit tests for transformers:
    
    ```typescript
    import * as ts from 'typescript';
    
    function testTransformer(
      input: string,
      transformer: ts.TransformerFactory<ts.SourceFile>
    ): string {
      const sourceFile = ts.createSourceFile(
        'test.ts',
        input,
        ts.ScriptTarget.Latest,
        true
      );
      
      const result = ts.transform(sourceFile, [transformer]);
      const printer = ts.createPrinter();
      
      return printer.printFile(result.transformed[0]);
    }
    
    const input = `function test() { console.log("Hello"); }`;
    const output = testTransformer(input, myCustomTransformer);
    console.log(output);
    ```
    

### Performance Considerations

When writing custom transformers, performance is a critical consideration as they can significantly impact build times.

**Key Points**

- Transformers run during every compilation, affecting build performance
- Inefficient transformers can cause major slowdowns in large projects
- Caching and memoization techniques can improve performance
- Node visit strategies affect performance significantly

Performance optimization techniques:

1. Use node maps for caching:
    
    ```typescript
    function createTransformer(): ts.TransformerFactory<ts.SourceFile> {
      // Cache processed nodes
      const processedNodes = new Map<ts.Node, ts.Node>();
      
      return context => {
        return sourceFile => {
          // Visitor function with caching
          const visitor: ts.Visitor = (node: ts.Node): ts.Node => {
            // Check cache first
            if (processedNodes.has(node)) {
              return processedNodes.get(node)!;
            }
            
            // Process the node
            let result = node;
            if (shouldTransform(node)) {
              result = transformNode(node);
            }
            
            // Cache result
            processedNodes.set(node, result);
            return result;
          };
          
          return ts.visitEachChild(sourceFile, visitor, context);
        };
      };
    }
    ```
    
2. Skip unnecessary node traversals:
    
    ```typescript
    function visitor(node: ts.Node): ts.Node {
      // Early exit condition
      if (!affectsThisNodeType(node)) {
        return node;
      }
      
      // Only recurse when necessary
      if (mightContainRelevantNodes(node)) {
        return ts.visitEachChild(node, visitor, context);
      }
      
      return node;
    }
    ```
    
3. Use TypeScript's incremental API:
    
    ```typescript
    const host = ts.createIncrementalCompilerHost(compilerOptions);
    const program = ts.createIncrementalProgram({
      rootNames: ['./src/index.ts'],
      options: compilerOptions,
      host
    });
    
    // Use transformer with incremental program
    const emitResult = program.emit(
      undefined, 
      undefined, 
      undefined, 
      undefined, 
      { before: [myTransformer] }
    );
    ```
    
4. Profile transformer performance:
    
    ```typescript
    function createProfiledTransformer(
      transformer: ts.TransformerFactory<ts.SourceFile>
    ): ts.TransformerFactory<ts.SourceFile> {
      return context => {
        return sourceFile => {
          const start = process.hrtime.bigint();
          const result = transformer(context)(sourceFile);
          const end = process.hrtime.bigint();
          
          console.log(
            `Transformer execution time for ${sourceFile.fileName}: 
            ${Number(end - start) / 1000000}ms`
          );
          
          return result;
        };
      };
    }
    ```
    

### Type-Aware Transformations

TypeScript transformers can leverage the type system to make more intelligent code transformations.

**Key Points**

- Type-aware transformers have access to the full TypeScript type system
- They can make transformation decisions based on inferred types
- This enables more powerful and precise transformations
- Type checking ensures transformations maintain type safety

Implementing type-aware transformers:

```typescript
function createTypeAwareTransformer(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
  // Get the type checker from the program
  const typeChecker = program.getTypeChecker();
  
  return context => {
    return sourceFile => {
      const visitor: ts.Visitor = node => {
        // Example: Transform only function calls with string arguments
        if (ts.isCallExpression(node)) {
          const signature = typeChecker.getResolvedSignature(node);
          if (signature) {
            const paramTypes = signature.getParameters().map(param => 
              typeChecker.getTypeOfSymbolAtLocation(param, node)
            );
            
            // Check if the first parameter is a string type
            if (paramTypes.length > 0 && 
                typeChecker.typeToString(paramTypes[0]) === 'string') {
              // Transform the call expression
              return transformStringFunctionCall(node, context);
            }
          }
        }
        
        return ts.visitEachChild(node, visitor, context);
      };
      
      return ts.visitNode(sourceFile, visitor);
    };
  };
}

function transformStringFunctionCall(
  node: ts.CallExpression, 
  context: ts.TransformationContext
): ts.Expression {
  // Transformation logic here
  // For example, add string validation
  if (node.arguments.length > 0 && ts.isStringLiteralLike(node.arguments[0])) {
    // Create a validation wrapper
    const validateFn = ts.factory.createIdentifier('validateString');
    return ts.factory.createCallExpression(
      node.expression,
      node.typeArguments,
      [
        ts.factory.createCallExpression(
          validateFn,
          undefined,
          [node.arguments[0]]
        ),
        ...node.arguments.slice(1)
      ]
    );
  }
  
  return node;
}
```

### Error Handling in Transformers

Proper error handling in transformers ensures that compilation failures provide meaningful diagnostics rather than cryptic errors.

**Key Points**

- Transformer errors can be difficult to trace and debug
- Well-structured error handling improves developer experience
- TypeScript provides diagnostic reporting mechanisms
- Custom error handling can catch and report transformer-specific issues

Implementing robust error handling:

```typescript
function createTransformerWithErrorHandling(
  program: ts.Program
): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    return sourceFile => {
      try {
        // Store original source file for error reporting
        const originalFileName = sourceFile.fileName;
        
        const visitor: ts.Visitor = node => {
          try {
            // Transformation logic that might throw
            if (shouldTransform(node)) {
              return transformNode(node);
            }
            
            return ts.visitEachChild(node, visitor, context);
          } catch (error) {
            // Create diagnostic info including node position
            const { line, character } = 
              sourceFile.getLineAndCharacterOfPosition(node.getStart());
            
            const diagnostic: ts.Diagnostic = {
              category: ts.DiagnosticCategory.Error,
              code: 9999, // Custom error code
              file: sourceFile,
              start: node.getStart(),
              length: node.getWidth(),
              messageText: `Transformer error: ${error.message} at ${line}:${character}`
            };
            
            // Report the diagnostic
            context.addDiagnostic(diagnostic);
            
            // Return original node to continue compilation
            return node;
          }
        };
        
        return ts.visitNode(sourceFile, visitor);
      } catch (error) {
        // Handle source file level errors
        console.error(`Fatal transformer error in ${sourceFile.fileName}: ${error.message}`);
        // Return original source file to continue compilation
        return sourceFile;
      }
    };
  };
}
```

### Custom Transformer Testing Strategies

Comprehensive testing strategies ensure transformers work correctly across different TypeScript versions and code patterns.

**Key Points**

- Testing transformers requires different approaches than regular code
- Unit tests should verify both the transformation result and preserved functionality
- Integration tests ensure transformers work with the build pipeline
- Testing against multiple TypeScript versions ensures compatibility

Testing approach examples:

1. Basic unit testing framework:

```typescript
import * as ts from 'typescript';
import * as assert from 'assert';

function testTransformer(
  transformer: ts.TransformerFactory<ts.SourceFile>,
  inputCode: string,
  expectedOutputCode: string
) {
  // Create a source file from input code
  const sourceFile = ts.createSourceFile(
    'test.ts',
    inputCode,
    ts.ScriptTarget.Latest,
    true
  );
  
  // Apply the transformer
  const result = ts.transform(sourceFile, [transformer]);
  const transformedSourceFile = result.transformed[0];
  
  // Print the result
  const printer = ts.createPrinter();
  const actual = printer.printFile(transformedSourceFile);
  
  // Normalize whitespace for comparison
  const normalizedActual = actual.replace(/\s+/g, ' ').trim();
  const normalizedExpected = expectedOutputCode.replace(/\s+/g, ' ').trim();
  
  // Assert equality
  assert.strictEqual(normalizedActual, normalizedExpected);
}

// Example test
testTransformer(
  myTransformer,
  `function hello() { return "world"; }`,
  `function hello() { console.log("Transformed"); return "world"; }`
);
```

2. Testing compiled output execution:

```typescript
function testTransformerExecution(
  transformer: ts.TransformerFactory<ts.SourceFile>,
  inputCode: string,
  expectedOutput: any
) {
  // Apply transformer
  const sourceFile = ts.createSourceFile(
    'test.ts',
    inputCode,
    ts.ScriptTarget.Latest,
    true
  );
  
  const result = ts.transform(sourceFile, [transformer]);
  const transformedSourceFile = result.transformed[0];
  
  // Print to JavaScript
  const printer = ts.createPrinter();
  const jsCode = printer.printFile(transformedSourceFile);
  
  // Execute the transformed code
  const executeResult = new Function(`
    ${jsCode}
    return test();
  `)();
  
  // Verify the execution result
  assert.deepStrictEqual(executeResult, expectedOutput);
}
```

3. Snapshot testing approach:

```typescript
import * as fs from 'fs';
import * as path from 'path';

function snapshotTest(
  transformer: ts.TransformerFactory<ts.SourceFile>,
  testName: string,
  inputCode: string
) {
  const sourceFile = ts.createSourceFile(
    'test.ts',
    inputCode,
    ts.ScriptTarget.Latest,
    true
  );
  
  const result = ts.transform(sourceFile, [transformer]);
  const printer = ts.createPrinter();
  const actual = printer.printFile(result.transformed[0]);
  
  const snapshotDir = path.join(__dirname, '__snapshots__');
  fs.mkdirSync(snapshotDir, { recursive: true });
  
  const snapshotPath = path.join(snapshotDir, `${testName}.snap`);
  
  if (process.env.UPDATE_SNAPSHOTS === 'true' || !fs.existsSync(snapshotPath)) {
    fs.writeFileSync(snapshotPath, actual, 'utf8');
    console.log(`Updated snapshot: ${testName}`);
  } else {
    const expected = fs.readFileSync(snapshotPath, 'utf8');
    assert.strictEqual(
      actual, 
      expected, 
      `Transformer output doesn't match snapshot for "${testName}"`
    );
    console.log(`Passed: ${testName}`);
  }
}
```

### Security Considerations

Custom transformers can introduce security risks if they're not carefully designed, especially when processing untrusted code.

**Key Points**

- Transformers can inject code, potentially introducing vulnerabilities
- Input validation is critical when transforming code
- Transformers should avoid executing untrusted code during compilation
- Access to certain APIs should be restricted in transformers

Security best practices:

1. Validate inputs:
    
    ```typescript
    function createSecureTransformer(): ts.TransformerFactory<ts.SourceFile> {
      return context => {
        return sourceFile => {
          // Validate source file before transformation
          if (!isValidSourceFile(sourceFile)) {
            // Log warning and return original to avoid transformation
            console.warn(`Skipping potentially unsafe file: ${sourceFile.fileName}`);
            return sourceFile;
          }
          
          return ts.visitNode(sourceFile, createSecureVisitor(context));
        };
      };
    }
    
    function isValidSourceFile(sourceFile: ts.SourceFile): boolean {
      // Implement validation logic
      const hasUnsafePattern = /eval\s*\(|Function\s*\(|new\s+Function\s*\(/g.test(
        sourceFile.getText()
      );
      
      return !hasUnsafePattern;
    }
    ```
    
2. Sanitize generated code:
    
    ```typescript
    function sanitizeExpression(expr: string): string {
      // Remove potential code execution patterns
      return expr
        .replace(/eval\s*\(/g, '/* sanitized */')
        .replace(/new\s+Function/g, '/* sanitized */');
    }
    
    function createSafeStringLiteral(text: string): ts.StringLiteral {
      return ts.factory.createStringLiteral(sanitizeExpression(text));
    }
    ```
    
3. Avoid dynamic code execution in transformers:
    
    ```typescript
    // UNSAFE - never do this in a transformer
    function unsafeTransformer() {
      return context => {
        return sourceFile => {
          // This is extremely dangerous!
          const dynamicConfig = eval(`(${sourceFile.getText()})`);
          
          // Rest of transformer...
        };
      };
    }
    
    // SAFE alternative
    function safeTransformer() {
      return context => {
        return sourceFile => {
          // Use static analysis instead of execution
          const configObject = findConfigObjectInSourceFile(sourceFile);
          
          // Rest of transformer...
        };
      };
    }
    ```
    

### Advanced Plugin Systems

Creating a plugin system for transformers allows for modular, configurable transformations that can be combined and shared.

**Key Points**

- Plugin systems allow composable transformers
- Configuration options can customize transformer behavior
- Plugin discovery mechanisms enable dynamic loading
- Well-designed APIs simplify transformer development

Example of a transformer plugin system:

```typescript
// Plugin interface
interface TransformerPlugin {
  name: string;
  version: string;
  factory: (config?: any) => ts.TransformerFactory<ts.SourceFile>;
}

// Plugin registry
class TransformerPluginRegistry {
  private plugins = new Map<string, TransformerPlugin>();
  
  register(plugin: TransformerPlugin): void {
    this.plugins.set(plugin.name, plugin);
  }
  
  getPlugin(name: string): TransformerPlugin | undefined {
    return this.plugins.get(name);
  }
  
  createTransformerFactories(config: {
    [pluginName: string]: any
  }): Array<ts.TransformerFactory<ts.SourceFile>> {
    const factories: Array<ts.TransformerFactory<ts.SourceFile>> = [];
    
    for (const [name, pluginConfig] of Object.entries(config)) {
      const plugin = this.getPlugin(name);
      if (plugin) {
        factories.push(plugin.factory(pluginConfig));
      } else {
        console.warn(`Plugin "${name}" not found, skipping`);
      }
    }
    
    return factories;
  }
}

// Plugin usage
const registry = new TransformerPluginRegistry();

// Register plugins
registry.register({
  name: 'logger',
  version: '1.0.0',
  factory: (config = {}) => createLoggerTransformer(config)
});

registry.register({
  name: 'autoImport',
  version: '1.0.0',
  factory: (config = {}) => createAutoImportTransformer(config)
});

// Create transformers from config
const transformers = registry.createTransformerFactories({
  logger: { level: 'debug' },
  autoImport: { imports: ['react', 'lodash'] }
});

// Use with TypeScript compiler
const program = ts.createProgram(['./src/index.ts'], compilerOptions);
const emitResult = program.emit(
  undefined, 
  undefined, 
  undefined, 
  undefined, 
  { before: transformers }
);
```

These additional sections complete the comprehensive overview of TypeScript Custom Transformations, providing deeper insights into advanced techniques, performance optimization, debugging strategies, and practical patterns for large-scale transformer development.

---

