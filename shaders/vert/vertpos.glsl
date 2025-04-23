#version 330
in vec2 vertex_position;

uniform mat4 matrix;

out vec2 pos;

void main()
{
    pos = vertex_position;
    gl_Position = matrix * vec4(vec3(vertex_position, 1.0), 1.0);
}
