#version 330
layout(location = 0) in vec3 vertex_position;

uniform mat4 matrix;

void main()
{
    vec3 p = vertex_position + vec3(0.1, 0.0, 0.0) * float(gl_VertexID);
    gl_Position = matrix * vec4(vertex_position, 1.0);
}
