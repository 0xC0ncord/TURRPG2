class ArtifactBase_EffectSphere extends RPGArtifact;

var class<RPGEffect> EffectClass;
var array<Pawn> Pawns;
var float Radius;
var vector CoreLocation;

var float EstimatedRunTime;

var class<Emitter> EmitterClass;

var float TimerInterval;

var float NextEffectTime;

state Activated
{
    function BeginState()
    {
        Super.BeginState();
        CoreLocation = Instigator.Location;
        Spawn(EmitterClass, self,, CoreLocation);
        CreateEffects();
        SetTimer(TimerInterval, true);
        NextEffectTime = Level.TimeSeconds + 0.45;
    }

    function EndState()
    {
        Super.EndState();
        SetTimer(0, false);
        RemoveAllEffects();
    }

    function Timer()
    {
        local int i;

        CreateEffects();

        if(class<RPGInstantEffect>(EffectClass) != None)
            return;

        for(i = 0; i < Pawns.Length; i++)
        {
            if(Pawns[i] == None || Pawns[i].Health <= 0 || VSize(Pawns[i].Location - CoreLocation) > Radius)
            {
                if(Pawns[i] != None)
                    RemoveEffect(Pawns[i]);
                Pawns.Remove(i, 1);
                i--;
            }
        }
    }

    function Tick(float dt)
    {
        Super.Tick(dt);
        if(NextEffectTime <= Level.TimeSeconds)
        {
            NextEffectTime = Level.TimeSeconds + 0.45;
            Spawn(EmitterClass, self,, CoreLocation);
        }
    }
}

function bool CanApplyEffectOn(Pawn Other)
{
    if(EffectClass != None)
        return EffectClass.static.CanBeApplied(Other, Instigator.Controller);
    return false;
}

function CreateEffects()
{
    local RPGEffect Effect;
    local Controller C, NextC;

    EstimatedRunTime = 4 * Instigator.Controller.Adrenaline * AdrenalineUsage / CostPerSec;

    if(EffectClass == None)
        return;

    C = Level.ControllerList;
    while(C != None)
    {
        NextC = C.NextController;
        if(C.Pawn != None && VSize(C.Pawn.Location - CoreLocation) <= Radius)
        {
            if(CanApplyEffectOn(C.Pawn))
            {
                if(class<RPGInstantEffect>(EffectClass) == None && class'Util'.static.InArray(C.Pawn, Pawns) != -1)
                {
                    C = NextC;
                    continue;
                }
                else
                    Pawns[Pawns.Length] = C.Pawn;

                Effect = EffectClass.static.Create(C.Pawn, Instigator.Controller, EstimatedRunTime, EstimatedRunTime);
                if(Effect != None)
                {
                    ModifyEffect(Effect);
                    Effect.Start();
                }
            }
        }
        C = NextC;
    }
}

function RemoveAllEffects()
{
    local int i;

    for(i = 0; i < Pawns.Length; i++)
        RemoveEffect(Pawns[i]);

    Pawns.Length = 0;
}

function RemoveEffect(Pawn Other)
{
    local RPGEffect Effect;

    Effect = EffectClass.static.GetFor(Other);

    EffectRemoved(Other, Effect);

    if(Effect != None)
        Effect.Destroy();
}

function EffectRemoved(Pawn Other, RPGEffect Effect);
function ModifyEffect(RPGEffect Effect);

defaultproperties
{
    TimerInterval=0.100000
    MinActivationTime=0.100000
    AdrenalineUsage=1.000000
    Radius=900.000000
}
