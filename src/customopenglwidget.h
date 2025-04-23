#ifndef CUSTOMOPENGLWIDGET_H
#define CUSTOMOPENGLWIDGET_H

#include <string>
#include <glm/glm.hpp>
#include <glm/gtc/quaternion.hpp>

#include "renderers/surfacerenderer.h"
#include "coordinatetexture.h"
#include "polygonshader.h"
#include "polygon.h"
#include "model.h"
#include "renderparameters.h"
#include "objectreader.h"
#include "enums.h"
#include "tessa.h"
#include "Shader.h"

#include "GL/glew.h"
#include "SDL2/SDL.h"

using namespace modes;

class Tessa;

class CustomOpenGLWidget {

public:
    CustomOpenGLWidget();
    ~CustomOpenGLWidget();

    void importFile();
    void convertMesh();

    void updateBuffers(bool callUpdate = true);
    void updateBuffers(class Vertex *v);

    glm::vec3 fitPlane(std::vector<glm::vec3> polygon);
    void setNonPlanarPolygon(int valency);
    void setPolygonObject(std::string filename);
    void savePolygon(std::string filename);
    void openPolygon(std::string filename);

    void takeScreenshot();
    void saveGeneratedGeometry(std::string filename);

    void mouseMoveEvent(const SDL_Event& event);
    void mousePressEvent(const SDL_Event& event);
    void wheelEvent(const SDL_Event& event);
    void keyPressEvent(const SDL_Event& event);

    RenderParameters settings;

    float Scale, Centroidal;
    int genPrims;
    int PtSelected;

    void setMatrix(bool Reset);

    Vertex* selectedVertex;

    void subdivide(int inc);
    void subdivideDS();


    glm::vec3 Rot, Trans;
    glm::quat qq;
    glm::vec3 oldVec;

    Polygon *polygon;
    //Mesh *mesh;
    Model model;

    void paintGL();
    void initializeGL();

    void drawUI();

protected:
   
    
    void resizeGL(int w, int h);
    void initTextures();
    void initBuffers();
    void setMatrix();

    Shader* setShaderUniforms(PolygonShader* ps);

    //SDLevents
    //void mousePressEvent(QMouseEvent* Event);
    //void mouseMoveEvent(QMouseEvent* Event);
    //void wheelEvent(QWheelEvent* Event);
    //void keyPressEvent(QKeyEvent* Event);

private:
    std::unordered_map<MeshModes, SurfaceRenderer*> renderers;

    Shader* _selectedPointShader;
    Shader* _normalVisualizeProg;
    Shader* _controlPointShaderProg;
    Shader* _controlNetShaderProg;
    Shader* _controlPointGBShaderProg;
    Shader* _controlNetGBShaderProg;
    Shader* _controlPointGSShaderProg;
    Shader* _controlNetGSShaderProg;
    Shader* _controlCTPointShaderProg;
    Shader* _controlSSPointShaderProg;
    Shader* _controlCTNetShaderProg;
    Shader* _controlSSNetShaderProg;
    Shader* _faceShaderProg;
    Shader* _boundCurveShaderProg;
    Shader* _controlGBSPointShaderProg;

    std::vector<CoordinateTexture> coordinateTextures;
    std::vector<CoordinateTexture> coordinateTexturesQuad;

    GLuint vboNoiseCC;

    glm::mat3x3 Normal_Matrix;
    glm::mat4x4 Matrix;
    glm::mat4x4 Projection;
    glm::mat4x4 MVP;
    glm::mat4x4 MVPscaled;
    glm::mat4x4 View;

    int m_width, m_height;

    float xPrev, yPrev;

    void findClosest(float x, float y);
    void initShaders();

    void setSize(int width, int height);

    glm::vec2 toNormalizedScreenCoordinates(int x, int y);
};

#endif // CUSTOMOPENGLWIDGET_H
