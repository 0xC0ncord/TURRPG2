class Artifact_KillDesiredMonster extends ArtifactBase_Beam;

const MSG_InvalidTarget = 0x0010;
var localized string Msg_Text_Invalid;

static function string GetMessageString(int Msg, optional int Value, optional Object Obj)
{
    switch(Msg)
    {
        case MSG_InvalidTarget:
            return default.Msg_Text_Invalid;
        default:
            return Super.GetMessageString(Msg,Value,Obj);
    }
}

function bool CanAffectTarget(Pawn Other)
{
    local int i;

    if(Monster(Other) != None && Other.Health > 0)
    {
        for(i = 0; i < InstigatorRPRI.Monsters.Length; i++)
            if(InstigatorRPRI.Monsters[i].Pawn == Other)
                return true;
    }

    MSG(MSG_InvalidTarget);
    return false;
}

function HitTarget(Pawn Other)
{
    SpawnEffects(Other);
    Other.Destroy();
}

defaultproperties
{
    Msg_Text_Invalid="Invalid target."
    bHarmful=False
    bAllowOnEnemies=False
    bAllowOnMonsters=True
    MaxRange=10000.000000
    Cooldown=1.0000000
    DamagePerAdrenaline=0
    AdrenalineForMiss=0
    MinAdrenaline=0
    CostPerSec=0
    IconMaterial=Texture'TURRPG2.ArtifactIcons.KillDesiredMonsterIcon'
    ItemName="Kill Target Summoned Monster"
    ArtifactID="KillTargetMonster"
    Description="Kills target summoned monster."
}
