/*********************
 * Utility Functions *
 *********************/

 Element get_element_from_descriptor(ElementDescriptor element_descriptor) {
    Element element;
    element.id = element_descriptor.id;
    element.bool = false;
    element.density = element_descriptor.density;
    element.flamability = element_descriptor.flamability;
    return element;
 }

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
    return element_descriptors.data[element_id].color;
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