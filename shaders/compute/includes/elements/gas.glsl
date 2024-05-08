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