#version 400 core
in vec3[] position;
in vec3[] normal;
flat in int[] instance;

uniform float tessInnerLevel;
uniform float tessOuterLevel;

layout(vertices = 8) out;
out vec3[] tc_position;
out vec3[] tc_normal;
out vec2[] tc_param;
patch out int inst;

vec2 param[8] = vec2[](  vec2(1.0, 0.0),
                            vec2(0.707107, 0.707107),
                            vec2(0.0, 1.0),
                            vec2(-0.707107, 0.707107),
                            vec2(-1, 0.0),
                            vec2(-0.707107, -0.707107),
                            vec2(0.0, -1.0),
                            vec2(0.707107, -0.707107));

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
    tc_normal[gl_InvocationID] = normalize(normal[gl_InvocationID]);
    tc_param[gl_InvocationID] = param[gl_InvocationID];


}
