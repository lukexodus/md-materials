## Sequence-to-Sequence Models


Sequence-to-sequence (seq2seq) models consist of an encoder that processes input sequences and a decoder that generates output sequences, commonly used for translation, summarization, and dialogue systems.

**Key Points:**

- Encoder processes entire input sequence into fixed-size context vector
- Decoder generates output sequence conditioned on context vector
- Teacher forcing used during training for faster convergence
- Inference requires autoregressive generation

```python
# Encoder-Decoder architecture
class Seq2SeqModel(tf.keras.Model):
    def __init__(self, vocab_size, embedding_dim, hidden_units):
        super().__init__()
        self.encoder_embedding = tf.keras.layers.Embedding(vocab_size, embedding_dim)
        self.encoder_lstm = tf.keras.layers.LSTM(hidden_units, return_state=True)
        
        self.decoder_embedding = tf.keras.layers.Embedding(vocab_size, embedding_dim)
        self.decoder_lstm = tf.keras.layers.LSTM(hidden_units, return_sequences=True, return_state=True)
        self.decoder_dense = tf.keras.layers.Dense(vocab_size, activation='softmax')
    
    def call(self, inputs, training=None):
        encoder_inputs, decoder_inputs = inputs
        
        # Encoder
        encoder_embedded = self.encoder_embedding(encoder_inputs)
        encoder_outputs, state_h, state_c = self.encoder_lstm(encoder_embedded)
        encoder_states = [state_h, state_c]
        
        # Decoder
        decoder_embedded = self.decoder_embedding(decoder_inputs)
        decoder_outputs, _, _ = self.decoder_lstm(decoder_embedded, initial_state=encoder_states)
        decoder_outputs = self.decoder_dense(decoder_outputs)
        
        return decoder_outputs
```

Traditional seq2seq models suffer from information bottleneck as entire input must be compressed into fixed-size context vector.

