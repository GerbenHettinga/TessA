#ifndef QUADMESH_H
#define QUADMESH_H


#include "../mesh/mesh.h"
#include "MeshType.h"


class QuadMesh : public MeshType
{
public:
    QuadMesh() {}
    QuadMesh(Mesh* m);

    std::vector<glm::vec3>& getVertices() { return vertices; }
    std::vector<unsigned>& getIndices() { return indices; }
    std::vector<glm::vec3>& getNormals() { return normals; }

    void update();
private:

    void construct();

    std::vector<glm::vec3> vertices;
    std::vector<glm::vec3> normals;
    std::vector<unsigned> indices;
};

#endif // QUADMESH_H
