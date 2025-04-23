#version 400 core
in vec3[] position;
in vec3[] normal;
flat in int[] index;

uniform float tessInnerLevel;
uniform float tessOuterLevel;

uniform bool quadNormals;

layout(vertices = 3) out;
out vec3[] tc_position;
out vec3[] tc_normal;

struct edgeCoeff
{
    vec3 b[2];
};

struct normCoeff
{
    vec3 n[2];
};

out edgeCoeff[] edges;
out normCoeff[] norms;

vec3 project(vec3 n, vec3 vertex, vec3 p) {
    return p - dot((p-vertex), n) * n;
}

vec3 reflect(int i, int j) {
    vec3 plane = normalize(position[j] - position[i]);
    return normalize(normalize(normal[j]) - 2.0*dot(normalize(normal[j]), plane)*plane);
}

int wrapper(int i, int n) {
    if(i < 0){
        return n + i;
    }
    return i % n;
}

void main()
{
    // set inner outer tess level

    if (gl_InvocationID == 0){
        gl_TessLevelInner[0] = tessInnerLevel;
        gl_TessLevelOuter[0] = tessOuterLevel;
        gl_TessLevelOuter[1] = tessOuterLevel;
        gl_TessLevelOuter[2] = tessOuterLevel;
    }


    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
    tc_position[gl_InvocationID] = position[gl_InvocationID];
    tc_normal[gl_InvocationID] = normal[gl_InvocationID];

    int m1 = wrapper(gl_InvocationID - 1, 3);
    int p1 = wrapper(gl_InvocationID + 1, 3);

    edges[gl_InvocationID].b[0] = project(normalize(normal[m1]), position[m1], position[gl_InvocationID]);
    edges[gl_InvocationID].b[1] = project(normalize(normal[p1]), position[p1], position[gl_InvocationID]);


    if(quadNormals) {
        norms[gl_InvocationID].n[0] = reflect(gl_InvocationID, m1);
        norms[gl_InvocationID].n[1] = reflect(gl_InvocationID, p1);
    }
}
