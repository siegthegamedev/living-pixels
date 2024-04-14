#[compute]
#version 450

struct Element {
    int id;
    float density;
    float flamability;
};

layout(local_size_x = 1024, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer ParamsBuffer {
    int width;
    int height;
} params;

layout(set = 0, binding = 1, std430) restrict buffer ElementsBuffer {
    Element data[];
} elements;

layout(set = 0, binding = 2, std430) restrict buffer OutputElementsBuffer {
    Element data[];
} output_elements;

void update_sand(Element element, uint x, uint y);

void main() {
    if (gl_GlobalInvocationID.x >= elements.data.length()) return;
    uint x = gl_GlobalInvocationID.x % params.width;
    uint y = gl_GlobalInvocationID.x / params.width;

    Element current_element = elements.data[gl_GlobalInvocationID.x];
    switch (current_element.id) {
        case 1: update_sand(current_element, x, y); break;
        default: break;
    }
}

void update_sand(Element element, uint x, uint y) {
    y += 1;
    output_elements.data[y * params.width + x] = element;
}