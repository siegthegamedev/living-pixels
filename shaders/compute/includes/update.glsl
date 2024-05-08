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