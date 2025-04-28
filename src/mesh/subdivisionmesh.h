#ifndef SUBDIVISIONMESH_H
#define SUBDIVISIONMESH_H

#include <vector>
#include "mesh.h"


class SubdivisionMesh
{
public:
    SubdivisionMesh() {}
    SubdivisionMesh(Mesh* m);
    SubdivisionMesh(Mesh* m, unsigned d);

    Mesh* getBaseLevel() { return &m_meshes[0]; }
    Mesh* getCurrentLevel();

    void setSubdivisionLevel(unsigned level, unsigned deg);
    unsigned getSubdivisionLevel() { return m_subdivisionLevel; }

    void setDegree(unsigned d) { m_degree = d; }
    unsigned getDegree() { return m_degree; }

    void subdivide(int level, unsigned degree);


    void linSubdivide();
    void dual();
    void evenSmooth();
    void oddSmooth();

    void update();

private:
    Mesh* m_mesh;
    std::vector<Mesh> m_meshes;

    unsigned m_subdivisionLevel;
    unsigned m_degree;
};

#endif // SUBDIVISIONMESH_H
