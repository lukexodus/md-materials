#!/usr/bin/env python3
"""
LaTeX Expression Replacer
Fixes common LaTeX syntax issues in Obsidian markdown files
"""

# Hardcoded file paths
INPUT_FILE = "input.md"
OUTPUT_FILE = "output.md"

# Define all replacement pairs
REPLACEMENTS = [
    (r"""$$
\sup_{w \in L(G)} #{\text{parse trees of } w}
$$""", 
     r"""$$
\sup_{w \in L(G)} \#\{\text{parse trees of } w\}
$$"""),

    (r"""$$
# w_1 # w_2 # \cdots # w_k #
$$""", 
     r"""$$
\# w_1 \# w_2 \# \cdots \# w_k \#
$$"""),

    (r"""$$  
L \mapsto { x #^{p |x|} \mid x \in L }  
$$""", 
     r"""$$  
L \mapsto \{ x \#^{p(|x|)} \mid x \in L \}  
$$"""),

    (r"""$$  
x \in L \iff \exists y \in \Sigma^* \text{ with } |y| \le p |x| \text{ and } V x # y = 1  
$$""", 
     r"""$$  
x \in L \iff \exists y \in \Sigma^* \text{ with } |y| \le p(|x|) \text{ and } V(x \# y) = 1  
$$"""),

    (r"""$$  
R_L = { \langle x , y \rangle \mid V x # y = 1 }  
$$""", 
     r"""$$  
R_L = \{ \langle x , y \rangle \mid V(x \# y) = 1 \}  
$$"""),

    (r"""$$  
\text{rev} C = # \text{ of head direction changes}  
$$""", 
     r"""$$  
\text{rev}_C = \# \text{ of head direction changes}  
$$"""),

    (r"""$$  
CTL \subsetneq CTL^_, \quad LTL \subsetneq CTL^_  
$$""", 
     r"""$$  
CTL \subsetneq CTL^*, \quad LTL \subsetneq CTL^*  
$$"""),

    (r"""$$  
\mathsf{REG}_\omega^\mathsf{tree}
# \text{MSO}
\mu\text{-calculus}  
$$""", 
     r"""$$  
\mathsf{REG}_\omega^\mathsf{tree} \subseteq \text{MSO} \subseteq \mu\text{-calculus}  
$$"""),

    (r"""$$  
\mathcal{A} : \Sigma^*{}^_ \to \mathcal{H}  
$$""", 
     r"""$$  
\mathcal{A} : \Sigma^* \to 2^\mathcal{H}  
$$"""),

    (r"""$$  
\llbracket \cdot \rrbracket : Q \to \nu F  
$$""", 
     r"""$$  
\llbracket \cdot \rrbracket : Q \to \nu F  
$$"""),
]

def replace_latex_expressions(input_file, output_file):
    """
    Read input file, apply all replacements, and write to output file.
    """
    try:
        # Read the input file
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        replacement_count = 0
        
        # Apply all replacements
        for old, new in REPLACEMENTS:
            if old in content:
                count = content.count(old)
                content = content.replace(old, new)
                replacement_count += count
                print(f"✓ Replaced {count} occurrence(s) of: {old[:50]}...")
        
        # Write to output file
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(content)
        
        if replacement_count > 0:
            print(f"\n✓ Successfully processed file!")
            print(f"  Total replacements made: {replacement_count}")
            print(f"  Output written to: {output_file}")
        else:
            print("\n⚠ No replacements needed - file may already be correct.")
            print(f"  Output written to: {output_file}")
        
        return True
        
    except FileNotFoundError:
        print(f"✗ Error: Input file '{input_file}' not found.")
        print(f"  Please create the file or update INPUT_FILE in the script.")
        return False
    
    except Exception as e:
        print(f"✗ Error occurred: {e}")
        return False

def main():
    print("LaTeX Expression Replacer")
    print("=" * 50)
    print(f"Input file:  {INPUT_FILE}")
    print(f"Output file: {OUTPUT_FILE}")
    print("=" * 50)
    print()
    
    replace_latex_expressions(INPUT_FILE, OUTPUT_FILE)

if __name__ == "__main__":
    main()
