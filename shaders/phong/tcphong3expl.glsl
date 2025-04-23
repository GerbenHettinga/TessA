#version 400 core
in vec3[] position;
in vec3[] normal;
in vec2[] param;
flat in int[] instance;

uniform float tessInnerLevel;
uniform float tessOuterLevel;

layout(vertices = 3) out;
out vec3[] tc_position;
out vec3[] tc_normal;
out vec2[] tc_param;

struct edgeCoeff
{
    vec3 b;
};

out edgeCoeff[] edges;

vec3 project(vec3 n, vec3 vertex, vec3 p) {
    return p - dot((p-vertex), n) * n;
}

vec3 reflect(int i, int j) {
    vec3 plane = normalize(position[j] - position[i]);
    return normalize(normalize(normal[j]) - 2.0*dot(normalize(normal[j]), plane)*plane);
}

int wrapper(int i, int n) {
    if(i < 0){
        return n + i;
    }
    return i % n;
}

void main()
{
    // set inner outer tess level
    if (gl_InvocationID == 0){
        gl_TessLevelInner[0] = tessInnerLevel;
        gl_TessLevelOuter[0] = tessOuterLevel;
        gl_TessLevelOuter[1] = tessOuterLevel;
        gl_TessLevelOuter[2] = tessOuterLevel;
    }

    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
    tc_position[gl_InvocationID] = position[gl_InvocationID];
    tc_normal[gl_InvocationID] = normalize(normal[gl_InvocationID]);
    tc_param[gl_InvocationID] = param[gl_InvocationID];

    int p1 = wrapper(gl_InvocationID + 1, 3);
    int m1 = wrapper(gl_InvocationID - 1, 3);

    edges[gl_InvocationID].b = project(normalize(normal[p1]), position[p1], position[gl_InvocationID])
            + project(normalize(normal[gl_InvocationID]), position[gl_InvocationID], position[p1]);

}
