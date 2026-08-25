## Fourier Transforms (FFT)


Fast Fourier Transform operations in NumPy provide efficient frequency domain analysis capabilities that enable signal processing, spectral analysis, convolution operations, and frequency filtering applications across diverse scientific domains.

The numpy.fft module implements optimized FFT algorithms that transform time-domain or spatial-domain signals into frequency domain representations. These transforms reveal periodic components, enable frequency analysis, and facilitate efficient convolution operations through the convolution theorem.

Discrete Fourier Transform variants include the standard FFT for complex inputs, RFFT for real inputs that exploits conjugate symmetry, and inverse transforms that reconstruct signals from frequency domain representations. Each variant optimizes computational efficiency based on input data characteristics.

Multi-dimensional FFT operations extend frequency analysis to higher-dimensional data structures, enabling analysis of image frequencies, spatial patterns in scientific data, and multi-dimensional signal processing applications. These operations can be applied along specific axes or across all dimensions simultaneously.

Frequency domain filtering utilizes FFT transforms to implement efficient digital filters, noise reduction algorithms, and signal enhancement techniques. The approach transforms signals to frequency domain, applies filtering operations, and transforms back to time domain, often providing superior performance compared to time-domain filtering.

Window functions and spectral analysis techniques improve FFT results by reducing spectral leakage, controlling frequency resolution, and optimizing signal-to-noise ratios. These techniques prove essential for accurate spectral estimation and robust frequency analysis.

**Example:**

```python
import numpy as np
import matplotlib.pyplot as plt

# Create composite signal with multiple frequency components
t = np.linspace(0, 2*np.pi, 1000)
signal = (2*np.sin(5*t) + 1.5*np.sin(20*t) + 
          0.8*np.sin(50*t) + 0.3*np.random.randn(len(t)))

# Forward FFT
fft_result = np.fft.fft(signal)
frequencies = np.fft.fftfreq(len(signal), t[1] - t[0])

# Power spectrum analysis
power_spectrum = np.abs(fft_result)**2

# Real FFT for efficiency with real signals
rfft_result = np.fft.rfft(signal)
rfreqs = np.fft.rfftfreq(len(signal), t[1] - t[0])

# Frequency domain filtering
# Remove high-frequency noise
filtered_fft = fft_result.copy()
filtered_fft[np.abs(frequencies) > 30] = 0
filtered_signal = np.fft.ifft(filtered_fft).real

# 2D FFT for image processing
image = np.random.rand(128, 128)
fft_2d = np.fft.fft2(image)
fft_shifted = np.fft.fftshift(fft_2d)  # Center zero frequency

# Spectral analysis with windowing
windowed_signal = signal * np.hanning(len(signal))
windowed_fft = np.fft.fft(windowed_signal)
```

