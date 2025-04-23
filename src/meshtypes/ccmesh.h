#ifndef CCMESH_H
#define CCMESH_H

#include <vector>
#include "ccpatch.h"
#include "MeshType.h"


class CCMesh : public MeshType {

public:
    CCMesh() {}
    CCMesh(Mesh* m);
    ~CCMesh();


    std::vector<glm::vec3>& getVertices() { return m_ps; }
    std::vector<std::vector<glm::vec3>>& getBs() { return m_bs; }
    std::vector<std::vector<CCPatch>>& getPatches() { return m_patches; }
    std::vector<glm::vec2>& getUVs() { return m_uvs;}

    void update();

private:

    void construct();

    std::vector<std::vector<CCPatch>> m_patches;

    std::vector<glm::vec3> m_ps;
    std::vector<std::vector<glm::vec3>> m_bs;
    std::vector<glm::vec2> m_uvs;
};

#endif // CCMESH_H
