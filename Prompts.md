## Syllabus

```
Most comprehensive syllabus for learning and mastering TOPIC. Topics only. Modular
```

**Further**

```
CHAPTER-aligned. Modular. Topics only. Continuable, indicate need for continuation if needed. Create most complete and comprehensive syllabus for

TOPIC
ITEMS
```

```
AI Engineering-aligned. Modular. Topics only. Continuable, indicate need for continuation if needed. Create most complete and comprehensive syllabus for
```

---

## Development

**Preliminary prompt V1**:

```
Format: No ordering number prefixes in titles. Make "Key Points", "Example", "Output", "Conclusion", "Next Steps" as bold only. Do not make them as header titles. When I give a topic, give me the most comprehensive content you can give 

Remove the casual talk at the end, except when you have to recommend important subtopics or related topics.

Do not add ordering/numbered prefixes to titles, unless it is a sequence or has a chronology.

Context: <Topic>

Assume the foundations and background are already know. Focus on the topics provided.
```

**Preliminary Prompt V2**

```
When I give a topic, give me the most comprehensive content you can give. Assume the foundations and background are already know. Focus on the topics provided. Header level start at 2 (overall title; the rest is downwards). Only have one overall title i.e. only have one header at level 2. Do not make html. Just md. Do not add "in TOPIC" or "with TOPIC" or similar in the titles, they're redundant. Make "Key Points", "Example", "Output", "Conclusion", "Next Steps" as bold only. Do not make them as header titles. Have no casual talk in the intro or outro.

Context: TOPIC (wait for the topic yet)
```

**Multiple Overall Titles**

```
When each topic I give, give me the most comprehensive content you can give. Assume the foundations and background are already know. Focus on the topics provided. Do not make html. Just md. Do not make html. Just md. Do not add "in TOPIC" or "with TOPIC" or similar in the titles, they're redundant. 

If there are headers such as "Key Points", "Example", "Output", "Conclusion", "Next Steps", make them as bold only. Do not make them as header titles. 

For every succeeding prompt, it will have an overall title (first line) and topics (bulleted; multiple).
For the output, ignore the first line (it is just context). For every topic, format the topic as header level 2 and its content downwards. There are multiple overall titles i.e. multiple header level 2s.

Context: TOPIC (wait for the topic yet)
```

**Single or multiple**

```
For every succeeding prompt, it may have single line/topic or multiple lines/topics. Each line is a topic. For every topic, format the topic as header level 2 and its content downwards.
```

**Refined**

```
When I provide a topic, create comprehensive technical content following these specifications:

**Structure:**

- Use a single H2 (##) for the overall title only
- All subsequent headers use H3 (###) and below
- Output in Markdown format only (no HTML)
- Omit redundant phrases like "in TOPIC" or "with TOPIC" from all titles

**Formatting:**

- Use **bold text** (not headers) for these standard sections when applicable:
    - **Key Points**
    - **Example**
    - **Output**
    - **Conclusion**
    - **Next Steps**

**Content Requirements:**

- Provide the most comprehensive coverage possible for the given topic
- Include practical examples and clear explanations
- Context: All content relates to Software Design Patterns

**Accuracy Standards:**

- Distinguish facts from inferences
- Label uncertain content: [Inference], [Speculation], or [Unverified]
- Avoid absolute guarantees (prevent, ensure, guarantee, will never, fixes, eliminates)
- For behavioral claims about systems/code, include disclaimers that behavior may vary

(Don't give content. Wait for the topic. Just affirm.)
```

---

## CTF

### CTF

#### Syllabus

```
Most comprehensive syllabus for cheatsheet for CTF [Area] using linux. Topics only. Modular.
```

#### Preliminary instruction when starting to prompt each subtopic/s

```
Format:
Let title be header 2, the rest would be header 3 downwards.
When i give a topic, give me the most comprehensive content you can give. Also, remove the casual talk at the end, except when you have to recommend important subtopics or related topics. Do not add ordering/numbered prefixes to titles, unless it is a sequence or has a chronology.

You are a Capture The Flag (CTF) exploitation expert providing detailed technical guidance based on the comprehensive CTF <CTF AREA> syllabus for Linux. For each section I prompt you with, provide focused, practical instruction covering tools, techniques, commands, and methodologies specific to that topic. Structure responses to be immediately actionable during CTF scenarios. When referencing tools, include exact command syntax and common parameter variations. For OS-specific sections, explicitly highlight differences between Linux, Windows, and other contexts. Assume intermediate technical knowledge but explain complex concepts clearly. Label all unverified claims, avoid speculation presented as fact, and cite reliable sources when referencing specific CVEs, tools, or techniques. Prioritize depth over breadth within each module, providing real-world applicable examples.

Below is the first topic.
The first is the overall title.
The following would be its points.

<Topic with points>
```

### Foundations

#### Syllabus

```
I have this syllabus <CTF SYLLABUS>

Created using this prompt:
"Most comprehensive syllabus for cheatsheet for CTF [Area] using linux. Topics only. Modular."

And each subtopic with this preliminary prompt:
"You are a Capture The Flag (CTF) exploitation expert providing detailed technical guidance based on the comprehensive CTF <CTF AREA> syllabus for Linux. For each section I prompt you with, provide focused, practical instruction covering tools, techniques, commands, and methodologies specific to that topic. Structure responses to be immediately actionable during CTF scenarios. When referencing tools, include exact command syntax and common parameter variations. For OS-specific sections, explicitly highlight differences between Linux, Windows, and other contexts. Assume intermediate technical knowledge but explain complex concepts clearly. Label all unverified claims, avoid speculation presented as fact, and cite reliable sources when referencing specific CVEs, tools, or techniques. Prioritize depth over breadth within each module, providing real-world applicable examples."

Give / create for me a most comprehensive syllabus but for the foundations of this topic. That will give me deep knowledge of all the foundations, concepts, ideas, background, etc. The previous syllabus is focused on hands-on, direct application. But for this syllabus, focus on the concepts themselves. For deep understanding. Modular. Topics only.
```

#### Request instruction text for the preliminary prompt for the subtopics

```
Now I will ask you to make the content for each subtopic, one by one for each subtopic. Make me a text containing context and instructions preceded for each prompt.
```

#### Preliminary prompt for Digital Forensics

```
# Instructions for Generating Forensics Foundations Content

## Context

You are creating comprehensive educational content for a **<AREA> Foundations** course. This course focuses on deep conceptual understanding rather than hands-on CTF techniques. The goal is to build theoretical knowledge that underpins practical forensic work.

Each module contains multiple subtopics that need detailed explanation. The content should:

- Explain **concepts, principles, and theory** in depth
- Provide **context and background** for why these concepts matter
- Use **clear examples** to illustrate abstract ideas
- Connect concepts to their **practical implications** in forensics
- Maintain **technical accuracy** while remaining accessible
- Build understanding **progressively** within each subtopic

## Target Audience

- Students with basic technical knowledge
- Individuals preparing for forensic analysis work
- Those seeking deep understanding beyond tool usage
- Learners who want conceptual foundations before hands-on practice

## Content Structure for Each Subtopic

When generating content for a subtopic, include:

1. **Introduction** - What is this concept and why does it matter?
2. **Core Explanation** - Detailed breakdown of the concept itself
3. **Underlying Principles** - The theory or science behind it
4. **Forensic Relevance** - How this applies to forensic investigations
5. **Examples** - Concrete illustrations of the concept
6. **Common Misconceptions** - What people often get wrong
7. **Connections** - How this relates to other forensic concepts
   
**Requirements:**
- Explain the concept with theoretical depth
- Provide clear context for forensic relevance
- Include illustrative examples
- Address common misconceptions
- Maintain technical accuracy
- Label any unverified claims appropriately
- Length: 800-1500 words
  
**Focus on conceptual understanding rather than tool commands or procedures.**

In the succeeding prompts, I will send two lines for each prompt. The first line is the module title. The second line is the subtopic title.

Only focus on giving information on the subtopic assuming that the introduction to the module title is already acquired.

Format:
Let subtopic be the overall title (do not add the module title to the subtopic), formatted as header 2, the rest would be header 3 downwards.
```

#### Preliminary Prompt For Steganography

```
You are an expert educator in steganography, information security, and theoretical computer science. I am working through a comprehensive foundational syllabus on steganography concepts for deep understanding prior to hands-on CTF practice.

Please provide:

1. **Conceptual Overview** (2-3 paragraphs)
   - Define core concepts and terminology
   - Explain the fundamental principles
   - Describe why this topic matters in steganography

2. **Theoretical Foundations** (detailed explanation)
   - Mathematical or logical basis (where applicable)
   - Key theories, laws, or principles
   - Historical development or evolution of concepts
   - Relationships to other topics in the syllabus

3. **Deep Dive Analysis**
   - Detailed mechanisms and how they work
   - Multiple perspectives or approaches
   - Edge cases and boundary conditions
   - Theoretical limitations and trade-offs

4. **Concrete Examples & Illustrations**
   - Thought experiments or analogies
   - Simple numerical examples (where applicable)
   - Visual descriptions or diagrams explained in text
   - Real-world applications or case studies

5. **Connections & Context**
   - How this relates to other subtopics
   - Prerequisites from earlier sections
   - Applications in later advanced topics
   - Interdisciplinary connections

6. **Critical Thinking Questions**
   - 3-5 questions that deepen understanding
   - Questions that challenge assumptions
   - Scenarios for applying concepts

7. **Common Misconceptions**
   - Typical misunderstandings about this topic
   - Clarifications and corrections
   - Subtle distinctions that matter

8. **Further Exploration Paths**
   - Key papers or researchers in this area (if applicable)
   - Related mathematical/theoretical frameworks
   - Advanced topics that build on this foundation

Requirements:
- Prioritize conceptual clarity over technical jargon
- Use precise mathematical notation where appropriate
- Explain all technical terms upon first use
- Build from first principles
- Label any claims that are [Inference], [Speculation], or [Unverified]
- Avoid tutorial-style commands; focus on understanding "why" and "how"
- Assume I have strong general technical knowledge but am new to steganography specifics
- Aim for approximately 1500-2500 words of dense, information-rich content

In the succeeding prompts, I will send two lines for each prompt. The first line is the module title. The second line is the subtopic title.

Only focus on giving information on the subtopic assuming that the introduction to the module title is already acquired.

Format:
Let subtopic be the overall title (do not add the module title to the subtopic), formatted as header 2, the rest would be header 3 downwards.
```

**Sample subtopic prompt**:

```
Digital Evidence Theory
- Definition and characteristics of digital evidence
```

### RE

#### Syllabus

```
Most comprehensive structured series of topics in the creation of <AREA> CTF challenges. Modular. Topics only. Each topic would be the approach to create the CTF challenge.
```

#### Context Setting

```
I will prompt each of these to another thread. Make me a preliminary prompt containing all context needed and maybe additional instructions if needed.

Include this:

"""
**Input Format:**
Every prompt I send in this thread will contain three titles separated by "|":
`Module title | Subtopic | Subtopic's subtopic`

**Required Response Format:**
1. **Do NOT** output the "Module title" or the "Subtopic" text.
2. **Overall Title:** Use the "Subtopic's subtopic" as your main title. This must be formatted as **Header Level 3** `### Title`).
3. **Content Headers:** All subsequent headers within the response must be **Header Level 4** `#### Section`) or lower.

**Rules:**
1. Do not use conversational filler (e.g., "Here is the information you requested"). Go straight to the content.
...

**Instructions:**
* Give the most comprehensive output you can for each topic.
* Do not reply. Just wait for the first input.
* Do not add suggestions for the next prompts at the end.
* If ever you will add a link to a video, do not embed the video but just add the link that can be copied.
...
"""

More about my plan:
- Since the topics are only for challenge creation, after I prompt each of the topic, I will immediately ask for its solution afterwards.
```

##### DF RE

```
You are an expert Digital Forensics CTF Architect and Instructor. I am currently building comprehensive **Digital Forensics CTF Reviewer Materials** and solutions.

**Input Format:**
Every prompt I send in this thread will contain three titles separated by "|":
`Module title | Subtopic | Subtopic's subtopic`

**Your Goal:**
For each input I provide, you must generate a detailed technical entry containing the following sections. Use the "Perspective" in the input to determine the focus (creating the puzzle vs. solving the puzzle).
Provide the most comprehensive output possible for the specific "Subtopic's subtopic" provided.

**Required Response Format:**
1.  **Do NOT** output the "Module title" or the "Subtopic" text.
2.  **Overall Title:** Use the "Subtopic's subtopic" as your main title. This must be formatted as **Header Level 3** (`### Title`).
3.  **Content Headers:** All subsequent headers within the response must be **Header Level 4** (`#### Section`) or lower.

**Content Structure:**

#### 1. Technical Theory
* Briefly explain the underlying concept (e.g., how the file header works, how the protocol operates).
* **Key Constraints:** Keep this concise but technically accurate.

#### 2. Practical Implementation (The "How-To")
* **If the Input Subtopic is "The Architect (Creation)":** Provide the specific command-line steps, Python scripts, or hex editing instructions to *create* this artifact/challenge. Show code/commands.
* **If the Input Subtopic is "The Investigator (Solution)":** Provide the specific analysis steps, tools, and commands to *detect and solve* this artifact. Show code/commands.

#### 3. Example Scenario
* Describe a hypothetical CTF flag scenario involving this topic.
* *Example:* "The flag is hidden in the slack space of `evidence.jpg`."

#### 4. Key Tools
* List the 2-3 industry-standard tools best suited for this specific task (e.g., `volatility`, `binwalk`, `scapy`).

**Rules:**
1. Do not use conversational filler (e.g., "Here is the information you requested"). Go straight to the content.
2. Use Code Blocks for all scripts and terminal commands.
3. If the topic involves `Python`, ensure the code is Python 3 compatible.

**Instructions:**
* Give the most comprehensive output you can for each topic.
* Do not reply. Just wait for the first input.
* Do not add suggestions for the next prompts at the end.
* If ever you will add a link to a video, do not embed the video but just add the link that can be copied.
```

##### Cr RE

```
You are an expert **Cryptography CTF Architect and Instructor**. I am currently building a comprehensive library of **Cryptography CTF Challenges**.

My goal is to generate the "Creation/Architect" side of specific cryptographic vulnerabilities. For every topic I provide, you must act as the challenge creator. You will explain the mathematical/logic vulnerability and provide the Python code or resources necessary to generate the challenge artifacts (e.g., the vulnerable encryption script, the public keys, or the ciphertext) that would be given to a CTF player.

Context:

I will provide a specific cryptographic concept (e.g., "RSA Small Public Exponent"). You will generate the educational context and the challenge source code.

Note: Immediately after you generate the challenge, I will ask for the solution/exploit in a separate turn. Ensure the challenge you create is solvable and mathematically accurate.

Input Format:

Every prompt I send in this thread will contain three titles separated by "|":

Module title | Subtopic | Subtopic's subtopic

**Required Response Format:**

1. **Do NOT** output the "Module title" or the "Subtopic" text.
2. **Overall Title:** Use the "Subtopic's subtopic" as your main title. This must be formatted as **Header Level 3** (`### Title`).
3. **Content Headers:** All subsequent headers within the response must be **Header Level 4** (`#### Section`) or lower.
    

Content Structure Requirements:

For each topic, structure your response as follows:
1. **Theoretical Basis:** A concise explanation of the mathematical concept or protocol.
2. **The Vulnerability:** Mathematically or logically, why does this break? (Use LaTeX for math).
3. **Challenge Design:** The Python code (or relevant format) to create the challenge. This script should generate the `flag.txt` (encrypted) or provide the public parameters.
4. **Player Artifacts:** Explicitly list what files/information are provided to the player (e.g., "source.py and output.txt").
    

Rules:
1. Do not use conversational filler (e.g., "Here is the information you requested"). Go straight to the content.
2. Use LaTeX for all mathematical notations, formulas, and variables.
3. **Code Accuracy:** Ensure Python scripts are functional and use standard libraries (like `pycryptodome`) where applicable.
4. **No Solutions Yet:** Do not provide the solver script or the decrypted flag in this response. Focus only on the _creation_ and _theory_.
    

Instructions:
- Give the most comprehensive output you can for each topic.
- Do not add suggestions for the next prompts at the end.
- If ever you will add a link to a video, do not embed the video but just add the link that can be copied.
- **Do not reply to this prompt with content.** Just confirm you understand the instructions and wait for the first input.
- Whenever I ask for the solution, append "Solution: " to the title
- Do not add suggestions for next prompts at the end.
```

---

## Language Learning

**Preliminary prompt**:

```
I am an English speaker. I am learning <Language>. 
I have a syllabus containing progressive levels of practice sentences.
Give me as much many sentences (even if you have to give hundreds) in this level for me to master it:

[Level]

Example format for each entry (<Language> (formatted bold) + English separated by newline):
**Selamat pagi.**  
Good morning.
Answer format: Remove introduction (only retain title (format: [module number] [title]) and sections headers) and closing remarks.

(Continuable)
```

---


## Continue

```
Say 'done' if done otherwise continue from where you have left off.
```


---

## Perplexity

```
Format:
- Ensure an overall title (format as header level 2)
- Subheaders are formatted downwards by the header level (header level 3, etc.)
- Do not make "Examples", "Output", "Key Points", "Summary" as headers but only format as bold.
- Give the most comprehensive output you can give for the topic.
```

## Flatten Syllabus

```
Convert format.

The previous output's format is this

'''
Module title
- Subtopic
- subtopic's subtopic
'''

Now only list the subtopic's subtopics. Prefixed by module title and subtopic, all three separated by " | "

Example:
"Module title | Subtopic | Subtopic's subtopic"

Each of these separated by newline
```

## Prompting With Flattened Topic

```
For <TOPIC> reviewer materials creation. 

Format: Every prompt in this thread will contain three titles separated by "|": 
Module title 
Subtopic 
Subtopic's subtopic 

In your response format is as this: 
- Do not add the Module title and the Subtopic title. 
- Let the subtopic's subtopic be the overall title which will be formatted as header level 3 (ensure there is always an overall title) 
- The rest of the content shall be header level 4 and downwards

Give the most comprehensive output you can give your each topic.

Do not reply.
```

## Context Setting 

```
I will prompt each of these to another thread. Make me a preliminary prompt containing all context needed and maybe additional instructions if needed.
```

# Presentation

```
You are given a design system file (CSS variables, fonts, components, layout rules). Your task is to generate a single self-contained HTML file for a presentation.

Follow these rules strictly:

DESIGN SYSTEM USAGE
- Use ALL CSS variables exactly as defined (no approximations or replacements).
- Use the provided fonts exactly as specified.
- Reuse all available components (cards, badges, callouts, code blocks, layout frames, etc.).
- Do NOT invent new styles unless absolutely necessary.
- Maintain strict visual consistency across slides.

STRUCTURE
- Output a single HTML file (no external dependencies).
- Include all CSS inside a <style> tag.
- Include all JavaScript inside a <script> tag.
- Each slide must follow the provided slide-frame structure.
- Add a vertical accent bar on the left edge of every slide.

TOPBAR & FOOTER
- Topbar:
  - Left text: [ORGANIZATION NAME]
  - Right text: [PRESENTATION TOPIC]
- Footer:
  - Left text: [PRESENTATION SUBTITLE]
  - Right text: slide counter in format: "01 / XX" where XX is total slide count

NAVIGATION
- No visible buttons.
- Clicking LEFT half of screen → previous slide
- Clicking RIGHT half → next slide
- Keyboard:
  - Left arrow → previous slide
  - Right arrow → next slide
- Smooth transitions between slides
- Maintain slide index state

ILLUSTRATIONS & GRAPHICS
- If illustrating a concept is needed, use inline SVG code for the illustration/graphics.
- Keep SVGs clean, scalable, and styled using the design system's CSS variables (e.g., `fill="var(--accent)"`, `stroke="var(--border)"`).

SLIDES CONTENT
- Build slides in the exact order provided below.
- Each slide should:
  - Follow the design system layout
  - Use varied layouts:
    - Some text-heavy
    - Some visual (cards/grid, SVG illustrations)
    - Some minimal (large heading + short text)
  - Use appropriate components:
    - Cards for grouped info
    - Badges for tags/labels
    - Code blocks for technical or structured content
    - Callouts for warnings or emphasis

SLIDE LIST
[INSERT YOUR SLIDES HERE. For each slide, specify:
- Slide number and title
- Content to display
- Preferred layout (minimal / card grid / text-heavy / visual/SVG / comparison)
- Components to use (callout, badge, code block, card, etc.)

Example format:
1. **[Slide Title]**: [Content description]. [Layout preference]. 
   [Components to use.]
2. **[Slide Title]**: [Content description]. [Layout preference]. [Components to use.]
...]

INTERACTIVITY
- Implement slide switching logic in JavaScript
- Ensure full-screen slide behavior
- Prevent scrolling between slides

OUTPUT FORMAT
- Return ONLY the HTML file
- No explanations
- No markdown wrappers around the HTML
```

```
You are tasked with generating a single self-contained HTML file for a presentation based on the content provided at the end of this prompt.

STEP 1 — INFER A DESIGN SYSTEM
Before building any slides, derive a fitting visual design system from the content itself. Consider:
- The topic, tone, and audience (technical? civic? academic? corporate?)
- An appropriate color palette (2–3 primary colors + neutrals)
- Typography pairing (heading font + body font, sourced from Google Fonts via @import)
- Component styles: cards, badges, callouts, code blocks, dividers, accent bars
- Overall mood: clean/minimal, bold/data-driven, warm/community-focused, etc.

Define all design decisions as CSS custom properties (variables) at the top of your <style> block. Every visual choice must reference these variables — no hardcoded colors, fonts, or spacing values elsewhere.

STEP 2 — PLAN THE SLIDES
From the content provided, extract and organize the key ideas into a logical slide sequence. Determine:
- Total number of slides (typically 6–10)
- A title slide, a closing/summary slide, and content slides in between
- Which slides benefit from visuals (SVG illustrations, card grids) vs. text-heavy or minimal layouts

STEP 3 — BUILD THE PRESENTATION
Generate a single HTML file following all rules below.

---

STRUCTURE
- Output a single HTML file (no external dependencies except Google Fonts).
- Include all CSS inside a <style> tag.
- Include all JavaScript inside a <script> tag.
- Each slide must use a consistent slide-frame structure.
- Add a vertical accent bar on the left edge of every slide.

TOPBAR & FOOTER
- Topbar:
  - Left: organization or author name (inferred from content, or left as a short placeholder)
  - Right: presentation topic (inferred from content)
- Footer:
  - Left: presentation subtitle or tagline (inferred from content)
  - Right: slide counter in format "01 / XX" where XX is total slide count

NAVIGATION
- No visible buttons.
- Clicking LEFT half of screen → previous slide
- Clicking RIGHT half → next slide
- Keyboard:
  - Left arrow → previous slide
  - Right arrow → next slide
- Smooth transitions between slides
- Maintain slide index state

ILLUSTRATIONS & GRAPHICS
- Where a concept benefits from visualization, use inline SVG.
- SVGs must be clean, scalable, and use only CSS variables for all colors and strokes.
- Do not use emoji or external images.

SLIDE LAYOUTS
Use a varied mix across slides:
- Minimal: large heading + short supporting text
- Card grid: grouped information in 2–4 cards
- Text-heavy: structured prose or bullet points with section heading
- Visual: SVG illustration as the primary element with a short caption
- Comparison: two side-by-side cards contrasting two options or ideas

Use components as appropriate:
- Cards for grouped or categorized info
- Badges for labels, tags, or status markers
- Callouts for emphasis, mandates, warnings, or key insights
- Code blocks for formulas, structured data, or technical content

INTERACTIVITY
- Implement slide switching logic in JavaScript
- Ensure full-screen slide behavior
- Prevent scrolling between slides

OUTPUT FORMAT
- Return ONLY the HTML file
- No explanations
- No markdown wrappers around the HTML

---

CONTENT
[PASTE YOUR RAW CONTENT HERE — notes, outline, report excerpt, data, or any source material the slides should be derived from]
```