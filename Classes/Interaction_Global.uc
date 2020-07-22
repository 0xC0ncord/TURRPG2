//=============================================================================
// Interaction_Global.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

/*
    An Interaction for anybody joining the server, even Spectators
*/
class Interaction_Global extends RPGBaseInteraction;

var array<FriendlyPawnReplicationInfo> FriendlyPawns;

function PostRender(Canvas C) {
    local int i;
    local float Dist, Height, Pct;
    local vector ScreenPos;
    local FriendlyPawnReplicationInfo FPRI;
    local Color BarColor;
    local string Text;
#ifdef __DEBUG__
    local float XT, YT;
#endif

    for(i = 0; i < FriendlyPawns.Length; i++) {
        FPRI = FriendlyPawns[i];

        if(FPRI.Pawn != None && IsPawnVisible(C, FPRI.Pawn, ScreenPos, Dist)) {
            if(Dist < 0.0f || Dist > TeamBeaconMaxDist) {
                continue;
            }

            //Draw height
            Height = FPRI.Pawn.CollisionHeight * FClamp(0.85f + Dist * (0.85f / TeamBeaconPlayerInfoMaxDist), 0.85f, 1.75f);

            //Actual beacon position
            ScreenPos = C.WorldToScreen(FPRI.Pawn.Location + Height * vect(0, 0, 1));
            ScreenPos.X -= 0.5f * TeamBeacon.USize * 0.2f;
            ScreenPos.Y -= 0.5f * TeamBeacon.VSize * 0.2f;

            //Player name
            if(Dist < TeamBeaconPlayerInfoMaxDist && C.ClipX > 600) {
                Text = FPRI.Master.PlayerName;
            }

            //Draw beacon
            DrawTeamBeacon(C, ScreenPos.X, ScreenPos.Y, GetTeamBeaconColor(FPRI.Master), 0.2f, Text);

            //Health bar
            if(
                Dist < TeamBeaconMaxDist &&
                ViewportOwner.Actor.PlayerReplicationInfo != None &&
                FPRI.Master.Team == ViewportOwner.Actor.PlayerReplicationInfo.Team
            )
            {
                Height = SmallFontHeight * FClamp(1 - Dist / (TeamBeaconPlayerInfoMaxDist * 0.5), 0.5, 1);
                Pct = float(FPRI.Pawn.Health) / FPRI.Pawn.HealthMax;

                if(Pct > 0.5) {
                    BarColor.R = byte(255.0 * FClamp(1.0 - (FPRI.Pawn.HealthMax - (FPRI.Pawn.HealthMax - FPRI.Pawn.Health) * 2) / FPRI.Pawn.HealthMax, 0, 1));
                    BarColor.G = 255;
                    BarColor.B = 0;
                } else {
                    BarColor.R = 255;
                    BarColor.G = byte(255.0 * FClamp(2.0 * FPRI.Pawn.Health / FPRI.Pawn.HealthMax, 0, 1));
                    BarColor.B = 0;
                }

                BarColor.A = 255;
                DrawBar(C,
                    ScreenPos.X,
                    ScreenPos.Y - SmallFontHeight - 4 - Height,
                    BarColor, Pct, 5 * Height, Height);
            }
        }
    }

#ifdef __DEBUG__
    Text = "TURRPG2 / DEBUG / " $ class'MutTURRPG'.default.TURRPG2Version $ " / " $ class'MutTURRPG'.default.BuildDate;
    if(HudBase(ViewportOwner.Actor.MyHud) != None)
        C.Font = HudBase(ViewportOwner.Actor.MyHud).LoadInstructionFont();
    else
        C.Font = C.default.Font;
    C.TextSize(Text, XT, YT);
    C.SetPos(C.ClipX * 0.5 - XT * 0.5, 0);
    C.DrawColor = C.MakeColor(255, 0, 0);
    C.DrawText(Text);
#endif

    //Reset canvas properties
    C.Font = C.default.Font;
    C.Style = C.default.Style;
    C.DrawColor = C.default.DrawColor;
}

event NotifyLevelChange() {
    Super.NotifyLevelChange();
    FriendlyPawns.Length = 0;
}

function AddFriendlyPawn(FriendlyPawnReplicationInfo FPRI) {
    FriendlyPawns[FriendlyPawns.Length] = FPRI;
}

function bool IsFriendlyPawn(Pawn P) {
    local int i;

    for(i = 0; i < FriendlyPawns.Length; i++) {
        if(FriendlyPawns[i].Pawn == P) {
            return true;
        }
    }
    return false;
}

function RemoveFriendlyPawn(FriendlyPawnReplicationInfo FPRI) {
    local int i;

    for(i = 0; i < FriendlyPawns.Length; i++) {
        if(FriendlyPawns[i] == FPRI) {
            FriendlyPawns.Remove(i, 1);
            break;
        }
    }
}

defaultproperties {
    bVisible=True
}
