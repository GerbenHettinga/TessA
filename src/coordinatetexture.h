#ifndef COORDINATETEXTURE_H
#define COORDINATETEXTURE_H

#include <vector>
#include <glm/glm.hpp>

class CoordinateTexture {
public:
    CoordinateTexture() {}
    CoordinateTexture(int n, int size, bool q);

    std::vector<float> getData();
    unsigned int getID();
    void setID(unsigned int d) {id = d;}

private:
    int valency;
    int size;
    float fsize;
    unsigned int id;

    std::vector<float> asSingle;
    std::vector<glm::vec2> points;

    void createWeightMatrixQuad();
    void createWeightMatrix();
    void createTextures();
    std::vector<float> wachspress(glm::vec2 p);
    std::vector<float> wachspress2(glm::vec2 p);
    std::vector<float> meanvalue(glm::vec2 p);

};
#endif // COORDINATETEXTURE_H
