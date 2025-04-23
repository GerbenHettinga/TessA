#ifndef OBJECTREADER_H
#define OBJECTREADER_H

#include <string>
#include "mesh/mesh.h"
#include "polygon.h"

class ObjectReader
{
public:
    static void read(std::string filename, Mesh& mesh);
    static Polygon readPoly(std::string filename);

    static void parseVertex(const std::string& tokens, std::vector<glm::vec3>& vertices);
    static void parseNormal(const std::string& tokens, std::vector<glm::vec3>& vertices);
    static void parseTexCoords(const std::string& tokens, std::vector<glm::vec2>& uvs);

private:
    //static object
    ObjectReader() {}
};

#endif // OBJECTREADER_H
