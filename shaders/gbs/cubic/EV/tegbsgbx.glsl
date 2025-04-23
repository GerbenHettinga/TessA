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

uniform float avalue;
uniform float bvalue;
uniform float cvalue;

uniform float dvalue;
uniform float evalue;
uniform float fvalue;

bool linear;
int side;

struct Jet {
    vec3 b[9];
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
    return v2.x*v3.y + v3.x*v1.y + v1.x*v2.y - v2.x*v1.y - v1.x*v3.y - v3.x*v2.y;
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
    int p1 = 1;
    A_iplus1 = signedTriangleArea(tc_param[N-1], tc_param[0], p);
    for(int i = 0; i < N; i++) {
        p1 = (i+1) % N;
        A_i = A_iplus1;
        A_iplus1 = signedTriangleArea(tc_param[i], tc_param[p1], p);
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

float H_0(float u) {
    return 1.0 - 10.0*u*u*u + 15.0*u*u*u*u - 6.0*u*u*u*u*u;
}

float H_1(float u) {
    return 10.0*u*u*u - 15.0*u*u*u*u + 6.0*u*u*u*u*u;
}

float Bump(float u) {
    float B;
    if(u < 1.0) {
        B = 5.0*pvalue*H_1(u);
    } else {
        B = 5.0*pvalue*H_0(u-1);
    }
    return B;
}

float Bump2(float u) {
    float B = 0.0;
    if(u < 1.0 && u > 0.5) {
        float v = 2.0*(u-0.5);
        B = 5.0*pvalue*H_1(v);
    } else if(u > 1.0 && u < 1.5) {
        float v = 2.0*(u-1.0);
        B = 5.0*pvalue*H_0(v);
    }
    return B;
}


float D_0(float u) {
    float B_0;
    if(u >= 1.0) {
        B_0 = 0;
    } else {
        B_0 = (1.0 - u)*(1.0 - u)*(1.0 - u) / 6.0;
    }
    return B_0;
}

float D_1(float u) {
    float B_1;
    if(u >= 1.0) {
        float v = u - 1.0;
        B_1 = (1.0 - v)*(1.0 - v)*(1.0 - v) / 6.0;
    } else {
        B_1 = (4.0 - 6.0*u*u + 3.0*u*u*u) / 6.0;
    }
    return B_1;
}


float D_1_2(float u) {
    float B_2;
    if(u < 1.0) {
        B_2 = (2.0/3.0) * (1.0 - u)*(1.0 - u)*(1.0 - u)*(1.0 - u)*(1.0 - u) +
              5.0 * (2.0 / 3.0) * (1.0 - u)*(1.0 - u)*(1.0 - u)*(1.0 - u)*u +
              10.0 * (17.0 / 30.0) * (1.0 - u)*(1.0 - u)*(1.0 - u)*u*u +

              10.0 * cvalue * (1.0 - u)*(1.0 - u)*u*u*u +
              5.0 * bvalue *(1.0 - u)*u*u*u*u +
              avalue * u*u*u*u*u;

        //2 / 3 (1 - x)⁵ + 5 * 2 / 3 (1 - x)⁴ x + 10 * 17 / 30 (1 - x)³ x² + k x⁵ + l * 5 (1 - x) x⁴ + m * 10(1 - x)² x³
    } else {
        float v = (u - 1.0);
        B_2 = avalue*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v) +
              5.0*(2.0*avalue - bvalue)*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*v +
              10.0*(2.0*avalue - cvalue)*(1.0-v)*(1.0-v)*(1.0-v)*v*v;

        //(1 - x)⁵ k + (2k - l) * 5(1 - x)⁴ x + (2k - m) * 10(1 - x)³ x²
    }
    return B_2;
}


float D_2(float u) {
    float B_2;
    if(u < 1.0) {
        B_2 = (1.0 + 3.0*u + 3.0*u*u - 3.0*u*u*u) / 6.0;
    } else {
        B_2 = (2.0/3.0)*(2.0-u)*(2.0-u)*(2.0-u)*(2.0-u)*(2.0-u) +
                5.0*(2.0/3.0)*(2.0-u)*(2.0-u)*(2.0-u)*(2.0-u)*(u-1.0) +
                10.0*(17.0/30.0)*(2.0-u)*(2.0-u)*(2.0-u)*(u-1.0)*(u-1.0);
    }

    return B_2;
}

float D_2_2(float u) {
    float B_2;
    if(u < 1.0) {
        B_2 = 1.0/6.0 * (1.0 - u)*(1.0 - u)*(1.0 - u)*(1.0 - u)*(1.0 - u) +
              4.0/15.0 * 5.0 * (1.0 - u)*(1.0 - u)*(1.0 - u)*(1.0 - u)*u +
              5.0/12.0 * 10.0 * (1.0 - u)*(1.0 - u)*(1.0 - u)*u*u +

              5.0*cvalue * 10.0*(1.0 - u)*(1.0 - u)*u*u*u +
              (avalue + bvalue) * 5.0*(1.0 - u)*u*u*u*u +
              avalue * u*u*u*u*u;
    } else {
        float v = (u - 1.0);
        B_2 = avalue * (1.0 - v)*(1.0 - v)*(1.0 - v)*(1.0 - v)*(1.0 - v) +
              (avalue - bvalue) * 5.0*(1.0 - v)*(1.0 - v)*(1.0 - v)*(1.0 - v)*v +
              5.0*cvalue * 10.0*(1.0 - v)*(1.0 - v)*(1.0 - v)*v*v;
    }
    return B_2;
}

float D_2_4(float u) {
    float B_1;
    if(u >= 1.0) {
        float v = u - 1.0;
        B_1 = dvalue*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v) +
              (2.0*dvalue - evalue)*5.0*(1.0-v)*(1.0-v)*(1.0-v)*(1.0-v)*v +
              (2.0*dvalue - fvalue)*10.0*(1.0-v)*(1.0-v)*(1.0-v)*v*v;

        //    a (1 - x)⁵ + 5 (2a - b) (1 - x)⁴ x + 10 (2a - c) (1 - x)³ x²

    } else {
        B_1 = (1.0/6.0)*(1.0-u)*(1.0-u)*(1.0-u)*(1.0-u)*(1.0-u) +
              (4.0/15.0)*5.0*(1.0-u)*(1.0-u)*(1.0-u)*(1.0-u)*u +
              (5.0/12.0)*10.0*(1.0-u)*(1.0-u)*(1.0-u)*u*u +
              fvalue*10.0*(1.0-u)*(1.0-u)*u*u*u +
              evalue*5.0*(1.0-u)*u*u*u*u +
              dvalue*u*u*u*u*u;

        //1 / 6 (1 - x)⁵ + 5 * 4 / 15 (1 - x)⁴ x + 10 * 5 / 12 (1 - x)³ x² + c * 10(1 - x)² x³ + b * 5 (1 - x) x⁴ + a x⁵
    }
    return B_1;
}



float D_3(float u) {
    float B_3;
    if(u < 1.0) {
        B_3 = u*u*u / 6.0;


        //(1 - x)⁵ k + (2k - l) * 5(1 - x)⁴ x + (2k - m) * 10(1 - x)³ x²
    } else {
        float v = u - 1.0;
        B_3 = 1.0/6.0 * (1.0 - v)*(1.0 - v)*(1.0 - v)*(1.0 - v)*(1.0 - v) +
              5.0 * 4.0/15.0 * (1.0 - v)*(1.0 - v)*(1.0 - v)*(1.0 - v)*v +
              10.0 * 5.0/12.0 * (1.0 - v)*(1.0 - v)*(1.0 - v)*v*v;


        //2 / 3 (1 - x)⁵ + 5 * 2 / 3 (1 - x)⁴ x + 10 * 17 / 30 (1 - x)³ x² + k x⁵ + l * 5 (1 - x) x⁴ + m * 10(1 - x)² x³
    }
    return B_3;
}


float mu(float a, float b) {
    float bbb = b*b*b;
    return bbb / (a*a*a + bbb);
}

float qu(float a, float b, float c) {
    float ccc = c*c*c;
    float bbb = b*b*b;
    float aaa = a*a*a;

    float L = bbb / (aaa + bbb);
    float R = ccc / (aaa + ccc);

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

        h = hi[i] * 2.0;

        float D0 = D_0(h);
        float D1 = D_1(h);
        float D2 = D_2(h);
        float D2_2;
        float D1_2;
        if(centreFunctions) {
            //D1_2 = D_1_2(h);
            D1_2 = D1;
            D2_2 = D_2_4(h);
        } else {
            D1_2 = D1;
            D2_2 = D2;
        }
        float DS = D0 + D1 + D2;
        float DS2 = D0 + D1_2 + D2_2;

        float muvu = mu(hi[i], hi[m1]);
        float quvu = qu(hi[i], hi[m1], hi[p1]);
        float muv1u = mu(hi[i], hi[p1]);

        if(si[i] <= 0.5) {
            s = si[i] * 2.0;

            float B0 = B_0(s);
            float B1 = B_1(s);
            float B2 = B_2(s);
            float B3 = B_3(s);

            sidesum =
            muvu *          B0 * (D0 * J[m1].b[0]  + D1 * J[m1].b[3]   + D2 * J[m1].b[6]) +
            muvu *          B1 * (D0 * J[m1].b[1]  + D1 * J[m1].b[4]   + D2 * J[m1].b[7]) +
            quvu *          B2 * (D0 * J[m1].b[2]  + D1 * J[m1].b[5]   + D2_2 * J[m1].b[8]) +
            muv1u *         B3 * (D0 * J[i].b[3]   + D1 * J[i].b[4]    + D2 * J[i].b[5]);

            weightSum +=
            muvu * B0 * DS +
            muvu * B1 * DS +
            quvu * B2 * DS2 +
            muv1u * B3 * DS;
        } else {
            s = si[i] * 2.0 - 1.0;

            float B0 = B_0(s);
            float B1 = B_1(s);
            float B2 = B_2(s);
            float B3 = B_3(s);

            sidesum =
            muvu *          B0 * (D0 * J[m1].b[1] + D1 * J[m1].b[4]  + D2 * J[m1].b[7]) +
            quvu *          B1 * (D0 * J[i].b[6]  + D1 * J[i].b[7]   + D2_2 * J[i].b[8]) +
            muv1u *         B2 * (D0 * J[i].b[3]  + D1 * J[i].b[4]   + D2 * J[i].b[5]) +
            muv1u *         B3 * (D0 * J[i].b[0]  + D1 * J[i].b[1]   + D2 * J[i].b[2]);


            weightSum +=
            muvu * B0 * DS +
            quvu * B1 * DS2 +
            muv1u * B2 * DS +
            muv1u * B3 * DS;
        }

        centrPoint += J[i].b[8];
        centrFlat += J[i].b[0];
        sum += sidesum;
    }

    if(!WD) {
        sum /= weightSum;

    } else {
        centrPoint /= float(N);
        centrFlat /= float(N);

        vec3 CC = centrPoint + pvalue*(centrPoint - centrFlat);
        //vec3 CC = J[0].b[8] + pvalue*(J[0].b[8] - centrPoint);

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
        float B30 = B_3(t);

        pos = B00 * ((J[side].b[0] + 4.0*J[side].b[3] + J[side].b[6])/6.0) +
              B10 * ((J[side].b[1] + 4.0*J[side].b[4] + J[side].b[7])/6.0) +
              B20 * ((J[side].b[2] + 4.0*J[side].b[5] + J[side].b[8])/6.0) +
              B30 * ((J[p1].b[3] + 4.0*J[p1].b[4] + J[p1].b[5])/6.0);
    } else {
        t = 1.0 - t;
        t = t * 2.0 - 1.0;

        float B00 = B_0(t);
        float B10 = B_1(t);
        float B20 = B_2(t);
        float B30 = B_3(t);

        pos = B00*((J[side].b[1] + 4.0*J[side].b[4] + J[side].b[7])/6.0) +
              B10*((J[p1].b[6] + 4.0*J[p1].b[7] + J[p1].b[8])/6.0) +
              B20*((J[p1].b[3] + 4.0*J[p1].b[4] + J[p1].b[5])/6.0) +
              B30*((J[p1].b[0] + 4.0*J[p1].b[1] + J[p1].b[2])/6.0);
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


    float dx = 0.0005;
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

    U = gl_TessCoord[0];
    V = gl_TessCoord[1] - dx;


    vec2 parPos4 = calcParamPos(U, V);
    vec3 pos4;
    if(!boundaryConditionsPie2(U, V)) {
        wachspress(parPos4);
        pos4 = tensorCubic();
    } else {
        pos4 = cubicBoundary();
    }

    U = gl_TessCoord[0] - dx;
    V = gl_TessCoord[1];

    vec2 parPos5 = calcParamPos(U, V);
    vec3 pos5;
    if(!boundaryConditionsPie2(U, V)) {
        wachspress(parPos5);
        pos5 = tensorCubic();
    } else {
        pos5 = cubicBoundary();
    }

    vec3 du = normalize(pos2 - position);
    vec3 dv = normalize(pos3 - position);
    vec3 duu = normalize(pos2 - 2.0*position + pos5);
    vec3 duv = normalize(pos2 - 2.0*position + pos3);
    vec3 dvv = normalize(pos3 - 2.0*position + pos4);

    float E = dot(du, du);
    float F = dot(du, dv);
    float G = dot(dv, dv);

    //compute normal from approximation of gradients
    normal = normalize(flip*cross(du, dv));

//    float L = dot(duu, normal);
//    float M = dot(duv, normal);
//    float n = dot(dvv, normal);

//    float K = (L*n - M*M) / (E*G - F*F) ;

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
    //outWeights[6] = K/3.14;
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


