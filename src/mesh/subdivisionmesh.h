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

    Mesh* getBaseLevel() { return &meshes[0]; }
    Mesh* getCurrentLevel();

    void setSubdivisionLevel(unsigned level, unsigned deg);
    unsigned getSubdivisionLevel() { return subdivisionLevel; }

    void setDegree(unsigned d) { degree = d; }
    unsigned getDegree() { return degree; }

    void subdivide(int level, unsigned degree);

    void dooSabin();

    void linSubdivide();
    void dual();
    void evenSmooth();
    void oddSmooth();

    void update();

private:
    Mesh* m;
    std::vector<Mesh> meshes;

    unsigned subdivisionLevel;
    unsigned degree;
};

#endif // SUBDIVISIONMESH_H
