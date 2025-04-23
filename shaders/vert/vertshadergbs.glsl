#version 400 core
in vec3 vertex_position;
in vec3 vertex_b10;
in vec3 vertex_b20;
in vec3 vertex_b30;
in vec3 vertex_b01;
in vec3 vertex_b11;
in vec3 vertex_b21;
in vec3 vertex_b31;
in vec3 vertex_b02;
in vec3 vertex_b12;
in vec3 vertex_b22;
in vec3 vertex_b32;
in vec2 vertex_uv;


out vec3 position;
out vec3 b10;
out vec3 b20;
out vec3 b30;
out vec3 b01;
out vec3 b11;
out vec3 b21;
out vec3 b31;
out vec3 b02;
out vec3 b12;
out vec3 b22;
out vec3 b32;
out vec2 uv;


flat out int instance;

void main()
{
    instance = gl_InstanceID;

    position = vertex_position;
    b10 = vertex_b10;
    b20 = vertex_b20;
    b30 = vertex_b30;

    b01 = vertex_b01;
    b11 = vertex_b11;
    b21 = vertex_b21;
    b31 = vertex_b31;

    b02 = vertex_b02;
    b12 = vertex_b12;
    b22 = vertex_b22;
    b32 = vertex_b32;

    uv = vertex_uv;

    gl_Position = vec4(vertex_position, 1.0);
}
