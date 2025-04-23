#version 400 core
layout(quads, fractional_odd_spacing, ccw) in;
in vec3[] te_b0;
in vec3[] te_b1;
in vec3[] te_b2;

in vec3[] te_b3;
in vec3[] te_b4;
in vec3[] te_b5;

in vec3[] te_b6;
in vec3[] te_b7;
in vec3[] te_b8;

uniform float alpha;
uniform bool flatOnly;
uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform bool quadNormals;
uniform bool nMatrix;
uniform float pvalue;
uniform bool captureGeometry;
uniform int gbcType;
uniform int triangulation;
uniform bool outline;

out vec3 position;
out vec3 normal;
out vec3 outColour;
out float[8] outWeights;

vec3 evalCubic(float u, float v) {
    vec3 p = vec3(0.0);

    float a_u = (1.0 - u)*(1.0 - u)*(1.0 - u)*(1.0 - u) / 24.0;
    float b_u = (-4.0*u*u*u*u + 12.0*u*u*u - 6.0*u*u - 12.0*u + 11.0) / 24.0;
    float c_u = (6.0*u*u*u*u - 12.0*u*u*u - 6.0*u*u + 12.0*u + 11.0) / 24.0;
    float d_u = (-4.0*u*u*u*u + 4.0*u*u*u + 6.0*u*u + 4.0*u + 1.0) / 24.0;
    float e_u = u*u*u*u / 24.0;

    float a_v = (1.0 - v)*(1.0 - v)*(1.0 - v)*(1.0 - v) / 24.0;
    float b_v = (-4.0*v*v*v*v + 12.0*v*v*v - 6.0*v*v - 12.0*v + 11.0) / 24.0;
    float c_v = (6.0*v*v*v*v - 12.0*v*v*v - 6.0*v*v + 12.0*v + 11.0) / 24.0;
    float d_v = (-4.0*v*v*v*v + 4.0*v*v*v + 6.0*v*v + 4.0*v + 1.0) / 24.0;
    float e_v = v*v*v*v / 24.0;

    p = e_v * (a_u * te_b0[3] + b_u * te_b3[3] + c_u * te_b2[2] + d_u * te_b1[2] + e_u * te_b0[2]) +
        d_v * (a_u * te_b1[3] + b_u * te_b4[3] + c_u * te_b5[2] + d_u * te_b4[2] + e_u * te_b3[2]) +
        c_v * (a_u * te_b6[0] + b_u * te_b7[0] + c_u * te_b8[0] + d_u * te_b5[1] + e_u * te_b2[1]) +
        b_v * (a_u * te_b3[0] + b_u * te_b4[0] + c_u * te_b5[0] + d_u * te_b4[1] + e_u * te_b1[1]) +
        a_v * (a_u * te_b0[0] + b_u * te_b1[0] + c_u * te_b2[0] + d_u * te_b3[1] + e_u * te_b0[1]);

    return p;
}

vec3 evalDerivativeU(float u, float v) {
    float a_u = -(1.0 - u)*(1.0 - u)*(1.0 - u) / 6.0;
    float b_u = (-4.0*u*u*u + 9.0*u*u - 3.0*u - 3.0) / 6.0;
    float c_u = (2.0*u*u*u - 3.0*u*u - u + 1.0) / 2.0;
    float d_u = (-4.0*u*u*u + 3.0*u*u + 3.0*u + 1.0) / 6.0;
    float e_u = u*u*u / 6.0;

    float a_v = (1.0 - v)*(1.0 - v)*(1.0 - v)*(1.0 - v) / 24.0;
    float b_v = (-4.0*v*v*v*v + 12.0*v*v*v - 6.0*v*v - 12.0*v + 11.0) / 24.0;
    float c_v = (6.0*v*v*v*v - 12.0*v*v*v - 6.0*v*v + 12.0*v + 11.0) / 24.0;
    float d_v = (-4.0*v*v*v*v + 4.0*v*v*v + 6.0*v*v + 4.0*v + 1.0) / 24.0;
    float e_v = v*v*v*v / 24.0;

    return e_v * (a_u * te_b0[3] + b_u * te_b3[3] + c_u * te_b2[2] + d_u * te_b1[2] + e_u * te_b0[2]) +
        d_v * (a_u * te_b1[3] + b_u * te_b4[3] + c_u * te_b5[2] + d_u * te_b4[2] + e_u * te_b3[2]) +
        c_v * (a_u * te_b6[0] + b_u * te_b7[0] + c_u * te_b8[0] + d_u * te_b5[1] + e_u * te_b2[1]) +
        b_v * (a_u * te_b3[0] + b_u * te_b4[0] + c_u * te_b5[0] + d_u * te_b4[1] + e_u * te_b1[1]) +
        a_v * (a_u * te_b0[0] + b_u * te_b1[0] + c_u * te_b2[0] + d_u * te_b3[1] + e_u * te_b0[1]);

}


vec3 evalDerivativeV(float u, float v) {
    float a_u = (1.0 - u)*(1.0 - u)*(1.0 - u)*(1.0 - u) / 24.0;
    float b_u = (-4.0*u*u*u*u + 12.0*u*u*u - 6.0*u*u - 12.0*u + 11.0) / 24.0;
    float c_u = (6.0*u*u*u*u - 12.0*u*u*u - 6.0*u*u + 12.0*u + 11.0) / 24.0;
    float d_u = (-4.0*u*u*u*u + 4.0*u*u*u + 6.0*u*u + 4.0*u + 1.0) / 24.0;
    float e_u = u*u*u*u / 24.0;

    float a_v = -(1.0 - v)*(1.0 - v)*(1.0 - v) / 6.0;
    float b_v = (-4.0*v*v*v + 9.0*v*v - 3.0*v - 3.0) / 6.0;
    float c_v = (2.0*v*v*v - 3.0*v*v - v + 1.0) / 2.0;
    float d_v = (-4.0*v*v*v + 3.0*v*v + 3.0*v + 1.0) / 6.0;
    float e_v = v*v*v / 6.0;

    return e_v * (a_u * te_b0[3] + b_u * te_b3[3] + c_u * te_b2[2] + d_u * te_b1[2] + e_u * te_b0[2]) +
        d_v * (a_u * te_b1[3] + b_u * te_b4[3] + c_u * te_b5[2] + d_u * te_b4[2] + e_u * te_b3[2]) +
        c_v * (a_u * te_b6[0] + b_u * te_b7[0] + c_u * te_b8[0] + d_u * te_b5[1] + e_u * te_b2[1]) +
        b_v * (a_u * te_b3[0] + b_u * te_b4[0] + c_u * te_b5[0] + d_u * te_b4[1] + e_u * te_b1[1]) +
        a_v * (a_u * te_b0[0] + b_u * te_b1[0] + c_u * te_b2[0] + d_u * te_b3[1] + e_u * te_b0[1]);

}

vec3 evalNormal(float u, float v) {
    return normalize(cross(normalize(evalDerivativeU(u,v)), normalize(evalDerivativeV(u,v))));
}

void main() {
    vec3 pos = vec3(0.0);
    vec2 paramPos;
    bool bConditions;

    float u = gl_TessCoord[0];
    float v = gl_TessCoord[1];

    position = evalCubic(u, v);
    normal = evalNormal(u, v);

    if(nMatrix){
        normal = normalize(normal_matrix * normalize(normal));
    }

    outWeights[0] = (1.0-u)*(1.0-v);
    outWeights[1] = u*(1.0-v);
    outWeights[2] = u*v;
    outWeights[3] = (1.0-u)*v;

    bool outL = false;
    for(int i = 0; i < 4; i++) {
        outL = outL || (outWeights[i] < 0.0001);
    }

    pos = (1.0-u)*(1.0-v) * te_b0[0] +
          u*(1.0-v)       * te_b0[1] +
          u*v             * te_b0[2] +
          (1.0-u)*v       * te_b0[3];



    position = mix(pos, position, alpha);

    outColour = vec3((4 % 3)/8.0 + 0.5, (4 % 2)/8.0 + 0.5, (4 % 5)/8.0 + 0.5);

    if(outline && outL) {
        outColour = vec3(0.0);
    }

    if(captureGeometry) {
        gl_Position = vec4(position, 1.0);
    } else {
        gl_Position = matrix * vec4(position, 1.0);
    }
    position = gl_Position.xyz;
}

