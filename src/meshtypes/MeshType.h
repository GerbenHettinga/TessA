#ifndef MESHTYPE_H
#define MESHTYPE_H


#include "../mesh/subdivisionmesh.h"

class MeshType
{
public:
    MeshType() {

    }

    MeshType(Mesh* m) : meshes(m) {

    }

    Mesh* getMesh() {
        return meshes.getCurrentLevel();
    }

    SubdivisionMesh& getSubdivisionMesh() {
        return meshes;
    }


protected:

    SubdivisionMesh meshes;

};

#endif // MESHTYPE_H
