class FX_VorpalExplosion extends RocketExplosion;

simulated function PostBeginPlay()
{
    local PlayerController PC;

    PC = Level.GetLocalPlayerController();
    if(PC == None || PC.ViewTarget == None || VSize(PC.ViewTarget.Location - Location) > 5000 )
    {
        LightType = LT_None;
        bDynamicLight = false;
    }
    else
    {
        Spawn(class'RocketSmokeRing');
        if(Level.bDropDetail)
            LightRadius = 7;
    }
}

defaultproperties
{
    RemoteRole=ROLE_DumbProxy
    bNetTemporary=True
}
