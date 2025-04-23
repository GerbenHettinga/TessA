#version 400 core
layout(quads, fractional_odd_spacing, ccw) in;
in vec3[] tc_position;
in vec3[] tc_normal;


uniform float alpha;
uniform bool flatOnly;
uniform bool quadNormals;
uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform bool nMatrix;
uniform float pvalue;
uniform int gbcType;

struct coeff
{
    vec3 b[2];
    vec3 f[2];
};

struct normCoeff
{
    vec3 n[3];
};

in normCoeff[] norms;

in coeff cps[];

float[8] weights = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

out vec3 position;
out vec3 normal;
out float[8] outWeights;


int bVertex;
#define id1 inst + 1
#define id2 inst + 2
#define N gl_PatchVerticesIn


//linear interpolation of normals
vec3 phongInterpolate() {
    vec3 sum = vec3(0.0, 0.0, 0.0);
    for(int i = 0; i < N; i++) {
        sum += weights[i] * tc_normal[i];
    }
    return normalize(sum);
}



vec3 evaluatePatchCub() {

    float u = gl_TessCoord[0];
    float u2 = u*u;
    float u3 = u*u2;

    float v = gl_TessCoord[1];
    float v2 = v*v;
    float v3 = v*v2;

    float m1u = (1.0 - gl_TessCoord[0]);
    float m1u2 = m1u*m1u;
    float m1u3 = m1u*m1u2;

    float m1v = (1.0 - gl_TessCoord[1]);
    float m1v2 = m1v*m1v;
    float m1v3 = m1v*m1v2;

    vec3 lt = ((1.0-v)*cps[3].f[0] + u*cps[2].f[1])/(u + (1.0-v));
    vec3 lb = (u*cps[0].f[0] + v*cps[3].f[1])/(u+v);
    vec3 rt = ((1.0-u)*cps[2].f[0] + (1.0-v)*cps[1].f[1])/((1.0-u) + (1.0-v));
    vec3 rb = ((1.0-u)*cps[0].f[1] + v*cps[1].f[0])/((1.0-u) + v);

    return
    m1u3*v3*tc_position[3]      + 3.0*u*m1u2*v3*cps[3].b[0]    + 3.0*u2*m1u*v3*cps[2].b[1]     + u3*v3*tc_position[2] +
    3.0*m1u3*m1v*v2*cps[3].b[1] + 9.0*u*m1u2*m1v*v2*lt         + 9.0*u2*m1u*m1v*v2*rt          + 3.0*u3*m1v*v2*cps[2].b[0] +
    3.0*m1u3*m1v2*v*cps[0].b[0] + 9.0*u*m1u2*m1v2*v*lb         + 9.0*u2*m1u*m1v2*v*rb          + 3.0*u3*m1v2*v*cps[1].b[1] +
    m1u3*m1v3*tc_position[0]    + 3.0*u*m1u2*m1v3*cps[0].b[1]  + 3.0*u2*m1u*m1v3*cps[1].b[0]   + u3*m1v3*tc_position[1];

}



vec3 evaluateBoundaryCurve() {
    int p1 = (bVertex + 1) % 4;
    return weights[bVertex] * weights[bVertex] * weights[bVertex] * tc_position[bVertex] +
            3.0 * weights[bVertex] * weights[bVertex] * weights[p1] * cps[bVertex].b[1] +
            3.0 * weights[p1] * weights[bVertex] * weights[p1] * cps[p1].b[0] +
           weights[p1] * weights[p1] * weights[p1] * tc_position[p1];
}


vec3 pnNormal() {
    return weights[0] * weights[0] * normalize(tc_normal[0]) +
           weights[1] * weights[1] * normalize(tc_normal[1]) +
           weights[2] * weights[2] * normalize(tc_normal[2]) +
           weights[3] * weights[3] * normalize(tc_normal[3]) +

           weights[0] * weights[3] * normalize(norms[0].n[0] + norms[3].n[2]) +
           weights[0] * weights[2] * normalize(norms[0].n[1] + norms[2].n[1]) +
           weights[0] * weights[1] * normalize(norms[0].n[2] + norms[1].n[0]) +
           weights[1] * weights[3] * normalize(norms[1].n[1] + norms[3].n[1]) +
           weights[1] * weights[2] * normalize(norms[1].n[2] + norms[2].n[0]) +
           weights[2] * weights[3] * normalize(norms[2].n[2] + norms[3].n[0]);

}


void main() {
    bVertex = -1;
    //if not on boundary calculate GBCS
    //if(!boundaryConditions()) {
    if(gl_TessCoord[0] == 0.0 && gl_TessCoord[1] == 0.0) {
        position = tc_position[0];
    } else if(gl_TessCoord[0] == 1.0 && gl_TessCoord[1] == 0.0) {
        position = tc_position[1];
    } else if(gl_TessCoord[0] == 1.0 && gl_TessCoord[1] == 1.0) {
        position = tc_position[2];
    } else if(gl_TessCoord[0] == 0.0 && gl_TessCoord[1] == 1.0) {
        position = tc_position[3];
    } else {
        position = evaluatePatchCub();
    }
    //} else {
    //    position = evaluateBoundaryCurve();
    //}

    if(quadNormals) {
        normal = pnNormal();
    } else {
        normal = phongInterpolate();
    }
    
    if(nMatrix){
        normal = normalize(normal_matrix * normalize(normal));
    }

    vec3 pos = (1.0 - gl_TessCoord[0])*(1.0-gl_TessCoord[1]) * tc_position[0] +
             (gl_TessCoord[0])*(1.0-gl_TessCoord[1]) * tc_position[1] +
             gl_TessCoord[0]*gl_TessCoord[1] * tc_position[2] +
             (1.0-gl_TessCoord[0])*(gl_TessCoord[1]) * tc_position[3];


    outWeights = weights;
    position = mix(pos, position, alpha);
    gl_Position = matrix * vec4(position, 1.0);
    position = gl_Position.xyz;
}

