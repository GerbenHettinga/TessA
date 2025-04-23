#include "genquarticbsplinemesh.h"
#include "../model.h"
#include "math.h"
#include "ccpatch.h"
#include "../mesh/mesh.h"

GenQuarticBSplineMesh::GenQuarticBSplineMesh(Mesh* m) : MeshType(m)
{
    construct();
}


void GenQuarticBSplineMesh::selectMesh() {
    //get appropriately subdivided model
    SubdivisionMesh& sm = getSubdivisionMesh();
    while((sm.getCurrentLevel()->hasExtraordinaryVertices() && !sm.getCurrentLevel()->areEVsTwiceIsolated())
          ||
          (sm.getCurrentLevel()->hasExtraordinaryFaces() && !sm.getCurrentLevel()->areEFsTwiceIsolated())
          )
    {
        //qDebug() << "quartic subdivision";
        sm.setSubdivisionLevel(sm.getSubdivisionLevel() + 1, 4);
    }
}

void GenQuarticBSplineMesh::construct() {
    selectMesh();

    controlPointsBSplineFace();
    controlPointsBSpline();
    controlPointsRegular();
//    //qDebug() << "Gen B-spline stats, triangles:" << patchesBezier[0].size() << "quads" << patchesBezier[1].size() << "pents" << patchesBezier[2].size()
//             << "hexs" << patchesBezier[3].size() << "hepts" << patchesBezier[4].size() << "octs" << patchesBezier[5].size() << "nons" << patchesBezier[6].size();
}

/*      12 --- 15 --- 9 ---  8
 *       |     |      |      |
 *       |     |      |      |
 *      13 --- 14 --- 10 --- 11
 *       |     |      |      |
 *       |     |      |      |
 *       3 --- 2 ---  6 ---  5
 *       |     |      |      |
 *       |     |      |      |
 *       0 --- 1 ---  7 ---  4
 */
void GenQuarticBSplineMesh::controlPointsBSplineFace() {
    Mesh* m = getSubdivisionMesh().getCurrentLevel();

    bsBSplineEF.clear();
    //iterate over different valencies of EFs
    for(size_t f = 0; f < 7; ++f) {
        for(size_t i = 0; i < m->efs[f].size(); ++i) {
            Face* face = m->efs[f][i];

            HalfEdge* he = face->side;
            for(size_t v = 0; v < face->val; ++v) {
                HalfEdge* he2 = he->twin->next->twin->prev->twin->next->twin->prev;

                std::vector<glm::vec3> jet;
                //walk along the regular block of vertices
                for(size_t q = 0; q < 4; ++q) {
                    HalfEdge* he3 = he2->twin->next->twin->prev->prev;
                    for(size_t r = 0; r < 4; ++r) {
                        jet.push_back(he3->target->coords);

                        he3 = he3->next;
                    }
                    he2 = he2->next;
                }

                bsBSplineEF.insert(bsBSplineEF.end(), jet.begin(), jet.end());

                he = he->next;
            }

        }
    }
}


/*      12 --- 15 --- 9 ---  8
 *       |     |      |      |
 *       |     |      |      |
 *      13 --- 14 --- 10 --- 11
 *       |     |      |      |
 *       |     |      |      |
 *       3 --- 2 ---  6 ---  5
 *       |     |      |      |
 *       |     |      |      |
 *       0 --- 1 ---  7 ---  4
 */
void GenQuarticBSplineMesh::controlPointsBSpline() {
    Mesh* m = getSubdivisionMesh().getCurrentLevel();

    bsBSplineEV.clear();
    //calculate parabolic jets at vertices surrounding EVs
    for(size_t v = 0; v < 7; ++v) {
        for(size_t i = 0; i < m->evs[v].size(); i++) {
            HalfEdge* he = m->evs[v][i]->out;
            //retrieve all C^3 ribbon control points per vertex
            for(size_t j = 0; j < m->evs[v][i]->val; j++) {
                HalfEdge* he2 = he->twin->prev->twin->next->twin->prev;

                std::vector<glm::vec3> jet;
                for(size_t q = 0; q < 4; ++q) {
                    HalfEdge* he3 = he2->twin->next->twin->prev->prev;
                    for(size_t r = 0; r < 4; ++r) {
                        jet.push_back(he3->target->coords);

                        he3 = he3->next;
                    }
                    he2 = he2->next;
                }
                bsBSplineEV.insert(bsBSplineEV.end(), jet.begin(), jet.end());

                he = he->prev->twin;
            }
        }
    }
}


void GenQuarticBSplineMesh::controlPointsRegular() {
    Mesh* m = getSubdivisionMesh().getCurrentLevel();

    rbs.clear();

    for(Vertex* v : m->regVertex) {
        bool reg = true;
        HalfEdge* he = v->out;
        for(size_t i = 0; i < 4; ++i) {
            if(!he->target->isRegularFaced() || !he->next->target->isRegularFaced() || he->target->isOnBoundary()) {
                reg = false;
                break;
            }
            he = he->prev->twin;
        }

        he = v->out;
        if(reg) {
            for(size_t i = 0; i < 4; ++i) {
                HalfEdge* he2 = he->next->twin->prev->twin;
                for(size_t j = 0; j < 4; ++j) {
                    rbs.push_back(he2->next->target->coords);
                    rbs.push_back(he2->next->next->target->coords);

                    he2 = he2->prev->twin;
                }
                rbs.push_back(he2->twin->target->coords);
                he = he->prev->twin;
            }
        }
    }
}

void GenQuarticBSplineMesh::update() {
    getSubdivisionMesh().update();
    construct();
}
