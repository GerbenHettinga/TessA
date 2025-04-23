#ifndef CONTROLMESH_H
#define CONTROLMESH_H

#include "MeshType.h"

class ControlMesh
{
public:
    ControlMesh() {}
    ControlMesh(class Mesh* m);

    std::vector<glm::vec3>& getVertices() { return vertices; }
    std::vector<unsigned>& getIndices() { return indices; }
private:

    std::vector<glm::vec3> vertices;
    std::vector<unsigned> indices;
};

#endif // CONTROLMESH_H
