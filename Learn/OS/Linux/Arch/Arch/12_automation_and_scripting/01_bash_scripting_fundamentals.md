## Bash Scripting Fundamentals


### Bash Scripting Overview

**Purpose**: Automate tasks, manage system operations, and boost productivity.[1][2]

**Definition**: Bash script is a text file containing commands for the Bash shell.[5]

**Advantages**:[1]
- Automate repetitive tasks[1]
- Combine multiple commands[1]
- Increase efficiency[1]
- Execute on schedule (cron)[1]

**Knowledge Required**: Basic Linux command line understanding.[1]

### Getting Started

#### Shebang Line

**Definition**: First line telling system which interpreter to use.[5][1]

**Standard Shebang**:[1]

```bash
#!/bin/bash
```

**Find bash Path**:[5]

```bash
which bash
```

**Output**: `/bin/bash` or similar.[5]

#### Creating First Script

**Create File**:[5]

```bash
nano hello_world.sh
```

**Simple Script**:[5]

```bash
#!/bin/bash
STRING="Hello World"
echo $STRING
```

**Make Executable**:[5]

```bash
chmod +x hello_world.sh
```

**Run Script**:[5]

```bash
./hello_world.sh
```

**Output**: `Hello World`.[5]

### Variables and Data Types

#### Declaring Variables

**No Type Declaration**:[5]

Bash variables are dynamically typed.[5]

**Basic Assignment**:[1][5]

```bash
#!/bin/bash
variable_name="value"
name="John"
age=25
```

**No Spaces Around Equals**:[5]

Spaces will cause errors.[5]

#### Using Variables

**Access Variable**:[5]

```bash
echo $variable_name
echo ${variable_name}  # Better for complex cases
```

**Variable Substitution**:[1]

```bash
echo "Hello, $name"
```

#### Variable Scope

**Global Variables**: Accessible everywhere.[5]

**Local Variables**: Function-only:[5]

```bash
function my_function() {
    local local_var="local"
}
```

### Input and Output

#### Reading User Input

**read Command**:[1]

```bash
#!/bin/bash
echo "What's your name?"
read entered_name
echo "Welcome, $entered_name"
```

**Multiple Variables**:[1]

```bash
read var1 var2 var3
```

#### Echo Command

**Print Text**:[1]

```bash
echo "Hello, World!"
```

**With Newline**:[1]

```bash
echo "Line 1"
echo "Line 2"
```

**No Newline**:[1]

```bash
echo -n "Text without newline"
```

**Escape Sequences**:[1]

```bash
echo -e "Line 1\nLine 2"  # -e enables interpretation
echo -e "Tab:\tSeparated"
```

#### Redirection

**Redirect to File**:[1]

```bash
echo "Output" > output.txt
```

**Append to File**:[1]

```bash
echo "More output" >> output.txt
```

**Redirect Command Output**:[1]

```bash
ls > files.txt
```

#### Command Line Arguments

**Access Arguments**:[1]

```bash
#!/bin/bash
echo "Hello, $1!"
```

**Usage**:[1]

```bash
./script.sh John
# Output: Hello, John!
```

**Multiple Arguments**:[5]

```bash
$0    # Script name
$1    # First argument
$2    # Second argument
$#    # Total arguments
$@    # All arguments
```

### Conditional Statements

#### if Statements

**Basic if**:[5]

```bash
#!/bin/bash
if [ $age -gt 18 ]; then
    echo "Adult"
fi
```

**if-else**:[5]

```bash
if [ $age -gt 18 ]; then
    echo "Adult"
else
    echo "Minor"
fi
```

**if-elif-else**:[5]

```bash
if [ $age -lt 13 ]; then
    echo "Child"
elif [ $age -lt 18 ]; then
    echo "Teen"
else
    echo "Adult"
fi
```

#### Comparison Operators

**Integer Comparison**:[5]

- `-eq`: Equal[5]
- `-ne`: Not equal[5]
- `-lt`: Less than[5]
- `-le`: Less than or equal[5]
- `-gt`: Greater than[5]
- `-ge`: Greater than or equal[5]

**Examples**:[5]

```bash
[ $a -eq $b ]
[ $x -lt 10 ]
```

**String Comparison**:[5]

- `=`: Equal[5]
- `!=`: Not equal[5]
- `-z`: Empty string[5]
- `-n`: Non-empty[5]

**Examples**:[5]

```bash
[ "$str1" = "$str2" ]
[ -z "$str" ]  # True if empty
```

#### File Tests

**File Exists**:[5]

```bash
if [ -f filename ]; then
    echo "File exists"
fi
```

**Common Tests**:[5]

- `-f`: Regular file[5]
- `-d`: Directory[5]
- `-e`: Exists[5]
- `-r`: Readable[5]
- `-w`: Writable[5]
- `-x`: Executable[5]

### Loops

#### for Loop

**Basic for**:[1][5]

```bash
for i in 1 2 3 4 5; do
    echo $i
done
```

**Sequence**:[5]

```bash
for i in {1..5}; do
    echo $i
done
```

**C-style for**:[5]

```bash
for ((i=1; i<=5; i++)); do
    echo $i
done
```

**Loop Through Files**:[5]

```bash
for file in *.txt; do
    echo $file
done
```

#### while Loop

**Basic while**:[1][5]

```bash
counter=1
while [ $counter -le 5 ]; do
    echo $counter
    ((counter++))
done
```

**Read File**:[1]

```bash
while read line; do
    echo $line
done < input.txt
```

#### until Loop

**Basic until**:[5]

```bash
counter=1
until [ $counter -gt 5 ]; do
    echo $counter
    ((counter++))
done
```

**Opposite of while**:[5]

Continues while condition false.[5]

### Case Statements

#### Basic Case

**Syntax**:[5]

```bash
case $variable in
    pattern1)
        echo "Pattern 1"
        ;;
    pattern2)
        echo "Pattern 2"
        ;;
    *)
        echo "Default"
        ;;
esac
```

**Example**:[5]

```bash
read -p "Enter choice: " choice
case $choice in
    1)
        echo "One"
        ;;
    2)
        echo "Two"
        ;;
    *)
        echo "Invalid"
        ;;
esac
```

### Functions

#### Defining Functions

**Basic Function**:[5]

```bash
function greet() {
    echo "Hello, $1"
}
```

**Alternative Syntax**:[5]

```bash
greet() {
    echo "Hello, $1"
}
```

#### Calling Functions

**Without Arguments**:[5]

```bash
greet
```

**With Arguments**:[5]

```bash
greet "John"
```

#### Return Values

**Return Status**:[5]

```bash
check_file() {
    if [ -f "$1" ]; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}
```

**Check Return**:[5]

```bash
if check_file "file.txt"; then
    echo "File exists"
fi
```

**Return Value**:[5]

```bash
function add() {
    echo $(($1 + $2))
}

result=$(add 5 3)
echo $result  # Output: 8
```

### Arrays

#### Creating Arrays

**Basic Array**:[5]

```bash
fruits=("apple" "banana" "cherry")
```

**Index Assignment**:[5]

```bash
fruits[0]="apple"
fruits[1]="banana"
```

#### Accessing Arrays

**Single Element**:[5]

```bash
echo ${fruits[0]}  # apple
```

**All Elements**:[5]

```bash
echo ${fruits[@]}
```

**Array Length**:[5]

```bash
echo ${#fruits[@]}  # 3
```

**Loop Through Array**:[5]

```bash
for fruit in "${fruits[@]}"; do
    echo $fruit
done
```

### Arithmetic

#### Basic Arithmetic

**Using $(())**:[5]

```bash
result=$((5 + 3))
echo $result  # 8
```

**Operators**:[5]

```bash
$((10 - 5))    # Subtraction
$((4 * 3))     # Multiplication
$((10 / 2))    # Division
$((10 % 3))    # Modulo
$((2 ** 3))    # Exponentiation
```

#### Increment/Decrement

**Increment**:[5]

```bash
((counter++))
((counter+=5))
```

**Decrement**:[5]

```bash
((counter--))
((counter-=2))
```

### Practical Examples

#### Backup Script

**Simple Backup**:[5]

```bash
#!/bin/bash
tar -czf myhome_directory.tar.gz /home/username
```

#### Directory Listing Script

**List and Display**:[1]

```bash
#!/bin/bash
echo "Today is " `date`
echo -e "\nEnter the path to directory"
read the_path
echo -e "\nYour path has the following files and folders:"
ls $the_path
```

#### File Processing

**Process Files**:[1]

```bash
#!/bin/bash
for file in *.txt; do
    echo "Processing $file"
    cat "$file" >> combined.txt
done
```

### Debugging

#### Debug Mode

**Enable Debugging**:[1]

```bash
bash -x script.sh
```

Shows each command before execution.[1]

**Set in Script**:[1]

```bash
#!/bin/bash
set -x  # Enable debugging
# Commands here
set +x  # Disable debugging
```

#### Error Handling

**Check Exit Status**:[1]

```bash
command
if [ $? -ne 0 ]; then
    echo "Command failed"
fi
```

**Stop on Error**:[1]

```bash
#!/bin/bash
set -e  # Exit on any error
```

### Best Practices

**Use Quotes**: Quote variables:[1]

```bash
echo "$variable"  # Good
echo $variable    # Can break with spaces
```

**Check Inputs**: Validate arguments:[1]

```bash
if [ $# -lt 1 ]; then
    echo "Usage: script.sh argument"
    exit 1
fi
```

**Comments**: Document code:[1][5]

```bash
# This is a comment
variable="value"  # Inline comment
```

**Meaningful Names**: Use clear variable names:[5]

```bash
age=25        # Good
a=25          # Bad
```

**Error Messages**: Provide helpful output:[1]

```bash
echo "Error: File not found" >&2
exit 1
```

### Scheduling Scripts with cron

#### Cron Syntax

**Edit Crontab**:[1]

```bash
crontab -e
```

**Minute Hour Day Month DayOfWeek Command**:[1]

```
0 2 * * * /path/to/script.sh
```

**Every 5 Minutes**:[1]

```
*/5 * * * * /path/to/script.sh
```

**Daily at 3 AM**:[1]

```
0 3 * * * /path/to/script.sh
```

This comprehensive bash scripting fundamentals guide provides users with essential knowledge to create automated solutions and manage Arch Linux systems efficiently.

Sources
[1] Bash Scripting Tutorial – Linux Shell Script and Command ... https://www.freecodecamp.org/news/bash-scripting-tutorial-linux-shell-script-and-command-line-for-beginners/
[2] Bash Tutorial https://www.w3schools.com/bash/
[3] Bash Scripting Tutorial for Beginners https://www.youtube.com/watch?v=tK9Oc6AEnR4
[4] Bash Scripting Tutorial for Beginners https://linuxconfig.org/bash-scripting-tutorial-for-beginners
[5] Bash Scripting Tutorial: A Beginner's Guide https://linuxconfig.org/bash-scripting-tutorial
[6] Bash Scripting Tutorial for Beginners https://www.hostinger.com/in/tutorials/bash-scripting-tutorial
[7] Bash Guide for Beginners https://www.tldp.org/LDP/Bash-Beginners-Guide/html/
[8] Free Introduction to Bash Scripting eBook https://github.com/bobbyiliev/introduction-to-bash-scripting
[9] Bash Scripting Tutorial for Beginners https://www.youtube.com/watch?v=PNhq_4d-5ek

