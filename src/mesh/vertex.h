#ifndef VERTEX
#define VERTEX

#include <glm/glm.hpp>

class HalfEdge;

class Vertex {
public:
    glm::vec3 coords;
    glm::vec3 normal;
    HalfEdge* out;
    unsigned val;
    unsigned index;
    double c;
    glm::vec3 p; //limit position
    glm::vec3 n; //limit normal
    glm::vec2 uv;
    glm::vec3 noise;
    bool onBoundary;

    bool isRegular();
    bool isRegularFaced();
    bool isSurroundedByQuads();
    bool isIsolated();
    bool isIsolated(Vertex* ignore);
    bool isIsolated(int level);
    bool isOnBoundary();
    HalfEdge* boundaryEdge();
    unsigned isolationLevel();

    glm::vec3 computeNormal();
    glm::vec3 vertexLimitStencil();

    // Inline constructors
    Vertex() {
        coords = glm::vec3();
        out = nullptr; //nullptr
        val = 0;
        index = 0;
        normal = glm::vec3(0.0, 0.0, 0.0);
        noise = glm::vec3(0.5, 1.0, 0.0);
        uv = glm::vec2(0.0, 0.0);
        onBoundary = false;
    }

    Vertex(glm::vec3 vcoords, HalfEdge* vout, unsigned short vval, unsigned vindex) {
        ////qDebug() << "glm::vec3 Vertex Constructor";
        coords = vcoords;
        out = vout;
        val = vval;
        index = vindex;
        normal = glm::vec3(0.0f, 0.0f, 0.0f);
        noise = glm::vec3(0.5, 1.0, 0.0);
        uv = glm::vec2(0.0, 0.0);
        onBoundary = false;
    }

    Vertex(glm::vec3 vcoords, HalfEdge* vout, unsigned short vval, unsigned vindex, glm::vec3 n, glm::vec2 u) {
        ////qDebug() << "glm::vec3 Vertex Constructor";
        coords = vcoords;
        out = vout;
        val = vval;
        index = vindex;
        normal = n;
        uv = u;
        noise = glm::vec3(0.5, 1.0, 0.0);
        onBoundary = false;
    }

    Vertex(glm::vec3 vcoords, HalfEdge* vout, unsigned short vval, unsigned vindex, glm::vec2 u) {
        ////qDebug() << "glm::vec3 Vertex Constructor";
        coords = vcoords;
        out = vout;
        val = vval;
        index = vindex;
        normal = glm::vec3(0.5, 0.0, 0.0);
        uv = u;
        noise = glm::vec3(0.5, 1.0, 0.0);
        onBoundary = false;
    }


//    Vertex(const Vertex& ve) {
//        ////qDebug() << "glm::vec3 Vertex Constructor";
//        coords = ve.coords;
//        out = ve.out;
//        val = ve.val;
//        index = ve.index;
//        normal = ve.normal;
//        onBoundary
//    }


};

#endif // VERTEX
