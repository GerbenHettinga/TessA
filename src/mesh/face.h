#ifndef FACE
#define FACE

#include <glm/glm.hpp>

// Forward declaration
class HalfEdge;

class Face {
public:
    HalfEdge* side;
    unsigned short val;
    unsigned index;
    glm::vec3 c;

    // Inline constructors
    Face() {
        side = nullptr; //nullptr
        val = 0;
        index = 0;
    }

    Face(HalfEdge* fside, unsigned short fval, unsigned findex) {
        side = fside;
        val = fval;
        index = findex;
    }

    static bool compare(const Face * a, const Face * b) {
        return (a->val < b->val);
    }

    bool isIsolated();
    bool isIsolated(Face* ignore);
    bool isIsolated(unsigned level);
    bool isRegular();
    bool isOnBoundary();
    bool isSurroundedByQuads();

};

#endif // FACE
