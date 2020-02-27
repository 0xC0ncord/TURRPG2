class Effect_SphereUDamage extends RPGEffect;

var float ExpPerDamage;

var vector SphereLocation;
var float Radius;
var float EstimatedUDamageTime;

function bool ShouldDisplayEffect()
{
    return true;
}

state Activated
{
    function BeginState()
    {
        Super.BeginState();
        Instigator.EnableUDamage(EstimatedUDamageTime);
        SetTimer(0.1,true);
    }

    function Timer()
    {
        if(VSize(SphereLocation - Instigator.Location) > Radius || !class'Artifact_SphereDamage'.static.IsActiveFor(EffectCauser.Pawn))
            Destroy();
    }

    function EndState()
    {
        Super.EndState();

        Instigator.DisableUDamage();
        if(EffectOverlay != None)
            class'Sync_OverlayMaterial'.static.Sync(Instigator, None, 0, true);

        //Fix the annoying UDamage running out sounds
        if(xPawn(Instigator) != None && xPawn(Instigator).UDamageTimer != None)
            xPawn(Instigator).UDamageTimer.Destroy();
    }
}

function Destroyed()
{
    Super.Destroyed();
    Instigator.DisableUDamage();
    if(EffectOverlay != None)
        class'Sync_OverlayMaterial'.static.Sync(Instigator, None, 0, true);

    //Fix the annoying UDamage running out sounds
    if(xPawn(Instigator) != None && xPawn(Instigator).UDamageTimer != None)
        xPawn(Instigator).UDamageTimer.Destroy();
}

defaultproperties
{
    EstimatedUDamageTime=5
    EffectMessageClass=Class'EffectMessage_UDamage'
    EffectOverlay=Shader'XGameShaders.PlayerShaders.WeaponUDamageShader'
    bHarmful=False
    bAllowOnTeammates=True
}
