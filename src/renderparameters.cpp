#include "renderparameters.h"

void RenderParameters::init() {
    //Set parameters for scene
    m_lightPosition = glm::vec4(-0.0f, 5.0f, 10.0f, 1.0f);
    m_lightIntensity = glm::vec3(1.0f, 1.0f, 1.0f);
    m_ambient = glm::vec3(0.15f, 0.15f, 0.15f);
    m_diffuse = glm::vec3(0.5f, .8f, .5f);

    //MULTITESS: m_specular = glm::vec3(1.0f, 0.0f, 1.0f);
    m_specular = glm::vec3(0.2f, 1.0f, 0.5f);
    m_shininess = 50.0f;
    m_color = glm::vec3(0.0f, 0.7f, 0.2f);

    DrawingMode = DrawModes::Solid;
    ShadingMode = ShadeModes::Phong;
    MeshMode = MeshModes::QuadMesh;
    SurfaceMode = SurfaceModes::Tensor;
    PrimitiveMode = PrimitiveModes::Poly;
    TriangulationMode = TriangulationModes::Minimal;
    CoordinateMode = CoordinateModes::Fly;

    animationRunning = false;
    animation2Running = false;
    captureGeneratedObject = false;
    captureNoOfGeneratedPrimitives = false;
    fixedCurves = true;
    outlinePhong = false;
    outlineSpokes = false;
    patchColoursRF = false;

    renderRegularPatches = true;

    alpha = 1.0;
    p_angle = 1.0f/3.0f;
    q_angle = 1.0f/3.0f;

    pValue = 0.0f;
    qValue = 0.0f;

    aValue = 0.0f;
    bValue = 0.0f;
    cValue = 0.0f;

    dValue = 0.0f;
    eValue = 0.0f;
    fValue = 0.0f;

    rValue = 0.0f;
    sValue = 0.0f;

    tessInnerLevel = 1.0;
    tessOuterLevel = 1.0;

    centreFunctions = false;
    extraLayer = false;

    showBoundaryPatches = false;

    showControlMesh = true;
    showControlPoints = false;
    FrequencyLights = 0.0;

    drawNormals = false;
    drawFaces = false;
    drawSelected = true;
    QuadraticNormals = false;
    ObjectDrawMode = true;
    TextureCoordinateMode = false;
    WD = false;

    genPrims = 0;

    noiseFreq = 4.0f;
    noiseFreqU = 4.0f;
    noiseFreqV = 4.0f;
    maxOctaves = 10;
    sineFreq = 2.0f;
    sineAngle = 0.;
    //noiseToRGB = glm::vec3(1, 1, 1);
    noiseDistEnabled = false;
    seed = 0.0;
    filterEnabled = false;
    paramX = 0.0;
    paramY = 1.0;
    jitter = 0.8f;

    primaryColour = glm::vec3(0, 0, 0);
    secondaryColour = glm::vec3(1, 1, 1);

    FilterMode = FilterModes::Pulse;
    DistortionMode = DistortionModes::Ripple;
    NoiseBlendMode = NoiseBlendModes::NoiseColour;
    ColourBlendingMode = ColourBlendingModes::Subtract;
    NoiseMode = NoiseModes::Perlin;
    WorleyFunction = WorleyFunctions::F2F1;
    DistMetric = DistMetrics::Euclidean;
}
