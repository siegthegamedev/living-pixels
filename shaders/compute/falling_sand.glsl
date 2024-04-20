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

layout(set = 0, binding = 0, std430) restrict readonly buffer ParamsBuffer {
    int width;
    int height;
    float vertical_rand;
    float horizontal_rand;
} params;

layout(set = 0, binding = 1, std430) restrict buffer ElementsBuffer {
    Element data[];
} elements;

layout(set = 0, binding = 2, std430) restrict buffer OutputElementsBuffer {
    Element data[];
} output_elements;

/*************************
 * Function Declarations *
 *************************/

// Utility Functions
uint get_index_from_position(uint x, uint y);
bool is_cell_empty(uint x, uint y);
void set_output_cell(Element element, uint x, uint y);
void parse_update_output(Element element, UpdateOutput update_output);
void sync_buffers(uint x, uint y);
void sync_threads(uint x, uint y);

// Update Functions
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

void set_output_cell(Element element, uint x, uint y) {
    output_elements.data[get_index_from_position(x, y)] = element;
}

void parse_update_output(Element element, UpdateOutput update_output) {
    element.updated = update_output.updated;
    set_output_cell(element, update_output.x, update_output.y);
}

void sync_buffers(uint x, uint y) {
    uint index = get_index_from_position(x, y);
    elements.data[index] = output_elements.data[index];
    output_elements.data[index].id = 0;
}

void sync_threads(uint x, uint y) {
    memoryBarrierShared();
    barrier();

    sync_buffers(x, y);

    memoryBarrierShared();
    barrier();
}

/********************
 * Update Functions *
 ********************/

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
    return UpdateOutput(x, y, false);
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

void main() {
    if (gl_GlobalInvocationID.x >= elements.data.length()) return;
    uint x = gl_GlobalInvocationID.x % params.width;
    uint y = gl_GlobalInvocationID.x / params.width;

    update_vertical(elements.data[gl_GlobalInvocationID.x], x, y);
    sync_threads(x, y);
    update_diagonal(elements.data[gl_GlobalInvocationID.x], x, y);
    sync_threads(x, y);
    update_horizontal(elements.data[gl_GlobalInvocationID.x], x, y);
}