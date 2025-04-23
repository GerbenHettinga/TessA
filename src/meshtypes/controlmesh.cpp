#include "controlmesh.h"

ControlMesh::ControlMesh(Mesh* m)
{
    //extract vertex position data
    std::vector<Vertex>& meshVerts = m->getVertices();
    vertices = std::vector<glm::vec3>(meshVerts.size());
    indices.clear();

    for(size_t i = 0; i < unsigned(meshVerts.size()); ++i) {
        vertices[i] = meshVerts[i].coords;
    }

    //extract face loop vertex indices
    std::vector<Face>& meshFaces = m->getFaces();
    for(size_t i = 0; i < unsigned(meshFaces.size()); ++i) {
        HalfEdge* he = meshFaces[i].side;

        for(size_t j = 0; j < meshFaces[i].val; ++j) {
            indices.push_back(he->target->index);

            he = he->next;
        }

        indices.push_back(0xFFFFFFFF);
    }
}
