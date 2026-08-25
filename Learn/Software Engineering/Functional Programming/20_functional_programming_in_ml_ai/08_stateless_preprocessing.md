## Stateless Preprocessing


Stateless preprocessing in ML/AI involves transforming data using pure functions that don't maintain internal state between invocations. This approach ensures reproducibility, enables parallelization, and simplifies testing and debugging of data pipelines.

### Pure Transformation Functions

**Basic Transformations:**

```javascript
// Pure normalization function
const normalize = (value, min, max) => {
  return (value - min) / (max - min);
};

// Pure standardization function
const standardize = (value, mean, stdDev) => {
  return (value - mean) / stdDev;
};

// Pure one-hot encoding
const oneHotEncode = (value, categories) => {
  return categories.map(cat => cat === value ? 1 : 0);
};

// Pure label encoding
const labelEncode = (value, categories) => {
  return categories.indexOf(value);
};

// Usage
const normalizedAge = normalize(25, 0, 100); // 0.25
const standardizedScore = standardize(85, 75, 10); // 1.0
const encoded = oneHotEncode('red', ['red', 'green', 'blue']); // [1, 0, 0]
```

**Composable Feature Engineering:**

```javascript
// Pure feature extraction
const extractFeatures = {
  age: (person) => person.age,
  ageSquared: (person) => person.age ** 2,
  ageLog: (person) => Math.log(person.age + 1),
  bmi: (person) => person.weight / (person.height ** 2),
  isAdult: (person) => person.age >= 18 ? 1 : 0
};

// Compose multiple features
const createFeatureVector = (extractors) => (data) => {
  return Object.keys(extractors).map(key => extractors[key](data));
};

const featureExtractor = createFeatureVector(extractFeatures);

const person = { age: 30, weight: 70, height: 1.75 };
const features = featureExtractor(person);
// [30, 900, 3.434, 22.86, 1]
```

**Pipeline Composition:**

```javascript
const pipe = (...fns) => (x) => fns.reduce((v, f) => f(v), x);

const compose = (...fns) => (x) => fns.reduceRight((v, f) => f(v), x);

// Text preprocessing pipeline
const toLowerCase = (text) => text.toLowerCase();
const removeSpecialChars = (text) => text.replace(/[^a-z0-9\s]/g, '');
const tokenize = (text) => text.split(/\s+/).filter(Boolean);
const removeStopWords = (tokens) => {
  const stopWords = new Set(['the', 'is', 'at', 'which', 'on']);
  return tokens.filter(token => !stopWords.has(token));
};
const stem = (tokens) => tokens.map(token => {
  // Simple stemming
  return token.replace(/ing$|ed$|s$/, '');
});

const preprocessText = pipe(
  toLowerCase,
  removeSpecialChars,
  tokenize,
  removeStopWords,
  stem
);

const text = "The cats are running quickly!";
const processed = preprocessText(text); // ['cat', 'run', 'quick']
```

### Stateless Data Normalization

**Min-Max Scaling with Statistics:**

```javascript
// Compute statistics (pure)
const computeStats = (values) => ({
  min: Math.min(...values),
  max: Math.max(...values),
  mean: values.reduce((a, b) => a + b, 0) / values.length,
  stdDev: Math.sqrt(
    values.reduce((sum, val, _, arr) => {
      const mean = arr.reduce((a, b) => a + b, 0) / arr.length;
      return sum + (val - mean) ** 2;
    }, 0) / values.length
  )
});

// Create scaler (returns pure function)
const createMinMaxScaler = (min, max) => (value) => {
  return (value - min) / (max - min);
};

const createStandardScaler = (mean, stdDev) => (value) => {
  return (value - mean) / stdDev;
};

// Usage - fit on training data
const trainingData = [10, 20, 30, 40, 50];
const stats = computeStats(trainingData);

// Create scalers using computed statistics
const scaler = createMinMaxScaler(stats.min, stats.max);
const standardizer = createStandardScaler(stats.mean, stats.stdDev);

// Apply to new data (stateless)
const testData = [15, 35, 55];
const scaled = testData.map(scaler);
const standardized = testData.map(standardizer);

console.log(scaled); // [0.125, 0.625, 1.125]
```

**Multi-Column Normalization:**

```javascript
// Create normalizers for each column
const createColumnNormalizers = (data) => {
  const columns = Object.keys(data[0]);
  
  return columns.reduce((normalizers, col) => {
    const values = data.map(row => row[col]);
    
    if (typeof values[0] === 'number') {
      const stats = computeStats(values);
      normalizers[col] = createMinMaxScaler(stats.min, stats.max);
    } else {
      // Categorical - create label encoder
      const categories = [...new Set(values)];
      normalizers[col] = (value) => categories.indexOf(value);
    }
    
    return normalizers;
  }, {});
};

// Apply normalizers (pure function)
const normalizeRow = (normalizers) => (row) => {
  return Object.keys(row).reduce((normalized, key) => {
    normalized[key] = normalizers[key](row[key]);
    return normalized;
  }, {});
};

// Usage
const rawData = [
  { age: 25, income: 50000, city: 'NYC' },
  { age: 35, income: 75000, city: 'LA' },
  { age: 45, income: 100000, city: 'NYC' }
];

const normalizers = createColumnNormalizers(rawData);
const normalize = normalizeRow(normalizers);

const newData = { age: 30, income: 60000, city: 'LA' };
const normalized = normalize(newData);
```

### Stateless Feature Selection

**Correlation-Based Selection:**

```javascript
// Pure correlation calculation
const pearsonCorrelation = (x, y) => {
  const n = x.length;
  const sumX = x.reduce((a, b) => a + b, 0);
  const sumY = y.reduce((a, b) => a + b, 0);
  const sumXY = x.reduce((sum, xi, i) => sum + xi * y[i], 0);
  const sumX2 = x.reduce((sum, xi) => sum + xi ** 2, 0);
  const sumY2 = y.reduce((sum, yi) => sum + yi ** 2, 0);
  
  const numerator = n * sumXY - sumX * sumY;
  const denominator = Math.sqrt(
    (n * sumX2 - sumX ** 2) * (n * sumY2 - sumY ** 2)
  );
  
  return numerator / denominator;
};

// Select features by correlation threshold (pure)
const selectFeaturesByCorrelation = (data, target, threshold = 0.5) => {
  const features = Object.keys(data[0]).filter(k => k !== target);
  const targetValues = data.map(row => row[target]);
  
  return features.filter(feature => {
    const featureValues = data.map(row => row[feature]);
    const correlation = Math.abs(pearsonCorrelation(featureValues, targetValues));
    return correlation >= threshold;
  });
};

// Create feature selector (returns pure function)
const createFeatureSelector = (selectedFeatures) => (row) => {
  return selectedFeatures.reduce((selected, feature) => {
    selected[feature] = row[feature];
    return selected;
  }, {});
};
```

**Variance-Based Selection:**

```javascript
// Pure variance calculation
const variance = (values) => {
  const mean = values.reduce((a, b) => a + b, 0) / values.length;
  return values.reduce((sum, val) => sum + (val - mean) ** 2, 0) / values.length;
};

// Select features by variance threshold (pure)
const selectFeaturesByVariance = (data, threshold = 0.01) => {
  const features = Object.keys(data[0]);
  
  return features.filter(feature => {
    const values = data.map(row => row[feature]);
    if (typeof values[0] !== 'number') return true;
    return variance(values) >= threshold;
  });
};
```

### Stateless Data Augmentation

**Image Augmentation (Functional):**

```javascript
// Pure augmentation functions
const flipHorizontal = (image) => {
  return image.map(row => [...row].reverse());
};

const rotate90 = (image) => {
  const rows = image.length;
  const cols = image[0].length;
  const rotated = Array(cols).fill().map(() => Array(rows));
  
  for (let i = 0; i < rows; i++) {
    for (let j = 0; j < cols; j++) {
      rotated[j][rows - 1 - i] = image[i][j];
    }
  }
  
  return rotated;
};

const addNoise = (image, noiseLevel = 0.1) => {
  return image.map(row =>
    row.map(pixel => {
      const noise = (Math.random() - 0.5) * noiseLevel;
      return Math.max(0, Math.min(1, pixel + noise));
    })
  );
};

const adjustBrightness = (image, factor) => {
  return image.map(row =>
    row.map(pixel => Math.max(0, Math.min(1, pixel * factor)))
  );
};

// Compose augmentations
const augmentImage = (augmentations) => (image) => {
  return augmentations.reduce((img, aug) => aug(img), image);
};

// Usage
const originalImage = [
  [0.1, 0.2, 0.3],
  [0.4, 0.5, 0.6],
  [0.7, 0.8, 0.9]
];

const augment1 = augmentImage([
  flipHorizontal,
  (img) => adjustBrightness(img, 1.2)
]);

const augment2 = augmentImage([
  rotate90,
  (img) => addNoise(img, 0.05)
]);

const augmented1 = augment1(originalImage);
const augmented2 = augment2(originalImage);
```

**Text Augmentation:**

```javascript
// Pure text augmentation functions
const synonymReplace = (tokens, synonymMap, probability = 0.3) => {
  return tokens.map(token => {
    if (Math.random() < probability && synonymMap[token]) {
      const synonyms = synonymMap[token];
      return synonyms[Math.floor(Math.random() * synonyms.length)];
    }
    return token;
  });
};

const randomSwap = (tokens, swapCount = 1) => {
  const result = [...tokens];
  for (let i = 0; i < swapCount; i++) {
    const idx1 = Math.floor(Math.random() * result.length);
    const idx2 = Math.floor(Math.random() * result.length);
    [result[idx1], result[idx2]] = [result[idx2], result[idx1]];
  }
  return result;
};

const randomDelete = (tokens, probability = 0.1) => {
  return tokens.filter(() => Math.random() > probability);
};

const randomInsert = (tokens, wordPool, insertCount = 1) => {
  const result = [...tokens];
  for (let i = 0; i < insertCount; i++) {
    const idx = Math.floor(Math.random() * (result.length + 1));
    const word = wordPool[Math.floor(Math.random() * wordPool.length)];
    result.splice(idx, 0, word);
  }
  return result;
};
```

### Stateless Batch Processing

**Batch Generator:**

```javascript
// Pure batch creation
const createBatches = (data, batchSize) => {
  const batches = [];
  for (let i = 0; i < data.length; i += batchSize) {
    batches.push(data.slice(i, i + batchSize));
  }
  return batches;
};

// Shuffle and batch (uses seed for reproducibility)
const shuffleWithSeed = (array, seed) => {
  const result = [...array];
  let currentSeed = seed;
  
  const seededRandom = () => {
    currentSeed = (currentSeed * 9301 + 49297) % 233280;
    return currentSeed / 233280;
  };
  
  for (let i = result.length - 1; i > 0; i--) {
    const j = Math.floor(seededRandom() * (i + 1));
    [result[i], result[j]] = [result[j], result[i]];
  }
  
  return result;
};

const createShuffledBatches = (data, batchSize, seed = 42) => {
  const shuffled = shuffleWithSeed(data, seed);
  return createBatches(shuffled, batchSize);
};

// Usage
const dataset = Array.from({ length: 100 }, (_, i) => ({ id: i, value: i * 2 }));
const batches = createShuffledBatches(dataset, 10, 12345);
```

**Parallel Processing:**

```javascript
// Process batches in parallel (pure operations)
const processBatchesParallel = async (batches, processor) => {
  return Promise.all(batches.map(batch => processor(batch)));
};

// Pure batch processor
const processBatch = (transformations) => (batch) => {
  return batch.map(item => {
    return transformations.reduce((transformed, fn) => fn(transformed), item);
  });
};

// Usage
const transformations = [
  (item) => ({ ...item, normalized: item.value / 100 }),
  (item) => ({ ...item, squared: item.value ** 2 }),
  (item) => ({ ...item, label: item.value > 50 ? 1 : 0 })
];

const processor = processBatch(transformations);
const results = await processBatchesParallel(batches, processor);
```

### Stateless Cross-Validation

**K-Fold Split (Pure):**

```javascript
// Pure k-fold split
const createKFolds = (data, k, seed = 42) => {
  const shuffled = shuffleWithSeed(data, seed);
  const foldSize = Math.floor(shuffled.length / k);
  
  return Array.from({ length: k }, (_, i) => {
    const testStart = i * foldSize;
    const testEnd = i === k - 1 ? shuffled.length : (i + 1) * foldSize;
    
    const testSet = shuffled.slice(testStart, testEnd);
    const trainSet = [
      ...shuffled.slice(0, testStart),
      ...shuffled.slice(testEnd)
    ];
    
    return { train: trainSet, test: testSet, fold: i };
  });
};

// Stratified k-fold (maintains class distribution)
const createStratifiedKFolds = (data, k, labelKey, seed = 42) => {
  // Group by label
  const grouped = data.reduce((groups, item) => {
    const label = item[labelKey];
    if (!groups[label]) groups[label] = [];
    groups[label].push(item);
    return groups;
  }, {});
  
  // Create folds for each class
  const foldsByClass = Object.keys(grouped).map(label => {
    return createKFolds(grouped[label], k, seed);
  });
  
  // Merge folds
  return Array.from({ length: k }, (_, i) => {
    const trainSets = foldsByClass.map(folds => folds[i].train);
    const testSets = foldsByClass.map(folds => folds[i].test);
    
    return {
      train: trainSets.flat(),
      test: testSets.flat(),
      fold: i
    };
  });
};
```

**Train-Test Split:**

```javascript
// Pure train-test split
const trainTestSplit = (data, testSize = 0.2, seed = 42) => {
  const shuffled = shuffleWithSeed(data, seed);
  const splitIndex = Math.floor(shuffled.length * (1 - testSize));
  
  return {
    train: shuffled.slice(0, splitIndex),
    test: shuffled.slice(splitIndex)
  };
};

// Stratified split
const stratifiedSplit = (data, testSize, labelKey, seed = 42) => {
  const grouped = data.reduce((groups, item) => {
    const label = item[labelKey];
    if (!groups[label]) groups[label] = [];
    groups[label].push(item);
    return groups;
  }, {});
  
  const splits = Object.keys(grouped).map(label => {
    return trainTestSplit(grouped[label], testSize, seed);
  });
  
  return {
    train: splits.flatMap(split => split.train),
    test: splits.flatMap(split => split.test)
  };
};
```

**Key Points:**

- Stateless preprocessing uses pure functions without internal state
- All transformations are reproducible given the same inputs
- Statistics (mean, std, min, max) are computed once and passed to transformers
- Feature engineering is composable through function composition
- Data augmentation functions don't modify original data
- Batch processing can be parallelized safely
- Cross-validation splits are deterministic with seeds
- Enables testing, debugging, and distributed processing
- Preprocessing pipelines can be serialized and versioned
- Essential for production ML systems requiring reproducibility

