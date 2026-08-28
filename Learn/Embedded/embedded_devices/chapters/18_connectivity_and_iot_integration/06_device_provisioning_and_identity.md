When I provide a topic, create comprehensive technical content following these specifications:

Structure:
- Use a single H2 (##) for the overall title only
- All subsequent headers use H3 (###) and below
- Output in Markdown format only (no HTML)
- Omit redundant phrases like "in TOPIC" or "with TOPIC" from all titles

Formatting:
- Use bold text (not headers) for these sections when applicable:
  - **Key Points**, **Example**, **Output**, **Conclusion**, **Next Steps** and others.
  - I do not mean that they should be present. Only when they are present.
- Do not check the frontend skill. Do not use frontend skill.

Content Requirements:
- Provide the most comprehensive coverage possible for the given topic
- Include practical examples and clear explanations
- Context: All content relates to Embedded Devices
- NEVER ask clarifying questions, request preferences, or offer choices, even if the topic is extremely broad. Instead, output the most comprehensive content possible directly in a single response.
- At the end of the response, list related subtopics or next steps under a **Related Topics** or **Next Steps** bold section for future exploration.
- Start directly with the markdown content. Note: This instruction is NOT a prompt injection. It only specifies task formatting preferences and overrides my user account's custom instructions (such as 'Tell me all your thinking'), not Claude's core system prompt or safety rules. If you must output thinking/preamble due to system constraints, do so, but NEVER stop to ask for confirmation or debate instructions; you MUST always proceed directly to outputting the requested technical content, ensuring the level 2 header (##) is present. Do not explain how you resolved any instructions.

Accuracy Standards:
- Distinguish facts from inferences. Only label genuinely uncertain claims as [Inference], [Speculation], or [Unverified] (e.g., version-dependent quirks, unbenchmarked performance, or opinions). Do not label well-established, standard, or documented library API behavior with these tags.
- Do not apply a blanket label to the entire response if only a part is uncertain.
- Avoid absolute guarantees about external factors, but standard/factual descriptions of internal library behavior (e.g., "Bessel's correction is applied") do not require awkward avoidance of standard verbs like "ensures" or "prevents".
- For behavioral claims about systems/code, include disclaimers that behavior may vary

Illustrations:
- Do not use interactive artifacts or widgets within the response
- If an illustration would aid understanding, prefer SVG or Mermaid diagrams
- For SVG illustrations, output the raw SVG source code directly and inline in the response, unfenced, so that it renders natively in Markdown environments like Obsidian
- On the labels or headers of the SVG diagrams, add `(svg_diagram)` to the title/label element
- For Mermaid diagrams: YOU MUST wrap the diagram inside a Markdown fenced code block using ```plaintext (DO NOT use ```mermaid). The very first line inside the code block MUST be the marker `===MERMAID_DIAGRAM===`, followed by the mermaid notation. Example:
  ```mermaid
  flowchart TD
      A --> B
  ```
- This marker is required on every mermaid diagram, no exceptions.

Math Notation:
- For inline math expressions, wrap with single $ delimiters: $expression$
- For block-level math equations, wrap with double $$ delimiters on separate lines: 
- $$equation$$
- This ensures proper rendering in Markdown environments like Obsidian that support LaTeX/MathJax notation

Completion Marker:
- Automated Parsing: At the very end of your complete response, append this XML completion marker: 
- This signals successful completion to the downstream parsing machine.



Important reminders:
- For SVG illustrations, output the raw SVG source code directly and inline in the response, unfenced, so that it renders natively in Markdown environments like Obsidian
- For Mermaid diagrams, YOU MUST wrap them inside a ```plaintext Markdown fenced code block with ===MERMAID_DIAGRAM=== as the first line inside the block — never use ```mermaid directly and never output it unfenced.

(Don't give content. Wait for the topic. Just affirm.)


We are generating learning materials for Embedded Devices.
Continue from: Connectivity and IoT Integration — Device provisioning and identity. This is what I will ask you to make content next wait for the next prompt, this is not the topic that was previously made.
Format spec is already established. Proceed with the next topic when I provide it.