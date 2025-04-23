#include "Shader.h"

#include <string>
#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <filesystem>

#include "GL/glew.h"

#define DEBUG_SHADERS 1

std::string readFile(const char* filePath) {
    std::string content;
    std::ifstream fileStream(filePath, std::ios::in);

    if (!fileStream.is_open()) {
        std::cerr << "Could not read file " << filePath << ". File does not exist." << std::endl;
        return "";
    }

    std::string line = "";
    while (!fileStream.eof()) {
        std::getline(fileStream, line);
        content.append(line + "\n");
    }

    //fileStream.close();
    return content;
}

std::string replaceFlags(std::string orig, int valency) {
    size_t index = orig.find("/* VLFLAG */");

    if (index != std::string::npos) {
        std::string replacement = "           " + std::to_string(valency);
        orig.replace(index, 12, replacement);
    }

    return orig;
}

void Shader::checkShader(const GLuint shader, const char* location, ShaderType shaderType)
{
    GLint shaderCompiled = GL_FALSE;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &shaderCompiled);
    if (DEBUG_SHADERS && !shaderCompiled) {
        std::filesystem::path cwd = std::filesystem::current_path() / (location ? std::string(location) : std::string(""));

        GLint logLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            std::vector<char> shaderError((logLength > 1) ? logLength : 1);
            glGetShaderInfoLog(shader, logLength, NULL, &shaderError[0]);
            if (DEBUG_SHADERS)
                std::cout << &shaderError[0] << std::endl;

            std::cout << shaderCompiled << " " << shaderType << " " << cwd << std::endl;
        }
    }
}

GLuint Shader::compileShaderFromFile(const char* location, ShaderType shaderType) {
    std::string text = readFile(location);

    const char* src = text.c_str();

    GLuint shader = glCreateShader(shaderType);
    glShaderSource(shader, 1, &src, NULL);
    glCompileShader(shader);

    checkShader(shader, location, shaderType);

    return shader;
}

GLuint Shader::compileShaderFromSource(const std::string& src, ShaderType shaderType) {
    GLuint shader = glCreateShader(shaderType);

    const char* srcPtr = src.c_str();

    glShaderSource(shader, 1, &srcPtr, NULL);
    glCompileShader(shader);

    checkShader(shader, nullptr, shaderType);

    return shader;
}

Shader::Shader() :
    m_program(-1),
    m_linked(false)
{

}

Shader::~Shader()
{
    glDeleteProgram(m_program);
}


void Shader::addShaderFromSourceFile(const ShaderType shaderType, std::string path)
{
    GLuint shader = compileShaderFromFile(path.c_str(), shaderType);

    //glAttachShader(m_program, shader);

    m_shaders.push_back(shader);
}

void Shader::addShaderFromSourceCode(const ShaderType shaderType, const std::string& src)
{
    GLuint shader = compileShaderFromSource(src, shaderType);

    //glAttachShader(m_program, shader);

    m_shaders.push_back(shader);
}

bool Shader::link()
{
    m_program = glCreateProgram();

    for (const GLuint& shader : m_shaders) {
        glAttachShader(m_program, shader);
    }

    glLinkProgram(m_program);

    GLint programLinked = GL_FALSE;
    glGetProgramiv(m_program, GL_LINK_STATUS, &programLinked);
    if (DEBUG_SHADERS && !programLinked) {
        std::cout << programLinked << " program" << std::endl;
        return false;
    }

    GLint logLength;
    glGetProgramiv(m_program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        std::vector<char> programError((logLength > 1) ? logLength : 1);
        glGetProgramInfoLog(m_program, logLength, NULL, &programError[0]);
        if (DEBUG_SHADERS) {
            std::cout << &programError[0] << std::endl;
            return false;
        }
    }

    for (GLuint shader : m_shaders) {
        glDetachShader(m_program, shader);
        glDeleteShader(shader);
    }

    m_linked = true;

    return true;
}