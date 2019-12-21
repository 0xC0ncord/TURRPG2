class RPGComboInvis extends RPGCombo;

var RPGPlayerReplicationInfo RPRI;

//special handling for effects; if this combo is started,
//destroy the effects from other combos so as to not blow
//the player's cover!
function StartEffect(xPawn P)
{
	local int i;

	P.SetInvisibility(60.0);
	RPRI = class'RPGPlayerReplicationInfo'.static.GetFor(P.Controller);

	if(TitanPawn(P)!=None)
	{
		for(i = 0; i < TitanPawn(P).ActiveCombos.Length; i++)
		{
			if(RPGCombo(TitanPawn(P).ActiveCombos[i]) != None)
				RPGCombo(TitanPawn(P).ActiveCombos[i]).DestroyEffects(P);
		}
	}
}

function StopEffect(xPawn P)
{
	local int i;

    P.SetInvisibility(0.0);
	if(TitanPawn(P) != None)
	{
		for(i = 0; i < TitanPawn(P).ActiveCombos.Length; i++)
		{
			if(RPGCombo(TitanPawn(P).ActiveCombos[i]) != None)
				RPGCombo(TitanPawn(P).ActiveCombos[i]).CreateEffects(P);
		}
	}
}

simulated function Tick(float DeltaTime)
{
    local Pawn P;
    
    P = Pawn(Owner);

    if(P == None || P.Controller == None)
	{
        Destroy();
        return;
    }
    if(P.Controller.PlayerReplicationInfo != None && P.Controller.PlayerReplicationInfo.HasFlag != None)
		DeltaTime *= 2;
	if(RPRI != None)
		RPRI.DrainAdrenaline(AdrenalineCost * DeltaTime / Duration, Self);
	else
		P.Controller.Adrenaline -= AdrenalineCost * DeltaTime / Duration;
    if (P.Controller.Adrenaline <= 0.0)
    {
        P.Controller.Adrenaline = 0.0;
        Destroy();
    }
}

defaultproperties
{
     ExecMessage="Invisible!"
     ComboAnnouncementName="Invisible"
     keys(0)=8
     keys(1)=8
     keys(2)=4
     keys(3)=4
}
