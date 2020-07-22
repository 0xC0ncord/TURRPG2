//=============================================================================
// RPGFieldGenerator_Matrix.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGFieldGenerator_Matrix extends RPGFieldGenerator
    cacheexempt
    config(TURRPG2);

var() config array<name> Ignore;
var RPGMatrixField Field;

simulated function ModifyEffect(FX_Field FX)
{
    local Color C;

    C.G = 255;
    FX.Emitters[0].ColorScale[0].Color = C;
    FX.Emitters[0].ColorScale[1].Color = C;
    FX.Emitters[1].ColorScale[0].Color = C;
    FX.Emitters[1].ColorScale[1].Color = C;
    FX.Emitters[2].ColorScale[0].Color = C;
    FX.Emitters[2].ColorScale[1].Color = C;
    FX.Emitters[3].ColorScale[0].Color = C;
    FX.Emitters[3].ColorScale[1].Color = C;
}

function SpawnEffects()
{
    Super.SpawnEffects();
    Field = Spawn(class'RPGMatrixField', RPGFieldGeneratorController(Controller).PlayerSpawner,, Location + vect(0,0,128));
    Field.SetBase(Instigator);
    Field.Radius = ScanRange;
    Field.Multiplier = 0.2;
    Field.Ignore = Ignore;
}

simulated function Destroyed()
{
    Super.Destroyed();
    if(Field != None)
        Field.Destroy();
}

defaultproperties
{
    VehicleNameString="Matrix Field Generator"
}
