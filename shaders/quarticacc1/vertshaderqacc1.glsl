#version 330
in vec3 vertex_b0;
in vec3 vertex_b1;
in vec3 vertex_b2;

in vec3 vertex_b3;
in vec3 vertex_b4;
in vec3 vertex_b5;

in vec3 vertex_b6;
in vec3 vertex_b7;
in vec3 vertex_b8;


uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform float sysTime;
uniform bool anim;
uniform bool anim2;

out vec3 tc_b0;
out vec3 tc_b1;
out vec3 tc_b2;

out vec3 tc_b3;
out vec3 tc_b4;
out vec3 tc_b5;

out vec3 tc_b6;
out vec3 tc_b7;
out vec3 tc_b8;


void main()
{
    tc_b0 = vertex_b0;
    tc_b1 = vertex_b1;
    tc_b2 = vertex_b2;

    tc_b3 = vertex_b3;
    tc_b4 = vertex_b4;
    tc_b5 = vertex_b5;

    tc_b6 = vertex_b6;
    tc_b7 = vertex_b7;
    tc_b8 = vertex_b8;

    gl_Position = vec4(vertex_b0, 1.0);
}
