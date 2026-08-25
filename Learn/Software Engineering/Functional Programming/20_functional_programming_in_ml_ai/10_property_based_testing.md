## Property-Based Testing


Property-based testing verifies that functions satisfy general properties across a wide range of automatically generated inputs, rather than testing specific examples. This approach is particularly powerful for ML/AI where data varies widely and edge cases are hard to predict.

### Basic Property Testing Framework

**Simple Property Testing Implementation:**

```javascript
class PropertyTest {
  constructor(name, property, generator) {
    this.name = name;
    this.property = property;
    this.generator = generator;
  }
  
  run(numTests = 100, seed = 42) {
    let currentSeed = seed;
    
    const seededRandom = () => {
      currentSeed = (currentSeed * 9301 + 49297) % 233280;
      return currentSeed / 233280;
    };
    
    for (let i = 0; i < numTests; i++) {
      const input = this.generator(seededRandom);
      
      try {
        const result = this.property(input);
        if (!result) {
          console.error(`✗ ${this.name} failed with input:`, input);
          return false;
        }
      } catch (error) {
        console.error(`✗ ${this.name} threw error with input:`, input);
        console.error(`  Error: ${error.message}`);
        return false;
      }
    }
    
    console.log(`✓ ${this.name} passed ${numTests} tests`);
    return true;
  }
}

// Generators
const generators = {
  integer: (min = -100, max = 100) => (random) => {
    return Math.floor(random() * (max - min + 1)) + min;
  },
  
  float: (min = -100, max = 100) => (random) => {
    return random() * (max - min) + min;
  },
  
  array: (elementGen, minLength = 0, maxLength = 10) => (random) => {
    const length = Math.floor(random() * (maxLength - minLength + 1)) + minLength;
    return Array.from({ length }, () => elementGen(random));
  },
  
  string: (minLength = 0, maxLength = 10) => (random) => {
    const length = Math.floor(random() * (maxLength - minLength + 1)) + minLength;
    const chars = 'abcdefghijklmnopqrstuvwxyz';
    return Array.from({ length }, () => 
      chars[Math.floor(random() * chars.length)]
    ).join('');
  },
  
  object: (schema) => (random) => {
    return Object.keys(schema).reduce((obj, key) => {
      obj[key] = schema[key](random);
      return obj;
    }, {});
  }
};
```

### Properties for Data Transformations

**Normalization Properties:**

```javascript
// Property: normalized values are in [0, 1]
const testNormalizationRange = new PropertyTest(
  'Normalization produces values in [0, 1]',
  (data) => {
    const min = Math.min(...data);
    const max = Math.max(...data);
    
    const normalize = (value) => (value - min) / (max - min);
    const normalized = data.map(normalize);
    
    return normalized.every(val => val >= 0 && val <= 1);
  },
  generators.array(generators.float(0, 100), 5, 20)
);

// Property: normalization preserves ordering
const testNormalizationOrdering = new PropertyTest(
  'Normalization preserves relative ordering',
  (data) => {
    const min = Math.min(...data);
    const max = Math.max(...data);
    
    const normalize = (value) => (value - min) / (max - min);
    const normalized = data.map(normalize);
    
    // Check if ordering is preserved
    for (let i = 0; i < data.length - 1; i++) {
      for (let j = i + 1; j < data.length; j++) {
        const originalOrder = data[i] <= data[j];
        const normalizedOrder = normalized[i] <= normalized[j];
        if (originalOrder !== normalizedOrder) return false;
      }
    }
    return true;
  },
  generators.array(generators.float(0, 100), 5, 20)
);

// Property: denormalization restores original values
const testNormalizationInverse = new PropertyTest(
  'Denormalization restores original values',
  (data) => {
    const min = Math.min(...data);
    const max = Math.max(...data);
    
    const normalize = (value) => (value - min) / (max - min);
    const denormalize = (value) => value * (max - min) + min;
    
    const normalized = data.map(normalize);
    const restored = normalized.map(denormalize);
    
    return data.every((val, i) => Math.abs(val - restored[i]) < 1e-10);
  },
  generators.array(generators.float(0, 100), 5, 20)
);
```

**Pipeline Properties:**

```javascript
const pipe = (...fns) => (x) => fns.reduce((v, f) => f(v), x);

// Property: pipeline composition is associative
const testPipelineAssociativity = new PropertyTest(
  'Pipeline composition is associative',
  (value) => {
    const f = (x) => x + 1;
    const g = (x) => x * 2;
    const h = (x) => x ** 2;
    
    // (f . g) . h = f . (g . h)
    const left = pipe(pipe(f, g), h);
    const right = pipe(f, pipe(g, h));
    
    return left(value) === right(value);
  },
  generators.integer(1, 10)
);

// Property: identity function in pipeline
const testPipelineIdentity = new PropertyTest(
  'Identity function doesn\'t change pipeline result',
  (value) => {
    const f = (x) => x * 2;
    const g = (x) => x + 10;
    const identity = (x) => x;
    
    const withIdentity = pipe(f, identity, g);
    const withoutIdentity = pipe(f, g);
    
    return withIdentity(value) === withoutIdentity(value);
  },
  generators.integer(1, 100)
);
```

### Properties for Feature Engineering

**Feature Extraction Properties:**

```javascript
// Property: feature count matches extractor count
const testFeatureCount = new PropertyTest(
  'Feature vector length matches number of extractors',
  (person) => {
    const extractors = {
      age: (p) => p.age,
      ageSquared: (p) => p.age ** 2,
      bmi: (p) => p.weight / (p.height ** 2)
    };
    
    const createFeatureVector = (exs) => (data) => {
      return Object.keys(exs).map(key => exs[key](data));
    };
    
    const features = createFeatureVector(extractors)(person);
    return features.length === Object.keys(extractors).length;
  },
  generators.object({
    age: generators.integer(1, 100),
    weight: generators.float(40, 150),
    height: generators.float(1.4, 2.2)
  })
);

// Property: feature extraction is deterministic
const testFeatureDeterminism = new PropertyTest(
  'Same input produces same features',
  (person) => {
    const extractBMI = (p) => p.weight / (p.height ** 2);
    
    const features1 = extractBMI(person);
    const features2 = extractBMI(person);
    
    return features1 === features2;
  },
  generators.object({
    weight: generators.float(40, 150),
    height: generators.float(1.4, 2.2)
  })
);

// Property: one-hot encoding sum
const testOneHotSum = new PropertyTest(
  'One-hot encoded vector sums to 1',
  ({ value, categories }) => {
    const oneHotEncode = (val, cats) => {
      return cats.map(cat => cat === val ? 1 : 0);
    };
    
    const encoded = oneHotEncode(value, categories);
    const sum = encoded.reduce((a, b) => a + b, 0);
    
    return sum <= 1; // <= 1 because value might not be in categories
  },
  (random) => {
    const categories = Array.from({ length: 5 }, (_, i) => `cat${i}`);
    const value = categories[Math.floor(random() * categories.length)];
    return { value, categories };
  }
);
```

### Properties for Data Splitting

**Train-Test Split Properties:**

```javascript
// Property: no data loss in split
const testSplitNoDataLoss = new PropertyTest(
  'Train-test split preserves all data',
  (data) => {
    const trainTestSplit = (arr, testSize = 0.2) => {
      const splitIndex = Math.floor(arr.length * (1 - testSize));
      return {
        train: arr.slice(0, splitIndex),
        test: arr.slice(splitIndex)
      };
    };
    
    const { train, test } = trainTestSplit(data);
    const combined = [...train, ...test];
    
    return combined.length === data.length &&
           combined.every((val, i) => val === data[i]);
  },
  generators.array(generators.integer(0, 100), 10, 50)
);

// Property: no overlap between train and test
const testSplitNoOverlap = new PropertyTest(
  'Train and test sets don\'t overlap',
  (data) => {
    const uniqueData = [...new Set(data)];
    if (uniqueData.length < 2) return true; // Skip if not enough unique values
    
    const trainTestSplit = (arr, testSize = 0.2) => {
      const splitIndex = Math.floor(arr.length * (1 - testSize));
      return {
        train: arr.slice(0, splitIndex),
        test: arr.slice(splitIndex)
      };
    };
    
    const { train, test } = trainTestSplit(uniqueData);
    const trainSet = new Set(train);
    const testSet = new Set(test);
    
    const intersection = [...trainSet].filter(x => testSet.has(x));
    return intersection.length === 0;
  },
  generators.array(generators.integer(0, 100), 10, 50)
);

// Property: split ratio is approximately correct
const testSplitRatio = new PropertyTest(
  'Split maintains approximate test ratio',
  ({ data, testSize }) => {
    const trainTestSplit = (arr, size) => {
      const splitIndex = Math.floor(arr.length * (1 - size));
      return {
        train: arr.slice(0, splitIndex),
        test: arr.slice(splitIndex)
      };
    };
    
    const { train, test } = trainTestSplit(data, testSize);
    const actualRatio = test.length / data.length;
    const tolerance = 0.1; // 10% tolerance
    
    return Math.abs(actualRatio - testSize) <= tolerance;
  },
  (random) => ({
    data: generators.array(generators.integer(0, 100), 20, 100)(random),
    testSize: generators.float(0.1, 0.4)(random)
  })
);
```

### Properties for Batch Processing

**Batching Properties:**

```javascript
// Property: batching preserves all data
const testBatchingPreservesData = new PropertyTest(
  'Batching preserves all data',
  (data) => {
    const createBatches = (arr, batchSize) => {
      const batches = [];
      for (let i = 0; i < arr.length; i += batchSize) {
        batches.push(arr.slice(i, i + batchSize));
      }
      return batches;
    };
    
    const batchSize = Math.max(1, Math.floor(data.length / 3) || 1);
    const batches = createBatches(data, batchSize);
    const flattened = batches.flat();
    
    return flattened.length === data.length &&
           flattened.every((val, i) => val === data[i]);
  },
  generators.array(generators.integer(0, 100), 5, 50)
);

// Property: all batches except last have correct size
const testBatchSizes = new PropertyTest(
  'All batches except possibly last have correct size',
  ({ data, batchSize }) => {
    const createBatches = (arr, size) => {
      const batches = [];
      for (let i = 0; i < arr.length; i += size) {
        batches.push(arr.slice(i, i + size));
      }
      return batches;
    };
    
    const batches = createBatches(data, batchSize);
    
    // Check all batches except last
    for (let i = 0; i < batches.length - 1; i++) {
      if (batches[i].length !== batchSize) return false;
    }
    
    // Last batch can be smaller or equal
    return batches[batches.length - 1].length <= batchSize;
  },
  (random) => ({
    data: generators.array(generators.integer(0, 100), 10, 50)(random),
    batchSize: generators.integer(2, 10)(random)
  })
);
```

### Properties for Metrics

**Classification Metrics Properties:**

```javascript
// Property: accuracy is between 0 and 1
const testAccuracyRange = new PropertyTest(
  'Accuracy is between 0 and 1',
  ({ yTrue, yPred }) => {
    const accuracy = (yt, yp) => {
      const correct = yt.filter((val, i) => val === yp[i]).length;
      return correct / yt.length;
    };
    
    const acc = accuracy(yTrue, yPred);
    return acc >= 0 && acc <= 1;
  },
  (random) => {
    const length = generators.integer(10, 50)(random);
    return {
      yTrue: generators.array(() => Math.floor(random() * 2), length, length)(random),
      yPred: generators.array(() => Math.floor(random() * 2), length, length)(random)
    };
  }
);

// Property: perfect predictions have accuracy = 1
const testPerfectAccuracy = new PropertyTest(
  'Perfect predictions have accuracy 1.0',
  (yTrue) => {
    const accuracy = (yt, yp) => {
      const correct = yt.filter((val, i) => val === yp[i]).length;
      return correct / yt.length;
    };
    
    // yPred = yTrue (perfect predictions)
    const acc = accuracy(yTrue, yTrue);
    return Math.abs(acc - 1.0) < 1e-10;
  },
  generators.array(() => Math.floor(Math.random() * 2), 10, 50)
);

// Property: F1 score is harmonic mean of precision and recall
const testF1IsHarmonicMean = new PropertyTest(
  'F1 is harmonic mean of precision and recall',
  ({ yTrue, yPred }) => {
    const precision = (yt, yp) => {
      const tp = yt.filter((val, i) => val === 1 && yp[i] === 1).length;
      const pp = yp.filter(val => val === 1).length;
      return pp === 0 ? 0 : tp / pp;
    };
    
    const recall = (yt, yp) => {
      const tp = yt.filter((val, i) => val === 1 && yp[i] === 1).length;
      const ap = yt.filter(val => val === 1).length;
      return ap === 0 ? 0 : tp / ap;
    };
    
    const f1 = (yt, yp) => {
      const p = precision(yt, yp);
      const r = recall(yt, yp);
      return p + r === 0 ? 0 : 2 * (p * r) / (p + r);
    };
    
    const p = precision(yTrue, yPred);
    const r = recall(yTrue, yPred);
    const f = f1(yTrue, yPred);
    
    if (p + r === 0) return f === 0;
    
    const expected = 2 * (p * r) / (p + r);
    return Math.abs(f - expected) < 1e-10;
  },
  (random) => {
    const length = generators.integer(10, 50)(random);
    return {
      yTrue: generators.array(() => Math.floor(random() * 2), length, length)(random),
      yPred: generators.array(() => Math.floor(random() * 2), length, length)(random)
    };
  }
);
```

### Running Property Tests

**Test Suite Runner:**

```javascript
const runPropertyTests = () => {
  console.log('Running Property-Based Tests\n');
  
  const tests = [
    // Normalization
    testNormalizationRange,
    testNormalizationOrdering,
    testNormalizationInverse,
    
    // Pipeline
    testPipelineAssociativity,
    testPipelineIdentity,
    
    // Features
    testFeatureCount,
    testFeatureDeterminism,
    testOneHotSum,
    
    // Splitting
    testSplitNoDataLoss,
    testSplitNoOverlap,
    testSplitRatio,
    
    // Batching
    testBatchingPreservesData,
    testBatchSizes,
    
    // Metrics
    testAccuracyRange,
    testPerfectAccuracy,
    testF1IsHarmonicMean
  ];
  
  let passed = 0;
  let failed = 0;
  
  tests.forEach(test => {
    try {
      if (test.run(100)) {
        passed++;
      } else {
        failed++;
      }
    } catch (error) {
      console.error(`Test ${test.name} crashed:`, error.message);
      failed++;
    }
  });
  
  console.log(`\n${'='.repeat(50)}`);
  console.log(`Total: ${tests.length} | Passed: ${passed} | Failed: ${failed}`);
  console.log('='.repeat(50));
};

// Run all tests
runPropertyTests();
```

**Key Points:**

- Property-based testing verifies general properties across many inputs
- Generators create diverse test cases automatically
- Tests verify invariants, relationships, and mathematical properties
- More powerful than example-based tests for catching edge cases
- Particularly useful for data transformations and pipelines
- Tests should verify reversibility, ordering preservation, data integrity
- Metrics tests verify mathematical relationships and ranges
- Split tests ensure no data leakage and correct ratios
- Property tests complement traditional unit tests
- Essential for robust ML/AI systems with varied input data

---

