## T5 and Sequence-to-Sequence Models


**Text-to-Text Transfer Framework** T5 formulates all NLP tasks as text-to-text problems where inputs and outputs are text strings. This unified approach enables using the same model architecture, pre-training procedure, and fine-tuning process across diverse tasks. Task-specific prefixes like "translate English to German:" indicate the desired operation, allowing multi-task learning within single models.

**Encoder-Decoder Architecture** T5 uses the full transformer encoder-decoder architecture where encoders process input sequences bidirectionally and decoders generate output sequences autoregressively. Cross-attention layers in the decoder attend to encoder outputs, enabling the model to condition generation on input representations. This architecture naturally handles variable-length inputs and outputs.

**Denoising Pre-training Objectives** T5 pre-training uses span corruption where consecutive spans of tokens are replaced with sentinel tokens, and the model learns to reconstruct the corrupted spans. This approach combines benefits of masked language modeling and autoregressive generation. Various span corruption strategies include different span lengths, corruption rates, and sentinel token strategies.

**Multi-Task Learning and Task Formatting** T5 can be trained on multiple tasks simultaneously by formatting each task as text-to-text with appropriate prefixes. Examples include "summarize: [document]" for summarization, "translate English to French: [text]" for translation, and "cola sentence: [sentence]" for acceptability classification. Multi-task learning can improve performance through knowledge transfer between related tasks.

**Scaling and Variant Models** T5 models range from T5-Small (60M parameters) to T5-11B (11B parameters), demonstrating scaling effects in sequence-to-sequence models. UL2 extends T5 with unified language learning that combines different denoising objectives. Flan-T5 incorporates instruction tuning for improved few-shot performance. mT5 extends T5 to multilingual settings with training data from 101 languages.

**Fine-tuning and Adaptation Strategies** T5 fine-tuning typically involves continued training on task-specific datasets with appropriate text-to-text formatting. Parameter-efficient fine-tuning methods like LoRA (Low-Rank Adaptation) and prefix tuning can adapt large T5 models with fewer trainable parameters. Prompt tuning learns soft prompts that guide model behavior without modifying core parameters.

**Generation and Decoding Strategies** T5 generation uses various decoding strategies including greedy decoding, beam search, nucleus sampling, and top-k sampling. Temperature scaling controls generation randomness. Length penalties and repetition penalties improve generation quality. For structured outputs, constrained decoding can enforce format requirements.

**Key Points:**

- Text-to-text formulation enables unified handling of diverse NLP tasks
- Encoder-decoder architecture naturally handles variable-length sequences
- Span corruption pre-training combines masked language modeling with generation
- Multi-task learning enables knowledge transfer across related tasks

