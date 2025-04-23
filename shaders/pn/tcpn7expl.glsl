#version 400 core
in vec3[] position;
in vec3[] normal;
flat in int[] instance;

uniform float tessInnerLevel;
uniform float tessOuterLevel;

uniform bool quadNormals;
uniform bool pn;

layout(vertices = 7) out;
out vec3[] tc_position;
out vec3[] tc_normal;
patch out int inst;

// edge coefficients fanned from previous neighbour
// and a mid coeff
struct coeff
{
    vec3 b[6];
    vec3 m[5];
};


out coeff cps[];

struct normCoeff
{
    vec3 n[6];
};

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
        inst = instance[0];
    }

    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
    tc_position[gl_InvocationID] = position[gl_InvocationID];
    tc_normal[gl_InvocationID] = normal[gl_InvocationID];

    int m1 = wrapper(gl_InvocationID - 1, 7);
    int p5 = wrapper(gl_InvocationID + 5, 7);
    int p4 = wrapper(gl_InvocationID + 4, 7);
    int p3 = wrapper(gl_InvocationID + 3, 7);
    int p2 = wrapper(gl_InvocationID + 2, 7);
    int p1 = wrapper(gl_InvocationID + 1, 7);

    cps[gl_InvocationID].b[0] = 2.0 * position[gl_InvocationID] + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[m1]);
    cps[gl_InvocationID].b[1] = 2.0 * position[gl_InvocationID] + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p5]);
    cps[gl_InvocationID].b[2] = 2.0 * position[gl_InvocationID] + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p4]);
    cps[gl_InvocationID].b[3] = 2.0 * position[gl_InvocationID] + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p3]);
    cps[gl_InvocationID].b[4] = 2.0 * position[gl_InvocationID] + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p2]);
    cps[gl_InvocationID].b[5] = 2.0 * position[gl_InvocationID] + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p1]);

    vec3 mid = (position[m1] + position[gl_InvocationID] + position[p1]);
    cps[gl_InvocationID].m[0] = (mid + 3.0*project(normalize(normal[m1]), position[m1], mid/3.0)
                               + 3.0*project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], mid/3.0)
                               + 3.0*project(normalize(normal[p1]), position[p1], mid/3.0))/12.0;

    mid = (position[gl_InvocationID] + position[p2] + position[m1]);
    cps[gl_InvocationID].m[1] = (mid + 3.0*project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], mid/3.0)
                               + 3.0*project(normalize(normal[p2]), position[p2], mid/3.0)
                               + 3.0*project(normalize(normal[m1]), position[m1], mid/3.0))/12.0;

    mid = (position[gl_InvocationID] + position[p3] + position[m1]);
    cps[gl_InvocationID].m[2] = (mid + 3.0*project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], mid/3.0)
                               + 3.0*project(normalize(normal[p3]), position[p3], mid/3.0)
                               + 3.0*project(normalize(normal[m1]), position[m1], mid/3.0))/12.0;

    mid = (position[gl_InvocationID] + position[p4] + position[m1]);
    cps[gl_InvocationID].m[3] = (mid + 3.0*project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], mid/3.0)
                               + 3.0*project(normalize(normal[p4]), position[p4], mid/3.0)
                               + 3.0*project(normalize(normal[m1]), position[m1], mid/3.0))/12.0;

    mid = (position[gl_InvocationID] + position[p5] + position[p2]);
    cps[gl_InvocationID].m[4] = (mid + 3.0*project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], mid/3.0)
                               + 3.0*project(normalize(normal[p5]), position[p5], mid/3.0)
                               + 3.0*project(normalize(normal[p2]), position[p2], mid/3.0))/12.0;


    if(quadNormals) {
        norms[gl_InvocationID].n[0] = reflect(gl_InvocationID, m1);
        norms[gl_InvocationID].n[1] = reflect(gl_InvocationID, p5);
        norms[gl_InvocationID].n[2] = reflect(gl_InvocationID, p4);
        norms[gl_InvocationID].n[3] = reflect(gl_InvocationID, p3);
        norms[gl_InvocationID].n[4] = reflect(gl_InvocationID, p2);
        norms[gl_InvocationID].n[5] = reflect(gl_InvocationID, p1);
    }
}
