class FX_HuntersMarkSight extends Emitter;

var Pawn PawnOwner;

replication
{
    reliable if(Role == ROLE_Authority && bNetDirty)
        PawnOwner;
}

simulated function PostNetBeginPlay()
{
    if(Level.NetMode == NM_DedicatedServer)
    {
        Disable('Tick');
        return;
    }

    if(PawnOwner != None)
        PawnOwner.AttachToBone(Self, PawnOwner.HeadBone);
}

simulated function Tick(float DeltaTime)
{
    if(PawnOwner == None)
        return;

    Emitters[0].StartLocationOffset = PawnOwner.HeadScale * vect(1, 0, 1) * 4;
    Emitters[1].StartLocationOffset = Emitters[0].StartLocationOffset;
}

simulated function PostNetReceive()
{
    if(PawnOwner == None)
        Kill();
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        ZTest=False
        SpinParticles=True
        UniformSize=True
        ColorMultiplierRange=(Y=(Min=0.600000,Max=0.600000),Z=(Min=0.400000,Max=0.600000))
        FadeOutStartTime=0.250000
        FadeInEndTime=0.250000
        CoordinateSystem=PTCS_Relative
        MaxParticles=24
        StartLocationRange=(Y=(Min=-3.000000,Max=3.000000))
        StartLocationShape=PTLS_All
        SphereRadiusRange=(Max=1.000000)
        UseRotationFrom=PTRS_Offset
        RotationOffset=(Roll=-16384)
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=2.000000,Max=3.000000))
        Texture=Texture'AW-2004Particles.Weapons.PlasmaFlare'
        LifetimeRange=(Min=0.750000,Max=0.750000)
    End Object
    Emitters(0)=SpriteEmitter'FX_HuntersMarkSight.SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        FadeOut=True
        FadeIn=True
        ZTest=False
        UniformSize=True
        ColorMultiplierRange=(Y=(Min=0.600000,Max=0.600000),Z=(Min=0.400000,Max=0.600000))
        FadeOutStartTime=0.100000
        FadeInEndTime=0.100000
        CoordinateSystem=PTCS_Relative
        MaxParticles=4
        StartLocationRange=(Y=(Min=-2.000000,Max=2.000000))
        StartLocationShape=PTLS_All
        SphereRadiusRange=(Max=0.500000)
        UseRotationFrom=PTRS_Offset
        RotationOffset=(Roll=-16384)
        StartSizeRange=(X=(Min=8.000000,Max=12.000000))
        Texture=Texture'EpicParticles.Flares.BurnFlare1'
        LifetimeRange=(Min=0.600000,Max=0.600000)
    End Object
    Emitters(1)=SpriteEmitter'FX_HuntersMarkSight.SpriteEmitter1'

    AutoDestroy=True
    bNoDelete=False
    RemoteRole=ROLE_SimulatedProxy
    bReplicateMovement=False
    bNotOnDedServer=False
    bOwnerNoSee=True
    bNetNotify=True
}
