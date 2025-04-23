#include "mesh.h"

bool Mesh::dooSabin(Mesh& newMesh) {
    
    std::vector<Vertex> newVertices = newMesh.getVertices();
    std::vector<HalfEdge> newHalfEdges = newMesh.getHalfEdges();
    std::vector<Face> newFaces = newMesh.getFaces();

    size_t numVertices = vertices.size();
    size_t numHalfEdges = halfEdges.size();
    size_t numFaces = faces.size();


    size_t vertexValences = 0;
    for(Vertex& v : vertices)  {
        vertexValences += v.val;
    }

    size_t faceValences = 0;
    for(Face& f : faces)  {
        faceValences += f.val;
    }

    newVertices.reserve(faceValences);
    newHalfEdges.reserve(faceValences * 2 + vertexValences * 2);
    newFaces.reserve(numFaces + numVertices + numHalfEdges / 2);

    HalfEdge* currentEdge;

    size_t vIndex = 0;
    size_t hIndex = 0;
    size_t fIndex = 0;

    //create faces and vertices from old faces
    for(Face& f : faces) {
        size_t n = f.val;

        //create new face
        newFaces.push_back(Face(&newHalfEdges[f.side->index], n, fIndex++));

        //create vertices in corners of patches
        currentEdge = f.side;
        for(size_t i = 0; i < n; ++i) {
            newVertices.push_back(Vertex(0.5f*(f.c + currentEdge->target->p), nullptr, 4, vIndex++));

            currentEdge = currentEdge->next;
        }


        //create two new half edges for every side half edge of f
        currentEdge = f.side;
        for(size_t i = 0; i < n; ++i) {
            newHalfEdges.push_back(HalfEdge(&newVertices[vIndex - n + i],
                                        &newHalfEdges[currentEdge->next->index],
                                        &newHalfEdges[currentEdge->prev->index],
                                        &newHalfEdges[currentEdge->index * 2],
                                        &newFaces[f.side->index],
                                        currentEdge->index));

            newHalfEdges.push_back(HalfEdge(&newVertices[vIndex - n + n - i],
                                         nullptr,
                                         nullptr,
                                         &newHalfEdges[currentEdge->index],
                                         nullptr,
                                         currentEdge->index * 2));
        }
    }

    size_t numVertexHe = 0;
    //create new face for each old vertex
    for(Vertex& v : vertices) {
        size_t n = v.val;

        //create new face
        newFaces.push_back(Face(&newHalfEdges[v.out->index], n, fIndex++));

        currentEdge = v.out;
        for(size_t i = 0; i < n; ++i) {
            Vertex* v1 = newHalfEdges[currentEdge->index*2].target;

            newHalfEdges.push_back(HalfEdge(v1,
                                &newHalfEdges[numHalfEdges*2 + numVertexHe + (i - 1 + n) % n],
                                &newHalfEdges[numHalfEdges*2 + numVertexHe + (i + 1) % n],
                                nullptr, //no twin yet
                                &newFaces[numFaces + v.index],
                                numHalfEdges*2 + numVertexHe + i));

            ++numVertexHe;
        }

        //create twins of the halfedges of the vertex face
        currentEdge = v.out;
        for(size_t i = 0; i < n; ++i) {
            Vertex* v2 = newHalfEdges[currentEdge->twin->index * 2].target;

            newHalfEdges.push_back(HalfEdge(v2,
                                newHalfEdges[currentEdge->twin->index * 2].twin,
                                newHalfEdges[currentEdge->index * 2].twin,
                                &newHalfEdges[numHalfEdges*2 + numVertexHe + i],
                                nullptr, //no face yet
                                hIndex++));

            //set twin
            newHalfEdges[numHalfEdges*2 + numVertexHe + i].twin = &newHalfEdges[hIndex - 1];
        }
    }

    //create face for each halfedge face
    for(HalfEdge& he : halfEdges) {
        //only do this once per pair of edges
        if(he.index < he.twin->index) {

            newFaces.push_back(Face(&newHalfEdges[he.twin->index*2], 4, fIndex++));

            HalfEdge* currentEdge = &newHalfEdges[he.twin->index*2];
            //set all the face pointers for the halfedges
            for(size_t i = 0; i < 4; ++i) {
                currentEdge->polygon = &newFaces[fIndex - 1];

                currentEdge = currentEdge->next;
            }
        }
    }

    return true;
}
