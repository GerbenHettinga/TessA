#include "objectreader.h"
#include <fstream>
#include <sstream>
#include <iostream>

#include "mesh/mesh.h"
#include "mesh/vertex.h"
#include "mesh/face.h"


/* preserves clockwise ordering of vertices*/
bool testClockWise(std::vector<glm::vec3> vs) {
    float sum = 0.0;
    for(int i = 0; i < vs.size(); i++) {
        sum += glm::distance(vs[i], vs[(i + 1) % vs.size()]);
    }
    return sum >= 0.0;
}

std::vector<glm::vec3> reverse(std::vector<glm::vec3> a) {
    std::vector<glm::vec3> b;
    for(int i = a.size()-1; i >= 0; i--){
        b.push_back(a[i]);
    }
    return b;
}

std::vector<int> reverse(std::vector<int> a) {
    std::vector<int> b;
    for(int i = a.size()-1; i >= 0; i--){
        b.push_back(a[i]);
    }
    return b;
}


/* Reads in polygonal model in obj form
 *
 */
void ObjectReader::read(std::string filename, Mesh& mesh) 
{
    //qDebug() << "Loading model:" << filename;
    std::fstream file(filename);

    std::vector<glm::vec3> vertices; vertices.clear();
    std::vector<glm::vec3> normals; normals.clear();
    std::vector<glm::vec2> uvs; uvs.clear();

    std::vector<std::vector<int>> nInds;
    std::vector<std::vector<int>> uvInds;
    std::vector<std::vector<int>> nextInds;

    bool hasNormals = false;
    bool hasUVs = false;
    bool isFirstFace = true;

    std::vector<int> polyIndices;
    std::vector<int> faceValences;

    if(file.is_open()) {
        std::string line;

        while(std::getline(file, line)) {
            if (line.empty()) continue;
            if (line.rfind("#", 0) == 0) continue; // skip comments

            if (line.rfind("vn", 0) == 0)
            {
                line.erase(0, 3);
                hasNormals = true;
                ObjectReader::parseNormal(line, normals);
            } else if (line.rfind("vt", 0) == 0)
            {
                line.erase(0, 3);
                hasUVs = true;
                ObjectReader::parseTexCoords(line, uvs);
            } else if (line.rfind("v", 0) == 0)
            {
                line.erase(0, 2);
                ObjectReader::parseVertex(line, vertices);
                nextInds.push_back(std::vector<int>(0));
            }

            


            if (line.rfind("f", 0) == 0)
            {
                if(isFirstFace) {
                    if(hasNormals) {
                        nInds = std::vector<std::vector<int>>(vertices.size());
                    }
                    if(hasUVs) {
                        uvInds = std::vector<std::vector<int>>(vertices.size());
                    }

                    isFirstFace = false;
                }

                std::string elements;
                std::vector<int> inds; inds.clear();


                int cnt = 0;
                //remove 'f'
                line.erase(0, 2);

                std::istringstream lineinput(line);
                for (std::string lineToken; std::getline(lineinput, lineToken, ' ');) {
                    
                    int vInd;
                    std::istringstream vertinput(lineToken);
                    int i = 0;
                    for (std::string vertToken; std::getline(vertinput, vertToken, '/'); ) {
                        
                        if (i == 0) {
                            vInd = std::stoi(vertToken) - 1;
                            inds.push_back(vInd);
                        }
                        if (i == 1 && hasUVs) {
                            int uvInd = std::stoi(vertToken) - 1;
                            uvInds[vInd].push_back(uvInd);
                        }
                        if (i == 2 && hasNormals) {
                            int nInd = std::stoi(vertToken) - 1;
                            nInds[vInd].push_back(nInd);
                        }

                        i++;
                    }

                    cnt++;
                }

                faceValences.push_back(cnt);

                //save neighbour indices for each index
                for(size_t i = 0; i < cnt; i++) {
                    nextInds[inds[i]].push_back(inds[(i + 1) % cnt]);
                }

                polyIndices.insert(polyIndices.end(), inds.begin(), inds.end());
            }
        }

        // Release the file resources
        file.close();
    } else {
        //qDebug() << "Could not open the file!";
    }

    mesh.init(vertices, normals, nInds,
        uvs, uvInds,
        nextInds, polyIndices, faceValences);
}

/* reads in a single polygon saved as .obj file */
Polygon ObjectReader::readPoly(std::string filename) {
    //qDebug() << "Loading poly:" << filename;
    std::fstream file(filename);
    std::vector<glm::vec3> polyV; polyV.clear();
    std::vector<glm::vec3> polyN; polyN.clear();

    std::vector<glm::vec3> vertices;
    std::vector<glm::vec3> normals;


    if(file.is_open()) {
        std::string line;
        vertices.clear();
        normals.clear();
        while(std::getline(file, line)) {
            if (line.rfind("#", 0) == 0) continue; // skip comments

            // Switch depending on first element
            if (line.rfind("v", 0) == 0)
            {
                ObjectReader::parseVertex(line, vertices);
            }

            if (line.rfind("vn", 0) == 0)
            {
                ObjectReader::parseNormal(line, normals);
            }

            if (line.rfind("f", 0) == 0)
            {
                /* TODO: fix
                // find the beginning index and set this as first of the boundary in polygon
                int begin = tokens[1].toInt();
                int val = tokens.length() - 1;
                for(int i = 0; i < val; i++) {
                    polyV.push_back(vertices[((begin - 1)  + i) % val]);
                    polyN.push_back(normals[((begin - 1)  + i) % val]);
                }
                */
            }
        }
        file.close();
    }
    return Polygon(polyV, polyN);
}


void ObjectReader::parseVertex(const std::string& line, std::vector<glm::vec3>& vertices) {
    float x,y,z;
    std::istringstream iss(line);
    iss >> x >> y >> z;
    vertices.push_back(glm::vec3(x,y,z));
}

void ObjectReader::parseNormal(const std::string& line, std::vector<glm::vec3>& normals) {
    float x,y,z;
    std::istringstream iss(line);
    iss >> x >> y >> z;
    normals.push_back(glm::normalize(glm::vec3(x, y, z)));
}

void ObjectReader::parseTexCoords(const std::string& line, std::vector<glm::vec2>& uvs) {
    float x,y;
    std::istringstream iss(line);
    iss >> x >> y;
    
    uvs.push_back(glm::vec2(x, y));
}
