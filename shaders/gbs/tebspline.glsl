
layout(quads, fractional_odd_spacing, ccw) in;
in vec3[] tc_p;
in vec3[] tc_ep;
in vec3[] tc_em;
in vec3[] tc_fp;
in vec3[] tc_fm;
in vec3[] tc_n;
in vec2[] tc_uv;
in vec3[] tc_noise;

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
bool linear;
int side;


patch in int inst;

float[8] weights = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

out vec3 position;
out vec3 normal;
out vec3 outColour;
out vec2 uv;
out vec3 noiseP;
out float[8] outWeights;

vec3 du;
vec3 dv;


/*INCLUDE NOISE*/

vec2 tc_param[8] = /*PARAM FLAG*/


/*DEFINE N FLAG*/
#define id1 (inst + 1) % N
#define id2 (inst + 2) % N

#define M_PI 3.14159265358979323846264


int wrapper(int i, int n) {
    return (i + n) % n;
}

//linear interpolation of normals
vec2 phongInterpolateUV() {
    vec2 sum = vec2(0.0);
    for(int i = 0; i < N; i++) {
        sum += weights[i] * tc_uv[i];
    }
    return sum;
}


vec3 tensorCubic() {
    float u = gl_TessCoord[0];
    vec4 U = vec4((1.0 - u)*(1.0 - u)*(1.0 - u),
            3.0*(1.0-u)*(1.0-u)*u,
            3.0*(1.0-u)*u*u,
            u*u*u);

    float v = gl_TessCoord[1];
    vec4 V = vec4((1.0 - v)*(1.0 - v)*(1.0 - v),
            3.0*(1.0-v)*(1.0-v)*v,
            3.0*(1.0-v)*v*v,
            v*v*v);

    noiseP = U.x*V.w*tc_noise[3] + U.y*V.w*tc_noise[3] + U.z*V.w*tc_noise[2] + U.w*V.w*tc_noise[2] +
            U.x*V.z*tc_noise[3] + U.y*V.z*tc_noise[3] + U.z*V.z*tc_noise[2] + U.w*V.z*tc_noise[2] +
            U.x*V.y*tc_noise[0] + U.y*V.y*tc_noise[0] + U.z*V.y*tc_noise[1] + U.w*V.y*tc_noise[1] +
            U.x*V.x*tc_noise[0] + U.y*V.x*tc_noise[0] + U.z*V.x*tc_noise[1] + U.w*V.x*tc_noise[1];


    return U.x*V.w*tc_p[3] + U.y*V.w*tc_em[3] + U.z*V.w*tc_ep[2] + U.w*V.w*tc_p[2] +
            U.x*V.z*tc_ep[3] + U.y*V.z*tc_fp[3] + U.z*V.z*tc_fp[2] + U.w*V.z*tc_em[2] +
            U.x*V.y*tc_em[0] + U.y*V.y*tc_fp[0] + U.z*V.y*tc_fp[1] + U.w*V.y*tc_ep[1] +
            U.x*V.x*tc_p[0] + U.y*V.x*tc_ep[0] + U.z*V.x*tc_em[1] + U.w*V.x*tc_p[1];
}

vec3 tensorNormal() {
    float u = gl_TessCoord[0];
    vec4 U = vec4((1.0 - u)*(1.0 - u)*(1.0 - u),
            3.0*(1.0-u)*(1.0-u)*u,
            3.0*(1.0-u)*u*u,
            u*u*u);

    float v = gl_TessCoord[1];
    vec4 V = vec4((1.0 - v)*(1.0 - v)*(1.0 - v),
            3.0*(1.0-v)*(1.0-v)*v,
            3.0*(1.0-v)*v*v,
            v*v*v);

    vec4 dU = vec4(-3.0*(1.0 - u)*(1.0 - u),
                   9.0*u*u - 12.0*u + 3.0,
                   3.0*(2.0-3.0*u)*u,
                   3.0*u*u);

    vec4 dV = vec4(-3.0*(1.0 - v)*(1.0 - v),
                   9.0*v*v - 12.0*v + 3.0,
                   3.0*(2.0-3.0*v)*v,
                   3.0*v*v);



    vec3 du = dU.x*V.w*tc_p[3] + dU.y*V.w*tc_em[3] + dU.z*V.w*tc_ep[2] + dU.w*V.w*tc_p[2] +
            dU.x*V.z*tc_ep[3] + dU.y*V.z*tc_fp[3] + dU.z*V.z*tc_fp[2] + dU.w*V.z*tc_em[2] +
            dU.x*V.y*tc_em[0] + dU.y*V.y*tc_fp[0] + dU.z*V.y*tc_fp[1] + dU.w*V.y*tc_ep[1] +
            dU.x*V.x*tc_p[0] + dU.y*V.x*tc_ep[0] + dU.z*V.x*tc_em[1] + dU.w*V.x*tc_p[1];

    vec3 dv = U.x*dV.w*tc_p[3] + U.y*dV.w*tc_em[3] + U.z*dV.w*tc_ep[2] + U.w*dV.w*tc_p[2] +
            U.x*dV.z*tc_ep[3] + U.y*dV.z*tc_fp[3] + U.z*dV.z*tc_fp[2] + U.w*dV.z*tc_em[2] +
            U.x*dV.y*tc_em[0] + U.y*dV.y*tc_fp[0] + U.z*dV.y*tc_fp[1] + U.w*dV.y*tc_ep[1] +
            U.x*dV.x*tc_p[0] + U.y*dV.x*tc_ep[0] + U.z*dV.x*tc_em[1] + U.w*dV.x*tc_p[1];

    return cross(du, dv);
}




void main() {
    vec3 pos = vec3(0.0);
    vec2 paramPos;
    bool bConditions;


    weights[0] = (1.0 - gl_TessCoord[0])*(1.0-gl_TessCoord[1]);
    weights[1] = gl_TessCoord[0]*(1.0-gl_TessCoord[1]);
    weights[2] = gl_TessCoord[0]*gl_TessCoord[1];
    weights[3] = (1.0-gl_TessCoord[0])*gl_TessCoord[1];

    position = tensorCubic();
    normal = tensorNormal();
    uv = phongInterpolateUV();


    /*vec4 NN = pNoiseWorley(uv , noiseP.x*2.0);
    noise = NN.x;**/



    float noise, noiseU, noiseV;
    if(noiseType == 1) {
        vec4 NN = pNoiseWorley(uv*vec2(baseNoiseFrequencyU, baseNoiseFrequencyV), noiseP.x);
        //vec4 NNU = pNoiseWorley((uv + vec2(0.02, 0.0))*baseNoiseFrequency, noiseP.x);
        //vec4 NNV = pNoiseWorley((uv + vec2(0.0, 0.02))*baseNoiseFrequency, noiseP.x);
        noise = noiseToScalar(NN);
        //noiseU = noiseToScalar(NNU);
        //noiseV = noiseToScalar(NNV);
    } else {
        noise = pNoisePerlin(uv*vec2(baseNoiseFrequencyU, baseNoiseFrequencyV), noiseP.x);
        //noiseU = pNoisePerlin((uv + vec2(0.02, 0.0))*baseNoiseFrequency, noiseP.x);
        //noiseV = pNoisePerlin((uv + vec2(0.0, 0.02))*baseNoiseFrequency, noiseP.x);
    }

    vec3 pos2 = position;

    vec3 posU, posV;

    position = position - normal*noise*noiseP.y + 0.5*normal;
    posU = position + 0.02 * du + normal*noiseU*noiseP.y;
    posV = position + 0.02 * dv + normal*noiseV*noiseP.y;

    //normal = cross(normalize(posU-position), normalize(posV-position));

    if(nMatrix){
        normal = normalize(normal_matrix * normalize(normal));
    }

    bool outL = false;
    for(int i = 0; i < N; i++) {
        pos = weights[i] * tc_p[i];
        outL = outL || (weights[i] < 0.0001);
    }

    outWeights = weights;
    position = mix(pos2, position, alpha);

    outColour = vec3((N % 3)/8.0 + 0.5, (N % 2)/8.0 + 0.5, (N % 5)/8.0 + 0.5);

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

