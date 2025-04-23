#include "regularrenderer.h"

RegularRenderer::RegularRenderer(RenderParameters* rp)
    : SurfaceRenderer(rp)
{
    initBuffers();
    initShaders();
}

RegularRenderer::~RegularRenderer() {

}

void RegularRenderer::initBuffers() {
    //regular buffers for regular patches
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);

    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);

    for(GLuint i = 0; i < 4; ++i) {
        glEnableVertexAttribArray(i);
        glVertexAttribPointer(i, 3, GL_FLOAT, GL_FALSE, 4*sizeof(glm::vec3), (void*) (i*sizeof(glm::vec3)));
    }

    glBindVertexArray(0);
}

void RegularRenderer::initShaders() {
    polyShaders.push_back(new PolygonShader(4,
                                         std::string("../shaders/vert/vertshaderacc1.glsl"),
                                         std::string("../shaders/acc1/tcacc1.glsl"),
                                         std::string("../shaders/acc1/teacc1bs.glsl") ));


    // for transform feedback
    //const char* varyings[1] = {"pos"};

    //glTransformFeedbackVaryings(polyShaders[0]->getFlatNormalShader()->getId(), 1, varyings, GL_SEPARATE_ATTRIBS);
    //polyShaders[0]->linkAll();
}


void RegularRenderer::updateBuffers(Model& model) {
    GenBSplineMesh& m = model.getGBSMesh();

    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, m.getRegularBs().size() * sizeof(glm::vec3), m.getRegularBs().data(), GL_STATIC_DRAW);

    //qDebug() << e << "buffers";
}

void RegularRenderer::render(Model& model) {


    glBindVertexArray(vao);

    Mesh* m = model.getGBSMesh().getMesh();

    if(m->hasRegularFaces()) {
        Shader* shader = setShaderUniforms(polyShaders[0]);

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
            glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, settings->feedbackbo[1]);
            glGenQueries(1, &q);
            glBeginQuery(GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN, q);
            glBeginTransformFeedback(GL_TRIANGLES);
        }

        int numPatches = m->getNumberOfRegularFaces() * 4;

        glPatchParameteri(GL_PATCH_VERTICES, 4);
        glDrawArrays(GL_PATCHES, 0, numPatches);

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
            settings->generatedTriangles[1] = prims;

            //qDebug() << 4 << ":  " << settings->generatedTriangles[1];
        }
    }

    glBindVertexArray(0);


}
