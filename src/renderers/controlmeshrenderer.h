#ifndef CONTROLMESHRENDERER_H
#define CONTROLMESHRENDERER_H

#include "surfacerenderer.h"

class ControlMeshRenderer : public SurfaceRenderer {
public:
    ControlMeshRenderer(RenderParameters* rp);
    ~ControlMeshRenderer();

    void initBuffers() override;
    void initShaders() override;
    void updateBuffers(Model &model) override;
    void render(Model &model) override;

private:
    Shader* shader;

    GLuint vao, ibo, vbo;
};

#endif // CONTROLMESHRENDERER_H
