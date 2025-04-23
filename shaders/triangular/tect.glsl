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

struct microTriangle
{
    vec3 T[2];
    vec3 I[2];
    vec3 F[2];
    vec3 L[2];
    vec3 C;
};

patch in vec3 S;
patch in int inst;

struct normCoeff
{
    vec3 n[2];
};

in microTriangle mt[];
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


vec3 evaluatePatch(bool bounds) {

    vec3 tc = gl_TessCoord;

    vec3 b111;
    vec3 b210, b120;
    vec3 b102, b201;
    vec3 b021, b012;
    vec3 b300, b030, b003;


//    float blxz = tc.z * tc.x;
//    float blyz = tc.z * tc.y;
//    float blxy = tc.x * tc.y;
//    float blyx = tc.x * tc.y;

//    float blxz = tc.z;
//    float blyz = tc.z;
//    float blxy = tc.y;
//    float blyx = tc.x;

//    float blxz = (1.0 - tc.x) * tc.x;
//    float blxy = (1.0 - tc.z) * tc.x;
//    float blyz = (1.0 - tc.x) * tc.y;
//    float blyx = (1.0 - tc.z) * tc.y;

//    float blxy = (1.0 - tc.y) * tc.x;
//    float blxz = (1.0 - tc.z) * tc.x;
//    float blyx = (1.0 - tc.x) * tc.y;
//    float blyz = (1.0 - tc.z) * tc.y;


    float blyz = (1.0 - tc.z) * tc.y;
    float blzy = (1.0 - tc.y) * tc.z;
    float blxz = (1.0 - tc.z) * tc.x;
    float blzx = (1.0 - tc.x) * tc.z;

    //b201 and b021 have to be blended
    if(inst == 0) {
        b300 = tc_position[0];
        b030 = tc_position[1];
        b003 = S;

        b111 = mt[0].C;

        b210 = mt[0].T[1];

        //b201 = mt[0].I[0];
        //b201 = mt[0].L[1];
        //b201 = (bzx1 * mt[0].L[1] + bzx2 * mt[0].I[0])/(bzx1 + bzx2);
        if(bounds) {
            b201 = mt[0].I[0];
            b021 = mt[1].I[0];
        } else {
            b201 = (blyz * mt[0].L[1] + blzy * mt[0].I[0])/(blzy + blyz);
            b021 = (blxz * mt[1].L[0] + blzx * mt[1].I[0])/(blxz + blzx);

        }

        //b021 = mt[1].I[0];
        //b021 = mt[1].L[0];
        //b021 = (bzy1 * mt[1].L[0] + bzy2 * mt[1].I[0])/(bzy2 + bzy1);


        b120 = mt[1].T[0];

        b102 = mt[0].I[1];
        b012 = mt[1].I[1];

    } else if(inst == 1) {
        b300 = tc_position[1];
        b030 = tc_position[2];
        b003 = S;

        b111 = mt[1].C;

        b210 = mt[1].T[1];

        if(bounds) {
            b201 = mt[1].I[0];
            b021 = mt[2].I[0];
        //b201 = mt[1].L[1];
        //b201 = (bzx1 * mt[1].L[1] + bzx2 * mt[1].I[0])/(bzx1 + bzx2);
        } else {
            b201 = (blyz * mt[1].L[1] + blzy * mt[1].I[0])/(blzy + blyz);
            b021 = (blxz * mt[2].L[0] + blzx * mt[2].I[0])/(blxz + blzx);
        }
        //
        //b021 = mt[2].L[0];




        b120 = mt[2].T[0];

        b102 = mt[1].I[1];
        b012 = mt[2].I[1];
    } else {
        b300 = tc_position[2];
        b030 = tc_position[0];
        b003 = S;

        b111 = mt[2].C;

        b210 = mt[2].T[1];

        if(bounds) {
            b201 = mt[2].I[0];
            b021 = mt[0].I[0];
        //b201 = mt[2].L[1];
        } else {
            b201 = (blyz * mt[2].L[1] + blzy * mt[2].I[0])/(blyz + blzy);
            b021 = (blxz * mt[0].L[0] + blzx * mt[0].I[0])/(blxz + blzx);
        }

        //b021 = mt[0].I[0];
        //b021 = mt[0].L[0];


        b120 = mt[0].T[0];

        b102 = mt[2].I[1];
        b012 = mt[0].I[1];
    }


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

bool boundConds() {
    return (gl_TessCoord[0] == 0 || gl_TessCoord[1] == 0 || gl_TessCoord[2] == 0);
}


void main() {
    vec3 pos = gl_TessCoord[0] * tc_position[0] + gl_TessCoord[1] * tc_position[1] + gl_TessCoord[2] * tc_position[2];

    weights[0] = gl_TessCoord[0];
    weights[1] = gl_TessCoord[1];
    weights[2] = gl_TessCoord[2];



    position = evaluatePatch(boundConds());
    //position = evaluatePatch(true);


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

