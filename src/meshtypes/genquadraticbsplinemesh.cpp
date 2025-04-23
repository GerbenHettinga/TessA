#include "genquadraticbsplinemesh.h"
#include "../mesh/mesh.h"
#include "../model.h"

GenQuadraticBSplineMesh::GenQuadraticBSplineMesh(Mesh* m) : MeshType(m)
{
    construct();
}

void GenQuadraticBSplineMesh::construct() {
    Mesh* m = meshes.getCurrentLevel();
    //qDebug() << m->hasExtraordinaryVertices() << " " << m->areEVsSurroundedByQuads() << " " << m->hasExtraordinaryFaces() << " " << m->areEFsSurroundedByQuads() ;
    while((m->hasExtraordinaryVertices() && !m->areEVsSurroundedByQuads())
          ||
          (m->hasExtraordinaryFaces() && !m->areEFsSurroundedByQuads())) {
        //qDebug() << "quadratic subdivision";

        meshes.setSubdivisionLevel(meshes.getSubdivisionLevel() + 1, 2);
        m = meshes.getCurrentLevel();
    }

    controlPointsRegular();
    controlPointsBSpline();
    controlPointsBSplineFace();
}

bool GenQuadraticBSplineMesh::hasFacesOfValency(int i) {
    Mesh* m = meshes.getCurrentLevel();
    if(i == 4) {
        return !m->regVertex.empty();
    }
    return !m->evs[i-3].empty();
}

int GenQuadraticBSplineMesh::getNumberOfFaces(int i) {
    Mesh* m = meshes.getCurrentLevel();
    if(i == 4) {
        return m->regVertex.size();
    }
    return m->evs[i-3].size();
}

void GenQuadraticBSplineMesh::controlPointsBSpline() {
    Mesh* mesh = meshes.getCurrentLevel();

    bsBSplineEV.clear();

    //retrieve G1 data for all evs
    for(size_t v = 0; v < 7; ++v) {
        for(size_t i = 0; i < mesh->evs[v].size(); i++) {
            HalfEdge* he = mesh->evs[v][i]->out;
            //retrieve all C^2 ribbon control points per vertex
            for(size_t j = 0; j < mesh->evs[v][i]->val; j++) {
                //HalfEdge* he2 = he->next;
                HalfEdge* he2 = he->next;

                // this is the order of the vertices
                // 3    --      2(m->evs[i])
                // ||          ||
                // 0    --      1

                std::vector<glm::vec3> jet(4);
                for(size_t p = 0; p < 4; ++p) {
                    jet[p] = he2->target->coords;
                    he2 = he2->next;
                }

                bsBSplineEV.insert(bsBSplineEV.end(), jet.begin(), jet.end());
                he = he->prev->twin;
            }
        }
    }
}

void GenQuadraticBSplineMesh::controlPointsBSplineFace() {
    Mesh* mesh = meshes.getCurrentLevel();

    bsBSplineEF.clear();

    //retrieve G1 data for all evs
    for(size_t v = 0; v < 7; ++v) {
        for(size_t i = 0; i < mesh->efs[v].size(); i++) {
            HalfEdge* he = mesh->efs[v][i]->side;
            //retrieve all C^2 ribbon control points per vertex
            for(size_t j = 0; j < mesh->efs[v][i]->val; j++) {
                //HalfEdge* he2 = he->next;
                HalfEdge* he2 = he->twin->next->twin->next->next;

                // this is the order of the vertices
                // 3    --      2(m->evs[i])
                // ||          ||
                // 0    --      1

                std::vector<glm::vec3> jet(4);
                for(size_t p = 0; p < 4; ++p) {
                    jet[p] = he2->target->coords;
                    he2 = he2->next;
                }

                bsBSplineEF.insert(bsBSplineEF.end(), jet.begin(), jet.end());
                he = he->next;
            }
        }
    }
}

void GenQuadraticBSplineMesh::controlPointsRegular() {
    Mesh* mesh = meshes.getCurrentLevel();

    bsRegular.clear();

    //regular regions from evs
    for(Vertex* v : mesh->regVertex) {
        HalfEdge* he = v->out;

        for(size_t j = 0; j < 4; ++j) {
            bsRegular.push_back(he->next->target->coords);
            bsRegular.push_back(he->next->next->target->coords);
            bsRegular.push_back(v->coords);

            he = he->prev->twin;
        }
    }
}

void GenQuadraticBSplineMesh::update() {
    meshes.update();
    construct();
}
