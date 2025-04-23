#version 400 core
in vec3[] position;
in vec3[] normal;

uniform float tessInnerLevel;
uniform float tessOuterLevel;

uniform bool pn;

layout(vertices = 2) out;
out vec3[] tc_position;
out vec3[] tc_normal;
out vec3[] T;

vec3 project(vec3 n, vec3 vertex, vec3 p) {
    return p - dot((p-vertex), n) * n;
}

void main()
{
    // set inner outer tess level
    if (gl_InvocationID == 0){
        gl_TessLevelOuter[0] = 1.0;
        gl_TessLevelOuter[1] = 50.0;
    }

    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
    tc_position[gl_InvocationID] = position[gl_InvocationID];
    tc_normal[gl_InvocationID] = normal[gl_InvocationID];

    int p1 = (gl_InvocationID + 1) % 2;

    if(pn) {
        T[gl_InvocationID] = 2.0 * position[gl_InvocationID] + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p1]);
    } else {
        T[gl_InvocationID] = project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p1]);
    }
}
