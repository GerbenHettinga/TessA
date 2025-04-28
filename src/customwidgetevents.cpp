#include "customopenglwidget.h"
#include "imgui.h"

#include <numbers>
#include <Windows.h>
#include <filesystem>

void CustomOpenGLWidget::setNonPlanarPolygon(int valency){
    //polygon = new TessA::Polygon(valency);
    settings.ObjectDrawMode = false;
    updateBuffers();
}

void CustomOpenGLWidget::setPolygonObject(std::string filename){
    model.set(filename, &settings);
    
    settings.ObjectDrawMode = true;
    updateBuffers();
}

void CustomOpenGLWidget::openPolygon(std::string filename) {
    //polygon = new TessA::Polygon(ObjectReader::readPoly(filename));
    settings.ObjectDrawMode = false;
    updateBuffers();
}

void CustomOpenGLWidget::savePolygon(std::string filename) {
    polygon->savePolygon(filename);
}

void CustomOpenGLWidget::takeScreenshot() {
    //TODO:
}

void CustomOpenGLWidget::findClosest(float x, float y) {
    glm::vec2 ray_nds = glm::vec2(2.0*x/double(m_width) - 1.0, 1.0 -(2.0*y)/double(m_height));

    Mesh* m = model.getMesh();
    Vertex* v = m->findClosest(ray_nds, settings.MVP);
    selectedVertex = v;
}

void CustomOpenGLWidget::subdivideDS() {
    //model.dooSabin();
}

void CustomOpenGLWidget::mouseMoveEvent(const SDL_Event& event) {

    if (event.button.button == SDL_BUTTON_LEFT) {
        int x, y;
        SDL_GetMouseState(&x, &y);

        glm::vec2 sPos = toNormalizedScreenCoordinates(x, y);
        glm::vec3 newVec = glm::vec3(sPos.x, sPos.y, 0.0);

        //project onto sphere
        float sqrZ = 1.0f - glm::dot(newVec, newVec);
        if (sqrZ > 0.0f) {
            newVec.z = sqrt(sqrZ);
        }
        else {
            glm::normalize(newVec);
        }

        glm::vec3 v2 = glm::normalize(newVec);

        // reset if we are starting a drag
        if (glm::length(oldVec) == 0.0) {
            oldVec = newVec;
            return;
        }

        // calculate axis and angle
        glm::vec3 v1 = glm::normalize(oldVec);
        if (glm::length(v1 - v2) == 0.0) {
            oldVec = newVec;
            return;
        }

        glm::vec3 N = glm::normalize(glm::cross(v1, v2));
        if(glm::length(N) == 0.0) {
            oldVec = newVec;
            return;
        }
        
        float angle = acos(glm::dot(v1, v2));
        // calculate quaternion
        glm::quat rot = glm::angleAxis(angle, N);
        qq = qq * rot;
        Rot = glm::degrees(glm::eulerAngles(qq));
        setMatrix(true);

        // for next iteration
        oldVec = newVec;
    } else {
        // to reset drag
        oldVec = glm::vec3(0.0);
    }
}

glm::vec2 CustomOpenGLWidget::toNormalizedScreenCoordinates(int x, int y) {
    float xRatio, yRatio;
    float xScene, yScene;

    xRatio = float(x) / float(m_width);
    yRatio = float(y) / float(m_height);

    xScene = (1. - xRatio) * -1. + xRatio * 1.;
    yScene = yRatio * -1. + (1. - yRatio) * 1.;

    return {xScene, yScene};
}


void CustomOpenGLWidget::mousePressEvent(const SDL_Event& event) {
    // In order to allow keyPressEvents:
    

    switch (event.button.button) {
        case SDL_BUTTON_LEFT:
            int x, y;
            SDL_GetMouseState(&x, &y);
            findClosest(float(x), float(y));
            //update();
            break;
        case SDL_BUTTON_RIGHT:

        break;
    }
}

void CustomOpenGLWidget::setSize(int width, int height)
{

}

void CustomOpenGLWidget::wheelEvent(const SDL_Event& event) {
    float Phi;
    // Delta is usually 120
    Phi = 1.0f + (event.wheel.y / 50.0f);

    Scale = fmin(fmax(Phi * Scale, 0.1f), 100.0f);
    setMatrix(true);
    //update();
}


void CustomOpenGLWidget::keyPressEvent(const SDL_Event& event) {
    switch(event.button.button) {
    case SDLK_DOWN :
        Trans = Trans - glm::vec3(0.0, 0.1f, 0.0);
        setMatrix(true);
        //update();
        break;
    case SDLK_UP:
        Trans = Trans + glm::vec3(0.0, 0.1f, 0.0);
        setMatrix(true);
        //update();
        break;
    case SDLK_LEFT:
        Trans = Trans - glm::vec3(0.1f, 0.0, 0.0);
        setMatrix(true);
        //update();
        break;
    case SDLK_RIGHT:
        Trans = Trans + glm::vec3(0.1f, 0.0, 0.0);
        setMatrix(true);
        //update();
        break;
    case SDLK_z:
        settings.DrawingMode = DrawModes::Solid;
        //update();
        break;
    case SDLK_x:
        settings.DrawingMode = DrawModes::WireFrame;
        //update();
        break;
    case SDLK_c:
        settings.DrawingMode = DrawModes::PointCloud;
        //update();
        break;
    }
}

bool getOpenFileName(std::string& path)
{
    char filename[MAX_PATH];

    OPENFILENAME ofn;
    ZeroMemory(&filename, sizeof(filename));
    ZeroMemory(&ofn, sizeof(ofn));
    ofn.lStructSize = sizeof(ofn);
    ofn.hwndOwner = NULL;  // If you have a window to center over, put its HANDLE here
    ofn.lpstrFilter = "Obj Files\0*.obj\0Any File\0*.*\0";
    ofn.lpstrFile = filename;
    ofn.nMaxFile = MAX_PATH;
    ofn.lpstrTitle = "Select a mesh file.";
    ofn.Flags = OFN_DONTADDTORECENT | OFN_FILEMUSTEXIST;

    if (GetOpenFileNameA(&ofn))
    {
        path = filename;

        return true;
    }

    return false;
}

void CustomOpenGLWidget::drawUI()
{
    if (ImGui::Button("Open File")) {
        std::string path;
        if (getOpenFileName(path)) {
            setPolygonObject(path);
        }
    }

    int currentDrawMode = (int)settings.DrawingMode;
    const char* drawModeItems[4] = {"PointCloud",
                                 "WireFrame",
                                 "Solid",
                                 "Nothing" };

    if (ImGui::Combo("Draw mode", &currentDrawMode, drawModeItems, 4)) {
        settings.DrawingMode = (DrawModes)currentDrawMode;
    }

    int currentMeshMode = (int)settings.MeshMode;
    //PolyMesh, ACC2, CubicGBS, QuadraticGBS, QuarticGBS, QuadMesh, Nothing, ControlMesh;
    const char* meshModeItems[8] = { "PolyMesh",
                                 "ACC2",
                                 "CubicGBS",
                                 "QuadraticGBS",
                                 "QuarticGBS",
                                 "QuadMesh",
                                "Nothing",
                                "ControlMesh"};

    if (ImGui::Combo("Mesh Mode", &currentMeshMode, meshModeItems, 8)) {
        settings.MeshMode = (MeshModes)currentMeshMode;
        updateBuffers();
    }

    int currentShadeMode = (int)settings.ShadingMode;
    const char* shadeModeItems[10] = { "FlatNormalBuffer",
                                     "NormalBuffer",
                                     "FlatPhong",
                                     "Phong",
                                     "GBC",
                                     "Isophotes",
                                     "IsophotesFlat",
                                     "Slicing",
                                     "UV",
                                     "Noise" };

    if (ImGui::Combo("Shade Mode", &currentShadeMode, shadeModeItems, 10)) {
        settings.ShadingMode = (ShadeModes)currentShadeMode;
    }

    int tessInner = settings.tessInnerLevel;
    if (ImGui::SliderInt("Tessellation inner", &tessInner, 1.0, 64.0)) {
        settings.tessInnerLevel = (float)tessInner;
    }

    int tessOuter = settings.tessOuterLevel;
    if (ImGui::SliderInt("Tessellation outer", &tessOuter, 1.0, 64.0)) {
        settings.tessOuterLevel = (float)tessOuter;
    }

    if (ImGui::SliderInt("isophote frequency", &settings.FrequencyLights, 1.0, 360.0));

    ImGui::Checkbox("boundary curves", &settings.outlinePhong);
    ImGui::Checkbox("control mesh", &settings.showControlMesh);
    ImGui::Checkbox("patch colours", &settings.patchColoursRF);

    int subdivLevel = model.getSubdivisionLevel();
    int subdivDegree = model.getSubdivisionDegree();
    
    if (ImGui::InputInt("Subdivision degree", &subdivDegree)) {
        model.setSubdivisionLevel(subdivLevel, subdivDegree);

        updateBuffers();
    }

    if(ImGui::InputInt("Subdivision level", &subdivLevel)) {
        model.setSubdivisionLevel(subdivLevel, subdivDegree);

        updateBuffers();
    }

    if (ImGui::Button("dual")) {
        model.dual();
        updateBuffers();
    }

    if (ImGui::Button("lin subdivide")) {
        model.linSubdivide();
        updateBuffers();
    }

    if (ImGui::Button("even smooth")) {
        model.evenSmooth();
        updateBuffers();
    }

    if (ImGui::Button("odd smooth")) {
        model.oddSmooth();
        updateBuffers();
    }

}