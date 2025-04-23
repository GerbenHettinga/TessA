#ifndef QUADMESHRENDERER_H
#define QUADMESHRENDERER_H

#include "surfacerenderer.h"

class QuadMeshRenderer : public SurfaceRenderer {
public:
    QuadMeshRenderer(RenderParameters* rp);
    ~QuadMeshRenderer();

    void initBuffers() override;
    void initShaders() override;
    void updateBuffers(Model &model) override;
    void render(Model &model) override;

private:
    Shader* shader;

    GLuint vao, ibo, vbo, nbo;
};

#endif // QUADMESHRENDERER_H
