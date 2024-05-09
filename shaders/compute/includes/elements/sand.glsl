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