## Heterogeneous Graph Processing


Heterogeneous graphs contain multiple node and edge types, requiring specialized architectures to handle different semantic relationships and node characteristics.

**Heterogeneous Graph Attention**

HGT (Heterogeneous Graph Transformer) uses type-specific transformations:

```python
from torch_geometric.nn import HGTConv

class HeterogeneousGNN(nn.Module):
    def __init__(self, metadata, hidden_channels=64, out_channels=10, num_heads=4, num_layers=2):
        super().__init__()
        self.num_layers = num_layers
        
        self.convs = nn.ModuleList()
        for _ in range(num_layers):
            self.convs.append(HGTConv(hidden_channels, hidden_channels, metadata,
                                    num_heads, group='sum'))
        
        self.lin = nn.Linear(hidden_channels, out_channels)
        
    def forward(self, x_dict, edge_index_dict):
        for conv in self.convs:
            x_dict = conv(x_dict, edge_index_dict)
            x_dict = {key: torch.relu(x) for key, x in x_dict.items()}
        return self.lin(x_dict['target_node_type'])
```

**Metapath-Based Processing**

Metapaths capture higher-order relationships in heterogeneous graphs:

```python
class MetapathGNN(nn.Module):
    def __init__(self, metapaths, in_channels, out_channels):
        super().__init__()
        self.metapaths = metapaths
        self.convs = nn.ModuleDict()
        
        for metapath in metapaths:
            path_name = '_'.join(metapath)
            self.convs[path_name] = nn.ModuleList([
                GCNConv(in_channels, out_channels) for _ in range(len(metapath) - 1)
            ])
        
        self.attention = nn.Linear(out_channels, 1)
        
    def forward(self, x_dict, edge_index_dict):
        path_embeddings = []
        
        for metapath in self.metapaths:
            x = x_dict[metapath[0]]
            for i, (src_type, dst_type) in enumerate(zip(metapath[:-1], metapath[1:])):
                edge_type = f"{src_type}__to__{dst_type}"
                if edge_type in edge_index_dict:
                    path_name = '_'.join(metapath)
                    x = self.convs[path_name][i](x, edge_index_dict[edge_type])
                    x = torch.relu(x)
            path_embeddings.append(x)
        
        # Attention over metapaths
        stacked = torch.stack(path_embeddings, dim=1)
        attention_weights = torch.softmax(self.attention(stacked), dim=1)
        return torch.sum(attention_weights * stacked, dim=1)
```

