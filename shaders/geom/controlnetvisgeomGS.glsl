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
uniform bool triang;
uniform float p;

layout(line_strip, max_vertices = 64) out;
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

    vec3 left[6];
    vec3 leftm[6];
    vec3 rightm[6];
    vec3 right[6];

    vec3 flatPos;
    vec3 patchPos;

    vec3 T1;
    vec3 p1T0;

    int p1, m1, p2;
    p1 = (gl_PrimitiveIDIn + 1) % polygonSize;
    m1 = wrapper(gl_PrimitiveIDIn - 1, polygonSize);
    p2 = (gl_PrimitiveIDIn + 2) % polygonSize;


    flatPos = (2.0*ps[gl_PrimitiveIDIn] + ps[p1])/3.0;
    patchPos = p * project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], ps[p1]) + (1.0 - p) * ps[gl_PrimitiveIDIn];
    T1 = patchPos;
    position = mix(flatPos, patchPos, alpha);
    normal = vec3(1.0, 0.0, 0.0);
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();

    flatPos = (ps[gl_PrimitiveIDIn] + 2.0*ps[p1])/3.0;
    patchPos = p * project(ns[p1], ps[p1], ps[gl_PrimitiveIDIn]) + (1.0 - p) * ps[p1];
    p1T0 = patchPos;
    position = mix(flatPos, patchPos, alpha);
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();

    gl_Position = matrix * vec4(ps[p1], 1.0);
    position = ps[gl_PrimitiveIDIn];
    normal = ns[gl_PrimitiveIDIn];
    EmitVertex();

    EndPrimitive();

    vec3 H0 = T1 - ps[gl_PrimitiveIDIn];
    vec3 H0Hat = normalize(H0);
    vec3 H1 = p1T0 - T1;
    vec3 H2 = ps[p1] - p1T0;
    vec3 H2Hat = normalize(H2);

    //unit vector perpendiculars for basis patch
    vec3 C0 = -cross(H0Hat, normalize(ns[gl_PrimitiveIDIn]));
    vec3 C1 = -cross(H2Hat, normalize(ns[p1]));

    for(int i = 2; i < polygonSize; i++) {

        int pt = (gl_PrimitiveIDIn + i) % polygonSize;

        vec3 Fp = p * project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], ps[pt]) + (1.0 - p) * ps[gl_PrimitiveIDIn];
        normal = vec3(1.0, 0.0, 0.0);
        gl_Position = matrix * vec4((3.0*Fp + ps[gl_PrimitiveIDIn])/4.0, 1.0);
        //EmitVertex();


        vec3 Fp2 = p * project(ns[p1], ps[p1], ps[pt]) + (1.0 - p) * ps[p1];
        normal = vec3(1.0, 0.0, 0.0);
        gl_Position = matrix * vec4((3.0*Fp2 + ps[p1])/4.0, 1.0);
        //EmitVertex();

        vec3 F0 = (0.75*Fp + 0.25*ps[gl_PrimitiveIDIn]) - ps[gl_PrimitiveIDIn];
        vec3 F3 = (0.75*Fp2 + 0.25*ps[p1]) - ps[p1];

        left[i-2] = (0.75*Fp + 0.25*ps[gl_PrimitiveIDIn]);
        right[i-2] = (0.75*Fp2 + 0.25*ps[p1]);

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

        leftm[i-2] = L0;
        rightm[i-2] = K0;

        position = T1;
        normal = vec3(1.0, 0.0, 0.0);
        gl_Position = matrix * vec4(position, 1.0);
        EmitVertex();

        position = L0;
        normal = vec3(0.0, 1.0, 0.0);
        gl_Position = matrix * vec4(position, 1.0);
        EmitVertex();

        EndPrimitive();

        position = p1T0;
        normal = vec3(1.0, 0.0, 0.0);
        gl_Position = matrix * vec4(position, 1.0);
        EmitVertex();

        position = K0;
        normal = vec3(0.0, 1.0, 0.0);
        gl_Position = matrix * vec4(position, 1.0);
        EmitVertex();


        EndPrimitive();

    }

    normal = vec3(1.0, 0.0, 0.0);
    position = ps[gl_PrimitiveIDIn];
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();
    for(int i = polygonSize-3; i >= 0; i--) {
        position = left[i];
        gl_Position = matrix * vec4(left[i], 1.0);
        EmitVertex();
    }
    position = (0.25*ps[gl_PrimitiveIDIn] + 0.75*T1);
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();
    EndPrimitive();


    position = (0.25*ps[p1] + 0.75*p1T0);
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();
    for(int i = polygonSize-3; i >= 0; i--) {
        position = right[i];
        gl_Position = matrix * vec4(position, 1.0);
        EmitVertex();
    }
    position = ps[p1];
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();
    EndPrimitive();

    normal = vec3(0.0, 1.0, 0.0);
    position = (0.25*ps[gl_PrimitiveIDIn] + 0.75*T1);
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();
    for(int i = polygonSize-3; i >= 0; i--) {
        position = leftm[i];
        gl_Position = matrix * vec4(position, 1.0);
        EmitVertex();
    }
    position = 0.5*(T1 + p1T0);
    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();
    EndPrimitive();

    gl_Position = matrix * vec4(position, 1.0);
    EmitVertex();
    for(int i = polygonSize-3; i >= 0; i--) {
        position = rightm[i];
        gl_Position = matrix * vec4(position, 1.0);
        EmitVertex();
    }
    position = (0.25*ps[p1] + 0.75*p1T0);
    gl_Position = matrix * vec4(position , 1.0);
    EmitVertex();
    EndPrimitive();

}

