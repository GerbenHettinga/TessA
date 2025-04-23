#version 400 core
layout(/*LAYOUT FLAG*/, fractional_odd_spacing, ccw) in;
in vec3[] tc_p;
in vec3[] tc_ep;
in vec3[] tc_em;
in vec3[] tc_fp;
in vec3[] tc_fm;
in vec3[] tc_n;
in vec2[] tc_uv;

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
out float[8] outWeights;
out vec2 uv;


/*PARAM FLAG*/


/*DEFINE N FLAG*/
#define id1 (inst + 1) % N
#define id2 (inst + 2) % N


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

//linear interpolation of normals
vec2 phongInterpolateUV() {
    vec2 sum = vec2(0.0);
    for(int i = 0; i < N; i++) {
        sum += weights[i] * tc_uv[i];
    }
    return sum;
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




vec3 tensorCubic() {
    vec3 sum = vec3(0.0);
    vec3 sidesum;

    float[8] hi;
    float[8] si;
    float alpha_i, beta_i;

    vec3 cent = vec3(0.0);

    for(int i = 0; i < N; i++) {
        int m1 = wrapper(i - 1, N);
        int p1 = (i + 1) % N;
        si[i] = weights[i]/(weights[m1] + weights[i]);
        hi[i] = 1.0 - weights[m1] - weights[i];
        cent += tc_fm[i] + tc_fp[i];
    }

    cent = cent/(2.0 * float(N));
    float weightSum = 0.0;

    for(int i = 0; i < N; i++) {
        int m1 = wrapper(i - 1, N);
        int p1 = (i + 1) % N;

        alpha_i = hi[m1]/(hi[m1] + hi[i]);
        beta_i = hi[p1]/(hi[p1] + hi[i]);

        float si2 = si[i]*si[i];
        float hi2 = hi[i]*hi[i];
        float si3 = si[i]*si2;
        float hi3 = hi[i]*hi2;

        float m1si = (1.0-si[i]);
        float m1si2 = m1si*m1si;
        float m1si3 = m1si*m1si2;
        float m1hi = (1.0-hi[i]);
        float m1hi2 = m1hi*m1hi;
        float m1hi3 = m1hi*m1hi2;

        float B01 = alpha_i*3.0*m1si3*m1hi2*hi[i];
        float B11 = 9.0*alpha_i*m1si2*si[i]*m1hi2*hi[i];
        float B21 = 9.0*beta_i*m1si*si2*m1hi2*hi[i];
        float B31 = 3.0*beta_i*si3*m1hi2*hi[i];

        float B00 = alpha_i*m1si3*m1hi3;
        float B10 = 3.0*alpha_i*m1si2*si[i]*m1hi3;
        float B20 = 3.0*beta_i*m1si*si2*m1hi3;
        float B30 = beta_i*si3*m1hi3;

        sidesum =
        //first row from edge
        B01*tc_em[m1] + B11*tc_fp[m1] + B21*tc_fm[i] + B31*tc_ep[i] +
        //edge
        B00*tc_p[m1] + B10*tc_ep[m1] + B20*tc_em[i]  + B30*tc_p[i];

        weightSum += B01 + B11 + B21 + B31;
        weightSum += B00 + B10 + B20 + B30;

        sum += sidesum;
    }

    sum = sum + (1.0 - weightSum) * cent;

    return sum;
}

vec3 cubicBoundary() {
    int p1 = wrapper(side + 1 , N);

    vec3 pos = weights[side]*weights[side]*weights[side] * tc_p[side] +
    3.0*weights[side]*weights[side]*weights[p1]*tc_ep[side] +
    3.0*weights[p1]*weights[p1]*weights[side]*tc_em[p1] +
    weights[p1] * weights[p1] * weights[p1] * tc_p[p1];

    return pos;
}

bool triangleBoundary(){
    if(gl_TessCoord[0] == 1.0) {
        position = tc_p[0];
    } else if(gl_TessCoord[1] == 1.0) {
        position = tc_p[1];
    } else if(gl_TessCoord[2] == 1.0) {
        position = tc_p[2];
    } else {
        return false;
    }
    return true;
}

bool quadBoundary(){
    float u;
    if(gl_TessCoord[0] == 0.0) {
        u = (1.0 - gl_TessCoord[1]);
        position = (1.0-u)*(1.0-u)*(1.0-u)*tc_p[3] + 3.0*(1.0-u)*(1.0-u)*u*tc_ep[3]  + 3.0*(1.0-u)*u*u*tc_em[0]  + u*u*u*tc_p[0];
    } else if(gl_TessCoord[1] == 0.0) {
        u = gl_TessCoord[0];
        position = (1.0-u)*(1.0-u)*(1.0-u)*tc_p[0] + 3.0*(1.0-u)*(1.0-u)*u*tc_ep[0] + 3.0*(1.0-u)*u*u*tc_em[1]  + u*u*u*tc_p[1];

    } else if(gl_TessCoord[0] == 1.0) {
        u = gl_TessCoord[1];
        position = (1.0-u)*(1.0-u)*(1.0-u)*tc_p[1] + 3.0*(1.0-u)*(1.0-u)*u*tc_ep[1] + 3.0*(1.0-u)*u*u*tc_em[2]  + u*u*u*tc_p[2];
    } else if(gl_TessCoord[1] == 1.0) {
        u = (1.0 - gl_TessCoord[0]);
        position = (1.0-u)*(1.0-u)*(1.0-u)*tc_p[2] + 3.0*(1.0-u)*(1.0-u)*u*tc_ep[2] + 3.0*(1.0-u)*u*u*tc_em[3]  + u*u*u*tc_p[3];
    } else {
        return false;
    }
    return true;
}

bool boundaryConditionsPie() {
    if(gl_TessCoord[0] == 0.0) {
        if(gl_TessCoord[1] == 0.0) {
            side = id2;
            weights[id2] = 1.0;
        } else if(gl_TessCoord[2] == 0.0) {
            side = id1;
            weights[id1] = 1.0;
        } else {
            linear = true;
            side = id1;
            weights[id1] = gl_TessCoord[1];
            weights[id2] = gl_TessCoord[2];
        }
        return true;
    }
    return false;
}

//check for boundary conditions
bool boundaryConditions()   {
    linear = false;
    side = -1;
    if(gl_TessCoord[0] == 0.0) {
        if(gl_TessCoord[1] == 0.0) {
            side = id2;
            weights[id2] = 1.0;
        } else if(gl_TessCoord[2] == 0.0) {
            weights[id1] = 1.0;
            side = id1;
        } else {
            linear = true;
            side = id1;
            weights[id2] = gl_TessCoord[2];
            weights[id1] = gl_TessCoord[1];
        }
        return true;
    } else if(gl_TessCoord[1] == 0.0) {
        if(gl_TessCoord[0] > 0.0 && gl_TessCoord[2] > 0.0) {
            if(abs(id2) == 1 || abs(id2) == (N - 1)) {
                linear = true;
                side = id2;
                weights[0] = gl_TessCoord[0];
                weights[id2] = gl_TessCoord[2];
                return true;
            }
        } else if(gl_TessCoord[0] == 0.0) {
            weights[id2] = 1.0;
            side = id2;
            return true;
        } else {
            weights[0] = 1.0;
            side = 0;
            return true;
        }
    } else if(gl_TessCoord[2] == 0.0) {
        if(gl_TessCoord[0] > 0.0 && gl_TessCoord[1] > 0.0) {
            if(abs(id1) == 1 || abs(id1) == (N - 1)) {
                linear = true;
                side = 0;
                weights[0] = gl_TessCoord[0];
                weights[id1] = gl_TessCoord[1];
                return true;
            }
        } else if(gl_TessCoord[0] == 0.0) {
            weights[id1] = 1.0;
            side = id1;
            return true;
        } else {
            weights[0] = 1.0;
            side = 0;
            return true;
        }
    }
    return false;
}

void main() {
    vec3 pos = vec3(0.0);
    vec2 paramPos;
    bool bConditions;


    if(N == 3) {
        weights[0] = gl_TessCoord[0];
        weights[1] = gl_TessCoord[1];
        weights[2] = gl_TessCoord[2];
        if(!triangleBoundary()){
           position = tensorCubic();
        }
    } else if(N == 4){
	
        weights[0] = (1.0 - gl_TessCoord[0])*(1.0-gl_TessCoord[1]);
        weights[1] = gl_TessCoord[0]*(1.0-gl_TessCoord[1]);
        weights[2] = gl_TessCoord[0]*gl_TessCoord[1];
        weights[3] = (1.0-gl_TessCoord[0])*gl_TessCoord[1];

	position = tensorCubic();
        quadBoundary();
    } else {
        // interpolated param position wrt triangulations methods
        if(triangulation == 0) {
            paramPos = gl_TessCoord[0]*tc_param[0]
                    + gl_TessCoord[1]*tc_param[id1]
                    + gl_TessCoord[2]*tc_param[id2];
            bConditions = boundaryConditions();
        } else {
            paramPos = gl_TessCoord[1] * tc_param[id1]
                    + gl_TessCoord[2] * tc_param[id2];
            bConditions = boundaryConditionsPie();
        }

        //if not on boundary calculate GBCS
        if(!bConditions) {
            wachspress(paramPos);
            position = tensorCubic();
        } else {
            if(linear) {
                position = cubicBoundary();
            } else {
                position = tc_p[side];
            }
        }
    }

    normal = phongInterpolate();
    uv = phongInterpolateUV();

    if(nMatrix){
        normal = normalize(normal_matrix * normalize(normal));
    }

    bool outL = false;
    for(int i = 0; i < N; i++) {
        pos = weights[i] * tc_p[i];
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

