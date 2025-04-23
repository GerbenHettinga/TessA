#include "surfacerenderer.h"
#include "../renderparameters.h"
#include <algorithm>

SurfaceRenderer::SurfaceRenderer(RenderParameters* rp) :
    settings(rp)
{
    
}

SurfaceRenderer::~SurfaceRenderer() {
    for(PolygonShader* ps : polyShaders) {
        delete ps;
    }
}

Shader* SurfaceRenderer::setShaderUniforms(PolygonShader *ps) {
    Shader* shader;

    //select correct shader program and set uniforms

    switch(settings->ShadingMode) {
        case ShadeModes::Isophotes              :
            shader = ps->getIsophoteShader();
            shader->use();
            shader->setUniform("nMatrix", true);
            shader->setUniform("frequency", (float) settings->FrequencyLights);
            shader->setUniform("patchColours", settings->patchColoursRF);
            break;
        case ShadeModes::Slicing                :
            shader = ps->getSliceShader();
            shader->use();
            shader->setUniform("nMatrix", true);
            shader->setUniform("lightPosition", settings->m_lightPosition);
            shader->setUniform("frequency", (float) settings->FrequencyLights);
            shader->setUniform("patchColours", settings->patchColoursRF);
            break;
        case ShadeModes::GBC                    :
            shader = ps->getGBCShader();
            shader->use();
            shader->setUniform("nMatrix", true);
            shader->setUniform("selectedVertex", settings->selectedPoint);
            break;
        case ShadeModes::UV                    :
            shader = ps->getUVShader();
            shader->use();
            shader->setUniform("nMatrix", true);
            break;
        case ShadeModes::Noise                  :
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            glEnable( GL_BLEND );
            shader = ps->getNoiseShader();
            shader->use();
            shader->setUniform("nMatrix", true);
            break;
        case ShadeModes::NormalBuffer           :
            shader = ps->getNormalShader();
            shader->use();
            shader->setUniform("nMatrix", false);
            break;
        case ShadeModes::FlatNormalBuffer       :
            shader = ps->getFlatNormalShader();
            shader->use();
            shader->setUniform("nMatrix", false);
            break;
        default                                 :
            getError();

            shader = ps->getPhongShader();
            shader->use();

            getError();

            shader->setUniform("nMatrix", true);
            getError();
            shader->setUniform("patchColours", settings->patchColoursRF);
            getError();
            shader->setUniform("color", settings->m_color);
            getError();
            shader->setUniform("lightPosition", settings->m_lightPosition);
            getError();
            shader->setUniform("lightIntensity", settings->m_lightIntensity);
            getError();
            shader->setUniform("Ka", settings->m_ambient);
            getError();
            shader->setUniform("Kd", settings->m_diffuse);
            getError();
            shader->setUniform("Ks", settings->m_specular);
            getError();
            shader->setUniform("shininess", settings->m_shininess);
            getError();
            shader->setUniform("surfaceAlpha", settings->surfaceAlpha);

            getError();
    }


    getError();

    shader->setUniform("matrix", settings->MVP);
    getError();
    shader->setUniform("normal_matrix", settings->NormalMatrix);
    getError();
    shader->setUniform("tessInnerLevel", settings->tessInnerLevel);
    getError();
    shader->setUniform("tessOuterLevel", settings->tessOuterLevel);
    getError();
    shader->setUniform("alpha", settings->alpha);
    getError();
    shader->setUniform("WD", settings->WD);
    getError();
    shader->setUniform("quadNormals", settings->QuadraticNormals);
    getError();
    shader->setUniform("extraLayer", true);

    getError();

    shader->setUniform("avalue", settings->aValue);
    shader->setUniform("bvalue", settings->bValue);
    shader->setUniform("cvalue", settings->cValue);

    getError();

    shader->setUniform("dvalue", settings->dValue);
    shader->setUniform("evalue", settings->eValue);
    shader->setUniform("fvalue", settings->fValue);

    shader->setUniform("pvalue", settings->pValue);
    shader->setUniform("qvalue", settings->qValue);

    shader->setUniform("rvalue", settings->rValue);
    shader->setUniform("svalue", settings->sValue);

    getError();

    shader->setUniform("fixedCurves", settings->fixedCurves);
    shader->setUniform("captureGeometry", settings->captureGeneratedObject);
    shader->setUniform("outline", settings->outlinePhong);
    shader->setUniform("spokes", settings->outlineSpokes);

    getError();

    shader->setUniform("extraLayer", settings->extraLayer);
    shader->setUniform("centreFunctions", settings->centreFunctions);

    shader->setUniform("anim", settings->animationRunning);
    shader->setUniform("anim2", settings->animation2Running);
    shader->setUniform("noiseType", int(settings->NoiseMode));

    shader->setUniform("baseNoiseFrequency", settings->noiseFreq);
    shader->setUniform("baseNoiseFrequencyU", settings->noiseFreqU);
    shader->setUniform("baseNoiseFrequencyV", settings->noiseFreqV);
    shader->setUniform("maxOctaves", settings->maxOctaves);

    getError();

    //shader->setUniform("noiseToRGB", settings->noiseToRGB);
    //shader->setUniform("paramX", settings->paramX);
    //shader->setUniform("paramY", settings->paramY);
    shader->setUniform("seed", /*settings->seed*/ 2.3f);
    shader->setUniform("distortion.enabled", settings->noiseDistEnabled);
    shader->setUniform("distortion.mode", int(settings->DistortionMode));
    shader->setUniform("filtering.enabled", settings->filterEnabled);
    shader->setUniform("filtering.mode", int(settings->FilterMode));
    shader->setUniform("sineFreq", settings->sineFreq);
    shader->setUniform("sineAngle", settings->sineAngle);
    shader->setUniform("jitter", settings->jitter);

    getError();

    shader->setUniform("noiseBlendMode", int(settings->NoiseBlendMode));
    shader->setUniform("worleyMode", int(settings->WorleyFunction));
    shader->setUniform("distMetric", int(settings->DistMetric));

    getError();

    return shader;
}
