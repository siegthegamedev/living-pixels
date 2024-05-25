/*******************
 * Compute Buffers *
 *******************/

layout(set = 0, binding = 0, std430) restrict readonly buffer ParamsBuffer {
    int width;
    int height;
    ivec2 brush_position;
    int brush_size;
    bool mouse_pressed;
    int selected_element_id;
    float vertical_rand;
    float horizontal_rand;
} params;

layout(set = 0, binding = 1, std430) restrict buffer ElementsBuffer {
    Element data[];
} elements;

layout(set = 0, binding = 2, std430) restrict buffer OutputElementsBuffer {
    Element data[];
} output_elements;

layout(rgba8, binding = 3) restrict writeonly uniform image2D output_texture;

layout(set = 0, binding = 4, std430) restrict buffer ElementDescriptorsBuffer {
    ElementDescriptor data[];
} element_descriptors;

layout(set = 0, binding = 5, std430) restrict writeonly buffer DebugMetricsBuffer {
    int empty_count;
    int sand_count;
    int water_count;
    int wood_count;
    int gas_count;
} debug_metrics;