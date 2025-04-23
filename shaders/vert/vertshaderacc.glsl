#version 330
in vec3 vertex_position;
in vec3 vertex_ep;
in vec3 vertex_em;
in vec3 vertex_fp;
in vec3 vertex_fm;
in vec2 vertex_uv;
in vec3 vertex_noise;


uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform float sysTime;
uniform bool anim;
uniform bool anim2;

out vec3 position;
out vec3 a;
out vec3 b;
out vec3 c;
out vec3 d;
out vec2 uv;
out vec3 noise;

flat out int instance;

void main()
{
    instance = gl_InstanceID;
    position = vertex_position;
    a = vertex_ep;
    b = vertex_em;
    c = vertex_fp;
    d = vertex_fm;
    uv = vertex_uv;
    noise = vertex_noise;


    gl_Position = vec4(vertex_position, 1.0);
}
