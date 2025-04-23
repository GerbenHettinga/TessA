#include "genbsplinemesh.h"
#include "../model.h"
#include "../mesh/mesh.h"
#include "math.h"
#include "ccpatch.h"


GenBSplineMesh::GenBSplineMesh(Mesh* m) : MeshType(m)
{
    construct();
}

void GenBSplineMesh::selectMesh() {

    //get appropriately subdivided model
    while((meshes.getCurrentLevel()->hasExtraordinaryVertices() && !meshes.getCurrentLevel()->areEVsIsolated())
          ||
          (meshes.getCurrentLevel()->hasExtraordinaryFaces() && !meshes.getCurrentLevel()->areEFsIsolated())
          )
    {
        //qDebug() << "cubic subdivision";
        meshes.setSubdivisionLevel(meshes.getSubdivisionLevel() + 1, 3);
    }
}

void GenBSplineMesh::construct() {
    selectMesh();

    controlPointsBSplineFace();
    controlPointsBSpline();
    controlPointsRegular();
//    //qDebug() << "Gen B-spline stats, triangles:" << patchesBezier[0].size() << "quads" << patchesBezier[1].size() << "pents" << patchesBezier[2].size()
//             << "hexs" << patchesBezier[3].size() << "hepts" << patchesBezier[4].size() << "octs" << patchesBezier[5].size() << "nons" << patchesBezier[6].size();
}

HalfEdge* vertOnBoundary(Vertex* currentVertex) {
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


std::vector<glm::vec3> tangentLimitStencils(Vertex* v) {
    HalfEdge* he = v->out;

    return {};
}



void GenBSplineMesh::controlPointsBSplineFace() {
    //iterate over different valencies of EFs
    Mesh* m = meshes.getCurrentLevel();

    bsBSplineEF.clear();

    for(size_t f = 0; f < 7; ++f) {
        for(size_t i = 0; i < m->efs[f].size(); ++i) {
            Face* face = m->efs[f][i];

            HalfEdge* he = face->side;
            for(size_t v = 0; v < face->val; ++v) {
                HalfEdge* cHe = he->twin->next->twin;
                HalfEdge* heW = cHe;

                std::vector<glm::vec3> jet(9);
                //walk along the regular block of vertices
                for(size_t j = 0; j < 8; ++j){
                    jet[8 - j] = heW->target->coords;

                    if((j % 2) == 0) {
                        heW = heW->next;
                    } else {
                        heW = heW->next->twin->next;
                    }
                }
                jet[0] = cHe->prev->twin->target->coords;
                //do not forget to insert in buffers
                bsBSplineEF.insert(bsBSplineEF.end(), jet.begin(), jet.end());
                he = he->next;
            }

        }
    }
}

void GenBSplineMesh::controlPointsBSpline() {
    idxB.resize(7);
    Mesh* m = meshes.getCurrentLevel();
    bsBSplineEV.clear();
    //calculate parabolic jets at vertices surrounding EVs
    for(size_t v = 0; v < 7; ++v) {
        for(size_t i = 0; i < m->evs[v].size(); i++) {
            HalfEdge* he = m->evs[v][i]->out->next->next;
            //retrieve all C^2 ribbon control points per vertex
            for(size_t j = 0; j < m->evs[v][i]->val; j++) {
                //HalfEdge* he2 = he->next;
                HalfEdge* he2 = he->next;

                // this is the order of the vertices
                // 6     --    7    --      8(m->evs[i])
                // ||          ||          ||
                // 5     --    0    --      1
                // ||          ||          ||
                // 4     --    3    --      2

                std::vector<glm::vec3> jet(9);
                for(size_t p = 0; p < 8; ++p) {
                    jet[8 - p] = he2->target->coords;
                    if(p % 2 == 0) {
                        he2 = he2->next;
                    } else {
                        he2 = he2->next->twin->next;
                    }
                }
                //get centre vertex by using HE instead of HE2!!!!!!
                jet[0] = he->twin->target->coords;
                bsBSplineEV.insert(bsBSplineEV.end(), jet.begin(), jet.end());

                he = he->next->twin->next->next;
            }
        }
    }
}

void GenBSplineMesh::controlPointsRegular() {
    Mesh* m = meshes.getCurrentLevel();

    rbs.clear();

    rbs.reserve(m->regFaces.size() * 16 + m->bRegFaces.size() * 16);
    //extract regular faces
    for(size_t i = 0; i < m->regFaces.size(); i++) {
            HalfEdge* he = m->regFaces[i]->side;
            for(size_t j = 0; j < 4; j++) {
                rbs.push_back(he->target->p);
                rbs.push_back(he->twin->e);
                rbs.push_back(he->next->e);
                rbs.push_back(he->next->fp);

                he = he->next;
            }

    }

    for(size_t i = 0; i < m->halfEdges.size(); i++) {
        HalfEdge* he = &m->halfEdges[i];

        //get limit positions;
        glm::vec3 t = he->twin->target->coords;
        if(he->twin->target->val == 4 || he->twin->target->onBoundary) {
            he->twin->target->p = he->twin->target->vertexLimitStencil();
        }

        if(!he->twin->polygon) {
            //if(he->twin->target->val == 2) {
                // control mesh positions
                // b5 -- b6
                // ||    ||
                // t  xx b3
                he->e = (2.0f*t + he->target->coords) / 3.0f;
                he->fm = (t + 2.0f*he->target->coords) / 3.0f;
                he->fp = (4.0f*t + 2.0f*he->target->coords + he->next->target->coords + 2.0f*he->next->next->target->coords) / 9.0f;
            //}
        } else if(!he->polygon) {
                he->e = (2.0f*t + he->target->coords) / 3.0f;
                he->fm = (t + 2.0f*he->target->coords) / 3.0f;
        } else {
                // control mesh positions
                // b4 -- b5 -- b6
                // ||    ||    ||
                // b0 -- t  xx b3
                glm::vec3 b5 = he->target->coords;
                glm::vec3 b4 = he->next->target->coords;
                glm::vec3 b0 = he->next->next->target->coords;
                glm::vec3 b6 = he->twin->prev->prev->target->coords;
                glm::vec3 b3 = he->twin->next->target->coords;


                he->e = ((2.0f*b0 + b4)/3.0f + 4.0f*(2.0f*t + b5)/3.0f + (2.0f*b3 + b6)/3.0f) / 6.0f;
                he->fm = ((b0 + 2.0f*b4)/3.0f + 4.0f*(t + 2.0f*b5)/3.0f + (b3 + 2.0f*b6)/3.0f) / 6.0f;
                he->fp = (4.0f*t + 2.0f*b5 + 2.0f*b0 + b4 ) / 9.0f;
        }
    }

//    for(size_t i = 0; i < m->bRegFaces.size(); i++) {
//        HalfEdge* he = m->bRegFaces[i]->side;

//        if(!m->bRegFaces[i]->isOnBoundary()) {

//            for(size_t j = 0; j < 4; ++j) {
//                rbs.push_back(he->target->p);
//                rbs.push_back(he->twin->e);
//                rbs.push_back(he->next->e);
//                rbs.push_back(he->next->fp);

//                he = he->next;
//            }
//        }
//    }
}

void GenBSplineMesh::update() {
    meshes.update();
    construct();
}




