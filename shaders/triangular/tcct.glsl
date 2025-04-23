#version 400 core
in vec3[] position;
in vec3[] normal;
flat in int[] instance;

uniform float tessInnerLevel;
uniform float tessOuterLevel;

uniform bool quadNormals;
uniform float p;

layout(vertices = 3) out;
out vec3[] tc_position;
out vec3[] tc_normal;

struct microTriangle
{
    vec3 T[2];
    vec3 I[2];
    vec3 F[2];
    vec3 L[2];
    vec3 C;
};

patch out vec3 S;
patch out int inst;

struct normCoeff
{
    vec3 n[2];
};

out microTriangle[] mt;
out normCoeff[] norms;

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
    tc_normal[gl_InvocationID] = normalize(normal[gl_InvocationID]);

    int m1 = wrapper(gl_InvocationID - 1, 3);
    int p1 = wrapper(gl_InvocationID + 1, 3);

    mt[gl_InvocationID].T[0] = (2.0 * position[gl_InvocationID] + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[m1]))/3.0;
    mt[gl_InvocationID].T[1] = (2.0 * position[gl_InvocationID] + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p1]))/3.0;
    mt[gl_InvocationID].I[0] = (mt[gl_InvocationID].T[0] + mt[gl_InvocationID].T[1] + position[gl_InvocationID])/3.0;

    vec3 edgeVec0 = -cross(normalize(normal[gl_InvocationID]), normalize(mt[gl_InvocationID].T[0] - position[gl_InvocationID]));
    vec3 edgeVec1 = -cross(normalize(mt[gl_InvocationID].T[1] - position[gl_InvocationID]), normalize(normal[gl_InvocationID]));

    float rat0 = length(mt[gl_InvocationID].T[0] - position[gl_InvocationID]);
    float rat1 = length(mt[gl_InvocationID].T[1] - position[gl_InvocationID]);


    mt[gl_InvocationID].L[0] = (mt[gl_InvocationID].T[0] + position[gl_InvocationID])*0.5 + edgeVec0 * tan(p) * rat0;
    mt[gl_InvocationID].L[1] = (mt[gl_InvocationID].T[1] + position[gl_InvocationID])*0.5 + edgeVec1 * tan(p) * rat1;

    barrier();

    //vec3 contrPolyCentre1 = (mt[gl_InvocationID].T[0] + mt[m1].T[1])*0.5;
    vec3 contrPolyCentre2 = (mt[gl_InvocationID].T[1] + mt[p1].T[0])*0.5;

    barrier();

    //vec3 cbt = normalize(mt[gl_InvocationID].F[1] + mt[p1].F[0]);
    //vec3 avgNormal = normalize(normal[gl_InvocationID] + normal[p1]);
    //vec3 pnNormal = reflect(gl_InvocationID, p1) + reflect(p1, gl_InvocationID);
    //vec3 cbt = -cross(e4, pnNormal);

    vec3 H0 = normalize(mt[gl_InvocationID].T[1] - position[gl_InvocationID]);
    vec3 H2 = normalize(position[p1] - mt[p1].T[0]);

    vec3 C0 = -cross(H0, normalize(normal[gl_InvocationID]));
    vec3 C1 = -cross(H2, normalize(normal[p1]));

    vec3 cbt = (C0 + C1)*0.5;

    mt[gl_InvocationID].C = contrPolyCentre2 + cbt * tan(p) * length(mt[p1].T[0] - mt[gl_InvocationID].T[1]);

    barrier();

    mt[gl_InvocationID].I[1] = (mt[gl_InvocationID].C + mt[m1].C + mt[gl_InvocationID].I[0])/3.0;

    barrier();

    if(gl_InvocationID == 0) {
        S = (mt[0].I[1] + mt[1].I[1] + mt[2].I[1])/3.0;
    }

    if(quadNormals) {
        norms[gl_InvocationID].n[0] = reflect(gl_InvocationID, m1);
        norms[gl_InvocationID].n[1] = reflect(gl_InvocationID, p1);
    }
}
