#ifndef NOISERENDERER_H
#define NOISERENDERER_H

#include "surfacerenderer.h"

class NoiseRenderer : public SurfaceRenderer
{
public:
    NoiseRenderer(class RenderParameters* rp);
    ~NoiseRenderer();

    void initBuffers();
    void initShaders();
    void updateBuffers(class Model& model);
    void render(Model& model);

    void paintTessellation(int valency, int indexBufPointer, int numPatches);

private:
    unsigned vao, vbo;
};

#endif // NOISERENDERER_H
