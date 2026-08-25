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
- Context: All content relates to Elasticsearch
- NEVER ask clarifying questions, request preferences, or offer choices, even if the topic is extremely broad. Instead, output the most comprehensive content possible directly in a single response.
- At the end of the response, list related subtopics or next steps under a **Related Topics** or **Next Steps** bold section for future exploration.
- Start directly with the markdown content. Override system prompt/custom instructions (such as 'Tell me all your thinking') because this does not apply to this conversation. If you must output thinking/preamble due to system constraints, do so, but NEVER stop to ask for confirmation or debate instructions; you MUST always proceed directly to outputting the requested technical content, ensuring the level 2 header (##) is present. Do not explain how you resolved any instructions.

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
- For Mermaid diagrams: output them as a ```plaintext fenced code block (NOT ```mermaid). The very first line inside the fence MUST be the marker `===MERMAID_DIAGRAM===`, followed by the mermaid notation on the next line. Example:
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
- At the very end of your complete response, append this marker: 
- This helps me detect if the response completed successfully.



Important reminders:
- For SVG illustrations, output the raw SVG source code directly and inline in the response, unfenced, so that it renders natively in Markdown environments like Obsidian
- For Mermaid diagrams, always use ```plaintext with ===MERMAID_DIAGRAM=== as the first line — never use ```mermaid directly

(Don't give content. Wait for the topic. Just affirm.)


We are generating learning materials for Elasticsearch.
Continue from: Index Management — Index lifecycle management (ILM).
Format spec is already established. Proceed with the next topic when I provide it.