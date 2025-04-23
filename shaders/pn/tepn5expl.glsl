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
    vec3 b[4];
    vec3 m[2];
};

struct normCoeff
{
    vec3 n[4];
};

patch in int inst;

in normCoeff[] norms;

in coeff cps[];

float[8] weights = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

vec2 tc_param[8] = vec2[](  vec2(1.0, 0.0),
                            vec2(0.309017, 0.951057),
                            vec2(-0.809017, 0.587785),
                            vec2(-0.809017, -0.587785),
                            vec2(0.309017, -0.951056),
                            vec2(0.0), vec2(0.0), vec2(0.0));

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
    return v2.x*v3.y + v3.x*v1.y + v1.x*v2.y - v2.x*v1.y - v1.x*v3.y - v3.x*v2.y;
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
        vi_plus1 = tc_param[wrapper(i+1, N)];

        A_i = A_iplus1;
        A_iplus1 = signedTriangleArea(vi, vi_plus1, p);
        weights[i] = 1.0/(A_i*A_iplus1);
        sumweights += weights[i];
    }
    for(int i = 0; i < N; i++) {
        weights[i] /= sumweights;
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

                 sqd[0] * weights[4] * cps[0].b[0] +
                 sqd[0] * weights[3] * cps[0].b[1] +
                 sqd[0] * weights[2] * cps[0].b[2] +
                 sqd[0] * weights[1] * cps[0].b[3] +

                 sqd[1] * weights[0] * cps[1].b[0] +
                 sqd[1] * weights[4] * cps[1].b[1] +
                 sqd[1] * weights[3] * cps[1].b[2] +
                 sqd[1] * weights[2] * cps[1].b[3] +

                 sqd[2] * weights[1] * cps[2].b[0] +
                 sqd[2] * weights[0] * cps[2].b[1] +
                 sqd[2] * weights[4] * cps[2].b[2] +
                 sqd[2] * weights[3] * cps[2].b[3] +

                 sqd[3] * weights[2] * cps[3].b[0] +
                 sqd[3] * weights[1] * cps[3].b[1] +
                 sqd[3] * weights[0] * cps[3].b[2] +
                 sqd[3] * weights[4] * cps[3].b[3] +

                 sqd[4] * weights[3] * cps[4].b[0] +
                 sqd[4] * weights[2] * cps[4].b[1] +
                 sqd[4] * weights[1] * cps[4].b[2] +
                 sqd[4] * weights[0] * cps[4].b[3]
            +
                6.0 * (
                     weights[4] * weights[0] * weights[1] * cps[0].m[0] +
                     weights[0] * weights[1] * weights[2] * cps[1].m[0] +
                     weights[1] * weights[2] * weights[3] * cps[2].m[0] +
                     weights[2] * weights[3] * weights[4] * cps[3].m[0] +
                     weights[3] * weights[4] * weights[0] * cps[4].m[0] +
                     weights[0] * weights[2] * weights[4] * cps[0].m[1] +
                     weights[1] * weights[3] * weights[0] * cps[1].m[1] +
                     weights[2] * weights[4] * weights[1] * cps[2].m[1] +
                     weights[3] * weights[0] * weights[2] * cps[3].m[1] +
                     weights[4] * weights[1] * weights[3] * cps[4].m[1]
                );
}


vec3 pnNormal() {
    return weights[0] * weights[0] * normalize(tc_normal[0]) +
           weights[1] * weights[1] * normalize(tc_normal[1]) +
           weights[2] * weights[2] * normalize(tc_normal[2]) +
           weights[3] * weights[3] * normalize(tc_normal[3]) +
           weights[4] * weights[4] * normalize(tc_normal[4]) +

           2.0 * (
               weights[0] * weights[4] * normalize(norms[0].n[0] + norms[4].n[3]) +
               weights[0] * weights[3] * normalize(norms[0].n[1] + norms[3].n[2]) +
               weights[0] * weights[2] * normalize(norms[0].n[2] + norms[2].n[1]) +
               weights[0] * weights[1] * normalize(norms[0].n[3] + norms[1].n[0]) +

               weights[1] * weights[4] * normalize(norms[1].n[1] + norms[4].n[2]) +
               weights[1] * weights[3] * normalize(norms[1].n[2] + norms[3].n[1]) +
               weights[1] * weights[2] * normalize(norms[1].n[3] + norms[2].n[0]) +

               weights[2] * weights[4] * normalize(norms[2].n[2] + norms[4].n[1]) +
               weights[2] * weights[3] * normalize(norms[2].n[3] + norms[3].n[0]) +

               weights[3] * weights[4] * normalize(norms[3].n[3] + norms[4].n[0])
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

