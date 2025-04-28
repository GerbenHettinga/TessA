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
            shader = ps->getPhongShader();
            shader->use();

            shader->setUniform("nMatrix", true);
            shader->setUniform("patchColours", settings->patchColoursRF);
            shader->setUniform("color", settings->m_color);
            shader->setUniform("lightPosition", settings->m_lightPosition);
            shader->setUniform("lightIntensity", settings->m_lightIntensity);
            shader->setUniform("Ka", settings->m_ambient);
            shader->setUniform("Kd", settings->m_diffuse);
            shader->setUniform("Ks", settings->m_specular);
            shader->setUniform("shininess", settings->m_shininess);
            shader->setUniform("surfaceAlpha", settings->surfaceAlpha);
    }


    shader->setUniform("matrix", settings->MVP);
    shader->setUniform("normal_matrix", settings->NormalMatrix);
    shader->setUniform("tessInnerLevel", settings->tessInnerLevel);
    shader->setUniform("tessOuterLevel", settings->tessOuterLevel);
    shader->setUniform("alpha", settings->alpha);
    shader->setUniform("WD", settings->WD);
    shader->setUniform("quadNormals", settings->QuadraticNormals);
    shader->setUniform("extraLayer", true);

    shader->setUniform("avalue", settings->aValue);
    shader->setUniform("bvalue", settings->bValue);
    shader->setUniform("cvalue", settings->cValue);

    shader->setUniform("dvalue", settings->dValue);
    shader->setUniform("evalue", settings->eValue);
    shader->setUniform("fvalue", settings->fValue);

    shader->setUniform("pvalue", settings->pValue);
    shader->setUniform("qvalue", settings->qValue);

    shader->setUniform("rvalue", settings->rValue);
    shader->setUniform("svalue", settings->sValue);

    shader->setUniform("fixedCurves", settings->fixedCurves);
    shader->setUniform("captureGeometry", settings->captureGeneratedObject);
    shader->setUniform("outline", settings->outlinePhong);
    shader->setUniform("spokes", settings->outlineSpokes);

    shader->setUniform("extraLayer", settings->extraLayer);
    shader->setUniform("centreFunctions", settings->centreFunctions);

    shader->setUniform("anim", settings->animationRunning);
    shader->setUniform("anim2", settings->animation2Running);
    shader->setUniform("noiseType", int(settings->NoiseMode));

    shader->setUniform("baseNoiseFrequency", settings->noiseFreq);
    shader->setUniform("baseNoiseFrequencyU", settings->noiseFreqU);
    shader->setUniform("baseNoiseFrequencyV", settings->noiseFreqV);
    shader->setUniform("maxOctaves", settings->maxOctaves);


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

    shader->setUniform("noiseBlendMode", int(settings->NoiseBlendMode));
    shader->setUniform("worleyMode", int(settings->WorleyFunction));
    shader->setUniform("distMetric", int(settings->DistMetric));


    return shader;
}
