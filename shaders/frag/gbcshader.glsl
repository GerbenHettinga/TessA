#version 330
in float[8] outWeights;

uniform int selectedVertex;
uniform float p;
uniform float sysTime;

float weightSum = 0.0;

out vec4 fColor;

vec3 rainbow(float value){
    float NLEVELS = 20.0;
    value *= NLEVELS; value = ceil(value);
    value /= NLEVELS;

    float dx=0.8;
    if (value<0.0) value=0.0;
    //if (value>1.0) value=1.0;
    value = (6.0-2.0*dx)*value+dx;
    float R = max(0.0,(3.0-abs(value-4.0)-abs(value-5.0))/2.0);
    float G = max(0.0,(4.0-abs(value-2.0)-abs(value-4.0))/2.0);
    float B = max(0.0,(3.0-abs(value-1.0)-abs(value-2.0))/2.0);
    return vec3(R, G, B);
}

float sum2max() {
    float m = 0.0;
    for(int i = 0; i < 8; i++) {
        if(outWeights[i] > abs(sin(sysTime/1000000.0))) {
            m = m + outWeights[i];
        }
    }
    return m;
}

void main()
{
    float w;
    if(selectedVertex < 8) {
        w = outWeights[selectedVertex];
    } else {
        w = weightSum;
    }

    fColor = vec4(rainbow(w),1.0);


}

