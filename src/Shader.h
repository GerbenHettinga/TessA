#pragma once

#include <string>
#include <GL/glew.h>
#include "glm/glm.hpp"
#include "glm/gtc/type_ptr.hpp"

#include <unordered_map>
#include <string>
#include <iostream>

enum ShaderType {
	VertexS = GL_VERTEX_SHADER,
	Fragment = GL_FRAGMENT_SHADER,
	Geometry = GL_GEOMETRY_SHADER,
	TessellationControl = GL_TESS_CONTROL_SHADER,
	TessellationEvaluation = GL_TESS_EVALUATION_SHADER,
	Compute = GL_COMPUTE_SHADER
};

class Shader {

public:

	Shader();
	~Shader();

	void addShaderFromSourceFile(const ShaderType shaderType, std::string path);

	void addShaderFromSourceCode(const ShaderType shaderType, const std::string& src);

	bool link();

	GLint getUniformLocation(const std::string& uniform)
	{
		if (m_uniformLocationMap.find(uniform) == m_uniformLocationMap.end()) {
			const GLint location = glGetUniformLocation(m_program, uniform.c_str());

			if (location >= 0) {
				m_uniformLocationMap[uniform] = location;
			}

			return location;
		}

		return m_uniformLocationMap[uniform];
	}

	void setUniform(const std::string uniform, bool value) {
		GLuint location = getUniformLocation(uniform);

		if (location >= 0)
			glUniform1i(location, value);
	}

	void setUniform(const std::string uniform, int value) {
		GLuint location = getUniformLocation(uniform);

		if(location >= 0)
			glUniform1i(location, value);
	}

	void setUniform(const std::string uniform, float value) {
		GLuint location = getUniformLocation(uniform);

		if (location >= 0)
			glUniform1f(location, value);
	}

	void setUniform(const std::string uniform, const glm::mat4x4& matrix) {
		GLuint location = getUniformLocation(uniform);

		if (location >= 0)
			glUniformMatrix4fv(location, 1, false, glm::value_ptr(matrix));
	}

	void setUniform(const std::string uniform, const glm::mat3x3& matrix) {
		GLuint location = getUniformLocation(uniform);

		if (location >= 0)
			glUniformMatrix3fv(location, 1, false, glm::value_ptr(matrix));
	}

	void setUniform(const std::string uniform, const glm::vec3& vec) {
		GLuint location = getUniformLocation(uniform);

		if (location >= 0)
			glUniform3fv(location, 1, &(vec[0]));
	}

	void setUniform(const std::string uniform, const glm::vec4& vec) {
		GLuint location = getUniformLocation(uniform);

		if (location >= 0)
			glUniform4fv(location, 1, &(vec[0]));
	}

	void setUniform(const GLuint location, int value) {
		if (location >= 0)
			glUniform1i(location, value);
	}

	inline const uint32_t getId() const { 
		return m_program;  
	}

	void use() {
		if (!m_linked)
			link();

		glUseProgram(m_program);
	}

private:
	//map from uniform name to location
	std::unordered_map<std::string, GLint> m_uniformLocationMap;

	std::vector<GLuint> m_shaders;

	GLuint m_program;
	bool m_linked;

	GLuint compileShaderFromFile(const char* location, ShaderType shaderType);
	GLuint compileShaderFromSource(const std::string& src, ShaderType shaderType);


	void checkShader(const GLuint shader, const char* location, ShaderType shaderType);
};