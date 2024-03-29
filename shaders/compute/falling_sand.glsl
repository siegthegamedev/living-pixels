#[compute]
#version 450

struct Element {
    int id;
    float density;
    float flamability;
};

layout(local_size_x = 1024, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer ElementsBuffer {
    Element data[];
} elements_buffer;

void main() {
    if (gl_GlobalInvocationID.x >= elements_buffer.data.length()) return;
    elements_buffer.data[gl_GlobalInvocationID.x].id += 1;
}