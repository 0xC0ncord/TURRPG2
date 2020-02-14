class RPGFieldGenerator_Force extends RPGFieldGenerator
    config(TURRPG2)
    cacheexempt;

var() config array<name> Ignore;
var RPGForceField Field;

simulated function ModifyEffect(FX_Field FX)
{
    local Color C;

    C.R = 255;
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
    Field = Spawn(class'RPGForceField', RPGFieldGeneratorController(Controller).PlayerSpawner,, Location + vect(0,0,128));
    Field.SetBase(Instigator);
    Field.Radius = ScanRange;
    Field.Multiplier = 3;
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
    VehicleNameString="Propulsion Field Generator"
}
