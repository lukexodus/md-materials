## Message Passing Frameworks


The Message Passing Neural Network (MPNN) framework provides a unified abstraction for most GNN variants, consisting of message functions, aggregation functions, and update functions.

**Core MPNN Components**

The framework operates in three phases:

1. Message computation: m_ij = M(h_i, h_j, e_ij)
2. Aggregation: m_i = AGG({m_ij : j ∈ N(i)})
3. Update: h_i^(t+1) = U(h_i^t, m_i)

Where M is the message function, AGG is aggregation, U is the update function, and e_ij represents edge features.

```python
from torch_geometric.nn import MessagePassing
from torch_geometric.utils import add_self_loops, degree

class MPNNConv(MessagePassing):
    def __init__(self, in_channels, out_channels):
        super().__init__(aggr='add')
        self.lin = nn.Linear(in_channels, out_channels)
        
    def forward(self, x, edge_index):
        edge_index, _ = add_self_loops(edge_index, num_nodes=x.size(0))
        row, col = edge_index
        deg = degree(col, x.size(0), dtype=x.dtype)
        deg_inv_sqrt = deg.pow(-0.5)
        norm = deg_inv_sqrt[row] * deg_inv_sqrt[col]
        
        return self.propagate(edge_index, x=x, norm=norm)
    
    def message(self, x_j, norm):
        return norm.view(-1, 1) * x_j
    
    def update(self, aggr_out):
        return self.lin(aggr_out)
```

**Advanced Message Passing Patterns**

Gated Graph Neural Networks employ GRU-style updates:

```python
class GatedGraphConv(MessagePassing):
    def __init__(self, out_channels, num_layers):
        super().__init__(aggr='add')
        self.out_channels = out_channels
        self.num_layers = num_layers
        self.weight = nn.Parameter(torch.Tensor(num_layers, out_channels, out_channels))
        self.gru = nn.GRUCell(out_channels, out_channels)
        
    def forward(self, x, edge_index, edge_attr):
        for i in range(self.num_layers):
            m = self.propagate(edge_index, x=x, edge_attr=edge_attr, layer=i)
            x = self.gru(m, x)
        return x
    
    def message(self, x_j, edge_attr, layer):
        return torch.matmul(x_j.unsqueeze(1), self.weight[layer]).squeeze(1)
```

