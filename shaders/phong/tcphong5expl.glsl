#version 400 core
in vec3[] position;
in vec3[] normal;
in vec2[] param;
flat in int[] instance;

uniform float tessInnerLevel;
uniform float tessOuterLevel;

uniform bool quadNormals;
uniform bool pn;

layout(vertices = 5) out;
out vec3[] tc_position;
out vec3[] tc_normal;
out vec2[] tc_param;
patch out int inst;

// edge coefficients fanned from previous neighbour
// and a mid coeff
struct coeff
{
    vec3 b[4];
};


out coeff cps[];

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
        inst = instance[0];
    }

    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
    tc_position[gl_InvocationID] = position[gl_InvocationID];
    tc_normal[gl_InvocationID] = normal[gl_InvocationID];
    tc_param[gl_InvocationID] = param[gl_InvocationID];

    int m1 = wrapper(gl_InvocationID - 1, 5);
    int p3 = wrapper(gl_InvocationID + 3, 5);
    int p2 = wrapper(gl_InvocationID + 2, 5);
    int p1 = wrapper(gl_InvocationID + 1, 5);


    cps[gl_InvocationID].b[0] = project(normalize(normal[m1]), position[m1], position[gl_InvocationID]);

    cps[gl_InvocationID].b[1] = project(normalize(normal[p3]), position[p3], position[gl_InvocationID]);

    cps[gl_InvocationID].b[2] = project(normalize(normal[p2]), position[p2], position[gl_InvocationID]);

    cps[gl_InvocationID].b[3] = project(normalize(normal[p1]), position[p1], position[gl_InvocationID]);


}
