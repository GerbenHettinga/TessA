#version 330
in vec3 vertex_position;
in vec3 vertex_ep;
in vec3 vertex_m;


uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform float sysTime;
uniform bool anim;
uniform bool anim2;

out vec3 tc_position;
out vec3 tc_ep;
out vec3 tc_m;


void main()
{
    tc_position = vertex_position;
    tc_ep = vertex_ep;
    tc_m = vertex_m;

    gl_Position = vec4(vertex_position, 1.0);
}
