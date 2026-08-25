## Image Processing Libraries


Image processing libraries like OpenCV, scikit-image, and PIL/Pillow integrate closely with NumPy, representing images as multi-dimensional NumPy arrays where pixel values, color channels, and spatial dimensions are handled through array operations.

**Key points:**

- Images are represented as NumPy arrays with shape (height, width, channels)
- All image processing operations leverage NumPy's vectorized functions
- Color space conversions and filtering operations use NumPy broadcasting
- Integration supports various data types (uint8, float32, float64) for different precision needs

**Example:**

```python
import numpy as np
import cv2
from skimage import filters, morphology, measure
from PIL import Image

# Load image as NumPy array
image = cv2.imread('example.jpg')  # Returns NumPy array
image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

# NumPy-based image operations
# Brightness adjustment using broadcasting
brightened = np.clip(image_rgb + 50, 0, 255).astype(np.uint8)

# Channel manipulation
red_channel = image_rgb[:, :, 0]  # Extract red channel
grayscale = np.mean(image_rgb, axis=2).astype(np.uint8)

# Advanced processing with scikit-image
edges = filters.sobel(grayscale)
binary = grayscale > filters.threshold_otsu(grayscale)
labeled_regions = measure.label(binary)

# Morphological operations
cleaned = morphology.binary_opening(binary, morphology.disk(3))

# Custom filtering using NumPy operations
kernel = np.array([[-1, -1, -1], [-1, 8, -1], [-1, -1, -1]])
filtered = cv2.filter2D(grayscale, -1, kernel)

# Integration with PIL for format conversion
pil_image = Image.fromarray(image_rgb)
array_from_pil = np.array(pil_image)
```

The integration extends to specialized operations like Fourier transforms for frequency domain processing, where NumPy's FFT functions work directly on image arrays, and geometric transformations that leverage NumPy's linear algebra capabilities.

