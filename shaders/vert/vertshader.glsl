#version 330
layout(location = 0) in vec3 vertex_position;
layout(location = 1) in vec3 vertex_normal;
layout(location = 2) in vec2 vertex_uv;

uniform mat4 matrix;
uniform mat3 normal_matrix;


out vec3 normal;
out vec3 position;
out vec2  uv;
flat out int instance;

void main() {
    instance = gl_InstanceID;
    normal = normalize(vertex_normal);

    position = vertex_position;
    uv = vertex_uv;
    gl_Position = vec4(vertex_position, 1.0);
}
