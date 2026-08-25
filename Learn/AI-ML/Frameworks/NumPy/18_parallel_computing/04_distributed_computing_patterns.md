## Distributed Computing Patterns


Distributed computing extends NumPy's capabilities across multiple machines, enabling processing of datasets and computations that exceed single-machine resources. These patterns handle network communication, data distribution, fault tolerance, and result aggregation.

**Key points:**

- Data partitioning strategies optimize network communication and computational balance
- Distributed array abstractions maintain NumPy-like interfaces across clusters
- Fault tolerance mechanisms handle node failures and network partitions
- Load balancing adapts to heterogeneous computing environments
- Integration with distributed computing frameworks extends scalability

**Example:**

```python
import numpy as np
from concurrent.futures import ThreadPoolExecutor, as_completed
import socket
import pickle
import threading
import queue
import time
from typing import List, Tuple, Dict, Any
import hashlib

class DistributedArrayCoordinator:
    """Coordinator for distributed NumPy array operations across multiple nodes."""
    
    def __init__(self, worker_nodes: List[Tuple[str, int]]):
        self.worker_nodes = worker_nodes
        self.n_workers = len(worker_nodes)
        self.connections = {}
        self.worker_status = {}
        self.result_cache = {}
        
        # Connect to all worker nodes
        self._establish_connections()
    
    def _establish_connections(self):
        """Establish connections to all worker nodes."""
        for i, (host, port) in enumerate(self.worker_nodes):
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.connect((host, port))
                self.connections[i] = sock
                self.worker_status[i] = 'connected'
                print(f"Connected to worker {i} at {host}:{port}")
            except Exception as e:
                print(f"Failed to connect to worker {i} at {host}:{port}: {e}")
                self.worker_status[i] = 'failed'
    
    def _send_task(self, worker_id: int, task_data: Dict[str, Any]) -> bool:
        """Send task to specific worker node."""
        try:
            if worker_id not in self.connections:
                return False
            
            sock = self.connections[worker_id]
            
            # Serialize task data
            serialized_task = pickle.dumps(task_data)
            task_size = len(serialized_task)
            
            # Send size header followed by task data
            sock.sendall(task_size.to_bytes(8, byteorder='big'))
            sock.sendall(serialized_task)
            
            return True
        except Exception as e:
            print(f"Failed to send task to worker {worker_id}: {e}")
            self.worker_status[worker_id] = 'failed'
            return False
    
    def _receive_result(self, worker_id: int) -> Any:
        """Receive result from specific worker node."""
        try:
            if worker_id not in self.connections:
                return None
            
            sock = self.connections[worker_id]
            
            # Receive size header
            size_bytes = sock.recv(8)
            if len(size_bytes) != 8:
                return None
            
            result_size = int.from_bytes(size_bytes, byteorder='big')
            
            # Receive result data
            result_data = b''
            while len(result_data) < result_size:
                chunk = sock.recv(min(result_size - len(result_data), 8192))
                if not chunk:
                    break
                result_data += chunk
            
            # Deserialize result
            result = pickle.loads(result_data)
            return result
            
        except Exception as e:
            print(f"Failed to receive result from worker {worker_id}: {e}")
            return None
    
    def distributed_array_operation(self, arrays: List[np.ndarray], 
                                  operation: str, **kwargs) -> np.ndarray:
        """Perform distributed array operation across worker nodes."""
        
        if operation == 'matrix_multiply':
            return self._distributed_matrix_multiply(arrays[0], arrays[1])
        elif operation == 'element_wise':
            func = kwargs.get('function')
            return self._distributed_element_wise(arrays, func)
        elif operation == 'reduction':
            func = kwargs.get('reduction_func', np.sum)
            axis = kwargs.get('axis', None)
            return self._distributed_reduction(arrays[0], func, axis)
        else:
            raise ValueError(f"Unknown distributed operation: {operation}")
    
    def _distributed_matrix_multiply(self, A: np.ndarray, B: np.ndarray) -> np.ndarray:
        """Distributed matrix multiplication using block decomposition."""
        m, k = A.shape
        n = B.shape[1]
        
        # Calculate optimal block sizes
        block_size_m = max(64, m // self.n_workers)
        block_size_n = max(64, n // self.n_workers)
        
        # Create result matrix
        C = np.zeros((m, n), dtype=np.result_type(A.dtype, B.dtype))
        
        # Generate block tasks
        tasks = []
        task_id = 0
        
        for i in range(0, m, block_size_m):
            for j in range(0, n, block_size_n):
                i_end = min(i + block_size_m, m)
                j_end = min(j + block_size_n, n)
                
                task = {
                    'task_id': task_id,
                    'operation': 'block_matrix_multiply',
                    'A_block': A[i:i_end, :],
                    'B_block': B[:, j:j_end],
                    'block_position': (i, i_end, j, j_end)
                }
                tasks.append(task)
                task_id += 1
        
        # Distribute tasks to workers
        active_workers = [w for w in range(self.n_workers) 
                         if self.worker_status[w] == 'connected']
        
        if not active_workers:
            raise RuntimeError("No active worker nodes available")
        
        # Send tasks in round-robin fashion
        task_assignments = {}
        for i, task in enumerate(tasks):
            worker_id = active_workers[i % len(active_workers)]
            if self._send_task(worker_id, task):
                task_assignments[task['task_id']] = worker_id
        
        # Collect results
        completed_tasks = 0
        while completed_tasks < len(tasks):
            for task_id, worker_id in task_assignments.items():
                if task_id in self.result_cache:
                    continue  # Already processed
                
                result = self._receive_result(worker_id)
                if result is not None:
                    # Extract block result and position
                    block_result = result['block_result']
                    i, i_end, j, j_end = result['block_position']
                    
                    # Accumulate into final result
                    C[i:i_end, j:j_end] += block_result
                    
                    self.result_cache[task_id] = result
                    completed_tasks += 1
        
        return C
    
    def _distributed_element_wise(self, arrays: List[np.ndarray], 
                                operation_func) -> List[np.ndarray]:
        """Apply element-wise operation across distributed arrays."""
        # Partition arrays across workers
        arrays_per_worker = len(arrays) // self.n_workers
        
        tasks = []
        task_id = 0
        
        for worker_idx in range(self.n_workers):
            start_idx = worker_idx * arrays_per_worker
            if worker_idx == self.n_workers - 1:
                end_idx = len(arrays)  # Last worker gets remainder
            else:
                end_idx = start_idx + arrays_per_worker
            
            if start_idx < len(arrays):
                task = {
                    'task_id': task_id,
                    'operation': 'element_wise',
                    'arrays': arrays[start_idx:end_idx],
                    'function_code': pickle.dumps(operation_func),
                    'array_indices': (start_idx, end_idx)
                }
                tasks.append(task)
                task_id += 1
        
        # Send tasks to workers
        active_workers = [w for w in range(self.n_workers) 
                         if self.worker_status[w] == 'connected']
        task_assignments = {}
        
        for i, task in enumerate(tasks):
            worker_id = active_workers[i % len(active_workers)]
            if self._send_task(worker_id, task):
                task_assignments[task['task_id']] = worker_id
        
        # Collect results
        results = [None] * len(arrays)
        completed_tasks = 0
        
        while completed_tasks < len(tasks):
            for task_id, worker_id in task_assignments.items():
                if task_id in self.result_cache:
                    continue
                
                result = self._receive_result(worker_id)
                if result is not None:
                    start_idx, end_idx = result['array_indices']
                    worker_results = result['results']
                    
                    # Place results in correct positions
                    for i, worker_result in enumerate(worker_results):
                        results[start_idx + i] = worker_result
                    
                    self.result_cache[task_id] = result
                    completed_tasks += 1
        
        return results
    
    def _distributed_reduction(self, array: np.ndarray, reduction_func, axis=None):
        """Distributed reduction operation with tree-based aggregation."""
        # Split array across workers
        if axis is None:
            # Flatten and split
            flat_array = array.flatten()
            chunk_size = len(flat_array) // self.n_workers
        else:
            # Split along specified axis
            chunk_size = array.shape[axis] // self.n_workers
        
        # Create initial reduction tasks
        tasks = []
        for worker_idx in range(self.n_workers):
            start_idx = worker_idx * chunk_size
            if worker_idx == self.n_workers - 1:
                end_idx = len(flat_array) if axis is None else array.shape[axis]
            else:
                end_idx = start_idx + chunk_size
            
            if axis is None:
                array_chunk = flat_array[start_idx:end_idx]
            else:
                array_chunk = np.take(array, range(start_idx, end_idx), axis=axis)
            
            task = {
                'task_id': worker_idx,
                'operation': 'reduction',
                'array_chunk': array_chunk,
                'reduction_func_code': pickle.dumps(reduction_func),
                'axis': axis
            }
            tasks.append(task)
        
        # Send initial reduction tasks
        active_workers = [w for w in range(self.n_workers) 
                         if self.worker_status[w] == 'connected']
        
        for i, task in enumerate(tasks):
            worker_id = active_workers[i % len(active_workers)]
            self._send_task(worker_id, task)
        
        # Collect partial results
        partial_results = []
        for worker_idx in range(len(tasks)):
            worker_id = active_workers[worker_idx % len(active_workers)]
            result = self._receive_result(worker_id)
            if result is not None:
                partial_results.append(result['partial_result'])
        
        # Perform final reduction locally
        if len(partial_results) == 1:
            return partial_results[0]
        else:
            final_array = np.array(partial_results)
            return reduction_func(final_array, axis=0)
    
    def close_connections(self):
        """Close all worker connections."""
        for sock in self.connections.values():
            sock.close()
        self.connections.clear()

class DistributedArrayWorker:
    """Worker node for distributed array operations."""
    
    def __init__(self, host='localhost', port=8888):
        self.host = host
        self.port = port
        self.server_socket = None
        self.running = False
    
    def start_server(self):
        """Start worker server to handle coordinator requests."""
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server_socket.bind((self.host, self.port))
        self.server_socket.listen(5)
        
        self.running = True
        print(f"Worker server started on {self.host}:{self.port}")
        
        while self.running:
            try:
                client_socket, address = self.server_socket.accept()
                print(f"Connection from {address}")
                
                # Handle client in separate thread
                client_thread = threading.Thread(
                    target=self._handle_client,
                    args=(client_socket,)
                )
                client_thread.start()
                
            except Exception as e:
                if self.running:
                    print(f"Server error: {e}")
    
    def _handle_client(self, client_socket):
        """Handle individual client connection."""
        try:
            while True:
                # Receive task size
                size_bytes = client_socket.recv(8)
                if len(size_bytes) != 8:
                    break
                
                task_size = int.from_bytes(size_bytes, byteorder='big')
                
                # Receive task data
                task_data = b''
                while len(task_data) < task_size:
                    chunk = client_socket.recv(min(task_size - len(task_data), 8192))
                    if not chunk:
                        break
                    task_data += chunk
                
                # Deserialize and process task
                task = pickle.loads(task_data)
                result = self._process_task(task)
                
                # Send result back
                serialized_result = pickle.dumps(result)
                result_size = len(serialized_result)
                
                client_socket.sendall(result_size.to_bytes(8, byteorder='big'))
                client_socket.sendall(serialized_result)
                
        except Exception as e:
            print(f"Client handling error: {e}")
        finally:
            client_socket.close()
    
    def _process_task(self, task: Dict[str, Any]) -> Dict[str, Any]:
        """Process received task and return result."""
        operation = task['operation']
        
        try:
            if operation == 'block_matrix_multiply':
                A_block = task['A_block']
                B_block = task['B_block']
                block_position = task['block_position']
                
                # Compute block multiplication
                block_result = np.dot(A_block, B_block)
                
                return {
                    'task_id': task['task_id'],
                    'block_result': block_result,
                    'block_position': block_position,
                    'status': 'success'
                }
            
            elif operation == 'element_wise':
                arrays = task['arrays']
                function_code = task['function_code']
                array_indices = task['array_indices']
                
                # Deserialize function
                operation_func = pickle.loads(function_code)
                
                # Apply function to all arrays
                results = [operation_func(arr) for arr in arrays]
                
                return {
                    'task_id': task['task_id'],
                    'results': results,
                    'array_indices': array_indices,
                    'status': 'success'
                }
            
            elif operation == 'reduction':
                array_chunk = task['array_chunk']
                reduction_func_code = task['reduction_func_code']
                axis = task['axis']
                
                # Deserialize reduction function
                reduction_func = pickle.loads(reduction_func_code)
                
                # Perform partial reduction
                partial_result = reduction_func(array_chunk, axis=axis)
                
                return {
                    'task_id': task['task_id'],
                    'partial_result': partial_result,
                    'status': 'success'
                }
            
            else:
                return {
                    'task_id': task['task_id'],
                    'error': f"Unknown operation: {operation}",
                    'status': 'error'
                }
                
        except Exception as e:
            return {
                'task_id': task['task_id'],
                'error': str(e),
                'status': 'error'
            }
    
    def stop_server(self):
        """Stop the worker server."""
        self.running = False
        if self.server_socket:
            self.server_socket.close()

# [Inference] High-level distributed computing frameworks integration
class DistributedArrayFrameworkAdapter:
    """Adapter for integrating NumPy with distributed computing frameworks."""
    
    def __init__(self, framework='dask'):
        self.framework = framework
        self._setup_framework()
    
    def _setup_framework(self):
        """[Unverified] Setup connection to distributed framework."""
        if self.framework == 'dask':
            try:
                import dask.array as da
                from dask.distributed import Client
                self.client = Client()  # Connect to Dask cluster
                self.da = da
                self.framework_available = True
            except ImportError:
                print("Dask not available, falling back to local processing")
                self.framework_available = False
        
        elif self.framework == 'ray':
            try:
                import ray
                ray.init(ignore_reinit_error=True)
                self.framework_available = True
            except ImportError:
                print("Ray not available, falling back to local processing")
                self.framework_available = False
    
    def distribute_array(self, array: np.ndarray, chunk_size=None):
        """Convert NumPy array to distributed array."""
        if not self.framework_available:
            return array
        
        if self.framework == 'dask':
            if chunk_size is None:
                chunk_size = max(1000, array.shape[0] // 10)  # Reasonable default
            
            chunks = (chunk_size,) + array.shape[1:]
            return self.da.from_array(array, chunks=chunks)
        
        elif self.framework == 'ray':
            # [Unverified] Ray array distribution pattern
            import ray
            
            @ray.remote
            class ArrayChunk:
                def __init__(self, data):
                    self.data = data
                
                def get_data(self):
                    return self.data
                
                def apply_function(self, func):
                    return func(self.data)
            
            # Split array into chunks
            if chunk_size is None:
                chunk_size = max(1000, array.shape[0] // 10)
            
            chunks = []
            for i in range(0, array.shape[0], chunk_size):
                chunk_data = array[i:i + chunk_size]
                chunk_ref = ArrayChunk.remote(chunk_data)
                chunks.append(chunk_ref)
            
            return chunks
    
    def distributed_operation(self, distributed_array, operation, **kwargs):
        """Perform operation on distributed array."""
        if not self.framework_available:
            # Fall back to local NumPy operation
            if hasattr(distributed_array, operation):
                return getattr(distributed_array, operation)(**kwargs)
            else:
                return operation(distributed_array, **kwargs)
        
        if self.framework == 'dask':
            if operation == 'sum':
                return distributed_array.sum(**kwargs).compute()
            elif operation == 'mean':
                return distributed_array.mean(**kwargs).compute()
            elif operation == 'std':
                return distributed_array.std(**kwargs).compute()
            elif operation == 'dot':
                other = kwargs.get('other')
                return self.da.dot(distributed_array, other).compute()
            elif callable(operation):
                # Custom function
                result = operation(distributed_array, **kwargs)
                if hasattr(result, 'compute'):
                    return result.compute()
                return result
        
        elif self.framework == 'ray':
            import ray
            
            if operation == 'sum':
                @ray.remote
                def chunk_sum(chunk_ref):
                    chunk_data = ray.get(chunk_ref.get_data.remote())
                    return np.sum(chunk_data, **kwargs)
                
                chunk_sums = [chunk_sum.remote(chunk) for chunk in distributed_array]
                partial_sums = ray.get(chunk_sums)
                return np.sum(partial_sums)
            
            elif callable(operation):
                @ray.remote
                def apply_operation(chunk_ref):
                    chunk_data = ray.get(chunk_ref.get_data.remote())
                    return operation(chunk_data, **kwargs)
                
                results = [apply_operation.remote(chunk) for chunk in distributed_array]
                return ray.get(results)

# Fault-tolerant distributed computing patterns
class FaultTolerantDistributedProcessor:
    """Fault-tolerant distributed processor with automatic recovery."""
    
    def __init__(self, worker_nodes: List[Tuple[str, int]], 
                 max_retries=3, timeout=30):
        self.worker_nodes = worker_nodes
        self.max_retries = max_retries
        self.timeout = timeout
        self.failed_workers = set()
        self.task_history = {}
        
        # Health monitoring
        self.last_health_check = {}
        self.health_check_interval = 60  # seconds
    
    def _health_check_worker(self, worker_id: int) -> bool:
        """Check if worker node is responsive."""
        if worker_id in self.failed_workers:
            return False
        
        current_time = time.time()
        last_check = self.last_health_check.get(worker_id, 0)
        
        if current_time - last_check < self.health_check_interval:
            return True  # Recently checked
        
        try:
            host, port = self.worker_nodes[worker_id]
            with socket.create_connection((host, port), timeout=5) as sock:
                # Send ping task
                ping_task = {
                    'operation': 'ping',
                    'timestamp': current_time
                }
                
                serialized = pickle.dumps(ping_task)
                sock.sendall(len(serialized).to_bytes(8, byteorder='big'))
                sock.sendall(serialized)
                
                # Wait for pong response
                response_size_bytes = sock.recv(8)
                if len(response_size_bytes) == 8:
                    self.last_health_check[worker_id] = current_time
                    return True
                
        except Exception as e:
            print(f"Health check failed for worker {worker_id}: {e}")
            self.failed_workers.add(worker_id)
            return False
        
        return False
    
    def _get_healthy_workers(self) -> List[int]:
        """Get list of currently healthy worker nodes."""
        healthy_workers = []
        for worker_id in range(len(self.worker_nodes)):
            if self._health_check_worker(worker_id):
                healthy_workers.append(worker_id)
        
        return healthy_workers
    
    def _execute_task_with_retry(self, task: Dict[str, Any]) -> Any:
        """Execute task with automatic retry on failure."""
        task_id = task.get('task_id', 'unknown')
        attempts = 0
        
        while attempts < self.max_retries:
            healthy_workers = self._get_healthy_workers()
            
            if not healthy_workers:
                raise RuntimeError("No healthy workers available")
            
            # Select worker (round-robin or load-based selection)
            worker_id = healthy_workers[attempts % len(healthy_workers)]
            
            try:
                # Send task to selected worker
                result = self._send_and_receive_task(worker_id, task)
                
                # Log successful execution
                self.task_history[task_id] = {
                    'worker_id': worker_id,
                    'attempts': attempts + 1,
                    'status': 'success'
                }
                
                return result
                
            except Exception as e:
                attempts += 1
                print(f"Task {task_id} failed on worker {worker_id}, attempt {attempts}: {e}")
                
                # Mark worker as potentially failed
                if attempts >= 2:  # After second failure
                    self.failed_workers.add(worker_id)
                
                if attempts >= self.max_retries:
                    self.task_history[task_id] = {
                        'worker_id': worker_id,
                        'attempts': attempts,
                        'status': 'failed',
                        'error': str(e)
                    }
                    raise RuntimeError(f"Task {task_id} failed after {attempts} attempts: {e}")
        
        raise RuntimeError(f"Task {task_id} exceeded maximum retry attempts")
    
    def _send_and_receive_task(self, worker_id: int, task: Dict[str, Any]) -> Any:
        """Send task to worker and receive result with timeout."""
        host, port = self.worker_nodes[worker_id]
        
        with socket.create_connection((host, port), timeout=self.timeout) as sock:
            # Set socket timeout for receive operations
            sock.settimeout(self.timeout)
            
            # Send task
            serialized_task = pickle.dumps(task)
            sock.sendall(len(serialized_task).to_bytes(8, byteorder='big'))
            sock.sendall(serialized_task)
            
            # Receive result
            result_size_bytes = sock.recv(8)
            if len(result_size_bytes) != 8:
                raise RuntimeError("Failed to receive result size")
            
            result_size = int.from_bytes(result_size_bytes, byteorder='big')
            
            # Receive result data
            result_data = b''
            while len(result_data) < result_size:
                chunk = sock.recv(min(result_size - len(result_data), 8192))
                if not chunk:
                    raise RuntimeError("Connection closed while receiving result")
                result_data += chunk
            
            # Deserialize and return result
            return pickle.loads(result_data)
    
    def process_task_batch(self, tasks: List[Dict[str, Any]]) -> List[Any]:
        """Process batch of tasks with fault tolerance."""
        results = []
        
        # Use thread pool for parallel task execution
        with ThreadPoolExecutor(max_workers=min(len(tasks), 10)) as executor:
            # Submit all tasks
            future_to_task = {
                executor.submit(self._execute_task_with_retry, task): task
                for task in tasks
            }
            
            # Collect results as they complete
            for future in as_completed(future_to_task):
                task = future_to_task[future]
                try:
                    result = future.result()
                    results.append({
                        'task_id': task.get('task_id'),
                        'result': result,
                        'status': 'success'
                    })
                except Exception as e:
                    results.append({
                        'task_id': task.get('task_id'),
                        'error': str(e),
                        'status': 'failed'
                    })
        
        return results

# Comprehensive distributed computing demonstration
def demonstrate_distributed_computing():
    """Demonstrate distributed computing patterns with NumPy arrays."""
    print("Starting distributed computing demonstration...")
    
    # Simulate distributed environment (in practice, these would be separate machines)
    # For demonstration, we'll use localhost with different ports
    
    # Start worker nodes (in separate processes for simulation)
    from multiprocessing import Process
    
    def start_worker(port):
        worker = DistributedArrayWorker(host='localhost', port=port)
        worker.start_server()
    
    # Start worker processes
    worker_ports = [9001, 9002, 9003, 9004]
    worker_processes = []
    
    for port in worker_ports:
        process = Process(target=start_worker, args=(port,))
        process.daemon = True
        process.start()
        worker_processes.append(process)
    
    time.sleep(2)  # Wait for workers to start
    
    try:
        # Create coordinator
        worker_nodes = [('localhost', port) for port in worker_ports]
        coordinator = DistributedArrayCoordinator(worker_nodes)
        
        # Test distributed matrix multiplication
        print("\nTesting distributed matrix multiplication...")
        A = np.random.randn(1000, 800)
        B = np.random.randn(800, 600)
        
        start_time = time.time()
        distributed_result = coordinator.distributed_array_operation([A, B], 'matrix_multiply')
        distributed_time = time.time() - start_time
        
        # Compare with local computation
        start_time = time.time()
        local_result = np.dot(A, B)
        local_time = time.time() - start_time
        
        print(f"Distributed computation time: {distributed_time:.3f} seconds")
        print(f"Local computation time: {local_time:.3f} seconds")
        print(f"Results match: {np.allclose(distributed_result, local_result, rtol=1e-10)}")
        
        # Test distributed element-wise operations
        print("\nTesting distributed element-wise operations...")
        test_arrays = [np.random.randn(500, 500) for _ in range(8)]
        
        def complex_transform(arr):
            return np.fft.fft2(arr).real + np.sin(arr) * np.cos(arr)
        
        start_time = time.time()
        distributed_results = coordinator.distributed_array_operation(
            test_arrays, 'element_wise', function=complex_transform
        )
        distributed_time = time.time() - start_time
        
        # Local comparison
        start_time = time.time()
        local_results = [complex_transform(arr) for arr in test_arrays]
        local_time = time.time() - start_time
        
        print(f"Distributed element-wise time: {distributed_time:.3f} seconds")
        print(f"Local element-wise time: {local_time:.3f} seconds")
        
        # Verify results
        all_match = all(
            np.allclose(dist, local, rtol=1e-10)
            for dist, local in zip(distributed_results, local_results)
        )
        print(f"All results match: {all_match}")
        
        # Test fault tolerance
        print("\nTesting fault-tolerant processing...")
        fault_processor = FaultTolerantDistributedProcessor(worker_nodes)
        
        # Create test tasks
        test_tasks = []
        for i in range(20):
            task = {
                'task_id': f'fault_test_{i}',
                'operation': 'element_wise',
                'arrays': [np.random.randn(100, 100)],
                'function_code': pickle.dumps(lambda x: np.sum(x**2))
            }
            test_tasks.append(task)
        
        start_time = time.time()
        fault_results = fault_processor.process_task_batch(test_tasks)
        fault_time = time.time() - start_time
        
        successful_tasks = sum(1 for r in fault_results if r['status'] == 'success')
        print(f"Fault-tolerant processing completed in {fault_time:.3f} seconds")
        print(f"Successful tasks: {successful_tasks}/{len(test_tasks)}")
        
        # Clean up
        coordinator.close_connections()
        
    except Exception as e:
        print(f"Demonstration error: {e}")
    
    finally:
        # Terminate worker processes
        for process in worker_processes:
            process.terminate()
            process.join(timeout=1)

if __name__ == "__main__":
    # Run demonstration
    demonstrate_distributed_computing()
```

