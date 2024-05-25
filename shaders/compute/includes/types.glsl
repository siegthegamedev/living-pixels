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

struct ElementDescriptor {
    int id;
    float density;
    float flamability;
    vec4 color;
};