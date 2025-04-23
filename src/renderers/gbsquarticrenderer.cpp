#include "gbsquarticrenderer.h"
#include "../meshtypes/genquarticbsplinemesh.h"

GBSQuarticRenderer::GBSQuarticRenderer(RenderParameters* rp)
    : SurfaceRenderer(rp), rr(rp)
{
    initBuffers();
    initShaders();
}

GBSQuarticRenderer::~GBSQuarticRenderer() {
    glDeleteVertexArrays(1, &vaoEV);
    glDeleteBuffers(1, &vboEV);

    glDeleteVertexArrays(1, &vaoEF);
    glDeleteBuffers(1, &vboEF);
}

void GBSQuarticRenderer::initBuffers() {
    glGenVertexArrays(1, &vaoEV);
    glBindVertexArray(vaoEV);

    glGenBuffers(1, &vboEV);
    glBindBuffer(GL_ARRAY_BUFFER, vboEV);

    for(GLuint i = 0; i < 16; i++) {
        glEnableVertexAttribArray(i);
        glVertexAttribPointer(i, 3, GL_FLOAT, GL_FALSE, 16*sizeof(glm::vec3), (void*) (i*sizeof(glm::vec3)));
    }
    glBindVertexArray(0);

    glGenVertexArrays(1, &vaoEF);
    glBindVertexArray(vaoEF);

    glGenBuffers(1, &vboEF);
    glBindBuffer(GL_ARRAY_BUFFER, vboEF);

    for(GLuint i = 0; i < 16; i++) {
        glEnableVertexAttribArray(i);
        glVertexAttribPointer(i, 3, GL_FLOAT, GL_FALSE, 16*sizeof(glm::vec3), (void*) (i*sizeof(glm::vec3)));
    }
    glBindVertexArray(0);
}

void GBSQuarticRenderer::initShaders() {
    polyShaders.reserve(14);

    // for transform feedback
    const char* varyings[1] = {"pos"};

    for(size_t i = 0; i < 7; ++i) {
        polyShaders.push_back(new PolygonShader(i + 3,
                                             std::string("../shaders/gbs/quartic/vertshadergbsgb.glsl"),
                                             std::string("../shaders/gbs/quartic/EV/tcgbsgbx.glsl"),
                                             std::string("../shaders/gbs/quartic/EV/tegbsgbx.glsl") ));

        //glTransformFeedbackVaryings(polyShaders[i]->getFlatNormalShader()->getId(), 1, varyings, GL_SEPARATE_ATTRIBS);
        //link so that varyings are processed
        //polyShaders[i]->linkAll();
    }

    for(size_t i = 0; i < 7; ++i) {
        polyShaders.push_back(new PolygonShader(i + 3,
                                             std::string("../shaders/gbs/quartic/vertshadergbsgb.glsl"),
                                             std::string("../shaders/gbs/quartic/EF/tcgbsgbx.glsl"),
                                             std::string("../shaders/gbs/quartic/EF/tegbsgbx.glsl") ));

        //glTransformFeedbackVaryings(polyShaders[i]->getFlatNormalShader()->getId(), 1, varyings, GL_SEPARATE_ATTRIBS);
        //polyShaders[i]->linkAll();
    }
}


void GBSQuarticRenderer::updateBuffers(Model& model) {
    GenQuarticBSplineMesh& m = model.getQuarticGBSMesh();

    glBindBuffer(GL_ARRAY_BUFFER, vboEV);
    glBufferData(GL_ARRAY_BUFFER, m.getBsBSplineEV().size() * sizeof(glm::vec3), m.getBsBSplineEV().data(), GL_STATIC_DRAW);

    glBindBuffer(GL_ARRAY_BUFFER, vboEF);
    glBufferData(GL_ARRAY_BUFFER, m.getBsBSplineEF().size() * sizeof(glm::vec3), m.getBsBSplineEF().data(), GL_STATIC_DRAW);

    rr.updateBuffers(model);

    //qDebug() << e << "buffers";
}


void GBSQuarticRenderer::paintTessellation(int valency, int indexBufPointer, int numPatches, bool EV) {
   Shader* shader = setShaderUniforms(polyShaders[EV ? valency-3 : (valency - 3 + 7)]);

   if(settings->captureGeneratedObject) {
       //glEnable(GL_RASTERIZER_DISCARD);
       glBindTransformFeedback(GL_TRANSFORM_FEEDBACK, settings->feedbackObject);
   }
   GLuint q, q2;

   if(settings->captureNoOfGeneratedPrimitives) {
       glGenQueries(1, &q2);
       glBeginQuery(GL_PRIMITIVES_GENERATED, q2);
   }

   if(settings->captureGeneratedObject) {
       glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, settings->feedbackbo[valency-3]);
       glGenQueries(1, &q);
       glBeginQuery(GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN, q);
       glBeginTransformFeedback(GL_TRIANGLES);
   }

   glPatchParameteri(GL_PATCH_VERTICES, (unsigned int) valency);
   GLvoid* ptOffset = (GLvoid*)(indexBufPointer  * sizeof(unsigned));

   glDrawArraysInstanced(GL_PATCHES, indexBufPointer, numPatches, (unsigned int)(valency));

   if(settings->captureNoOfGeneratedPrimitives) {
       glEndQuery(GL_PRIMITIVES_GENERATED);
       GLuint primsgen;
       glGetQueryObjectuiv(q2, GL_QUERY_RESULT, &primsgen);
       settings->genPrims += (int)primsgen;
   }

   if(settings->captureGeneratedObject) {
       glEndTransformFeedback();

       glEndQuery(GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN);
       GLuint prims;
       glGetQueryObjectuiv(q, GL_QUERY_RESULT, &prims);
       settings->generatedTriangles[valency-3] = prims;

       //qDebug() << valency << ":  " << settings->generatedTriangles[valency-3];
   }
}


void GBSQuarticRenderer::render(Model& model) {
    Mesh* m = model.getQuarticGBSMesh().getMesh();

    //render EV patches
    glBindVertexArray(vaoEV);
    int bIdx = 0;
    int numPatches;
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

    //render regular faces
    //if(m->hasRegularFaces()) {
    if(settings->renderRegularPatches)
        rr.render(model);

}

