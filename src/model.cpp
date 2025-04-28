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

SubdivisionMesh& Model::getSubdivisionMesh() {
    switch (settings->MeshMode) {
        case MeshModes::PolyMesh: {
            //nmesh.getSubdivisionMesh().dual();
        } break;
        case MeshModes::ACC2: {
            return ccmesh.getSubdivisionMesh();
        } break;
        case MeshModes::CubicGBS: {
            return gbsmesh.getSubdivisionMesh();
        } break;
        case MeshModes::QuadraticGBS: {
            return q2gbsmesh.getSubdivisionMesh();
        } break;
        case MeshModes::QuarticGBS: {
            return q4gbsmesh.getSubdivisionMesh();
        } break;
        case MeshModes::QuadMesh: {
            return quadmesh.getSubdivisionMesh();
        } break;
    }

    return quadmesh.getSubdivisionMesh();
}

int Model::getSubdivisionDegree()
{
    SubdivisionMesh& subdivisionMesh = getSubdivisionMesh();

    return subdivisionMesh.getDegree();
}

int Model::getSubdivisionLevel()
{
    SubdivisionMesh& subdivisionMesh = getSubdivisionMesh();

    return subdivisionMesh.getSubdivisionLevel();
}

void Model::setSubdivisionLevel(unsigned level, unsigned degree) {
    SubdivisionMesh& subdivisionMesh = getSubdivisionMesh();

    subdivisionMesh.setSubdivisionLevel(level, degree);
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