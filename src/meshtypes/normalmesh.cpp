#include "normalmesh.h"
#include "../mesh/mesh.h"
#include <numbers>

NormalMesh::NormalMesh(Mesh* m) {
    size_t n = m->vertices.size();

    vertices = std::vector<glm::vec3>(n);
    normals = std::vector<glm::vec3>(n);
    uvs = std::vector<glm::vec2>(n);

    for(size_t i = 0; i < n; ++i) {
        vertices[i] = m->vertices[i].coords;
        normals[i] = m->vertices[i].normal;
        uvs[i] = m->vertices[i].uv;
    }

    //since faces are sorted by valency everything is grouped correctly
    for(size_t k = 3; k < 9; ++k) {
        for(size_t i = 0; i < m->faces.size(); i++) {
            Face* f = &m->faces[i];
            HalfEdge* he = f->side;


            for(size_t i = 0; i < f->val; i++) {
                indices.push_back(he->target->index);
                verticesArray.push_back(he->twin->target->coords);

                if(m->hasUVs()) {
                    uvsArray.push_back(he->uv);
                } else {
                    uvsArray.push_back(glm::vec2(0.5f, 0.5f));
                }

                if(m->hasNormals()) {
                    normalsArray.push_back(he->normal);
                } else {
                    normalsArray.push_back(he->twin->target->normal);
                }

                he = he->next;
            }
        }
    }

    // Calculating normals by averaging
    glm::vec3 vec1, vec2;
    Vertex* v;
    for(size_t k = 0; k < m->getVertices().size(); k++) {
        v = &m->vertices[k];
        if(v->out) {
            HalfEdge* he = v->out;
            vec1 = he->target->coords - v->coords;
            size_t n = m->vertices[k].val;

            if(n == 2) {
                vec2 = he->twin->next->target->coords - v->coords;
                v->normal = glm::cross(glm::normalize(vec2), glm::normalize(vec1));
            } else {
                for(int j = 0; j < n; j++) {
                    //Draw a vector from the target of two twins
                    vec2 = he->twin->next->target->coords - v->coords;
                    v->normal += glm::cross(glm::normalize(vec2), glm::normalize(vec1));

                    vec1 = vec2;
                    he = he->twin->next;
                }
            }


            // averaging by normalizing
            glm::normalize(v->normal);
            if(!m->hasNormals()) {
               //vertexNormals.push_back(vertices[k].normal);
            }

            if(!m->hasUVs()) {
                //spherical parameterisation
                glm::vec3 vn = glm::normalize(v->coords);
                glm::vec2 uv = glm::vec2(.5f + atan2(vn.z, vn.x), .5f - asin(vn.y) / float(std::numbers::pi));
                //vertexUVs.push_back();
                v->uv = uv;
            }
        }
    }


}

std::vector<int>* NormalMesh::getIndicesTriangular() {
    return &indicesTriangular;
}


void NormalMesh::addPolygon(Polygon p) {
    patches[p.getSize()-3].push_back(p);
}

int NormalMesh::getNumberOfTriangles() {
    return nOfTriangles;
}


