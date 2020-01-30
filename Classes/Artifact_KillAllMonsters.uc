class Artifact_KillAllMonsters extends RPGArtifact
    config(TURRPG2);

var int DestroyChoice;

var localized string SelectionTitle;

const MSG_Success = 0x0010;
var localized string Msg_Text_Success;

static function string GetMessageString(int Msg, optional int Value, optional Object Obj)
{
    switch(Msg)
    {
        case MSG_Success:
            return default.Msg_Text_Success;
        default:
            return Super.GetMessageString(Msg, Value, Obj);
    }
}

function bool DoEffect()
{
    InstigatorRPRI.ServerKillMonsters();
    MSG(MSG_Success);
    return true;
}

defaultproperties
{
    Msg_Text_Success="Destroyed all summoned monsters."
    IconMaterial=Texture'TURRPG2.ArtifactIcons.KillAllMonstersIcon'
    ItemName="Kill All Summoned Monsters"
    bCanBeTossed=False
    MinAdrenaline=0
    CostPerSec=0
    Cooldown=10.000000
    ArtifactID="KillAllMonsters"
    Description="Kills all your summoned monsters."
}
