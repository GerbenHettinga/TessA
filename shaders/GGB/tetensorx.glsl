#version 400 core
layout(/*LAYOUT FLAG*/, fractional_odd_spacing, ccw) in;
in vec3[] tc_position;
in vec3[] tc_normal;
in vec2[] tc_uv;

uniform float alpha;
uniform bool flatOnly;
uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform bool quadNormals;
uniform bool nMatrix;
uniform bool captureGeometry;
uniform float pvalue;
uniform int gbcType;
uniform int triangulation;
uniform bool outline;
uniform float qvalue;
bool linear;
int side;

struct coeff
{
    vec3 b[2];
    vec3 f[2];
    vec2 f_uv[2];
};

in coeff cps[];

patch in int inst;

vec4 U = vec4(1.0, gl_TessCoord[0], gl_TessCoord[0]*gl_TessCoord[0], gl_TessCoord[0]*gl_TessCoord[0]*gl_TessCoord[0]);
vec4 V = vec4(1.0, gl_TessCoord[1], gl_TessCoord[1]*gl_TessCoord[1], gl_TessCoord[1]*gl_TessCoord[1]*gl_TessCoord[1]);


float[8] weights = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

/*PARAM FLAG*/

out vec3 position;
out vec3 normal;
out vec3 outColour;
out vec2 uv;
out float[8] outWeights;

/*DEFINE N FLAG*/
#define id1 (inst + 1) % N
#define id2 (inst + 2) % N

#define M_PI 3.14159265358979323846264

int wrapper(int i, int n) {
    return (i + n) % n;
}

float signedTriangleArea(vec2 v1, vec2 v2, vec2 v3) {
    float det = v2.x*v3.y + v3.x*v1.y + v1.x*v2.y - v2.x*v1.y - v1.x*v3.y - v3.x*v2.y;
    return det;
}

void wachspress(vec2 p){
    vec2 vi, vi_min1, vi_plus1;
    float sumweights = 0.0;
    float B, A_i, A_iplus1;
    //optimization for regular case
    //B = signedTriangleArea(ps[0], ps[1], ps[2]);
    A_iplus1 = signedTriangleArea(tc_param[N-1], tc_param[0], p);
    for(int i = 0; i < N; i++) {
        vi = tc_param[i];
        vi_min1 = tc_param[wrapper(i-1, N)];
        vi_plus1 = tc_param[wrapper(i+1, N)];
        //B =  signedTriangleArea(vi_min1, vi, vi_plus1);
        A_i = A_iplus1;
        A_iplus1 = signedTriangleArea(vi, vi_plus1, p);
        weights[i] = 1.0/(A_i*A_iplus1);
        sumweights += weights[i];
    }
    for(int i = 0; i < N; i++) {
        weights[i] = weights[i]/sumweights;
    }
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

//linear interpolation of normals
vec3 phongInterpolate() {
    vec3 sum = vec3(0.0);
    for(int i = 0; i < N; i++) {
        sum += weights[i] * tc_normal[i];
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


vec3 tensorCubic() {
    vec3 sum = vec3(0.0);
    vec3 sidesum;

    float[8] hi;
    float[8] si;
    float alpha_i, beta_i;

    vec3 cent = vec3(0.0);
    vec3 fCent = vec3(0.0);

    for(int i = 0; i < N; i++) {
        int m1 = wrapper(i - 1, N);
        int p1 = wrapper(i + 1, N);
        si[i] = weights[i]/(weights[m1] + weights[i]);
        hi[i] = 1.0 - weights[m1] - weights[i];
        cent += cps[i].f[0] + cps[i].f[1];
    }

    cent = cent/(2.0 * float(N));
    float weightSum = 0.0;

    for(int i = 0; i < N; i++) {
        int m1 = wrapper(i - 1, N);
        int p1 = wrapper(i + 1, N);

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
        B01*cps[m1].b[0]    + B11*cps[m1].f[0] + B21*cps[m1].f[1] + B31*cps[i].b[1] +
        //edge
        B00*tc_position[m1] + B10*cps[m1].b[1] + B20*cps[i].b[0]  + B30*tc_position[i];

        weightSum += B01 + B11 + B21 + B31;
        weightSum += B00 + B10 + B20 + B30;

        sum += sidesum;
    }
    sum = sum + (1.0 - weightSum) * cent;

    return sum;
}


vec3 cubicBoundary() {
    int p1 = wrapper(side + 1 , N);

    vec3 pos = weights[side]*weights[side]*weights[side] * tc_position[side] +
    3.0*weights[side]*weights[side]*weights[p1]*cps[side].b[1] +
    3.0*weights[p1]*weights[p1]*weights[side]*cps[p1].b[0] +
    weights[p1] * weights[p1] * weights[p1] * tc_position[p1];


    return pos;
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


bool triangleBoundary(){
    if(gl_TessCoord[0] == 1.0) {
        position = tc_position[0];
    } else if(gl_TessCoord[1] == 1.0) {
        position = tc_position[1];
    } else if(gl_TessCoord[2] == 1.0) {
        position = tc_position[2];
    } else {
        return false;
    }
    return true;
}

bool quadBoundary(){
    float u;
    if(gl_TessCoord[0] == 0.0) {
        u = (1.0 - gl_TessCoord[1]);
        position = (1.0-u)*(1.0-u)*(1.0-u)*tc_position[3] + 3.0*(1.0-u)*(1.0-u)*u*cps[3].b[1]  + 3.0*(1.0-u)*u*u*cps[0].b[0]  + u*u*u*tc_position[0];
    } else if(gl_TessCoord[1] == 0.0) {
        u = gl_TessCoord[0];
        position = (1.0-u)*(1.0-u)*(1.0-u)*tc_position[0] + 3.0*(1.0-u)*(1.0-u)*u*cps[0].b[1] + 3.0*(1.0-u)*u*u*cps[1].b[0]  + u*u*u*tc_position[1];
    } else if(gl_TessCoord[0] == 1.0) {
        u = gl_TessCoord[1];
        position = (1.0-u)*(1.0-u)*(1.0-u)*tc_position[1] + 3.0*(1.0-u)*(1.0-u)*u*cps[1].b[1] + 3.0*(1.0-u)*u*u*cps[2].b[0]  + u*u*u*tc_position[2];
    } else if(gl_TessCoord[1] == 1.0) {
        u = (1.0 - gl_TessCoord[0]);
        position = (1.0-u)*(1.0-u)*(1.0-u)*tc_position[2] + 3.0*(1.0-u)*(1.0-u)*u*cps[2].b[1] + 3.0*(1.0-u)*u*u*cps[3].b[0]  + u*u*u*tc_position[3];
    } else {
        return false;
    }
    return true;
}

vec4 mod289(vec4 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x)
{
  return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

// 5th degree polynomial
vec2 fade(vec2 t) {
  return t*t*t*(t*(t*6.0-15.0)+10.0);
}

// phase from point and angle
float pointToAngle(vec2 P, float a){
    return dot(P, vec2(cos(a), -sin(a)));
}


// Classic Perlin noise
float cnoise(vec2 P)
{
    // Seed the coordinates
    P += 0.0;

    // Place the point in its lattice cube
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);

    // Store the decimal part for the distance vector
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod289(Pi); // To avoid truncation effects in permutation
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;

    // Hash the integer coordinates
    vec4 i = permute(permute(ix) + iy);

    vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
    vec4 gy = abs(gx) - 0.5 ;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;

    // Convert 2x vec4 to the 4 lattice vectors
    vec2 g00 = vec2(gx.x,gy.x);
    vec2 g10 = vec2(gx.y,gy.y);
    vec2 g01 = vec2(gx.z,gy.z);
    vec2 g11 = vec2(gx.w,gy.w);

    // normalize the vectors
    vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;

    // Dot product of lattice vector and distance vector
    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));

    // 5th degree polynomial for smooth interpolation
    vec2 fade_xy = fade(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);

    // -1 .. 1
    return 2.3 * n_xy;
}

float pNoise(vec2 p, float persistance){
    float n = 0.0;
    float normK = 0.0;
    float f = 1.0;
    float amp = 1.0;
    for (int i = 0; i < 3; i++){
        n += amp*(cnoise(p * f) / 2 + 0.5);
        f *= 2.0;
        normK += amp;
        amp *= persistance;
    }
    float nf = n/normK;
    return nf;
}



void main() {
    vec3 pos;
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
        if(!quadBoundary()){
            position = tensorCubic();
        }
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
                position = tc_position[side];
            }
        }
    }
    
    normal = phongInterpolate();
    uv = phongInterpolateUV();

    float noise = pNoise(uv * 0.25, 5.0);

    //position = position + normal * noise;

    if(nMatrix){
        normal = normalize(normal_matrix * normal);
    }

    bool outL = false;
    for(int i = 0; i < N; i++) {
        pos = weights[i] * tc_position[i];
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

