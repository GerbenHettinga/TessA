#include "ccmesh.h"
#include "math.h"
#include "../mesh/mesh.h"

int wrp(int a, int n) {
        return (a + n) % n;
}


CCMesh::CCMesh(Mesh* m) : MeshType(m) {
    construct();
}

CCMesh::~CCMesh()
{

}

void CCMesh::construct() {
    m_patches.clear();
    m_patches.resize(6);

    m_ps.clear();
    m_uvs.clear();

    Mesh* m = meshes.getCurrentLevel();
    //now that all the data has been determined and integrated into the half-edge structure we can
    //start building patches.
    for(unsigned i = 0; i < m->faces.size(); i++) {
        Face* f = &m->faces[i];
        Vertex* v;
        std::vector<glm::vec3> vs(f->val), ep(f->val), em(f->val), fp(f->val), fm(f->val);
        std::vector<glm::vec2> uvs(f->val);
        HalfEdge* he = f->side;
        for(int j = 0; j < f->val; j++) {
            v = he->target;

            vs[(j+1) % f->val] = v->p;
            //set e+, e-, f+ and f- for different halfedges every iteration
            ep[j] = he->e;
            em[(j+1) % f->val] = he->twin->e;

            fp[j] = he->fp;

            uvs[(j+1) % f->val] = v->uv;


            fm[(j+1) % f->val] = he->twin->fm;

            //traverse all edges of the polygon
            he = he->next;
        }
        m_patches[f->val-3].push_back(CCPatch(vs, ep, em, fp, fm, uvs));
    }



    m_bs = std::vector<std::vector<glm::vec3>>(4);
    //extract data from patches
    for(int i = 0; i < 6; i++) {
        for(int j = 0; j < m_patches[i].size(); j++) {
            const auto vertices = m_patches[i][j].getVertices();

            m_ps.insert(m_ps.end(), vertices.begin(), vertices.end());

            const std::vector<std::vector<glm::vec3>>& b = m_patches[i][j].getBs();
            for(size_t k = 0; k < 4; k++) {
                m_bs[k].insert(m_bs[k].end(), b[k].begin(), b[k].end());
            }

            m_uvs.insert(m_uvs.end(), m_patches[i][j].getUVs().begin(), m_patches[i][j].getUVs().end());
        }
    }
}

void CCMesh::update() {
    getSubdivisionMesh().update();
    construct();
}





