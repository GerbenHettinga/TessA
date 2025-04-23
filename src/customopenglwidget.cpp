#include "customopenglwidget.h"
#include "coordinatetexture.h"

#include <GL/glew.h>

#include <stdio.h>
#include <stdlib.h>

#include <chrono>

#include <math.h>
#include <random>
#include <iostream>

#include "renderers/acc2renderer.h"
#include "renderers/gbsrenderer.h"
#include "renderers/gbsquadraticrenderer.h"
#include "renderers/gbsquarticrenderer.h"
#include "renderers/polygonrenderer.h"
#include "renderers/regularrenderer.h"
#include "renderers/controlmeshrenderer.h"
#include "renderers/quadmeshrenderer.h"

#include "mesh/vertex.h"
#include "enums.h"
#define GLM_ENABLE_EXPERIMENTAL
#include <glm/gtx/quaternion.hpp>
#include <glm/gtx/euler_angles.hpp>

#include <iostream>
#include <fstream>

CustomOpenGLWidget::CustomOpenGLWidget(){
    //polygon = new Polygon(8);
    //model.set("Cube.obj", &settings);

    qq = glm::quat(glm::vec3(0, 0, 0));

    m_width = 1280;
    m_height = 720;
}

CustomOpenGLWidget::~CustomOpenGLWidget()
{
    //qDebug() << "Destructor of CustomOpenGLWidget";
  

    glDeleteBuffers(6, settings.feedbackbo);
    glDeleteTransformFeedbacks(1, &settings.feedbackObject);

    for(int i = 0; i < 5; i++) {
        GLuint id = coordinateTextures[i].getID();
        glDeleteTextures(1, &id);
    }

}


void CustomOpenGLWidget::initBuffers() {
    glGenTransformFeedbacks(1, &settings.feedbackObject);
    glBindTransformFeedback(GL_TRANSFORM_FEEDBACK, settings.feedbackObject);

    //generate a buffer for each valency of polygon as the split  calls will flush the buffer
    glGenBuffers(6, settings.feedbackbo);
    for(int i = 3; i < 9; i++) {
        glBindBuffer(GL_TRANSFORM_FEEDBACK_BUFFER, settings.feedbackbo[i-3]);
        glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, settings.feedbackbo[i-3]);
        glBufferData(GL_TRANSFORM_FEEDBACK_BUFFER, 1000000*sizeof(glm::vec3), nullptr, GL_DYNAMIC_COPY);
    }

    glBindTransformFeedback(GL_TRANSFORM_FEEDBACK, 0);
    //GLenum e = glGetError();
}


void CustomOpenGLWidget::updateBuffers(Vertex* v) {
    //model.recalculateBasedOnVertex(v);
    updateBuffers(true);
}

void CustomOpenGLWidget::updateBuffers(bool callUpdate) {
    model.update();

    renderers[settings.MeshMode]->updateBuffers(model);

    renderers[MeshModes::ControlMesh]->updateBuffers(model);
}

void CustomOpenGLWidget::initializeGL() {
    //qDebug() << init;

    /*
    aTimer = new QTimer(this);
    aTimer->setInterval(0);
    connect(aTimer, SIGNAL(timeout()), this, SLOT(animate()));

    eTimer = new QElapsedTimer();
    eTimer->start();

    debugLogger = new QOpenGLDebugLogger(this);
    connect( debugLogger, SIGNAL( messageLogged( QOpenGLDebugMessage ) ), this, SLOT( onMessageLogged( QOpenGLDebugMessage ) ), Qt::DirectConnection );
    if ( debugLogger->initialize() ) {
        debugLogger->startLogging( QOpenGLDebugLogger::SynchronousLogging );
        debugLogger->enableMessages();
    }
    */

    settings.init();

    std::string glVersion;
    glVersion = reinterpret_cast<const char*>(glGetString(GL_VERSION));
    //qDebug() << "Using OpenGL" << qPrintable(glVersion);

    // Background color
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);

    getError();
    initBuffers();

    getError();
    //qDebug() << e << "buffers";
    initTextures();
    
    getError();
    //qDebug() << e << "textures";


    getError();
    //todo: unique pointers
    renderers[MeshModes::ACC2] = new ACC2Renderer(&settings);
    getError();
    renderers[MeshModes::CubicGBS] = new GBSRenderer(&settings);
    getError();
    renderers[MeshModes::QuadraticGBS] = new GBSQuadraticRenderer(&settings);
    getError();
    renderers[MeshModes::QuarticGBS] = new GBSQuarticRenderer(&settings);
    getError();
    renderers[MeshModes::PolyMesh] = new PolygonRenderer(&settings);
    getError();
    renderers[MeshModes::QuadMesh] = new QuadMeshRenderer(&settings);
    getError();
    renderers[MeshModes::ControlMesh] = new ControlMeshRenderer(&settings);
    getError();

    PtSelected = -1;

    Rot = glm::vec3(0.0, 0.0, 0.0);
    Scale = 1.0f;
    //qq = glm::quat();
    Trans = glm::vec3(0.0, 0.0, -1.0);
    oldVec = glm::vec3(0.0 ,0.0, -1.0);

 

    resizeGL(1280, 720);

    updateBuffers();

    setMatrix(true);
}


void CustomOpenGLWidget::initTextures() {
    coordinateTextures.clear();
    coordinateTexturesQuad.clear();

    for(int i = 4; i < 9; i++) {
        coordinateTextures.push_back(CoordinateTexture(i, 128, false));
    }

    for(int i = 6; i < 9; i += 2) {
        coordinateTexturesQuad.push_back(CoordinateTexture(i, 128, true));
    }
}



void CustomOpenGLWidget::saveGeneratedGeometry(std::string filename) {
    std::vector<std::vector<glm::vec3>> d(6);
    int sumGeneratedTriangles = 0;

    for(int i = 3; i < 9; i++) {
        d[i-3] = std::vector<glm::vec3>(3 * settings.generatedTriangles[i-3]);
        if(settings.generatedTriangles[i-3] != 0) {
            glBindBuffer(GL_TRANSFORM_FEEDBACK_BUFFER, settings.feedbackbo[i-3]);
            glGetBufferSubData(GL_TRANSFORM_FEEDBACK_BUFFER, 0, 3*settings.generatedTriangles[i-3]*sizeof(glm::vec3), d[i-3].data());
            //glGetBufferSubData(GL_TRANSFORM_FEEDBACK_BUFFER, 0, 190512*sizeof(glm::vec3), d[i-3].data());
            glBindBuffer(GL_TRANSFORM_FEEDBACK_BUFFER, 0);
            sumGeneratedTriangles += settings.generatedTriangles[i-3];
        }
    }

    std::ofstream myfile;
    myfile.open (filename);
    for(int i = 3; i < 9; i++) {
        for(unsigned j = 0; j < settings.generatedTriangles[i-3]*3; j++) {
            myfile << "v " << d[i-3][j].x << " " << d[i-3][j].y << " " << d[i-3][j].z << std::endl;
        }
    }

    for(int i = 0; i < sumGeneratedTriangles; i++) {
        myfile << "f " << (3*i) + 1 << " " << (3*i) + 2 << " " << (3*i) + 3 << std::endl;
    }
    //myfile << std::endl;
    myfile.close();


    static const int tris[6] = {0, 0, 0, 0, 0, 0};
    memcpy(settings.generatedTriangles, tris, sizeof(tris));
}


void CustomOpenGLWidget::paintGL() {
    getError();

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glEnable(GL_DEPTH_TEST);

    if(settings.DrawingMode == DrawModes::Solid){
        //glEnable(GL_CULL_FACE);
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    } else if(settings.DrawingMode == DrawModes::WireFrame){
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    }

    getError();

    renderers[settings.MeshMode]->render(model);

    getError();

    if(settings.showControlMesh)
        renderers[MeshModes::ControlMesh]->render(model);

    if(settings.captureNoOfGeneratedPrimitives) {
        settings.genPrims = 0;
    }

}

void CustomOpenGLWidget::resizeGL(int w, int h) {
    const auto aratio = float( w ) / float( h );
    Projection = glm::mat4x4(1.0f);
    Projection = glm::ortho(-aratio, aratio, -1.f, 1.f, -0.5f, 10.0f);
    
    View = glm::mat4x4(1.0f);
    View = glm::lookAt(glm::vec3(0.0, 0.0, 1.0), glm::vec3(0.0, 0.0, 0.0), glm::vec3(0.0, 1.0, 0.0));

    setMatrix(true);
}

// function that uses the quaternion for rotation
void CustomOpenGLWidget::setMatrix() {
    Matrix = glm::mat4x4(1.0f);
    glm::mat4x4 ms;

    Matrix = glm::translate(Matrix, Trans);
    //Matrix = glm::rotate(Matrix, qq);
    //Matrix.rotate(qq);
    Matrix = glm::scale(Matrix, glm::vec3(Scale));
    
    settings.NormalMatrix = glm::mat3x3(glm::transpose(Matrix));

    settings.MVP = Projection * View * Matrix ;
}

//function that uses euler angles for rotation (xyz gui wheels)
void CustomOpenGLWidget::setMatrix(bool Reset) {
    if (Reset) {
        Matrix = glm::mat4x4(1.0f);
    }

    Matrix = glm::translate(Matrix, Trans);
    //todo: how to rotate?
    //Matrix = Matrix * glm::eulerAngleYXZ(Rot.x, Rot.y, Rot.z);
    Matrix =  Matrix * glm::toMat4(qq);
    //Matrix = glm::toMat4(qq) * Matrix;
    //Matrix.rotate(qq);
    Matrix = glm::scale(Matrix, glm::vec3(Scale));

    settings.NormalMatrix = glm::mat3x3(glm::transpose(Matrix));

    settings.MVP = Projection * View * Matrix;
}
