//=============================================================================
// RPGFieldGenerator_Freeze.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGFieldGenerator_Freeze extends RPGFieldGenerator
    cacheexempt;

simulated function ModifyEffect(FX_Field FX)
{
    local Color C;

    C.G = 224;
    C.B = 255;
    FX.Emitters[0].ColorScale[0].Color = C;
    FX.Emitters[0].ColorScale[1].Color = C;
    FX.Emitters[1].ColorScale[0].Color = C;
    FX.Emitters[1].ColorScale[1].Color = C;
    FX.Emitters[2].ColorScale[0].Color = C;
    FX.Emitters[2].ColorScale[1].Color = C;
    FX.Emitters[3].ColorScale[0].Color = C;
    FX.Emitters[3].ColorScale[1].Color = C;
}

function DoScan()
{
    local Controller C,PlayerSpawner;
    local vector V;
    local RPGEffect E;

    V = Location + vect(0,0,128);
    PlayerSpawner = RPGFieldGeneratorController(Controller).PlayerSpawner;
    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(C.Pawn != None && C.Pawn.Health >= 0 && VSize(C.Pawn.Location - V) <= ScanRange && !class'Util'.static.SameTeamC(C, PlayerSpawner))
        {
            E = class'Effect_Freeze'.static.GetFor(C.Pawn);
            if(E != None)
            {
                E.EffectCauser = PlayerSpawner;

                if(0.1 > E.Modifier)
                    E.Modifier = 0.1;

                if(!E.IsInState('Activated'))
                    E.Start();
            }
            else
            {
                E = class'Effect_Freeze'.static.Create(
                    C.Pawn,
                    PlayerSpawner,
                    1,
                    0.1);
                if(E != None)
                    E.Start();
            }
        }
    }
}

defaultproperties
{
    VehicleNameString="Ice Field Generator"
}
