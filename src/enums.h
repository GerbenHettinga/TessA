#ifndef ENUMS_H
#define ENUMS_H

namespace modes {
    enum class DrawModes  {PointCloud, WireFrame, Solid, Nothing};
    enum class ShadeModes  {FlatNormalBuffer, NormalBuffer, FlatPhong, Phong, GBC, Isophotes, IsophotesFlat, Slicing, UV, Noise};
    enum class SurfaceModes {Flat, Phong, PhongImplicit, PN, PNImplicit, CT, Gregory, SS, CTBB, Tensor, Mixed};
    enum class MeshModes {PolyMesh, ACC2, CubicGBS, QuadraticGBS, QuarticGBS, QuadMesh, Nothing, ControlMesh};
    enum class PrimitiveModes {Split, Tri, Poly};
    enum class TriangulationModes {SuperMinimal, Minimal, SuperPie, Pie};
    enum class CoordinateModes {Fly, Texture};

    enum DrawOptions : bool {Normals = false, Faces = false};

    enum class NoiseBlendModes {Colour, Noise, NoiseColour};
    enum class NoiseModes {Perlin, Worley};
    enum class DistMetrics {Euclidean, Manhattan};
    enum class WorleyFunctions {F1, F2, F3, F4, F2F1, F2F1Squared};
    enum class DistortionModes {Ripple, Domain, Sine, Wood};
    enum class FilterModes {Pulse, HighPass, LowPass, BandPass, BandPassNormal};
    enum class ColourBlendingModes {
        Add,
        Average,
        ColorBurn,
        ColorDodge,
        Darken,
        Difference,
        Exclusion,
        Glow,
        HardLight,
        HardMix,
        Lighten,
        LinearBurn,
        LinearDodge,
        LinearLight,
        Multiply,
        Negation,
        Normal,
        Overlay,
        Phoenix,
        PinLight,
        Reflect,
        Screen,
        SoftLight,
        Subtract,
        VividLight
    };
}

#endif // ENUMS_H
