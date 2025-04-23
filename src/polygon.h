#ifndef POLYGON_H
#define POLYGON_H

#include <vector>
#include <string>
#include <glm/glm.hpp>

class Polygon {
public:
    Polygon();
    Polygon(int valency);
    Polygon(std::vector<glm::vec3> vs, std::vector<glm::vec3> ns, std::vector<glm::vec2> uvs);
    Polygon(std::vector<glm::vec3> vs, std::vector<glm::vec2> uvs);
    Polygon(std::vector<glm::vec3> vs, std::vector<glm::vec3> ns);
    Polygon(std::vector<glm::vec3> vs);
    ~Polygon();


    std::vector<glm::vec3> getVertices();
    std::vector<glm::vec3> getPolygonVertices();
    std::vector<glm::vec3> getNormals();
    std::vector<glm::vec3> getPolygonNormals();
    std::vector<glm::vec2> getPolygonUVs();

    void changeNormal(int vert, glm::vec3 change);
    void setNormals(std::vector<glm::vec3> ns);
    std::vector<int> getIndices();
    std::vector<int> getIndicesRing();
    std::vector<int> getIndicesExplicit();
    std::vector<int> getIndicesTriangular();
    std::vector<glm::vec2> getParametrization();
    std::vector<glm::vec2> getParametrizationBilinear();
    std::vector<glm::vec3> getPlane();
    glm::vec3 getPlaneNormal();
    void savePolygon(std::string filename);
    int getSize();
    void setVertex(int index, glm::vec3 v);
    void calculate();

protected:
    std::vector<glm::vec3> triangulateEarClip();
    std::vector<int> triangulateEarClipIndex();
    std::vector<int> triangulateFanIndex();
    void calculatePlane();

    std::vector<glm::vec3> polygonVertices;
    std::vector<glm::vec3> polygonNormals;
    std::vector<glm::vec2> polygonUVs;
    std::vector<int> indices;
    int size;

};
#endif // POLYGON_H
