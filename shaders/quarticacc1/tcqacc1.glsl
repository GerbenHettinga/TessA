#version 400 core
in vec3[] tc_b0;
in vec3[] tc_b1;
in vec3[] tc_b2;

in vec3[] tc_b3;
in vec3[] tc_b4;
in vec3[] tc_b5;

in vec3[] tc_b6;
in vec3[] tc_b7;
in vec3[] tc_b8;

/*DEFINE N FLAG*/

uniform float tessInnerLevel;
uniform float tessOuterLevel;
uniform bool adaptive;
uniform mat4 matrix;

layout(vertices = N) out;
out vec3[] te_b0;
out vec3[] te_b1;
out vec3[] te_b2;

out vec3[] te_b3;
out vec3[] te_b4;
out vec3[] te_b5;

out vec3[] te_b6;
out vec3[] te_b7;
out vec3[] te_b8;


patch out int inst;


void main() {
    // set inner outer tess level
    if (gl_InvocationID == 0) {
        gl_TessLevelInner[0] = tessInnerLevel;
        gl_TessLevelInner[1] = tessInnerLevel;

        gl_TessLevelOuter[0] = tessOuterLevel;
        gl_TessLevelOuter[1] = tessOuterLevel;
        gl_TessLevelOuter[2] = tessOuterLevel;
        gl_TessLevelOuter[3] = tessOuterLevel;
    }


    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;


    te_b0[gl_InvocationID] = tc_b0[gl_InvocationID];
    te_b1[gl_InvocationID] = tc_b1[gl_InvocationID];
    te_b2[gl_InvocationID] = tc_b2[gl_InvocationID];

    te_b3[gl_InvocationID] = tc_b7[gl_InvocationID];
    te_b4[gl_InvocationID] = tc_b8[gl_InvocationID];
    te_b5[gl_InvocationID] = tc_b3[gl_InvocationID];

    te_b6[gl_InvocationID] = tc_b6[gl_InvocationID];
    te_b7[gl_InvocationID] = tc_b5[gl_InvocationID];
    te_b8[gl_InvocationID] = tc_b4[gl_InvocationID];

    //tc_n[gl_InvocationID] = normalize(cross(normalize(tc_ep[gl_InvocationID] - te_p[gl_InvocationID]), normalize(tc_em[gl_InvocationID] - te_p[gl_InvocationID])));
}
