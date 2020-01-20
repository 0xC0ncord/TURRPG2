class Effect_Knockback extends RPGEffect;

var vector Momentum;
var class<DamageType> DamageType;

var EPhysics OriginalPhysics;

static function bool CanBeApplied(Pawn Other, optional Controller Causer, optional float Duration, optional float Modifier)
{
    //don't knock something that's stuck
    if(class'Effect_NullEntropy'.static.GetFor(Other) != None)
        return false;

    //this causes way too funny bugs on turrets...
    if(ASTurret(Other) != None || ONSStationaryWeaponPawn(Other) != None)
        return false;
    
    //Don't allow if Other is the driver of a vehicle
    if(Other.DrivenVehicle != None)
        return false;

    return Super.CanBeApplied(Other, Causer, Duration, Modifier);
}

state Activated
{
    function BeginState()
    {
        Super.BeginState();
        
        if(
            Instigator.Physics != PHYS_Walking && 
            Instigator.Physics != PHYS_Falling &&
            Instigator.Physics != PHYS_Hovering)
        {
            OriginalPhysics = Instigator.Physics;
            Instigator.SetPhysics(PHYS_Hovering);
        }
        
        if(VSize(Momentum) > 0)
        {
            Instigator.TakeDamage(
                0,
                EffectCauser.Pawn,
                Instigator.Location,
                Momentum * Modifier * Instigator.Mass,
                DamageType);
        }
    }

    event Tick(float dt)
    {
        Super.Tick(dt);
        
        if(!bPendingDelete)
        {
            if(
                !bAllowOnFlagCarriers &&
                Instigator.PlayerReplicationInfo != None &&
                Instigator.PlayerReplicationInfo.HasFlag != None)
            {
                //exploit fix
                Instigator.Velocity = vect(0, 0, 0);
                Destroy();
                return;
            }
        }
    }
    
    function EndState()
    {
        if(Instigator != None && Instigator.Physics != PHYS_Walking && Instigator.Physics != PHYS_Falling)
            Instigator.SetPhysics(OriginalPhysics);
        
        Super.EndState();
    }
}

defaultproperties
{
    bAllowOnFlagCarriers=False
    
    DamageType=class'fell'
    
    Modifier=1.00

    EffectSound=Sound'WeaponSounds.Misc.ballgun_launch'
    EffectOverlay=Shader'TURRPG2.Overlays.RedShader'
    EffectMessageClass=class'EffectMessage_Knockback'
}
