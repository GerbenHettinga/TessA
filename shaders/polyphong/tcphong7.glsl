#version 400 core
in vec3[] position;
in vec3[] normal;
flat in int[] instance;

uniform float tessInnerLevel;
uniform float tessOuterLevel;


layout(vertices = 7) out;
out vec3[] tc_position;
out vec3[] tc_normal;
out vec2[] tc_param;
patch out int inst;

vec3 project(vec3 n, vec3 vertex, vec3 p) {
    return p - dot((p-vertex), n) * n;
}

vec2 param[8] = vec2[](  vec2(1.0, 0.0),
                            vec2(0.62349, 0.781832),
                            vec2(-0.222521, 0.974928),
                            vec2(-0.900969, 0.433884),
                            vec2(-0.900969, -0.433884),
                            vec2(-0.222521, -0.974928),
                            vec2(0.62349, -0.781831), vec2(0.0));

void main()
{
    // set inner outer tess level
    if (gl_InvocationID == 0){
        gl_TessLevelInner[0] = tessInnerLevel;
        gl_TessLevelOuter[0] = tessOuterLevel;
        gl_TessLevelOuter[1] = tessOuterLevel;
        gl_TessLevelOuter[2] = tessOuterLevel;
        inst = instance[0];
    }

    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
    tc_position[gl_InvocationID] = position[gl_InvocationID];
    tc_normal[gl_InvocationID] = normal[gl_InvocationID];
    tc_param[gl_InvocationID] = param[gl_InvocationID];


}
