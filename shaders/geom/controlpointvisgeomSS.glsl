#version 330
layout(points) in;
in vec3[] pos;
in vec3[] norm;

uniform mat4 matrix;
uniform vec3[3] ps;
uniform vec3[3] ns;
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

    int m1 = wrapper(gl_PrimitiveIDIn-1, 3);
    int p1 = (gl_PrimitiveIDIn + 1) % 3;

    vec3 T0 = p * project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], ps[m1]) + (1.0 - p) * ps[gl_PrimitiveIDIn];
    normal = vec3(1.0, 0.0, 0.0);
    gl_Position = matrix * vec4((3.0*T0 + ps[gl_PrimitiveIDIn])/4.0, 1.0);
    EmitVertex();

    vec3 T1 = p  * project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], ps[p1]) + (1.0 - p) * ps[gl_PrimitiveIDIn];
    normal = vec3(1.0, 0.0, 0.0);
    gl_Position = matrix * vec4((3.0*T1 + ps[gl_PrimitiveIDIn])/4.0, 1.0);
    EmitVertex();

    vec3 I1 = (T1 + T0 + ps[gl_PrimitiveIDIn])/3.0;
    normal = vec3(0.0, 0.0, 1.0);
    gl_Position = matrix * vec4(I1, 1.0);
    EmitVertex();

    vec3 m1T0 = p * project(ns[m1], ps[m1], ps[p1]) + (1.0 - p) * ps[m1];
    vec3 m1T1 = p * project(ns[m1], ps[m1], ps[gl_PrimitiveIDIn]) + (1.0 - p) * ps[m1];
    vec3 m1I1 = (m1T1 + m1T0 + ps[m1])/3.0;

    vec3 p1T0 = p * project(ns[p1], ps[p1], ps[gl_PrimitiveIDIn]) + (1.0 - p) * ps[p1];
    vec3 p1T1 = p * project(ns[p1], ps[p1], ps[m1]) + (1.0 - p) * ps[p1];
    vec3 p1I1 = (p1T1 + p1T0 + ps[p1])/3.0;

    vec3 H0 = T1 - ps[gl_PrimitiveIDIn];
    vec3 H0Hat = normalize(H0);
    vec3 H1 = p1T0 - T1;
    vec3 H2 = ps[p1] - p1T0;
    vec3 H2Hat = normalize(H2);

    vec3 F0 = (0.75*I1 + 0.25*ps[gl_PrimitiveIDIn]) - ps[gl_PrimitiveIDIn];
    vec3 F3 = (0.75*p1I1 + 0.25*ps[p1]) - ps[p1];

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

    vec3 L0 = (k1-k0)*C0/3.0 + 2.0*h0*H1/3.0 + h1*H0/3.0 + k0*C2;

    vec3 K0 = k1*C3 - (k1-k0)*C1/3.0 + h0*H2/3.0 + 2.0*h1*H1/3.0;

    //translate to boundary curve!
    L0 += T1;
    K0 += p1T0;

    position = L0;
    normal = vec3(0.0, 1.0, 0.0);
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();

    position = K0;
    normal = vec3(0.0, 1.0, 0.0);
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();


    H0 = m1T1 - ps[m1];
    H0Hat = normalize(H0);
    H1 = T0 - m1T1;
    H2 = ps[gl_PrimitiveIDIn] - T0;
    H2Hat = normalize(H2);

    F0 = (0.75*m1I1 + 0.25*ps[m1]) - ps[m1];
    F3 = (0.75*I1 + 0.25*ps[gl_PrimitiveIDIn]) - ps[gl_PrimitiveIDIn];

    //unit vector perpendiculars for basis patch
    C0 = -cross(H0Hat, normalize(ns[m1]));
    C1 = -cross(H2Hat, normalize(ns[gl_PrimitiveIDIn]));



    //find scalar ratios
    F0prime = dot(C0, F0) * C0;
    k0 = dot(C0, normalize(F0prime)) * length(F0prime);
    h0 = dot(H0Hat, normalize(F0-F0prime)) * length(F0 - F0prime)/length(H0);

    F3prime = dot(C1, F3) * C1;
    k1 = dot(C1, normalize(F3prime)) * length(F3prime);
    h1 = dot(H2Hat, normalize(F3-F3prime)) * length(F3 - F3prime)/length(H2);

    //linear interpolation for the other two vectors
    C2 = (2.0*C0 + C1)/3.0;
    C3 = (2.0*C1 + C0)/3.0;

    vec3 L2 = (k1-k0)*C0/3.0 + 2.0*h0*H1/3.0 + h1*H0/3.0 + k0*C2;

    vec3 K2 = k1*C3 - (k1-k0)*C1/3.0 + h0*H2/3.0 + 2.0*h1*H1/3.0;

    //translate to boundary curve!
    L2 += m1T1;
    K2 += T0;

    vec3 I2 = (4.0*K2 + 4.0*L0 - 3.0*I1 + ps[gl_PrimitiveIDIn])/6.0;
    normal = vec3(0.0, 0.0, 1.0);
    gl_Position = matrix * vec4(I2, 1.0);
    EmitVertex();

    H0 = p1T1 - ps[p1];
    H0Hat = normalize(H0);
    H1 = m1T0 - p1T1;
    H2 = ps[m1] - m1T0;
    H2Hat = normalize(H2);

    F0 = (0.75*p1I1 + 0.25*ps[p1]) - ps[p1];
    F3 = (0.75*m1I1 + 0.25*ps[m1]) - ps[m1];

    //unit vector perpendiculars for basis patch
    C0 = -cross(H0Hat, normalize(ns[p1]));
    C1 = -cross(H2Hat, normalize(ns[m1]));



    //find scalar ratios
    F0prime = dot(C0, F0) * C0;
    k0 = dot(C0, normalize(F0prime)) * length(F0prime);
    h0 = dot(H0Hat, normalize(F0-F0prime)) * length(F0 - F0prime)/length(H0);

    F3prime = dot(C1, F3) * C1;
    k1 = dot(C1, normalize(F3prime)) * length(F3prime);
    h1 = dot(H2Hat, normalize(F3-F3prime)) * length(F3 - F3prime)/length(H2);

    //linear interpolation for the other two vectors
    C2 = (2.0*C0 + C1)/3.0;
    C3 = (2.0*C1 + C0)/3.0;

    vec3 L1 = (k1-k0)*C0/3.0 + 2.0*h0*H1/3.0 + h1*H0/3.0 + k0*C2;

    vec3 K1 = k1*C3 - (k1-k0)*C1/3.0 + h0*H2/3.0 + 2.0*h1*H1/3.0;

    //translate to boundary curve!
    L1 += p1T1;
    K1 += m1T0;

    vec3 p1I2 = (4.0*K0 + 4.0*L1 - 3.0*p1I1 + ps[p1])/6.0;
    vec3 m1I2 = (4.0*K1 + 4.0*L2 - 3.0*m1I1 + ps[m1])/6.0;

    vec3 N = (-I1 - p1I1 + m1I1 + 4.0*I2 + 4.0*p1I2 - 3.0*m1I2)/4.0;
    normal = vec3(0.0, 1.0, 0.0);
    gl_Position = matrix * vec4(N, 1.0);
    EmitVertex();


    vec3 S = (I2 + p1I2 + m1I2)/3.0;
    normal = vec3(0.0, 0.0, 1.0);
    gl_Position = matrix * vec4(S, 1.0);
    EmitVertex();

}
