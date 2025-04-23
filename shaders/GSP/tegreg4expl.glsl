#version 400 core
layout(quads, fractional_odd_spacing, ccw) in;
in vec3[] tc_position;
in vec3[] tc_normal;

uniform float alpha;
uniform bool flatOnly;
uniform bool quadNormals;
uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform bool nMatrix;
uniform bool captureGeometry;
uniform int triangulation;
uniform bool outline;
uniform float pvalue;
uniform int gbcType;

bool linear;
int side;

struct coeff
{
    vec3 b[3];
    vec3 f[4];
};

struct normCoeff
{
    vec3 n[3];
};

in normCoeff[] norms;
patch in int inst;

in coeff cps[];

float[8] weights = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

vec2 tc_param[8] = vec2[](  vec2(-1.0, -1.0),
                            vec2(1.0, -1.0),
                            vec2(1.0, 1.0),
                            vec2(-1.0, 1.0),
                            vec2(0.0), vec2(0.0), vec2(0.0), vec2(0.0));

out vec3 position;
out vec3 normal;
out vec3 outColour;
out float[8] outWeights;


#define N gl_PatchVerticesIn
#define id1 (inst + 1) % N
#define id2 (inst + 2) % N


vec3 project2(vec3 n, vec3 p, vec3 N, vec3 P) {
    vec3 plane = p-P;
    if(length(plane) == 0.0) return n;
    return (n - dot(n+N, plane)/dot(plane, plane)*plane);
}

int wrapper(int i, int n) {
    return i >= 0 ? i % n : n + i;
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
    vec3 sum = vec3(0.0, 0.0, 0.0);
    for(int i = 0; i < N; i++) {
        sum += weights[i] * tc_normal[i];
    }
    return normalize(sum);
}


vec3 evaluatePatchCub2() {
    float[8] sqd = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    //float[8] cubd = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

    vec3 point =  vec3(0.0);

    for(int i = 0; i < N; i++) {
        sqd[i] = weights[i] * weights[i];
    }

    point += sqd[0] * weights[0] * tc_position[0];
    point += sqd[1] * weights[1] * tc_position[1];
    point += sqd[2] * weights[2] * tc_position[2];
    point += sqd[3] * weights[3] * tc_position[3];

    for(int i = 0; i < N; i++) {

    }

    point += 3.0 * weights[0] * weights[1] * (weights[0] + weights[1]) * (cps[0].b[0] * weights[0] + cps[0].b[0] * weights[1]);
    point += 3.0 * weights[0] * weights[2] * (weights[0] + weights[2]) * (weights[0] + weights[1]);
    point += 3.0 * weights[0] * weights[3] * (weights[0] + weights[3]) * (weights[0] + weights[1]);

    point += 3.0 * weights[1] * weights[0] * (weights[1] + weights[0]) * (weights[0] + weights[1]);
    point += 3.0 * weights[1] * weights[2] * (weights[1] + weights[2]) * (weights[0] + weights[1]);
    point += 3.0 * weights[1] * weights[3] * (weights[1] + weights[3]) * (weights[0] + weights[1]);

    point += 3.0 * weights[2] * weights[0] * (weights[2] + weights[0]) * (weights[0] + weights[1]);
    point += 3.0 * weights[2] * weights[1] * (weights[2] + weights[1]) * (weights[0] + weights[1]);
    point += 3.0 * weights[2] * weights[3] * (weights[2] + weights[3]) * (weights[0] + weights[1]);

    point += 3.0 * weights[3] * weights[0] * (weights[3] + weights[0]) * (weights[0] + weights[1]);
    point += 3.0 * weights[3] * weights[1] * (weights[3] + weights[1]) * (weights[0] + weights[1]);
    point += 3.0 * weights[3] * weights[2] * (weights[3] + weights[2]) * (weights[0] + weights[1]);



    return point;
}



vec3 evaluatePatchCub() {
    float[8] sqd = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    float[8] cubd = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

    vec3 point =  vec3(0.0);

    for(int i = 0; i < N; i++) {
        sqd[i] = weights[i] * weights[i];
        cubd[i] = sqd[i] * weights[i];
    }

    for(int i = 0; i < N; i++) {
        point += cubd[i] * weights[i] * tc_position[i];

        for(int j = 1; j < N; j++) {
            point += cubd[i] * weights[(i + j) % N] * (tc_position[i] + 3.0 * cps[i].b[j - 1]);
        }

        point += 3.0 * sqd[i] * sqd[(i+1) % N] * (cps[i].b[0] + cps[(i+1) % N].b[N-2]);
        point += 3.0 * sqd[i] * sqd[(i+2) % N] * cps[i].b[1];

        //blend point in each corner
        point += 12.0 *( (weights[wrapper(i-1, N)] * sqd[i] * weights[(i + 1) % N]) *
                ((1.0-weights[wrapper(i-1, N)]) * weights[(i + 1) % N] * cps[i].f[0] +
                (1.0-weights[(i + 1) % N]) * weights[wrapper(i-1, N)] * cps[wrapper(i-1, N)].f[3])
                /
                ((1.0-weights[wrapper(i-1, N)]) * weights[(i + 1) % N] + (1.0-weights[(i + 1) % N]) * weights[wrapper(i-1, N)]));

        point += 12.0 * sqd[i] * weights[(i + 1) % N] * weights[(i + 2) % N] * cps[i].f[2];
        point += 12.0 * weights[wrapper(i - 2,  N)] * weights[wrapper(i - 1, N)] * sqd[i] * cps[wrapper(i - 1, N)].f[1];

        point += 6.0 * weights[i] * weights[(i + 1) % N] * weights[(i + 2) % N] * weights[(i + 3) % N] * cps[i].b[1];
    }

    return point;
}

vec3 evaluateBoundaryCurve() {
    int p1 = (side + 1) % N;


    return weights[side] * weights[side] * weights[side] * tc_position[side] +
            3.0 * weights[side] * weights[side] * weights[p1] * cps[side].b[0] +
            3.0 * weights[p1] * weights[side] * weights[p1] * cps[p1].b[2] +
           weights[p1] * weights[p1] * weights[p1] * tc_position[p1];
}


vec3 pnNormal() {
    return weights[0] * weights[0] * normalize(tc_normal[0]) +
           weights[1] * weights[1] * normalize(tc_normal[1]) +
           weights[2] * weights[2] * normalize(tc_normal[2]) +
           weights[3] * weights[3] * normalize(tc_normal[3]) +

           weights[0] * weights[3] * normalize(norms[0].n[0] + norms[3].n[2]) +
           weights[0] * weights[2] * normalize(norms[0].n[1] + norms[2].n[1]) +
           weights[0] * weights[1] * normalize(norms[0].n[2] + norms[1].n[0]) +
           weights[1] * weights[3] * normalize(norms[1].n[1] + norms[3].n[1]) +
           weights[1] * weights[2] * normalize(norms[1].n[2] + norms[2].n[0]) +
           weights[2] * weights[3] * normalize(norms[2].n[2] + norms[3].n[0]);

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


void main() {
    vec2 paramPos;
    vec3 pos;
    bool bConditions;

    weights[0] = (1.0 - gl_TessCoord[0])*(1.0-gl_TessCoord[1]);
    weights[1] = (gl_TessCoord[0])*(1.0-gl_TessCoord[1]);
    weights[2] = gl_TessCoord[0]*gl_TessCoord[1];
    weights[3] = (1.0-gl_TessCoord[0])*(gl_TessCoord[1]);

    if(gl_TessCoord[0] == 0.0 && gl_TessCoord[1] == 0.0) {
        position = tc_position[0];
    } else if(gl_TessCoord[0] == 1.0 && gl_TessCoord[1] == 0.0) {
        position = tc_position[1];
    } else if(gl_TessCoord[0] == 1.0 && gl_TessCoord[1] == 1.0) {
        position = tc_position[2];
    } else if(gl_TessCoord[0] == 0.0 && gl_TessCoord[1] == 1.0) {
        position = tc_position[3];
    } else {
        position = evaluatePatchCub();
    }

    if(quadNormals) {
        normal = pnNormal();
    } else {
        normal = phongInterpolate();
    }
    
    if(nMatrix){
        normal = normalize(normal_matrix * normalize(normal));
    }


    pos = weights[0] * tc_position[0] +
             weights[1] * tc_position[1] +
             weights[2] * tc_position[2] +
             weights[3] * tc_position[3];

    outColour = vec3((N % 3)/8.0 + 0.5, (N % 2)/8.0 + 0.5, (N % 5)/8.0 + 0.5);
    if(outline && (weights[0] < 0.0001 || weights[1] < 0.0001 || weights[2] < 0.0001 || weights[3] < 0.0001)) {
        outColour = vec3(0.0);
    }

    outWeights = weights;
    position = mix(pos, position, alpha);
    //gl_Position = vec4(position, 1.0);
    if(captureGeometry) {
        gl_Position = vec4(position, 1.0);
    } else {
        gl_Position = matrix * vec4(position, 1.0);
    }
    position = gl_Position.xyz;
}

