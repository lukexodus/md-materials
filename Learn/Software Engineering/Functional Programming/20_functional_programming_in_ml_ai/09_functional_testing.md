## Functional Testing


Functional testing in ML/AI focuses on testing individual components and their compositions using pure functions, ensuring predictable behavior, correctness, and reliability of data processing and model pipelines.

### Testing Pure Transformations

**Unit Tests for Preprocessing:**

```javascript
// Test helpers
const assertEqual = (actual, expected, message = '') => {
  const isEqual = JSON.stringify(actual) === JSON.stringify(expected);
  if (!isEqual) {
    throw new Error(`Assertion failed: ${message}\nExpected: ${JSON.stringify(expected)}\nActual: ${JSON.stringify(actual)}`);
  }
  console.log(`✓ ${message || 'Test passed'}`);
};

const assertAlmostEqual = (actual, expected, tolerance = 1e-10, message = '') => {
  const diff = Math.abs(actual - expected);
  if (diff > tolerance) {
    throw new Error(`${message}\nExpected: ${expected}, Actual: ${actual}, Diff: ${diff}`);
  }
  console.log(`✓ ${message || 'Test passed'}`);
};

// Test normalization
const testNormalize = () => {
  const normalize = (value, min, max) => (value - min) / (max - min);
  
  // Test cases
  assertAlmostEqual(normalize(5, 0, 10), 0.5, 1e-10, 'Normalize midpoint');
  assertAlmostEqual(normalize(0, 0, 10), 0.0, 1e-10, 'Normalize minimum');
  assertAlmostEqual(normalize(10, 0, 10), 1.0, 1e-10, 'Normalize maximum');
  assertAlmostEqual(normalize(15, 0, 10), 1.5, 1e-10, 'Normalize out of range');
  assertAlmostEqual(normalize(-5, 0, 10), -0.5, 1e-10, 'Normalize negative');
};

// Test tokenization
const testTokenize = () => {
  const tokenize = (text) => text.toLowerCase().split(/\s+/).filter(Boolean);
  
  assertEqual(
    tokenize('Hello World'),
    ['hello', 'world'],
    'Basic tokenization'
  );
  
  assertEqual(
    tokenize('  Multiple   Spaces  '),
    ['multiple', 'spaces'],
    'Handle multiple spaces'
  );
  
  assertEqual(
    tokenize(''),
    [],
    'Empty string'
  );
};

// Test feature extraction
const testFeatureExtraction = () => {
  const extractAge = (person) => person.age;
  const extractBMI = (person) => person.weight / (person.height ** 2);
  
  const person = { age: 30, weight: 70, height: 1.75 };
  
  assertEqual(extractAge(person), 30, 'Extract age');
  assertAlmostEqual(extractBMI(person), 22.857, 0.001, 'Calculate BMI');
};

// Run tests
const runTests = () => {
  try {
    testNormalize();
    testTokenize();
    testFeatureExtraction();
    console.log('\nAll tests passed! ✓');
  } catch (error) {
    console.error('\nTest failed:', error.message);
  }
};
```

### Testing Pipelines

**Pipeline Composition Tests:**

```javascript
const pipe = (...fns) => (x) => fns.reduce((v, f) => f(v), x);

const testPipeline = () => {
  // Define transformations
  const double = (x) => x * 2;
  const addTen = (x) => x + 10;
  const square = (x) => x ** 2;
  
  // Test individual functions
  assertEqual(double(5), 10, 'Double function');
  assertEqual(addTen(5), 15, 'Add ten function');
  assertEqual(square(5), 25, 'Square function');
  
  // Test pipeline
  const transform = pipe(double, addTen, square);
  assertEqual(transform(5), 400, 'Pipeline: (5 * 2 + 10) ** 2');
  
  // Test empty pipeline
  const identity = pipe();
  assertEqual(identity(5), 5, 'Empty pipeline acts as identity');
  
  // Test single function pipeline
  const singleStep = pipe(double);
  assertEqual(singleStep(5), 10, 'Single function pipeline');
};

// Test text processing pipeline
const testTextPipeline = () => {
  const toLowerCase = (text) => text.toLowerCase();
  const removeSpecialChars = (text) => text.replace(/[^a-z0-9\s]/g, '');
  const tokenize = (text) => text.split(/\s+/).filter(Boolean);
  
  const preprocessText = pipe(toLowerCase, removeSpecialChars, tokenize);
  
  assertEqual(
    preprocessText('Hello, World! 123'),
    ['hello', 'world', '123'],
    'Text preprocessing pipeline'
  );
  
  // Test pipeline idempotency
  const input = 'Test String!';
  const firstPass = preprocessText(input);
  const secondPass = preprocessText(firstPass.join(' '));
  assertEqual(firstPass, secondPass, 'Pipeline is idempotent');
};
```

### Testing Data Transformations

**Batch Processing Tests:**

```javascript
const testBatchProcessing = () => {
  const createBatches = (data, batchSize) => {
    const batches = [];
    for (let i = 0; i < data.length; i += batchSize) {
      batches.push(data.slice(i, i + batchSize));
    }
    return batches;
  };
  
  const data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  
  // Test even division
  const batches1 = createBatches(data, 5);
  assertEqual(batches1.length, 2, 'Two batches for batch size 5');
  assertEqual(batches1[0], [1, 2, 3, 4, 5], 'First batch correct');
  assertEqual(batches1[1], [6, 7, 8, 9, 10], 'Second batch correct');
  
  // Test uneven division
  const batches2 = createBatches(data, 3);
  assertEqual(batches2.length, 4, 'Four batches for batch size 3');
  assertEqual(batches2[3], [10], 'Last batch has remainder');
  
  // Test batch size larger than data
  const batches3 = createBatches(data, 20);
  assertEqual(batches3.length, 1, 'Single batch when size > data length');
  assertEqual(batches3[0], data, 'Batch contains all data');
  
  // Test data integrity
  const allData = batches2.flat();
  assertEqual(allData, data, 'No data loss in batching');
};
```

**Normalization Tests:**

```javascript
const testNormalizationProperties = () => {
  const normalize = (value, min, max) => (value - min) / (max - min);
  
  // Test range preservation
  const data = [10, 20, 30, 40, 50];
  const min = Math.min(...data);
  const max = Math.max(...data);
  const normalized = data.map(v => normalize(v, min, max));
  
  assertAlmostEqual(Math.min(...normalized), 0.0, 1e-10, 'Min normalizes to 0');
  assertAlmostEqual(Math.max(...normalized), 1.0, 1e-10, 'Max normalizes to 1');
  
  // Test ordering preservation
  const isMonotonic = normalized.every((val, i, arr) => 
    i === 0 || val >= arr[i - 1]
  );
  assertEqual(isMonotonic, true, 'Normalization preserves ordering');
  
  // Test inverse transformation
  const denormalize = (value, min, max) => value * (max - min) + min;
  const restored = normalized.map(v => denormalize(v, min, max));
  
  restored.forEach((val, i) => {
    assertAlmostEqual(val, data[i], 1e-10, `Denormalization restores original value at index ${i}`);
  });
};
```

### Testing Feature Engineering

**Feature Extraction Tests:**

```javascript
const testFeatureEngineering = () => {
  const person = {
    age: 30,
    weight: 70,
    height: 1.75,
    income: 50000
  };
  
  const extractFeatures = {
    age: (p) => p.age,
    ageSquared: (p) => p.age ** 2,
    bmi: (p) => p.weight / (p.height ** 2),
    incomeLog: (p) => Math.log(p.income),
    isAdult: (p) => p.age >= 18 ? 1 : 0
  };
  
  // Test individual extractors
  assertEqual(extractFeatures.age(person), 30, 'Extract age');
  assertEqual(extractFeatures.ageSquared(person), 900, 'Extract age squared');
  assertAlmostEqual(extractFeatures.bmi(person), 22.857, 0.001, 'Calculate BMI');
  assertAlmostEqual(extractFeatures.incomeLog(person), 10.82, 0.01, 'Log income');
  assertEqual(extractFeatures.isAdult(person), 1, 'Is adult flag');
  
  // Test feature vector creation
  const createFeatureVector = (extractors) => (data) => {
    return Object.keys(extractors).map(key => extractors[key](data));
  };
  
  const featureExtractor = createFeatureVector(extractFeatures);
  const features = featureExtractor(person);
  
  assertEqual(features.length, 5, 'Correct number of features');
  assertEqual(features[0], 30, 'First feature is age');
  assertEqual(features[features.length - 1], 1, 'Last feature is adult flag');
};
```

**One-Hot Encoding Tests:**

```javascript
const testOneHotEncoding = () => {
  const oneHotEncode = (value, categories) => {
    return categories.map(cat => cat === value ? 1 : 0);
  };
  
  const categories = ['red', 'green', 'blue'];
  
  // Test each category
  assertEqual(oneHotEncode('red', categories), [1, 0, 0], 'Encode red');
  assertEqual(oneHotEncode('green', categories), [0, 1, 0], 'Encode green');
  assertEqual(oneHotEncode('blue', categories), [0, 0, 1], 'Encode blue');
  
  // Test unknown category
  assertEqual(oneHotEncode('yellow', categories), [0, 0, 0], 'Unknown category');
  
  // Test sum property
  const encoded = oneHotEncode('red', categories);
  const sum = encoded.reduce((a, b) => a + b, 0);
  assertEqual(sum, 1, 'One-hot vector sums to 1');
};
```

### Testing Model Evaluation

**Metrics Tests:**

```javascript
const testMetrics = () => {
  // Accuracy
  const accuracy = (yTrue, yPred) => {
    const correct = yTrue.filter((val, i) => val === yPred[i]).length;
    return correct / yTrue.length;
  };

  const yTrue1 = [0, 1, 1, 0, 1];
  const yPred1 = [0, 1, 0, 0, 1];

  assertAlmostEqual(
    accuracy(yTrue1, yPred1),
    0.8,
    1e-10,
    'Accuracy calculation'
  );

  // Precision
  const precision = (yTrue, yPred, positiveClass = 1) => {
    const truePositives = yTrue.filter(
      (val, i) => val === positiveClass && yPred[i] === positiveClass
    ).length;

    const predictedPositives = yPred.filter(
      val => val === positiveClass
    ).length;

    return predictedPositives === 0
      ? 0
      : truePositives / predictedPositives;
  };

  assertAlmostEqual(
    precision(yTrue1, yPred1),
    2 / 3,
    1e-10,
    'Precision calculation'
  );

  // Recall
  const recall = (yTrue, yPred, positiveClass = 1) => {
    const truePositives = yTrue.filter(
      (val, i) => val === positiveClass && yPred[i] === positiveClass
    ).length;

    const actualPositives = yTrue.filter(
      val => val === positiveClass
    ).length;

    return actualPositives === 0
      ? 0
      : truePositives / actualPositives;
  };

  assertAlmostEqual(
    recall(yTrue1, yPred1),
    2 / 3,
    1e-10,
    'Recall calculation'
  );

  // F1 Score
  const f1Score = (yTrue, yPred, positiveClass = 1) => {
    const p = precision(yTrue, yPred, positiveClass);
    const r = recall(yTrue, yPred, positiveClass);

    return p + r === 0
      ? 0
      : (2 * p * r) / (p + r);
  };

  assertAlmostEqual(
    f1Score(yTrue1, yPred1),
    2 / 3,
    1e-10,
    'F1 score calculation'
  );

  // Edge case: all correct
  const yTrue2 = [1, 1, 1];
  const yPred2 = [1, 1, 1];

  assertAlmostEqual(
    accuracy(yTrue2, yPred2),
    1.0,
    1e-10,
    'Perfect accuracy'
  );
  assertAlmostEqual(
    precision(yTrue2, yPred2),
    1.0,
    1e-10,
    'Perfect precision'
  );
  assertAlmostEqual(
    recall(yTrue2, yPred2),
    1.0,
    1e-10,
    'Perfect recall'
  );

  // Edge case: all wrong
  const yTrue3 = [0, 0, 0];
  const yPred3 = [1, 1, 1];

  assertAlmostEqual(
    accuracy(yTrue3, yPred3),
    0.0,
    1e-10,
    'Zero accuracy'
  );
  assertAlmostEqual(
    precision(yTrue3, yPred3),
    0.0,
    1e-10,
    'Zero precision'
  );
};

````

**Cross-Validation Tests:**
```javascript
const testCrossValidation = () => {
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
  
  const createKFolds = (data, k, seed = 42) => {
    const shuffled = shuffleWithSeed(data, seed);
    const foldSize = Math.floor(shuffled.length / k);
    
    return Array.from({ length: k }, (_, i) => {
      const testStart = i * foldSize;
      const testEnd = i === k - 1 ? shuffled.length : (i + 1) * foldSize;
      
      return {
        train: [
          ...shuffled.slice(0, testStart),
          ...shuffled.slice(testEnd)
        ],
        test: shuffled.slice(testStart, testEnd),
        fold: i
      };
    });
  };
  
  const data = Array.from({ length: 100 }, (_, i) => i);
  const folds = createKFolds(data, 5, 42);
  
  // Test number of folds
  assertEqual(folds.length, 5, 'Correct number of folds');
  
  // Test no data loss
  const allTestData = folds.flatMap(fold => fold.test);
  assertEqual(allTestData.length, 100, 'All data appears in test sets');
  
  // Test no overlap in test sets
  const testSets = folds.map(fold => new Set(fold.test));
  for (let i = 0; i < testSets.length; i++) {
    for (let j = i + 1; j < testSets.length; j++) {
      const intersection = [...testSets[i]].filter(x => testSets[j].has(x));
      assertEqual(intersection.length, 0, `No overlap between folds ${i} and ${j}`);
    }
  }
  
  // Test train + test = all data for each fold
  folds.forEach((fold, i) => {
    const combined = [...fold.train, ...fold.test].sort((a, b) => a - b);
    const sorted = [...data].sort((a, b) => a - b);
    assertEqual(combined, sorted, `Fold ${i}: train + test = all data`);
  });
  
  // Test reproducibility
  const folds2 = createKFolds(data, 5, 42);
  assertEqual(
    JSON.stringify(folds),
    JSON.stringify(folds2),
    'Same seed produces same folds'
  );
};
````

**Key Points:**

- Functional testing focuses on pure function behavior and compositions
- Tests should verify correctness, edge cases, and mathematical properties
- Pipeline tests ensure composition works correctly
- Transformation tests verify data integrity and invertibility
- Feature engineering tests validate extraction logic
- Metric tests check calculation accuracy and edge cases
- Cross-validation tests ensure no data leakage
- Pure functions make testing deterministic and reproducible
- All tests should be repeatable with same inputs
- Essential for maintaining ML pipeline reliability

