class Artifact_ChainLightning extends ArtifactBase_Beam;

var float MaxStepRange;
var int AdrenalineForHit;
var int FirstDamage;
var float StepDamageFraction;
var int MaxSteps;

var array<Pawn> ChainHitPawn;
var array<int> ChainStepNumber;
var array<vector> ChainHitLocation;
var array<int> ChainActive;

function ChainPawn(Pawn Victim, vector HitLocation, vector StartLocation, int StepNumber)
{
    local Actor A;
    local int DamageToDo;
    local int UDamageAdjust;
    local xEmitter HitEmitter;
    local int i;
    local float CurPercent;
    local bool bRunningTriple;
    local Artifact_TripleDamage TripleArtifact;

    if (StepNumber > MaxSteps)
        return;

    for (i = 0; i < ChainHitPawn.Length; i++)
        if (ChainHitPawn[i] == Victim)
            return;

    if (StepNumber < MaxSteps)
    {
        ChainHitPawn[ChainHitPawn.Length] = Victim;
        ChainStepNumber[ChainStepNumber.Length] = StepNumber;
        ChainHitLocation[ChainHitLocation.Length] = HitLocation;
        ChainActive[ChainActive.Length] = 1;
    }

    HitEmitter = spawn(HitEmitterClass,,,StartLocation , rotator(HitLocation - StartLocation));
    if (HitEmitter != None)
    {
        HitEmitter.mSpawnVecA = Victim.Location;
    }

    A = spawn(class'BlueSparks',,, Victim.Location);
    if (A != None)
    {
        A.RemoteRole = ROLE_SimulatedProxy;
        A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*Victim.TransientSoundVolume,,Victim.TransientSoundRadius);
    }

    CurPercent = 1.0;
    for (i = 0; i < StepNumber; i++)
        CurPercent *= StepDamageFraction;

    DamageToDo = FirstDamage * CurPercent;

    bRunningTriple = false;
    If (Instigator != None && Instigator.HasUDamage())
    {
        UDamageAdjust = 2;
        TripleArtifact = Artifact_TripleDamage(class'Artifact_TripleDamage'.static.HasArtifact(Instigator));
        if(TripleArtifact != None && TripleArtifact.bActive)
        {
            bRunningTriple = true;
            DamageToDo = DamageToDo / UDamageAdjust;
        }
    }
    else
        UDamageAdjust = 1;

    Victim.TakeDamage(DamageToDo, Instigator, Victim.Location, vect(0,0,0), MyDamageType);
}

function Pawn FindTarget()
{
    local Pawn Target;

    Target = Super.FindTarget();

    if(Target != None)
    {
        ChainHitPawn.Length = 0;
        ChainStepNumber.Length = 0;
        ChainHitLocation.Length = 0;
        ChainActive.Length = 0;
    }
    return Target;
}

function HitTarget(Pawn Other)
{
    local Actor A;

    InstigatorRPRI.DrainAdrenaline(AdrenalineForHit * AdrenalineUsage,Self);

    Cooldown = default.Cooldown * AdrenalineUsage;
    DoCooldown();

    A = spawn(class'BlueSparks',,, Instigator.Location);
    if (A != None)
    {
        A.RemoteRole = ROLE_SimulatedProxy;
        A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*Instigator.TransientSoundVolume,,Instigator.TransientSoundRadius);
    }

    ChainPawn(Other, Other.Location, (Instigator.Location + Instigator.EyePosition()), 0);
    SetTimer(0.2, true);
}

function Timer()
{
    local Controller C, NextC;
    local vector Ploc;
    local int i, j, besti;
    local bool bGotLive;
    local int minStepNo;
    local float CurPercent;
    local int NumActiveChainEntries;

    if (Instigator == None || Instigator.Controller == None || ChainHitPawn.Length == 0)
    {
        ChainHitPawn.Length = 0;
        ChainStepNumber.Length = 0;
        ChainHitLocation.Length = 0;
        ChainActive.Length = 0;
        SetTimer(0, false);
        return;
    }

    bGotLive = false;
    for (i = 0; i < ChainActive.Length; i++)
        if (ChainActive[i] > 0)
            bGotLive = true;
    if (!bGotLive)
    {
        ChainHitPawn.Length = 0;
        ChainStepNumber.Length = 0;
        ChainHitLocation.Length = 0;
        ChainActive.Length = 0;
        SetTimer(0, false);
        return;
    }

    for (i = 0; i < ChainStepNumber.Length; i++)
        ChainStepNumber[i]++;
    NumActiveChainEntries = ChainStepNumber.Length;

    C = Level.ControllerList;
    while (C != None)
    {
        NextC = C.NextController;
        if(CanAffectTarget(C.Pawn))
        {
            bGotLive = false;
            for (i = 0; i < ChainHitPawn.Length; i++)
                if (ChainHitPawn[i] == C.Pawn)
                    bGotLive = true;

            if (!bGotLive)
            {
                minStepNo = MaxSteps + 1;
                besti = -1;
                for (i = 0; i < ChainHitPawn.Length; i++)
                {
                    if (ChainHitPawn[i] == None)
                        Ploc = ChainHitLocation[i];
                    else
                        Ploc = ChainHitPawn[i].Location;
                    if (ChainStepNumber[i] <= MaxSteps && FastTrace(C.Pawn.Location, Ploc))
                    {
                        CurPercent = 1.0;
                        for (j = 1; j < ChainStepNumber[i]; j++)
                            CurPercent *= StepDamageFraction;
                        if (VSize(C.Pawn.Location - Ploc) < (MaxStepRange * CurPercent) && minStepNo > ChainStepNumber[i])
                        {
                            minStepNo = ChainStepNumber[i];
                            besti = i;
                        }
                    }
                }
                if (besti >= 0)
                {
                    if (ChainHitPawn[besti] == None)
                        Ploc = ChainHitLocation[besti];
                    else
                        Ploc = ChainHitPawn[besti].Location;
                    ChainPawn(C.Pawn, C.Pawn.Location, Ploc, minStepNo);
                }

            }
        }
        C = NextC;
    }
    for (i = 0; i < NumActiveChainEntries; i++)
        ChainActive[i] = 0;
}

defaultproperties
{
    HitEmitterClass=Class'FX_Bolt_Red'
    MyDamageType=Class'DamTypeChainLightning'
    MaxRange=3000.000000
    MaxStepRange=650.000000
    AdrenalineForMiss=4
    AdrenalineForHit=50
    FirstDamage=180
    StepDamageFraction=0.700000
    MaxSteps=3
    Cooldown=2.000000
    CostPerSec=1
    IconMaterial=Texture'ChainLightningIcon'
    ItemName="Chain Lightning"
    ArtifactID="Chain"
    Description="Fires a bolt of lightning that branches between enemies."
    HudColor=(R=255,G=128,B=64)
}
