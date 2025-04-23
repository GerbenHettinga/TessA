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

    vec3[8] T1s;
    vec3[8] T2s;
    vec3[8] T3s;
    vec3[8] T4s;

    vec3 flatPos;
    vec3 patchPos;
    int pt;
    for(int j = 1; j < polygonSize + 1; j++) {
        pt = (gl_PrimitiveIDIn + j) % polygonSize;
        if(gl_PrimitiveIDIn != pt) {
            if(pn) {

                flatPos = (2.0*ps[gl_PrimitiveIDIn] + ps[pt])/3.0;
                patchPos = (project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], ps[pt]) + 2.0*ps[gl_PrimitiveIDIn])/3.0;
                position = mix(flatPos, patchPos, alpha);
                normal = ns[gl_PrimitiveIDIn];
                gl_Position = matrix * vec4(position, 1.0);
                EmitVertex();

                T1s[j-1] = patchPos;
                T2s[j-1] = flatPos;

                flatPos = (ps[gl_PrimitiveIDIn] + 2.0*ps[pt])/3.0;
                patchPos = (project(ns[pt], ps[pt], ps[gl_PrimitiveIDIn]) + 2.0*ps[pt])/3.0;
//                position = mix(flatPos, patchPos, alpha);
//                normal = ns[j % polygonSize];
//                gl_Position = matrix * vec4(position, 1.0);
//                EmitVertex();

                T3s[j-1] = patchPos;
                T4s[j-1] = flatPos;

                //EndPrimitive();

            } else {
                flatPos = 0.5*ps[gl_PrimitiveIDIn] + 0.5*ps[pt];
                patchPos = 0.5*project(normalize(ns[gl_PrimitiveIDIn]), ps[gl_PrimitiveIDIn], ps[pt]) + 0.5*project(normalize(ns[pt]), ps[pt], ps[gl_PrimitiveIDIn]);
                position = mix(flatPos, patchPos, alpha);
                normal = ns[gl_PrimitiveIDIn];
                gl_Position = matrix * vec4(position, 1.0);
                EmitVertex();
            }
        }
    }



        gl_Position = matrix * vec4(ps[gl_PrimitiveIDIn], 1.0);
        position = ps[gl_PrimitiveIDIn];
        normal = ns[gl_PrimitiveIDIn];
        EmitVertex();

        EndPrimitive();

     if(pn) {
//        gl_Position = matrix * vec4(ps[gl_PrimitiveIDIn], 1.0);
//        position = ps[gl_PrimitiveIDIn];
//        normal = ns[gl_PrimitiveIDIn];
//        EmitVertex();


        int p1,p2;
        p1 = wrapper(gl_PrimitiveIDIn + 1, polygonSize);
        p2 = wrapper(gl_PrimitiveIDIn + 2, polygonSize);



        position = mix(T4s[0], T3s[0], alpha);
        normal = vec3(0.0, 0.0, 1.0);
        gl_Position = matrix * vec4(position, 1.0);
        EmitVertex();


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

        position = mix(T2s[0], T1s[0], alpha);
        normal = vec3(0.0, 1.0, 0.0);
        gl_Position = matrix * vec4(position, 1.0);
        EmitVertex();

        position = mix(T4s[0], T3s[0], alpha);
        normal = vec3(0.0, 0.0, 1.0);
        gl_Position = matrix * vec4(position, 1.0);
        EmitVertex();


        EndPrimitive();


//        for(int i = 1; i < polygonSize-1; i++) {
//            p1 = (gl_PrimitiveIDIn + i) % polygonSize;
//            p2 = (gl_PrimitiveIDIn + i + 1) % polygonSize;
//                mix(T2s[i - 1], T1s[i - 1], alpha);
//                normal = vec3(0.0, 1.0, 0.0);
//                gl_Position = matrix * vec4(position, 1.0);
//                EmitVertex();


//                vec3 B = (ps[gl_PrimitiveIDIn] + ps[p1] + ps[p2])/3.0;
//                patchPos = (3.0*B + 3.0*(project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], B/3.0) + project(ns[p1], ps[p1], B/3.0) + project(ns[p2], ps[p2], B/3.0)))/12.0;
//                position = mix(B, patchPos, alpha);
//                normal = vec3(0.0, 1.0, 0.0);
//                gl_Position = matrix * vec4(position, 1.0);
//                EmitVertex();

//                position = mix(T4s[i-1], T3s[i-1], alpha);
//                normal = vec3(0.0, 0.0, 1.0);
//                gl_Position = matrix * vec4(position, 1.0);
//                EmitVertex();

//                position = mix(T2s[i - 1], T1s[i - 1], alpha);
//                normal = vec3(0.0, 0.0, 1.0);
//                gl_Position = matrix * vec4(position, 1.0);
//                EmitVertex();

//                EndPrimitive();

//                if(polygonSize > 4 && i < (polygonSize - 2)) {
//                    int p3 = (gl_PrimitiveIDIn + i + 2) % polygonSize;
//                    position = mix(T2s[i - 1], T1s[i - 1], alpha);
//                    normal = vec3(0.0, 1.0, 0.0);
//                    gl_Position = matrix * vec4(position, 1.0);
//                    EmitVertex();


//                    vec3 B = (ps[gl_PrimitiveIDIn] + ps[p1] + ps[p3])/3.0;
//                    patchPos = (3.0*B + 3.0*(project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], B/3.0) + project(ns[p1], ps[p1], B/3.0) + project(ns[p3], ps[p3], B/3.0)))/12.0;
//                    position = mix(B, patchPos, alpha);
//                    normal = vec3(0.0, 1.0, 0.0);
//                    gl_Position = matrix * vec4(position, 1.0);
//                    EmitVertex();

//                    position = mix(T2s[i + 1], T1s[i + 1], alpha);
//                    normal = vec3(0.0, 0.0, 1.0);
//                    gl_Position = matrix * vec4(position, 1.0);
//                    EmitVertex();

//                    position = mix(T2s[i - 1], T1s[i - 1], alpha);
//                    normal = vec3(0.0, 0.0, 1.0);
//                    gl_Position = matrix * vec4(position, 1.0);
//                    EmitVertex();

//                    EndPrimitive();

//                    if(polygonSize > 4 && i < (polygonSize - 3)) {
//                        int p4 = (gl_PrimitiveIDIn + i + 3) % polygonSize;
//                        position = mix(T2s[i - 1], T1s[i - 1], alpha);
//                        normal = vec3(0.0, 1.0, 0.0);
//                        gl_Position = matrix * vec4(position, 1.0);
//                        EmitVertex();


//                        vec3 B = (ps[gl_PrimitiveIDIn] + ps[p1] + ps[p4])/3.0;
//                        patchPos = (3.0*B + 3.0*(project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], B/3.0) + project(ns[p1], ps[p1], B/3.0) + project(ns[p4], ps[p4], B/3.0)))/12.0;
//                        position = mix(B, patchPos, alpha);
//                        normal = vec3(0.0, 1.0, 0.0);
//                        gl_Position = matrix * vec4(position, 1.0);
//                        EmitVertex();

//                        position = mix(T2s[i + 2], T1s[i + 2], alpha);
//                        normal = vec3(0.0, 0.0, 1.0);
//                        gl_Position = matrix * vec4(position, 1.0);
//                        EmitVertex();

//                        position = mix(T2s[i - 1], T1s[i - 1], alpha);
//                        normal = vec3(0.0, 0.0, 1.0);
//                        gl_Position = matrix * vec4(position, 1.0);
//                        EmitVertex();

//                        EndPrimitive();

//                        if(polygonSize > 5 && i < (polygonSize - 4)) {
//                            int p5 = (gl_PrimitiveIDIn + i + 4) % polygonSize;
//                            position = mix(T2s[i - 1], T1s[i - 1], alpha);
//                            normal = vec3(0.0, 1.0, 0.0);
//                            gl_Position = matrix * vec4(position, 1.0);
//                            EmitVertex();


//                            vec3 B = (ps[gl_PrimitiveIDIn] + ps[p1] + ps[p5])/3.0;
//                            patchPos = (3.0*B + 3.0*(project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], B/3.0) + project(ns[p1], ps[p1], B/3.0) + project(ns[p5], ps[p5], B/3.0)))/12.0;
//                            position = mix(B, patchPos, alpha);
//                            normal = vec3(0.0, 1.0, 0.0);
//                            gl_Position = matrix * vec4(position, 1.0);
//                            EmitVertex();

//                            position = mix(T2s[i + 3], T1s[i + 3], alpha);
//                            normal = vec3(0.0, 0.0, 1.0);
//                            gl_Position = matrix * vec4(position, 1.0);
//                            EmitVertex();

//                            position = mix(T2s[i - 1], T1s[i - 1], alpha);
//                            normal = vec3(0.0, 0.0, 1.0);
//                            gl_Position = matrix * vec4(position, 1.0);
//                            EmitVertex();

//                            EndPrimitive();
//                        }
//                    }

//                }
//            }

    }


}
