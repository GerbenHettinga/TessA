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


float[8] weights = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

out vec3 position;
out vec3 normal;
out float[8] outWeights;

#define id1 1
#define id2 2
#define N gl_PatchVerticesIn

//linear interpolation of normals
vec3 phongInterpolate() {
    vec3 n = gl_TessCoord[0] * tc_normal[0] + gl_TessCoord[1] * tc_normal[1] + gl_TessCoord[2] * tc_normal[2];
    return normalize(n);
}

vec3 evaluatePatchQuad() {
        return gl_TessCoord[0] * gl_TessCoord[0] * tc_position[0] +
               gl_TessCoord[1] * gl_TessCoord[1] * tc_position[1] +
               gl_TessCoord[2] * gl_TessCoord[2] * tc_position[2] +
               gl_TessCoord[0] * gl_TessCoord[2] * (edges[0].b[0] + edges[2].b[1]) +
               gl_TessCoord[1] * gl_TessCoord[2] * (edges[1].b[1] + edges[2].b[0]) +
               gl_TessCoord[0] * gl_TessCoord[1] * (edges[0].b[1] + edges[1].b[0]);

}

vec3 project(vec3 n, vec3 vertex, vec3 p) {
    return p - dot((p-vertex), n) * n;
}


vec3 evaluatePatchQuad2() {
    float uv = (gl_TessCoord[0] + gl_TessCoord[1])/(gl_TessCoord[0] + gl_TessCoord[1]);
    float vw = (gl_TessCoord[1] + gl_TessCoord[2])/(gl_TessCoord[1] + gl_TessCoord[2]);
    float wu = (gl_TessCoord[2] + gl_TessCoord[0])/(gl_TessCoord[2] + gl_TessCoord[0]);

    vec3 puv = mix(tc_position[0], tc_position[1], uv);
    vec3 nuv = mix(tc_normal[0], tc_normal[1], uv);

    vec3 pvw = mix(tc_position[1], tc_position[2], vw);
    vec3 nvw = mix(tc_normal[1], tc_normal[2], vw);


    vec3 pwu = mix(tc_position[2], tc_position[0], wu);
    vec3 nwu = mix(tc_normal[2], tc_normal[0], wu);

    vec3 p = gl_TessCoord[0] * tc_position[0] +
            gl_TessCoord[1] * tc_position[1] +
            gl_TessCoord[2] * tc_position[2];


    return gl_TessCoord[0] * project(nuv, puv, p) +
           gl_TessCoord[1] * project(nvw, pvw, p) +
           gl_TessCoord[2] * project(nwu, pwu, p);
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
    vec3 pos = gl_TessCoord[0] * tc_position[0] + gl_TessCoord[1] * tc_position[1] + gl_TessCoord[2] * tc_position[2];

    weights[0] = gl_TessCoord[0];
    weights[1] = gl_TessCoord[1];
    weights[2] = gl_TessCoord[2];

    position = evaluatePatchQuad();


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

