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
            if(pn) {
                flatPos = (2.0*ps[gl_PrimitiveIDIn] + ps[j])/3.0;
                patchPos = (project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], ps[j]) + 2.0*ps[gl_PrimitiveIDIn])/3.0;
                position = mix(flatPos, patchPos, alpha);
                normal = vec3(1.0, 0.0, 0.0);
                gl_Position = matrix * vec4(position, 1.0);
                EmitVertex();
            } else {
                flatPos = 0.5*ps[gl_PrimitiveIDIn] + 0.5*ps[j];
                patchPos = 0.5*project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], ps[j]) + 0.5*project(ns[j], ps[j], ps[gl_PrimitiveIDIn]);
                position = mix(flatPos, patchPos, alpha);
                normal = vec3(1.0, 0.0, 0.0);
                gl_Position = matrix * vec4(position, 1.0);
                EmitVertex();
            }


        }
    }



    if(pn) {
        int p1 = (gl_PrimitiveIDIn + 1) % polygonSize;

        int pt;
        for(int i=2; i < polygonSize; i++) {
            pt = wrapper(gl_PrimitiveIDIn + i, polygonSize);

            vec3 B = (ps[gl_PrimitiveIDIn] + ps[p1] + ps[pt])/3.0;
            patchPos = (3.0*B + 3.0*(project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], B/3.0) + project(ns[p1], ps[p1], B/3.0) + project(ns[pt], ps[pt], B/3.0)))/12.0;
            position = mix(B, patchPos, alpha);
            normal = vec3(0.0, 1.0, 0.0);
            gl_Position = matrix * vec4(position, 1.0);
            EmitVertex();
        }
    }
}
