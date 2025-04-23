#version 400 core
layout(quads, fractional_odd_spacing, ccw) in;
in vec3[] te_p;
in vec3[] te_ep;
in vec3[] te_em;
in vec3[] te_fp;

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

    float a_u = (1.0-u)*(1.0-u)*(1.0-u)/6.0;
    float b_u = (4.0 - 6.0*u*u + 3.0*u*u*u)/6.0;
    float c_u = (1.0 + 3.0*u + 3.0*u*u - 3.0*u*u*u)/6.0;
    float d_u = (u*u*u)/6.0;

    float a_v = (1.0-v)*(1.0-v)*(1.0-v)/6.0;
    float b_v = (4.0 - 6.0*v*v + 3.0*v*v*v)/6.0;
    float c_v = (1.0 + 3.0*v + 3.0*v*v - 3.0*v*v*v)/6.0;
    float d_v = (v*v*v)/6.0;


    p = d_u * (a_v * te_p[1] + b_v * te_ep[1] + c_v * te_em[2] + d_v * te_p[2]) +
           c_u * (a_v * te_em[1] + b_v * te_fp[1] + c_v * te_fp[2] + d_v * te_ep[2]) +
           b_u * (a_v * te_ep[0] + b_v * te_fp[0] + c_v * te_fp[3] + d_v * te_em[3]) +
           a_u * (a_v * te_p[0] + b_v * te_em[0] + c_v * te_ep[3] + d_v * te_p[3]);

    return p;
}

vec3 evalCubicBezier(float u, float v) {
    vec3 p = vec3(0.0);

    float a_u = (1.0-u)*(1.0-u)*(1.0-u);
    float b_u = 3.0*(1.0 - u)*(1.0 - u)*u;
    float c_u = 3.0*(1.0 - u)*u*u;
    float d_u = u*u*u;

    float a_v = (1.0-v)*(1.0-v)*(1.0-v);
    float b_v = 3.0*(1.0 - v)*(1.0 - v)*v;
    float c_v = 3.0*(1.0 - v)*v*v;
    float d_v = (v*v*v);

    p = d_u * (a_v * te_p[1] + b_v * te_ep[1] + c_v * te_em[2] + d_v * te_p[2]) +
           c_u * (a_v * te_em[1] + b_v * te_fp[1] + c_v * te_fp[2] + d_v * te_ep[2]) +
           b_u * (a_v * te_ep[0] + b_v * te_fp[0] + c_v * te_fp[3] + d_v * te_em[3]) +
           a_u * (a_v * te_p[0] + b_v * te_em[0] + c_v * te_ep[3] + d_v * te_p[3]);

    return p;
}

vec3 evalDerivativeU(float u, float v) {
    float a_du = -0.5*(1.0-u)*(1.0-u);
    float b_du = 0.5*u*(3.0*u-4.0);
    float c_du = 0.5 + u - 1.5*u*u;
    float d_du = (u*u)*0.5;

    float a_v = (1.0-v)*(1.0-v)*(1.0-v)/6.0;
    float b_v = (4.0 - 6.0*v*v + 3.0*v*v*v)/6.0;
    float c_v = (1.0 + 3.0*v + 3.0*v*v - 3.0*v*v*v)/6.0;
    float d_v = (v*v*v)/6.0;

    return d_du * (a_v * te_p[1] + b_v * te_ep[1] + c_v * te_em[2] + d_v * te_p[2]) +
           c_du * (a_v * te_em[1] + b_v * te_fp[1] + c_v * te_fp[2] + d_v * te_ep[2]) +
           b_du * (a_v * te_ep[0] + b_v * te_fp[0] + c_v * te_fp[3] + d_v * te_em[3]) +
           a_du * (a_v * te_p[0] + b_v * te_em[0] + c_v * te_ep[3] + d_v * te_p[3]);
}

vec3 evalDerivativeUBezier(float u, float v) {
    float a_du = -3.0*(1.0 - u)*(1.0 - u);
    float b_du = 3.0*(1.0 - u)*(1.0 - u) - 6.0*(1.0-u)*u;
    float c_du = -3.0*u*u + 6.0*(1.0-u)*u;
    float d_du = 3*u*u;

    float a_v = (1.0-v)*(1.0-v)*(1.0-v);
    float b_v = 3.0*(1.0 - v)*(1.0 - v)*v;
    float c_v = 3.0*(1.0 - v)*v*v;
    float d_v = (v*v*v);

    return d_du * (a_v * te_p[1] + b_v * te_ep[1] + c_v * te_em[2] + d_v * te_p[2]) +
           c_du * (a_v * te_em[1] + b_v * te_fp[1] + c_v * te_fp[2] + d_v * te_ep[2]) +
           b_du * (a_v * te_ep[0] + b_v * te_fp[0] + c_v * te_fp[3] + d_v * te_em[3]) +
           a_du * (a_v * te_p[0] + b_v * te_em[0] + c_v * te_ep[3] + d_v * te_p[3]);
}

vec3 evalDerivativeV(float u, float v) {
    float a_dv = -0.5*(1.0-v)*(1.0-v);
    float b_dv = 0.5*v*(3.0*v-4.0);
    float c_dv = 0.5 + v - (3.0*v*v)/2.0;
    float d_dv = (v*v)*0.5;

    float a_u = (1.0-u)*(1.0-u)*(1.0-u)/6.0;
    float b_u = (4.0 - 6.0*u*u + 3.0*u*u*u)/6.0;
    float c_u = (1.0 + 3.0*u + 3.0*u*u - 3.0*u*u*u)/6.0;
    float d_u = (u*u*u)/6.0;


    return d_u * (a_dv * te_p[1] + b_dv * te_ep[1] + c_dv * te_em[2] + d_dv * te_p[2]) +
           c_u * (a_dv * te_em[1] + b_dv * te_fp[1] + c_dv * te_fp[2] + d_dv * te_ep[2]) +
           b_u * (a_dv * te_ep[0] + b_dv * te_fp[0] + c_dv * te_fp[3] + d_dv * te_em[3]) +
           a_u * (a_dv * te_p[0] + b_dv * te_em[0] + c_dv * te_ep[3] + d_dv * te_p[3]);
}

vec3 evalDerivativeVBezier(float u, float v) {
    float a_dv = -3.0*(1.0 - v)*(1.0 - v);
    float b_dv = 3.0*(1.0 - v)*(1.0 - v) - 6.0*(1.0-v)*v;
    float c_dv = -3.0*v*v + 6.0*(1.0-v)*v;
    float d_dv = 3*v*v;

    float a_u = (1.0-u)*(1.0-u)*(1.0-u);
    float b_u = 3.0*(1.0 - u)*(1.0 - u)*u;
    float c_u = 3.0*(1.0 - u)*u*u;
    float d_u = u*u*u;


    return d_u * (a_dv * te_p[1] + b_dv * te_ep[1] + c_dv * te_em[2] + d_dv * te_p[2]) +
           c_u * (a_dv * te_em[1] + b_dv * te_fp[1] + c_dv * te_fp[2] + d_dv * te_ep[2]) +
           b_u * (a_dv * te_ep[0] + b_dv * te_fp[0] + c_dv * te_fp[3] + d_dv * te_em[3]) +
           a_u * (a_dv * te_p[0] + b_dv * te_em[0] + c_dv * te_ep[3] + d_dv * te_p[3]);
}

vec3 evalNormal(float u, float v) {
    return normalize(cross(evalDerivativeUBezier(u,v), evalDerivativeVBezier(u,v)));
}

void main() {
    vec3 pos = vec3(0.0);
    vec2 paramPos;
    bool bConditions;

    float u = gl_TessCoord[0];
    float v = gl_TessCoord[1];

    position = evalCubicBezier(u, v);
    normal = evalNormal(u, v);

    if(nMatrix){
        normal = normalize(normal_matrix * normalize(normal));
    }

    outWeights[0] = (1.0-u)*(1.0-v);
    outWeights[1] = u*(1.0-v);
    outWeights[2] = u*v;
    outWeights[3] = (1.0-u)*v;
    outWeights[4] = u;
    outWeights[5] = v;
    outWeights[6] = v;
    outWeights[7] = u;


    bool outL = false;
    for(int i = 0; i < 4; i++) {
        outL = outL || (outWeights[i] < 0.0001);
    }

    pos = (1.0-u)*(1.0-v) * te_fp[0] +
          u*(1.0-v)       * te_fp[1] +
          u*v             * te_fp[2] +
          (1.0-u)*v       * te_fp[3];


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

