#include "model.h"
#include "objectreader.h"

#include <string>

Model::Model()
{

}

void Model::set(std::string fileName, RenderParameters* rp) {
    settings = rp;

    ObjectReader::read(fileName, mesh);

    nmesh = NormalMesh(&mesh);
    ccmesh = CCMesh(&mesh);
    controlmesh = ControlMesh(&mesh);
    quadmesh = QuadMesh(&mesh);

    q2gbsmesh = GenQuadraticBSplineMesh(&mesh);
    gbsmesh = GenBSplineMesh(&mesh);
    q4gbsmesh = GenQuarticBSplineMesh(&mesh);
}

void Model::update() {
    mesh.update();

    switch(settings->MeshMode) {
        case MeshModes::PolyMesh : {
            //nmesh.getSubdivisionMesh().dual();
        } break;
        case MeshModes::ACC2 : {
            ccmesh.update();
        } break;
        case MeshModes::CubicGBS : {
            gbsmesh.update();
        } break;
        case MeshModes::QuadraticGBS : {
            q2gbsmesh.update();
        } break;
        case MeshModes::QuarticGBS : {
            q4gbsmesh.update();
        } break;
        case MeshModes::QuadMesh : {
            quadmesh.update();
        } break;
    }

    controlmesh = ControlMesh(&mesh);
}

void Model::setSubdivisionLevel(unsigned level, unsigned degree) {
    switch(settings->MeshMode) {
        case MeshModes::PolyMesh : {
            //nmesh.getSubdivisionMesh().dual();
        } break;
        case MeshModes::ACC2 : {
            ccmesh.getSubdivisionMesh().setSubdivisionLevel(level, degree);
        } break;
        case MeshModes::CubicGBS : {
            gbsmesh.getSubdivisionMesh().setSubdivisionLevel(level, degree);
        } break;
        case MeshModes::QuadraticGBS : {
            q2gbsmesh.getSubdivisionMesh().setSubdivisionLevel(level, degree);
        } break;
        case MeshModes::QuarticGBS : {
            q4gbsmesh.getSubdivisionMesh().setSubdivisionLevel(level, degree);
        } break;
        case MeshModes::QuadMesh : {
            quadmesh.getSubdivisionMesh().setSubdivisionLevel(level, degree);
        } break;
    }
}

void Model::dual() {
    mesh.dual();
    update();
}

void Model::evenSmooth() {
    mesh.evenSmooth();
    update();
}

void Model::oddSmooth() {
    mesh.oddSmooth();
    update();
}

void Model::linSubdivide() {
    mesh.linSubdivide();
    update();
}