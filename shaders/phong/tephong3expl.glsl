#version 400 core
layout(triangles, fractional_odd_spacing, ccw) in;
in vec3[] tc_position;
in vec3[] tc_normal;


uniform float alpha;
uniform bool flatOnly;
uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform bool nMatrix;
uniform float pvalue;
uniform int gbcType;

struct edgeCoeff
{
    vec3 b;
};

in edgeCoeff edges[];

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

vec3 evaluatePatchQuad() {
        return gl_TessCoord[0] * gl_TessCoord[0] * tc_position[0] +
               gl_TessCoord[1] * gl_TessCoord[1] * tc_position[1] +
               gl_TessCoord[2] * gl_TessCoord[2] * tc_position[2] +
               gl_TessCoord[0] * gl_TessCoord[1] * edges[0].b +
               gl_TessCoord[1] * gl_TessCoord[2] * edges[1].b +
               gl_TessCoord[2] * gl_TessCoord[0] * edges[2].b;
}

void main() {
    vec3 pos;
    vec2 paramPos;

    weights[0] = gl_TessCoord[0];
    weights[1] = gl_TessCoord[1];
    weights[2] = gl_TessCoord[2];

    position = evaluatePatchQuad();


    normal = phongInterpolate();
    
    if(nMatrix){
        normal = normalize(normal_matrix * normalize(normal));
    }

    outWeights = weights;
    //position = mix(pos, position, alpha);
    gl_Position = matrix * vec4(position, 1.0);
    position = gl_Position.xyz;
}

