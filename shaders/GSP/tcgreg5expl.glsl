#version 400 core
in vec3[] position;
in vec3[] normal;
flat in int[] instance;

uniform float tessInnerLevel;
uniform float tessOuterLevel;

uniform bool quadNormals;
uniform float qvalue;
uniform bool fixedCurves;

layout(vertices = 5) out;
out vec3[] tc_position;
out vec3[] tc_normal;
patch out int inst;

// edge coefficients fanned from previous neighbour
// and a mid coeff
struct coeff
{
    vec3 b[4];
    vec3 f[6];
};

struct normCoeff
{
    vec3 n[4];
};

out normCoeff[] norms;
out coeff cps[];

vec3 project(vec3 n, vec3 vertex, vec3 p) {
    return p - dot((p-vertex), n) * n;
}

vec3 reflect(int i, int j) {
    vec3 plane = normalize(position[j] - position[i]);
    return normalize(normalize(normal[j]) - 2.0*dot(normalize(normal[j]), plane)*plane);
}

int wrapper(int i, int n) {
    return i >= 0 ? i % n : n + i;
}


vec4 findRatios(vec3 F0, vec3 F3,
                float lH0, vec3 H0Hat, float lH2, vec3 H2Hat, vec3 C0, vec3 C3) {
    float k0, h0, k1, h1;

    vec3 F0prime = dot(C0, F0) * C0;
    k0 = dot(C0, normalize(F0prime)) * length(F0prime);
    h0 = 0.0;
    vec3 f0f0prime = F0 - F0prime;
    if(length(f0f0prime) != 0.0) {
        h0 = dot(H0Hat, normalize(f0f0prime)) * length(F0 - F0prime) / lH0;
    }

    vec3 F3prime = dot(C3, F3) * C3;
    k1 = dot(C3, normalize(F3prime)) * length(F3prime);
    h1 = 0.0;
    vec3 f3f3prime = F3 - F3prime;
    if(length(f3f3prime) != 0.0) {
        h1 = dot(H2Hat, normalize(f3f3prime)) * length(F3 - F3prime) / lH2;
    }

    return vec4(k0, h0, k1, h1);
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

    int m1 = wrapper(gl_InvocationID - 1, 5);
    int p4 = (gl_InvocationID + 4) % 5;
    int p3 = (gl_InvocationID + 3) % 5;
    int p2 = (gl_InvocationID + 2) % 5;
    int p1 = (gl_InvocationID + 1) % 5;

    float p = qvalue;
    if(fixedCurves) p = 1.0/3.0;


    cps[gl_InvocationID].b[0] = mix(position[gl_InvocationID], project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p1]), p);
    cps[gl_InvocationID].b[1] = mix(position[gl_InvocationID], project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p2]), p);
    cps[gl_InvocationID].b[2] = mix(position[gl_InvocationID], project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p3]), p);
    cps[gl_InvocationID].b[3] = mix(position[gl_InvocationID], project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p4]), p);

//    cps[gl_InvocationID].b[0] = (2.0 * position[gl_InvocationID] + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p1]))/3.0;
//    cps[gl_InvocationID].b[1] = (2.0 * position[gl_InvocationID] + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p2]))/3.0;
//    cps[gl_InvocationID].b[2] = (2.0 * position[gl_InvocationID] + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p3]))/3.0;
//    cps[gl_InvocationID].b[3] = (2.0 * position[gl_InvocationID] + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p4]))/3.0;

    barrier();

    vec3 H0 = cps[gl_InvocationID].b[0] - position[gl_InvocationID];
    vec3 H0Hat = normalize(H0);
    vec3 H1 = cps[p1].b[3] - cps[gl_InvocationID].b[0];
    vec3 H2 = position[p1] - cps[p1].b[3];
    vec3 H2Hat = normalize(H2);

    //unit vector perpendiculars for basis patch
    vec3 C0 = -cross(H0Hat, normalize(normal[gl_InvocationID]));
    vec3 C3 = -cross(H2Hat, normalize(normal[p1]));

    //linear interpolation for the other two vectors
    vec3 C1 = (2.0*C0 + C3)/3.0;
    vec3 C2 = (2.0*C3 + C0)/3.0;

    vec3 F0, F3;
    float k0, h0, k1, h1;

    F0 = (0.75*cps[gl_InvocationID].b[3] + 0.25*position[gl_InvocationID]) - position[gl_InvocationID];
    F3 = (0.75*cps[p1].b[2] + 0.25*position[p1]) - position[p1];
    vec4 ratios = findRatios(F0, F3, length(H0), H0Hat, length(H2), H2Hat, C0, C3);
    k0 = ratios[0]; h0 = ratios[1];  k1 = ratios[2];  h1 = ratios[3];

    cps[gl_InvocationID].f[0] = cps[gl_InvocationID].b[0] + (k1-k0)*C0/3.0 + 2.0*h0*H1/3.0 + h1*H0/3.0 + k0*C1;
    cps[gl_InvocationID].f[1] = cps[p1].b[3] + k1*C2 - (k1-k0)*C3/3.0 + h0*H2/3.0 + 2.0*h1*H1/3.0;

    F0 = (0.75*cps[gl_InvocationID].b[2] + 0.25*position[gl_InvocationID]) - position[gl_InvocationID];
    F3 = (0.75*cps[p1].b[1] + 0.25*position[p1]) - position[p1];
    ratios = findRatios(F0, F3, length(H0), H0Hat, length(H2), H2Hat, C0, C3);
    k0 = ratios[0]; h0 = ratios[1];  k1 = ratios[2];  h1 = ratios[3];


    cps[gl_InvocationID].f[2] = cps[gl_InvocationID].b[0] + (k1-k0)*C0/3.0 + 2.0*h0*H1/3.0 + h1*H0/3.0 + k0*C1;
    cps[gl_InvocationID].f[3] = cps[p1].b[3] + k1*C2 - (k1-k0)*C3/3.0 + h0*H2/3.0 + 2.0*h1*H1/3.0;

    F0 = (0.75*cps[gl_InvocationID].b[1] + 0.25*position[gl_InvocationID]) - position[gl_InvocationID];
    F3 = (0.75*cps[p1].b[0] + 0.25*position[p1]) - position[p1];
    ratios = findRatios(F0, F3, length(H0), H0Hat, length(H2), H2Hat, C0, C3);
    k0 = ratios[0]; h0 = ratios[1];  k1 = ratios[2];  h1 = ratios[3];


    cps[gl_InvocationID].f[4] = cps[gl_InvocationID].b[0] + (k1-k0)*C0/3.0 + 2.0*h0*H1/3.0 + h1*H0/3.0 + k0*C1;
    cps[gl_InvocationID].f[5] = cps[p1].b[3] + k1*C2 - (k1-k0)*C3/3.0 + h0*H2/3.0 + 2.0*h1*H1/3.0;


    if(quadNormals) {
        norms[gl_InvocationID].n[0] = reflect(gl_InvocationID, m1);
        norms[gl_InvocationID].n[1] = reflect(gl_InvocationID, p3);
        norms[gl_InvocationID].n[2] = reflect(gl_InvocationID, p2);
        norms[gl_InvocationID].n[3] = reflect(gl_InvocationID, p1);
    }
}
