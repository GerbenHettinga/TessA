#ifndef POLYGONSHADER_H
#define POLYGONSHADER_H

#include "Shader.h"

class PolygonShader
{
public:
    PolygonShader(std::string vs, std::string tc, std::string te);
    PolygonShader(std::string vs);
    PolygonShader(int n, std::string vs, std::string tc, std::string te, const bool link = true);
    PolygonShader(int n, std::string te, std::string tc);
    ~PolygonShader();

    Shader* getPhongShader();
    Shader* getFlatPhongShader();
    Shader* getIsophoteShader();
    Shader* getFlatIsophoteShader();
    Shader* getGBCShader();
    Shader* getNormalShader();
    Shader* getUVShader();
    Shader* getFlatNormalShader();
    Shader* getSliceShader();
    Shader* getNoiseShader();

    void linkAll();


private:

    Shader* _phongShaderProg;
    Shader* _phongFlatShaderProg;
    Shader* _isophoteShaderProg;
    Shader* _isophoteFlatShaderProg;
    Shader* _gbcShaderProg;
    Shader* _normalShaderProg;
    Shader* _uvShaderProg;
    Shader* _flatNormalShaderProg;
    Shader* _sliceShaderProg;
    Shader* _noiseShaderProg;

//    GLuint* _phongShaderProg;
//    GLuint* _phongFlatShaderProg;
//    GLuint* _isophoteShaderProg;
//    GLuint* _isophoteFlatShaderProg;
//    GLuint* _gbcShaderProg;
//    GLuint* _normalShaderProg;
//    GLuint* _flatNormalShaderProg;
//    GLuint* _sliceShaderProg;
};

#endif // POLYGONSHADER_H
