#[compute]
#version 450

#define MULTIPLY_THREE

#if defined(MULTIPLY_TWO)
float multiply = 2.0;
#elif defined(MULTIPLY_THREE)
float multiply = 3.0;
#else
float multiply = 1.0;
#endif

layout(local_size_x = 2, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer MyDataBuffer {
    float data[];
} my_data_buffer;

void main() {
    my_data_buffer.data[gl_GlobalInvocationID.x] *= multiply;
}




