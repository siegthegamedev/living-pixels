/********************
 * Update Functions *
 ********************/

void update_brush(uint x, uint y) {
    if (!(abs(x - params.brush_position.x) <= params.brush_size && abs(y - params.brush_position.y) <= params.brush_size)) return;
    elements.data[get_index_from_position(x, y)] = get_element_from_descriptor(element_descriptors.data[params.selected_element_id]);
}