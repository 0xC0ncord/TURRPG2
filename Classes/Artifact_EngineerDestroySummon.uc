class Artifact_EngineerDestroySummon extends RPGArtifact;

const NUM_CHOICES = 5;

var int DestroyChoice;

var localized string SelectionTitle;

var localized string OptionsText[NUM_CHOICES];

const MSG_Buildings = 0x0000;
const MSG_Sentinels = 0x0100;
const MSG_Turrets = 0x0200;
const MSG_Vehicles = 0x0300;
const MSG_Utilities = 0x0400;
var localized string
    Msg_Text_Buildings,
    Msg_Text_Sentinels,
    Msg_Text_Turrets,
    Msg_Text_Vehicles,
    Msg_Text_Utilities;

static function string GetMessageString(int Msg, optional int Value, optional Object Obj)
{
    switch(Msg)
    {
        case MSG_Buildings:
            return default.Msg_Text_Buildings;
        case MSG_Sentinels:
            return default.Msg_Text_Sentinels;
        case MSG_Turrets:
            return default.Msg_Text_Turrets;
        case MSG_Vehicles:
            return default.Msg_Text_Vehicles;
        case MSG_Utilities:
            return default.Msg_Text_Utilities;
        default:
            return Super.GetMessageString(Msg, Value, Obj);
    }
}

simulated function string GetSelectionTitle()
{
    return SelectionTitle;
}

simulated function int GetNumOptions()
{
    return NUM_CHOICES;
}

simulated function string GetOption(int i)
{
    if(i < NUM_CHOICES)
        return OptionsText[i];
    return "";
}

simulated function int GetOptionCost(int i)
{
    return 0;
}

function OnSelection(int i)
{
    DestroyChoice = i;
}

function bool DoEffect()
{
    switch(DestroyChoice)
    {
        case 0:
            MSG(MSG_Buildings);
            InstigatorRPRI.ServerDestroyBuildings();
            break;
        case 1:
            MSG(MSG_Sentinels);
            InstigatorRPRI.ServerDestroySentinels();
            break;
        case 2:
            MSG(MSG_Turrets);
            InstigatorRPRI.ServerDestroyTurrets();
            break;
        case 3:
            MSG(MSG_Vehicles);
            InstigatorRPRI.ServerDestroyVehicles();
            break;
        case 4:
            MSG(MSG_Utilities);
            InstigatorRPRI.ServerDestroyUtilities();
            break;
        default:
            break;
    }
    return true;
}

exec function DestroyConstructions(string Chosen)
{
    local int i;
    local string tmp;

    tmp = Repl(Chosen, "_", " ");
    if(tmp ~= "BUILDINGS")
        i = 0;
    else if(tmp ~= "SENTINELS")
        i = 1;
    else if(tmp ~= "TURRETS")
        i = 2;
    else if(tmp ~= "VEHICLES")
        i = 3;
    else if(tmp ~= "UTILITIES")
        i = 4;
    SelectedOption = i;
    DestroyChoice = i;
    Activate();
}

defaultproperties
{
    Msg_Text_Buildings="Destroyed all summoned buildings."
    Msg_Text_Sentinels="Destroyed all summoned sentinels."
    Msg_Text_Turrets="Destroyed all summoned turrets."
    Msg_Text_Vehicles="Destroyed all summoned vehicles."
    Msg_Text_Utilities="Destroyed all summoned utilities."
    OptionsText(0)="Buildings"
    OptionsText(1)="Sentinels"
    OptionsText(2)="Turrets"
    OptionsText(3)="Vehicles"
    OptionsText(4)="Utilities"
    IconMaterial=Texture'DestroyConstructionIcon'
    ItemName="Destroy Constructions"
    bCanBeTossed=False
    bSelection=True
    MinAdrenaline=0
    CostPerSec=0
    SelectionTitle="Pick a group to destroy:"
    ArtifactID="DestroyConstructions"
    Description="Destroys all of a group of constructions of your choice."
}
