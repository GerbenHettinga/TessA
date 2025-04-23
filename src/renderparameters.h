#ifndef RENDERPARAMETERS_H
#define RENDERPARAMETERS_H


#include "enums.h"
#include <glm/glm.hpp>
#include <GL/glew.h>
#include <string>
#include "mesh/vertex.h"
#include <iostream>

static void getError() {
    int error = 0;
    if (error = glGetError()) {
        std::cout << "render errors " << error << std::endl;
    }
};

using namespace modes;
class RenderParameters
{
public:
    float noiseFreq;
    float noiseFreqU, noiseFreqV;
    float sineFreq;
    float sineAngle;
    float seed;
    float paramX, paramY;
    float jitter;

    int maxOctaves;

    bool noiseDistEnabled;
    bool filterEnabled;
    bool showControlMesh;

    bool renderRegularPatches;

    glm::mat4x4 MVP;
    glm::mat3x3 NormalMatrix;

    glm::vec3 noiseToRGB;
    glm::vec3 primaryColour;
    glm::vec3 secondaryColour;

    FilterModes FilterMode;
    DistortionModes DistortionMode;
    NoiseModes NoiseMode;
    NoiseBlendModes NoiseBlendMode;
    ColourBlendingModes ColourBlendingMode;
    WorleyFunctions WorleyFunction;
    DistMetrics DistMetric;

    ShadeModes ShadingMode;
    SurfaceModes SurfaceMode;
    MeshModes MeshMode;
    DrawModes DrawingMode;
    DrawOptions DrawOption;
    PrimitiveModes PrimitiveMode;
    TriangulationModes TriangulationMode;
    CoordinateModes CoordinateMode;

    bool drawSelected, drawFaces, drawBoundaryCurves, drawNormals, Extended, ObjectDrawMode;
    bool showControlPoints, WD, QuadraticNormals, TextureCoordinateMode;
    bool animationRunning, animation2Running;
    bool outlinePhong, outlineSpokes;

    bool patchColoursRF;
    int FrequencyLights;
    float pauseTime;
    bool captureGeneratedObject, captureNoOfGeneratedPrimitives;
    bool fixedCurves;
    float tessInnerLevel;
    float tessOuterLevel;
    float surfaceAlpha;
    float alpha;
    float p_angle;
    float q_angle;

    bool showBoundaryPatches;

    bool centreFunctions;
    bool extraLayer;

    float aValue, bValue, cValue;
    float dValue, eValue, fValue;

    float pValue, qValue;
    float rValue, sValue;

    unsigned feedbackObject;
    unsigned feedbackbo[6];
    unsigned genPrims;
    unsigned generatedTriangles[6] = {0, 0, 0, 0, 0, 0};

    int selectedPoint;

    glm::vec4 m_lightPosition;
    glm::vec3 m_lightIntensity;
    glm::vec3 m_color;

    glm::vec3 m_ambient, m_diffuse, m_specular;
    float m_shininess;

    void init();
};

#endif // RENDERPARAMETERS_H


