#include "face.h"
#include "halfedge.h"
#include "vertex.h"

bool Face::isIsolated() {
    HalfEdge* he = side;
    for(size_t i = 0; i < val; ++i) {
        if(he->twin->polygon && he->twin->polygon->val != 4) {
            return false;
        }
    }
    return true;
}

bool Face::isIsolated(Face* ignore) {
    HalfEdge* he = side;
    for(size_t i = 0; i < val; ++i) {
        if(he->twin->polygon && he->twin->polygon->val != 4 && he->twin->polygon != ignore) {
            return false;
        }
    }
    return true;
}

bool Face::isIsolated(unsigned level) {
    HalfEdge* he = side;
    level = level + 1;
    for(size_t i = 0; i < val; ++i) {
        if(he->twin->polygon && he->twin->polygon->val != 4) {
            return false;
        }

        if(!he->twin->polygon->isIsolated(this)) {
            return false;
        }
    }
    return true;
}

bool Face::isRegular() {
    if(val == 4) {
        HalfEdge* he = side;
        for(size_t i = 0; i < val; i++) {
            if(!he->target->isRegular()) {
                return false;
            } else {
                HalfEdge* he2 = he->target->out;
                for(size_t j = 0; j < 4; ++j) {
                    if(he2->polygon) {
                        if(he2->polygon->val != 4) {
                            return false;
                        }
                    }
                    he2 = he2->prev->twin;
                }
            }
            he = he->next;
        }
        return true;
    }
    return false;
}

bool Face::isOnBoundary() {
    HalfEdge* he = side;
    for(size_t i = 0; i < val; i++) {

        if(!he->twin->polygon) {
            return true;
        }

        he = he->next;
    }
    return false;
}

bool Face::isSurroundedByQuads() {
    HalfEdge* he = side;
    for(size_t i = 0; i < val; ++i) {
        if(not (he->twin->polygon && he->twin->polygon->val == 4)) {
            return false;
        }
        he = he->next;
    }
    return true;
}


