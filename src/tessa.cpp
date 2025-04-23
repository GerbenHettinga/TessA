#include "tessa.h"

using namespace modes;

Tessa::Tessa()
{
    drawMode = "Point Cloud";
    surfaceMode = "Phong Tessellation";
    shadeMode = "Normal Buffer";
    primitiveMode = "Polygonal";
    //setWorleyControlsVisible(false);
    updateWindowTitle();
}


Tessa::~Tessa()
{

}

void Tessa::updateWindowTitle() {
    std::string title;

    title = "Polygonal methods - " + drawMode + " - " + surfaceMode + " - " + shadeMode + " - " + primitiveMode;
}


/*
void Tessa::on_OptionFaces_clicked()
{
    ui->SurfaceDisplay->settings.drawFaces = !ui->SurfaceDisplay->settings.drawFaces;
    ui->SurfaceDisplay->update();
}


void Tessa::on_actionPhong_triggered()
{
    ui->SurfaceDisplay->settings.ShadingMode = modes::ShadeModes::Phong;
    shadeMode = "Phong";
    updateWindowTitle();
    ui->SurfaceDisplay->update();
}

void Tessa::on_action_flat_Phong_triggered()
{
    ui->SurfaceDisplay->settings.ShadingMode = modes::ShadeModes::FlatPhong;
    shadeMode = "Phong (flat)";
    updateWindowTitle();
    ui->SurfaceDisplay->update();
}

void Tessa::on_actionNormals_triggered()
{
    ui->SurfaceDisplay->settings.ShadingMode = modes::ShadeModes::NormalBuffer;
    shadeMode = "Normal Buffer";
    updateWindowTitle();
    ui->SurfaceDisplay->update();
}

void Tessa::on_actionUVs_triggered()
{
    ui->SurfaceDisplay->settings.ShadingMode = modes::ShadeModes::UV;
    shadeMode = "UVs";
    updateWindowTitle();
    ui->SurfaceDisplay->update();
}

void Tessa::on_action_flat_Normals_triggered()
{
    ui->SurfaceDisplay->settings.ShadingMode = modes::ShadeModes::FlatNormalBuffer;
    shadeMode = "Normal Buffer (flat)";
    updateWindowTitle();
    ui->SurfaceDisplay->update();
}

void Tessa::on_actionIsophotes_triggered()
{
    ui->SurfaceDisplay->settings.ShadingMode = modes::ShadeModes::Isophotes;
    shadeMode = "Isophotes";
    updateWindowTitle();
    ui->SurfaceDisplay->update();
}

void Tessa::on_action_flat_Isophotes_triggered()
{
    ui->SurfaceDisplay->settings.ShadingMode = modes::ShadeModes::IsophotesFlat;
    shadeMode = "Isophotes (flat)";
    updateWindowTitle();
    ui->SurfaceDisplay->update();
}

void Tessa::on_actionGBC_triggered()
{
    ui->SurfaceDisplay->settings.ShadingMode = modes::ShadeModes::GBC;
    shadeMode = "GBCs";
    updateWindowTitle();
    ui->SurfaceDisplay->update();
}

void Tessa::on_actionSlicing_triggered()
{
    ui->SurfaceDisplay->settings.ShadingMode = modes::ShadeModes::Slicing;
    shadeMode = "Slicing";
    updateWindowTitle();
    ui->SurfaceDisplay->update();
}

void Tessa::on_actionNoise_triggered()
{
    ui->SurfaceDisplay->settings.ShadingMode = modes::ShadeModes::Noise;
    shadeMode = "Noise";
    updateWindowTitle();
    ui->SurfaceDisplay->update();
}


void Tessa::on_actionQuit_triggered()
{
    qApp->quit();
}


void Tessa::on_actionTriangle_3_triggered(){
    ui->SurfaceDisplay->setNonPlanarPolygon(3);;
}

void Tessa::on_actionQuad_3_triggered(){
    ui->SurfaceDisplay->setNonPlanarPolygon(4);
}

void Tessa::on_actionPentagon_3_triggered(){
    ui->SurfaceDisplay->setNonPlanarPolygon(5);
}

void Tessa::on_actionHexagon_3_triggered() {
    ui->SurfaceDisplay->setNonPlanarPolygon(6);
}

void Tessa::on_actionSeptagon_3_triggered() {
    ui->SurfaceDisplay->setNonPlanarPolygon(7);
}

void Tessa::on_actionOctagon_3_triggered() {
    ui->SurfaceDisplay->setNonPlanarPolygon(8);
}

void Tessa::on_actionCube_triggered() {
    ui->SurfaceDisplay->setPolygonObject(":/../models/Cube.obj");
}

void Tessa::on_actionTetrahedron_triggered() {
    ui->SurfaceDisplay->setPolygonObject(":/../models/Tetrahedron.obj");
}

void Tessa::on_actionGoldberg_triggered() {
    ui->SurfaceDisplay->setPolygonObject(":/../models/GoldbergPoly.obj");
}

void Tessa::on_actionDodecahedron_triggered() {
    ui->SurfaceDisplay->setPolygonObject(":/../models/icosahedron.obj");
}

void Tessa::on_actionCube_cross_triggered() {
    ui->SurfaceDisplay->setPolygonObject(":/../models/cubecross.obj");
}

void Tessa::on_actionFile_triggered() {
    std::string fileName = QFileDialog::getOpenFileName(this, "Import OBJ File", "../");
    if(!fileName.isEmpty()) {
        ui->SurfaceDisplay->setPolygonObject(fileName);
    }
}

void Tessa::on_actionPerturb_Vertex_triggered() {
    ui->SurfaceDisplay->settings.animationRunning = !ui->SurfaceDisplay->settings.animationRunning;
}

void Tessa::on_actionPerturb_Normals_triggered() {
    ui->SurfaceDisplay->settings.animation2Running = !ui->SurfaceDisplay->settings.animation2Running;
}

void Tessa::on_actionStart_triggered() {
    if(!ui->SurfaceDisplay->aTimer->isActive()) {
        ui->SurfaceDisplay->aTimer->start(5);
        ui->SurfaceDisplay->eTimer->restart();
        ui->SurfaceDisplay->Rot[2] = 0.0;
    } else {
        ui->SurfaceDisplay->settings.pauseTime = 0.0f;
        ui->SurfaceDisplay->aTimer->stop();
    }
}

void Tessa::on_actionPause_triggered() {
    if(ui->SurfaceDisplay->aTimer->isActive()) {
        ui->SurfaceDisplay->aTimer->stop();
        ui->SurfaceDisplay->settings.pauseTime = (float)ui->SurfaceDisplay->eTimer->nsecsElapsed();
    }
}

void Tessa::on_FrequencySlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.FrequencyLights = value;
    ui->SurfaceDisplay->update();
}

void Tessa::on_alphaSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.alpha = float(value)/99.0f;
    ui->SurfaceDisplay->update();
}


void Tessa::on_tessInnerSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.tessInnerLevel = float(value);
    ui->SurfaceDisplay->update();
}

void Tessa::on_tessOuterSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.tessOuterLevel = float(value);
    ui->SurfaceDisplay->update();
}

void Tessa::on_optionPolygonal_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.Extended = checked;
    if(checked) {
        ui->SurfaceDisplay->settings.PrimitiveMode = modes::PrimitiveModes::Poly;
    } else {
        if(ui->SurfaceDisplay->settings.SurfaceMode == modes::SurfaceModes::SS) {
            ui->SurfaceDisplay->settings.PrimitiveMode = modes::PrimitiveModes::Split;
        } else {
            ui->SurfaceDisplay->settings.PrimitiveMode = modes::PrimitiveModes::Tri;
        }

    }
    ui->SurfaceDisplay->updateBuffers();
}

void Tessa::on_CheckDrawNormals_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.drawNormals = checked;
    ui->SurfaceDisplay->update();
}

void Tessa::on_OptionShowSelected_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.drawSelected = checked;
    ui->SurfaceDisplay->update();
}

void Tessa::on_OptionCPS_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.showControlPoints = checked;
    ui->SurfaceDisplay->update();
}

void Tessa::on_vertexSpinBox_valueChanged(int arg1)
{
    ui->SurfaceDisplay->settings.selectedPoint = arg1;
    ui->SurfaceDisplay->update();
    ui->SurfaceDisplay->setFocus();
}

void Tessa::on_Shininess_valueChanged(double arg1)
{
    ui->SurfaceDisplay->settings.m_shininess = float(arg1);
    ui->SurfaceDisplay->update();
}


void Tessa::on_animateButton_clicked()
{
    if(!ui->SurfaceDisplay->aTimer->isActive()) {
        ui->SurfaceDisplay->aTimer->start(5);
        ui->SurfaceDisplay->eTimer->restart();
        ui->SurfaceDisplay->Rot[2] = 0.0;
    } else {
        ui->SurfaceDisplay->aTimer->stop();
    }
    ui->SurfaceDisplay->settings.animationRunning = !ui->SurfaceDisplay->settings.animationRunning;
}

void Tessa::on_animateButton_2_clicked()
{
    if(!ui->SurfaceDisplay->aTimer->isActive()) {
        ui->SurfaceDisplay->aTimer->start(5);
        ui->SurfaceDisplay->eTimer->restart();
        ui->SurfaceDisplay->Rot[2] = 0.0;
    } else {
        ui->SurfaceDisplay->aTimer->stop();
    }
    ui->SurfaceDisplay->settings.animation2Running = !ui->SurfaceDisplay->settings.animation2Running;
}

void Tessa::on_OptionTexture_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.TextureCoordinateMode = checked;
    ui->SurfaceDisplay->updateBuffers();
}

void Tessa::on_alphaSurfaceSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.surfaceAlpha = float(value)/99.0f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_actionSave_polygon_triggered()
{
    std::string fileName = QFileDialog::getSaveFileName(this, "Save polygon OBJ File", "../");
    if(!fileName.isEmpty()) {
        ui->SurfaceDisplay->savePolygon(fileName);
    }
}

void Tessa::on_actionOpen_polygon_triggered()
{
    std::string fileName = QFileDialog::getOpenFileName(this, "Open polygon OBJ File", "../");
    if(!fileName.isEmpty()) {
        ui->SurfaceDisplay->openPolygon(fileName);
    }
}

void Tessa::on_pAngleSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.p_angle = float(value)/100.0f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_pAngleSlider_2_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.q_angle = float(value)/100.0f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_aValueSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.aValue = float(value)/100.0f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_bValueSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.bValue = float(value)/100.0f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_cValueSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.cValue = float(value)/100.0f;
    ui->SurfaceDisplay->update();
}


void Tessa::on_CheckWeightDeficiency_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.WD = checked;
    ui->SurfaceDisplay->update();
}

void Tessa::on_actionCapture_Geometry_triggered()
{
    ui->SurfaceDisplay->settings.captureGeneratedObject = !ui->SurfaceDisplay->settings.captureGeneratedObject;
}

void Tessa::on_actionTake_Screenshot_triggered()
{
    ui->SurfaceDisplay->takeScreenshot();
}


void Tessa::on_saveGeometryButton_clicked()
{
    std::string fileName = QFileDialog::getSaveFileName(this, "Save polygon OBJ File", "../");
    if(!fileName.isEmpty()) {
        ui->SurfaceDisplay->update();
        ui->SurfaceDisplay->saveGeneratedGeometry(fileName);
    }
}


void Tessa::on_checkBox_clicked()
{
    ui->SurfaceDisplay->settings.WD = !ui->SurfaceDisplay->settings.WD;
    ui->SurfaceDisplay->update();
}

void Tessa::on_checkBox_3_clicked()
{
    ui->SurfaceDisplay->settings.fixedCurves = !ui->SurfaceDisplay->settings.fixedCurves;
    ui->SurfaceDisplay->update();
}

void Tessa::on_actionNothing_triggered()
{
    ui->SurfaceDisplay->settings.DrawingMode = modes::DrawModes::Nothing;
    drawMode = "Nothing";
    updateWindowTitle();
    ui->SurfaceDisplay->update();
}

void Tessa::on_actionPoint_Cloud_triggered()
{
    ui->SurfaceDisplay->settings.DrawingMode = modes::DrawModes::PointCloud;
    drawMode = "Point Cloud";
    updateWindowTitle();
    ui->SurfaceDisplay->update();
}

void Tessa::on_actionWire_frame_triggered()
{
    ui->SurfaceDisplay->settings.DrawingMode = modes::DrawModes::WireFrame;
    drawMode = "Wireframe";
    updateWindowTitle();
    ui->SurfaceDisplay->update();
}

void Tessa::on_actionSolid_triggered()
{
    ui->SurfaceDisplay->settings.DrawingMode = modes::DrawModes::Solid;
    drawMode = "Solid";
    updateWindowTitle();
    ui->SurfaceDisplay->update();
}

void Tessa::on_checkBox_4_clicked(bool checked)
{
    if(checked) {
        ui->SurfaceDisplay->settings.MeshMode = modes::MeshModes::ACC2;
    } else {
        ui->SurfaceDisplay->settings.MeshMode = modes::MeshModes::PolyMesh;
    }
    ui->SurfaceDisplay->updateBuffers();
}


void Tessa::on_outline_checkBox_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.outlinePhong = checked;
    ui->SurfaceDisplay->update();
}


void Tessa::on_patchColoursRF_checkBox_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.patchColoursRF = checked;
    ui->SurfaceDisplay->update();
}

void Tessa::on_actionrecalculate_normals_triggered()
{
    //ui->SurfaceDisplay->model.getCurrentLevel()->getNormals();
    ui->SurfaceDisplay->updateBuffers();
}



void Tessa::on_optionVN_clicked()
{
    ui->SurfaceDisplay->settings.MeshMode = MeshModes::PolyMesh;
    ui->SurfaceDisplay->updateBuffers();
}


void Tessa::on_optionNada_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.MeshMode = MeshModes::Nothing;
    ui->SurfaceDisplay->updateBuffers();
}


void Tessa::on_optionQuadMesh_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.MeshMode = MeshModes::QuadMesh;
    ui->SurfaceDisplay->updateBuffers();
}

void Tessa::on_optionACC2_clicked()
{
    ui->SurfaceDisplay->settings.MeshMode = MeshModes::ACC2;
    ui->SurfaceDisplay->updateBuffers();
}

void Tessa::on_optionGBSCubic_clicked()
{
    ui->SurfaceDisplay->settings.MeshMode = MeshModes::CubicGBS;
    ui->SurfaceDisplay->updateBuffers();
}

void Tessa::on_optionGBSQuadratic_clicked()
{
    ui->SurfaceDisplay->settings.MeshMode = MeshModes::QuadraticGBS;
    ui->SurfaceDisplay->updateBuffers();
}

void Tessa::on_optionGBSQuartic_clicked()
{
    ui->SurfaceDisplay->settings.MeshMode = MeshModes::QuarticGBS;
    ui->SurfaceDisplay->updateBuffers();
}

void Tessa::onSelectedChanged() {
    Vertex* v = ui->SurfaceDisplay->selectedVertex;


    ui->vertexX->blockSignals(true); ui->vertexY->blockSignals(true); ui->vertexZ->blockSignals(true);

    ui->normalX->blockSignals(true); ui->normalY->blockSignals(true); ui->normalZ->blockSignals(true);

    ui->persistanceSlider->blockSignals(true); ui->opacitySlider->blockSignals(true); ui->distortionSlider->blockSignals(true);

    ui->vertexX->setValue(v->coords.x());
    ui->vertexY->setValue(v->coords.y());
    ui->vertexZ->setValue(v->coords.z());

    ui->normalX->setValue(v->normal.x());
    ui->normalY->setValue(v->normal.y());
    ui->normalZ->setValue(v->normal.z());

    ui->persistanceSlider->setValue(v->noise.x()*99);
    ui->opacitySlider->setValue(v->noise.y()*99);
    ui->distortionSlider->setValue(v->noise.z()*99);


    ui->vertexX->blockSignals(false); ui->vertexY->blockSignals(false); ui->vertexZ->blockSignals(false);

    ui->normalX->blockSignals(false); ui->normalY->blockSignals(false); ui->normalZ->blockSignals(false);

    ui->persistanceSlider->blockSignals(false); ui->opacitySlider->blockSignals(false); ui->distortionSlider->blockSignals(false);


}

void Tessa::on_vertexX_valueChanged(double arg1)
{
    ui->SurfaceDisplay->selectedVertex->coords.setX(arg1);
    ui->SurfaceDisplay->updateBuffers(true);
}

void Tessa::on_vertexY_valueChanged(double arg1)
{
    ui->SurfaceDisplay->selectedVertex->coords.setY(arg1);
    ui->SurfaceDisplay->updateBuffers(true);
}

void Tessa::on_vertexZ_valueChanged(double arg1)
{
    ui->SurfaceDisplay->selectedVertex->coords.setZ(arg1);
    ui->SurfaceDisplay->updateBuffers(true);
}

void Tessa::on_normalX_valueChanged(double arg1)
{
    ui->SurfaceDisplay->selectedVertex->normal.setX(arg1);
    ui->SurfaceDisplay->selectedVertex->normal.normalize();
    ui->SurfaceDisplay->updateBuffers(ui->SurfaceDisplay->selectedVertex);
}

void Tessa::on_normalY_valueChanged(double arg1)
{
    ui->SurfaceDisplay->selectedVertex->normal.setY(arg1);
    ui->SurfaceDisplay->selectedVertex->normal.normalize();
    ui->SurfaceDisplay->updateBuffers(ui->SurfaceDisplay->selectedVertex);
}

void Tessa::on_normalZ_valueChanged(double arg1)
{
    ui->SurfaceDisplay->selectedVertex->normal.setZ(arg1);
    ui->SurfaceDisplay->selectedVertex->normal.normalize();
    ui->SurfaceDisplay->updateBuffers(ui->SurfaceDisplay->selectedVertex);
}

void Tessa::on_persistanceSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->selectedVertex->noise.setX((float) value / 100.0);
    ui->SurfaceDisplay->updateBuffers(ui->SurfaceDisplay->selectedVertex);
}

void Tessa::on_opacitySlider_valueChanged(int value)
{
    ui->SurfaceDisplay->selectedVertex->noise.setY((float) value / 100.0);
    ui->SurfaceDisplay->updateBuffers(ui->SurfaceDisplay->selectedVertex);
}

void Tessa::on_distortionSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->selectedVertex->noise.setZ(float(value) / 100.0f);
    ui->SurfaceDisplay->updateBuffers(ui->SurfaceDisplay->selectedVertex);
}

void Tessa::on_noiseBaseFreq_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.noiseFreq = float(value)/5.0f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_maxOctaves_valueChanged(int arg1)
{
    ui->SurfaceDisplay->settings.maxOctaves = arg1;
    ui->SurfaceDisplay->update();
}


void Tessa::on_worleyJitter_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.jitter = float(value) / 100.0f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_perlin_clicked()
{
    ui->SurfaceDisplay->settings.NoiseMode = NoiseModes::Perlin;
    setWorleyControlsVisible(false);
    ui->SurfaceDisplay->update();
}

void Tessa::on_worley_clicked()
{
    ui->SurfaceDisplay->settings.NoiseMode = NoiseModes::Worley;
    setWorleyControlsVisible(true);
    ui->SurfaceDisplay->update();
}

void Tessa::setWorleyControlsVisible(bool enabled){
    ui->worleyFunction->setVisible(enabled);
    ui->jitter->setVisible(enabled);
    ui->distMetric->setVisible(enabled);
}

void Tessa::on_distMetric_currentIndexChanged(int index)
{
    ui->SurfaceDisplay->settings.DistMetric = DistMetrics(index);
    ui->SurfaceDisplay->update();
}

void Tessa::on_noiseBaseFreqU_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.noiseFreqU = float(value)/5.f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_noiseBaseFreqV_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.noiseFreqV = float(value)/5.f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_checkShowCtrlMesh_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.showControlMesh = checked;
    ui->SurfaceDisplay->update();
}


void Tessa::on_checkWeightDeficiency_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.WD = checked;
    ui->SurfaceDisplay->update();
}


void Tessa::on_subdivisionLevelSpinBox_2_valueChanged(int arg1)
{
    ui->SurfaceDisplay->model.setSubdivisionLevel(arg1, ui->DegreeSpinBox->value());
    ui->SurfaceDisplay->updateBuffers();
}

void Tessa::on_outlineSpokes_checkBox_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.outlineSpokes = checked;
    ui->SurfaceDisplay->update();
}



void Tessa::on_pushButton_clicked()
{
    ui->SurfaceDisplay->subdivideDS();
    ui->SurfaceDisplay->updateBuffers();
}



void Tessa::on_pushButton_2_clicked()
{
    //Mesh* m = ui->SurfaceDisplay->model.getCurrentLevel();
    //*m = ui->SurfaceDisplay->model.getCurrentLevel()->dual();
    //ui->SurfaceDisplay->model.recalculateBasedOnVertex(nullptr);
    ui->SurfaceDisplay->updateBuffers();
}

void Tessa::on_LinSubdivideButton_clicked()
{
    ui->SurfaceDisplay->model.linSubdivide();
    ui->SurfaceDisplay->updateBuffers();
}

void Tessa::on_DualButton_clicked()
{
    ui->SurfaceDisplay->model.dual();
    ui->SurfaceDisplay->updateBuffers();
}

void Tessa::on_EvenSmoothButton_clicked()
{
    ui->SurfaceDisplay->model.evenSmooth();
    ui->SurfaceDisplay->updateBuffers();
}

void Tessa::on_OddSmoothButton_clicked()
{
    ui->SurfaceDisplay->model.oddSmooth();
    ui->SurfaceDisplay->updateBuffers();
}

void Tessa::on_DegreeSpinBox_valueChanged(int arg1)
{
   // ui->SurfaceDisplay->model.setDegree((unsigned)arg1);
}

void Tessa::on_centreFunctionsCheckBox_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.centreFunctions = checked;
    ui->SurfaceDisplay->update();
}

void Tessa::on_EFextraLayerCheckBox_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.extraLayer = checked;
    ui->SurfaceDisplay->update();
}

void Tessa::on_dValueSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.dValue = float(value)/100.0f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_eValueSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.eValue = float(value)/100.0f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_fValueSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.fValue = float(value)/100.0f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_rValueSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.rValue = float(value)/100.0f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_sValueSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.sValue = float(value)/100.0f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_pValueSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.pValue = float(value)/100.0f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_qValueSlider_valueChanged(int value)
{
    ui->SurfaceDisplay->settings.qValue = float(value)/100.0f;
    ui->SurfaceDisplay->update();
}

void Tessa::on_renderRegularPatchesCheckBox_clicked(bool checked)
{
    ui->SurfaceDisplay->settings.renderRegularPatches = checked;
    ui->SurfaceDisplay->update();
}
*/