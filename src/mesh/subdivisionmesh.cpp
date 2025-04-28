#include "subdivisionmesh.h"
#include "../objectreader.h"

SubdivisionMesh::SubdivisionMesh(Mesh* m) : m_mesh(m) {
    m_subdivisionLevel = 0;
    m_degree = 3;
}

SubdivisionMesh::SubdivisionMesh(Mesh* m, unsigned d) : m_mesh(m) {
    m_subdivisionLevel = 0;
    m_degree = d;
}

Mesh* SubdivisionMesh::getCurrentLevel() {
    if(m_subdivisionLevel == 0) {
        return m_mesh;
    }
    return &m_meshes[m_subdivisionLevel - 1];
}

void SubdivisionMesh::linSubdivide() {
    m_meshes[m_subdivisionLevel].linSubdivide();
}

void SubdivisionMesh::dual() {
    m_meshes[m_subdivisionLevel].dual();
}

void SubdivisionMesh::evenSmooth() {
    m_meshes[m_subdivisionLevel].evenSmooth();
}

void SubdivisionMesh::oddSmooth() {
    m_meshes[m_subdivisionLevel].oddSmooth();
}

void SubdivisionMesh::update() {
    subdivide(m_subdivisionLevel, m_degree);
    //setSubdivisionLevel(subdivisionLevel, degree);
}

void SubdivisionMesh::setSubdivisionLevel(unsigned level, unsigned degree) {
    subdivide(level >= 0 ? level : 0, degree);

    m_degree = degree;

    m_subdivisionLevel = level;
}

void SubdivisionMesh::subdivide(int level, unsigned degree) {
    m_meshes.clear();
    m_meshes.reserve(10);

    size_t curLevel = 0;
    while(m_meshes.size() <= std::max(0, level - 1) && m_meshes.size() < 10 ) {
        if(m_meshes.empty()) {
            m_meshes.push_back(Mesh());
            Mesh& newMesh = m_meshes.back();
            m_mesh->subdivide(degree, newMesh);
        } else {
            m_meshes.push_back(Mesh());
            Mesh& newMesh = m_meshes.back();
            m_meshes[curLevel].subdivide(degree, newMesh);
            curLevel++;
        }
    }
}
