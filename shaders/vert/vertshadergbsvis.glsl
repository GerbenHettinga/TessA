#version 330
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


uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform float sysTime;
uniform bool anim;
uniform bool anim2;

out vec3 pos;
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

flat out int instance;

void main()
{
    instance = gl_InstanceID;

    pos = vertex_position;
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

    gl_Position = vec4(vertex_position, 1.0);
}
