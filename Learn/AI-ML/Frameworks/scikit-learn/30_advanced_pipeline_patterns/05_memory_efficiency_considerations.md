## Memory Efficiency Considerations


### Memory-Aware Transformations

Memory-efficient pipelines minimize RAM usage through strategic data handling, sparse matrix utilization, and incremental processing approaches that avoid loading entire datasets simultaneously.

```python
from sklearn.preprocessing import StandardScaler
from scipy import sparse
import gc

class MemoryEfficientPipeline(Pipeline):
    def __init__(self, steps, memory_limit_gb=4.0, use_sparse=True):
        super().__init__(steps)
        self.memory_limit_gb = memory_limit_gb
        self.use_sparse = use_sparse
        self.memory_usage_ = []
    
    def fit(self, X, y=None):
        import psutil
        
        current_X = X
        process = psutil.Process()
        
        for step_idx, (name, transformer) in enumerate(self.steps[:-1]):
            # Monitor memory usage
            memory_before = process.memory_info().rss / 1024**3  # GB
            
            # Apply memory-efficient transformations
            if self.use_sparse and hasattr(transformer, 'sparse_output'):
                transformer.set_params(sparse_output=True)
            
            # Check if we need to process in chunks
            estimated_memory = self._estimate_memory_usage(current_X, transformer)
            if estimated_memory > self.memory_limit_gb:
                current_X = self._chunked_fit_transform(current_X, transformer, y)
            else:
                current_X = transformer.fit_transform(current_X, y)
            
            # Force garbage collection
            gc.collect()
            
            memory_after = process.memory_info().rss / 1024**3
            self.memory_usage_.append({
                'step': name,
                'memory_before': memory_before,
                'memory_after': memory_after,
                'memory_delta': memory_after - memory_before
            })
        
        # Fit final estimator
        if self.steps:
            final_estimator = self.steps[-1][1]
            final_estimator.fit(current_X, y)
        
        return self
    
    def _estimate_memory_usage(self, X, transformer):
        # Rough estimation based on data size and transformation type
        base_size = X.nbytes if hasattr(X, 'nbytes') else X.size * 8  # bytes
        
        multipliers = {
            'StandardScaler': 1.1,
            'OneHotEncoder': 5.0,  # Can create many new features
            'PolynomialFeatures': 10.0,  # Quadratic growth
            'PCA': 2.0
        }
        
        transformer_name = transformer.__class__.__name__
        multiplier = multipliers.get(transformer_name, 2.0)
        
        estimated_bytes = base_size * multiplier
        return estimated_bytes / 1024**3  # Convert to GB
    
    def _chunked_fit_transform(self, X, transformer, y=None, chunk_size=10000):
        # Process data in chunks to manage memory
        if hasattr(X, 'shape'):
            n_samples = X.shape[0]
        else:
            n_samples = len(X)
        
        # Fit on first chunk to initialize transformer
        first_chunk_X = X[:min(chunk_size, n_samples)]
        first_chunk_y = y[:min(chunk_size, n_samples)] if y is not None else None
        transformer.fit(first_chunk_X, first_chunk_y)
        
        # Transform all chunks
        transformed_chunks = []
        for start_idx in range(0, n_samples, chunk_size):
            end_idx = min(start_idx + chunk_size, n_samples)
            chunk_X = X[start_idx:end_idx]
            
            transformed_chunk = transformer.transform(chunk_X)
            transformed_chunks.append(transformed_chunk)
            
            # Clear intermediate variables
            del chunk_X
            gc.collect()
        
        # Combine results
        if sparse.issparse(transformed_chunks[0]):
            return sparse.vstack(transformed_chunks)
        else:
            return np.vstack(transformed_chunks)

class SparsePreservingTransformer(BaseEstimator, TransformerMixin):
    """Wrapper that preserves sparse matrices throughout transformation"""
    
    def __init__(self, base_transformer):
        self.base_transformer = base_transformer
    
    def fit(self, X, y=None):
        # Convert to dense if necessary for fitting
        if sparse.issparse(X) and not self._supports_sparse(self.base_transformer):
            X_dense = X.toarray()
            self.base_transformer.fit(X_dense, y)
        else:
            self.base_transformer.fit(X, y)
        return self
    
    def transform(self, X):
        was_sparse = sparse.issparse(X)
        
        if was_sparse and not self._supports_sparse(self.base_transformer):
            X_dense = X.toarray()
            transformed = self.base_transformer.transform(X_dense)
            # Convert back to sparse if beneficial
            if self._should_be_sparse(transformed):
                return sparse.csr_matrix(transformed)
            return transformed
        else:
            return self.base_transformer.transform(X)
    
    def _supports_sparse(self, transformer):
        # Check if transformer supports sparse matrices
        sparse_support = getattr(transformer, '_get_tags', lambda: {}).get('requires_positive_X', False)
        return hasattr(transformer, 'accept_sparse') or sparse_support
    
    def _should_be_sparse(self, X, threshold=0.1):
        # Determine if array should be stored as sparse
        if hasattr(X, 'nnz'):
            return True  # Already sparse
        
        zero_fraction = (X == 0).sum() / X.size
        return zero_fraction > (1 - threshold)

# Memory-efficient pipeline with sparse preservation
memory_efficient_pipeline = MemoryEfficientPipeline([
    ('sparse_scaler', SparsePreservingTransformer(StandardScaler())),
    ('sparse_selector', SparsePreservingTransformer(SelectKBest(k=100))),
    ('classifier', LogisticRegression())
], memory_limit_gb=2.0, use_sparse=True)
```

### Incremental Learning Integration

Memory-constrained environments benefit from incremental learning approaches that process data in small batches, updating model parameters incrementally without storing entire datasets.

```python
from sklearn.linear_model import SGDClassifier
from sklearn.preprocessing import StandardScaler

class IncrementalPipeline(BaseEstimator, ClassifierMixin):
    def __init__(self, preprocessing_steps=None, estimator=None, batch_size=1000):
        self.preprocessing_steps = preprocessing_steps or []
        self.estimator = estimator or SGDClassifier()
        self.batch_size = batch_size```python
        self.fitted_preprocessors_ = []
        self.is_fitted_ = False
    
    def partial_fit(self, X, y, classes=None):
        # Initialize on first call
        if not self.is_fitted_:
            self._initialize_preprocessors(X, y)
            if hasattr(self.estimator, 'partial_fit'):
                # Initialize estimator with classes if needed
                X_transformed = self._transform_batch(X)
                self.estimator.partial_fit(X_transformed, y, classes=classes)
            self.is_fitted_ = True
        else:
            # Transform and update
            X_transformed = self._transform_batch(X)
            if hasattr(self.estimator, 'partial_fit'):
                self.estimator.partial_fit(X_transformed, y)
            else:
                raise ValueError("Estimator does not support incremental learning")
        
        return self
    
    def fit(self, X, y):
        n_samples = X.shape[0]
        classes = np.unique(y)
        
        # Process in batches
        for start_idx in range(0, n_samples, self.batch_size):
            end_idx = min(start_idx + self.batch_size, n_samples)
            batch_X = X[start_idx:end_idx]
            batch_y = y[start_idx:end_idx]
            
            self.partial_fit(batch_X, batch_y, classes=classes)
        
        return self
    
    def _initialize_preprocessors(self, X_sample, y_sample):
        # Initialize preprocessing steps with sample data
        current_X = X_sample
        
        for name, preprocessor in self.preprocessing_steps:
            # For incremental preprocessing, fit on sample
            fitted_preprocessor = clone(preprocessor)
            fitted_preprocessor.fit(current_X, y_sample)
            self.fitted_preprocessors_.append((name, fitted_preprocessor))
            current_X = fitted_preprocessor.transform(current_X)
    
    def _transform_batch(self, X):
        current_X = X
        for name, fitted_preprocessor in self.fitted_preprocessors_:
            current_X = fitted_preprocessor.transform(current_X)
        return current_X
    
    def predict(self, X):
        X_transformed = self._transform_batch(X)
        return self.estimator.predict(X_transformed)
    
    def predict_proba(self, X):
        X_transformed = self._transform_batch(X)
        return self.estimator.predict_proba(X_transformed)

# Incremental pipeline for streaming data
incremental_pipeline = IncrementalPipeline(
    preprocessing_steps=[
        ('scaler', StandardScaler()),
        ('selector', SelectKBest(k=50))
    ],
    estimator=SGDClassifier(random_state=42),
    batch_size=1000
)
```

### Memory Pool Management

Advanced memory management involves creating reusable memory pools and implementing custom allocation strategies to minimize memory fragmentation and garbage collection overhead.

```python
import numpy as np
from collections import deque
import weakref

class MemoryPool:
    def __init__(self, max_pool_size=5, cleanup_threshold=0.8):
        self.max_pool_size = max_pool_size
        self.cleanup_threshold = cleanup_threshold
        self.pools = {}  # dtype -> deque of arrays
        self.usage_stats = {}
        
    def get_array(self, shape, dtype=np.float64):
        key = (tuple(shape), dtype)
        
        if key not in self.pools:
            self.pools[key] = deque()
            self.usage_stats[key] = {'hits': 0, 'misses': 0}
        
        pool = self.pools[key]
        
        if pool:
            array = pool.popleft()
            array.fill(0)  # Clear previous data
            self.usage_stats[key]['hits'] += 1
            return array
        else:
            self.usage_stats[key]['misses'] += 1
            return np.zeros(shape, dtype=dtype)
    
    def return_array(self, array):
        if array is None:
            return
            
        key = (tuple(array.shape), array.dtype)
        
        if key in self.pools and len(self.pools[key]) < self.max_pool_size:
            self.pools[key].append(array)
        
        # Cleanup if memory usage is high
        if self._memory_usage_high():
            self._cleanup_pools()
    
    def _memory_usage_high(self):
        import psutil
        return psutil.virtual_memory().percent > (self.cleanup_threshold * 100)
    
    def _cleanup_pools(self):
        # Remove least used arrays from pools
        for key, pool in self.pools.items():
            if len(pool) > 1:
                # Keep only most recently used arrays
                keep_size = max(1, len(pool) // 2)
                while len(pool) > keep_size:
                    pool.pop()

class MemoryManagedTransformer(BaseEstimator, TransformerMixin):
    _memory_pool = MemoryPool()
    
    def __init__(self, base_transformer):
        self.base_transformer = base_transformer
        self.temp_arrays_ = []
    
    def fit(self, X, y=None):
        self.base_transformer.fit(X, y)
        return self
    
    def transform(self, X):
        # Get temporary array from pool
        temp_array = self._memory_pool.get_array(X.shape, X.dtype)
        self.temp_arrays_.append(temp_array)
        
        try:
            # Copy data to managed memory
            temp_array[:] = X
            
            # Apply transformation
            result = self.base_transformer.transform(temp_array)
            
            # Return managed memory result if possible
            if result.shape != X.shape:
                managed_result = self._memory_pool.get_array(result.shape, result.dtype)
                managed_result[:] = result
                self.temp_arrays_.append(managed_result)
                return managed_result
            else:
                return result
                
        finally:
            # Clean up temporary arrays
            self._cleanup_temp_arrays()
    
    def _cleanup_temp_arrays(self):
        for array in self.temp_arrays_:
            self._memory_pool.return_array(array)
        self.temp_arrays_.clear()
    
    def __del__(self):
        self._cleanup_temp_arrays()
```

### Out-of-Core Processing

Extremely large datasets that exceed available RAM require out-of-core processing techniques that work with data stored on disk, loading only necessary portions into memory.

```python
import joblib
import tempfile
import os

class OutOfCoreTransformer(BaseEstimator, TransformerMixin):
    def __init__(self, base_transformer, chunk_size=10000, temp_dir=None, 
                 compression=3):
        self.base_transformer = base_transformer
        self.chunk_size = chunk_size
        self.temp_dir = temp_dir or tempfile.mkdtemp()
        self.compression = compression
        self.chunk_files_ = []
        self.fitted_ = False
    
    def fit(self, X, y=None):
        # For large datasets, fit on representative sample
        if hasattr(X, 'shape') and X.shape[0] > self.chunk_size * 10:
            # Use stratified sample for fitting
            sample_indices = self._get_stratified_sample(X, y, size=self.chunk_size * 5)
            X_sample = X[sample_indices] if not hasattr(X, 'iloc') else X.iloc[sample_indices]
            y_sample = y[sample_indices] if y is not None else None
            self.base_transformer.fit(X_sample, y_sample)
        else:
            self.base_transformer.fit(X, y)
        
        self.fitted_ = True
        return self
    
    def transform(self, X):
        if not self.fitted_:
            raise ValueError("Transformer must be fitted before transform")
        
        n_samples = X.shape[0] if hasattr(X, 'shape') else len(X)
        
        # Process in chunks and save to disk
        self.chunk_files_ = []
        
        for start_idx in range(0, n_samples, self.chunk_size):
            end_idx = min(start_idx + self.chunk_size, n_samples)
            
            # Load chunk
            if hasattr(X, 'iloc'):
                chunk = X.iloc[start_idx:end_idx]
            else:
                chunk = X[start_idx:end_idx]
            
            # Transform chunk
            transformed_chunk = self.base_transformer.transform(chunk)
            
            # Save chunk to disk
            chunk_file = os.path.join(self.temp_dir, f'chunk_{len(self.chunk_files_)}.joblib')
            joblib.dump(transformed_chunk, chunk_file, compress=self.compression)
            self.chunk_files_.append(chunk_file)
            
            # Clear memory
            del chunk, transformed_chunk
            gc.collect()
        
        # Return lazy loader for transformed data
        return OutOfCoreArray(self.chunk_files_, self.temp_dir)
    
    def _get_stratified_sample(self, X, y, size):
        if y is None:
            return np.random.choice(X.shape[0], size=min(size, X.shape[0]), replace=False)
        
        from sklearn.model_selection import train_test_split
        _, _, indices = train_test_split(
            X, np.arange(len(y)), test_size=min(size / len(y), 0.5),
            stratify=y, random_state=42
        )
        return indices
    
    def __del__(self):
        self.cleanup()
    
    def cleanup(self):
        # Clean up temporary files
        for chunk_file in self.chunk_files_:
            if os.path.exists(chunk_file):
                os.remove(chunk_file)
        self.chunk_files_.clear()

class OutOfCoreArray:
    def __init__(self, chunk_files, temp_dir):
        self.chunk_files = chunk_files
        self.temp_dir = temp_dir
        self._shape = None
        self._dtype = None
        self._load_metadata()
    
    def _load_metadata(self):
        if self.chunk_files:
            first_chunk = joblib.load(self.chunk_files[0])
            self._dtype = first_chunk.dtype
            
            # Calculate total shape
            total_rows = 0
            n_cols = first_chunk.shape[1] if len(first_chunk.shape) > 1 else 1
            
            for chunk_file in self.chunk_files:
                chunk = joblib.load(chunk_file)
                total_rows += chunk.shape[0]
                del chunk
            
            self._shape = (total_rows, n_cols) if n_cols > 1 else (total_rows,)
    
    @property
    def shape(self):
        return self._shape
    
    @property
    def dtype(self):
        return self._dtype
    
    def __getitem__(self, key):
        if isinstance(key, slice):
            return self._slice_data(key)
        elif isinstance(key, int):
            return self._get_row(key)
        else:
            raise NotImplementedError("Advanced indexing not yet supported")
    
    def _slice_data(self, slice_obj):
        start, stop, step = slice_obj.indices(self.shape[0])
        
        if step != 1:
            raise NotImplementedError("Step slicing not yet supported")
        
        # Find relevant chunks
        result_chunks = []
        current_start = 0
        
        for chunk_file in self.chunk_files:
            chunk = joblib.load(chunk_file)
            chunk_size = chunk.shape[0]
            current_end = current_start + chunk_size
            
            # Check if this chunk overlaps with requested slice
            if current_end > start and current_start < stop:
                # Calculate overlap
                chunk_start = max(0, start - current_start)
                chunk_end = min(chunk_size, stop - current_start)
                
                relevant_data = chunk[chunk_start:chunk_end]
                result_chunks.append(relevant_data)
            
            current_start = current_end
            del chunk
            
            if current_start >= stop:
                break
        
        if result_chunks:
            return np.vstack(result_chunks)
        else:
            return np.array([])
    
    def _get_row(self, index):
        if index < 0:
            index = self.shape[0] + index
        
        current_start = 0
        for chunk_file in self.chunk_files:
            chunk = joblib.load(chunk_file)
            chunk_size = chunk.shape[0]
            current_end = current_start + chunk_size
            
            if current_start <= index < current_end:
                row_index = index - current_start
                result = chunk[row_index]
                del chunk
                return result
            
            current_start = current_end
            del chunk
        
        raise IndexError(f"Index {index} is out of bounds")
    
    def compute(self):
        # Load all chunks into memory
        chunks = []
        for chunk_file in self.chunk_files:
            chunk = joblib.load(chunk_file)
            chunks.append(chunk)
        
        if chunks:
            return np.vstack(chunks)
        else:
            return np.array([])

# Out-of-core pipeline for massive datasets
class OutOfCorePipeline(Pipeline):
    def __init__(self, steps, chunk_size=10000, temp_dir=None):
        super().__init__(steps)
        self.chunk_size = chunk_size
        self.temp_dir = temp_dir
    
    def fit(self, X, y=None):
        # Wrap transformers with out-of-core capability
        wrapped_steps = []
        
        for name, step in self.steps[:-1]:
            if hasattr(step, 'fit_transform'):
                wrapped_step = OutOfCoreTransformer(
                    step, chunk_size=self.chunk_size, temp_dir=self.temp_dir
                )
            else:
                wrapped_step = step
            
            wrapped_steps.append((name, wrapped_step))
        
        # Add final estimator (unchanged)
        if self.steps:
            wrapped_steps.append(self.steps[-1])
        
        # Create new pipeline with wrapped steps
        self.steps = wrapped_steps
        
        # Fit pipeline
        current_X = X
        for name, step in self.steps[:-1]:
            step.fit(current_X, y)
            current_X = step.transform(current_X)
        
        # Fit final estimator
        if self.steps:
            final_estimator = self.steps[-1][1]
            if isinstance(current_X, OutOfCoreArray):
                # For out-of-core data, fit in batches
                self._fit_estimator_incremental(final_estimator, current_X, y)
            else:
                final_estimator.fit(current_X, y)
        
        return self
    
    def _fit_estimator_incremental(self, estimator, X_out_of_core, y):
        if hasattr(estimator, 'partial_fit'):
            # Incremental fitting
            chunk_start = 0
            for chunk_file in X_out_of_core.chunk_files:
                chunk = joblib.load(chunk_file)
                chunk_size = chunk.shape[0]
                chunk_end = chunk_start + chunk_size
                
                y_chunk = y[chunk_start:chunk_end] if y is not None else None
                
                if chunk_start == 0:
                    classes = np.unique(y) if y is not None else None
                    estimator.partial_fit(chunk, y_chunk, classes=classes)
                else:
                    estimator.partial_fit(chunk, y_chunk)
                
                chunk_start = chunk_end
                del chunk
        else:
            # Load all data and fit normally
            X_full = X_out_of_core.compute()
            estimator.fit(X_full, y)
```

**Key points** for implementing advanced pipeline patterns:

- **Nested structures** enable modular design and code reusability across different problem domains
- **Conditional transformations** provide adaptability to varying data characteristics and quality issues
- **Feature selection integration** combines multiple selection strategies for robust feature subset identification
- **Parallel processing** leverages multi-core systems and distributed computing for computational efficiency
- **Memory management** prevents out-of-memory errors and optimizes resource utilization for large datasets

**Example** implementation combining multiple patterns:

```python
# Comprehensive advanced pipeline
advanced_pipeline = Pipeline([
    ('memory_manager', MemoryManagedTransformer(
        ConditionalTransformer(threshold_skew=0.5)
    )),
    ('feature_engineering', FeatureUnion([
        ('numerical', Pipeline([
            ('scaler', StandardScaler()),
            ('pca', PCA(n_components=10))
        ])),
        ('categorical', Pipeline([
            ('encoder', OneHotEncoder(sparse_output=False)),
            ('selector', SelectKBest(k=15))
        ]))
    ])),
    ('ensemble_selection', EnsembleFeatureSelector(n_features_to_select=20)),
    ('classifier', RandomForestClassifier(n_jobs=-1))
])

# With parallel processing and memory management
parallel_advanced_pipeline = ParallelPipeline([
    ('preprocessing', advanced_pipeline.steps[0][1]),
    ('feature_union', advanced_pipeline.steps[1][1]),
    ('selection', advanced_pipeline.steps[2][1]),
    ('classifier', advanced_pipeline.steps[3][1])
], n_jobs=4)
```

**Output** considerations include monitoring memory usage patterns, tracking transformation performance metrics, and implementing fallback strategies for resource-constrained environments. Advanced patterns require careful testing across different data scales and system configurations to ensure robust deployment.

**Next steps** involve implementing monitoring systems for production pipelines, developing automated optimization strategies based on system resource availability, and creating adaptive patterns that can dynamically adjust processing strategies based on real-time performance feedback.

---

