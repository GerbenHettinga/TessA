#version 330
in vec3 position;
in vec3 outColour;
in vec3 normal;

uniform float frequency;
uniform bool patchColours;

out vec4 fColor;

void main()
{
    vec3 controlNormal = normalize(vec3(0.5, 0.5, 0.5));
    float angle = dot(controlNormal, normal);

    if(frequency == 0.0 || sin(frequency*angle) > 0){
        //fColor = vec4(1.0, 1.0, 1.0, 1.0);
        //fColor = vec4(patchColours ? outColour : vec3(1.0), 1.0);
        fColor = vec4(1.0);
        if(patchColours) {
            fColor.xyz = outColour;
        }
    } else {
        fColor = vec4(0.0, 0.0, 0.0, 1.0);
    }

}
