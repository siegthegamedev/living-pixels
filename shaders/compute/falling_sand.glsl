#[compute]
#version 450

#include "includes/types.glsl"
#include "includes/buffers.glsl"
#include "includes/utils.glsl"
#include "includes/elements/sand.glsl"
#include "includes/elements/water.glsl"
#include "includes/elements/wood.glsl"
#include "includes/elements/gas.glsl"
#include "includes/update.glsl"

layout(local_size_x = 1024, local_size_y = 1, local_size_z = 1) in;
void main() {
    if (gl_GlobalInvocationID.x >= elements.data.length()) return;
    uint x = gl_GlobalInvocationID.x % params.width;
    uint y = gl_GlobalInvocationID.x / params.width;

    switch (constants.stage) {
        case 0: { // Input stage
            if (params.mouse_pressed) update_brush(x, y);
            break;   
        }
        case 1: { // Vertical movement stage
            reset_debug_metrics();
            update_vertical(elements.data[gl_GlobalInvocationID.x], x, y);
            break;
        }
        case 2: { // Buffer swap stage 1
            sync_buffers(x, y);
            clear_output_buffer(x, y);
            break;
        }
        case 3: { // Diagonal movement stage
            update_diagonal(elements.data[gl_GlobalInvocationID.x], x, y);
            break;
        }
        case 4: { // Buffer swap stage 2
            sync_buffers(x, y);
            clear_output_buffer(x, y);
            break;
        }
        case 5: { // Horizontal movement stage
            update_horizontal(elements.data[gl_GlobalInvocationID.x], x, y);
            break;
        }
        case 6: { // Buffer swap stage 3
            sync_buffers(x, y);
            clear_output_buffer(x, y);
            break;
        }
        case 7: { // Final stage
            update_debug_metrics(elements.data[gl_GlobalInvocationID.x].id);
            imageStore(output_texture, ivec2(x, y), get_element_base_color(elements.data[gl_GlobalInvocationID.x].id));
            break;
        }
        default: return;
    }
}