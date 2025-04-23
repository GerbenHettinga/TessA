#ifndef NORMALMESH_H
#define NORMALMESH_H

#include "../polygon.h"

class Mesh;

class NormalMesh
{
public:
    NormalMesh() {}
    NormalMesh(Mesh* m);
    ~NormalMesh() {}


    inline std::vector<glm::vec3>& getVertices() { return vertices; }
    inline std::vector<glm::vec3>& getNormals() { return normals; }
    inline std::vector<glm::vec2>& getUVs() { return uvs; }
    inline std::vector<int>& getIndicesRing() { return indicesRing; }
    inline std::vector<int>& getIndices() { return indices; }
    std::vector<glm::vec2>* getParams();
    std::vector<glm::vec2>* getBilinearParams();

    std::vector<int>* getIndicesExplicit();
    std::vector<int>* getIndicesTriangular();

    void calculateNormals();

    void addPolygon(Polygon p);
    int getNumberOfTriangles();


private:
    std::vector<glm::vec3> vertices;
    std::vector<glm::vec3> normals;
    std::vector<glm::vec2> uvs;
    std::vector<int> indices;

    std::vector<glm::vec3> verticesArray;
    std::vector<glm::vec3> normalsArray;
    std::vector<glm::vec2> uvsArray;

    std::vector<int> indicesTriangular;
    std::vector<int> indicesRing;

    std::vector<std::vector<Polygon>> patches;

    int nOfTriangles;
};

#endif // NORMALMESH_H
