#version 330
in vec3 position;
in vec3 normal;

uniform float frequency;

out vec4 fColor;

void main()
{
    vec3 controlNormal = normalize(vec3(0.5, 0.5, 0.5));
    float angle = dot(controlNormal, normal);

    if(frequency == 0.0 || sin(frequency*angle) > 0){
        fColor = vec4(1.0);
    } else {
        fColor = vec4(0.0, 0.0, 0.0, 1.0);
    }

}
