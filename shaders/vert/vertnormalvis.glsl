#version 330
in vec3 vertex_position;
in vec3 vertex_normal;

uniform mat4 matrix;
uniform bool anim;
uniform bool anim2;
uniform float sysTime;

out vec3 norm;
out vec3 pos;

void main()
{
    norm = normalize(vertex_normal);
    pos = vertex_position;

    if (anim) {
       pos += 0.25 * norm * sin(sysTime/10000000.0*dot(norm, pos)*abs(norm.y));
    } else if(anim2) {
       norm = normalize(norm + 0.3*vec3(sin(sysTime/1000000.0), cos(sysTime/1000000.0), sin(sysTime/1000000.0)));
    }

    gl_Position = matrix * vec4(vertex_position, 1.0);
}
