/**********************
 * Macro Declarations *
 **********************/

// Position macros

#define POSITION x, y

#define UP       x, y - 1
#define DOWN     x, y + 1
#define LEFT     x - 1, y
#define RIGHT    x + 1, y

#define UP_LEFT   x - 1, y - 1
#define UP_RIGHT  x + 1, y - 1
#define DOWN_LEFT  x - 1, y + 1
#define DOWN_RIGHT x + 1, y + 1

// Movement macros

#define CAN_MOVE_UP    (y > 0 && is_cell_empty(UP))
#define CAN_MOVE_DOWN  (y < params.height - 1 && is_cell_empty(DOWN))
#define CAN_MOVE_LEFT  (params.horizontal_rand <= 0.5 && x > 0 && is_cell_empty(LEFT))
#define CAN_MOVE_RIGHT (params.horizontal_rand >= 0.5 && x < params.width - 1 && is_cell_empty(RIGHT))

#define CAN_MOVE_UP_LEFT   (params.horizontal_rand <= 0.5 && x > 0 && y > 0 && is_cell_empty(UP_LEFT))
#define CAN_MOVE_UP_RIGHT  (params.horizontal_rand >= 0.5 && x < params.width - 1 && y > 0 && is_cell_empty(UP_RIGHT))
#define CAN_MOVE_DOWN_LEFT  (params.horizontal_rand <= 0.5 && x > 0 && y < params.height - 1 && is_cell_empty(DOWN_LEFT))
#define CAN_MOVE_DOWN_RIGHT (params.horizontal_rand >= 0.5 && x < params.width - 1 && y < params.height - 1 && is_cell_empty(DOWN_RIGHT))

// Output macros

#define STAY        return UpdateOutput(x, y, false);
#define STAY_UPDATE return UpdateOutput(x, y, true);

#define MOVE_UP    return UpdateOutput(x, y - 1, true);
#define MOVE_DOWN  return UpdateOutput(x, y + 1, true);
#define MOVE_LEFT  return UpdateOutput(x - 1, y, true);
#define MOVE_RIGHT return UpdateOutput(x + 1, y, true);

#define MOVE_UP_LEFT   return UpdateOutput(x - 1, y - 1, true);
#define MOVE_UP_RIGHT  return UpdateOutput(x + 1, y - 1, true);
#define MOVE_DOWN_LEFT  return UpdateOutput(x - 1, y + 1, true);
#define MOVE_DOWN_RIGHT return UpdateOutput(x + 1, y + 1, true);