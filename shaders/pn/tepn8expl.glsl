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
uniform float pvalue;
uniform int gbcType;
uniform int triangulation;

struct coeff
{
    vec3 b[7];
    vec3 m[7];
};

patch in int inst;

in coeff cps[];

struct normCoeff
{
    vec3 n[7];
};

in normCoeff[] norms;

float[8] weights = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

vec2 tc_param[8] = vec2[](  vec2(1.0, 0.0),
                            vec2(0.707107, 0.707107),
                            vec2(0.0, 1.0),
                            vec2(-0.707107, 0.707107),
                            vec2(-1, 0.0),
                            vec2(-0.707107, -0.707107),
                            vec2(0.0, -1.0),
                            vec2(0.707107, -0.707107));

out vec3 position;
out vec3 normal;
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
    if(i < 0){
        return n-1;
    } else if(i == n){
        return 0;
    }
    return i;
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
    if(gl_TessCoord[0] == 0.0) {
        if(gl_TessCoord[1] == 0.0) {
            weights[id2] = 1.0;
        } else if(gl_TessCoord[2] == 0.0) {
            weights[id1] = 1.0;

        } else {
            weights[id2] = gl_TessCoord[2];
            weights[id1] = gl_TessCoord[1];
        }
        return true;
    } else if(gl_TessCoord[1] == 0.0) {
        if(gl_TessCoord[0] > 0.0 && gl_TessCoord[2] > 0.0) {
            if(abs(id2) == 1 || abs(id2) == (N - 1)) {
                weights[0] = gl_TessCoord[0];
                weights[id2] = gl_TessCoord[2];
                return true;
            }
        } else if(gl_TessCoord[0] == 0.0) {
            weights[id2] = 1.0;
            return true;
        } else {
            weights[0] = 1.0;
            return true;
        }
    } else if(gl_TessCoord[2] == 0.0) {
        if(gl_TessCoord[0] > 0.0 && gl_TessCoord[1] > 0.0) {
            if(abs(id1) == 1 || abs(id1) == (N - 1)) {
                weights[0] = gl_TessCoord[0];
                weights[id1] = gl_TessCoord[1];
                return true;
            }
        } else if(gl_TessCoord[0] == 0.0) {
            weights[id1] = 1.0;
            return true;
        } else {
            weights[0] = 1.0;
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
        for(int i = 0; i < N; i++) {
            sqd[i] = weights[i] * weights[i];
        }

        return sqd[0] * weights[0] * tc_position[0] +
               sqd[1] * weights[1] * tc_position[1] +
               sqd[2] * weights[2] * tc_position[2] +
               sqd[3] * weights[3] * tc_position[3] +
               sqd[4] * weights[4] * tc_position[4] +
               sqd[5] * weights[5] * tc_position[5] +
               sqd[6] * weights[6] * tc_position[6] +
               sqd[7] * weights[7] * tc_position[7] +


                 sqd[0] * weights[7] * cps[0].b[0] +
                 sqd[0] * weights[6] * cps[0].b[1] +
                 sqd[0] * weights[5] * cps[0].b[2] +
                 sqd[0] * weights[4] * cps[0].b[3] +
                 sqd[0] * weights[3] * cps[0].b[4] +
                 sqd[0] * weights[2] * cps[0].b[5] +
                 sqd[0] * weights[1] * cps[0].b[6] +


                 sqd[1] * weights[0] * cps[1].b[0] +
                 sqd[1] * weights[7] * cps[1].b[1] +
                 sqd[1] * weights[6] * cps[1].b[2] +
                 sqd[1] * weights[5] * cps[1].b[3] +
                 sqd[1] * weights[4] * cps[1].b[4] +
                 sqd[1] * weights[3] * cps[1].b[5] +
                 sqd[1] * weights[2] * cps[1].b[6] +


                 sqd[2] * weights[1] * cps[2].b[0] +
                 sqd[2] * weights[0] * cps[2].b[1] +
                 sqd[2] * weights[7] * cps[2].b[2] +
                 sqd[2] * weights[6] * cps[2].b[3] +
                 sqd[2] * weights[5] * cps[2].b[4] +
                 sqd[2] * weights[4] * cps[2].b[5] +
                 sqd[2] * weights[3] * cps[2].b[6] +

                 sqd[3] * weights[2] * cps[3].b[0] +
                 sqd[3] * weights[1] * cps[3].b[1] +
                 sqd[3] * weights[0] * cps[3].b[2] +
                 sqd[3] * weights[7] * cps[3].b[3] +
                 sqd[3] * weights[6] * cps[3].b[4] +
                 sqd[3] * weights[5] * cps[3].b[5] +
                 sqd[3] * weights[4] * cps[3].b[6] +

                 sqd[4] * weights[3] * cps[4].b[0] +
                 sqd[4] * weights[2] * cps[4].b[1] +
                 sqd[4] * weights[1] * cps[4].b[2] +
                 sqd[4] * weights[0] * cps[4].b[3] +
                 sqd[4] * weights[7] * cps[4].b[4] +
                 sqd[4] * weights[6] * cps[4].b[5] +
                 sqd[4] * weights[5] * cps[4].b[6] +

                 sqd[5] * weights[4] * cps[5].b[0] +
                 sqd[5] * weights[3] * cps[5].b[1] +
                 sqd[5] * weights[2] * cps[5].b[2] +
                 sqd[5] * weights[1] * cps[5].b[3] +
                 sqd[5] * weights[0] * cps[5].b[4] +
                 sqd[5] * weights[7] * cps[5].b[5] +
                 sqd[5] * weights[6] * cps[5].b[6] +

                 sqd[6] * weights[5] * cps[6].b[0] +
                 sqd[6] * weights[4] * cps[6].b[1] +
                 sqd[6] * weights[3] * cps[6].b[2] +
                 sqd[6] * weights[2] * cps[6].b[3] +
                 sqd[6] * weights[1] * cps[6].b[4] +
                 sqd[6] * weights[0] * cps[6].b[5] +
                 sqd[6] * weights[7] * cps[6].b[6] +

                 sqd[7] * weights[6] * cps[7].b[0] +
                 sqd[7] * weights[5] * cps[7].b[1] +
                 sqd[7] * weights[4] * cps[7].b[2] +
                 sqd[7] * weights[3] * cps[7].b[3] +
                 sqd[7] * weights[2] * cps[7].b[4] +
                 sqd[7] * weights[1] * cps[7].b[5] +
                 sqd[7] * weights[0] * cps[7].b[6] +

                //56 centre cps
                6.0 * (

                    weights[7] * weights[0] * weights[1] * cps[0].m[0] +
                    weights[7] * weights[0] * weights[2] * cps[0].m[1] +
                    weights[7] * weights[0] * weights[3] * cps[0].m[2] +
                    weights[7] * weights[0] * weights[4] * cps[0].m[3] +
                    weights[7] * weights[0] * weights[5] * cps[0].m[4] +

                    weights[0] * weights[1] * weights[2] * cps[1].m[0] +
                    weights[0] * weights[1] * weights[3] * cps[1].m[1] +
                    weights[0] * weights[1] * weights[4] * cps[1].m[2] +
                    weights[0] * weights[1] * weights[5] * cps[1].m[3] +
                    weights[0] * weights[1] * weights[6] * cps[1].m[4] +

                    weights[1] * weights[2] * weights[3] * cps[2].m[0] +
                    weights[1] * weights[2] * weights[4] * cps[2].m[1] +
                    weights[1] * weights[2] * weights[5] * cps[2].m[2] +
                    weights[1] * weights[2] * weights[6] * cps[2].m[3] +
                    weights[1] * weights[2] * weights[7] * cps[2].m[4] +

                    weights[2] * weights[3] * weights[4] * cps[3].m[0] +
                    weights[2] * weights[3] * weights[5] * cps[3].m[1] +
                    weights[2] * weights[3] * weights[6] * cps[3].m[2] +
                    weights[2] * weights[3] * weights[7] * cps[3].m[3] +
                    weights[2] * weights[3] * weights[0] * cps[3].m[4] +


                    weights[3] * weights[4] * weights[5] * cps[4].m[0] +
                    weights[3] * weights[4] * weights[6] * cps[4].m[1] +
                    weights[3] * weights[4] * weights[7] * cps[4].m[2] +
                    weights[3] * weights[4] * weights[0] * cps[4].m[3] +
                    weights[3] * weights[4] * weights[1] * cps[4].m[4] +

                    weights[4] * weights[5] * weights[6] * cps[5].m[0] +
                    weights[4] * weights[5] * weights[7] * cps[5].m[1] +
                    weights[4] * weights[5] * weights[0] * cps[5].m[2] +
                    weights[4] * weights[5] * weights[1] * cps[5].m[3] +
                    weights[4] * weights[5] * weights[2] * cps[5].m[4] +

                    weights[5] * weights[6] * weights[7] * cps[6].m[0] +
                    weights[5] * weights[6] * weights[0] * cps[6].m[1] +
                    weights[5] * weights[6] * weights[1] * cps[6].m[2] +
                    weights[5] * weights[6] * weights[2] * cps[6].m[3] +
                    weights[5] * weights[6] * weights[3] * cps[6].m[4] +

                    weights[6] * weights[7] * weights[0] * cps[7].m[0] +
                    weights[6] * weights[7] * weights[1] * cps[7].m[1] +
                    weights[6] * weights[7] * weights[2] * cps[7].m[2] +
                    weights[6] * weights[7] * weights[3] * cps[7].m[3] +
                    weights[6] * weights[7] * weights[4] * cps[7].m[4] +

                    weights[0] * weights[6] * weights[2] * cps[0].m[5] +
                    weights[1] * weights[7] * weights[3] * cps[1].m[5] +
                    weights[2] * weights[0] * weights[4] * cps[2].m[5] +
                    weights[3] * weights[1] * weights[5] * cps[3].m[5] +
                    weights[4] * weights[2] * weights[6] * cps[4].m[5] +
                    weights[5] * weights[3] * weights[7] * cps[5].m[5] +
                    weights[6] * weights[4] * weights[0] * cps[6].m[5] +
                    weights[7] * weights[5] * weights[1] * cps[7].m[5] +

                    weights[0] * weights[5] * weights[3] * cps[0].m[6] +
                    weights[1] * weights[6] * weights[4] * cps[1].m[6] +
                    weights[2] * weights[7] * weights[5] * cps[2].m[6] +
                    weights[3] * weights[0] * weights[6] * cps[3].m[6] +
                    weights[4] * weights[1] * weights[7] * cps[4].m[6] +
                    weights[5] * weights[2] * weights[0] * cps[5].m[6] +
                    weights[6] * weights[3] * weights[1] * cps[6].m[6] +
                    weights[7] * weights[4] * weights[2] * cps[7].m[6]

                );
}


vec3 pnNormal() {
        return weights[0] * weights[0]  * normalize(tc_normal[0]) +
               weights[1] * weights[1]  * normalize(tc_normal[1]) +
               weights[2] * weights[2]  * normalize(tc_normal[2]) +
               weights[3] * weights[3]  * normalize(tc_normal[3]) +
               weights[4] * weights[4]  * normalize(tc_normal[4]) +
               weights[5] * weights[5]  * normalize(tc_normal[5]) +
               weights[6] * weights[6]  * normalize(tc_normal[6]) +
               weights[7] * weights[7]  * normalize(tc_normal[7]) +

                2.0*(
                 weights[0] * weights[7] * normalize(norms[0].n[0] + norms[7].n[6]) +
                 weights[0] * weights[6] * normalize(norms[0].n[1] + norms[6].n[5]) +
                 weights[0] * weights[5] * normalize(norms[0].n[2] + norms[5].n[4]) +
                 weights[0] * weights[4] * normalize(norms[0].n[3] + norms[4].n[3]) +
                 weights[0] * weights[3] * normalize(norms[0].n[4] + norms[3].n[2]) +
                 weights[0] * weights[2] * normalize(norms[0].n[5] + norms[2].n[1]) +
                 weights[0] * weights[1] * normalize(norms[0].n[6] + norms[1].n[0]) +

                 weights[1] * weights[7] * normalize(norms[1].n[1] + norms[7].n[5]) +
                 weights[1] * weights[6] * normalize(norms[1].n[2] + norms[6].n[4]) +
                 weights[1] * weights[5] * normalize(norms[1].n[3] + norms[5].n[3]) +
                 weights[1] * weights[4] * normalize(norms[1].n[4] + norms[4].n[2]) +
                 weights[1] * weights[3] * normalize(norms[1].n[5] + norms[3].n[1]) +
                 weights[1] * weights[2] * normalize(norms[1].n[6] + norms[2].n[0]) +

                 weights[2] * weights[7] * normalize(norms[2].n[2] + norms[7].n[4]) +
                 weights[2] * weights[6] * normalize(norms[2].n[3] + norms[6].n[3]) +
                 weights[2] * weights[5] * normalize(norms[2].n[4] + norms[5].n[2]) +
                 weights[2] * weights[4] * normalize(norms[2].n[5] + norms[4].n[1]) +
                 weights[2] * weights[3] * normalize(norms[2].n[6] + norms[3].n[0]) +

                 weights[3] * weights[7] * normalize(norms[3].n[3] + norms[7].n[3]) +
                 weights[3] * weights[6] * normalize(norms[3].n[4] + norms[6].n[2]) +
                 weights[3] * weights[5] * normalize(norms[3].n[5] + norms[5].n[1]) +
                 weights[3] * weights[4] * normalize(norms[3].n[6] + norms[4].n[0]) +

                 weights[4] * weights[7] * normalize(norms[4].n[4] + norms[7].n[2]) +
                 weights[4] * weights[6] * normalize(norms[4].n[5] + norms[6].n[1]) +
                 weights[4] * weights[5] * normalize(norms[4].n[6] + norms[5].n[0]) +

                 weights[5] * weights[7] * normalize(norms[5].n[5] + norms[7].n[1]) +
                 weights[5] * weights[6] * normalize(norms[5].n[6] + norms[6].n[0]) +

                 weights[6] * weights[7] * normalize(norms[6].n[6] + norms[7].n[0])


                );
}

bool boundaryConditionsPie() {
    if(gl_TessCoord[0] == 0.0) {
        if(gl_TessCoord[1] == 0.0) {
            weights[id2] = 1.0;
        } else if(gl_TessCoord[2] == 0.0) {
            weights[id1] = 1.0;
        } else {
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
    }

    position = evaluatePatchCub();

    if(quadNormals) {
        normal = pnNormal();
    } else {
        normal = phongInterpolate();
    }
    
    if(nMatrix){
        normal = normalize(normal_matrix * normalize(normal));
    }

    outWeights = weights;
    //position = mix(pos, position, alpha);
    gl_Position = matrix * vec4(position, 1.0);
    position = gl_Position.xyz;
}

