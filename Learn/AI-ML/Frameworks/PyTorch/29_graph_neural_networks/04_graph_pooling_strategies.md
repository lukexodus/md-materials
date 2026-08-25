## Graph Pooling Strategies


Graph pooling reduces graph size while preserving important structural information, analogous to pooling in CNNs but adapted for irregular graph structures.

**Hierarchical Pooling**

DiffPool learns soft cluster assignments to create hierarchical representations:

```python
from torch_geometric.nn import DenseGraphConv, dense_diff_pool

class DiffPoolLayer(nn.Module):
    def __init__(self, num_nodes, in_channels, out_channels):
        super().__init__()
        self.embed = DenseGraphConv(in_channels, out_channels)
        self.pool = DenseGraphConv(in_channels, num_nodes)
        
    def forward(self, x, adj, mask=None):
        x = torch.relu(self.embed(x, adj, mask))
        s = torch.softmax(self.pool(x, adj, mask), dim=-1)
        x, adj, reg = dense_diff_pool(x, adj, s, mask)
        return x, adj, reg
```

**Global Pooling Operations**

Global pooling aggregates node features to create graph-level representations:

```python
from torch_geometric.nn import global_mean_pool, global_max_pool, global_add_pool

class GlobalPooling(nn.Module):
    def __init__(self, pooling_type='mean'):
        super().__init__()
        self.pooling_type = pooling_type
        
    def forward(self, x, batch):
        if self.pooling_type == 'mean':
            return global_mean_pool(x, batch)
        elif self.pooling_type == 'max':
            return global_max_pool(x, batch)
        elif self.pooling_type == 'sum':
            return global_add_pool(x, batch)
        else:
            # Set2Set pooling for more sophisticated aggregation
            return global_sort_pool(x, batch, k=10)
```

**Learnable Pooling**

TopK pooling selects the most important nodes based on learned scoring functions:

```python
from torch_geometric.nn import TopKPooling

class LearnablePool(nn.Module):
    def __init__(self, in_channels, ratio=0.5):
        super().__init__()
        self.pool = TopKPooling(in_channels, ratio=ratio)
        self.conv = GCNConv(in_channels, in_channels)
        
    def forward(self, x, edge_index, batch):
        x = self.conv(x, edge_index)
        x, edge_index, _, batch, _, _ = self.pool(x, edge_index, batch=batch)
        return x, edge_index, batch
```

