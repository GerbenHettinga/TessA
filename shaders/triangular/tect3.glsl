#version 400 core
layout(triangles, fractional_odd_spacing, ccw) in;
in vec3[] tc_position;
in vec3[] tc_normal;

uniform float alpha;
uniform bool flatOnly;
uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform bool nMatrix;

struct microTriangle
{
    vec3 T[2];
    vec3 I[2];
    vec3 J[2];
    vec3 K[2];
    vec3 C[3];
};

in microTriangle mt[];
in vec3[] P;
in vec3[] R;
in vec3[] S;
patch in int inst;

float[8] weights = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

out vec3 position;
out vec3 normal;
out float[8] outWeights;


#define id1 1
#define id2 2
#define N gl_PatchVerticesIn

//linear interpolation of normals
vec3 phongInterpolate() {
    vec3 avg = normalize(tc_normal[0] + tc_normal[1] + tc_normal[2]);
    vec3 n;
    if(inst == 0) {
        n = gl_TessCoord[0] * tc_normal[0]
                + gl_TessCoord[1] * tc_normal[1]
                + gl_TessCoord[2] * avg;
    } else if(inst == 1) {
        n = gl_TessCoord[0] * tc_normal[1]
                + gl_TessCoord[1] * tc_normal[2]
                + gl_TessCoord[2] * avg;
    } else {
        n = gl_TessCoord[0] * tc_normal[2]
                + gl_TessCoord[1] * tc_normal[0]
                + gl_TessCoord[2] * avg;
    }
    return normalize(n);
}

vec3 evaluatePatch() {
    vec3 tc = gl_TessCoord;

    vec3 UVW;
    vec3 b300, b030, b003;
    vec3 b111;
    vec3 b210, b201, b120, b021, b102, b012;

    vec3 split = vec3(1.0, 1.0, 1.0)/3.0;

    if(inst == 0) {
        UVW = tc.x * vec3(1.0, 0.0, 0.0) + tc.y * vec3(0.0, 1.0, 0.0) + tc.z * split;
        //UVW = vec3(1.0, 0.0, 0.0);

        b300 = tc_position[0];
        b030 = tc_position[1];
        b003 = UVW.x * S[0] + UVW.y * S[1] +  UVW.z * S[2];

        b201 = UVW.x * mt[0].I[0] + UVW.y * mt[1].K[0] + UVW.z * mt[2].J[0];
        b021 = UVW.x * mt[0].J[0] + UVW.y * mt[1].I[0] + UVW.z * mt[2].K[0];

//        b201 = mt[0].I[0];
//        b021 = mt[1].I[0];

//        b210 = (UVW.x + UVW.y) * mt[0].T[1] + UVW.z * P[2];
//        b120 = (UVW.x + UVW.y) * mt[1].T[0] + UVW.z * R[2];
        b210 = mt[0].T[1];
        b120 = mt[1].T[0];

        b102 = UVW.x * mt[0].I[1] + UVW.y * mt[1].K[1] + UVW.z * mt[2].J[1];
        b012 = UVW.x * mt[0].J[1] + UVW.y * mt[1].I[1] + UVW.z * mt[2].K[1];

        b111 = UVW.x * mt[0].C[0] + UVW.y * mt[1].C[2] + UVW.z * mt[2].C[1];
        //b111 = mt[0].C[0];

    } else if(inst == 1) {
        UVW  = tc.x * vec3(0.0, 1.0, 0.0) + tc.y * vec3(0.0, 0.0, 1.0) + tc.z * split;
        //UVW = vec3(1.0, 0.0, 0.0);

        b300 = tc_position[1];
        b030 = tc_position[2];
        b003 = UVW.x * S[0] + UVW.y * S[1] +  UVW.z * S[2];

        b201 = UVW.x * mt[0].J[0] + UVW.y * mt[1].I[0] + UVW.z * mt[2].K[0];
        b021 = UVW.x * mt[0].K[0] + UVW.y * mt[1].J[0] + UVW.z * mt[2].I[0];

//        b210 = (UVW.y + UVW.z) * mt[1].T[1] + UVW.x * P[0];
//        b120 = (UVW.y + UVW.z) * mt[2].T[0] + UVW.x * R[0];

//        b201 = mt[1].I[0];
//        b021 = mt[2].I[0];

        b210 = mt[1].T[1];
        b120 = mt[2].T[0];

        b102 = UVW.x * mt[0].J[1] + UVW.y * mt[1].I[1] + UVW.z * mt[2].K[1];
        b012 = UVW.x * mt[0].K[1] + UVW.y * mt[1].J[1] + UVW.z * mt[2].I[1];

        b111 = UVW.x * mt[0].C[1] + UVW.y * mt[1].C[0] + UVW.z * mt[2].C[2];
        //b111 = mt[0].C[1];
    } else {
        UVW = tc.x * vec3(0.0, 0.0, 1.0) + tc.y * vec3(1.0, 0.0, 0.0) + tc.z * split;
        //UVW = vec3(1.0, 0.0, 0.0);

        b300 = tc_position[2];
        b030 = tc_position[0];
        b003 = UVW.x * S[0] + UVW.y * S[1] + UVW.z * S[2];

        b201 = UVW.x * mt[0].K[0] + UVW.y * mt[1].J[0] + UVW.z * mt[2].I[0];
        b021 = UVW.x * mt[0].I[0] + UVW.y * mt[1].K[0] + UVW.z * mt[2].J[0];

//        b201 = mt[2].I[0];
//        b021 = mt[0].I[0];

//        b210 = (UVW.x + UVW.z) * mt[2].T[1] + UVW.y * P[1];
//        b120 = (UVW.x + UVW.z) * mt[0].T[0] + UVW.y * R[1];

        b210 = mt[2].T[1];
        b120 = mt[0].T[0];

        b102 = UVW.x * mt[0].K[1] + UVW.y * mt[1].J[1] + UVW.z * mt[2].I[1];
        b012 = UVW.x * mt[0].I[1] + UVW.y * mt[1].K[1] + UVW.z * mt[2].J[1];

        b111 = UVW.x * mt[0].C[2] + UVW.y * mt[1].C[1] + UVW.z * mt[2].C[0];
        //b111 = mt[0].C[2];
    }

    weights[0] = UVW.x;
    weights[1] = UVW.y;
    weights[2] = UVW.z;

    vec3 du = 3.0*tc.x*tc.x*(b300 - b201) + 3.0*tc.z*tc.z*(b102 - b003) + 3.0*tc.y*tc.y*(b120 - b021) +
            6.0*tc.x*tc.y*(b210 - b111) + 6.0*tc.x*tc.z*(b201 - b102) + 6.0*tc.y*tc.z*(b111 - b012);

    vec3 dv = 3.0*tc.y*tc.y*(b030 - b021) + 3.0*tc.z*tc.z*(b012 - b003) + 3.0*tc.x*tc.x*(b210 - b201) +
            6.0*tc.y*tc.z*(b021 - b012) + 6.0*tc.x*tc.z*(b111 - b102) + 6.0*tc.x*tc.y*(b120 - b111);

    normal = normalize(cross(du, dv));

    vec3 sqd = tc*tc;
    return sqd[0] * tc.x * b300 +
           sqd[1] * tc.y * b030 +
           sqd[2] * tc.z * b003 +

           3.0 * sqd[0] * tc.z * b201 +
           3.0 * sqd[0] * tc.y * b210 +

           3.0 * sqd[1] * tc.x * b120 +
           3.0 * sqd[1] * tc.z * b021 +

           3.0 * sqd[2] * tc.y * b012 +
           3.0 * sqd[2] * tc.x * b102 +

           6.0 * tc.x * tc.y * tc.z * b111;
    //return tc.x * b300 + tc.y * b030 + tc.z * b003;
}

void main() {
    vec3 pos;

    vec3 S = (tc_position[0] + tc_position[1] + tc_position[2])/3.0;

    if (inst == 0) {
        pos = gl_TessCoord[0] * tc_position[0] + gl_TessCoord[1] * tc_position[1] + gl_TessCoord[2] * S;
    } else if(inst == 1) {
        pos = gl_TessCoord[0] * tc_position[1] + gl_TessCoord[1] * tc_position[2] + gl_TessCoord[2] * S;
    } else {
        pos = gl_TessCoord[0] * tc_position[2] + gl_TessCoord[1] * tc_position[0] + gl_TessCoord[2] * S;
    }

    position = evaluatePatch();

    pos = weights[0] *  tc_position[0] +  weights[1] *  tc_position[1] +  weights[2] *  tc_position[2];

    //normal = phongInterpolate();

    
    if(nMatrix) {
        normal = normalize(normal_matrix * normalize(normal));
    }

    outWeights = weights;
    position = mix(pos, position, alpha);
    gl_Position = matrix * vec4(position, 1.0);
    position = gl_Position.xyz;
}

