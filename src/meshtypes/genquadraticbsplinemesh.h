#ifndef GENQUADRATICBSPLINEMESH_H
#define GENQUADRATICBSPLINEMESH_H

#include <vector>
#include <glm/glm.hpp>

#include "MeshType.h"

class GenQuadraticBSplineMesh : public MeshType
{
public:
    GenQuadraticBSplineMesh() {}
    GenQuadraticBSplineMesh(Mesh* m);
    ~GenQuadraticBSplineMesh() {}

    bool hasFacesOfValency(int i);
    int getNumberOfFaces(int i);



    inline const std::vector<glm::vec3>& getBsBSplineEF() const {return bsBSplineEF; }
    inline const std::vector<glm::vec3>& getBsBSplineEV() const {return bsBSplineEV; }
    inline const std::vector<glm::vec3>& getRegularBs() const {return bsRegular; }

    void update();

private:
    void construct();
    void controlPointsBSpline();
    void controlPointsBSplineFace();
    void controlPointsRegular();


    std::vector<glm::vec3> bsBSplineEV;
    std::vector<glm::vec3> bsBSplineEF;
    std::vector<glm::vec3> bsRegular;
};

#endif // GENQUADRATICBSPLINEMESH_H
