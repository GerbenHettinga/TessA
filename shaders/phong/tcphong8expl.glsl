#version 400 core
in vec3[] position;
in vec3[] normal;
in vec2[] param;
flat in int[] instance;

uniform float tessInnerLevel;
uniform float tessOuterLevel;


layout(vertices = 8) out;
out vec3[] tc_position;
out vec3[] tc_normal;
out vec2[] tc_param;
patch out int inst;

// edge coefficients fanned from previous neighbour
// and a mid coeff
struct coeff
{
    vec3 b[7];
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

    int m1 = wrapper(gl_InvocationID - 1, 8);
    int p6 = wrapper(gl_InvocationID + 6, 8);
    int p5 = wrapper(gl_InvocationID + 5, 8);
    int p4 = wrapper(gl_InvocationID + 4, 8);
    int p3 = wrapper(gl_InvocationID + 3, 8);
    int p2 = wrapper(gl_InvocationID + 2, 8);
    int p1 = wrapper(gl_InvocationID + 1, 8);


    cps[gl_InvocationID].b[0] = project(normalize(normal[m1]), position[m1], position[gl_InvocationID]);

    cps[gl_InvocationID].b[1] = project(normalize(normal[p6]), position[p6], position[gl_InvocationID]);

    cps[gl_InvocationID].b[2] = project(normalize(normal[p5]), position[p5], position[gl_InvocationID]);

    cps[gl_InvocationID].b[3] = project(normalize(normal[p4]), position[p4], position[gl_InvocationID]);

    cps[gl_InvocationID].b[4] = project(normalize(normal[p3]), position[p3], position[gl_InvocationID]);

    cps[gl_InvocationID].b[5] = project(normalize(normal[p2]), position[p2], position[gl_InvocationID]);

    cps[gl_InvocationID].b[6] = project(normalize(normal[p1]), position[p1], position[gl_InvocationID]);


}
