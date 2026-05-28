# Affine

In mathematics—specifically geometry and linear algebra—the term **affine** refers to a relationship or transformation that preserves **collinearity** and **ratios of distances**, even if it doesn't preserve absolute angles or lengths.

Think of it as a "relaxed" version of Euclidean geometry. While Euclidean geometry cares about exact shapes, affine geometry focuses on how points, lines, and planes connect.

---

## 1. Affine Transformations

An affine transformation is a function between affine spaces that maps lines to lines. It is a combination of **linear transformations** (like scaling, rotation, or shear) and **translation** (moving the origin).

The general formula for an affine transformation in vector notation is:

$$y = Ax + b$$

- **$A$**: A linear transformation matrix (handles rotation, scaling, and shearing).
    
- **$b$**: A translation vector (shifts the entire object).
    

### Key Properties

- **Parallelism:** Parallel lines always remain parallel after an affine transformation.
    
- **Collinearity:** If three points lie on a line, they will still lie on a line after the transformation.
    
- **Ratios:** While lengths change, the ratio of lengths along a line is preserved (e.g., the midpoint of a segment remains the midpoint).
    

---

## 2. Affine Combinations and Spaces

In linear algebra, we often talk about linear combinations. An **affine combination** is a specific type where the coefficients sum to 1.

Given points $v_1, v_2, \dots, v_n$, an affine combination is:

$$\sum_{i=1}^{n} \alpha_i v_i \quad \text{where} \quad \sum_{i=1}^{n} \alpha_i = 1$$

- **Affine Hull:** The set of all affine combinations of a set of points (for two points, this is the infinite line passing through them).
    
- **Affine Space:** A geometric structure that "forgets" where the origin is. Unlike a vector space, you cannot "add" two points in an affine space, but you can subtract two points to get a **displacement vector**.
    

---

## 3. Common Use Cases

- **Computer Graphics:** Affine transformations are the bread and butter of 3D rendering (moving objects, stretching textures, and rotating cameras).
    
- **Statistics:** An **affine cipher** is a basic type of substitution cipher.
    
- **Machine Learning:** The "layer" in a neural network ($Wx + b$) is an affine transformation before the non-linear activation function is applied.
    

---

**Would you like me to generate a visual example of an affine transformation (like a "before and after" of a geometric shape), or would you prefer a deeper dive into the linear algebra proofs?**