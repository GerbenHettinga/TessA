#include "quadmeshrenderer.h"
#include "../meshtypes/quadmesh.h"
#include "../mesh/mesh.h"


QuadMeshRenderer::QuadMeshRenderer(RenderParameters* rp)
    : SurfaceRenderer(rp)
{
    initBuffers();
    initShaders();
}


QuadMeshRenderer::~QuadMeshRenderer() {

}

void QuadMeshRenderer::initBuffers() {
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);

    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);

    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, nullptr);

    glGenBuffers(1, &nbo);
    glBindBuffer(GL_ARRAY_BUFFER, nbo);

    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, nullptr);

    glGenBuffers(1, &ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
}

void QuadMeshRenderer::initShaders() {
    polyShaders.reserve(1);
    polyShaders.push_back(new PolygonShader("../shaders/vert/vertshaderqm.glsl"));

    // for transform feedback
    //const char* varyings[1] = {"pos"};
    //glTransformFeedbackVaryings(polyShaders[0]->getFlatNormalShader()->getId(), 1, varyings, GL_SEPARATE_ATTRIBS);
    //link so that varyings are processed
    //polyShaders[0]->linkAll();
}

void QuadMeshRenderer::updateBuffers(Model &model) {
    QuadMesh& m = model.getQuadMesh();

    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, m.getVertices().size() * sizeof(glm::vec3), m.getVertices().data(), GL_STATIC_DRAW);

    glBindBuffer(GL_ARRAY_BUFFER, nbo);
    glBufferData(GL_ARRAY_BUFFER, m.getNormals().size() * sizeof(glm::vec3), m.getNormals().data(), GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, m.getIndices().size() * sizeof(unsigned), m.getIndices().data(), GL_STATIC_DRAW);
}

void QuadMeshRenderer::render(Model& model) {
    getError();

    glBindVertexArray(vao);

    Shader* s = setShaderUniforms(polyShaders[0]);

    QuadMesh& qm = model.getQuadMesh();

    getError();


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

    getError();

    glPointSize(5.0f);
    //render the wireframe
    glEnable(GL_PRIMITIVE_RESTART);
    glPrimitiveRestartIndex(0xFFFFFFFF);

    glDrawElements(GL_TRIANGLE_FAN, qm.getIndices().size(), GL_UNSIGNED_INT, (GLvoid *) 0);

    glBindVertexArray(0);
    glDisable(GL_PRIMITIVE_RESTART);

    getError();

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

    getError();
}

