#version 400 core
layout(triangles, fractional_odd_spacing, ccw) in;
in vec3[] tc_position;
in vec3[] tc_normal;

uniform float alpha;
uniform bool flatOnly;
uniform bool quadNormals;
uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform bool nMatrix;
uniform int mtIndex;

struct microTriangle
{
    vec3 T[2];
    vec3 E[3];
    vec3 I[2];
    vec3 F[2];
    vec3 C;
};

patch in vec3 S;
patch in int inst;

struct normCoeff
{
    vec3 n[2];
};

in microTriangle[] mt;
in normCoeff norms[];

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

    vec3 b211, b121, b112;
    vec3 b310, b130, b220;
    vec3 b103, b301, b202;
    vec3 b031, b013, b022;
    vec3 b400, b040, b004;
    vec3 b210, b120, b102, b012;

    //b201 and b021 have to be blended
    if(inst == 0) {
        b400 = tc_position[0];
        b040 = tc_position[1];
        b004 = S;

        b112 = mt[0].C;
        b211 = mt[0].F[0];
        b121 = mt[0].F[1];

        b310 = mt[0].E[0];
        b220 = mt[0].E[1];
        b130 = mt[0].E[2];

        b102 = mt[0].I[0];
        b012 = mt[1].I[0];

        b210 = mt[0].T[1];
        b120 = mt[1].T[0];

        b031 = 0.25 * tc_position[1] +  0.75 * mt[1].I[0];
        b022 = 0.5 * mt[1].I[0] + 0.5 * mt[1].I[1];
        b013 = 0.75 * mt[1].I[1] + 0.25 * S;

        b301 = 0.25 * tc_position[0] +  0.75 * mt[0].I[0];
        b202 = 0.5 * mt[0].I[0] + 0.5 * mt[0].I[1];
        b103 = 0.75 * mt[0].I[1] + 0.25 * S;
    } else if(inst == 1) {
        b400 = tc_position[1];
        b040 = tc_position[2];
        b004 = S;

        b112 = mt[1].C;
        b211 = mt[1].F[0];
        b121 = mt[1].F[1];

        b310 = mt[1].E[0];
        b220 = mt[1].E[1];
        b130 = mt[1].E[2];

        b102 = mt[1].I[0];
        b012 = mt[2].I[0];

        b210 = mt[1].T[1];
        b120 = mt[2].T[0];

        b031 = 0.25 * tc_position[2] +  0.75 * mt[2].I[0];
        b022 = 0.5 * mt[2].I[0] + 0.5 * mt[2].I[1];
        b013 = 0.75 * mt[2].I[1] + 0.25 * S;

        b301 = 0.25 * tc_position[1] +  0.75 * mt[1].I[0];
        b202 = 0.5 * mt[1].I[0] + 0.5 * mt[1].I[1];
        b103 = 0.75 * mt[1].I[1] + 0.25 * S;
    } else {
        b400 = tc_position[2];
        b040 = tc_position[0];
        b004 = S;

        b112 = mt[2].C;
        b211 = mt[2].F[0];
        b121 = mt[2].F[1];

        b310 = mt[2].E[0];
        b220 = mt[2].E[1];
        b130 = mt[2].E[2];

        b102 = mt[2].I[0];
        b012 = mt[0].I[0];

        b210 = mt[2].T[1];
        b120 = mt[0].T[0];

        b031 = 0.25 * tc_position[0] +  0.75 * mt[0].I[0];
        b022 = 0.5 * mt[0].I[0] + 0.5 * mt[0].I[1];
        b013 = 0.75 * mt[0].I[1] + 0.25 * S;

        b301 = 0.25 * tc_position[2] +  0.75 * mt[2].I[0];
        b202 = 0.5 * mt[2].I[0] + 0.5 * mt[2].I[1];
        b103 = 0.75 * mt[2].I[1] + 0.25 * S;
    }


    vec3 sqd = tc*tc;
    vec3 cubd = sqd*tc;
    return cubd[0] * tc.x * b400 +
           cubd[1] * tc.y * b040 +
           cubd[2] * tc.z * b004 +

           4.0 * cubd[0] * tc.z * b301 +
           4.0 * cubd[0] * tc.y * b310 +

           4.0 * cubd[1] * tc.x * b130 +
           4.0 * cubd[1] * tc.z * b031 +

           4.0 * cubd[2] * tc.y * b013 +
           4.0 * cubd[2] * tc.x * b103 +

           6.0 * sqd[0] * sqd[1] * b220 +
           6.0 * sqd[0] * sqd[2] * b202 +
           6.0 * sqd[1] * sqd[2] * b022 +

           12.0 * sqd[0] * tc.y * tc.z * b211 +
           12.0 * tc.x * sqd[1] * tc.z * b121 +
           12.0 * tc.x * tc.y * sqd[2] * b112;
}


vec3 pnNormal() {
    return gl_TessCoord[0] * gl_TessCoord[0] * normalize(tc_normal[0]) +
           gl_TessCoord[1] * gl_TessCoord[1] * normalize(tc_normal[1]) +
           gl_TessCoord[2] * gl_TessCoord[2] * normalize(tc_normal[2]) +
           gl_TessCoord[0] * gl_TessCoord[2] * norms[0].n[0] +
           gl_TessCoord[0] * gl_TessCoord[1] * norms[0].n[1] +

           gl_TessCoord[1] * gl_TessCoord[0] * norms[1].n[0] +
           gl_TessCoord[1] * gl_TessCoord[2] * norms[1].n[1] +

           gl_TessCoord[2] * gl_TessCoord[1] * norms[2].n[0] +
           gl_TessCoord[2] * gl_TessCoord[0] * norms[2].n[1];
}

void main() {
    vec3 pos;


    if (inst == 0) {
        pos = gl_TessCoord[0] * tc_position[0] + gl_TessCoord[1] * tc_position[1] + gl_TessCoord[2] * S;
    } else if(inst == 1) {
        pos = gl_TessCoord[0] * tc_position[1] + gl_TessCoord[1] * tc_position[2] + gl_TessCoord[2] * S;
    } else {
        pos = gl_TessCoord[0] * tc_position[2] + gl_TessCoord[1] * tc_position[0] + gl_TessCoord[2] * S;
    }


    weights[0] = gl_TessCoord[0];
    weights[1] = gl_TessCoord[1];
    weights[2] = gl_TessCoord[2];

    position = evaluatePatch();

    if(quadNormals) {
        normal = pnNormal();
    } else {
        normal = phongInterpolate();
    }
    
    if(nMatrix) {
        normal = normalize(normal_matrix * normalize(normal));
    }

    outWeights = weights;
    position = mix(pos, position, alpha);
    gl_Position = matrix * vec4(position, 1.0);
    position = gl_Position.xyz;
}

