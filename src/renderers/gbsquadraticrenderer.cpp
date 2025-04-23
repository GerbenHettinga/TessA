#include "gbsquadraticrenderer.h"
#include "GL/glew.h"

GBSQuadraticRenderer::GBSQuadraticRenderer(RenderParameters* rp)
    : SurfaceRenderer(rp), rr(rp)
{
    initBuffers();
    initShaders();
}

GBSQuadraticRenderer::~GBSQuadraticRenderer() {
    glDeleteVertexArrays(1, &vaoEV);
    glDeleteBuffers(1, &vboEV);

    glDeleteVertexArrays(1, &vaoEF);
    glDeleteBuffers(1, &vboEF);
}

void GBSQuadraticRenderer::initBuffers() {
    glGenVertexArrays(1, &vaoEV);
    glBindVertexArray(vaoEV);

    glGenBuffers(1, &vboEV);
    glBindBuffer(GL_ARRAY_BUFFER, vboEV);

    for(GLuint i = 0; i < 4; i++) {
        glEnableVertexAttribArray(i);
        glVertexAttribPointer(i, 3, GL_FLOAT, GL_FALSE, 4*sizeof(glm::vec3), (void*) (i*sizeof(glm::vec3)));
    }
    glBindVertexArray(0);

    glGenVertexArrays(1, &vaoEF);
    glBindVertexArray(vaoEF);

    glGenBuffers(1, &vboEF);
    glBindBuffer(GL_ARRAY_BUFFER, vboEF);

    for(GLuint i = 0; i < 4; i++) {
        glEnableVertexAttribArray(i);
        glVertexAttribPointer(i, 3, GL_FLOAT, GL_FALSE, 4*sizeof(glm::vec3), (void*) (i*sizeof(glm::vec3)));
    }
    glBindVertexArray(0);
}

void GBSQuadraticRenderer::initShaders() {
    //qDebug() << "GBS shaders quadratic EV";

    polyShaders.reserve(14);

    // for transform feedback
    const char* varyings[1] = {"pos"};

    for(size_t i = 0; i < 7; ++i) {
        polyShaders.push_back(new PolygonShader(i + 3,
                                             std::string("../shaders/gbs/quadratic/vertshadergbsgb.glsl"),
                                             std::string("../shaders/gbs/quadratic/EV/tcgbsgbx.glsl"),
                                             std::string("../shaders/gbs/quadratic/EV/tegbsgbx.glsl") ));

        //glTransformFeedbackVaryings(polyShaders[i]->getFlatNormalShader()->getId(), 1, varyings, GL_SEPARATE_ATTRIBS);
    }

    //qDebug() << "GBS shaders quadratic EF";

    for(size_t i = 0; i < 7; ++i) {
        polyShaders.push_back(new PolygonShader(i + 3,
                                             std::string("../shaders/gbs/quadratic/vertshadergbsgb.glsl"),
                                             std::string("../shaders/gbs/quadratic/EF/tcgbsgbx.glsl"),
                                             std::string("../shaders/gbs/quadratic/EF/tegbsgbx.glsl") ));

        //glTransformFeedbackVaryings(polyShaders[i]->getFlatNormalShader()->getId(), 1, varyings, GL_SEPARATE_ATTRIBS);
    }
}


void GBSQuadraticRenderer::updateBuffers(Model& model) {
    GenQuadraticBSplineMesh& m = model.getQuadraticGBSMesh();

    glBindBuffer(GL_ARRAY_BUFFER, vboEV);
    glBufferData(GL_ARRAY_BUFFER, m.getBsBSplineEV().size() * sizeof(glm::vec3), m.getBsBSplineEV().data(), GL_STATIC_DRAW);

    glBindBuffer(GL_ARRAY_BUFFER, vboEF);
    glBufferData(GL_ARRAY_BUFFER, m.getBsBSplineEF().size() * sizeof(glm::vec3), m.getBsBSplineEF().data(), GL_STATIC_DRAW);


    rr.updateBuffers(model);

    //qDebug() << e << "buffers";
}


void GBSQuadraticRenderer::paintTessellation(int valency, int indexBufPointer, int numPatches, bool EV) {
   Shader* shader = setShaderUniforms(polyShaders[EV ? valency-3 : (valency - 3 + 7)]);

   glPatchParameteri(GL_PATCH_VERTICES, (unsigned int) valency);
   GLvoid* ptOffset = (GLvoid*)(indexBufPointer  * sizeof(unsigned));


   if(valency != 4) {
       glDrawArraysInstanced(GL_PATCHES, indexBufPointer, numPatches, (unsigned int)(valency));
   } else {
       glDrawArrays(GL_PATCHES, indexBufPointer, numPatches);
   }
}


void GBSQuadraticRenderer::render(Model& model) {
    Mesh* m = model.getQuadraticGBSMesh().getMesh();

    int bIdx = 0;
    int numPatches;

    glBindVertexArray(vaoEV);
    for(int i = 3; i < 9; ++i) {
        if(m->hasEVsOfValency(i)) {
            numPatches = m->getNumberOfEVs(i) * i;
            paintTessellation(i, bIdx, numPatches, true);
            bIdx += numPatches;
        }
    }
    glBindVertexArray(0);

    //render EV patches
    glBindVertexArray(vaoEF);
    bIdx = 0;
    for(int i = 3; i < 9; ++i) {
        if(m->hasEFsOfValency(i)) {
            numPatches = m->getNumberOfEFs(i) * i;
            paintTessellation(i, bIdx, numPatches, false);
            bIdx += numPatches;
        }
    }
    glBindVertexArray(0);

    if(settings->renderRegularPatches)
        rr.render(model);
}
