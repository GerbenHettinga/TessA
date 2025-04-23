#version 330
layout(points) in;
in vec3[] pos;
in vec3[] norm;

uniform mat4 matrix;
uniform vec3[8] ps;
uniform vec3[8] ns;
uniform int polygonSize;
uniform float alpha;
uniform bool triang;
uniform float p;

layout(line_strip, max_vertices = 128) out;
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
    gl_Position = matrix * vec4(ps[gl_PrimitiveIDIn], 1.0);
    position = ps[gl_PrimitiveIDIn];
    normal = ns[gl_PrimitiveIDIn];
    EmitVertex();

    vec3 flatPos;
    vec3 patchPos;

    vec3 T1;
    vec3 T0p1;

    int p1, m1, p2;
    p1 = (gl_PrimitiveIDIn + 1) % polygonSize;
    m1 = wrapper(gl_PrimitiveIDIn - 1, polygonSize);
    p2 = (gl_PrimitiveIDIn + 2) % polygonSize;

    flatPos = (2.0*ps[gl_PrimitiveIDIn] + ps[p1])/3.0;
    patchPos = (project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], ps[p1]) + 2.0*ps[gl_PrimitiveIDIn])/3.0;
    T1 = patchPos;
    vec3 T0 = (project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], ps[m1]) + 2.0*ps[gl_PrimitiveIDIn])/3.0;

    position = mix(flatPos, patchPos, alpha);
    normal = ns[gl_PrimitiveIDIn];
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();

    flatPos = (ps[gl_PrimitiveIDIn] + 2.0*ps[p1])/3.0;

    patchPos = (project(ns[p1], ps[p1], ps[gl_PrimitiveIDIn]) + 2.0*ps[p1])/3.0;
    T0p1 = patchPos;
    position = mix(flatPos, patchPos, alpha);
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();

    vec3 T1p1 = (project(ns[p1], ps[p1], ps[p2]) + 2.0*ps[p1])/3.0;

    gl_Position = matrix * vec4(ps[p1], 1.0);
    position = ps[p1];
    normal = ns[p1];
    EmitVertex();

    EndPrimitive();

    vec3 L0 = T1;
    vec3 K0 = T0p1;

    vec3 H0 = T1 - ps[gl_PrimitiveIDIn];
    vec3 H0Hat = normalize(H0);
    vec3 H1 = T0p1 - T1;
    vec3 H2 = ps[p1] - T0p1;
    vec3 H2Hat = normalize(H2);

    vec3 F0 = T0  - ps[gl_PrimitiveIDIn];
    vec3 F3 = T1p1  - ps[p1];



    //unit vector perpendiculars for basis patch
    vec3 C0 = -cross(H0Hat, normalize(ns[gl_PrimitiveIDIn]));
    vec3 C1 = -cross(H2Hat, normalize(ns[p1]));

    float k0, h0, k1, h1;

    //find scalar ratios
    vec3 F0prime = dot(C0, F0) * C0;
    k0 = dot(C0, normalize(F0prime)) * length(F0prime);
    h0 = dot(H0Hat, normalize(F0-F0prime)) * length(F0 - F0prime)/length(H0);

    vec3 F3prime = dot(C1, F3) * C1;
    k1 = dot(C1, normalize(F3prime)) * length(F3prime);
    h1 = dot(H2Hat, normalize(F3-F3prime)) * length(F3 - F3prime)/length(H2);

    //linear interpolation for the other two vectors
    vec3 C2 = (2.0*C0 + C1)/3.0;
    vec3 C3 = (2.0*C1 + C0)/3.0;

    L0 += (k1-k0)*C0/3.0 + 2.0*h0*H1/3.0 + h1*H0/3.0 + k0*C2;

    K0 += k1*C3 - (k1-k0)*C1/3.0 + h0*H2/3.0 + 2.0*h1*H1/3.0;

    gl_Position = matrix * vec4(T0, 1.0);
    position = T0;
    normal = ns[p1];
    EmitVertex();

    gl_Position = matrix * vec4(L0, 1.0);
    position = L0;
    normal = ns[p1];
    EmitVertex();



    gl_Position = matrix * vec4(K0, 1.0);
    position = K0;
    normal = ns[p1];
    EmitVertex();


    gl_Position = matrix * vec4(T1p1, 1.0);
    position = T1p1;
    normal = ns[p1];
    EmitVertex();

    EndPrimitive();


}
