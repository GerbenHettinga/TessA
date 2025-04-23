#version 400 core
in vec3[] position;
in vec3[] normal;
flat in int[] instance;

uniform float tessInnerLevel;
uniform float tessOuterLevel;

uniform float p;

layout(vertices = 3) out;
out vec3[] tc_position;
out vec3[] tc_normal;
patch out int inst;

struct microTriangle
{
    vec3 T[2];
    vec3 I[2];
    vec3 J[2];
    vec3 K[2];
    vec3 C[3];
};

out microTriangle[] mt;
out vec3[] P;
out vec3[] R;
out vec3[] S;


vec3 project(vec3 n, vec3 vertex, vec3 pos) {
    return pos - dot((pos-vertex), n) * n;
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

    int m1 = wrapper(gl_InvocationID - 1, 3);
    int p1 = wrapper(gl_InvocationID + 1, 3);

    mt[gl_InvocationID].T[0] = ((1.0 - p) * position[gl_InvocationID] + p*project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[m1]));
    mt[gl_InvocationID].T[1] = ((1.0 - p) * position[gl_InvocationID] + p*project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p1]));
    mt[gl_InvocationID].I[0] = (mt[gl_InvocationID].T[0] + mt[gl_InvocationID].T[1] + position[gl_InvocationID])/3.0;

    barrier();

    //construct local coordinate system
    vec3 A0 = mt[gl_InvocationID].T[0] - position[gl_InvocationID];
    vec3 A0hat = normalize(A0);
    vec3 C0 = -cross(normalize(normal[gl_InvocationID]), A0hat);

    vec3 B0 = mt[gl_InvocationID].T[1] - position[gl_InvocationID];
    vec3 B0hat = normalize(B0);
    vec3 D0 = -cross(normalize(normal[gl_InvocationID]), B0hat);


    float a0, b0, c0, d0;

    //find 2D coordinates of B0 in system A0xC0
    vec3 B0prime = dot(A0hat, B0) * A0hat;
    a0 = dot(A0hat, normalize(B0prime)) * length(B0prime);
    c0 = dot(C0, normalize(B0-B0prime)) * length(B0 - B0prime);

    //find 2D coordinates of A0 in system B0xD0
    vec3 A0prime = dot(B0hat, A0) * B0hat;
    b0 = dot(B0hat, normalize(A0prime)) * length(A0prime);
    d0 = dot(D0, normalize(A0-A0prime)) * length(A0 - A0prime);

    // on the J side
    vec3 F0 = position[p1] - mt[p1].T[0];
    vec3 F0hat = normalize(F0);
    vec3 G0 = -cross(normalize(normal[p1]), F0hat);

    P[gl_InvocationID] = mt[p1].T[0] + (b0 * F0hat + d0 * G0) * length(F0)/length(B0);

    //on the K side
    vec3 F1 = position[m1] - mt[m1].T[1];
    vec3 F1hat = normalize(F1);
    vec3 G1 = -cross(normalize(normal[m1]), F1hat);

    R[gl_InvocationID] = mt[m1].T[1] + (a0 * F1hat + c0 * G1) * length(F1)/length(A0);

    mt[gl_InvocationID].J[0] = (P[gl_InvocationID] + mt[p1].T[0] + position[p1])/3.0;
    mt[gl_InvocationID].K[0] = (mt[m1].T[1] + R[gl_InvocationID] + position[m1])/3.0;

    vec3 iN2 = normalize(normal[m1] + normal[gl_InvocationID]);
    vec3 iN0 = normalize(normal[p1] + normal[gl_InvocationID]);
    vec3 iN1 = normalize(normal[m1] + normal[p1]);

    vec3 E0 = mt[p1].T[0] - mt[gl_InvocationID].T[1];
    vec3 E0hat = normalize(E0);
    vec3 cbt0 = -cross(iN0, E0hat);

    vec3 E2 = mt[m1].T[1] - mt[gl_InvocationID].T[0];
    vec3 E2hat = normalize(E2);
    vec3 cbt2 = -cross(iN2, E2hat);

    vec3 E1 = R[gl_InvocationID] - P[gl_InvocationID];
    vec3 E1hat = normalize(E1);
    vec3 cbt1 = -cross(iN1, E1hat);

    vec3 auxC0 = mt[gl_InvocationID].T[1] + (b0 * E0hat + d0 * cbt0) * length(E0)/length(B0);
    vec3 auxC2 = mt[gl_InvocationID].T[0] + (a0 * E2hat + c0 * cbt2) * length(E2)/length(A0);
    vec3 auxC1 = P[gl_InvocationID] + (b0 * E1hat + d0 * cbt1) * length(E1)/length(B0);


    mt[gl_InvocationID].C[2] = (mt[gl_InvocationID].T[0] + mt[m1].T[1] + auxC2)/3.0;
    mt[gl_InvocationID].C[0] = (mt[gl_InvocationID].T[1] + mt[p1].T[0] + auxC0)/3.0;

    barrier();
    //mt[gl_InvocationID].C[1] = (P[gl_InvocationID] + R[gl_InvocationID] + auxC1)/3.0;
    mt[gl_InvocationID].C[1] = (mt[p1].C[0] + mt[m1].C[2])/2.0;
//    mt[gl_InvocationID].C[2] = (2.0 * mt[gl_InvocationID].T[0] + 2.0 * mt[m1].T[1] + auxC2)/5.0;
//    mt[gl_InvocationID].C[0] = (2.0 * mt[gl_InvocationID].T[1] + 2.0 * mt[p1].T[0] + auxC0)/5.0;
//    mt[gl_InvocationID].C[1] = (2.0 * P[gl_InvocationID] + 2.0 * R[gl_InvocationID] + auxC1)/5.0;


    mt[gl_InvocationID].I[1] = (mt[gl_InvocationID].C[2] + mt[gl_InvocationID].C[0] + mt[gl_InvocationID].I[0])/3.0;

    mt[gl_InvocationID].J[1] = (mt[gl_InvocationID].C[0] + mt[gl_InvocationID].C[1] + mt[gl_InvocationID].J[0])/3.0;

    mt[gl_InvocationID].K[1] = (mt[gl_InvocationID].C[1] + mt[gl_InvocationID].C[2] + mt[gl_InvocationID].K[0])/3.0;


    S[gl_InvocationID] = (mt[gl_InvocationID].I[1] + mt[gl_InvocationID].J[1] + mt[gl_InvocationID].K[1])/3.0;
    //S[gl_InvocationID] = (tc_position[0] + tc_position[1] + tc_position[2])/3.0;

}
