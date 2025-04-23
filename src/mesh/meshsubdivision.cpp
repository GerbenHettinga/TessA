#include "mesh.h"

static HalfEdge* vertOnBoundary(Vertex* currentVertex) {

    unsigned short n = currentVertex->val;
    int k;
    HalfEdge* currentEdge = currentVertex->out;

    for (k=0; k<n; k++) {
        if (!currentEdge->polygon) {
            return currentEdge;
        }
        currentEdge = currentEdge->prev->twin;
    }

    return nullptr;
}

void createFacePoints(std::vector<Vertex>& newVertices, std::vector<Face>& faces, size_t numFaces) {
    glm::vec3 newPt, newN;
    glm::vec2 newUV;
    HalfEdge* currentEdge;

    size_t n;
    // Create Face points
    for (size_t k = 0; k < numFaces; k++) {
        currentEdge = faces[k].side;
        n = faces[k].val;
        newPt = glm::vec3(0.0, 0.0, 0.0);
        newN = glm::vec3(0.0, 0.0, 0.0);
        newUV = glm::vec2(0.0, 0.0);
        for (size_t j = 0; j < n; j++) {
            newPt += currentEdge->target->coords;
            newUV += currentEdge->target->uv;

            newN += glm::cross(glm::normalize(currentEdge->target->coords - currentEdge->twin->target->coords),
                               glm::normalize(currentEdge->prev->twin->target->coords - currentEdge->prev->target->coords));

            currentEdge = currentEdge->next;
        }
        const float fn = float(n);
        newVertices.push_back(Vertex(newPt / fn, 0, n, k, glm::normalize(newN), newUV / fn));
    }
}

void updateVertexPoints(std::vector<Vertex>& newVertices, std::vector<Vertex>& vertices, size_t numVertices, size_t indexV) {
    Vertex* currentVert;
    HalfEdge* currentEdge;
    size_t n;

    glm::vec3 newPt, newN, sumFacePts, sumEdgePts;
    glm::vec2 newUV;

    // Update Vertex points
    for(size_t k = 0; k < numVertices; k++) {
        currentVert = &vertices[k];
        currentEdge = vertices[k].out;
        n = vertices[k].val;

        if (HalfEdge* boundaryEdge = vertOnBoundary(currentVert)) {
            if (boundaryEdge->twin->target->val == 2) {
                // Interpolate corners
                newPt = boundaryEdge->twin->target->coords;
                newUV = boundaryEdge->twin->target->uv;
                newN = boundaryEdge->twin->target->normal;
            } else {
                newPt  = 1.0f * boundaryEdge->target->coords;
                newPt += 6.0f * boundaryEdge->twin->target->coords;
                newPt += 1.0f * boundaryEdge->prev->twin->target->coords;
                newPt /= 8.0f;

                newUV  = 1.0f * boundaryEdge->target->uv;
                newUV += 6.0f * boundaryEdge->twin->target->uv;
                newUV += 1.0f * boundaryEdge->prev->twin->target->uv;
                newUV /= 8.0f;
            }
        } else {
            sumFacePts = glm::vec3(0.0, 0.0, 0.0);
            sumEdgePts = glm::vec3(0.0, 0.0, 0.0);

            glm::vec2 sumFaceUVs = glm::vec2(0.0, 0.0);
            glm::vec2 sumEdgeUVs = glm::vec2(0.0, 0.0);

            glm::vec3 sumFaceNs = glm::vec3(0.0, 0.0, 0.0);
            glm::vec3 sumEdgeNs = glm::vec3(0.0, 0.0, 0.0);
            for(size_t j = 0; j < n; j++) {
                sumFacePts += newVertices[currentEdge->polygon->index].coords;
                sumEdgePts += currentEdge->target->coords;

                sumFaceUVs += newVertices[currentEdge->polygon->index].uv;
                sumEdgeUVs += currentEdge->target->uv;

                sumFaceNs += newVertices[currentEdge->polygon->index].normal;
                sumEdgeNs += currentEdge->target->normal;

                currentEdge = currentEdge->twin->next;
            }
            const float fn = float(n);
            newPt = ((fn-2.f) * currentVert->coords + sumFacePts / fn + sumEdgePts / fn) / fn;
            newUV = ((fn-2.f) * currentVert->uv + sumFaceUVs / fn + sumEdgeUVs / fn) / fn;
            newN = ((fn-2.f) * currentVert->normal + sumFaceNs / fn + sumEdgeNs / fn) / fn;
        }

        newVertices.push_back(Vertex(newPt, nullptr, n, indexV, newUV));
        indexV++;

    }
}

void createEdgePoints(std::vector<Vertex>& newVertices, std::vector<HalfEdge>& halfEdges, size_t numHalfEdges, size_t indexV) {
    HalfEdge* currentEdge;

    glm::vec3 newPt;
    glm::vec2 newUV;
    // Create Edge points
    for (size_t k = 0; k < numHalfEdges; k++) {
        currentEdge = &halfEdges[k];

        // check needed to only create edge points for each edge once
        if (currentEdge->index < currentEdge->twin->index) {
            int m;
            if(!currentEdge->polygon || !currentEdge->twin->polygon) {
                newPt  = currentEdge->target->coords;
                newPt += currentEdge->twin->target->coords;
                newPt *= 0.5;
                m = 3;

                newUV = currentEdge->target->uv;
                newUV += currentEdge->twin->target->uv;
                newUV *= 0.5;
            } else {
                newPt  = currentEdge->target->coords;
                newPt += currentEdge->twin->target->coords;
                newPt += newVertices[currentEdge->polygon->index].coords;
                newPt += newVertices[currentEdge->twin->polygon->index].coords;
                newPt *= 0.25;
                m = 4;

                newUV  = currentEdge->target->uv;
                newUV += currentEdge->twin->target->uv;
                newUV += newVertices[currentEdge->polygon->index].uv;
                newUV += newVertices[currentEdge->twin->polygon->index].uv;
                newUV *= 0.25;
            }

            newVertices.push_back(Vertex(newPt, nullptr, m, indexV, newUV)); // 0 = nullptr
            indexV++;
        }
    }
}

void splitHalfEdges(std::vector<HalfEdge>& newHalfEdges, std::vector<HalfEdge>& halfEdges, std::vector<Vertex>& newVertices, size_t numHalfEdges, size_t vIndex, size_t numFaces) {
    HalfEdge* currentEdge;

    for(size_t k = 0; k < numHalfEdges; k++) {
        newHalfEdges.push_back(HalfEdge(nullptr, nullptr, nullptr, nullptr, nullptr, 2*k));
        newHalfEdges.push_back(HalfEdge(nullptr, nullptr, nullptr, nullptr, nullptr, 2*k+1));
    }

    for (size_t k = 0; k < numHalfEdges; k++) {
        // Split existing HalfEdges
        // Target, Next, Prev, Twin, Poly, Index
        currentEdge = &halfEdges[k];
        size_t m = currentEdge->twin->index;

        // check needed to only create edge points for each edge once
        if (k < currentEdge->twin->index) {
            newHalfEdges[2*k].target = &newVertices[vIndex];
            newHalfEdges[2*k+1].target = &newVertices[numFaces + currentEdge->target->index ];


            vIndex++;
        } else {
            newHalfEdges[2*k].target = newHalfEdges[2*m].target;
            newHalfEdges[2*k+1].target = &newVertices[numFaces + currentEdge->target->index ];

            // Assign Twins
            newHalfEdges[2*k].twin = &newHalfEdges[2*m+1];
            newHalfEdges[2*k+1].twin = &newHalfEdges[2*m];
            newHalfEdges[2*m].twin = &newHalfEdges[2*k+1];
            newHalfEdges[2*m+1].twin = &newHalfEdges[2*k];

            if (!currentEdge->polygon) {
                newHalfEdges[2*k].next = &newHalfEdges[2*k+1];
                newHalfEdges[2*k+1].prev = &newHalfEdges[2*k];

                if (currentEdge > currentEdge->next) {
                   m = currentEdge->next->index;
                   newHalfEdges[2*k+1].next = &newHalfEdges[2*m];
                   newHalfEdges[2*m].prev = &newHalfEdges[2*k+1];
                }

                if (currentEdge > currentEdge->prev) {
                   m = currentEdge->prev->index;
                   newHalfEdges[2*k].prev = &newHalfEdges[2*m+1];
                   newHalfEdges[2*m+1].next = &newHalfEdges[2*k];
                }
            }

        }
    }
}

void createNewFaces(std::vector<HalfEdge>& newHalfEdges, std::vector<Face>& newFaces, std::vector<Vertex>& newVertices, std::vector<Face>& faces, size_t numHalfEdges) {
    size_t indexH = 2*numHalfEdges;
    size_t indexF = 0;
    size_t n, s, t;
    HalfEdge* currentEdge;


    // Create new HalfEdges and Faces
    for(size_t k = 0; k < faces.size(); k++) {
        currentEdge = faces[k].side;
        n = faces[k].val;

        for (size_t j = 0; j < n; j++) {

            s = currentEdge->prev->index;
            t = currentEdge->index;

            // Side, Val, Index
            newFaces.push_back(Face(nullptr, 4, indexF));
            newFaces[indexF].side = &newHalfEdges[ 2*t ];

            // Target, Next, Prev, Twin, Poly, Index
            newHalfEdges.push_back(HalfEdge( &newVertices[k], nullptr, &newHalfEdges[ 2*t ], nullptr, &newFaces[indexF], indexH ));
            newHalfEdges.push_back(HalfEdge( nullptr, &newHalfEdges[2*s+1], &newHalfEdges[indexH], nullptr, &newFaces[indexF], indexH+1 ));


            newHalfEdges[indexH].next = &newHalfEdges[indexH+1];
            newHalfEdges[indexH+1].target = newHalfEdges[indexH+1].next->twin->target;

            newHalfEdges[2*s+1].next = &newHalfEdges[2*t];
            newHalfEdges[2*s+1].prev = &newHalfEdges[indexH+1];
            newHalfEdges[2*s+1].polygon = &newFaces[indexF];

            newHalfEdges[2*t].polygon = &newFaces[indexF];
            newHalfEdges[2*t].next = &newHalfEdges[indexH];
            newHalfEdges[2*t].prev = &newHalfEdges[2*s+1];

            if (j > 0) {
                // Twins
                newHalfEdges[indexH+1].twin = &newHalfEdges[indexH-2];
                newHalfEdges[indexH-2].twin = &newHalfEdges[indexH+1];
            }

            newHalfEdges[2*t].target->out = &newHalfEdges[indexH];


            indexF++;
            indexH += 2;
            currentEdge = currentEdge->next;
        }

        newHalfEdges[indexH-2*n+1].twin = &newHalfEdges[indexH-2];
        newHalfEdges[indexH-2].twin = &newHalfEdges[indexH-2*n+1];

        newVertices[k].out = &newHalfEdges[indexH-1];
    }

}


bool Mesh::catmullClark(Mesh& newMesh) {
    size_t indexV;

    std::vector<Vertex>& newVertices = newMesh.getVertices();
    std::vector<HalfEdge>& newHalfEdges = newMesh.getHalfEdges();
    std::vector<Face>& newFaces = newMesh.getFaces();

    size_t numVertices = vertices.size();
    size_t numHalfEdges = halfEdges.size();
    size_t numFaces = faces.size();

    // Reserve memory
    newVertices.reserve(numVertices + numHalfEdges/2 + numFaces);
    newHalfEdges.reserve(4*numHalfEdges);
    newFaces.reserve(numHalfEdges);

    createFacePoints(newVertices, faces, numFaces);

    indexV = numFaces;

    updateVertexPoints(newVertices, vertices, numVertices, indexV);

    indexV += numVertices;

    createEdgePoints(newVertices, halfEdges, numHalfEdges, indexV);

    //split half edges so count from new vertices on edges
    int vIndex = numFaces + numVertices;


    splitHalfEdges(newHalfEdges, halfEdges, newVertices, numHalfEdges, vIndex, numFaces);

    createNewFaces(newHalfEdges, newFaces, newVertices, faces, numHalfEdges);

    //set outs
    for(size_t k = 0; k < numVertices; k++) {
       newVertices[numFaces + k].out = &newHalfEdges[ 2*vertices[k].out->index ];
    }

    newMesh.meshMetrics();

    newMesh.setLimitPositionsAndTangents();

    return true;
}
