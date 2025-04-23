#version 400 core
layout(quads, fractional_odd_spacing, ccw) in;
in vec3[] tc_position;
in vec3[] tc_normal;
in vec2[] tc_param;
patch in int inst;

uniform float alpha;
uniform bool quadNormals;
uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform bool nMatrix;
uniform float pvalue;
uniform bool textureMode;
uniform int triangulation;

uniform sampler3D text;

float[8] weights = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

out vec3 position;
out vec3 normal;
out float[8] outWeights;

#define N gl_PatchVerticesIn
#define id1 (inst + 1) % N
#define id2 (inst + 2) % N


vec3 project(vec3 n, vec3 vertex, vec3 p) {
    return p - dot((p-vertex), n) * n;
}

vec3 refl(int i, vec3 n, vec3 p) {
    vec3 tc_position_ij = p - tc_position[i];
     return normalize(n - dot(tc_position_ij, tc_normal[i] + n)*tc_position_ij);
}

vec3 refl2(int i, int j, vec3 n) {
    vec3 plane = normalize(tc_position[j] - tc_position[i]);
    return n - 2.0*dot(n, plane)*plane;
}

vec3 project2(vec3 n, vec3 p, vec3 N, vec3 P) {
    vec3 plane = p-P;
    if(length(plane) == 0.0) return n;
    return (n - dot(n+N, plane)/dot(plane, plane)*plane);
}


int wrapper(int i, int n) {
    return i > 0 ? i % n : n + i;
}




float signedTriangleArea(vec2 v1, vec2 v2, vec2 v3) {
    return v2.x*v3.y + v3.x*v1.y + v1.x*v2.y - v2.x*v1.y - v1.x*v3.y - v3.x*v2.y;
}

void wachspress(vec2 p){
    if(N == 3) {
        weights[0] = gl_TessCoord[0];
        weights[1] = gl_TessCoord[1];
        weights[2] = gl_TessCoord[2];
        return;
    }
    vec2 vi, vi_plus1;
    float sumweights = 0.0;
    float A_i, A_iplus1;

    A_iplus1 = signedTriangleArea(tc_param[N-1], tc_param[0], p);
    for(int i = 0; i < N; i++) {
        A_i = A_iplus1;
        A_iplus1 = signedTriangleArea(tc_param[i], tc_param[wrapper(i+1, N)], p);
        weights[i] = 1.0/(A_i*A_iplus1);
        sumweights += weights[i];
    }

    for(int i = 0; i < N; i++) {
        weights[i] /= sumweights;
    }
}

vec3 phongTessellate(vec3 p) {
    vec3 sum = vec3(0.0, 0.0, 0.0);
    for(int i = 0; i < N; i++) {
        sum += weights[i] * project(tc_normal[i], tc_position[i], p);
    }
    return sum;
}

//linear interpolation of positiotc_normal
vec3 phongInterpolatePos() {
    vec3 sum = vec3(0.0, 0.0, 0.0);
    for(int i = 0; i < N; i++) {
        sum += weights[i] * tc_position[i];
    }
    return sum;
}

//linear interpolation of normals
vec3 phongInterpolate() {
    vec3 sum = vec3(0.0, 0.0, 0.0);
    for(int i = 0; i < N; i++) {
        sum += weights[i] * tc_normal[i];
    }
    return normalize(sum);
}

// calculation of quadratic normal field
vec3 pnNormal(vec3 n, vec3 p) {
    vec3 retn = vec3(0.0, 0.0, 0.0);
    vec3 intmn;
    for(int i = 0; i < N; i++) {
        intmn = vec3(0.0, 0.0, 0.0);
        for(int j = 0; j < N; j++) {
            intmn += weights[j] * project2(normalize(tc_normal[j]), tc_position[j], normalize(tc_normal[i]), tc_position[i]);
        }
        retn += weights[i] * intmn;
    }
    return normalize(retn);
}

// calculation of quadratic normal field
vec3 pnNormal2(vec3 n, vec3 p) {
    vec3 retn = vec3(0.0, 0.0, 0.0);
    vec3 intmn;
    for(int i = 0; i < N; i++) {
        intmn = vec3(0.0, 0.0, 0.0);
        for(int j = 0; j < N; j++) {
            if(i == j) {
                intmn += weights[j] * normalize(tc_normal[j]);
            } else {
                intmn += weights[j] * normalize(refl2(i, j, normalize(tc_normal[j])));
            }
        }
        retn += weights[i] * intmn;
    }
    return normalize(retn);
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

/* Takes two dimensional tex coords from the two layers of the 3d texture
 * Then orders them correctly into weights array such that based on inst
 * the correct GBC is matched to the correct vertex
 **/
void textureLookup(vec2 texCoords) {
    vec4 w1 = texture(text, vec3(texCoords, 0.0));
    vec4 w2 = texture(text, vec3(texCoords, 1.0));

    for(int i = 0; i < N; i++) {
        if(i < 4) {
            weights[(inst + (i % N)) % N] = w1[i];
        } else {
            weights[(inst + (i % N)) % N] = w2[i % 4];
        }
    }
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

    weights[0] = (1.0 - gl_TessCoord[0]) * (1.0 - gl_TessCoord[1]);
    weights[1] = gl_TessCoord[0] * (1.0 - gl_TessCoord[1]);
    weights[2] = gl_TessCoord[0] * gl_TessCoord[1];
    weights[3] = (1.0 - gl_TessCoord[0]) * gl_TessCoord[1];

//    // interpolated param position wrt triangulations methods
//    if(triangulation == 0) {
//        paramPos = gl_TessCoord[0] * tc_param[0]
//                + gl_TessCoord[1] * tc_param[id1]
//                + gl_TessCoord[2] * tc_param[id2];
//        bConditions = boundaryConditions();
//    } else if(textureMode){
//        paramPos = gl_TessCoord[2] * vec2(1.0, 0.0)
//                + gl_TessCoord[1] * vec2(0.0, 1.0);
//        bConditions = false;
//    } else {
//        paramPos = gl_TessCoord[1] * tc_param[id1]
//                + gl_TessCoord[2] * tc_param[id2];
//        bConditions = boundaryConditionsPie();
//    }

//    //if not on boundary calculate GBCS
//    if(!bConditions) {
//        if(textureMode) {
//            textureLookup(paramPos);
//        } else {
//            wachspress(paramPos);
//        }
//    }

    pos = phongInterpolatePos();

    if(quadNormals) {
        normal = pnNormal2(normal, pos);
    } else {
        normal = phongInterpolate();
    }

    position = phongTessellate(pos);

    outWeights = weights;
    position = mix(pos, position, alpha);
    gl_Position = matrix * vec4(position, 1.0);
    if(nMatrix){
        normal = normalize(normal_matrix * normal);
        position = gl_Position.xyz;
    }

}

