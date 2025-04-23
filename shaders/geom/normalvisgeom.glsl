#version 330
layout(points) in;
in vec3[] pos;
in vec3[] norm;

uniform mat4 matrix;

layout(line_strip, max_vertices = 16) out;
out vec3 normal;
out vec3 position;

void main()
{
    for(int i=0; i < gl_in.length(); i++){
        gl_Position = matrix * vec4(pos[i], 1.0);
        position = pos[i];
        normal = norm[i];
        EmitVertex();

        gl_Position = matrix * vec4(pos[i] + norm[i], 1.0);
        position = pos[i] + norm[i];
        normal = norm[i];
        EmitVertex();

        EndPrimitive();
    }
}
