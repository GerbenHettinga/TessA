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

layout(points, max_vertices = 16) out;
out vec3 normal;
out vec3 position;

vec3 project(vec3 n, vec3 vertex, vec3 p) {
    return p - dot((p-vertex), n) * n;
}

int wrapper(int i, int n) {
    if(i < 0){
        return n-1;
    } else if(i == n){
        return 0;
    }
    return i;
}

void main()
{
    vec3 flatPos;
    vec3 patchPos;
    for(int j = 0; j < polygonSize; j++) {
        if(gl_PrimitiveIDIn != j) {
            if(pn || ct) {
                if(ct && abs(j-gl_PrimitiveIDIn) != 1) {
                    continue;
                }
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

    if(ct) {
        int m1 = wrapper(gl_PrimitiveIDIn-1, polygonSize);
        int p1 = (gl_PrimitiveIDIn + 1) % polygonSize;

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


//        vec3 e1 = normalize(ps[gl_PrimitiveIDIn] - T_0);
//        vec3 e2 = normalize(contrPolyCentre1 - T_0);
//        vec3 e3 = -e2;
//        vec3 e4 = normalize(ps[p1] - T_1);

//        vec3 F_0 = normalize(cross(e1, e2));


        position = (T_0 + ps[gl_PrimitiveIDIn])*0.5 + F_0 * rat0 * tan(p);
        normal = vec3(0.0, 0.0, 1.0);
        gl_Position = matrix * vec4(position, 1.0);
        EmitVertex();

        //vec3 F_1 = normalize(cross(e3, e4));

        position = (T_1 + ps[p1])*0.5 + F_0 * rat1 * tan(p);
        normal = vec3(0.0, 0.0, 1.0);
        gl_Position = matrix * vec4(position, 1.0);
        EmitVertex();

        vec3 avgNormal = normalize(ns[gl_PrimitiveIDIn] + ns[p1]);
        vec3 cbt = -cross(normalize(T_0 - T_1), avgNormal);

        vec3 eCentre = (T_0 + T_1)/2.0;
        float ratio = length(T_0 - T_1);
        vec3 C = eCentre + cbt * tan(p) * ratio;

        position = C;
        normal = vec3(0.0, 1.0, 0.0);
        gl_Position = matrix * vec4(position, 1.0);
        EmitVertex();
    }

    if(pn) {
        int m1 = wrapper(gl_PrimitiveIDIn-1, polygonSize);
        int p1 = (gl_PrimitiveIDIn + 1) % polygonSize;
        vec3 B = (ps[gl_PrimitiveIDIn] + ps[m1] + ps[p1])/3.0;
        patchPos = (3.0*B + 3.0*(project(ns[gl_PrimitiveIDIn], ps[gl_PrimitiveIDIn], B/3.0) + project(ns[m1], ps[m1], B/3.0) + project(ns[p1], ps[p1], B/3.0)))/12.0;
        position = mix(B, patchPos, alpha);
        normal = vec3(0.0, 1.0, 0.0);
        gl_Position = matrix * vec4(position, 1.0);
        EmitVertex();
    }


    EndPrimitive();
}
