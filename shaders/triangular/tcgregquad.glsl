#version 400 core
in vec3[] position;
in vec3[] normal;
flat in int[] instance;

uniform float tessInnerLevel;
uniform float tessOuterLevel;

uniform bool quadNormals;

layout(vertices = 4) out;
out vec3[] tc_position;
out vec3[] tc_normal;
patch out int inst;

// edge coefficients fanned from previous neighbour
// and a mid coeff
struct coeff
{
    vec3 b[2];
    vec3 f[2];
};

out coeff cps[];

struct normCoeff
{
    vec3 n[3];
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
    return i > 0 ? n - i : i % n;
}

void main()
{
    // set inner outer tess level
    if (gl_InvocationID == 0){
        gl_TessLevelInner[0] = tessInnerLevel;
        gl_TessLevelInner[1] = tessInnerLevel;

        gl_TessLevelOuter[0] = tessOuterLevel;
        gl_TessLevelOuter[1] = tessOuterLevel;
        gl_TessLevelOuter[2] = tessOuterLevel;
        gl_TessLevelOuter[3] = tessOuterLevel;
        inst = instance[0];
    }

    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
    tc_position[gl_InvocationID] = position[gl_InvocationID];
    tc_normal[gl_InvocationID] = normal[gl_InvocationID];

    int m1 = wrapper(gl_InvocationID - 1, 4);
    int p1 = wrapper(gl_InvocationID + 1, 4);

    cps[gl_InvocationID].b[0] = (2.0 * position[gl_InvocationID] + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[m1]))/3.0;
    cps[gl_InvocationID].b[1] = (2.0 * position[gl_InvocationID] + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p1]))/3.0;

    barrier();

    vec3 H0 = cps[gl_InvocationID].b[1] - position[gl_InvocationID];
    vec3 H0Hat = normalize(H0);
    vec3 H1 = cps[p1].b[0] - cps[gl_InvocationID].b[1];
    vec3 H2 = position[p1] - cps[p1].b[0];
    vec3 H2Hat = normalize(H2);

    vec3 F0 = cps[gl_InvocationID].b[0] - position[gl_InvocationID];
    vec3 F3 = cps[p1].b[1] - position[p1];

    //unit vector perpendiculars for basis patch
    vec3 C0 = -cross(H0Hat, normalize(normal[gl_InvocationID]));
    vec3 C1 = -cross(H2Hat, normalize(normal[p1]));

    float k0, h0, k1, h1;

    //find scalar ratios
    vec3 F0prime = dot(C0, F0) * C0;
    k0 = dot(C0, normalize(F0prime)) * length(F0prime);
    h0 = dot(H0Hat, normalize(F0-F0prime)) * length(F0 - F0prime)/length(H0);

    vec3 F3prime = dot(C1, F3) * C1;
    k1 = dot(C1, normalize(F3prime)) * length(F3prime);
    h1 = dot(H2Hat, normalize(F3-F3prime)) * length(F3 - F3prime)/length(H2);

    //linear interpolation for the other two vectors
    vec3 C2 = (2.0*C0 + C1)/3.0;
    vec3 C3 = (2.0*C1 + C0)/3.0;

    cps[gl_InvocationID].f[0] = (k1-k0)*C0/3.0 + 2.0*h0*H1/3.0 + h1*H0/3.0 + k0*C2;
    cps[gl_InvocationID].f[1] = k1*C3 - (k1-k0)*C1/3.0 + h0*H2/3.0 + 2.0*h1*H1/3.0;


    cps[gl_InvocationID].f[0] += cps[gl_InvocationID].b[1];
    cps[gl_InvocationID].f[1] += cps[p1].b[0];

    if(quadNormals) {
        int p2 = wrapper(gl_InvocationID + 2, 4);
        norms[gl_InvocationID].n[0] = reflect(gl_InvocationID, m1);
        norms[gl_InvocationID].n[1] = reflect(gl_InvocationID, p2);
        norms[gl_InvocationID].n[2] = reflect(gl_InvocationID, p1);
    }

}
