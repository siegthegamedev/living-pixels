
UpdateOutput update_sand_vertical(uint x, uint y) {
	if CAN_MOVE_DOWN MOVE_DOWN 
	STAY
}

UpdateOutput update_sand_diagonal(uint x, uint y) {
	if CAN_MOVE_DOWN_RIGHT MOVE_DOWN_RIGHT
	if CAN_MOVE_DOWN_LEFT MOVE_DOWN_LEFT 
	STAY
}

UpdateOutput update_sand_horizontal(uint x, uint y) {
	STAY
}

UpdateOutput update_water_vertical(uint x, uint y) {
	if CAN_MOVE_DOWN MOVE_DOWN
	STAY
}

UpdateOutput update_water_diagonal(uint x, uint y) {
	if CAN_MOVE_DOWN_RIGHT MOVE_DOWN_RIGHT
	if CAN_MOVE_DOWN_LEFT MOVE_DOWN_LEFT 
	STAY
}

UpdateOutput update_water_horizontal(uint x, uint y) {
	if CAN_MOVE_RIGHT MOVE_RIGHT
	if CAN_MOVE_LEFT MOVE_LEFT
	STAY
}

UpdateOutput update_wood_vertical(uint x, uint y) {
	STAY_UPDATE
}

UpdateOutput update_wood_diagonal(uint x, uint y) {
	STAY_UPDATE
}

UpdateOutput update_wood_horizontal(uint x, uint y) {
	STAY_UPDATE
}

UpdateOutput update_gas_vertical(uint x, uint y) {
	if CAN_MOVE_UP MOVE_UP
	STAY
}

UpdateOutput update_gas_diagonal(uint x, uint y) {
	if CAN_MOVE_UP_RIGHT MOVE_UP_RIGHT
	if CAN_MOVE_UP_LEFT MOVE_UP_LEFT 
	STAY
}

UpdateOutput update_gas_horizontal(uint x, uint y) {
	if CAN_MOVE_RIGHT MOVE_RIGHT 
	if CAN_MOVE_LEFT MOVE_LEFT 
	STAY
}
