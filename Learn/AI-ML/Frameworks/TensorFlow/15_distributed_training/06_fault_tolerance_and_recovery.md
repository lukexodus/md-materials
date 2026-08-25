## Fault Tolerance and Recovery


Distributed training systems must handle various failure modes including hardware failures, network partitions, and preemptions. TensorFlow provides mechanisms for checkpoint-based recovery and graceful failure handling.

**Key Points:**

- Regular checkpointing enables recovery from arbitrary failure points
- Preemption handling essential for cloud and cluster environments
- Backup strategies prevent single points of failure
- Health monitoring detects and responds to degraded performance

### Checkpoint-Based Fault Tolerance

```python
class FaultTolerantTrainer(DistributedTrainer):
    def __init__(self, strategy, model, optimizer, train_dataset, val_dataset=None, 
                 checkpoint_dir='./checkpoints', save_freq=1000):
        super().__init__(strategy, model, optimizer, train_dataset, val_dataset)
        
        self.checkpoint_dir = checkpoint_dir
        self.save_freq = save_freq
        
        # Initialize checkpoint manager
        with strategy.scope():
            self.checkpoint = tf.train.Checkpoint(
                model=model,
                optimizer=optimizer,
                step=tf.Variable(0, dtype=tf.int64)
            )
            
            self.checkpoint_manager = tf.train.CheckpointManager(
                self.checkpoint,
                directory=checkpoint_dir,
                max_to_keep=3,
                step_counter=self.checkpoint.step
            )
            
        # Restore from latest checkpoint if available
        self.restore_checkpoint()
    
    def restore_checkpoint(self):
        latest_checkpoint = self.checkpoint_manager.latest_checkpoint
        if latest_checkpoint:
            self.checkpoint.restore(latest_checkpoint)
            print(f'Restored from checkpoint: {latest_checkpoint}')
            print(f'Starting from step: {self.checkpoint.step.numpy()}')
        else:
            print('No checkpoint found. Starting from scratch.')
    
    def save_checkpoint(self):
        saved_path = self.checkpoint_manager.save(checkpoint_number=self.checkpoint.step)
        print(f'Checkpoint saved: {saved_path}')
        return saved_path
    
    @tf.function
    def distributed_train_step_with_checkpoint(self, inputs):
        loss = self.distributed_train_step(inputs)
        self.checkpoint.step.assign_add(1)
        return loss
    
    def train_with_fault_tolerance(self, epochs, steps_per_epoch=None, validation_steps=None):
        start_epoch = self.checkpoint.step.numpy() // (steps_per_epoch or len(self.train_dataset))
        start_step = self.checkpoint.step.numpy() % (steps_per_epoch or len(self.train_dataset))
        
        try:
            train_iterator = iter(self.train_dist_dataset)
            
            # Skip to current position
            for _ in range(start_step):
                next(train_iterator)
            
            for epoch in range(start_epoch, epochs):
                total_train_loss = 0.0
                num_train_batches = 0
                
                step_range = range(start_step if epoch == start_epoch else 0, 
                                 steps_per_epoch or len(self.train_dataset))
                
                for step in step_range:
                    try:
                        batch = next(train_iterator)
                        loss = self.distributed_train_step_with_checkpoint(batch)
                        total_train_loss += loss
                        num_train_batches += 1
                        
                        # Save checkpoint periodically
                        if self.checkpoint.step % self.save_freq == 0:
                            self.save_checkpoint()
                        
                        if step % 100 == 0:
                            print(f'Epoch {epoch}, Step {step}, Global Step {self.checkpoint.step.numpy()}, Loss: {loss:.4f}')
                    
                    except (tf.errors.UnavailableError, tf.errors.AbortedError) as e:
                        print(f'Recoverable error encountered: {e}')
                        # Save emergency checkpoint
                        self.save_checkpoint()
                        # Re-initialize iterator
                        train_iterator = iter(self.train_dist_dataset)
                        continue
                    
                    except StopIteration:
                        train_iterator = iter(self.train_dist_dataset)
                        batch = next(train_iterator)
                        loss = self.distributed_train_step_with_checkpoint(batch)
                        total_train_loss += loss
                        num_train_batches += 1
                
                # Reset start_step for subsequent epochs
                start_step = 0
                
                # Validation and checkpointing at epoch end
                if self.val_dataset:
                    self.validate_epoch(validation_steps)
                
                # Save checkpoint at end of epoch
                self.save_checkpoint()
                
                avg_train_loss = total_train_loss / num_train_batches if num_train_batches > 0 else 0
                print(f'Epoch {epoch} completed. Average Loss: {avg_train_loss:.4f}')
        
        except Exception as e:
            print(f'Fatal error encountered: {e}')
            # Save emergency checkpoint before exiting
            self.save_checkpoint()
            raise
    
    def validate_epoch(self, validation_steps):
        if not self.val_dataset:
            return
        
        val_iterator = iter(self.val_dist_dataset)
        total_val_loss = 0.0
        total_val_acc = 0.0
        num_val_batches = 0
        
        for step in range(validation_steps or len(self.val_dataset)):
            try:
                batch = next(val_iterator)
                val_loss, val_acc = self.distributed_validation_step(batch)
                total_val_loss += val_loss
                total_val_acc += val_acc
                num_val_batches += 1
            except StopIteration:
                break
            except (tf.errors.UnavailableError, tf.errors.AbortedError):
                # Skip validation on recoverable errors
                print('Validation skipped due to recoverable error')
                return
        
        if num_val_batches > 0:
            avg_val_loss = total_val_loss / num_val_batches
            avg_val_acc = total_val_acc / num_val_batches
            print(f'Validation: Loss: {avg_val_loss:.4f}, Acc: {avg_val_acc:.4f}')

# Health monitoring and preemption handling
class PreemptionHandler:
    def __init__(self, trainer, checkpoint_frequency=300):  # 5 minutes
        self.trainer = trainer
        self.checkpoint_frequency = checkpoint_frequency
        self.last_checkpoint_time = time.time()
        
        # Set up signal handlers for graceful shutdown
        signal.signal(signal.SIGTERM, self._handle_preemption)
        signal.signal(signal.SIGINT, self._handle_preemption)
    
    def _handle_preemption(self, signum, frame):
        print(f'Preemption signal received: {signum}')
        print('Saving checkpoint before shutdown...')
        self.trainer.save_checkpoint()
        print('Checkpoint saved. Exiting gracefully.')
        sys.exit(0)
    
    def check_and_save(self):
        current_time = time.time()
        if current_time - self.last_checkpoint_time > self.checkpoint_frequency:
            self.trainer.save_checkpoint()
            self.last_checkpoint_time = current_time
            
            # Health check [Inference - basic system monitoring]
            gpu_memory = tf.config.experimental.get_memory_info('GPU:0')
            if gpu_memory:
                memory_usage = gpu_memory['current'] / gpu_memory['peak']
                if memory_usage > 0.95:
                    print(f'Warning: High GPU memory usage: {memory_usage:.2%}')

# Usage with fault tolerance
with strategy.scope():
    model = create_model()
    optimizer = tf.keras.optimizers.Adam(learning_rate=0.001)

fault_tolerant_trainer = FaultTolerantTrainer(
    strategy, model, optimizer, train_dataset, val_dataset,
    checkpoint_dir='./fault_tolerant_checkpoints',
    save_freq=500
)

preemption_handler = PreemptionHandler(fault_tolerant_trainer)

# Training with automatic recovery
fault_tolerant_trainer.train_with_fault_tolerance(
    epochs=100,
    steps_per_epoch=2000,
    validation_steps=200
)
```

**Output:** TensorFlow's distributed training capabilities enable efficient scaling across multiple devices and nodes through various parallelism strategies. The Strategy API provides unified interfaces for different hardware configurations while maintaining optimization for specific architectures. Proper implementation of fault tolerance mechanisms ensures robust training in production environments where hardware failures and preemptions are common.

**Implementation Considerations:**

- Choose data parallelism for models that fit on single devices with large datasets
- Apply model parallelism when individual models exceed single-device memory capacity
- Use TPUs for workloads requiring maximum throughput with static computational graphs
- Implement comprehensive checkpointing for long-running distributed training jobs
- Monitor communication overhead and adjust batch sizes accordingly for optimal performance

---

