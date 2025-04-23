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
uniform float pvalue;
uniform bool captureGeometry;
uniform int gbcType;
uniform int triangulation;
uniform bool outline;
bool linear;
int side = 0;

struct Jet
{
    vec3 b[12];
};

in Jet J[];

patch in int inst;

float[8] weights = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

out vec3 position;
out vec3 normal;
out vec3 outColour;
out float[8] outWeights;

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
    return (1.0 - u)*(1.0 - u)*(1.0 - u);
}

float G_1(float u) {
    return 3.0*(1.0 - u)*(1.0 - u)*u;
}

float G_2(float u) {
    return 3.0*(1.0 - u)*u*u;
}

float G_3(float u) {
    return u*u*u;
}

float Q_0(float u) {
    return (1.0 - u)*(1.0 - u)*(1.0 - u)*(1.0 - u);
}

float Q_1(float u) {
    return 4.0*(1.0 - u)*(1.0 - u)*(1.0 - u)*u;
}

float Q_2(float u) {
    return 6.0*(1.0 - u)*(1.0 - u)*u*u;
}

float Q_3(float u) {
    return 4.0*(1.0 - u)*u*u*u;
}

float Q_4(float u) {
    return u*u*u*u;
}


float R_0(float u) {
    return (1.0 - u)*(1.0 - u)*(1.0 - u)*(1.0 - u)*(1.0 - u);
}

float R_1(float u) {
    return 5.0*(1.0-u)*(1.0 - u)*(1.0 - u)*(1.0 - u)*u;
}

float R_2(float u) {
    return 10.0*(1.0 - u)*(1.0 - u)*(1.0 - u)*u*u;
}

float R_3(float u) {
    return 10.0*(1.0 - u)*(1.0 - u)*u*u*u;
}

float R_4(float u) {
    return 5.0*(1.0 - u)*u*u*u*u;
}

float R_5(float u) {
    return u*u*u*u*u;
}

float B_0(float u) {
    return (1.0 - u)*(1.0 - u)*(1.0 - u) / 6.0;
}

float B_1(float u) {
    return (4.0 - 6.0*u*u + 3.0*u*u*u) / 6.0;
}

float B_2(float u) {
    return (1.0 + 3.0*u + 3.0*u*u - 3.0*u*u*u) / 6.0;
}

float B_3(float u) {
    return (u*u*u)/6.0;
}

float E_0(float u) {
    return (1.0 - u / 2.0)*(1.0 - u / 2.0)*(1.0 - u / 2.0)*(1.0 - u / 2.0)*(1.0 - u / 2.0);
}

float E_1(float u) {
    return 5.0*(1.0 - u / 2.0)*(1.0 - u / 2.0)*(1.0 - u / 2.0)*(1.0 - u / 2.0)*(u / 2.0);
}

float E_2(float u) {
    return 10.0*(1.0 - u / 2.0)*(1.0 - u / 2.0)*(1.0 - u / 2.0)*(u / 2.0)*(u / 2.0);
}


float mu(float a, float b) {
    float bb = b*b*b;
    return bb / (a*a*a + bb);
}

vec3 tensorCubicBezier() {
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

    float weightSum = 0.0;
    float centr = 1.0;
    vec3 centrPoint = vec3(0.0);
    float sideWeights = 0.0;

    for(int i = 0; i < N; i++) {
        int m1 = wrapper(i - 1, N);
        int p1 = (i + 1) % N;

        float s, h, u, v;
        u = si[i];
        v = hi[i];

        h = hi[i] * 2.0;

        float D0 = E_0(h);
        float D1 = E_1(h);
        float D2 = E_2(h);

        float DS = D0 + D1 + D2;

        float muvu = mu(hi[i], hi[m1]);
        float muv1u = mu(hi[i], hi[p1]);

        if(si[i] <= 0.5) {
            s = si[i] * 2.0;


            float m = 1.2;
            vec3 A_1 = J[m1].b[0] + m * (J[m1].b[4] - J[m1].b[0]);
            vec3 B_1 = J[m1].b[1] + m * (J[m1].b[5] - J[m1].b[1]);
            vec3 C_1 = J[m1].b[2] + m * (J[m1].b[6] - J[m1].b[2]);
            vec3 D_1 = J[m1].b[3] + m * (J[m1].b[7] - J[m1].b[3]);

            vec3 A_2 = J[m1].b[0] + m * (J[m1].b[8] - J[m1].b[0]);
            vec3 B_2 = J[m1].b[1] + m * (J[m1].b[9] - J[m1].b[1]);
            vec3 C_2 = J[m1].b[2] + m * (J[m1].b[10] - J[m1].b[2]);
            vec3 D_2 = J[m1].b[3] + m * (J[m1].b[11] - J[m1].b[3]);

//            vec3 A_1 = (3.0 * J[m1].b[4] + 2.0 * J[m1].b[0]) / 5.0;
//            vec3 B_1 = (3.0 * J[m1].b[5] + 2.0 * J[m1].b[1]) / 5.0;
//            vec3 C_1 = (3.0 * J[m1].b[6] + 2.0 * J[m1].b[2]) / 5.0;
//            vec3 D_1 = (3.0 * J[m1].b[7] + 2.0 * J[m1].b[3]) / 5.0;

//            vec3 A_2 = (3.0*J[m1].b[4] + (J[m1].b[0] + 3.0*J[m1].b[8])/2.0) / 5.0;
//            vec3 B_2 = (3.0*J[m1].b[5] + (J[m1].b[1] + 3.0*J[m1].b[9])/2.0) / 5.0;
//            vec3 C_2 = (3.0*J[m1].b[6] + (J[m1].b[2] + 3.0*J[m1].b[10])/2.0) / 5.0;
//            vec3 D_2 = (3.0*J[m1].b[7] + (J[m1].b[3] + 3.0*J[m1].b[11])/2.0) / 5.0;


            sidesum =
            muvu *          R_0(s) * (D0 * J[m1].b[0]                                                  + D1 * A_1                                      + D2 * A_2) +
            muvu *          R_1(s) * (D0 * (2.0*J[m1].b[0] + 3.0 * J[m1].b[1])/5.0                     + D1 * (2.0*A_1 + 3.0*B_1) / 5.0                + D2 * (2.0*A_2 + 3.0 * B_2) / 5.0 ) +
            muvu *          R_2(s) * (D0 * (3.0*J[m1].b[1] + (J[m1].b[0] + 3.0*J[m1].b[2])/2.0)/5.0    + D1 * (3.0*B_1 + (A_1 + 3.0*C_1)/2.0)/5.0      + D2 * (3.0*B_2 + (A_2 + 3.0*C_2)/2.0)/5.0 ) +
            1.0  *          R_3(s) * (D0 * (3.0*J[m1].b[2] + (J[m1].b[3] + 3.0*J[m1].b[1])/2.0)/5.0    + D1 * (3.0*C_1 + (D_1 + 3.0*B_1)/2.0)/5.0      + D2 * (3.0*C_2 + (D_2 + 3.0*B_2)/2.0)/5.0 ) +
            1.0  *          R_4(s) * (D0 * (3.0*J[m1].b[2] + 2.0*J[m1].b[3])/5.0                       + D1 * (3.0*C_1 + 2.0*D_1) / 5.0                + D2 * (3.0*C_2 + 2.0*D_2)/5.0 ) +
            1.0  *          R_5(s) * (D0 * J[m1].b[3]                                                  + D1 * D_1                                      + D2 * D_2);


            //J[m1].b[0] J[m1].b[1] J[m1].b[2] J[m1].b[3]
            //                                                                                          J[m1].b[4] J[m1].b[5] J[m1].b[6] J[m1].b[7]
            //                                                                                                                                                              J[m1].b[8] J[m1].b[9] J[m1].b[10] J[m1].b[11]
//            sidesum =
//            muvu *          R_0(s) * (D0 * J[m1].b[0]                                                  + D1 * J[m1].b[4]                                                    + D2 * J[m1].b[8]) +
//            muvu *          R_1(s) * (D0 * (2.0*J[m1].b[0] + 3.0 * J[m1].b[1])/5.0                     + D1 * (2.0*J[m1].b[4] + 3.0*J[m1].b[5]) / 5.0                       + D2 * (2.0*J[m1].b[8] + 3.0 * J[m1].b[9]) / 5.0 ) +
//            muvu *          R_2(s) * (D0 * (3.0*J[m1].b[1] + (J[m1].b[0] + 3.0*J[m1].b[2])/2.0)/5.0    + D1 * (3.0*J[m1].b[5] + (J[m1].b[4] + 3.0*J[m1].b[6])/2.0)/5.0      + D2 * (3.0*J[m1].b[9] + (J[m1].b[8] + 3.0*J[m1].b[10])/2.0)/5.0 ) +
//            1.0  *          R_3(s) * (D0 * (3.0*J[m1].b[2] + (J[m1].b[3] + 3.0*J[m1].b[1])/2.0)/5.0    + D1 * (3.0*J[m1].b[6] + (J[m1].b[7] + 3.0*J[m1].b[5])/2.0)/5.0      + D2 * (3.0*J[m1].b[10] + (J[m1].b[11] + 3.0*J[m1].b[9])/2.0)/5.0 ) +
//            1.0  *          R_4(s) * (D0 * (3.0*J[m1].b[2] + 2.0*J[m1].b[3])/5.0                       + D1 * (3.0*J[m1].b[6] + 2.0*J[m1].b[7]) / 5.0                       + D2 * (3.0*J[m1].b[10] + 2.0*J[m1].b[11])/5.0 ) +
//            1.0  *          R_5(s) * (D0 * J[m1].b[3]                                                  + D1 * J[m1].b[7]                                                    + D2 * J[m1].b[11]);


            weightSum +=
            muvu    * R_0(s) * DS +
            muvu    * R_1(s) * DS +
            muvu    * R_2(s) * DS +
            1.0     * R_3(s) * DS +
            1.0     * R_4(s) * DS +
            1.0     * R_5(s) * DS;

        } else {
            s = si[i] * 2.0 - 1.0;

            float m = 1.2;
            vec3 A_1 = J[m1].b[3] + m * (J[m1].b[7] - J[m1].b[3]);
            vec3 B_1 = J[i].b[8] + m * (J[i].b[9] - J[i].b[8]);
            vec3 C_1 = J[i].b[4] + m * (J[i].b[5] - J[i].b[4]);
            vec3 D_1 = J[i].b[0] + m * (J[i].b[1] - J[i].b[0]);

            vec3 A_2 = J[m1].b[3] + m * (J[m1].b[11] - J[m1].b[3]);
            vec3 B_2 = J[i].b[8] + m * (J[i].b[10] - J[i].b[8]);
            vec3 C_2 = J[i].b[4] + m * (J[i].b[6] - J[i].b[4]);
            vec3 D_2 = J[i].b[0] + m * (J[i].b[2] - J[i].b[0]);

//            vec3 A_1 = (2.0*J[m1].b[3] + 3.0*J[m1].b[7]) / 5.0;
//            vec3 B_1 = (2.0*J[i].b[8] + 3.0*J[i].b[9]) / 5.0;
//            vec3 C_1 = (2.0*J[i].b[4] + 3.0*J[i].b[5]) / 5.0;
//            vec3 D_1 = (2.0*J[i].b[0] + 3.0*J[i].b[1]) / 5.0;

//            vec3 A_2 = (3.0*J[m1].b[7] + (J[m1].b[3] + 3.0*J[m1].b[11])/2.0)/5.0 ;
//            vec3 B_2 = (3.0*J[i].b[9] + (J[i].b[8] + 3.0*J[i].b[10])/2.0)/5.0 ;
//            vec3 C_2 = (3.0*J[i].b[5] + (J[i].b[4] + 3.0*J[i].b[6])/2.0)/5.0 ;
//            vec3 D_2 = (3.0*J[i].b[1] + (J[i].b[0] + 3.0*J[i].b[2])/2.0)/5.0 ;


            sidesum =
            1.0 *          R_0(s) * (D0 * J[m1].b[3]                                                + D1 * A_1                                      + D2 * A_2) +
            1.0 *          R_1(s) * (D0 * (2.0*J[m1].b[3] + 3.0*J[i].b[8]) / 5.0                    + D1 * (2.0*A_1 + 3.0 * B_1) / 5.0              + D2 * (2.0*A_2 + 3.0*B_2) / 5.0  ) +
            1.0 *          R_2(s) * (D0 * (3.0*J[i].b[8] + (J[m1].b[3] + 3.0*J[i].b[4])/2.0 ) / 5.0 + D1 * (3.0*B_1 + (A_1 + 3.0*C_1)/2.0 ) / 5.0   + D2 * (3.0*B_2 + (A_2 + 3.0*C_2)/2.0) / 5.0 ) +
            muv1u *        R_3(s) * (D0 * (3.0*J[i].b[4] + (J[i].b[0] + 3.0*J[i].b[8])/2.0 ) / 5.0  + D1 * (3.0*C_1 + (D_1 + 3.0*B_1)/2.0 ) / 5.0   + D2 * (3.0*C_2 + (D_2 + 3.0*B_2)/2.0) / 5.0 ) +
            muv1u *        R_4(s) * (D0 * (3.0*J[i].b[4] + 2.0*J[i].b[0]) / 5.0                     + D1 * (3.0*C_1 + 2.0*D_1) / 5.0                + D2 * (3.0*C_2 + 2.0*D_2) / 5.0 ) +
            muv1u *        R_5(s) * (D0 * J[i].b[0]                                                 + D1 * D_1                                      + D2 * D_2);


            weightSum +=
            1.0     * R_0(s) * DS +
            1.0     * R_1(s) * DS +
            1.0     * R_2(s) * DS +
            muv1u   * R_3(s) * DS +
            muv1u   * R_4(s) * DS +
            muv1u   * R_5(s) * DS;

        }

        centrPoint += J[m1].b[11];
        sum += sidesum;
    }

    centrPoint /= float(N);

    //sum /= weightSum;
    sum = sum + centrPoint * (1.0 - weightSum);
    weights[7] = weightSum;
    //weights[6] = sideWeights;

    return sum;
}

vec3 cubicBoundary() {
    int p1 = wrapper(side + 1 , N);
    vec3 pos;
    float t = weights[side];
    if(weights[side] > 0.5) {
        t = 1.0 - t;
        t = t * 2.0;

        float B00 = G_0(t);
        float B10 = G_1(t);
        float B20 = G_2(t);
        float B30 = G_3(t);

        pos = G_0(t) * J[side].b[0] +
              G_1(t) * J[side].b[1] +
              G_2(t) * J[side].b[2] +
              G_3(t) * J[side].b[3];

    } else {
        t = 1.0 - t;
        t = t * 2.0 - 1.0;

        pos = G_0(t) * J[side].b[3] +
              G_1(t) * J[p1].b[8] +
              G_2(t) * J[p1].b[4] +
              G_3(t) * J[p1].b[0];
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
        position = tensorCubicBezier();
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
        pos2 = tensorCubicBezier();
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
        pos3 = tensorCubicBezier();
    } else {
        pos3 = cubicBoundary();
    }

    normal = flip*cross(normalize(pos2 - position), normalize(pos3 - position));

    //normal = phongInterpolate();

    if(nMatrix){
        normal = normalize(normal_matrix * normalize(normal));
    }

    bool outL = false;
    for(int i = 0; i < N; i++) {
        pos += weights[i] * tc_p[i];
        outL = outL || (weights[i] < 0.0001);
    }

    outWeights = weights;
    position = mix(pos, position, alpha);

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


