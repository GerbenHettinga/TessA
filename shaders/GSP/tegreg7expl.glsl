#version 400 core
layout(triangles, fractional_odd_spacing, ccw) in;
in vec3[] tc_position;
in vec3[] tc_normal;

uniform float alpha;
uniform bool flatOnly;
uniform bool quadNormals;
uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform bool nMatrix;
uniform bool captureGeometry;
uniform float pvalue;
uniform bool outline;
uniform int triangulation;
uniform int gbcType;

bool linear;
int side;

struct coeff
{
    vec3 b[6];
    vec3 f[10];
};

struct normCoeff
{
    vec3 n[6];
};

out normCoeff[] norms;
patch in int inst;

in coeff cps[];

float[8] weights = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

vec2 tc_param[8] = vec2[](  vec2(1.0, 0.0),
                            vec2(0.62349, 0.781832),
                            vec2(-0.222521, 0.974928),
                            vec2(-0.900969, 0.433884),
                            vec2(-0.900969, -0.433884),
                            vec2(-0.222521, -0.974928),
                            vec2(0.62349, -0.781831), vec2(0.0));

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


vec3 evaluatePatchCub() {
    float[8] sqd = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    float[8] cubd = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

    for(int i = 0; i < N; i++) {
        sqd[i] = weights[i] * weights[i];
        cubd[i] = sqd[i] * weights[i];
    }
    vec3 point = vec3(0.0);
    for(int i = 0; i < N; i++) {
        point += cubd[i] * weights[i] * tc_position[i];
        for(int j = 1; j < N; j++) {
            point += cubd[i] * weights[(i + j) % N] * (tc_position[i] + 3.0 * cps[i].b[j - 1]);
        }

        point += 3.0 * sqd[i] * sqd[(i+1) % N] * (cps[i].b[0] + cps[(i+1) % N].b[N-2]);
        point += 3.0 * sqd[i] * sqd[(i+2) % N] * cps[i].b[1];
        point += 3.0 * sqd[i] * sqd[(i+3) % N] * cps[i].b[2];
        point += 3.0 * sqd[i] * sqd[(i+4) % N] * cps[i].b[3];
        point += 3.0 * sqd[i] * sqd[(i+5) % N] * cps[i].b[4];

        //uniquely determined points
        point += 12.0 *  (weights[wrapper(i-1, N)] * sqd[i] * weights[(i + 1) % N]) *
                ((1.0-weights[wrapper(i-1, N)]) * weights[(i + 1) % N] * cps[i].f[0] +
                (1.0-weights[(i + 1) % N]) * weights[wrapper(i-1, N)] * cps[wrapper(i-1, N)].f[9])
                /
                ((1.0-weights[wrapper(i-1, N)]) * weights[(i + 1) % N] + (1.0-weights[(i + 1) % N]) * weights[wrapper(i-1, N)]);

       point += 12.0 *(
            weights[wrapper(i-1, N)] * weights[i] * sqd[(i+1) % N] * cps[i].f[1] +

            sqd[i] * weights[(i+1) % N] * weights[(i+5) % N] * cps[i].f[2] +
            weights[i] * sqd[(i+1) % N] * weights[(i+5) % N] * cps[i].f[3] +

            sqd[i] * weights[(i+1) % N] * weights[(i+4) % N] * cps[i].f[4] +
            weights[i] * sqd[(i+1) % N] * weights[(i+4) % N] * cps[i].f[5] +

            sqd[i] * weights[(i+1) % N] * weights[(i+3) % N] * cps[i].f[6] +
            weights[i] * sqd[(i+1) % N] * weights[(i+3) % N] * cps[i].f[7] +

            sqd[i] * weights[(i+1) % N] * weights[(i+2) % N] * cps[i].f[8]);

        //free points
            //weights[i] * weights[(i+1) % N] * sqd[(i+4) % N] * cps[(i + 3) % N].f[5] +
            //weights[i] * weights[(i+1) % N] * sqd[(i+3) % N] * cps[(i + 3) % N].f[2] +

            //sqd[i] * weights[(i+2) % N] * weights[(i+4) % N] * cps[i].f[3]);

        //point += 12.0 * weights[i] * weights[(i + 1) % N] * weights[(i + 2) % N] * weights[(i + 3) % N] * (cps[(i + 1) % N].f[2] + cps[(i + 1) % N].f[5]);
        //point += 12.0 * weights[i] * weights[(i + 1) % N] * weights[(i + 2) % N] * weights[(i + 4) % N] * (cps[i % N].f[2] + cps[(i + 1) % N].f[5]);
        //point += 6.0 * weights[i] * weights[(i + 1) % N] * weights[(i + 3) % N] * weights[(i + 4) % N] * (cps[i].f[2] + cps[i].f[5]);

    }

    return point;
}

vec3 evaluateBoundaryCurve() {
    int p1 = (side + 1) % N;
    return weights[side] * weights[side] * weights[side] * tc_position[side] +
            3.0 * weights[side] * weights[side] * weights[p1] * cps[side].b[0] +
            3.0 * weights[p1] * weights[side] * weights[p1] * cps[p1].b[5] +
           weights[p1] * weights[p1] * weights[p1] * tc_position[p1];
}


vec3 pnNormal() {
    return weights[0] * weights[0]  * normalize(tc_normal[0]) +
           weights[1] * weights[1]  * normalize(tc_normal[1]) +
           weights[2] * weights[2]  * normalize(tc_normal[2]) +
           weights[3] * weights[3]  * normalize(tc_normal[3]) +
           weights[4] * weights[4]  * normalize(tc_normal[4]) +
           weights[5] * weights[5]  * normalize(tc_normal[5]) +
           weights[6] * weights[6]  * normalize(tc_normal[6]) +

           2.0*(
            weights[0] * weights[6] * normalize(norms[0].n[0] + norms[6].n[5]) +
            weights[0] * weights[5] * normalize(norms[0].n[1] + norms[5].n[4]) +
            weights[0] * weights[4] * normalize(norms[0].n[2] + norms[4].n[3]) +
            weights[0] * weights[3] * normalize(norms[0].n[3] + norms[3].n[2]) +
            weights[0] * weights[2] * normalize(norms[0].n[4] + norms[2].n[1]) +
            weights[0] * weights[1] * normalize(norms[0].n[5] + norms[1].n[0]) +

            weights[1] * weights[6] * normalize(norms[1].n[1] + norms[6].n[4]) +
            weights[1] * weights[5] * normalize(norms[1].n[2] + norms[5].n[3]) +
            weights[1] * weights[4] * normalize(norms[1].n[3] + norms[4].n[2]) +
            weights[1] * weights[3] * normalize(norms[1].n[4] + norms[3].n[1]) +
            weights[1] * weights[2] * normalize(norms[1].n[5] + norms[2].n[0]) +

            weights[2] * weights[6] * normalize(norms[2].n[2] + norms[6].n[3]) +
            weights[2] * weights[5] * normalize(norms[2].n[3] + norms[5].n[2]) +
            weights[2] * weights[4] * normalize(norms[2].n[4] + norms[4].n[1]) +
            weights[2] * weights[3] * normalize(norms[2].n[5] + norms[3].n[0]) +

            weights[3] * weights[6] * normalize(norms[3].n[3] + norms[6].n[2]) +
            weights[3] * weights[5] * normalize(norms[3].n[4] + norms[5].n[1]) +
            weights[3] * weights[4] * normalize(norms[3].n[5] + norms[4].n[0]) +

            weights[4] * weights[6] * normalize(norms[4].n[4] + norms[6].n[1]) +
            weights[4] * weights[5] * normalize(norms[4].n[5] + norms[5].n[0]) +

            weights[5] * weights[6] * normalize(norms[5].n[5] + norms[6].n[0])


           );
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
    vec3 pos;
    vec2 paramPos;
    bool bConditions;

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
        position = evaluatePatchCub();
    } else {
        position = evaluateBoundaryCurve();
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
             weights[3] * tc_position[3] +
             weights[4] * tc_position[4] +
             weights[5] * tc_position[5] +
             weights[6] * tc_position[6];

    outColour = vec3((8 % 3)/8.0 + 0.5, (8 % 2)/8.0 + 0.5, (8 % 5)/8.0 + 0.5);
    if(outline && (weights[0] < 0.0001 || weights[1] < 0.0001 || weights[2] < 0.0001 || weights[3] < 0.0001 || weights[4] < 0.0001 || weights[5] < 0.0001 || weights[6] < 0.0001 || weights[7] < 0.0001)) {
        outColour = vec3(0.0);
    }

    outWeights = weights;
    position = mix(pos, position, alpha);
    if(captureGeometry) {
        gl_Position = vec4(position, 1.0);
    } else {
        gl_Position = matrix * vec4(position, 1.0);
    }
    position = gl_Position.xyz;
}

