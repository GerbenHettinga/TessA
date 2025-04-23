#version 400 core
layout(quads, fractional_odd_spacing, ccw) in;
in vec3[] tc_p;
in vec3[] tc_n;

uniform float alpha;
uniform bool flatOnly;
uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform bool quadNormals;
uniform bool nMatrix;
uniform bool captureGeometry;
uniform int gbcType;
uniform int triangulation;
uniform bool outline;
uniform bool spokes;
uniform bool WD;

uniform bool centreFunctions;

uniform float pvalue;
uniform float qvalue;

uniform float rvalue;
uniform float svalue;

bool linear;
int side;

struct Jet {
    vec3 b[4];
};

in Jet J[];

patch in int inst;

float[8] weights = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

out vec3 position;
out vec3 normal;
out vec3 outColour;
out float[8] outWeights;
out float weightSum;


/*PARAM FLAG*/


/*DEFINE N FLAG*/
#define id1 ((inst + 1) % N)
#define id2 ((inst + 2) % N)
#define id3 ((inst + 3) % N)


int wrapper(int i, int n) {
    return (i + n) % n;
}


float signedTriangleArea(vec2 v1, vec2 v2, vec2 v3) {
    float det = v2.x*v3.y + v3.x*v1.y + v1.x*v2.y - v2.x*v1.y - v1.x*v3.y - v3.x*v2.y;
    return det;
}

//linear interpolation of normals
vec3 phongInterpolate() {
    vec3 sum = vec3(0.0, 0.0, 0.0);
    for(int i = 0; i < N; i++) {
        sum += weights[i] * tc_n[i];
    }
    return normalize(sum);
}

void wachspress(vec2 p) {
    float sumweights = 0.0;
    float A_i, A_iplus1;
    A_iplus1 = signedTriangleArea(tc_param[N-1], tc_param[0], p);
    for(int i = 0; i < N; i++) {
        A_i = A_iplus1;
        A_iplus1 = signedTriangleArea(tc_param[i], tc_param[(i+1) % N], p);
        weights[i] = 1.0/(A_i*A_iplus1);
        sumweights += weights[i];
    }
    float recp = 1.0/sumweights;
    for(int i = 0; i < N; i++) {
        weights[i] *= recp;
    }
}

float G_0(float u) {
    return (1.0 - u)*(1.0 - u);
}

float G_1(float u) {
    return 2.0*(1.0 - u)*u;
}

float G_2(float u) {
    return u*u;
}


float D_0(float u) {
    float B0 = 0.0;
    if(u < 1.0) {
        B0 = (1.0 - u)*(1.0 - u) / 2.0;
    }
    return B0;
}

float D_0_2(float u) {
    float B0 = 0.0;
    if(u < 1.0) {
        B0 = 0.5 * (1.0 - u)*(1.0 - u)*(1.0 - u) +
             3.0*(1.0/6.0)*(1.0 - u)*(1.0 - u)*u +
             3.0*svalue*(1.0-u)*u*u +
             rvalue*u*u*u;
    } else {
        float v = (u - 1.0);
        B0 = rvalue*(1.0-v)*(1.0-v)*(1.0-v) +
             3.0*(2.0*rvalue - svalue)*(1.0-v)*(1.0-v)*v;
    }
    return B0;
}

float D_1(float u) {
    float B1 = 0.0;
    if(u < 1.0) {
        B1 = (-2.0*u*u + 2.0*u + 1.0) / 2.0;
    } else {
        float v = u - 1.0;
        B1 = (1.0 - v)*(1.0 - v) / 2.0;
    }
    return B1;
}

float D_1_2(float u) {
    float B1 = 0.0;
    if(u < 1) {
        B1 = 0.5 * (1.0 - u)*(1.0 - u)*(1.0 - u) +
             3.0 * (5.0/6.0) * (1.0-u)*(1.0-u)*u +
             3.0 * qvalue*(1.0-u)*u*u +
             pvalue * u*u*u;
    } else {
        float v = u - 1.0;
        B1 = pvalue *(1.0-v)*(1.0-v)*(1.0-v) +
             3.0*(2.0*pvalue - qvalue)*(1.0-v)*(1.0-v)*v;
    }

    return B1;
}

float B_0(float u) {
    return (1.0 - u)*(1.0 - u) / 2.0;
}

float B_1(float u) {
    return (-2.0*u*u + 2.0*u + 1.0) / 2.0;
}

float B_2(float u) {
    return (u*u)/2.0;
}


float mu(float a, float b) {
    float bb = b*b;
    return bb / (a*a + bb);
}

float qu(float a, float b, float c) {
    float cc = c*c;
    float bb = b*b;
    float aa = a*a;

    float L = bb / (aa + bb);
    float R = cc / (aa + cc);

    return L*R;
}


vec3 tensorQuadratic() {
    vec3 sum = vec3(0.0);
    vec3 sidesum;

    float[8] hi;
    float[8] si;

    for(int i = 0; i < N; i++) {
        int m1 = wrapper(i - 1, N);
        int p1 = (i + 1) % N;
        si[i] = weights[i] / (weights[m1] + weights[i]);
        hi[i] = 1.0 - weights[m1] - weights[i];
    }

    weightSum = 0.0;
    float centr = 1.0;
    vec3 centrPoint = vec3(0.0);
    vec3 centrFlat = vec3(0.0);
    float sideWeights = 0.0;

    for(int i = 0; i < N; i++) {
        int m1 = wrapper(i - 1, N);
        int p1 = (i + 1) % N;

        float s, h;

        h = hi[i]*2.0;

        float D0 = D_0(h);
        float D1 = D_1(h);

        float D0_2;
        float D1_2;
        if(centreFunctions) {
            D0_2 = D_0_2(h);
            D1_2 = D_1_2(h);
        } else {
            D0_2 = D0;
            D1_2 = D1;
        }

        float DS = D0 + D1;
        float DS2 = D0_2 + D1_2;

        float muvu = mu(hi[i], hi[m1]);
        float muv1u = mu(hi[i], hi[p1]);

        if(si[i] <= 0.5) {
            s = si[i] * 2.0;

            float B0 = B_0(s);
            float B1 = B_1(s);
            float B2 = B_2(s);

            sidesum =
            muvu *          B0 * (D0_2 * J[m1].b[0]   + D1_2 * J[m1].b[2] ) +
            muvu *          B1 * (D0_2 * J[m1].b[1]   + D1_2 * J[m1].b[3] ) +
            muv1u *         B2 * (D0_2 * J[i].b[2]    + D1_2 * J[i].b[3] );

            weightSum +=
            muvu * B0 * DS2 +
            muvu * B1 * DS2 +
            muv1u * B2 * DS2;

        } else {
            s =  si[i]*2.0 - 1.0;

            float B0 = B_0(s);
            float B1 = B_1(s);
            float B2 = B_2(s);

            sidesum =
            muvu *          B0 * (D0_2 * J[m1].b[1]   + D1_2 * J[m1].b[3] ) +
            muv1u *         B1 * (D0_2 * J[i].b[2]    + D1_2 * J[i].b[3] ) +
            muv1u *         B2 * (D0_2 * J[i].b[0]    + D1_2 * J[i].b[1] );

            weightSum +=
            muvu * B0 * DS2 +
            muv1u * B1 * DS2 +
            muv1u * B2 * DS2;
        }

        centrPoint += J[i].b[3];
        centrFlat += J[i].b[0];
        sum += sidesum;
    }

    if(!WD) {
        sum /= weightSum;
    } else {
        centrPoint /= float(N);
        centrFlat /= float(N);

        vec3 CC = centrPoint + pvalue * (centrPoint - centrFlat);

        sum = sum + CC * (1.0 - weightSum);
    }


    return sum;
}

vec3 cubicBoundary() {
    int p1 = wrapper(side + 1 , N);
    vec3 pos;
    float t = weights[side];

    if(weights[side] > 0.5) {
        t = 1.0 - t;
        t = t * 2.0;

        float B00 = B_0(t);
        float B10 = B_1(t);
        float B20 = B_2(t);

        pos = B00 * (J[side].b[0] + J[side].b[2])*0.5 +
              B10 * (J[side].b[1] + J[side].b[3])*0.5 +
              B20 * (J[p1].b[2] + J[p1].b[3] )*0.5;
    } else {
        t = 1.0 - t;
        t = t * 2.0 - 1.0;

        float B00 = B_0(t);
        float B10 = B_1(t);
        float B20 = B_2(t);

        pos = B00*(J[side].b[1] + J[side].b[3])*0.5 +
              B10*(J[p1].b[2] + J[p1].b[3])*0.5 +
              B20*(J[p1].b[0] + J[p1].b[1])*0.5;
    }
    return pos;
}



bool boundaryConditionsPie2(float u, float v) {
    if(u == 0.0) {
        if(v == 1.0) {
            linear = true;
            side = id2;
            weights[id2] = 0.5;
            weights[id3] = 0.5;
            return true;
        }
    } else if(u == 1.0) {
        if(v == 0.0) {
            linear = true;
            side = id1;
            weights[id1] = 0.5;
            weights[id2] = 0.5;
            return true;
        } else if(v == 1.0) {
            side = id2;
            weights[id2] = 1.0;
            return true;
        } else {
            linear = true;
            side = id1;
            weights[id1] = (1.0 - (0.5 + v*0.5));
            weights[id2] = 0.5 + v*0.5;
            return true;
        }
    } else if(v == 1.0) {
        linear = true;
        side = id2;
        weights[id3] = (1.0 - (0.5 + u * 0.5));
        weights[id2] = 0.5 + u * 0.5;
        return true;
    }

    return false;
}

vec2 calcParamPos(float u, float v) {
    return u * (1.0 - v) * 0.5*(tc_param[id1] + tc_param[id2])
         + u * v * tc_param[id2]
         + (1.0 - u) * v * 0.5*(tc_param[id3] + tc_param[id2]);
}

void main() {
    vec3 pos = vec3(0.0);
    bool bConditions;
    side = 0;

    vec2 paramPos = calcParamPos(gl_TessCoord[0], gl_TessCoord[1]);
    if(!boundaryConditionsPie2(gl_TessCoord[0], gl_TessCoord[1])) {
        wachspress(paramPos);
        position = tensorQuadratic();
    } else {
        position = cubicBoundary();
    }

    float flip = 1.0;

    float U = gl_TessCoord[0] + 0.00125;
    float V = gl_TessCoord[1];
    if((gl_TessCoord[0] + 0.00125) > 1.0) {
        flip *= -1.0;
        U = gl_TessCoord[0] - 0.00125;
        V = gl_TessCoord[1];
    }

    vec2 parPos2 = calcParamPos(U, V);
    vec3 pos2;
    if(!boundaryConditionsPie2(U, V)) {
        wachspress(parPos2);
        pos2 = tensorQuadratic();
    } else {
        pos2 = cubicBoundary();
    }

    U = gl_TessCoord[0];
    V = gl_TessCoord[1] + 0.00125;
    if((gl_TessCoord[1] + 0.00125) > 1.0) {
        flip *= -1.0;
        V = gl_TessCoord[1] - 0.00125;
        U = gl_TessCoord[0];
    }

    vec2 parPos3 = calcParamPos(U, V);
    vec3 pos3;
    if(!boundaryConditionsPie2(U, V)) {
        wachspress(parPos3);
        pos3 = tensorQuadratic();
    } else {
        pos3 = cubicBoundary();
    }

    //compute normal from approximation of gradients
    normal = normalize(flip*cross(normalize(pos2 - position), normalize(pos3 - position)));

    if(nMatrix){
        normal = normalize(normal_matrix * normal);
    }

    //compute linear interpolation of normal
    for(int i = 0; i < N; i++) {
        pos += weights[i] * tc_p[i];
    }

    pos = gl_TessCoord[0] * tc_p[0];
    pos += gl_TessCoord[1] * tc_p[1];
    pos += gl_TessCoord[2] * tc_p[2];

    bool outL = false;
    outL = outL || (gl_TessCoord[1] > 0.99);
    outL = outL || (gl_TessCoord[0] > 0.99);
    if(spokes) {
        outL = outL || (gl_TessCoord[0] < 0.01);
        outL = outL || (gl_TessCoord[1] < 0.01);
    }


    outWeights = weights;
    position = mix(pos, position, alpha);

    outColour = vec3((N % 3)/8.0 + 0.5, (N % 2)/8.0 + 0.5, (N % 5)/8.0 + 0.5);

    if((outline || spokes) && outL) {
        outColour = vec3(0.0);
    }

    if(captureGeometry) {
        gl_Position = vec4(position, 1.0);
    } else {
        gl_Position = matrix * vec4(position, 1.0);
    }
    position = gl_Position.xyz;
}


