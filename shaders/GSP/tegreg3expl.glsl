#version 400 core
layout(triangles, fractional_odd_spacing, ccw) in;
in vec3[] tc_position;
in vec3[] tc_normal;

uniform float alpha;
uniform bool flatOnly;
uniform bool quadNormals;
uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform bool captureGeometry;
uniform bool nMatrix;
uniform bool outline;
uniform int mtIndex;
patch in int inst;

struct microTriangle
{
    vec3 T[2];
    vec3 F[2];
};

struct normCoeff
{
    vec3 n[2];
};

in microTriangle mt[];
in normCoeff norms[];

float[8] weights = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

out vec3 position;
out vec3 normal;
out vec3 outColour;
out float[8] outWeights;

#define id1 1
#define id2 2
#define N gl_PatchVerticesIn

//linear interpolation of normals
vec3 phongInterpolate() {
    vec3 n = gl_TessCoord[0] * tc_normal[0] + gl_TessCoord[1] * tc_normal[1] + gl_TessCoord[2] * tc_normal[2];
    return normalize(n);
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


vec3 evaluateGregoryPatch() {
    vec3 tc = gl_TessCoord;

    vec3 b211, b121, b112;

    float blyz = (1.0 - tc.z) * tc.y;
    float blzy = (1.0 - tc.y) * tc.z;
    float blxz = (1.0 - tc.z) * tc.x;
    float blzx = (1.0 - tc.x) * tc.z;
    float blxy = (1.0 - tc.y) * tc.x;
    float blyx = (1.0 - tc.x) * tc.y;

    vec3 sqd = tc*tc;
    vec3 cubd = sqd*tc;

    b211 = (blyz * mt[0].F[0] + blzy * mt[2].F[1])/(blyz + blzy);
    b121 = (blzx * mt[1].F[0] + blxz * mt[0].F[1])/(blzx + blxz);
    b112 = (blxy * mt[2].F[0] + blyx * mt[1].F[1])/(blyx + blxy);

    return cubd[0] * tc.x * tc_position[0] +
            cubd[1] * tc.y * tc_position[1] +
            cubd[2] * tc.z * tc_position[2] +

            cubd[0] * tc.z * (3.0 * mt[0].T[0] + tc_position[0]) +
            cubd[0] * tc.y * (3.0 * mt[0].T[1] + tc_position[0]) +

            cubd[1] * tc.x * (3.0 * mt[1].T[0] + tc_position[1]) +
            cubd[1] * tc.z * (3.0 * mt[1].T[1] + tc_position[1]) +

            cubd[2] * tc.y * (3.0 * mt[2].T[0] + tc_position[2]) +
            cubd[2] * tc.x * (3.0 * mt[2].T[1] + tc_position[2]) +

            3.0 * sqd[0] * sqd[1] * (mt[0].T[1] + mt[1].T[0]) +
            3.0 * sqd[0] * sqd[2] * (mt[0].T[0] + mt[2].T[1]) +
            3.0 * sqd[1] * sqd[2] * (mt[2].T[0] + mt[1].T[1]) +

            12.0 * sqd[0] * tc.y * tc.z * b211 +
            12.0 * tc.x * sqd[1] * tc.z * b121 +
            12.0 * tc.x * tc.y * sqd[2] * b112;
}

void main() {
    vec3 pos = gl_TessCoord[0] * tc_position[0] + gl_TessCoord[1] * tc_position[1] + gl_TessCoord[2] * tc_position[2];

    weights[0] = gl_TessCoord[0];
    weights[1] = gl_TessCoord[1];
    weights[2] = gl_TessCoord[2];


    if((gl_TessCoord[0] != 1.0) && (gl_TessCoord[1] != 1.0) && (gl_TessCoord[2] != 1.0)) {
        position = evaluateGregoryPatch();
    } else {
        position = pos;
    }


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

    outColour = vec3((3 % 3)/8.0 + 0.5, (3 % 2)/8.0 + 0.5, (3 % 5)/8.0 + 0.5);
    if(outline && (weights[0] < 0.0001 || weights[1] < 0.0001 || weights[2] < 0.0001)) {
        outColour = vec3(0.0);
    }

    if(captureGeometry) {
        gl_Position = vec4(position, 1.0);
    } else {
        gl_Position = matrix * vec4(position, 1.0);
    }
    position = gl_Position.xyz;
}

