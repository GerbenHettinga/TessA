#version 330
in vec3 pos;
in vec3 oColour;
flat in vec3 norm;

uniform float frequency;
uniform float sysTime;
uniform bool patchColours;

out vec4 fColor;

void main()
{


    vec3 controlNormal = normalize(vec3(0.5, 0.5, 0.5));
    float angle = dot(controlNormal, norm);

    if(sin(frequency*10.0*angle) > 0){
        fColor = vec4(patchColours ? oColour : vec3(1.0), 1.0);
    } else {
        fColor = vec4(0.0, 0.0, 0.0, 1.0);
    }

}
