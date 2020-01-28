class RPGSentinelPlayerReplicationInfo extends PlayerReplicationInfo;

var bool bNoTeamBeacon, bOldNoTeamBeacon;

replication
{
    reliable if(Role == Role_Authority)
        bNoTeamBeacon;
}

simulated function PostNetReceive()
{
    local Pawn P;

    Super.PostNetReceive();

    if(Role < Role_Authority && bNoTeamBeacon != bOldNoTeamBeacon)
    {
        bOldNoTeamBeacon = bNoTeamBeacon;
        foreach DynamicActors(class'Pawn', P)
        {
            if(P.PlayerReplicationInfo == P && !P.bNoTeamBeacon)
            {
                P.bNoTeamBeacon = true;
                break;
            }
        }
    }
}

defaultproperties
{
    bIsSpectator=True
    bBot=True
    bWelcomed=True
}
