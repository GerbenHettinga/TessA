#version 330
in vec3 vertex_position;
in vec3 vertex_normal;

uniform mat4 matrix;
uniform float sysTime;
uniform bool anim;
uniform bool anim2;

out vec3 position;
out vec3 normal;


void main()
{
    normal = normalize(vertex_normal);
    position = vertex_position;

    if (anim) {
        position += 0.25 * normal * sin(sysTime/10000000.0*dot(normal, position)*abs(normal.y));
    }
    if(anim2) {
       normal = normalize(normal + 0.3*vec3(sin(sysTime/1000000.0), cos(sysTime/1000000.0), sin(sysTime/1000000.0)));
    }
    gl_Position = matrix * vec4(position, 1.0);
}
