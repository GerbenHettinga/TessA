#version 400 core
in vec3[] b0;
in vec3[] b1;
in vec3[] b2;
in vec3[] b3;


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
    vec3 b[4];
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
    J[gl_InvocationID].b[2] = b3[gl_InvocationID];
    J[gl_InvocationID].b[3] = b2[gl_InvocationID];

    tc_n[gl_InvocationID] = normalize(cross(normalize(b1[gl_InvocationID] - b0[gl_InvocationID]), normalize(b3[gl_InvocationID] - b0[gl_InvocationID])));
}
