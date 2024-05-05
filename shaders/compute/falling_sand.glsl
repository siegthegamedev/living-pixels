#[compute]
#version 450

layout(local_size_x = 1024, local_size_y = 1, local_size_z = 1) in;

/*********************
 * Type Declarations *
 *********************/

struct Element {
    int id;
    bool updated;
    float density;
    float flamability;
};

struct UpdateOutput {
    uint x;
    uint y;
    bool updated;
};

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

/*************************
 * Function Declarations *
 *************************/

// Utility Functions
uint get_index_from_position(uint x, uint y);
bool is_cell_empty(uint x, uint y);
void set_output_cell(Element element, uint x, uint y);
void parse_update_output(Element element, UpdateOutput update_output);
void sync_buffers(uint x, uint y);
void clear_output_buffer(uint x, uint y);
void sync_threads(uint x, uint y);
vec4 get_element_base_color(uint element_id);
void reset_debug_metrics();
void update_debug_metrics(uint element_id);

// Update Functions
void update_brush(uint x, uint y);
void update_vertical(Element element, uint x, uint y);
void update_diagonal(Element element, uint x, uint y);
void update_horizontal(Element element, uint x, uint y);

// Element Update functions
// Sand
UpdateOutput update_sand_vertical(uint x, uint y);
UpdateOutput update_sand_diagonal(uint x, uint y);
UpdateOutput update_sand_horizontal(uint x, uint y);
// Water
UpdateOutput update_water_vertical(uint x, uint y);
UpdateOutput update_water_diagonal(uint x, uint y);
UpdateOutput update_water_horizontal(uint x, uint y);
// Wood
UpdateOutput update_wood_vertical(uint x, uint y);
UpdateOutput update_wood_diagonal(uint x, uint y);
UpdateOutput update_wood_horizontal(uint x, uint y);
// Gas
UpdateOutput update_gas_vertical(uint x, uint y);
UpdateOutput update_gas_diagonal(uint x, uint y);
UpdateOutput update_gas_horizontal(uint x, uint y);

/*********************
 * Utility Functions *
 *********************/

uint get_index_from_position(uint x, uint y) {
    return y * params.width + x;
}

bool is_cell_empty(uint x, uint y) {
    return elements.data[get_index_from_position(x, y)].id == 0;
}

bool is_output_cell_empty(uint x, uint y) {
    return output_elements.data[get_index_from_position(x, y)].id == 0;
}

void set_output_cell(Element element, uint x, uint y) {
    if (!is_output_cell_empty(x, y)) return;
    output_elements.data[get_index_from_position(x, y)] = element;
}

void parse_update_output(Element element, UpdateOutput update_output) {
    element.updated = update_output.updated;
    set_output_cell(element, update_output.x, update_output.y);
}

void sync_buffers(uint x, uint y) {
    uint index = get_index_from_position(x, y);
    elements.data[index] = output_elements.data[index];
}

void clear_output_buffer(uint x, uint y) {
    uint index = get_index_from_position(x, y);
    output_elements.data[index].id = 0;
}

void sync_threads() {
    barrier();
    memoryBarrier();
    barrier();
}

vec4 get_element_base_color(uint element_id) {
    switch (element_id) {
        case 0: return vec4(0.0, 0.0, 0.0, 0.0);
        case 1: return vec4(1.0, 0.921569, 0.803922, 1.0);
        case 2: return vec4(0.117647, 0.564706, 1, 1);
        case 3: return vec4(0.545098, 0.270588, 0.0745098, 1.0);
        case 4: return vec4(1.0, 0.894118, 0.882353, 1.0);
        default: return vec4(0.0, 0.0, 0.0, 1.0);
    }
}

void reset_debug_metrics() {
    atomicExchange(debug_metrics.empty_count, 0);
    atomicExchange(debug_metrics.sand_count, 0);
    atomicExchange(debug_metrics.water_count, 0);
    atomicExchange(debug_metrics.wood_count, 0);
    atomicExchange(debug_metrics.gas_count, 0);
}

void update_debug_metrics(uint element_id) {
    switch (element_id) {
        case 0: atomicAdd(debug_metrics.empty_count, 1); break;
        case 1: atomicAdd(debug_metrics.sand_count, 1); break;
        case 2: atomicAdd(debug_metrics.water_count, 1); break;
        case 3: atomicAdd(debug_metrics.wood_count, 1); break;
        case 4: atomicAdd(debug_metrics.gas_count, 1); break;
    }
}

/********************
 * Update Functions *
 ********************/

void update_brush(uint x, uint y) {
    if (abs(x - params.brush_position.x) <= 2 && abs(y - params.brush_position.y) <= 2)
        elements.data[get_index_from_position(x, y)] = params.selected_element;
}

void update_vertical(Element element, uint x, uint y) {
    element.updated = false;
    switch (element.id) {
        case 1: parse_update_output(element, update_sand_vertical(x, y)); break;
        case 2: parse_update_output(element, update_water_vertical(x, y)); break;
        case 3: parse_update_output(element, update_wood_vertical(x, y)); break;
        case 4: parse_update_output(element, update_gas_vertical(x, y)); break;
        default: break;
    }
}

void update_diagonal(Element element, uint x, uint y) {
    if (!element.updated) {
        switch (element.id) {
            case 1: parse_update_output(element, update_sand_diagonal(x, y)); break;
            case 2: parse_update_output(element, update_water_diagonal(x, y)); break;
            case 3: parse_update_output(element, update_wood_diagonal(x, y)); break;
            case 4: parse_update_output(element, update_gas_diagonal(x, y)); break;
            default: break;
        }
    } else set_output_cell(element, x, y);
}

void update_horizontal(Element element, uint x, uint y) {
    if (!element.updated) {
        switch (element.id) {
            case 1: parse_update_output(element, update_sand_horizontal(x, y)); break;
            case 2: parse_update_output(element, update_water_horizontal(x, y)); break;
            case 3: parse_update_output(element, update_wood_horizontal(x, y)); break;
            case 4: parse_update_output(element, update_gas_horizontal(x, y)); break;
            default: break;
        }
    } else set_output_cell(element, x, y);
}

/****************************
 * Element Update Functions *
 ****************************/

/*********** Sand ***********/

UpdateOutput update_sand_vertical(uint x, uint y) {
    if (y < params.height - 1 && is_cell_empty(x, y + 1)) 
        return UpdateOutput(x, y + 1, true);
    return UpdateOutput(x, y, false);
}

UpdateOutput update_sand_diagonal(uint x, uint y) {
    if (y < params.height - 1) {
        if (params.horizontal_rand >= 0.5 && x < params.width - 1 && is_cell_empty(x + 1, y + 1)) 
            return UpdateOutput(x + 1, y + 1, true);
        if (params.horizontal_rand <= 0.5 && x > 0 && is_cell_empty(x - 1, y + 1)) 
            return UpdateOutput(x - 1, y + 1, true);
    }
    return UpdateOutput(x, y, false);
}

UpdateOutput update_sand_horizontal(uint x, uint y) {
    return UpdateOutput(x, y, true);
}

/*********** Water ***********/

UpdateOutput update_water_vertical(uint x, uint y) {
    if (y < params.height - 1 && is_cell_empty(x, y + 1)) 
        return UpdateOutput(x, y + 1, true);
    return UpdateOutput(x, y, false);
}

UpdateOutput update_water_diagonal(uint x, uint y) {
    if (y < params.height - 1) {
        if (params.horizontal_rand >= 0.5 && x < params.width - 1 && is_cell_empty(x + 1, y + 1)) 
            return UpdateOutput(x + 1, y + 1, true);
        if (params.horizontal_rand <= 0.5 && x > 0 && is_cell_empty(x - 1, y + 1)) 
            return UpdateOutput(x - 1, y + 1, true);
    }
    return UpdateOutput(x, y, false);
}

UpdateOutput update_water_horizontal(uint x, uint y) {
    if (params.horizontal_rand >= 0.5 && x < params.width - 1 && is_cell_empty(x + 1, y)) 
        return UpdateOutput(x + 1, y, true);
    if (params.horizontal_rand <= 0.5 && x > 0 && is_cell_empty(x - 1, y)) 
        return UpdateOutput(x - 1, y, true);
    return UpdateOutput(x, y, false);
}

/*********** Wood ***********/

UpdateOutput update_wood_vertical(uint x, uint y) {
    return UpdateOutput(x, y, true);
}

UpdateOutput update_wood_diagonal(uint x, uint y) {
    return UpdateOutput(x, y, true);
}

UpdateOutput update_wood_horizontal(uint x, uint y) {
    return UpdateOutput(x, y, true);
}

/*********** Gas ***********/

UpdateOutput update_gas_vertical(uint x, uint y) {
    if (y > 0 && is_cell_empty(x, y - 1)) 
        return UpdateOutput(x, y - 1, true);
    return UpdateOutput(x, y, false);
}

UpdateOutput update_gas_diagonal(uint x, uint y) {
    if (y > 0 && is_cell_empty(x, y - 1)) {
        if (params.horizontal_rand >= 0.5 && x < params.width - 1 && is_cell_empty(x + 1, y - 1)) 
            return UpdateOutput(x + 1, y - 1, true);
        if (params.horizontal_rand <= 0.5 && x > 0 && is_cell_empty(x - 1, y - 1)) 
            return UpdateOutput(x - 1, y - 1, true);
    }
    return UpdateOutput(x, y, false);
}

UpdateOutput update_gas_horizontal(uint x, uint y) {
    if (params.horizontal_rand >= 0.5 && x < params.width - 1 && is_cell_empty(x + 1, y)) 
        return UpdateOutput(x + 1, y, true);
    if (params.horizontal_rand <= 0.5 && x > 0 && is_cell_empty(x - 1, y)) 
        return UpdateOutput(x - 1, y, true);
    return UpdateOutput(x, y, false);
}

/*****************
 * Main Function *
 *****************/

// void main() {
//     if (gl_GlobalInvocationID.x >= elements.data.length()) return;
//     uint x = gl_GlobalInvocationID.x % params.width;
//     uint y = gl_GlobalInvocationID.x / params.width;

//     if (params.mouse_pressed) {
//         update_brush(x, y);
//         sync_threads();
//     }
    
//     reset_debug_metrics();
//     update_vertical(elements.data[gl_GlobalInvocationID.x], x, y);
    
//     sync_threads();
//     sync_buffers(x, y);
//     clear_output_buffer(x, y);
//     sync_threads();

//     update_diagonal(elements.data[gl_GlobalInvocationID.x], x, y);
    
//     sync_threads();
//     sync_buffers(x, y);
//     clear_output_buffer(x, y);
//     sync_threads();
    
//     update_horizontal(elements.data[gl_GlobalInvocationID.x], x, y);
    
//     sync_threads();
//     sync_buffers(x, y);
//     clear_output_buffer(x, y);
//     sync_threads();

//     update_debug_metrics(elements.data[gl_GlobalInvocationID.x].id);
//     imageStore(output_texture, ivec2(x, y), get_element_base_color(elements.data[gl_GlobalInvocationID.x].id));
// }

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