#version 330
layout(points) in;
in vec3[] pos;
in vec3[] norm;

uniform mat4 matrix;
uniform vec3[8] ps;
uniform vec3[8] ns;
uniform int polygonSize;
uniform float alpha;
uniform bool pn;
uniform bool ct;
uniform float p;

layout(points, max_vertices = 32) out;
out vec3 normal;
out vec3 position;

vec3 project(vec3 n, vec3 vertex, vec3 p) {
    return p - dot((p-vertex), n) * n;
}

int wrapper(int i, int n) {
    if(i < 0){
        return n + i;
    }
    return i % n;
}

void main()
{
    vec3 flatPos;
    vec3 patchPos;
    for(int j = 0; j < polygonSize; j++) {
        if(gl_PrimitiveIDIn != j) {
            if(abs(j-gl_PrimitiveIDIn) != 1 && abs(j-gl_PrimitiveIDIn) != polygonSize-1) {
                continue;
            }
            flatPos = (2.0*ps[gl_PrimitiveIDIn] + ps[j])/3.0;
            patchPos = (project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], ps[j]) + 2.0*ps[gl_PrimitiveIDIn])/3.0;
            position = mix(flatPos, patchPos, alpha);
            normal = vec3(1.0, 0.0, 0.0);
            gl_Position = matrix * vec4(position, 1.0);
            EmitVertex();
        }
    }


    int m1 = wrapper(gl_PrimitiveIDIn-1, 3);
    int p1 = (gl_PrimitiveIDIn + 1) % 3;

    vec3 centre = (ps[gl_PrimitiveIDIn] + ps[p1] + ps[m1])/3.0;

    flatPos = (centre + 2.0*ps[gl_PrimitiveIDIn])/3.0;
    patchPos = (project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], centre) + 2.0*ps[gl_PrimitiveIDIn])/3.0;
    position = mix(flatPos, patchPos, alpha);
    normal = vec3(0.0, 1.0, 0.0);
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();


    vec3 T_0 = (project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], ps[p1]) + 2.0*ps[gl_PrimitiveIDIn])/3.0;
    vec3 T_1 = (project(ns[p1], ps[p1], ps[gl_PrimitiveIDIn]) + 2.0*ps[p1])/3.0;

    vec3 edgeVec0 = cross(normalize(ns[gl_PrimitiveIDIn]), normalize(T_0 - ps[gl_PrimitiveIDIn]));
    vec3 edgeVec1 = cross(normalize(T_1 - ps[p1]), normalize(ns[p1]));

    vec3 contrPolyCentre1 = (T_0 + T_1)*0.5;

    float rat0 = length(T_0 - ps[gl_PrimitiveIDIn]);
    float rat1 = length(T_1 - ps[p1]);


    vec3 F_0 = edgeVec0;


    position = (T_0 + ps[gl_PrimitiveIDIn])*0.5 + F_0 * rat0 * tan(p);
    normal = vec3(0.0, 0.0, 1.0);
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();

    vec3 F_1 = edgeVec1;

    position = (T_1 + ps[p1])*0.5 + F_1 * rat1 * tan(p);
    normal = vec3(0.0, 0.0, 1.0);
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();

    vec3 avgNormal = normalize(ns[gl_PrimitiveIDIn] + ns[p1]);
    vec3 cbt = cross(normalize(T_0 - T_1), avgNormal);

    vec3 eCentre = (T_0 + T_1)/2.0;
    float ratio = length(T_0 - T_1);
    vec3 C = eCentre + cbt * tan(p) * ratio;

    position = C;
    normal = vec3(0.0, 1.0, 0.0);
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();
}
