#include "mesh.h"

void calculateNumberOfAttributes(size_t& numVertices, size_t& numFaces, size_t& numHalfEdges, bool isDual,
                                 std::vector<Vertex>& vertices, std::vector<Face>& faces, std::vector<HalfEdge>& halfEdges) {
    size_t numNonCornerBoundaryEdges = 0;
    size_t numBoundaryEdges = 0;
    size_t numCornerVertices = 0;
    size_t numNonBoundaryVertices = 0;
    size_t regularBoundaryEdges = 0;
    for(Vertex& v : vertices) {
        if(v.val == 2 && v.onBoundary) {
            ++numCornerVertices;
        }
        if(v.onBoundary) {
            ++numNonBoundaryVertices;
        }
    }

    for(HalfEdge& he : halfEdges) {
        if(not he.polygon) {
            if(he.target->val != 2) {
                ++numNonCornerBoundaryEdges;
            }
            if(he.target->val != 2 && he.twin->target->val != 2) {
                ++regularBoundaryEdges;
            }
            ++numBoundaryEdges;
        }
    }

    if(not isDual) {
        numVertices = faces.size() + numBoundaryEdges + numCornerVertices;
        numFaces = vertices.size();
        numHalfEdges = halfEdges.size() + numNonCornerBoundaryEdges*2 + numCornerVertices*4;
    } else {
        numVertices = faces.size();
        numFaces = vertices.size() - numNonBoundaryVertices;
        numHalfEdges = halfEdges.size() - numCornerVertices*4 - regularBoundaryEdges * 2;
    }
    //qDebug() << "halfedges: " << halfEdges.size() << " numCornerVertices: " << numCornerVertices << " numNonCornerBoundaryEdges: " << regularBoundaryEdges;
}

// Create Face points
void createFacePointsDual(std::vector<Face>& faces, std::vector<Vertex>& newVertices, std::vector<HalfEdge>& newHalfEdges,
                          bool isDual) {


    for (size_t k = 0; k < unsigned(faces.size()); k++) {
        HalfEdge* currentEdge = faces[k].side;
        size_t n = faces[k].val;
        glm::vec3 newPt = glm::vec3(0.0, 0.0, 0.0);
        glm::vec2 newUV = glm::vec2(0.0, 0.0);
        size_t numBoundaryEdges = 0;
        for (size_t j = 0; j < n; j++) {
            newPt += currentEdge->target->coords;
            newUV += currentEdge->target->uv;

            if(not currentEdge->twin->polygon) {
                ++numBoundaryEdges;
            }
            currentEdge = currentEdge->next;
        }

        const float fn = float(n);
        if(isDual) {
           //the boundary vertices will translate to boundary vertices
           newVertices[k] = Vertex(newPt / fn, &newHalfEdges[faces[k].side->twin->index], n - numBoundaryEdges, k, newUV / fn);
           if(numBoundaryEdges > 0) {
               newVertices[k].onBoundary = true;
           }
        } else {
           newVertices[k] = Vertex(newPt / fn, &newHalfEdges[faces[k].side->index], n, k, newUV / fn);
        }

        newVertices[k].onBoundary = false;
    }
}

void createNewHalfEdges(std::vector<HalfEdge>& halfEdges, std::vector<Vertex>& newVertices, std::vector<Face>& newFaces, std::vector<HalfEdge>& newHalfEdges,
                        bool isDual, size_t& curHe, size_t& curV, std::vector<HalfEdge*>& boundary) {
    //create two new halfEdges for each original pair of half edges
    for(HalfEdge& he : halfEdges) {
        if(he.index < he.twin->index) {

            if(he.polygon && he.twin->polygon) {
                if(isDual && he.target->onBoundary) {
                    //A
                    newHalfEdges[he.index].target = &newVertices[he.polygon->index];
                    newHalfEdges[he.index].setNext(&newHalfEdges[he.prev->twin->index]);
                    newHalfEdges[he.index].setPrev(&newHalfEdges[he.twin->next->index]);
                    newHalfEdges[he.index].setTwin(&newHalfEdges[he.twin->index]);
                    newHalfEdges[he.index].polygon = &newFaces[he.twin->target->index];
                    newHalfEdges[he.index].index = he.index;

                    newVertices[he.polygon->index].out = &newHalfEdges[he.twin->index];

                    //edge case for boundary edge
                    //e
                    newHalfEdges[he.twin->index].target = &newVertices[he.twin->polygon->index];
                    if(he.twin->prev->twin->target->val == 2) {
                        newHalfEdges[he.twin->index].setNext(&newHalfEdges[he.twin->next->twin->index]);
                    } else {
                        newHalfEdges[he.twin->index].setNext(&newHalfEdges[he.twin->prev->prev->twin->index]);
                    }
                    if(he.next->target->val == 2) {
                        newHalfEdges[he.twin->index].setPrev(&newHalfEdges[he.prev->index]);
                    } else {
                        newHalfEdges[he.twin->index].setPrev(&newHalfEdges[he.next->next->index]);
                    }
                    newHalfEdges[he.twin->index].setTwin(&newHalfEdges[he.index]);
                    newHalfEdges[he.twin->index].polygon = nullptr;
                    newHalfEdges[he.twin->index].index = he.twin->index;

                    newVertices[he.twin->polygon->index].out = &newHalfEdges[he.index];
                } else {
                    if(isDual) {
                        newHalfEdges[he.index].target = &newVertices[he.polygon->index];
                        newHalfEdges[he.index].setNext(&newHalfEdges[he.prev->twin->index]);
                        newHalfEdges[he.index].setPrev(&newHalfEdges[he.twin->next->index]);
                        newHalfEdges[he.index].setTwin(&newHalfEdges[he.twin->index]);
                        newHalfEdges[he.index].polygon = &newFaces[he.twin->target->index];
                        newHalfEdges[he.index].index = he.index;


                        newHalfEdges[he.twin->index].target = &newVertices[he.twin->polygon->index];
                        newHalfEdges[he.twin->index].setNext(&newHalfEdges[he.twin->prev->twin->index]);
                        newHalfEdges[he.twin->index].setPrev(&newHalfEdges[he.next->index]);
                        newHalfEdges[he.twin->index].setTwin(&newHalfEdges[he.index]);
                        newHalfEdges[he.twin->index].polygon = &newFaces[he.target->index];
                        newHalfEdges[he.twin->index].index = he.twin->index;
                    } else {

                        newHalfEdges[he.index].target = &newVertices[he.twin->polygon->index];
                        newHalfEdges[he.index].setNext(&newHalfEdges[he.twin->prev->index]);
                        newHalfEdges[he.index].setPrev(&newHalfEdges[he.next->twin->index]);
                        newHalfEdges[he.index].setTwin(&newHalfEdges[he.twin->index]);
                        newHalfEdges[he.index].polygon = &newFaces[he.target->index];
                        newHalfEdges[he.index].index = he.index;


                        newHalfEdges[he.twin->index].target = &newVertices[he.polygon->index];
                        newHalfEdges[he.twin->index].setNext(&newHalfEdges[he.prev->index]);
                        newHalfEdges[he.twin->index].setPrev(&newHalfEdges[he.twin->next->twin->index]);
                        newHalfEdges[he.twin->index].setTwin(&newHalfEdges[he.index]);
                        newHalfEdges[he.twin->index].polygon = &newFaces[he.twin->target->index];
                        newHalfEdges[he.twin->index].index = he.twin->index;
                    }

                }
            } else if(!isDual) {
                //only do this when is not dual

                //edge pair is on boundary so split edge
                glm::vec3 p = 0.5f * (he.target->coords + he.twin->target->coords);
                glm::vec2 u = 0.5f * (he.target->uv + he.twin->target->uv);

                //create new vertex for split boundary edge
                newVertices[curV] = Vertex(p, &newHalfEdges[he.twin->index], 3, curV, u);
                newVertices[curV].onBoundary = true;


                //C
                newHalfEdges[he.index].target = &newVertices[curV];
                newHalfEdges[he.index].next = nullptr;
                if(he.target->val == 2) {
                    newHalfEdges[he.index].setPrev(&newHalfEdges[he.twin->prev->index]);
                } else {
                    newHalfEdges[he.index].setPrev(&newHalfEdges[he.next->twin->index]);
                }

                newHalfEdges[he.index].setTwin(&newHalfEdges[he.twin->index]);
                newHalfEdges[he.index].polygon = &newFaces[he.target->index];
                newHalfEdges[he.index].index = he.index;

                //qDebug() << he.index;

                //D
                newHalfEdges[he.twin->index].target = &newVertices[he.polygon->index];
                newHalfEdges[he.twin->index].setNext(&newHalfEdges[he.prev->index]);
                newHalfEdges[he.twin->index].prev = nullptr;
                newHalfEdges[he.twin->index].setTwin(&newHalfEdges[he.index]);
                newHalfEdges[he.twin->index].polygon = &newFaces[he.twin->target->index];
                newHalfEdges[he.twin->index].index = he.twin->index;



                ++curV;
            }
        }
    }


    for(HalfEdge& he : halfEdges) {
        if(!he.twin->polygon && !isDual) {

            if(he.twin->target->val >= 3) {
                //create two new edges on the boundary
                newHalfEdges[curHe].target = newHalfEdges[he.index].target;
                newHalfEdges[curHe].setNext(&newHalfEdges[he.twin->index]);
                newHalfEdges[curHe].setPrev(&newHalfEdges[he.twin->next->twin->index]);
                newHalfEdges[curHe].setTwin(&newHalfEdges[curHe + 1]);
                newHalfEdges[curHe].polygon = &newFaces[he.twin->target->index];
                newHalfEdges[curHe].index = curHe;

                newHalfEdges[he.twin->index].prev = &newHalfEdges[curHe];
                newHalfEdges[he.twin->next->twin->index].next = &newHalfEdges[curHe];

                //boundary edge
                newHalfEdges[curHe + 1].target = newHalfEdges[he.twin->next->twin->index].target;
                newHalfEdges[curHe + 1].next = nullptr;
                newHalfEdges[curHe + 1].prev = nullptr;
                newHalfEdges[curHe + 1].setTwin(&newHalfEdges[curHe]);
                newHalfEdges[curHe + 1].polygon = nullptr;
                newHalfEdges[curHe + 1].index = curHe + 1;

                boundary.push_back(&newHalfEdges[curHe + 1]);

                curHe += 2;
            } else {
                //create two new edges on the boundary
                newHalfEdges[curHe].target = newHalfEdges[he.index].target;
                newHalfEdges[curHe].setNext(&newHalfEdges[he.twin->index]);
                newHalfEdges[curHe].prev = nullptr;
                newHalfEdges[curHe].setTwin(&newHalfEdges[curHe + 1]);
                newHalfEdges[curHe].polygon = &newFaces[he.twin->target->index];
                newHalfEdges[curHe].index = curHe;

                newHalfEdges[he.twin->index].prev = &newHalfEdges[curHe];

                //boundary edge
                newHalfEdges[curHe + 1].target = newHalfEdges[he.twin->next->twin->index].target;
                newHalfEdges[curHe + 1].next = nullptr;
                newHalfEdges[curHe + 1].prev = nullptr;
                newHalfEdges[curHe + 1].setTwin(&newHalfEdges[curHe]);
                newHalfEdges[curHe + 1].polygon = nullptr;
                newHalfEdges[curHe + 1].index = curHe + 1;

                boundary.push_back(&newHalfEdges[curHe + 1]);

                curHe += 2;
            }
        }
    }
}

//create new faces for each vertex
void createNewFaces(std::vector<Vertex>& vertices, std::vector<Vertex>& newVertices, std::vector<Face>& newFaces, std::vector<HalfEdge>& newHalfEdges,
                    bool isDual, size_t& curHe, size_t& curV, std::vector<HalfEdge*>& boundary) {

    for(Vertex& v : vertices) {
        if(v.val == 2 && v.onBoundary && not isDual) {
            newVertices[curV] = Vertex(v.coords, nullptr, 2, curV, v.uv);
            newVertices[curV].onBoundary = true;

            //a Vertex in a corner has two outgoing halfedge
            //one with a face (outSel) and one on the boundary outBound
            HalfEdge* outSel = v.out;
            //set correct out it might be the he on boundary
            if(not outSel->polygon) {
                outSel = outSel->prev->twin;
            }
            HalfEdge* outBound = outSel->twin->next;
            newVertices[curV].out = &newHalfEdges[curHe + 1];


            //E
            newHalfEdges[curHe].target = &newVertices[curV];
            newHalfEdges[curHe].next = newHalfEdges[outSel->twin->index].prev;
            newHalfEdges[curHe].prev = &newHalfEdges[outBound->twin->index];
            newHalfEdges[curHe].twin = &newHalfEdges[curHe + 1];
            newHalfEdges[curHe].polygon = &newFaces[v.index];
            newHalfEdges[curHe].index = curHe;

            //also set next and prev of connecting edges which were not previously set.
            newHalfEdges[outSel->twin->index].prev->prev = &newHalfEdges[curHe];
            newHalfEdges[outBound->twin->index].next = &newHalfEdges[curHe];

            //qDebug() << newHalfEdges[outBound->twin->index].index;

            //F
            newHalfEdges[curHe + 1].target = newHalfEdges[outBound->twin->index].target;
            newHalfEdges[curHe + 1].twin = &newHalfEdges[curHe];
            newHalfEdges[curHe + 1].index = curHe + 1;


            //add it to list of boundary
            boundary.push_back(&newHalfEdges[curHe + 1]);

            //still create face for corner vertex
            newFaces[v.index] = Face(&newHalfEdges[v.out->twin->index],
                                    4,
                                    v.index);

            ++curV;
            curHe += 2;
       } else if(v.onBoundary && not isDual) {
            newFaces[v.index] = Face(&newHalfEdges[v.out->twin->index],
                                    v.val + 1,
                                    v.index);
       } else {
            if(isDual)  {
                if(not v.onBoundary) {
                    newFaces[v.index] = Face(&newHalfEdges[v.out->index],
                                    v.val,
                                    v.index);
                }
            } else {
                newFaces[v.index] = Face(&newHalfEdges[v.out->twin->index],
                                v.val,
                                v.index);
            }

       }
    }

}

bool Mesh::dual() {

    std::vector<Vertex> newVertices;
    std::vector<HalfEdge> newHalfEdges;
    std::vector<Face> newFaces;

    size_t numVertices, numFaces, numHalfEdges;
    calculateNumberOfAttributes(numVertices, numFaces, numHalfEdges, isDual,
                                vertices, faces, halfEdges);

    newVertices = std::vector<Vertex>(numVertices);
    newHalfEdges = std::vector<HalfEdge>(numHalfEdges);
    newFaces = std::vector<Face>(numFaces);

    //create face points
    createFacePointsDual(faces, newVertices, newHalfEdges,
                         isDual);

    std::vector<HalfEdge*> boundary;
    size_t curV = faces.size();
    size_t curHe;

    curHe = halfEdges.size();


    //create new halfEdges
    createNewHalfEdges(halfEdges, newVertices, newFaces, newHalfEdges,
                       isDual, curHe, curV, boundary);

    //create new faces
    createNewFaces(vertices, newVertices, newFaces, newHalfEdges,
                   isDual, curHe, curV, boundary);


    //fix boundary
    if(!isDual) {

        for(size_t i = 0; i < boundary.size(); ++i) {
            HalfEdge* he = boundary[i];

            he->target = he->twin->prev->target;

            //find next
            HalfEdge* curEdge = he;
            for(size_t j = 0; j < he->target->val; ++j) {
                if(not curEdge->twin->prev->twin->polygon) {
                    he->next = curEdge->twin->prev->twin;
                    curEdge->twin->prev->twin->prev = he;
                    break;
                }
                curEdge = curEdge->twin->prev;
            }
        }

    }

    this->vertices = std::move(newVertices);
    this->halfEdges = std::move(newHalfEdges);
    this->faces = std::move(newFaces);
    this->isDual = !isDual;
    meshMetrics();

    //set is dual so that next iteration of dual will not generate more boundary vertices/faces


    return true;
}
