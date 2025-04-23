#version 400 core
in vec3[] b0;
in vec3[] b1;
in vec3[] b2;
in vec3[] b3;

in vec3[] b4;
in vec3[] b5;
in vec3[] b6;
in vec3[] b7;

in vec3[] b8;
in vec3[] b9;
in vec3[] b10;
in vec3[] b11;

in vec3[] b12;
in vec3[] b13;
in vec3[] b14;
in vec3[] b15;


flat in int[] instance;

/*DEFINE N FLAG*/

uniform float tessInnerLevel;
uniform float tessOuterLevel;
uniform bool adaptive;
uniform mat4 matrix;

layout(vertices = N) out;
out vec3[] tc_p;
out vec3[] tc_n;


struct Jet
{
    vec3 b[16];
};

out Jet J[];


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

    tc_p[gl_InvocationID] = b0[gl_InvocationID];

    J[gl_InvocationID].b[0] = b0[gl_InvocationID];
    J[gl_InvocationID].b[1] = b1[gl_InvocationID];
    J[gl_InvocationID].b[2] = b7[gl_InvocationID];
    J[gl_InvocationID].b[3] = b4[gl_InvocationID];

    J[gl_InvocationID].b[4] = b3[gl_InvocationID];
    J[gl_InvocationID].b[5] = b2[gl_InvocationID];
    J[gl_InvocationID].b[6] = b6[gl_InvocationID];
    J[gl_InvocationID].b[7] = b5[gl_InvocationID];

    J[gl_InvocationID].b[8] = b13[gl_InvocationID];
    J[gl_InvocationID].b[9] = b14[gl_InvocationID];
    J[gl_InvocationID].b[10] = b10[gl_InvocationID];
    J[gl_InvocationID].b[11] = b11[gl_InvocationID];

    J[gl_InvocationID].b[12] = b12[gl_InvocationID];
    J[gl_InvocationID].b[13] = b15[gl_InvocationID];
    J[gl_InvocationID].b[14] = b9[gl_InvocationID];
    J[gl_InvocationID].b[15] = b8[gl_InvocationID];


    tc_n[gl_InvocationID] = normalize(cross(normalize(b1[gl_InvocationID] - b0[gl_InvocationID]), normalize(b7[gl_InvocationID] - b0[gl_InvocationID])));
    //tc_n[gl_InvocationID] = normalize(cross(normalize(b1[gl_InvocationID] - b0[gl_InvocationID]), normalize(b4[gl_InvocationID] - b0[gl_InvocationID])));
}
