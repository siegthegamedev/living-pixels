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