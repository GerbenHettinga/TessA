#include "mesh.h"

bool Mesh::oddDegree(unsigned degree, Mesh& newMesh) {
    linSubdivide(newMesh);
    for(size_t i = 0; i <= (degree - 1)/2; ++i) {
        newMesh.oddSmooth();
    }
    newMesh.meshMetrics();
    return true;
}

bool Mesh::evenDegree(unsigned degree, Mesh& newMesh) {
    linSubdivide(newMesh);
    newMesh.dual();
    for(size_t i = 0; i < (degree - 2)/2; ++i) {
        newMesh.evenSmooth();
    }

    newMesh.meshMetrics();
    return true;
}

static HalfEdge* vertOnBoundary(Vertex* currentVertex) {

    unsigned short n = currentVertex->val;
    int k;
    HalfEdge* currentEdge = currentVertex->out;

    for (k = 0; k < n; k++) {
        if (!currentEdge->polygon) {
            return currentEdge;
        }
        currentEdge = currentEdge->prev->twin;
    }

    return nullptr;
}


void Mesh::oddSmooth() {
    std::vector<glm::vec3> newPos = std::vector<glm::vec3>(vertices.size());
    std::vector<glm::vec2> newUVs = std::vector<glm::vec2>(vertices.size());


    glm::vec3 newPt, sumFacePts, sumEdgePts;
    glm::vec2 newUV;

    // Update Vertex points
    for(size_t k = 0; k < unsigned(vertices.size()); k++) {
        Vertex* currentVert = &vertices[k];
        HalfEdge* currentEdge = vertices[k].out;
        size_t n = vertices[k].val;

        if (HalfEdge* boundaryEdge = vertOnBoundary(currentVert)) {
            if (boundaryEdge->twin->target->val == 2) {
                // Interpolate corners
                newPt = boundaryEdge->twin->target->coords;
                newUV = boundaryEdge->twin->target->uv;
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

            for(size_t j = 0; j < n; j++) {
                //compute face averages
                glm::vec3 p = glm::vec3(0.0, 0.0, 0.0);
                glm::vec2 uv = glm::vec2(0.0, 0.0);

                HalfEdge* faceEdge = currentEdge->polygon->side;
                for(size_t i = 0; i < currentEdge->polygon->val; ++i) {
                    p += faceEdge->target->coords;
                    uv += faceEdge->target->uv;

                    faceEdge = faceEdge->next;
                }
                p /= currentEdge->polygon->val;
                uv /= currentEdge->polygon->val;

                sumFacePts += p;
                sumEdgePts += currentEdge->target->coords;

                sumFaceUVs += uv;
                sumEdgeUVs += currentEdge->target->uv;

                currentEdge = currentEdge->twin->next;
            }
            const float fn = float(n);
            newPt = ((fn - 2.f) * currentVert->coords + sumFacePts / fn + sumEdgePts / fn) / fn;
            newUV = ((fn - 2.f) * currentVert->uv + sumFaceUVs / fn + sumEdgeUVs / fn) / fn;
        }

        newPos[k] = newPt;
        newUVs[k] = newUV;
    }


    //copy new positions back
    for(size_t i = 0; i < unsigned(vertices.size()); ++i) {
        vertices[i].coords = newPos[i];
        vertices[i].uv = newUVs[i];
    }
}

void Mesh::evenSmooth() {
    std::vector<glm::vec3> newPos = std::vector<glm::vec3>(vertices.size());
    std::vector<glm::vec2> newUVs = std::vector<glm::vec2>(vertices.size());

    size_t i = 0;
    for(Vertex& v : vertices) {
        glm::vec3 p = glm::vec3(0.0);
        glm::vec2 uv = glm::vec2(0.0);;
        HalfEdge* he  = v.out;

        if (HalfEdge* boundaryEdge = vertOnBoundary(&v)) {
            if (boundaryEdge->twin->target->val == 2) {
                // Interpolate corners
                p = boundaryEdge->twin->target->coords;
                uv = boundaryEdge->twin->target->uv;
            } else {
                p  = 1.0f * boundaryEdge->target->coords;
                p += 6.0f * boundaryEdge->twin->target->coords;
                p += 1.0f * boundaryEdge->prev->twin->target->coords;
                p /= 8.0f;

                uv  = 1.0f * boundaryEdge->target->uv;
                uv += 6.0f * boundaryEdge->twin->target->uv;
                uv += 1.0f * boundaryEdge->prev->twin->target->uv;
                uv /= 8.0f;
            }

            newPos[i] = p;
            newUVs[i] = uv;
        } else {

            for(size_t j = 0; j < v.val; ++j) {
                p += he->target->coords;
                uv += he->target->uv;

                he = he->twin->next;
            }

            newPos[i] = p / float(v.val);
            newUVs[i] = uv / float(v.val);
        }

        ++i;
    }

    //copy new positions back
    for(size_t i = 0; i < unsigned(vertices.size()); ++i) {
        vertices[i].coords = newPos[i];
        vertices[i].uv = newUVs[i];
    }
}


void createFacePoints(std::vector<Vertex>& newVertices, std::vector<Face>& faces) {
    glm::vec3 newPt;
    glm::vec2 newUV;
    HalfEdge* currentEdge;

    
    // Create Face points
    for (size_t k = 0; k < unsigned(faces.size()); k++) {
        currentEdge = faces[k].side;
        float fn = faces[k].val;
        newPt = glm::vec3(0.0, 0.0, 0.0);
        newUV = glm::vec2(0.0, 0.0);
        for (size_t j = 0; j < faces[k].val; j++) {
            newPt += currentEdge->target->coords;
            newUV += currentEdge->target->uv;

            currentEdge = currentEdge->next;
        }
        newVertices.push_back(Vertex(newPt/ float(faces[k].val), nullptr, faces[k].val, k, newUV/ float(faces[k].val)));
    }
    //qDebug() << "Added Face Points.";
}

void createEdgePointsLinear(std::vector<Vertex>& newVertices, std::vector<HalfEdge>& halfEdges, size_t numHalfEdges, size_t indexV) {
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
                newPt *= 0.5f;
                m = 3;

                newUV = currentEdge->target->uv;
                newUV += currentEdge->twin->target->uv;
                newUV *= 0.5f;
            } else {
                newPt  = currentEdge->target->coords;
                newPt += currentEdge->twin->target->coords;
                newPt *= 0.5f;
                m = 4;

                newUV  = currentEdge->target->uv;
                newUV += currentEdge->twin->target->uv;
                newUV *= 0.5f;
            }

            newVertices.push_back(Vertex(newPt, nullptr, m, indexV, newUV));
            indexV++;
        }
    }

    //qDebug() << "Created edge Points.";
}

void splitHalfEdgesLin(std::vector<HalfEdge>& newHalfEdges, std::vector<HalfEdge>& halfEdges, std::vector<Vertex>& newVertices, size_t numHalfEdges, size_t vIndex, size_t numFaces) {
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

    //qDebug() << "Split halfedges Points";
}

void createNewFacesLin(std::vector<HalfEdge>& newHalfEdges, std::vector<Face>& newFaces, std::vector<Vertex>& newVertices, std::vector<Face>& faces, size_t numHalfEdges) {
    size_t indexH = 2*numHalfEdges;
    size_t indexF = 0;
    size_t n, s, t;
    HalfEdge* currentEdge;


    // Create new HalfEdges and Faces
    for(size_t k = 0; k < unsigned(faces.size()); k++) {
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
    //qDebug() << "Created HalfEdges and Faces.";
}

bool Mesh::linSubdivide(Mesh& newMesh) {
    std::vector<Vertex>& newVertices = newMesh.vertices;
    std::vector<HalfEdge>& newHalfEdges = newMesh.halfEdges;
    std::vector<Face>& newFaces = newMesh.faces;

    linSubdivide(newVertices, newHalfEdges, newFaces);

    newMesh.meshMetrics();

    return true;
}

bool Mesh::linSubdivide() {
    std::vector<Vertex> newVertices;
    std::vector<HalfEdge> newHalfEdges;
    std::vector<Face> newFaces;

    linSubdivide(newVertices, newHalfEdges, newFaces);

    vertices = std::move(newVertices);
    halfEdges = std::move(newHalfEdges);
    faces = std::move(newFaces);

    meshMetrics();

    return true;
}

bool Mesh::linSubdivide(std::vector<Vertex>& newVertices, std::vector<HalfEdge>& newHalfEdges, std::vector<Face>& newFaces) {
    size_t indexV;

    size_t numVertices = vertices.size();
    size_t numHalfEdges = halfEdges.size();
    size_t numFaces = faces.size();

    // Reserve memory
    newVertices.reserve(numVertices + numHalfEdges/2 + numFaces);
    newHalfEdges.reserve(4*numHalfEdges);
    newFaces.reserve(numHalfEdges);

    createFacePoints(newVertices, faces);

    indexV = numFaces;

    //copy vertex positions
    for(size_t i = 0; i < numVertices; ++i) {
        newVertices.push_back(Vertex(vertices[i].coords, nullptr, vertices[i].val, numFaces + i, vertices[i].uv));
    }

    indexV += numVertices;

    createEdgePointsLinear(newVertices, halfEdges, numHalfEdges, indexV);

    //split half edges so count from new vertices on edges
    int vIndex = numFaces + numVertices;


    splitHalfEdgesLin(newHalfEdges, halfEdges, newVertices, numHalfEdges, vIndex, numFaces);

    createNewFacesLin(newHalfEdges, newFaces, newVertices, faces, numHalfEdges);

    //set outs
    for(size_t k = 0; k < numVertices; k++) {
       newVertices[numFaces + k].out = &newHalfEdges[ 2*vertices[k].out->index ];
    }

    return true;
}
