in vec3 position;
in vec3 normal;
in vec3 outColour;
in vec2 uv;
in vec3 noiseP;
in float[8] outWeights;


uniform vec4 lightPosition;
uniform float frequency;
uniform float pvalue;
uniform bool patchColours;

/*INCLUDE NOISE*/

out vec4 fColor;

void main()
{
    float noise;
    if(noiseType == 1) {
        vec4 NN = pNoiseWorley(uv*vec2(baseNoiseFrequencyU, baseNoiseFrequencyV), noiseP.x);
        noise = noiseToScalar(NN);
    } else {
        noise = pNoisePerlin(uv*vec2(baseNoiseFrequencyU, baseNoiseFrequencyV), noiseP.x);
    }

    float c = 0.0;
    if(noise > 0.5) {
        c = 1.0;
    }




    vec3 N = normalize(normal);
    vec3 L = normalize(lightPosition.xyz - position);
    vec3 E = normalize(-position);
    vec3 R = normalize(-reflect(L, N));


    float oc = max(dot(N, L), 0.0) * c;


    fColor = vec4(vec3(oc), c);

}
