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
uniform float pvalue;
uniform int gbcType;


struct edgeCoeff
{
    vec3 b[2];
};

struct normCoeff
{
    vec3 n[2];
};

in edgeCoeff edges[];
in normCoeff norms[];

patch in vec3 m;

float[8] weights = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

out vec3 position;
out vec3 normal;
out float[8] outWeights;

#define id1 1
#define id2 2
#define N gl_PatchVerticesIn

//linear interpolation of normals
vec3 phongInterpolate() {
    vec3 sum = vec3(0.0, 0.0, 0.0);
    for(int i = 0; i < N; i++) {
        sum += gl_TessCoord[i] * tc_normal[i];
    }
    return normalize(sum);
}


vec3 evaluatePatchCub() {
    vec3 sqd = gl_TessCoord*gl_TessCoord;

        return sqd[0] * gl_TessCoord[0] * tc_position[0] +
               sqd[1] * gl_TessCoord[1] * tc_position[1] +
               sqd[2] * gl_TessCoord[2] * tc_position[2] +

               sqd[0] * gl_TessCoord[2] * edges[0].b[0] +
               sqd[0] * gl_TessCoord[1] * edges[0].b[1] +

               sqd[1] * gl_TessCoord[0] * edges[1].b[0] +
               sqd[1] * gl_TessCoord[2] * edges[1].b[1] +

               sqd[2] * gl_TessCoord[1] * edges[2].b[0] +
               sqd[2] * gl_TessCoord[0] * edges[2].b[1] +

               6.0 * gl_TessCoord[0] * gl_TessCoord[1] * gl_TessCoord[2] * m;
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
    vec2 paramPos;

    weights[0] = gl_TessCoord[0];
    weights[1] = gl_TessCoord[1];
    weights[2] = gl_TessCoord[2];


    position = evaluatePatchCub();


    if(quadNormals) {
        normal = pnNormal();
    } else {
        normal = phongInterpolate();
    }
    
    if(nMatrix){
        normal = normalize(normal_matrix * normalize(normal));
    }

    outWeights = weights;
    //position = mix(pos, position, alpha);
    gl_Position = matrix * vec4(position, 1.0);
    position = gl_Position.xyz;
}

