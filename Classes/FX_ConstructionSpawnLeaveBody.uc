class FX_ConstructionSpawnLeaveBody extends BodyEffect;

function PostBeginPlay()
{
    local ColorModifier Alpha;
    local float frame, rate;
    local name seq;
    local int i;

    Super(Effects).PostBeginPlay();
    if(Owner.DrawType == DT_Mesh)
    {
        LinkMesh(Owner.Mesh);
        Owner.GetAnimParams( 0, seq, frame, rate );
        PlayAnim(seq, 0, 0);
        SetAnimFrame(frame);
        StopAnimating();
    }
    else if(Owner.DrawType == DT_StaticMesh)
    {
        SetDrawType(DT_StaticMesh);
        SetStaticMesh(Owner.StaticMesh);
    }
    SetDrawScale3D(Owner.DrawScale3D);
    SetDrawScale(Owner.DrawScale);
    PrePivot = Owner.PrePivot;
    Alpha = ColorModifier(Level.ObjectPool.AllocateObject(class'ColorModifier'));
    Alpha.Material = Skins[0];
    Alpha.AlphaBlend = true;
    Alpha.RenderTwoSided = true;
    Alpha.Color.A = 255;

    if(Owner.Skins.Length > Skins.Length)
        Skins.Length = Owner.Skins.Length;
    for(i = 0; i < Skins.Length; i++)
        Skins[i] = Alpha;
}

simulated function Tick(float DeltaTime)
{
    SetDrawScale(DrawScale * (1 + 0.5 * DeltaTime));
    ColorModifier(Skins[0]).Color.A = int(255.f * (LifeSpan / default.LifeSpan));
}

simulated function Destroyed()
{
    local int i;

    Level.ObjectPool.FreeObject(Skins[0]);
    for(i = 0; i < Skins.Length; i++)
        Skins[i] = None;
    Super(Effects).Destroyed();
}

defaultproperties
{
     LifeSpan=1.000000
     Skins(0)=FinalBlend'ConstructionSpawnFinal'
     Skins(1)=FinalBlend'ConstructionSpawnFinal'
     Skins(2)=FinalBlend'ConstructionSpawnFinal'
     Skins(3)=FinalBlend'ConstructionSpawnFinal'
     Skins(4)=FinalBlend'ConstructionSpawnFinal'
     Skins(5)=FinalBlend'ConstructionSpawnFinal'
     Skins(6)=FinalBlend'ConstructionSpawnFinal'
     Skins(7)=FinalBlend'ConstructionSpawnFinal'
     Skins(8)=FinalBlend'ConstructionSpawnFinal'
     Skins(9)=FinalBlend'ConstructionSpawnFinal'
     Skins(10)=FinalBlend'ConstructionSpawnFinal'
     Skins(11)=FinalBlend'ConstructionSpawnFinal'
     Skins(12)=FinalBlend'ConstructionSpawnFinal'
     Skins(13)=FinalBlend'ConstructionSpawnFinal'
     Skins(14)=FinalBlend'ConstructionSpawnFinal'
     Skins(15)=FinalBlend'ConstructionSpawnFinal'
}
