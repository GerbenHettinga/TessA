#version 400 core
layout(isolines, equal_spacing) in;
in vec3[] tc_position;
in vec3[] tc_normal;
in vec3[] T;

uniform float alpha;
uniform bool pn;
uniform mat4 matrix;
//uniform float pvalue;

out vec3 position;
out vec3 normal;


vec3 evaluateLineQuad() {
    vec3 tc = gl_TessCoord;
    vec3 sqd = gl_TessCoord*gl_TessCoord;

        return sqd[0] * tc_position[0] +
               (1.0 - sqd[0])*(1.0 - sqd[0]) * tc_position[1] +
               tc.x * (1.0 - tc.x) * (T[0] + T[1]);

}

vec3 evaluateLineCub() {
    vec3 sqd = gl_TessCoord*gl_TessCoord;
    vec3 tc = gl_TessCoord;

    return sqd[0] * tc.x * tc_position[0] +
           (1.0 - sqd[0])*(1.0 - sqd[0])*(1.0 - sqd[0]) * tc_position[1] +
           sqd[0] * (1.0 - tc.x) * T[0] +
           (1.0 - tc.x) * (1.0 - tc.x) * tc.x * T[1];
}


void main() {
    vec3 pos = gl_TessCoord[0] * tc_position[0] + (1.0 -gl_TessCoord[0]) * tc_position[1];
    vec3 normal = gl_TessCoord[0] * tc_normal[0] + (1.0 - gl_TessCoord[1]) * tc_normal[1];

    if(pn) {
        position = evaluateLineCub();
    } else {
        position = evaluateLineQuad();
    }

    position = mix(pos, position, alpha);
    gl_Position = matrix * vec4(position, 1.0);
    position = gl_Position.xyz;
}

