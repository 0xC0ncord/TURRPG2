class TitanPawn extends xPawn;

var() bool bCanMultiCombo;
var array<Combo> ActiveCombos;

function bool InCurrentCombo()
{
    return (CurrentCombo != None || ActiveCombos.Length > 0);
}

function Combo GetActiveCombo(class<Combo> ComboClass)
{
    local int i;

    for(i = 0; i < ActiveCombos.Length; i++)
    {
        if(ActiveCombos[i].Class == ComboClass)
            return ActiveCombos[i];
    }
    return None;
}

function bool CanNewCombo(class<Combo> ComboClass)
{
    local int i;

    if(!bCanMultiCombo)
        return false;
    for(i = 0; i < ActiveCombos.Length; i++)
    {
        if(ActiveCombos[i].Class == ComboClass)
            return false;
    }
    return true;
}

function bool CancelCombo(class<Combo> ComboClass)
{
    local int i;

    for(i = 0; i < ActiveCombos.Length; i++)
    {
        if(ActiveCombos[i].Class == ComboClass)
        {
            //removing from ActiveCombos is handled in RPGCombo::Destroyed
            ActiveCombos[i].Destroy();
            return true;
        }
    }
    return false;
}

function DoCombo( class<Combo> ComboClass )
{
    local int i;

    if ( ComboClass != None )
    {
        if (CurrentCombo == None || bCanMultiCombo)
        {
            CurrentCombo = Spawn(ComboClass, self);
            ActiveCombos[ActiveCombos.Length] = CurrentCombo;

            // Record stats for using the combo
            UnrealMPGameInfo(Level.Game).SpecialEvent(PlayerReplicationInfo, string(CurrentCombo.Class));
            if (ClassIsChildOf(ComboClass, class'ComboSpeed'))
                i = 0;
            else if (ClassIsChildOf(ComboClass, class'ComboBerserk'))
                i = 1;
            else if (ClassIsChildOf(ComboClass, class'ComboDefensive'))
                i = 2;
            else if (ClassIsChildOf(ComboClass, class'ComboInvis'))
                i = 3;
            else
                i = 4;
            TeamPlayerReplicationInfo(PlayerReplicationInfo).Combos[i] += 1;
        }
    }
}

defaultproperties
{
}
