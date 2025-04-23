#ifndef SURFACERENDERER_H
#define SURFACERENDERER_H

#include <glm/glm.hpp>
#include "../polygonshader.h"
#include "../model.h"
#include "../renderparameters.h"
#include "GL/glew.h"

class SurfaceRenderer
{
public:
    SurfaceRenderer(RenderParameters* rp);
    virtual ~SurfaceRenderer();

    Shader* setShaderUniforms(PolygonShader* ps);

    virtual void initBuffers() = 0;
    virtual void initShaders() = 0;
    virtual void updateBuffers(Model& model) = 0;
    virtual void render(Model& model) = 0;

protected:
    RenderParameters* settings;
    std::vector<PolygonShader*> polyShaders;
};

#endif // SURFACERENDERER_H
