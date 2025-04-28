#ifndef MODEL_H
#define MODEL_H

#include "mesh/mesh.h"
#include "meshtypes/normalmesh.h"
#include "meshtypes/ccmesh.h"
#include "meshtypes/genquadraticbsplinemesh.h"
#include "meshtypes/genquarticbsplinemesh.h"
#include "meshtypes/genbsplinemesh.h"
#include "meshtypes/controlmesh.h"
#include "meshtypes/quadmesh.h"
#include "renderparameters.h"


class Model
{
public:
    Model();


    void set(std::string fileName, RenderParameters* rp);

    Mesh*       getMesh()                               { return &mesh; }

    CCMesh& getCCMesh()                                 { return ccmesh; }
    GenBSplineMesh& getGBSMesh()                        { return gbsmesh; }
    GenQuadraticBSplineMesh& getQuadraticGBSMesh()      { return q2gbsmesh; }
    GenQuarticBSplineMesh& getQuarticGBSMesh()          { return q4gbsmesh; }
    NormalMesh& getNormalMesh()                         { return nmesh; }
    ControlMesh& getControlMesh()                       { return controlmesh; }
    QuadMesh& getQuadMesh()                             { return quadmesh; }


    
    int getSubdivisionDegree();
    int getSubdivisionLevel();
    void setSubdivisionLevel(unsigned level, unsigned degree);
    void dual();
    void evenSmooth();
    void oddSmooth();
    void linSubdivide();

    void update();

private:
    SubdivisionMesh& getSubdivisionMesh();
    
    Mesh mesh;
    std::vector<Mesh> meshes;


    RenderParameters* settings;

    NormalMesh nmesh;
    CCMesh ccmesh;
    GenBSplineMesh gbsmesh;
    GenQuadraticBSplineMesh q2gbsmesh;
    GenQuarticBSplineMesh q4gbsmesh;
    ControlMesh controlmesh;
    QuadMesh quadmesh;
};

#endif // MODEL_H
