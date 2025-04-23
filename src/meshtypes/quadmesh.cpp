#include "quadmesh.h"

QuadMesh::QuadMesh(Mesh* m) : MeshType(m)
{

}

void QuadMesh::construct() {
    Mesh* m = meshes.getCurrentLevel();

    //extract vertex position data
    std::vector<Vertex>& meshVerts = m->getVertices();
    vertices = std::vector<glm::vec3>(meshVerts.size());
    normals = std::vector<glm::vec3>(meshVerts.size());
    indices.clear();

    for(size_t i = 0; i < unsigned(meshVerts.size()); ++i) {
        vertices[i] = meshVerts[i].coords; //use limit position
        normals[i] = meshVerts[i].computeNormal(); //use limit normal
    }

    //extract face loop vertex indices
    std::vector<Face>& meshFaces = m->getFaces();
    for(size_t i = 0; i < unsigned(meshFaces.size()); ++i) {

        size_t val = meshFaces[i].val;
        //only support quad faces
        if(val == 4) {
            HalfEdge* he = meshFaces[i].side;
            for(size_t j = 0; j < val; ++j) {
                indices.push_back(he->target->index);

                he = he->next;
            }
            indices.push_back(0xFFFFFFFF);
        }

    }
}

void QuadMesh::update() {
    meshes.update();
    construct();
}
