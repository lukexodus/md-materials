## Question Answering Models


PyTorch supports diverse question answering paradigms from extractive reading comprehension to generative open-domain systems, utilizing pre-trained language models and specialized architectures.

**Extractive QA Systems:** BERT-based models fine-tune on reading comprehension datasets like SQuAD by predicting start and end positions of answer spans within context passages. BiDAF (Bidirectional Attention Flow) models bidirectional attention between questions and passages. QANet combines convolution and self-attention without recurrence for efficient processing. R-NET uses gated attention mechanisms and self-matching networks.

**Generative QA Approaches:** T5 (Text-to-Text Transfer Transformer) frames question answering as text generation, converting questions and contexts into target answers. BART combines bidirectional encoder with autoregressive decoder for flexible answer generation. UnifiedQA handles multiple QA formats through consistent text-to-text formulation. FiD (Fusion-in-Decoder) processes multiple retrieved passages through separate encoders then fuses information in the decoder.

**Open-Domain Systems:** Dense Passage Retrieval (DPR) learns dense representations for questions and passages, retrieving relevant contexts through approximate nearest neighbor search. RAG (Retrieval-Augmented Generation) combines retrieval with generation by encoding retrieved passages and generating answers conditioned on both questions and retrieved content. REALM pre-trains language models with retrieval augmentation from the beginning.

**Multi-Hop Reasoning:** HotpotQA requires reasoning across multiple documents to answer complex questions. Graph neural networks model relationships between entities and facts for multi-step reasoning. Iterative retrieval systems progressively gather evidence through multiple retrieval steps. Chain-of-thought prompting encourages models to generate intermediate reasoning steps.

**Conversational QA:** CoQA and QuAC datasets contain conversational question answering requiring coreference resolution and context understanding across dialogue turns. History-aware models maintain conversation context through memory mechanisms or explicit history encoding. Turn-level attention focuses on relevant previous turns for current question understanding.

