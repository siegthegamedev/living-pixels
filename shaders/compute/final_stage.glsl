#[compute]
#version 450

#extension GL_GOOGLE_include_directive : enable

#include "includes/macros.glsl"
#include "includes/types.glsl"
#include "includes/buffers.glsl"
#include "includes/utils.glsl"
#include "includes/elements.glsl"
#include "includes/update.glsl"

layout(local_size_x = 1024, local_size_y = 1, local_size_z = 1) in;
void main() {
    if (gl_GlobalInvocationID.x >= elements.data.length()) return;
    uint x = gl_GlobalInvocationID.x % params.width;
    uint y = gl_GlobalInvocationID.x / params.width;

    update_debug_metrics(elements.data[gl_GlobalInvocationID.x].id);
    imageStore(output_texture, ivec2(x, y), get_element_base_color(elements.data[gl_GlobalInvocationID.x].id));
}