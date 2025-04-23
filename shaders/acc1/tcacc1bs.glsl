#version 400 core
in vec3[] tc_position;
in vec3[] tc_em;
in vec3[] tc_ep;
in vec3[] tc_fp;

/*DEFINE N FLAG*/

uniform float tessInnerLevel;
uniform float tessOuterLevel;
uniform bool adaptive;
uniform mat4 matrix;

layout(vertices = N) out;
out vec3[] te_p;
out vec3[] te_em;
out vec3[] te_ep;
out vec3[] te_fp;

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
    te_p[gl_InvocationID] = tc_position[gl_InvocationID];
    te_em[gl_InvocationID] = tc_em[gl_InvocationID];
    te_ep[gl_InvocationID] = tc_ep[gl_InvocationID];
    te_fp[gl_InvocationID] = tc_fp[gl_InvocationID];

    //tc_n[gl_InvocationID] = normalize(cross(normalize(tc_ep[gl_InvocationID] - te_p[gl_InvocationID]), normalize(tc_em[gl_InvocationID] - te_p[gl_InvocationID])));
}
