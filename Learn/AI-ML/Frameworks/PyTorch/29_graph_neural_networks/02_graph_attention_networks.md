## Graph Attention Networks


Graph Attention Networks (GATs) introduce attention mechanisms to weight neighbor contributions dynamically, addressing the limitation of fixed neighbor importance in GCNs.

**Attention Mechanism**

The attention coefficient between nodes i and j is computed as:

α_ij = softmax(LeakyReLU(a^T[Wh_i || Wh_j]))

Where W is the weight matrix, h_i and h_j are node features, a is the attention vector, and || denotes concatenation.

```python
from torch_geometric.nn import GATConv

class MultiHeadGAT(nn.Module):
    def __init__(self, in_channels, out_channels, heads=8, dropout=0.6):
        super().__init__()
        self.gat1 = GATConv(in_channels, 8, heads=heads, dropout=dropout)
        self.gat2 = GATConv(8 * heads, out_channels, heads=1, 
                           concat=False, dropout=dropout)
    
    def forward(self, x, edge_index):
        x = torch.dropout(x, p=0.6, training=self.training)
        x = torch.elu(self.gat1(x, edge_index))
        x = torch.dropout(x, p=0.6, training=self.training)
        x = self.gat2(x, edge_index)
        return torch.log_softmax(x, dim=-1)
```

**Multi-Head Attention**

Multi-head attention captures different types of relationships simultaneously. Each head learns distinct attention patterns, with final representations either concatenated or averaged:

```python
class CustomGATLayer(nn.Module):
    def __init__(self, in_features, out_features, num_heads, alpha=0.2):
        super().__init__()
        self.num_heads = num_heads
        self.out_features = out_features
        
        self.W = nn.Parameter(torch.zeros(in_features, out_features * num_heads))
        self.a = nn.Parameter(torch.zeros(2 * out_features, num_heads))
        self.leakyrelu = nn.LeakyReLU(alpha)
        
    def forward(self, h, adj):
        Wh = torch.mm(h, self.W)  # h.shape: (N, in_features), Wh.shape: (N, out_features * num_heads)
        Wh = Wh.view(-1, self.num_heads, self.out_features)  # (N, num_heads, out_features)
        
        # Attention mechanism for each head
        attention_input = self._prepare_attentional_mechanism_input(Wh)
        e = self.leakyrelu(torch.matmul(attention_input, self.a))
        attention = torch.softmax(e.squeeze(-1), dim=1)
        
        return torch.bmm(attention.unsqueeze(1), Wh).squeeze(1)
```

