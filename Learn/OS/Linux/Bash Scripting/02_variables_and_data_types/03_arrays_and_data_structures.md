## Arrays and Data Structures


### Indexed Arrays

Indexed arrays in bash use numeric indices starting from zero, providing ordered storage for multiple values. Declaration can be explicit using `declare -a arrayname` or implicit through direct assignment.

Array initialization supports multiple syntaxes. Use `array=(value1 value2 value3)` for space-separated values, or `array=([0]=first [2]=third)` for specific index assignment. Individual elements are assigned with `array[index]=value`.

Element access requires specific syntax: `${array[index]}` retrieves a single element, while `${array[@]}` or `${array[*]}` expands all elements. The difference between `@` and `*` becomes apparent in quoted contexts - `"${array[@]}"` preserves individual elements as separate words, while `"${array[*]}"` creates a single string.

Array length determination uses `${#array[@]}` for total elements or `${#array[index]}` for specific element length. Bash arrays can have gaps, so the highest index may not equal the array length.

**Example**:

```bash
fruits=(apple banana cherry)
fruits[5]=grape
echo ${#fruits[@]}  # Output: 4 (not 6)
echo ${fruits[3]}   # Output: (empty)
```

### Associative Arrays

Associative arrays, available in bash 4.0+, use string keys instead of numeric indices. They must be explicitly declared with `declare -A arrayname` before use.

Key-value assignment follows the syntax `array[key]=value`, supporting complex keys including strings with spaces when properly quoted. Unlike indexed arrays, associative arrays maintain no inherent order.

Retrieval uses the same syntax as indexed arrays: `${array[key]}` for individual values and `${array[@]}` for all values. Key retrieval uses `${!array[@]}` to get all keys as an array.

**Example**:

```bash
declare -A config
config[database_host]="localhost"
config[database_port]=5432
config["application name"]="MyApp"

for key in "${!config[@]}"; do
    echo "$key: ${config[$key]}"
done
```

Associative arrays excel at configuration management, lookup tables, and data mapping scenarios where meaningful keys improve code readability.

### Array Operations and Iteration

Array slicing extracts portions using `${array[@]:start:length}` syntax. The start position is zero-based, and length is optional - omitting it returns all elements from the start position.

Element modification supports pattern-based operations. Use `${array[@]/pattern/replacement}` for substitution across all elements, or `${array[@]#pattern}` for prefix removal.

**Example**:

```bash
files=(file1.txt file2.log file3.txt)
txt_files=("${files[@]%.log}")  # Remove .log extension
echo "${txt_files[@]}"
```

Array appending uses `array+=(new_elements)` syntax, while prepending requires reconstruction: `array=(new_elements "${array[@]}")`. Element removal typically involves rebuilding the array with desired elements.

Iteration patterns vary by need. Simple iteration uses `for element in "${array[@]}"`, while index-based iteration requires `for i in "${!array[@]}"` to access both indices and values.

Sorting arrays requires external tools since bash lacks built-in sorting. Use `readarray -t sorted_array < <(printf '%s\n' "${array[@]}" | sort)` for alphabetical sorting.

### Multi-dimensional Array Simulation

Bash lacks native multi-dimensional arrays, but several simulation techniques provide similar functionality. The most common approach uses delimiter-separated keys in associative arrays.

**Two-dimensional simulation**:

```bash
declare -A matrix
matrix[1,1]="value11"
matrix[1,2]="value12"
matrix[2,1]="value21"
matrix[2,2]="value22"

# Access with constructed keys
row=1; col=2
echo "${matrix[$row,$col]}"
```

Nested array simulation stores array names as values, then uses indirect expansion to access nested elements. This approach requires careful variable naming to avoid conflicts.

**Example**:

```bash
declare -A outer
outer[row1]="inner1"
outer[row2]="inner2"

declare -a inner1=(a b c)
declare -a inner2=(x y z)

# Access nested element
row="row1"
inner_name="${outer[$row]}"
declare -n inner_ref="$inner_name"
echo "${inner_ref[0]}"  # Output: a
```

Flattened indexing converts multi-dimensional coordinates to single indices using mathematical formulas. For a 2D array with width W, index calculation becomes `index = row * W + col`.

### Advanced Array Techniques

Array copying requires careful consideration of array types. Indexed arrays copy with `new_array=("${old_array[@]}")`, while associative arrays need key iteration for proper copying.

**Deep copying associative arrays**:

```bash
declare -A original=([key1]=value1 [key2]=value2)
declare -A copy

for key in "${!original[@]}"; do
    copy["$key"]="${original[$key]}"
done
```

Array comparison lacks built-in operators, requiring custom functions. Element-by-element comparison works for small arrays, while sorted comparison handles larger datasets efficiently.

Sparse arrays in bash naturally support non-contiguous indices. This feature proves useful for implementing hash tables or when working with datasets containing gaps.

**Performance considerations**: Associative arrays generally perform better for key-based lookups, while indexed arrays excel at sequential access. Large arrays may benefit from external tools like `awk` or `sort` for complex operations.

### Practical Applications

Configuration management benefits from associative arrays storing related settings with meaningful keys. This approach improves maintainability compared to multiple individual variables.

Data processing pipelines often use arrays to collect intermediate results before final processing. Array operations enable functional programming patterns within bash scripts.

**Example - Log analysis**:

```bash
declare -A log_counts
while IFS= read -r line; do
    level=$(echo "$line" | cut -d' ' -f3)
    ((log_counts["$level"]++))
done < logfile.txt

for level in "${!log_counts[@]}"; do
    echo "$level: ${log_counts[$level]}"
done
```

**Key points**:

- Always quote array expansions to preserve elements containing spaces
- Use associative arrays for bash 4+ environments when key-based access is needed
- Implement multi-dimensional arrays through key encoding or nested structures
- Consider performance implications when choosing between array types
- Leverage array operations for data transformation and filtering tasks

**Conclusion**: Mastering bash arrays enables sophisticated data manipulation within shell scripts. While bash arrays have limitations compared to other programming languages, understanding their capabilities and workarounds allows for powerful script development. The choice between indexed and associative arrays depends on access patterns and key requirements, while multi-dimensional simulation techniques extend functionality for complex data structures.

---

