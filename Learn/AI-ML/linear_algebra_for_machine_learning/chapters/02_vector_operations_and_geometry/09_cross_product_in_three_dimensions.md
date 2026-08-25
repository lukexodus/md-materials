## Cross Product in Three Dimensions

### Definition

The cross product is a binary operation on two vectors in $\mathbb{R}^3$ that produces a third vector orthogonal to both inputs. For vectors $\mathbf{a} = (a_1, a_2, a_3)$ and $\mathbf{b} = (b_1, b_2, b_3)$:

$$\mathbf{a} \times \mathbf{b} = \begin{pmatrix} a_2 b_3 - a_3 b_2 \\ a_3 b_1 - a_1 b_3 \\ a_1 b_2 - a_2 b_1 \end{pmatrix}$$

Unlike the dot product, the cross product is only defined in three dimensions (and, in a generalized sense, seven dimensions, which is a specialized topic outside standard ML use). It is not defined in $\mathbb{R}^2$ or higher-dimensional spaces beyond $\mathbb{R}^3$ in the standard sense.

### Determinant Formulation

A common mnemonic expresses the cross product as a symbolic determinant:

$$\mathbf{a} \times \mathbf{b} = \begin{vmatrix} \mathbf{i} & \mathbf{j} & \mathbf{k} \\ a_1 & a_2 & a_3 \\ b_1 & b_2 & b_3 \end{vmatrix}$$

where $\mathbf{i}, \mathbf{j}, \mathbf{k}$ are the standard basis vectors. Expanding along the first row reproduces the component formula above.

### Geometric Interpretation

**Key Points**
- The resulting vector $\mathbf{a} \times \mathbf{b}$ is perpendicular to both $\mathbf{a}$ and $\mathbf{b}$.
- Its direction follows the right-hand rule: curl the fingers of the right hand from $\mathbf{a}$ toward $\mathbf{b}$; the thumb points along $\mathbf{a} \times \mathbf{b}$.
- Its magnitude equals the area of the parallelogram spanned by $\mathbf{a}$ and $\mathbf{b}$:

$$\|\mathbf{a} \times \mathbf{b}\| = \|\mathbf{a}\| \, \|\mathbf{b}\| \sin\theta$$

where $\theta$ is the angle between the two vectors.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300">
  <text x="200" y="20" font-size="13" text-anchor="middle" fill="#333">Cross Product Geometry (svg_diagram)</text>
  <line x1="50" y1="250" x2="200" y2="150" stroke="#1f77b4" stroke-width="2" marker-end="url(#arrow1)" />
  <text x="200" y="145" font-size="12" fill="#1f77b4">a</text>
  <line x1="50" y1="250" x2="280" y2="230" stroke="#ff7f0e" stroke-width="2" marker-end="url(#arrow2)" />
  <text x="285" y="235" font-size="12" fill="#ff7f0e">b</text>
  <polygon points="50,250 200,150 320,175 280,230" fill="#cccccc" opacity="0.4" stroke="none" />
  <line x1="50" y1="250" x2="120" y2="60" stroke="#2ca02c" stroke-width="2" marker-end="url(#arrow3)" />
  <text x="115" y="50" font-size="12" fill="#2ca02c">a × b (perpendicular)</text>
  <text x="200" y="280" font-size="11" text-anchor="middle" fill="#666">Shaded region = parallelogram area = ‖a × b‖</text>
</svg>

### Algebraic Properties

- **Anti-commutativity**: $\mathbf{a} \times \mathbf{b} = -(\mathbf{b} \times \mathbf{a})$
- **Distributivity**: $\mathbf{a} \times (\mathbf{b} + \mathbf{c}) = \mathbf{a} \times \mathbf{b} + \mathbf{a} \times \mathbf{c}$
- **Scalar compatibility**: $(k\mathbf{a}) \times \mathbf{b} = k(\mathbf{a} \times \mathbf{b})$
- **Self-cross is zero**: $\mathbf{a} \times \mathbf{a} = \mathbf{0}$
- **Not associative**: In general, $\mathbf{a} \times (\mathbf{b} \times \mathbf{c}) \neq (\mathbf{a} \times \mathbf{b}) \times \mathbf{c}$
- Parallel vectors (including the zero vector case) produce a zero cross product, since $\sin\theta = 0$ when $\theta = 0$ or $\pi$.

### Relation to the Dot Product

The scalar triple product combines both operations:

$$\mathbf{a} \cdot (\mathbf{b} \times \mathbf{c})$$

This quantity equals the signed volume of the parallelepiped formed by $\mathbf{a}$, $\mathbf{b}$, and $\mathbf{c}$. It also equals the determinant of the $3 \times 3$ matrix whose rows (or columns) are the three vectors.

### Worked Example

Let $\mathbf{a} = (1, 2, 3)$ and $\mathbf{b} = (4, 5, 6)$.

$$\mathbf{a} \times \mathbf{b} = \begin{pmatrix} (2)(6) - (3)(5) \\ (3)(4) - (1)(6) \\ (1)(5) - (2)(4) \end{pmatrix} = \begin{pmatrix} 12 - 15 \\ 12 - 6 \\ 5 - 8 \end{pmatrix} = \begin{pmatrix} -3 \\ 6 \\ -3 \end{pmatrix}$$

**Output**

$$\mathbf{a} \times \mathbf{b} = (-3, 6, -3)$$

Verification via dot product (should be zero for both):
$$\mathbf{a} \cdot (\mathbf{a} \times \mathbf{b}) = (1)(-3) + (2)(6) + (3)(-3) = -3 + 12 - 9 = 0$$
$$\mathbf{b} \cdot (\mathbf{a} \times \mathbf{b}) = (4)(-3) + (5)(6) + (6)(-3) = -12 + 30 - 18 = 0$$

Both results confirm orthogonality to the original vectors.

### Relevance to Machine Learning

[Inference] The cross product itself is not a primary operation in most standard machine learning algorithms, since ML typically operates in high-dimensional spaces ($n \gg 3$) where the standard 3D cross product is undefined. Its practical relevance in ML contexts is largely confined to specific applied domains rather than general-purpose model training. This inference is based on the mathematical constraint that the cross product is only defined in three (or seven) dimensions, not on a survey of ML literature.

Known areas of applicability include:

- **Computer vision and 3D graphics**: computing surface normals for point clouds or meshes, which feed into vision pipelines (e.g., normal estimation for 3D object detection).
- **Robotics and reinforcement learning in physical environments**: torque calculations, orientation and angular velocity computations, which appear in physics-based simulation environments used for RL.
- **Rotation representations**: cross products appear in formulas for rotation matrices and quaternion operations used in pose estimation.

[Unverified] The extent to which any specific production ML system relies on cross product computations internally cannot be confirmed without inspecting that system's source code or documentation.

### Cross Product vs. Dot Product

| Property | Dot Product | Cross Product |
|---|---|---|
| Output type | Scalar | Vector |
| Dimensionality | Any $n$ | Only $\mathbb{R}^3$ (standard case) |
| Result meaning | Projection / similarity | Orthogonal vector, area |
| Commutative | Yes | No (anti-commutative) |
| Zero condition | Orthogonal vectors | Parallel vectors |

**Related Topics**
- Dot product and vector projections
- Determinants and their geometric meaning
- Scalar and vector triple products
- Rotation matrices and quaternions
- Normal vector computation in computer vision
- Linear independence and the geometry of spanning sets