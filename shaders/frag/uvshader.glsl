#version 330
in vec2 uv;

out vec4 fColor;



void main()
{
    vec3 c = vec3(uv.x);
    vec3 quant = floor((c*20.0))/20.0;
    fColor = vec4(vec3(uv.x, 0.0, uv.y), 1.0);
}

