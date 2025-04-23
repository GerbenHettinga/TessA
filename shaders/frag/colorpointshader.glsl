#version 330
in vec3 position;
in vec3 normal;

out vec4 fColor;

void main()
{
    fColor = vec4(normal, 1.0);
}
