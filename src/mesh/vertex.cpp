#include "vertex.h"
#include "halfedge.h"
#include "face.h"

bool Vertex::isRegular() {
    return (isOnBoundary() && val < 4) || (!isOnBoundary() && val == 4);
}

bool Vertex::isRegularFaced() {
    if((isOnBoundary() && val < 4) || (!isOnBoundary() && val == 4)) {
        HalfEdge* he = out;

        for(size_t i = 0; i < val; ++i) {
            if(he->polygon && he->polygon->val != 4) {
                return false;
            }
            he = he->twin->next;
        }
        return true;
    }
    return false;
}

bool Vertex::isSurroundedByQuads() {
    HalfEdge* he = out;

    for(size_t i = 0; i < val; ++i) {
        if(he->polygon && he->polygon->val != 4) {
            return false;
        }
        he = he->twin->next;
    }
    return true;
}

bool Vertex::isIsolated() {
    HalfEdge* he = out;
    for(size_t i = 0; i < val; i++) {
        Vertex* v2 = he->next->target;
        if(!v2->isRegular()) {
            return false;
        }
        he = he->twin->next;
    }
    return true;
}

bool Vertex::isIsolated(Vertex* ignore) {
    HalfEdge* he = out;
    for(size_t i = 0; i < val; i++) {
        Vertex* v2 = he->next->target;
        if(!v2->isRegular() && v2 != ignore) {
            return false;
        }
        he = he->twin->next;
    }
    return true;
}

bool Vertex::isIsolated(int level) {
    HalfEdge* he = out;
    for(size_t i = 0; i < val; i++) {
        Vertex* v2 = he->next->target;
        if(!v2->isRegular()) {
            return false;
        }

        if(!v2->isIsolated(this)) {
            return false;
        }

        he = he->twin->next;
    }
    return true;
}

bool Vertex::isOnBoundary() {
    HalfEdge* currentEdge = out;
    for (size_t k = 0; k < val; k++) {
        if (!currentEdge->polygon) {
            return true;
        }
        currentEdge = currentEdge->prev->twin;
    }

    return false;
}

HalfEdge* Vertex::boundaryEdge() {
    unsigned short n = val;
    int k;
    HalfEdge* currentEdge = out;

    for (k=0; k<n; k++) {
        if (!currentEdge->polygon) {
            return currentEdge;
        }
        currentEdge = currentEdge->prev->twin;
    }

    return nullptr;
}

glm::vec3 Vertex::computeNormal() {
    HalfEdge* he = out;
    glm::vec3 N = glm::vec3(0.0, 0.0, 0.0);
    for(size_t i = 0; i < val; ++i) {
        glm::vec3 t1 = he->target->coords - coords;
        glm::vec3 t2 = he->prev->twin->target->coords - coords;

        N += glm::cross(glm::normalize(t1), glm::normalize(t2));

        he = he->prev->twin;
    }
    return glm::normalize(N);
}

/* limit position for regular vertices */
glm::vec3 Vertex::vertexLimitStencil() {
    if(onBoundary) {
        if(val == 2) {
            return coords;
        } else {
            HalfEdge* he = boundaryEdge();
            glm::vec3 p = 1.0f * he->target->coords;
            p += 4.0f * he->twin->target->coords;
            p += 1.0f * he->prev->twin->target->coords;
            return p / 6.0f;
        }
    }

    HalfEdge* he = out;
    glm::vec3 p = 16.0f * coords;
    p += 4.0f * he->target->coords;

    he = he->next;
    for(size_t i = 0; i < 7; i++) {
        if(i % 2 == 0) {
            p += he->target->coords;
            he = he->next;
        } else {
            p += 4.0f * he->target->coords;
            he = he->next->twin->next;
        }
    }

    return p / 36.0f;
}
