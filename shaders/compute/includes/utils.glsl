/*********************
 * Utility Functions *
 *********************/

UpdateOutput test_update_vertical(Element element, uint x, uint y);
UpdateOutput test_update_diagonal(Element element, uint x, uint y);
UpdateOutput test_update_horizontal(Element element, uint x, uint y);

 Element get_element_from_descriptor(ElementDescriptor element_descriptor) {
    Element element;
    element.id = element_descriptor.id;
    element.updated = false;
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

int compare_density(Element element, uint x, uint y) {
    Element other_element = elements.data[get_index_from_position(x, y)];
    if (element.id == other_element.id) return 0;
    if (element.density - other_element.density > 0) return 1;
    return -1;

}

bool will_move_here(uint x0, uint y0, uint x1, uint y1, int stage) {
    Element calling_element = elements.data[get_index_from_position(x0, y0)];
    Element element = elements.data[get_index_from_position(x1, y1)];
    if (calling_element.id == element.id) return false;
    if (element.updated) return x0 == x1 && y0 == y1;

    UpdateOutput update_output;
    switch (stage) {
        case 1: update_output = test_update_vertical(element, x1, y1); break;
        case 2: update_output = test_update_diagonal(element, x1, y1); break;
        case 3: update_output = test_update_horizontal(element, x1, y1); break;
        default: return false;
    }

    if (!update_output.updated) return x0 == x1 && y0 == y1;;
    return update_output.x == x0 && update_output.y == y0;
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
    output_elements.data[get_index_from_position(x, y)] = get_element_from_descriptor(element_descriptors.data[0]);
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