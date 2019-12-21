class RPGCombo extends Combo;

function CreateEffects(Pawn P);
function DestroyEffects(Pawn P);

function Destroyed()
{
    local xPawn P;
    local int i;

    P = xPawn(Owner);

    if (P != None)
    {
        StopEffect(P);

        if(TitanPawn(Owner) != None)
        {
            i = class'Util'.static.InArray(Self, TitanPawn(Owner).ActiveCombos);
            TitanPawn(Owner).ActiveCombos.Remove(i, 1);
            if(P.CurrentCombo == self)
            {
                if(TitanPawn(Owner).ActiveCombos.Length > 0)
                    P.CurrentCombo = TitanPawn(Owner).ActiveCombos[TitanPawn(Owner).ActiveCombos.Length - 1];
                else
                    P.CurrentCombo = None;
            }
        }
        else if (P.CurrentCombo == self)
            P.CurrentCombo = None;
    }
}

function StartEffect(xPawn P)
{
	CreateEffects(P);
}

function StopEffect(xPawn P)
{
	DestroyEffects(P);
}

defaultproperties
{
}
