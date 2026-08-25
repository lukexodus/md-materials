## Graph Convolution Networks


Graph Convolution Networks form the foundation of most GNN architectures by generalizing convolution operations to irregular graph structures.

**Spectral Graph Convolutions**

The mathematical foundation relies on the graph Laplacian eigendecomposition. For a graph with adjacency matrix A and degree matrix D, the normalized Laplacian L = I - D^(-1/2)AD^(-1/2) enables spectral filtering. PyTorch implementations typically use Chebyshev polynomials to approximate spectral filters:

```python
import torch
import torch.nn as nn
from torch_geometric.nn import ChebConv

class SpectralGCN(nn.Module):
    def __init__(self, in_channels, out_channels, K=3):
        super().__init__()
        self.conv = ChebConv(in_channels, out_channels, K)
    
    def forward(self, x, edge_index):
        return self.conv(x, edge_index)
```

**Spatial Graph Convolutions**

Spatial approaches operate directly on the graph topology. The Graph Convolutional Network (GCN) layer performs:

H^(l+1) = σ(D^(-1/2)AD^(-1/2)H^(l)W^(l))

Where H^(l) represents node features at layer l, W^(l) is the learnable weight matrix, and σ is the activation function.

```python
from torch_geometric.nn import GCNConv

class GCNLayer(nn.Module):
    def __init__(self, in_features, out_features):
        super().__init__()
        self.conv = GCNConv(in_features, out_features)
        self.dropout = nn.Dropout(0.5)
    
    def forward(self, x, edge_index):
        x = self.conv(x, edge_index)
        x = torch.relu(x)
        return self.dropout(x)
```

**Advanced Convolution Variants**

GraphSAINT sampling reduces computational complexity for large graphs by sampling subgraphs during training. FastGCN employs importance sampling of nodes rather than edges. PyTorch Geometric supports these through specialized data loaders and sampling strategies.

