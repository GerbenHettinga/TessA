#version 400 core
in vec3[] position;
in vec3[] b10;
in vec3[] b20;
in vec3[] b30;

in vec3[] b01;
in vec3[] b11;
in vec3[] b21;
in vec3[] b31;

in vec3[] b02;
in vec3[] b12;

in vec3[] b22;
in vec3[] b32;
flat in int[] instance;

/*DEFINE N FLAG*/

uniform float tessInnerLevel;
uniform float tessOuterLevel;
uniform bool adaptive;
uniform mat4 matrix;

layout(vertices = N) out;
out vec3[] tc_p;
out vec3[] tc_n;

struct Pos
{
    vec3 b[5];
};

struct Tangent
{
    vec3 b[7];
};

/*
struct Curvature
{
    vec3 b[7];
};*/

out Pos P[];
out Tangent T[];
//out Curvature C[];



patch out int inst;


void main()
{

    // set inner outer tess level
    if (gl_InvocationID == 0) {
        gl_TessLevelInner[0] = tessInnerLevel;
        gl_TessLevelInner[1] = tessInnerLevel;

        gl_TessLevelOuter[0] = tessOuterLevel;
        gl_TessLevelOuter[1] = tessOuterLevel;
        gl_TessLevelOuter[2] = tessOuterLevel;
        gl_TessLevelOuter[3] = tessOuterLevel;

        inst = instance[0];
    }

    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
    tc_p[gl_InvocationID] = position[gl_InvocationID];

    int p1 = (gl_InvocationID + 1) % N;

    P[gl_InvocationID].b[0] = b10[gl_InvocationID];
    P[gl_InvocationID].b[1] = b20[gl_InvocationID];
    P[gl_InvocationID].b[2] = b30[gl_InvocationID];
    P[gl_InvocationID].b[3] = b02[p1];
    P[gl_InvocationID].b[4] = b01[p1];

    T[gl_InvocationID].b[0] = 3.0*(b01[gl_InvocationID] - position[gl_InvocationID]);
    T[gl_InvocationID].b[1] = 3.0*(b11[gl_InvocationID] - b10[gl_InvocationID]);
    T[gl_InvocationID].b[2] = 3.0*(b21[gl_InvocationID] - b20[gl_InvocationID]);
    T[gl_InvocationID].b[3] = 3.0*(b31[gl_InvocationID] - b30[gl_InvocationID]);

    T[gl_InvocationID].b[4] = 3.0*(b12[p1] - b02[p1]);
    T[gl_InvocationID].b[5] = 3.0*(b11[p1] - b01[p1]);
    T[gl_InvocationID].b[6] = 3.0*(b10[p1] - position[p1]);


    tc_n[gl_InvocationID] = normalize(cross(normalize(b10[gl_InvocationID] - position[gl_InvocationID]), normalize(b01[gl_InvocationID] - position[gl_InvocationID])));
}
