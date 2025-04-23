#include "subdivisionmesh.h"
#include "../objectreader.h"

SubdivisionMesh::SubdivisionMesh(Mesh* m) : m(m) {
    subdivisionLevel = 0;
    degree = 3;
}

SubdivisionMesh::SubdivisionMesh(Mesh* m, unsigned d) : m(m) {
    subdivisionLevel = 0;
    degree = d;
}

Mesh* SubdivisionMesh::getCurrentLevel() {
    if(subdivisionLevel == 0) {
        return m;
    }
    return &meshes[subdivisionLevel - 1];
}

void SubdivisionMesh::linSubdivide() {
    meshes[subdivisionLevel].linSubdivide();
}

void SubdivisionMesh::dual() {
    meshes[subdivisionLevel].dual();
}

void SubdivisionMesh::evenSmooth() {
    meshes[subdivisionLevel].evenSmooth();
}

void SubdivisionMesh::oddSmooth() {
    meshes[subdivisionLevel].oddSmooth();
}

void SubdivisionMesh::update() {
    subdivide(subdivisionLevel, degree);
    //setSubdivisionLevel(subdivisionLevel, degree);
}

void SubdivisionMesh::setSubdivisionLevel(unsigned level, unsigned degree) {
    subdivide(level >= 0 ? level : 0, degree);

    this->degree = degree;

    subdivisionLevel = level;
}


void SubdivisionMesh::subdivide(int level, unsigned degree) {
    meshes.clear();


    size_t curLevel = 0;
    while(meshes.size() <= std::max(0, level - 1) ) {
        if(meshes.empty()) {
            meshes.push_back(Mesh());
            Mesh& newMesh = meshes.back();
            m->subdivide(degree, newMesh);
        } else {
            meshes.push_back(Mesh());
            Mesh& newMesh = meshes.back();
            meshes[curLevel].subdivide(degree, newMesh);
            curLevel++;
        }
    }
}
