#ifndef GENQUARTICBSPLINEMESH_H
#define GENQUARTICBSPLINEMESH_H

#include <vector>
#include <glm/glm.hpp>
#include "MeshType.h"


class GenQuarticBSplineMesh : public MeshType
{
public:
    GenQuarticBSplineMesh() {}
    GenQuarticBSplineMesh(Mesh* m);
    ~GenQuarticBSplineMesh() {}

    bool hasFacesOfValency(int i);
    int getNumberOfFaces(int i);

    void selectMesh();

    inline const std::vector<glm::vec3>& getVertices() const { return ps; }
    inline const std::vector<glm::vec3>& getBsBSplineEV() const {return bsBSplineEV; }
    inline const std::vector<glm::vec3>& getBsBSplineEF() const {return bsBSplineEF; }
    inline const std::vector<glm::vec3>& getRegularBs() const {return rbs; }
    inline const std::vector<glm::vec2>& getUVs() const {return uvs; }

    inline const std::vector<glm::vec3>& getRegularVertices() const { return rps; }


    void update();

private:


    void controlPointsBezier();
    void controlPointsBSpline();
    void controlPointsBSplineFace();
    void controlPointsRegular();

    void construct();


    std::vector<glm::vec3> ps;
    std::vector<glm::vec3> psB;
    //concatenated array of cps
    std::vector<glm::vec3> bsBSplineEV;
    std::vector<glm::vec3> bsBSplineEF;
    std::vector<glm::vec2> uvs;

    std::vector<glm::vec3> rps;
    std::vector<glm::vec3> rbs;

    std::vector<std::vector<glm::vec3>> bsB;
};

#endif // GENQUARTICBSPLINEMESH_H
