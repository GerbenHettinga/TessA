#version 400 core
in vec3 vertex_b0;
in vec3 vertex_b1;
in vec3 vertex_b2;
in vec3 vertex_b3;

out vec3 b0;
out vec3 b1;
out vec3 b2;
out vec3 b3;

flat out int instance;

void main()
{
    instance = gl_InstanceID;

    b0 = vertex_b0;
    b1 = vertex_b1;
    b2 = vertex_b2;
    b3 = vertex_b3;

    gl_Position = vec4(b0, 1.0);
}
