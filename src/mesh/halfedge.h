#ifndef HALFEDGE
#define HALFEDGE

#include <glm/glm.hpp>
#include <vector>

// Forward declarations
class Vertex;
class Face;

class HalfEdge {
public:
    Vertex* target;
    HalfEdge* next;
    HalfEdge* prev;
    HalfEdge* twin;
    Face* polygon;
    unsigned index;

    bool seam;

    glm::vec3 e;
    glm::vec3 r;
    glm::vec3 fm, fp;

    glm::vec3 normal;
    glm::vec2 uv;

    std::vector<glm::vec3> ribbon;

    // Inline constructors
    HalfEdge() {
        target = nullptr; //nullptr
        next = nullptr;
        prev = nullptr;
        twin = nullptr;
        polygon = nullptr;
        index = 0;
    }

    HalfEdge(Vertex* htarget, HalfEdge* hnext, HalfEdge* hprev, HalfEdge* htwin, Face* hpolygon, int hindex) {
        target = htarget;
        next = hnext;
        prev = hprev;
        twin = htwin;
        polygon = hpolygon;
        index = hindex;
    }

    HalfEdge(const HalfEdge &he) {
        target = he.target;
        next = he.next;
        prev = he.prev;
        twin = he.twin;
        polygon = he.polygon;
        index = he.index;
    }

    void setNext(HalfEdge* n) {
        next = n;
        n->prev = this;
    }

    void setPrev(HalfEdge* p) {
        prev = p;
        p->next = this;
    }

    void setTwin(HalfEdge* t) {

        twin = t;
        t->twin = this;
    }
};

#endif // HALFEDGE
