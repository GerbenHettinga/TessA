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

bool linear;
int side;

struct Jet {
    vec3 b[16];
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

float B_0(float u) {
    return (1.0 - u)*(1.0 - u)*(1.0 - u)*(1.0 - u) / 24.0;
}

float B_1(float u) {
    return (-4.0*u*u*u*u + 12.0*u*u*u - 6.0*u*u - 12.0*u + 11.0) / 24.0;
}

float B_2(float u) {
    return (6.0*u*u*u*u - 12.0*u*u*u - 6.0*u*u + 12.0*u + 11.0) / 24.0;
}

float B_3(float u) {
    return (-4.0*u*u*u*u + 4.0*u*u*u + 6.0*u*u + 4.0*u + 1.0) / 24.0;
}

float B_4(float u) {
    return (u*u*u*u) / 24.0;
}

float D_0(float u) {
    float B_0;
    if(u < 1.0) {
        B_0 = (1.0 - u)*(1.0 - u)*(1.0 - u)*(1.0 - u) / 24.0;
    } else {
        B_0 = 0.0;
    }
    return B_0;
}

float D_1(float u) {
    float B_1;
    if(u < 1.0) {
        B_1 = (-4.0*u*u*u*u + 12.0*u*u*u - 6.0*u*u - 12.0*u + 11.0) / 24.0;
    } else if(u < 2.0) {
        float v = u - 1.0;
        B_1 = (1.0 - v)*(1.0 - v)*(1.0 - v)*(1.0 - v) / 24.0;
    } else {
        B_1 = 0.0;
    }
    return B_1;
}

float D_2(float u) {
    float B_2;
    if(u < 1.0) {
        B_2 =  (6.0*u*u*u*u - 12.0*u*u*u - 6.0*u*u + 12.0*u + 11.0) / 24.0;
    } else if(u < 2.0) {
        float v = u - 1.0;
        B_2 = (-4.0*v*v*v*v + 12.0*v*v*v - 6.0*v*v - 12.0*v + 11.0) / 24.0;
    } else {
        float v = u - 2.0;
        B_2 = (1.0 - v)*(1.0 - v)*(1.0 - v)*(1.0 - v) / 24.0;
    }
    return B_2;
}

float D_3(float u) {
    float B_3;
    if(u < 1.0) {
        B_3 = (-4.0*u*u*u*u + 4.0*u*u*u + 6.0*u*u + 4.0*u + 1.0) / 24.0;
    } else if(u < 2.0){
        float v = u - 1.0;
        B_3 =  (6.0*v*v*v*v - 12.0*v*v*v - 6.0*v*v + 12.0*v + 11.0) / 24.0;
    } else {
        float v = u - 2.0;
        B_3 = (11.0/24.0)           * (1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v) +
              7.0*(65.0/168.0)      * (1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*v +
              21.0*(103.0/336.0)    * (1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*v*v +
              35.0*(383.0/1680.0)   * (1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*v*v*v;
    }
    return B_3;
}

float D_3_2(float u) {
    float B_3;
    if(u < 1.0) {
        B_3 = (-4.0*u*u*u*u + 4.0*u*u*u + 6.0*u*u + 4.0*u + 1.0) / 24.0;
    } else if(u < 2.0){
        float v = u - 1.0;
        B_3 =  (6.0*v*v*v*v - 12.0*v*v*v - 6.0*v*v + 12.0*v + 11.0) / 24.0;
    } else {
        float v = u - 2.0;
        B_3 = (11.0/24.0)           * (1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v) +
              7.0*(65.0/168.0)      * (1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*v +
              21.0*(103.0/336.0)    * (1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*v*v +
              35.0*(383.0/1680.0)   * (1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*v*v*v;
    }
    return B_3;
}


float mu(float a, float b) {
    float bbbb = b*b*b*b;
    return bbbb / (a*a*a*a + bbbb);
}

float qu(float a, float b, float c) {
    float cccc = c*c*c*c;
    float bbbb = b*b*b*b;
    float aaaa = a*a*a*a;

    float L = bbbb / (aaaa + bbbb);
    float R = cccc / (aaaa + cccc);

    return L*R;
}


vec3 tensorCubic() {
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

        h = hi[i] * 3.0;

        float D0 = D_0(h);
        float D1 = D_1(h);
        float D2 = D_2(h);
        float D3 = D_3(h);
        float DS = D0 + D1 + D2 + D3;

        float muvu = mu(hi[i], hi[m1]);
        float quvu = qu(hi[i], hi[m1], hi[p1]);
        float muv1u = mu(hi[i], hi[p1]);

        if(si[i] <= 1.0/3.0) {
            s = si[i] * 3.0;

            float B0 = B_0(s);
            float B1 = B_1(s);
            float B2 = B_2(s);
            float B3 = B_3(s);
            float B4 = B_4(s);

            sidesum =
            muvu *      B0 * (D0 * J[m1].b[0]  + D1 * J[m1].b[4] + D2 * J[m1].b[8]  + D3 * J[m1].b[12]) +
            muvu *      B1 * (D0 * J[m1].b[1]  + D1 * J[m1].b[5] + D2 * J[m1].b[9]  + D3 * J[m1].b[13]) +
            muvu *      B2 * (D0 * J[m1].b[2]  + D1 * J[m1].b[6] + D2 * J[m1].b[10] + D3 * J[m1].b[14]) +
            quvu *      B3 * (D0 * J[m1].b[3]  + D1 * J[m1].b[7] + D2 * J[m1].b[11] + D3 * J[m1].b[15]) +
            muv1u *     B4 * (D0 * J[i].b[8]   + D1 * J[i].b[9]  + D2 * J[i].b[10]  + D3 * J[i].b[11]);

            weightSum += DS * (
                        muvu * B0 +
                        muvu * B1 +
                        muvu * B2 +
                        quvu * B3 +
                        muv1u * B4);

        } else if(si[i] <= 2.0/3.0) {
            s = si[i] * 3.0 - 1.0;

            float B0 = B_0(s);
            float B1 = B_1(s);
            float B2 = B_2(s);
            float B3 = B_3(s);
            float B4 = B_4(s);

            sidesum =
            muvu *      B0 * (D0 * J[m1].b[1]  + D1 * J[m1].b[5] + D2 * J[m1].b[9]  + D3 * J[m1].b[13]) +
            muvu *      B1 * (D0 * J[m1].b[2]  + D1 * J[m1].b[6] + D2 * J[m1].b[10] + D3 * J[m1].b[14]) +
            quvu *      B2 * (D0 * J[m1].b[3]  + D1 * J[m1].b[7] + D2 * J[m1].b[11] + D3 * J[m1].b[15]) +
            muv1u *     B3 * (D0 * J[i].b[8]   + D1 * J[i].b[9]  + D2 * J[i].b[10]  + D3 * J[i].b[11]) +
            muv1u *     B4 * (D0 * J[i].b[4]   + D1 * J[i].b[5]  + D2 * J[i].b[6]   + D3 * J[i].b[7]);

            weightSum += DS * (
                        muvu * B0 +
                        muvu * B1 +
                        quvu * B2 +
                        muv1u * B3 +
                        muv1u * B4);

        } else {
            s = si[i] * 3.0 - 2.0;

            float B0 = B_0(s);
            float B1 = B_1(s);
            float B2 = B_2(s);
            float B3 = B_3(s);
            float B4 = B_4(s);

            sidesum =
            muvu *      B0 * (D0 * J[m1].b[2]  + D1 * J[m1].b[6] + D2 * J[m1].b[10]  + D3 * J[m1].b[14]) +
            quvu *      B1 * (D0 * J[m1].b[3]  + D1 * J[m1].b[7] + D2 * J[m1].b[11] + D3 * J[m1].b[15]) +
            muv1u *     B2 * (D0 * J[i].b[8]   + D1 * J[i].b[9]  + D2 * J[i].b[10]  + D3 * J[i].b[11]) +
            muv1u *     B3 * (D0 * J[i].b[4]   + D1 * J[i].b[5]  + D2 * J[i].b[6]  + D3 * J[i].b[7]) +
            muv1u *     B4 * (D0 * J[i].b[0]   + D1 * J[i].b[1]  + D2 * J[i].b[2]  + D3 * J[i].b[3]);

            weightSum += DS * (
                            muvu * B0 +
                            quvu * B1 +
                            muv1u * B2 +
                            muv1u * B3 +
                            muv1u * B4);
        }

        centrPoint += J[i].b[15];
        centrFlat += J[i].b[0];
        sum += sidesum;
    }

    if(!WD) {
        sum /= weightSum;
    } else {
        centrPoint /= float(N);
        centrFlat /= float(N);

        vec3 CC = centrPoint + pvalue*(centrPoint - centrFlat);

        sum = sum + CC * (1.0 - weightSum);
    }

    return sum;
}

vec3 cubicBoundary() {
    int p1 = wrapper(side + 1 , N);
    vec3 pos;
    float t = weights[side];
    if(weights[side] > 2.0/3.0) {
        t = 1.0 - t;
        t = t * 3.0;

        float B00 = B_0(t);
        float B10 = B_1(t);
        float B20 = B_2(t);
        float B30 = B_3(t);
        float B40 = B_4(t);

        pos = B00 * (J[side].b[0] + 11.0*J[side].b[4] + 11.0*J[side].b[8]  + J[side].b[12])/24.0 +
              B10 * (J[side].b[1] + 11.0*J[side].b[5] + 11.0*J[side].b[9]  + J[side].b[13])/24.0 +
              B20 * (J[side].b[2] + 11.0*J[side].b[6] + 11.0*J[side].b[10] + J[side].b[14])/24.0 +
              B30 * (J[side].b[3] + 11.0*J[side].b[7] + 11.0*J[side].b[11] + J[side].b[15])/24.0 +
              B40 * (J[p1].b[8]   + 11.0*J[p1].b[9]   + 11.0*J[p1].b[10]   + J[p1].b[11])/24.0  ;

    } else if(weights[side] > 1.0/3.0) {
        t = 1.0 - t;
        t = t * 3.0 - 1.0;

        float B00 = B_0(t);
        float B10 = B_1(t);
        float B20 = B_2(t);
        float B30 = B_3(t);
        float B40 = B_4(t);

        pos = B00 * (J[side].b[1] + 11.0*J[side].b[5] + 11.0*J[side].b[9]  + J[side].b[13]) / 24.0 +
              B10 * (J[side].b[2] + 11.0*J[side].b[6] + 11.0*J[side].b[10] + J[side].b[14]) / 24.0 +
              B20 * (J[side].b[3] + 11.0*J[side].b[7] + 11.0*J[side].b[11] + J[side].b[15]) / 24.0 +
              B30 * (J[p1].b[8]   + 11.0*J[p1].b[9]   + 11.0*J[p1].b[10]   + J[p1].b[11]) / 24.0 +
              B40 * (J[p1].b[4]   + 11.0*J[p1].b[5]   + 11.0*J[p1].b[6]    + J[p1].b[7]) / 24.0;

    } else {
        t = 1.0 - t;
        t = t * 3.0 - 2.0;

        float B00 = B_0(t);
        float B10 = B_1(t);
        float B20 = B_2(t);
        float B30 = B_3(t);
        float B40 = B_4(t);

        pos = B00 * (J[side].b[2] + 11.0*J[side].b[6] + 11.0*J[side].b[10] + J[side].b[14]) / 24.0 +
              B10 * (J[side].b[3] + 11.0*J[side].b[7] + 11.0*J[side].b[11] + J[side].b[15]) / 24.0 +
              B20 * (J[p1].b[8]   + 11.0*J[p1].b[9]   + 11.0*J[p1].b[10]   + J[p1].b[11]) / 24.0 +
              B30 * (J[p1].b[4]   + 11.0*J[p1].b[5]   + 11.0*J[p1].b[6]    + J[p1].b[7]) / 24.0 +
              B40 * (J[p1].b[0]   + 11.0*J[p1].b[1]   + 11.0*J[p1].b[2]    + J[p1].b[3]) / 24.0;

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
        position = tensorCubic();
    } else {
        position = cubicBoundary();
    }


    float dx = 0.00125;
    float flip = 1.0;

    float U = gl_TessCoord[0] + dx;
    float V = gl_TessCoord[1];
    if((gl_TessCoord[0] + dx) > 1.0) {
        flip *= -1.0;
        U = gl_TessCoord[0] - dx;
        V = gl_TessCoord[1];
    }

    vec2 parPos2 = calcParamPos(U, V);
    vec3 pos2;
    if(!boundaryConditionsPie2(U, V)) {
        wachspress(parPos2);
        pos2 = tensorCubic();
    } else {
        pos2 = cubicBoundary();
    }

    U = gl_TessCoord[0];
    V = gl_TessCoord[1] + dx;
    if((gl_TessCoord[1] + dx) > 1.0) {
        flip *= -1.0;
        V = gl_TessCoord[1] - dx;
        U = gl_TessCoord[0];
    }


    vec2 parPos3 = calcParamPos(U, V);
    vec3 pos3;
    if(!boundaryConditionsPie2(U, V)) {
        wachspress(parPos3);
        pos3 = tensorCubic();
    } else {
        pos3 = cubicBoundary();
    }

    vec3 du = normalize(pos2 - position);
    vec3 dv = normalize(pos3 - position);
    //compute normal from approximation of gradients
    normal = normalize(flip*cross(du, dv));

    if(nMatrix) {
        normal = normalize(normal_matrix * normal);
    }

    //compute linear interpolation of normal
    for(int i = 0; i < N; i++) {
        pos += weights[i] * tc_p[i];
    }

    bool outL = false;
    outL = outL || (gl_TessCoord[1] > 0.99);
    outL = outL || (gl_TessCoord[0] > 0.99);
    if(spokes) {
        outL = outL || (gl_TessCoord[0] < 0.01);
        outL = outL || (gl_TessCoord[1] < 0.01);
    }

    outWeights = weights;
    //position = mix(pos, position, alpha);

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


