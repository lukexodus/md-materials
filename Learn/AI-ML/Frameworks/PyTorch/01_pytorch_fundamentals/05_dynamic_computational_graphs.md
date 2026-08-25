## Dynamic Computational Graphs


**Dynamic vs Static Graphs**

PyTorch uses dynamic computational graphs (also called define-by-run), where the graph structure is built during the forward pass. This contrasts with static graphs where structure is defined before execution.

**Graph Construction**

The computational graph is constructed implicitly as operations are performed on tensors with `requires_grad=True`. Each operation creates nodes in the graph representing the function and its inputs.

**Advantages of Dynamic Graphs**

Dynamic graphs provide several benefits for deep learning development:

- **Flexibility**: Graph structure can change during execution based on input or conditions
- **Debugging**: Standard Python debugging tools work naturally with dynamic graphs
- **Control Flow**: Native Python control structures (loops, conditionals) work seamlessly
- **Variable Input Sizes**: Models can handle inputs of different sizes without redefinition

**Graph Execution**

During forward pass, PyTorch builds the computational graph while computing results. During backward pass, it traverses this graph to compute gradients, then typically discards the graph unless `retain_graph=True` is specified.

**Examples of Dynamic Behavior**

```python
# Conditional execution
if some_condition:
    output = model.branch_a(input)
else:
    output = model.branch_b(input)

# Variable sequence lengths in RNNs
for i in range(sequence_length):  # sequence_length can vary
    hidden = rnn_cell(input[i], hidden)
```

**Key Points:**

- Graphs are rebuilt for each forward pass
- Memory usage is typically lower than static graphs due to immediate execution
- Debugging is more intuitive compared to static graph frameworks
- Performance optimization may require additional techniques for production deployment

