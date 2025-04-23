#version 330
in vec3 pos;
flat in vec3 norm;

out vec4 fColor;
out vec3 pos2;

void main()
{
    pos2 = pos;
    fColor = vec4(norm/2.0 + vec3(0.5, 0.5, 0.5), 1.0);

}
