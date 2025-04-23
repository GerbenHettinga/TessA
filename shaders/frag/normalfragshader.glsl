#version 330
in vec3 position;
in vec3 normal;

out vec4 fColor;

void main()
{
    fColor = vec4(normalize(normal)/2.0 + 0.5, 1.0);
}
