#version 400 core

// Distortion modes
#define SQUARED_DISTORTION 0
#define DOMAIN_DISTORTION 1
#define SINE_DISTORTION 2
#define WOOD_DISTORTION 3

// Filter modes
#define PULSE 0
#define HIGHPASS 1
#define LOWPASS 2
#define BANDPASS 3
#define BANDPASS_2 4

// Noise + Mesh mixing modes
#define COLOUR 0
#define NOISE 1
#define COLOUR_NOISE 2

// Worley Functions (f1..f4)
#define F1 0
#define F2 1
#define F3 2
#define F4 3
#define F2F1 4
#define F2F1SQ 5

// Distance Metric
#define EUCLIDEAN 0
#define MANHATTAN 1

struct Distortion {
    int mode;
    bool enabled;
};

struct Filter {
    int mode;
    bool enabled;
};

uniform Distortion distortion;
uniform Filter filtering;

uniform float baseNoiseFrequency;
uniform float baseNoiseFrequencyU;
uniform float baseNoiseFrequencyV;
uniform int maxOctaves;
uniform float paramX;
uniform float paramY;

uniform vec3 noiseToRGB;
uniform float sineFreq;
uniform float sineAngle;
uniform float noiseToSin;
uniform float jitter;
uniform int noiseBlendMode;
uniform int worleyMode;
uniform int distMetric;
uniform int noiseType;


uniform float seed;

#define M_PI 3.14159265358979323846264

#define highpass(a,x) (smoothstep (a-0.1, a, x))
#define lowpass(b,x) (1 - smoothstep(b, b+0.1, x))
#define pulse(a,b,x) (step((a),(x)) - step((b),(x)))
#define smoothpulse(a,b,x) (smoothstep(a-0.1, a, x) - smoothstep(b, b+0.1, x))

float K= 0.142857142857;    // 1/7
float Ko= 0.428571428571;   // 3/7


vec4 mod289(vec4 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

/*
vec4 permute(vec4 x)
{
  return mod289(((x*34.0)+1.0)*x);
}*/

vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec3 permute(vec3 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec2 permute(vec2 x){return mod(((x*34.0)+1.0)*x, 289.0);}
float permute(float x){return mod(((x*34.0)+1.0)*x, 289.0);}

vec3 dist(vec3 x, vec3 y){
    if (distMetric == EUCLIDEAN){
        return x * x + y * y;
    } else if (distMetric == MANHATTAN) {
        return abs(x) + abs(y);
    }
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


//Worley noise
vec4 cellular(vec2 P) {
    P += seed;

    // Store integer part & decimal part from coordinates
    vec2 Pi = mod(floor(P), 289.0);
    vec2 Pf = fract(P);

    // Coordinate offsets
    vec3 oi = vec3(-1.0, 0.0, 1.0);
    vec3 of = vec3(-0.5, 0.5, 1.5);
    vec3 px = permute(Pi.x + oi);

    // Hash the coordinates
    vec3 p = permute(px.x + Pi.y + oi); // p11, p12, p13
    vec3 ox = fract(p*K) - Ko;
    vec3 oy = mod(floor(p*K),7.0)*K - Ko;

    // Offset point in direction (ox, oy)
    vec3 dx = Pf.x + 0.5 + jitter*ox;
    vec3 dy = Pf.y - of + jitter*oy;

    // Compute distance
    vec3 d1 = dist(dx, dy);

    p = permute(px.y + Pi.y + oi); // p21, p22, p23
    ox = fract(p*K) - Ko;
    oy = mod(floor(p*K),7.0)*K - Ko;
    dx = Pf.x - 0.5 + jitter*ox;
    dy = Pf.y - of + jitter*oy;
    vec3 d2 = dist(dx, dy);

    p = permute(px.z + Pi.y + oi); // p31, p32, p33
    ox = fract(p*K) - Ko;
    oy = mod(floor(p*K),7.0)*K - Ko;
    dx = Pf.x - 1.5 + jitter*ox;
    dy = Pf.y - of + jitter*oy;
    vec3 d3 = dist(dx, dy);

    // Modified original code to support nearest 4 points
    float arr[9] = float[9](d1.x, d1.y, d1.z, d2.x, d2.y, d2.z, d3.x, d3.y, d3.z);
    float tmp;
    // Bubble sort, negligible since length == 9
    for (int i = 0; i<9; i++){
        for (int j = i+1; j<9; j++){
            if (arr[j] < arr[i]){
                tmp = arr[i];
                arr[i] = arr[j];
                arr[j] = tmp;
            }
        }
    }
    return sqrt(vec4(arr[0], arr[1], arr[2], arr[3]));
}

float noiseToScalar(vec4 xy){
    if (worleyMode == F1)
        return xy.x;
    else if (worleyMode == F2)
        return xy.y;
    else if (worleyMode == F3)
        return xy.z;
    else if (worleyMode == F4)
        return xy.w;
    else if (worleyMode == F2F1)
        return xy.y - xy.x;
    else if (worleyMode == F2F1SQ)
        return xy.y * xy.y - xy.x * xy.x;
}


// change 0 .. 1 range to -1 .. 1
float toNegativeRange(float x){
    return x * 2 - 1;
}

float toPositiveRange(float x){
    return (x + 1) / 2;
}

/*
vec2 vecNoise(vec2 xy){
    float x,y;
    x = toNegativeRange(noiseToScalar(pNoise(uv * baseNoiseFrequency, tc_noise.x)));
    y = toNegativeRange(noiseToScalar(pNoise((uv * baseNoiseFrequency) + 0.33, tc_noise.x)));
    return vec2(x,y);
}*/

float pNoisePerlin(vec2 p, float persistance){
    float n = 0.0;
    float normK = 0.0;
    float f = 1.0;
    float amp = 1.0;
    for (int i = 0; i < maxOctaves; i++) {
        n += amp*(cnoise(p * f) / 2 + 0.5);
        f *= 2.0;
        normK += amp;
        amp *= persistance;
    }
    float nf = n/normK;
    return nf;
}


vec4 pNoiseWorley(vec2 p, float persistance){
        vec4 n = vec4(0.0);
        float normK = 0.;
        float f = 1.;
        float amp = 1.;
        int iCount = 0;
        for (int i = 0; i<maxOctaves; i++){
            n+=amp*cellular(p * f);
            f*=2.;
            normK+=amp;
            amp*=persistance;
        }
        vec4 nf = n/normK;
        return nf*nf;
}

