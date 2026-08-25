## Table of Contents: Linear Algebra for Machine Learning

### Foundations and Notation

- scalars vectors and vector spaces
- vector notation conventions in ML
- fields and closure properties
- linear combinations
- span of a set of vectors
- linear independence and dependence
- basis and dimension
- subspaces
- coordinate systems and change of basis

### Vector Operations and Geometry

- vector addition and scalar multiplication
- dot product and inner product
- norms L1 L2 Linfinity and Lp
- unit vectors and normalization
- cosine similarity
- orthogonality and orthonormal vectors
- projections onto vectors and subspaces
- angle between vectors
- cross product in three dimensions

### Matrices and Matrix Operations

- matrix notation and terminology
- matrix addition and scalar multiplication
- matrix multiplication and its properties
- transpose of a matrix
- identity matrix
- diagonal matrices
- symmetric and skew symmetric matrices
- triangular matrices
- block matrices
- trace of a matrix
- matrix as a linear transformation

### Systems of Linear Equations

- representing systems in matrix form
- Gaussian elimination
- row echelon and reduced row echelon form
- rank of a matrix
- consistency and solution existence
- homogeneous systems
- particular and general solutions
- LU decomposition
- solving systems computationally

### Matrix Inverses and Determinants

- invertibility conditions
- computing the inverse
- properties of inverses
- pseudoinverse for non square matrices
- determinant definition and properties
- cofactor expansion
- determinant and invertibility relationship
- determinant and volume interpretation
- Cramer rule

### Vector Spaces in Depth

- formal vector space axioms
- subspace tests
- null space and kernel
- column space and range
- row space
- rank nullity theorem
- direct sums of subspaces
- quotient spaces

### Linear Transformations

- definition and properties of linear maps
- matrix representation of linear transformations
- composition of linear transformations
- injective surjective and bijective maps
- kernel and image of a transformation
- isomorphisms
- change of basis for transformations
- linear transformations as data operations

### Orthogonality and Projections

- orthogonal complements
- orthogonal projection matrices
- Gram Schmidt process
- QR decomposition
- least squares approximation
- normal equations
- orthogonal matrices and their properties
- applications to regression

### Eigenvalues and Eigenvectors

- definition and geometric intuition
- characteristic polynomial
- computing eigenvalues and eigenvectors
- eigenspaces
- algebraic and geometric multiplicity
- diagonalization
- conditions for diagonalizability
- similar matrices
- eigen decomposition
- power iteration method

### Special Matrix Properties

- symmetric matrices and real eigenvalues
- positive definite and positive semidefinite matrices
- quadratic forms
- spectral theorem
- orthogonal diagonalization
- matrix norms
- condition number
- sparse matrices

### Singular Value Decomposition

- motivation and geometric interpretation
- singular values and singular vectors
- computing the SVD
- relationship to eigen decomposition
- low rank matrix approximation
- SVD and pseudoinverse
- truncated SVD
- applications to dimensionality reduction
- applications to recommender systems

### Matrix Decompositions

- LU decomposition revisited
- Cholesky decomposition
- QR decomposition revisited
- eigen decomposition revisited
- SVD revisited
- choosing the right decomposition
- computational cost comparisons

### Dimensionality Reduction Techniques

- principal component analysis derivation
- covariance matrix computation
- PCA via eigen decomposition
- PCA via SVD
- explained variance and component selection
- whitening transformation
- linear discriminant analysis basics
- relationship between PCA and SVD

### Tensors and Multilinear Algebra

- tensor definition and rank
- tensor notation and indexing
- tensor operations
- tensor reshaping and broadcasting
- Kronecker product
- Hadamard product
- outer product
- tensor decomposition overview

### Matrix Calculus for Machine Learning

- gradients of scalar functions with respect to vectors
- gradients with respect to matrices
- Jacobian matrix
- Hessian matrix
- chain rule in matrix calculus
- common derivative identities
- derivative of matrix multiplication
- derivative of quadratic forms
- backpropagation as matrix calculus

### Norms Distances and Similarity Measures

- vector norms revisited
- matrix norms Frobenius and spectral
- distance metrics Euclidean and Manhattan
- Mahalanobis distance
- similarity measures in high dimensions
- normalization techniques for ML features

### Linear Algebra in Optimization

- convexity and linear algebra connections
- gradient descent as vector updates
- Newton method and the Hessian
- constrained optimization with linear algebra
- Lagrange multipliers
- quadratic programming basics
- eigenvalues and optimization landscape

### Numerical Linear Algebra Considerations

- floating point precision issues
- numerical stability of algorithms
- condition number and error sensitivity
- iterative methods for large systems
- sparse matrix computations
- computational complexity of matrix operations
- efficient matrix multiplication algorithms

### Linear Algebra for Neural Networks

- weight matrices and layer representations
- forward propagation as matrix multiplication
- batch processing with matrices
- convolution as a linear operation
- weight initialization and matrix properties
- vanishing and exploding gradients linked to eigenvalues
- attention mechanisms as matrix operations

### Applied Linear Algebra Case Studies

- linear regression fully derived
- logistic regression matrix formulation
- support vector machines and linear separability
- image compression using SVD
- word embeddings and vector spaces
- graph representations using adjacency matrices
- Markov chains and transition matrices

### Computational Tools and Libraries

- NumPy array and matrix operations
- broadcasting rules
- linear algebra functions in NumPy and SciPy
- matrix operations in PyTorch and TensorFlow
- GPU acceleration for matrix computations
- verifying results with symbolic computation tools
