#version 400 core
in vec3 vertex_b0;
in vec3 vertex_b1;
in vec3 vertex_b2;
in vec3 vertex_b3;

in vec3 vertex_b4;
in vec3 vertex_b5;
in vec3 vertex_b6;
in vec3 vertex_b7;

in vec3 vertex_b8;
in vec3 vertex_b9;
in vec3 vertex_b10;
in vec3 vertex_b11;

in vec3 vertex_b12;
in vec3 vertex_b13;
in vec3 vertex_b14;
in vec3 vertex_b15;

out vec3 b0;
out vec3 b1;
out vec3 b2;
out vec3 b3;

out vec3 b4;
out vec3 b5;
out vec3 b6;
out vec3 b7;

out vec3 b8;
out vec3 b9;
out vec3 b10;
out vec3 b11;

out vec3 b12;
out vec3 b13;
out vec3 b14;
out vec3 b15;

flat out int instance;

void main()
{
    instance = gl_InstanceID;

    b0 = vertex_b0;
    b1 = vertex_b1;
    b2 = vertex_b2;
    b3 = vertex_b3;

    b4 = vertex_b4;
    b5 = vertex_b5;
    b6 = vertex_b6;
    b7 = vertex_b7;

    b8 = vertex_b8;
    b9 = vertex_b9;
    b10 = vertex_b10;
    b11 = vertex_b11;

    b12 = vertex_b12;
    b13 = vertex_b13;
    b14 = vertex_b14;
    b15 = vertex_b15;

    gl_Position = vec4(b0, 1.0);
}
