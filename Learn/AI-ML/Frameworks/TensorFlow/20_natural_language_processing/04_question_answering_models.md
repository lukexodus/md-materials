## Question Answering Models


Question answering systems extract or generate answers from given contexts or knowledge bases. TensorFlow supports multiple QA paradigms including extractive QA (selecting spans from context), generative QA (producing new text), and retrieval-based QA (combining information retrieval with reading comprehension).

**Key Points:**

- Extractive QA using span prediction models that identify answer boundaries
- Generative QA producing free-form answers using sequence generation
- Reading comprehension models processing passage-question pairs
- Open-domain QA combining document retrieval with answer extraction
- Conversational QA maintaining context across multiple question-answer exchanges

BERT-based models excel at extractive QA tasks, predicting start and end positions of answer spans within provided contexts. The model receives concatenated question-context pairs as input and outputs probability distributions over token positions for answer boundaries.

**Examples:**

- Customer service chatbots answering product-related questions
- Educational systems providing explanations for academic concepts
- Legal research tools extracting relevant information from case law
- Medical QA systems assisting healthcare professionals with diagnostic information

Multi-hop reasoning models handle questions requiring information synthesis from multiple sources. These architectures iteratively refine their understanding by attending to different parts of the context or retrieving additional relevant information.

