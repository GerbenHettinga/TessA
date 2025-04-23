#version 400 core
layout(/*LAYOUT FLAG*/, fractional_odd_spacing, ccw) in;
in vec3[] tc_position;
in vec3[] tc_normal;
patch in int inst;

uniform mat4 matrix;
uniform mat3 normal_matrix;
uniform bool nMatrix;
uniform int triangulation;
uniform bool textureMode;
uniform bool captureGeometry;

uniform sampler3D text;

float[8] weights = float[8](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

out vec3 position;
out vec3 normal;
out float[8] outWeights;
out vec3 outColour;

/*PARAM FLAG*/

/*DEFINE N FLAG*/
#define id1 (inst * 2 + 1) % N
#define id2 (inst * 2 + 2) % N
#define id3 (inst * 2 + 3) % N


float signedTriangleArea(vec2 v1, vec2 v2, vec2 v3) {
    return v2.x*v3.y + v3.x*v1.y + v1.x*v2.y - v2.x*v1.y - v1.x*v3.y - v3.x*v2.y;
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


//linear interpolation of positiotc_normal
vec3 phongInterpolatePos() {
    vec3 sum = vec3(0.0, 0.0, 0.0);
    for(int i = 0; i < N; ++i) {
       sum += weights[i] * tc_position[i];
    }
    return sum;
}

//linear interpolation of normals
vec3 phongInterpolate() {
    vec3 sum = vec3(0.0);
    for(int i = 0; i < N; ++i) {
       sum += weights[i] * tc_normal[i];
    }
    return normalize(sum);
}


//check for boundary conditions
bool boundaryConditions()   {
    if(gl_TessCoord[0] == 0.0) {
        if(gl_TessCoord[1] == 0.0) {
            weights[0] = 1.0;
        } else if(gl_TessCoord[1] == 1.0) {
            weights[id3] = 1.0;
        } else {
            if(id3 == (N-1)) {
                weights[0] = (1.0 - gl_TessCoord[1]);
                weights[id3] = gl_TessCoord[1];
            } else {
                return false;
            }
        }
        return true;
    } else if(gl_TessCoord[0] == 1.0) {
        if(gl_TessCoord[1] == 0.0) {
            weights[id1] = 1.0;
        } else if(gl_TessCoord[1] == 1.0) {
            weights[id2] = 1.0;
        } else {
            weights[id1] = (1.0-gl_TessCoord[1]);
            weights[id2] = gl_TessCoord[1];
        }
        return true;
    } else if(gl_TessCoord[1] == 0.0) {
        if(id1 == 1) {
            weights[0] = (1.0-gl_TessCoord[0]);
            weights[id1] = gl_TessCoord[0];
            return true;
        }
    } else if(gl_TessCoord[1] == 1.0) {
        weights[id3] = (1.0-gl_TessCoord[0]);
        weights[id2] = gl_TessCoord[0];
        return true;
    }
    return false;
}

bool boundaryConditionsPie() {
    if(gl_TessCoord[0] == 0.0) {
        if(gl_TessCoord[1] == 1.0) {
            weights[id3] = 1.0;
            return true;
        }
    } else if(gl_TessCoord[0] == 1.0) {
        if(gl_TessCoord[1] == 0.0) {
            weights[id1] = 1.0;
            return true;
        } else if(gl_TessCoord[1] == 1.0) {
            weights[id2] = 1.0;
            return true;
        } else {
            weights[id1] = (1.0 - gl_TessCoord[1]);
            weights[id2] = gl_TessCoord[1];
            return true;
        }
    } else if(gl_TessCoord[1] == 1.0) {
        weights[id3] = (1.0 - gl_TessCoord[0]);
        weights[id2] = gl_TessCoord[0];
        return true;
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

    int instx2 = inst*2;
    weights[instx2] = w1[0];
    weights[(instx2 + 1) % N] = w1[1];
    weights[(instx2 + 2) % N] = w1[2];
    weights[(instx2 + 3) % N] = w1[3];

    weights[(instx2 + 4 ) % N] = w2[0];
    weights[(instx2 + (5 % N) ) % N] = w2[1];
    if(N > 6) {
        weights[(instx2 + (6 % N) ) % N] = w2[2];
        weights[(instx2 + (7 % N) ) % N] = w2[3];
    }
}

void main() {
    vec2 paramPos;
    bool bConditions = false;

    if(N > 4) {
        // interpolated param position wrt triangulations methods
        if(triangulation == 0) {
            paramPos = (1.0 - gl_TessCoord[0]) * (1.0 - gl_TessCoord[1]) * tc_param[0]
                    + gl_TessCoord[0] * (1.0 - gl_TessCoord[1]) * tc_param[id1]
                    + gl_TessCoord[0] * gl_TessCoord[1] * tc_param[id2]
                    + (1.0 - gl_TessCoord[0]) * gl_TessCoord[1] * tc_param[id3];
            bConditions = boundaryConditions();
        } else if(textureMode) {
            paramPos = gl_TessCoord[0] * (1.0 - gl_TessCoord[1]) * vec2(1.0, 0.0)
                    + gl_TessCoord[0] * gl_TessCoord[1] * vec2(1.0, 1.0)
                    + (1.0 - gl_TessCoord[0]) * gl_TessCoord[1] * vec2(0.0, 1.0);
        } else {
            paramPos = gl_TessCoord[0] * (1.0 - gl_TessCoord[1]) * tc_param[id1]
                    + gl_TessCoord[0] * gl_TessCoord[1] * tc_param[id2]
                    + (1.0 - gl_TessCoord[0]) * gl_TessCoord[1] * tc_param[id3];
            bConditions = boundaryConditionsPie();
        }


        if(textureMode) {
            textureLookup(paramPos);
        } else if(!bConditions) {
            wachspress(paramPos);
        }
    } else {
        weights[0] = (1.0 - gl_TessCoord[0]) * (1.0 - gl_TessCoord[1]);
        weights[1] = gl_TessCoord[0] * (1.0 - gl_TessCoord[1]);
        weights[2] = gl_TessCoord[0] * gl_TessCoord[1];
        weights[3] = (1.0 - gl_TessCoord[0]) * gl_TessCoord[1];
    }

    position = phongInterpolatePos();
    outWeights = weights;

    outColour = vec3(8.0/N, 1.0-8.0/N, (1.0-8.0/N)*0.5);



    if(nMatrix){
        normal = normalize(normal_matrix * normal);
    }

    if(captureGeometry) {
        gl_Position = vec4(position, 1.0);
    } else {
        gl_Position = matrix * vec4(position, 1.0);
    }
    position = gl_Position.xyz;

}

