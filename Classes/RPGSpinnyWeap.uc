//=============================================================================
// RPGSpinnyWeap.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

//Total hack to make overlays work even if using a StaticMesh
class RPGSpinnyWeap extends SpinnyWeap;

var array<Material> OriginalSkins;

var array<Shader> DuplicateShaders;
var array<Combiner> DuplicateCombiners;
var array<FinalBlend> OverlayFinals;

struct StaticMeshMaterialStruct
{
    var bool EnableCollision;
    var Material Material;
};
var array<StaticMeshMaterialStruct> StaticMeshMaterials;

var Coords CurCoords;

function PostBeginPlay()
{
    local vector X, Y, Z;

    GetAxes(Rotation, X, Y, Z);
    X = Y;
    Y = Z cross X;
    SetRotation(OrthoRotation(X, Y, Z));

    CurCoords.XAxis = X;
    CurCoords.YAxis = Y;
    CurCoords.ZAxis = Z;
}

function Tick(float Delta)
{
    local float Angle;

    CurrentTime += Delta / Level.TimeDilation;

    Angle = Delta * SpinRate / 65536f * 2 * pi;
    CurCoords.XAxis = Normal(CurCoords.XAxis * cos(Angle) + Normal(CurCoords.YAxis - (CurCoords.XAxis dot CurCoords.YAxis) * CurCoords.XAxis) * sin(Angle));
    CurCoords.YAxis = CurCoords.ZAxis cross CurCoords.XAxis;

    SetRotation(OrthoRotation(CurCoords.XAxis, CurCoords.YAxis, CurCoords.ZAxis));
}

simulated function SetOverlayMaterial(Material mat, float time, bool bOverride)
{
    local int i;

    Super.SetOverlayMaterial(mat, time, bOverride);

    if(SkeletalMesh(Mesh) != None || OverlayMaterial == None || (StaticMesh == None && VertMesh(Mesh) == None))
        return;

    //reset skins
    Skins = OriginalSkins;

    //reset all current allocated overlay objects
    for(i = 0; i < DuplicateShaders.Length; i++)
    {
        DuplicateShaders[i].Diffuse = None;
        /*
        DuplicateShaders[i].Opacity = None;
        DuplicateShaders[i].Specular = None;
        DuplicateShaders[i].SpecularityMask = None;
        DuplicateShaders[i].SelfIllumination = None;
        DuplicateShaders[i].SelfIlluminationMask = None;
        DuplicateShaders[i].Detail = None;
        DuplicateShaders[i].DetailScale = 8.0;
        DuplicateShaders[i].OutputBlending = OB_Normal;
        DuplicateShaders[i].TwoSided = false;
        DuplicateShaders[i].Wireframe = false;
        DuplicateShaders[i].PerformLightingOnSpecularPass = false;
        DuplicateShaders[i].ModulateSpecular2X = false;
        */
    }
    for(i = 0; i < DuplicateCombiners.Length; i++)
    {
        /*
        DuplicateCombiners[i].CombineOperation = CO_Use_Color_From_Material1;
        DuplicateCombiners[i].AlphaOperation = AO_Use_Mask;
        DuplicateCombiners[i].Material1 = None;
        */
        DuplicateCombiners[i].Material2 = None;
        /*
        DuplicateCombiners[i].Mask = None;
        DuplicateCombiners[i].InvertMask =f alse;
        DuplicateCombiners[i].Modulate2X = false;
        DuplicateCombiners[i].Modulate4X = false;
        */
    }
    for(i = 0; i < OverlayFinals.Length; i++)
    {
        OverlayFinals[i].Material = None;
        /*
        OverlayFinals[i].FrameBufferBlending = FB_Overwrite;
        OverlayFinals[i].ZWrite = true;
        OverlayFinals[i].ZTest = true;
        OverlayFinals[i].AlphaTest = false;
        OverlayFinals[i].TwoSided = false;
        OverlayFinals[i].AlphaRef = 0;
        */
    }

    if(StaticMesh != None && DrawType == DT_StaticMesh)
    {
        //can you believe this actually works?
        SetPropertyText("StaticMeshMaterials", StaticMesh.GetPropertyText("Materials"));
        if(Skins.Length < StaticMeshMaterials.Length)
            for(i = Skins.Length; i < StaticMeshMaterials.Length; i++)
                Skins[i] = StaticMeshMaterials[i].Material;
    }
    else if(VertMesh(Mesh) != None && DrawType == DT_Mesh)
        SetPropertyText("Skins", Mesh.GetPropertyText("Materials"));

    for(i = 0; i < Skins.Length; i++)
        Skins[i] = ApplyOverlayMaterial(Skins[i], i);
}

function Material ApplyOverlayMaterial(Material SkinMaterial, int Index)
{
    local Texture Tex;
    local int i;
    local bool bForceTranslucentFinalBlend;
    local FinalBlend OverlayFinalBlend;
    local bool bAlreadyAllocated;
    local bool bNeedsDuplicate;
    local Material TempOverlay;

    if(Shader(OverlayMaterial) == None && Combiner(OverlayMaterial) == None)
        return OverlayMaterial;

    Tex = Texture(GetTextureFromMaterial(SkinMaterial));
    if(Tex == None)
        return SkinMaterial;

    for(i = 0; i < OverlayFinals.Length; i++)
    {
        if(Tex == OverlayFinals[i].Material)
            return OverlayFinals[i];
        if(OverlayFinals[i].Material == None)
        {
            //first empty final blend in array; use this one if needed
            OverlayFinalBlend = OverlayFinals[i];
            bAlreadyAllocated = true;
            break;
        }
    }

    for(i = 0; i < Index; i++)
    {
        if(FinalBlend(Skins[i]) == None || FinalBlend(Skins[i]).Material == OverlayMaterial)
        {
            bNeedsDuplicate = true;
            break;
        }
    }

    if(!bNeedsDuplicate)
    {
        if(Shader(OverlayMaterial) != None)
            Shader(OverlayMaterial).Diffuse = Tex;
        else if(Combiner(OverlayMaterial) != None)
            Combiner(OverlayMaterial).Material2 = Tex;

        TempOverlay = OverlayMaterial;
    }
    else
    {
        if(Shader(OverlayMaterial) != None)
        {
            TempOverlay = GetDuplicateShader();
            Shader(TempOverlay).Diffuse = Tex;
        }
        else if(Combiner(OverlayMaterial) != None)
        {
            TempOverlay = GetDuplicateCombiner();
            Combiner(TempOverlay).Material2 = Tex;
        }
    }

    if(Tex.bAlphaTexture || Tex.bMasked)
        bForceTranslucentFinalBlend = true;

    if(OverlayFinalBlend == None)
        OverlayFinalBlend = FinalBlend(Level.ObjectPool.AllocateObject(class'FinalBlend'));
    if(FinalBlend(TempOverlay) != None)
    {
        OverlayFinalBlend.Material = TempOverlay;
        OverlayFinalBlend.FrameBufferBlending = FinalBlend(TempOverlay).FrameBufferBlending;
        OverlayFinalBlend.ZWrite = FinalBlend(TempOverlay).ZWrite;
        OverlayFinalBlend.ZTest = FinalBlend(TempOverlay).ZTest;
        OverlayFinalBlend.AlphaTest = FinalBlend(TempOverlay).AlphaTest;
        OverlayFinalBlend.TwoSided = FinalBlend(TempOverlay).TwoSided;
        OverlayFinalBlend.AlphaRef = FinalBlend(TempOverlay).AlphaRef;
        if(!bAlreadyAllocated)
            OverlayFinals[OverlayFinals.Length] = OverlayFinalBlend;
        return OverlayFinalBlend;
    }
    else
    {
        if(bForceTranslucentFinalBlend)
        {
            OverlayFinalBlend.Material = TempOverlay;
            OverlayFinalBlend.FrameBufferBlending = FB_Translucent;
            OverlayFinalBlend.ZWrite = false;
            OverlayFinalBlend.ZTest = true;
            OverlayFinalBlend.AlphaTest = false;
            OverlayFinalBlend.TwoSided = Tex.bTwoSided;
            OverlayFinalBlend.AlphaRef = 0;
            if(!bAlreadyAllocated)
                OverlayFinals[OverlayFinals.Length] = OverlayFinalBlend;
            return OverlayFinalBlend;
        }
        else
            return TempOverlay;
    }
}

final function Shader GetDuplicateShader()
{
    local Shader S;
    local int i;

    for(i = 0; i < DuplicateShaders.Length; i++)
    {
        if(DuplicateShaders[i].Diffuse == None)
        {
            S = DuplicateShaders[i];
            break;
        }
    }

    if(S == None)
        S = Shader(Level.ObjectPool.AllocateObject(class'Shader'));
    S.Opacity = Shader(OverlayMaterial).Opacity;
    S.Specular = Shader(OverlayMaterial).Specular;
    S.SpecularityMask = Shader(OverlayMaterial).SpecularityMask;
    S.SelfIllumination = Shader(OverlayMaterial).SelfIllumination;
    S.SelfIlluminationMask = Shader(OverlayMaterial).SelfIlluminationMask;
    S.Detail = Shader(OverlayMaterial).Detail;
    S.DetailScale = Shader(OverlayMaterial).DetailScale;
    S.OutputBlending = Shader(OverlayMaterial).OutputBlending;
    S.TwoSided = Shader(OverlayMaterial).TwoSided;
    S.Wireframe = Shader(OverlayMaterial).Wireframe;
    S.PerformLightingOnSpecularPass = Shader(OverlayMaterial).PerformLightingOnSpecularPass;
    S.ModulateSpecular2X = Shader(OverlayMaterial).ModulateSpecular2X;

    return S;
}

final function Combiner GetDuplicateCombiner()
{
    local Combiner C;
    local int i;

    for(i = 0; i < DuplicateCombiners.Length; i++)
    {
        if(DuplicateCombiners[i].Material2 == None)
        {
            C = DuplicateCombiners[i];
            break;
        }
    }

    if(C == None)
        C = Combiner(Level.ObjectPool.AllocateObject(class'Combiner'));
    C.CombineOperation = Combiner(OverlayMaterial).CombineOperation;
    C.AlphaOperation = Combiner(OverlayMaterial).AlphaOperation;
    C.Material1 = Combiner(OverlayMaterial).Material1;
    C.Mask = Combiner(OverlayMaterial).Mask;
    C.InvertMask = Combiner(OverlayMaterial).InvertMask;
    C.Modulate2X = Combiner(OverlayMaterial).Modulate2X;
    C.Modulate4X = Combiner(OverlayMaterial).Modulate4X;

    return C;
}

static final function Material GetTextureFromMaterial(Material Material)
{
    if(Texture(Material) != None)
        return Material;
    else if(FinalBlend(Material) != None)
        return GetTextureFromMaterial(FinalBlend(Material).Material);
    else if(Shader(Material) != None)
        return GetTextureFromMaterial(Shader(Material).Diffuse);
    else if(Combiner(Material) != None)
        return GetTextureFromMaterial(Combiner(Material).Material2);
    return None;
}

simulated function Destroyed()
{
    local int i;

    for(i = 0; i < DuplicateShaders.Length; i++)
    {
        if(DuplicateShaders[i] != None)
        {
            Level.ObjectPool.FreeObject(DuplicateShaders[i]);
            DuplicateShaders[i] = None;
        }
    }
    for(i = 0; i < DuplicateCombiners.Length; i++)
    {
        if(DuplicateCombiners[i] != None)
        {
            Level.ObjectPool.FreeObject(DuplicateCombiners[i]);
            DuplicateCombiners[i] = None;
        }
    }
    for(i = 0; i < OverlayFinals.Length; i++)
    {
        if(OverlayFinals[i] != None)
        {
            Level.ObjectPool.FreeObject(OverlayFinals[i]);
            OverlayFinals[i] = None;
        }
    }
}

defaultproperties
{
}
