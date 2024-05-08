/*******************
 * Compute Buffers *
 *******************/

layout(push_constant) uniform Cosntants {
    int stage;
} constants;

layout(set = 0, binding = 0, std430) restrict readonly buffer ParamsBuffer {
    int width;
    int height;
    ivec2 brush_position;
    bool mouse_pressed;
    Element selected_element;
    float vertical_rand;
    float horizontal_rand;
    int stage;
} params;

layout(set = 0, binding = 1, std430) restrict buffer ElementsBuffer {
    Element data[];
} elements;

layout(set = 0, binding = 2, std430) restrict buffer OutputElementsBuffer {
    Element data[];
} output_elements;

layout(rgba8, binding = 3) restrict writeonly uniform image2D output_texture;

layout(set = 0, binding = 4, std430) restrict writeonly buffer DebugMetricsBuffer {
    int empty_count;
    int sand_count;
    int water_count;
    int wood_count;
    int gas_count;
} debug_metrics;