#version 400 core
layout(quads, fractional_odd_spacing, ccw) in;
in vec3[] tc_p;
in vec3[] tc_n;
in vec2[] tc_uv;

#define M_EPSILON 1e-6

struct Pos
{
    vec3 b[5];
};

struct Tangent
{
    vec3 b[7];
};

/*
struct Curvature
{
    vec3 b[7];
};*/

in Pos P[];
in Tangent T[];
//in Curvature C[];

uniform float alpha;
uniform bool flatOnly;
uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform bool nMatrix;
uniform bool quadNormals;
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

/*PARAM FLAG*/

float[8] dsquared = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
float[8] dsquaredprod = float[8](1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0);

/*DEFINE N FLAG*/
#define id1 (inst + 1) % N
#define id2 (inst + 2) % N
#define id3 (inst + 3) % N
#define M_PI 3.14159265359


int wrap(int i, int n) {
    return (i + n) % n;
}

float A(vec2 p1, int i)
{
    //Triangle area between point and vertices i and i+1
    vec2 p2 = tc_param[i];
    vec2 p3 = tc_param[(i+1)%N];
    return abs( p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + p3.x * (p1.y - p2.y) ) / 2.0;
}

float A2(vec2 p, int i)
{
    vec2 n = tc_param[i] - tc_param[(i+1) % N];
    n = normalize(vec2(n.y, -n.x));
    return length(dot(p - tc_param[i], n)*n);
}
//Wachspress weight
float w_hat(vec2 x, int i)
{
    float product = 1.0;
    for (int j = 1; j < N-1; j++) {
        product *= A2(x, (i + j) % N);
    }
    return product;
}

//Squared Wachspress weight
float w_hat2(vec2 x, int i)
{
    float w = w_hat(x,i);
    return w*w;
}

//"Wachspress" coordinate with squared weights, used by Leung et al.
float phi2(vec2 x, int i)
{

    float wj = 0.0;
    float w;
    for(int j = 0; j < N; j++) {
        w = w_hat(x, j);
        wj += w*w;
    }

    return w_hat2(x,i) / wj;
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



vec3 bezierComposite(int i, float t) {
    if(t < 0.5) {
        //t *= 2.0;
        //t = t + 8.0*t*t*t*(1 - t);
        t = t + 4.0*t*t - 4.0*t*t*t;
        //t = t + 2.0*t - 2.0*t*t;

        vec3 Q0 = mix(tc_p[i], P[i].b[0], t);
        vec3 Q1 = mix(P[i].b[0], P[i].b[1], t);
        vec3 Q2 = mix(P[i].b[1], P[i].b[2], t);

        vec3 R0 = mix(Q0,Q1,t);
        vec3 R1 = mix(Q1,Q2,t);

        return mix(R0,R1,t);
    } else {
        //t = t*2.0 - 1.0;
        //t = t + 8.0*(t-1)*(t-1)*(t-1)*(1.0 + (t - 1.0));
        t = t - 4.0*(1.0-t)*(1.0-t) + 4.0*(1.0-t)*(1.0-t)*(1.0-t);
        //t = t - 2.0*(1.0 - t) + 2.0*(1.0 - t)*(1.0 - t);

        vec3 Q0 = mix(P[i].b[2], P[i].b[3], t);
        vec3 Q1 = mix(P[i].b[3], P[i].b[4], t);
        vec3 Q2 = mix(P[i].b[4], tc_p[(i+1) % N], t);

        vec3 R0 = mix(Q0,Q1,t);
        vec3 R1 = mix(Q1,Q2,t);

        return mix(R0,R1,t);
    }
}


vec3 bezierCompositeDerivative(int i, float t) {
    if(t < 0.5) {
        //t *= 2.0;
        //t = t + 8.0*t*t*t*(1 - t);
        t = t + 4.0*t*t - 4.0*t*t*t;
        //t = t + 2.0*t - 2.0*t*t;


        vec3 Q0 = mix(T[i].b[0], T[i].b[1], t);
        vec3 Q1 = mix(T[i].b[1], T[i].b[2], t);
        vec3 Q2 = mix(T[i].b[2], T[i].b[3], t);

        vec3 R0 = mix(Q0,Q1,t);
        vec3 R1 = mix(Q1,Q2,t);
        return mix(R0,R1,t);
    } else {
        //t = t*2.0 - 1.0;
        //t = t + 8.0*(t-1)*(t-1)*(t-1)*(1.0 + (t - 1.0));
        t = t - 4.0*(1.0-t)*(1.0-t) + 4.0*(1.0-t)*(1.0-t)*(1.0-t);
        //t = t - 2.0*(1.0 - t) + 2.0*(1.0 - t)*(1.0 - t);

        vec3 Q0 = mix(T[i].b[3], T[i].b[4], t);
        vec3 Q1 = mix(T[i].b[4], T[i].b[5], t);
        vec3 Q2 = mix(T[i].b[5], T[i].b[6], t);

        vec3 R0 = mix(Q0,Q1,t);
        vec3 R1 = mix(Q1,Q2,t);
        return mix(R0,R1,t);
    }
}


float beta(float u) {
    float pi2n = cos(2.0 * M_PI/float(N));
    float a = 2.0*u*pi2n+ 1.0;
    float u3 = u*u*u;
    float b = 2.0*(u3*u - 2.0*u3 + u)*pi2n + 1;
    return a/b;
}

//Gregory corner interpolator
vec3 gregory_corner(float u, float v, int i) {
    //Be careful: Q goes from p[i] to p[i-1] whereas C[i-1] goes from p[i-1] to p[i]
    //This means that the curve has to be flipped around in these equations
    int m1 = wrap(i-1, N);

    vec3 P0 = tc_p[i];

    vec3 Pu = bezierComposite(i, u);
    vec3 Qv = bezierComposite(m1, 1.0-v);

    vec3 Tpu = bezierCompositeDerivative(i, u);
    vec3 Tqv = bezierCompositeDerivative(m1, 1.0-v);

    if(u + v <= M_EPSILON) return -P0 + Pu + Qv; //At the (u,v)=(0,0) point, dividing by (u+v) will not work...

    vec3 Tp0 = T[i].b[0];
    vec3 Tq0 = T[m1].b[6];

    vec3 dTp0 = 3.0*(T[i].b[1] - T[i].b[0]);
    vec3 dTq0 = 3.0*(T[m1].b[5] - T[m1].b[6]);

    vec3 p;

    //float bu = beta(u);
    //float bv = beta(v);
    float bu = 1.0;
    float bv = 1.0;

    p = -P0 - (v * Tp0) - (u * Tq0) + Pu + bu*v * Tpu + Qv + bv*u * Tqv - u * v * (v * dTp0 + u * dTq0)/(u + v);

    return p;
}


vec2 calcUV(vec2 domain_pos, int i)
{
    float u, v, d1, d2;

    d1 = A2(domain_pos, (i-1+N)%N) + A2(domain_pos, (i+1)%N);
    d2 = A2(domain_pos, (i-2+N)%N) + A2(domain_pos, i);
    u = d1 <= M_EPSILON ? 1.0 : A2(domain_pos, (i-1+N)%N) / d1;
    v = d2 <= M_EPSILON ? 1.0 : A2(domain_pos, i)         / d2;


    return vec2(u, v);
}

bool boundaryConditionsPie() {
    if(gl_TessCoord[0] == 0.0) {
        if(gl_TessCoord[1] == 1.0) {
            weights[id2] = 0.5;
            weights[id3] = 0.5;
            return true;
        }
    } else if(gl_TessCoord[0] == 1.0) {
        if(gl_TessCoord[1] == 0.0) {
            weights[id1] = 0.5;
            weights[id2] = 0.5;
            return true;
        } else if(gl_TessCoord[1] == 1.0) {
            weights[id2] = 1.0;
            return true;
        } else {
            weights[id1] = (1.0 - (0.5 + gl_TessCoord[1]*0.5));
            weights[id2] = 0.5 + gl_TessCoord[1]*0.5;
            return true;
        }
    } else if(gl_TessCoord[1] == 1.0) {
        weights[id3] = (1.0 - (0.5 +gl_TessCoord[0] * 0.5));
        weights[id2] = 0.5 + gl_TessCoord[0] * 0.5;
        return true;
    }

    return false;
}


void main() {
    vec3 pos = vec3(0.0);
    vec2 paramPos;
    bool bConditions;

    paramPos = gl_TessCoord[0] * (1.0 - gl_TessCoord[1]) * 0.5*(tc_param[id1] + tc_param[id2])
                + gl_TessCoord[0] * gl_TessCoord[1] * tc_param[id2]
                + (1.0 - gl_TessCoord[0]) * gl_TessCoord[1] * 0.5*(tc_param[id3] + tc_param[id2]);





    //if not on boundary calculate GBCS
    if(!boundaryConditionsPie()) {
        wachspress(paramPos);
        //position = tensorCubic();
    } else {
        //if(linear) {
        //    position = cubicBoundary();
        //} else {
        //    position = tc_p[side];
        //}
    }


    position = vec3(0.0);
    vec2 uv;


    for(int i = 0; i < N; i++) {
        outWeights[i] = phi2(paramPos, i);
    }

    // Sum of gregory corner interpolators
    for(int i = 0; i < N; i++) {
        int m1 = wrap(i-1, N);
        int p1 = (i + 1) % N;
        //if(N != 3) {
            uv = calcUV(paramPos, i);
        //} else {
        //    uv = vec2(gl_TessCoord[instance + 1]);
        //}
        /*
        float denom = weights[i] + weights[p1];
        float s;
        if(denom == 0.0) {
            s = 0.0;
        } else {
            s = weights[p1]/denom;
        }
        uv = vec2(s, 1.0 - weights[i] - weights[p1]);*/
        position += outWeights[i] * gregory_corner(uv.x, uv.y, i);
    }

    normal = phongInterpolate();

    if(nMatrix){
        normal = normalize(normal_matrix * normalize(normal));
    }

    bool outL = false;
    for(int i = 0; i < N; i++) {
        pos += weights[i] * tc_p[i];
        outL = outL || (outWeights[i] < 0.000001);
    }

    //outWeights = weights;
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

