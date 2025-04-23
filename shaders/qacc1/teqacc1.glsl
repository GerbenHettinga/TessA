#version 400 core
layout(quads, fractional_odd_spacing, ccw) in;
in vec3[] te_p;
in vec3[] te_ep;
in vec3[] te_m;


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

vec3 eval(float u, float v) {
    vec3 p = vec3(0.0);

    float a_u = (1.0 - u)*(1.0 - u) / 2.0;
    float b_u = (-2.0*u*u + 2.0*u + 1.0) / 2.0;
    float c_u = (u*u) / 2.0;

    float a_v = (1.0 - v)*(1.0 - v) / 2.0;
    float b_v = (-2.0*v*v + 2.0*v + 1.0) / 2.0;
    float c_v = (v*v) / 2.0;

    p = c_v * (a_u * te_p[3] + b_u * te_ep[2] + c_u * te_p[2]  ) +
        b_v * (a_u * te_ep[3] + b_u * te_m[0] + c_u * te_ep[1] ) +
        a_v * (a_u * te_p[0] + b_u * te_ep[0] + c_u * te_p[1]  );

    return p;
}

vec3 evalDerivativeU(float u, float v) {
    float a_u = (1.0-u);
    float b_u = u;

    float a_v = (1.0 - v)*(1.0 - v) / 2.0;
    float b_v = (-2.0*v*v + 2.0*v + 1.0) / 2.0;
    float c_v = (v*v) / 2.0;

    //return vec3(1.0, 0.0 ,0.0);
    return  c_v * (a_u * (te_ep[2] - te_p[3]) + b_u * (te_p[2] - te_ep[2]) ) +
            b_v * (a_u * (te_m[0] - te_ep[3]) + b_u * (te_ep[1] - te_m[0]) ) +
            a_v * (a_u * (te_ep[0] - te_p[0]) + b_u * (te_p[1] - te_ep[0]) );
}


vec3 evalDerivativeV(float u, float v) {
    float a_v = (1.0-v);
    float b_v = v;

    float a_u = (1.0 - u)*(1.0 - u) / 2.0;
    float b_u = (-2.0*u*u + 2.0*u + 1.0) / 2.0;
    float c_u = (u*u) / 2.0;

    //return vec3(1.0, 0.0 ,0.0);
    return  c_u * (a_v * (te_ep[1] - te_p[1]) + b_v * (te_p[2] - te_ep[1]) ) +
            b_u * (a_v * (te_m[0] - te_ep[0]) + b_v * (te_ep[2] - te_m[0]) ) +
            a_u * (a_v * (te_ep[3] - te_p[0]) + b_v * (te_p[3] - te_ep[3]) );
}

vec3 evalNormal(float u, float v) {
    return normalize(cross(evalDerivativeU(u,v), evalDerivativeV(u,v)));
}

void main() {
    vec3 pos = vec3(0.0);
    vec2 paramPos;
    bool bConditions;

    float u = gl_TessCoord[0];
    float v = gl_TessCoord[1];

    position = eval(u, v);
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

    pos = (1.0-u)*(1.0-v) * te_p[0] +
          u*(1.0-v)       * te_p[1] +
          u*v             * te_p[2] +
          (1.0-u)*v       * te_p[3];

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

