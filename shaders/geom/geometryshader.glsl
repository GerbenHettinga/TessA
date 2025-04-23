#version 400 core
layout(triangles) in;
layout(triangle_strip, max_vertices=3) out;

in vec3 position[];
in vec3 normal[];

uniform bool nMatrix;
uniform mat3 normal_matrix;


out vec3 pos;
flat out vec3 norm;


void main()
{
    vec3 v1;
    vec3 v2;

    v1 = vec3(position[1] - position[0]);
    v2 = vec3(position[2] - position[0]);
    norm = normalize(cross(normalize(v1), normalize(v2)));
    //oColour = outColour[0];

    if(nMatrix) {
        norm = normalize(normal_matrix * norm);
    }

    for(int i=0; i<3; i++){
        pos = vec3(gl_in[i].gl_Position);
        gl_Position = gl_in[i].gl_Position;
        EmitVertex();
    }
    EndPrimitive();
}


