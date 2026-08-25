## Trigonometric Functions


**Basic Trigonometric Functions**

NumPy provides complete trigonometric functionality supporting both radians and degrees, with functions operating element-wise on arrays.

```python
# Angles in radians
angles_rad = np.array([0, np.pi/4, np.pi/2, np.pi, 2*np.pi])
sin_vals = np.sin(angles_rad)     # [0. 0.707 1. 0. 0.]
cos_vals = np.cos(angles_rad)     # [1. 0.707 0. -1. 1.]
tan_vals = np.tan(angles_rad)     # [0. 1. 16331239353195370. -0. 0.]

# Angles in degrees
angles_deg = np.array([0, 45, 90, 180, 360])
sin_deg = np.sin(np.deg2rad(angles_deg))
cos_deg = np.cos(np.deg2rad(angles_deg))
```

**Inverse Trigonometric Functions**

```python
# Inverse trigonometric functions
values = np.array([-1, -0.5, 0, 0.5, 1])
arcsin_vals = np.arcsin(values)   # Returns radians
arccos_vals = np.arccos(values)
arctan_vals = np.arctan(values)

# Two-argument arctangent
y = np.array([1, 1, -1, -1])
x = np.array([1, -1, 1, -1])
arctan2_vals = np.arctan2(y, x)   # Handles quadrants correctly
```

**Hyperbolic Functions**

```python
# Hyperbolic trigonometric functions
x = np.linspace(-2, 2, 5)
sinh_vals = np.sinh(x)
cosh_vals = np.cosh(x)
tanh_vals = np.tanh(x)

# Inverse hyperbolic functions
arcsinh_vals = np.arcsinh(sinh_vals)
arccosh_vals = np.arccosh(cosh_vals)
arctanh_vals = np.arctanh(np.array([-0.5, 0, 0.5]))
```

