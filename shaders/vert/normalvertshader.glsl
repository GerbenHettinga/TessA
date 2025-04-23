#version 330
in vec3 vertex_position;

uniform mat4 matrix;
uniform vec3 plane;

out vec3 normal;
out vec3 position;

void main()
{
    normal = normalize(plane);
    position = vertex_position;
    gl_Position = matrix * vec4(vertex_position, 1.0);
}
