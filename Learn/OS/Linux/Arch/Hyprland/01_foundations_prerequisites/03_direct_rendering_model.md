## Direct Rendering Model


### Buffer Management

Wayland does not include a rendering API but follows a direct rendering model where clients render window contents to buffers shareable with the compositor. Clients can use rendering libraries like Cairo, OpenGL, or Vulkan, or rely on widget libraries like Qt or GTK.[1]

Rendered contents are stored in `wl_buffer` objects with implementation-dependent internal types, requiring only that content data be shareable between client and compositor. Software renderers can use shared memory via `wl_shm` and `wl_shm_pool` interfaces, though this requires the compositor to copy data to the GPU.[1]

### GPU-Accelerated Rendering

The preferred method involves clients rendering directly into video memory buffers using GPU-accelerated APIs like OpenGL, OpenGL ES, or Vulkan. Client and compositor share GPU-space buffers using special handlers, allowing zero-copy buffer sharing that eliminates the extra data copy present in X11's architecture.[2][1]

When rendering completes, clients bind the buffer object to a surface object and send a commit request, transferring buffer control to the compositor. Clients can either wait for the compositor to release the buffer via an event or use multiple buffers for double/triple buffering.[1]

