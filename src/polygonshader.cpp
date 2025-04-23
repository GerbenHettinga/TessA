#include "polygonshader.h"
#include "shader.h"
#include <numbers>
#include <iostream>
#include <fstream>
#include <filesystem>

std::string paramDomain(int n) {
    std::string p = std::string("vec2 tc_param[" + std::to_string(n) + "] = vec2[]( \n");
    float phi = 2.0f * std::numbers::pi / float(n);
    for(int i = 0; i < n; i++) {
        if(i < n) {
            p = p + "vec2(" + std::to_string(cos(phi * float(i))) + ", " + std::to_string(sin(phi * float(i))) + ")";
        }
        if(i < (n - 1)) {
            p = p + ", \n";
        }
    }
    return p + ");";
}

Shader* shader(std::string vs, std::string fs) {
    Shader* s = new Shader();

    s->addShaderFromSourceFile(ShaderType::VertexS, vs);
    s->addShaderFromSourceFile(ShaderType::Fragment, fs);

    return s;
}

std::string readFileIntoString(std::string path)
{
    std::ifstream file;
    file.open(path, std::ios::in);


    if (!file.is_open()) {
        std::filesystem::path cwd = std::filesystem::current_path() / "filename.txt";
        std::cout << cwd << std::endl;
    }

    auto size = std::filesystem::file_size(path);

    std::string string(size, '\0');
    file.read(&string[0], size);
    file.close();
    
    
    return string;
}

void findAndReplace(std::string& str, std::string target, std::string replace)
{
    size_t index = str.find(target, 0);
    if (index == std::string::npos) 
        return;

    str.replace(index, target.length(), replace);
}

Shader* shader(int n, std::string vs, std::string tc, std::string te, std::string fs) {
    Shader* s = new Shader();

    s->addShaderFromSourceFile(ShaderType::VertexS, vs);

    std::string fsCode = readFileIntoString(fs);
    
    if(fsCode.find("/*INCLUDE NOISE*/") != std::string::npos) {
        std::string noiseCode = readFileIntoString("../shaders/noise/noise.glsl");
        fsCode = noiseCode + fsCode;
    }

    s->addShaderFromSourceCode(ShaderType::Fragment, fsCode);

    if(n < 3) {
        s->addShaderFromSourceFile(ShaderType::TessellationControl, tc);
        s->addShaderFromSourceFile(ShaderType::TessellationEvaluation, te);
    } else {
        std::string tcCode = readFileIntoString(tc);
        
        findAndReplace(tcCode, "/*DEFINE N FLAG*/", std::string("#define N ") + std::to_string(n));
       

        s->addShaderFromSourceCode(ShaderType::TessellationControl, tcCode);

        std::string teCode = readFileIntoString(te);

        findAndReplace(teCode, "/*LAYOUT FLAG*/", n == 4 ? "quads" : "triangles");
        findAndReplace(teCode, "/*DEFINE N FLAG*/", std::string("#define N ") + std::to_string(n));
        findAndReplace(teCode, "/*PARAM FLAG*/", paramDomain(n));

        if(teCode.find("/*INCLUDE NOISE*/") != std::string::npos) {
            std::string noiseCode = readFileIntoString("shaders/noise/noise.glsl");
            teCode = noiseCode + teCode;
        }

        s->addShaderFromSourceCode(ShaderType::TessellationEvaluation, teCode);
    }
    return s;
}

PolygonShader::PolygonShader(std::string vs, std::string tc, std::string te) : PolygonShader(4, vs, tc, te) {

}

PolygonShader::PolygonShader(std::string vs) {
    _phongShaderProg = shader(vs, "../shaders/frag/fragshaderqm.glsl");

    _gbcShaderProg = shader(vs, "../shaders/frag/gbcshader.glsl");

    _sliceShaderProg = shader(vs, "../shaders/frag/sliceshader.glsl");

    _normalShaderProg = shader(vs, "../shaders/frag/normalfragshader.glsl");

    _uvShaderProg = shader(vs, "../shaders/frag/uvshader.glsl");

    _isophoteShaderProg = shader(vs, "../shaders/frag/isophoteshaderqm.glsl");

    //_noiseShaderProg = shader(n, vs, tc, te, "../shaders/frag/noiseshader.glsl");

    _flatNormalShaderProg = shader(vs, "../shaders/frag/flatfragshader.glsl");
    _flatNormalShaderProg->addShaderFromSourceFile(ShaderType::Geometry, "../shaders/geom/geometryshader.glsl");
}


PolygonShader::PolygonShader(int n, std::string vs, std::string tc, std::string te, const bool link) {
    _phongShaderProg = shader(n, vs, tc, te, "../shaders/frag/fragshader.glsl");

    _gbcShaderProg = shader(n, vs, tc, te, "../shaders/frag/gbcshader.glsl");

    _sliceShaderProg = shader(n, vs, tc, te, "../shaders/frag/sliceshader.glsl");

    _normalShaderProg = shader(n, vs, tc, te, "../shaders/frag/normalfragshader.glsl");

    _uvShaderProg = shader(n, vs, tc, te, "../shaders/frag/uvshader.glsl");

    _isophoteShaderProg = shader(n, vs, tc, te, "../shaders/frag/isophoteshader.glsl");

    //_noiseShaderProg = shader(n, vs, tc, te, "../shaders/frag/noiseshader.glsl");

    _flatNormalShaderProg = shader(n, vs, tc, te, "../shaders/frag/flatfragshader.glsl");
    _flatNormalShaderProg->addShaderFromSourceFile(ShaderType::Geometry, "../shaders/geom/geometryshader.glsl");

    //if(link)
    //    linkAll();
}


PolygonShader::PolygonShader(int n, std::string tc, std::string te) :
    PolygonShader(n, "../shaders/vert/vertshader.glsl", tc, te) {}

PolygonShader::~PolygonShader() {
    delete _phongShaderProg;
    delete _isophoteShaderProg;
    delete _flatNormalShaderProg;
    delete _gbcShaderProg;
    delete _normalShaderProg;
    delete _uvShaderProg;
    delete _sliceShaderProg;
}


Shader* PolygonShader::getPhongShader() {
    return _phongShaderProg;
}

Shader* PolygonShader::getIsophoteShader() {
    return _isophoteShaderProg;
}

Shader* PolygonShader::getGBCShader() {
    return _gbcShaderProg;
}

Shader* PolygonShader::getNormalShader() {
    return _normalShaderProg;
}

Shader* PolygonShader::getUVShader() {
    return _uvShaderProg;
}

Shader* PolygonShader::getFlatNormalShader() {
    return _flatNormalShaderProg;
}

Shader* PolygonShader::getSliceShader() {
    return _sliceShaderProg;
}

Shader* PolygonShader::getNoiseShader() {
    return _noiseShaderProg;
}

void PolygonShader::linkAll() {
    _flatNormalShaderProg->link();
    _phongShaderProg->link();
    _isophoteShaderProg->link();
    _gbcShaderProg->link();
    _normalShaderProg->link();
    _sliceShaderProg->link();
}
