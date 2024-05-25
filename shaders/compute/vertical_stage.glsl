#version 450

{macros}

{types}

{buffers}

{utils}

{elements}

{update}

layout(local_size_x = 1024, local_size_y = 1, local_size_z = 1) in;
void main() {
    if (gl_GlobalInvocationID.x >= elements.data.length()) return;
    uint x = gl_GlobalInvocationID.x % params.width;
    uint y = gl_GlobalInvocationID.x / params.width;

    reset_debug_metrics();
    update_vertical(elements.data[gl_GlobalInvocationID.x], x, y);
}