#version 330
layout(lines) in;
layout(line_strip, max_vertices=32) out;

in vec3 position[];
in vec3 normal[];

uniform mat4 matrix;

flat out vec3 pos;
flat out vec3 norm;

vec3 project(vec3 n, vec3 vertex, vec3 p) {
            return p - dot((p-vertex), n) * n;
        }

void main()
{
    vec3 b21 = (2.0*position[0] + project(normal[0], position[0], position[1]))/3.0;
    vec3 b12 = (2.0*position[1] + project(normal[1], position[1], position[0]))/3.0;




    for(int i = 0; i<32; i++) {
        float u = float(i)/32.0;

//        pos = u*u*u*position[0] + (1.0 - u)*(1.0 - u)*(1.0 - u)*position[1] +
//                3.0*u*u*(1.0-u) * b21 + 3.0*u*(1.0-u)*(1.0-u) * b12;
//        gl_Position = vec4(pos, 1.0);
        //        pos = u*u*u*position[0] + (1.0 - u)*(1.0 - u)*(1.0 - u)*position[1] +
        //                3.0*u*u*(1.0-u) * b21 + 3.0*u*(1.0-u)*(1.0-u) * b12;
        pos = u*position[0] + (1.0 - u)*position[1];
        gl_Position = matrix * vec4(pos, 1.0);
        norm = normal[1];
        EmitVertex();
    }
    EndPrimitive();
}


