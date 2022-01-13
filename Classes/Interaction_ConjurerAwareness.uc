//=============================================================================
// Interaction_ConjurerAwareness.uc
// Copyright (C) 2022 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class Interaction_ConjurerAwareness extends RPGBaseInteraction;

var Interaction_Global GlobalInteraction;

event Initialized()
{
    local int i;

    Super.Initialized();

    for(i = 0; i < ViewportOwner.LocalInteractions.Length; i++)
    {
        if(Interaction_Global(ViewportOwner.LocalInteractions[i]) != None)
        {
            GlobalInteraction = Interaction_Global(ViewportOwner.LocalInteractions[i]);
            break;
        }
    }
}

function PostRender(Canvas C)
{
    local int i;
    local float FarAwayInv, Dist, ScaledDist, Scale, Height, Pct;
    local vector ScreenPos;
    local Pawn P;
    local Color BarColor;
    local xPlayer xPC;

    if(ViewportOwner.Actor.Pawn == None || ViewportOwner.Actor.Pawn.Health <= 0)
        return;

    xPC = xPlayer(ViewportOwner.Actor);

    FarAwayInv = 1.0f / TeamBeaconPlayerInfoMaxDist;

    for(i = 0; i < GlobalInteraction.FriendlyPawns.Length; i++)
    {
        if(
            GlobalInteraction.FriendlyPawns[i].Master == ViewportOwner.Actor.PlayerReplicationInfo
            && IsPawnVisible(C, P, ScreenPos, Dist)
        )
        {
            P = GlobalInteraction.FriendlyPawns[i].Pawn;

            ScaledDist = TeamBeaconPlayerInfoMaxDist * FClamp(0.04f * P.CollisionRadius, 1.0f, 2.0f);

            if(Dist < 0.0f || Dist > 2.0f * ScaledDist)
                continue;

            if(Dist > ScaledDist)
            {
                ScreenPos.Z = 0;
                if(VSize(ScreenPos) * VSize(ScreenPos) > 0.02f * Dist * Dist)
                    continue;
            }

            //Beacon scale
            Scale = FClamp(0.28f * (ScaledDist - Dist) / ScaledDist, 0.1f, 0.25f);

            //Draw height
            Height = P.CollisionHeight * FClamp(0.85f + Dist * 0.85f * FarAwayInv, 1.1f, 1.75f);

            //Offset, including the team beacon and text!
            ScreenPos = C.WorldToScreen(P.Location + Height * vect(0, 0, 1));

            ScreenPos.X -= 0.5f * TeamBeacon.USize * Scale;
            ScreenPos.Y -= 0.5f * TeamBeacon.VSize * Scale;

            //Text
            if(Dist < TeamBeaconPlayerInfoMaxDist && C.ClipX > 600)
                ScreenPos.Y -= SmallFontHeight;

            //Bar height
            Height = SmallFontHeight * FClamp(1 - Dist / (TeamBeaconPlayerInfoMaxDist * 0.5), 0.5, 1);

            BarColor.A = 255;

            //Health bar
            ScreenPos.Y -= (Height * RPGInteraction.Settings.BarHeightScale) + 4;
            Pct = FClamp(float(P.Health) / P.HealthMax, 0f, 1f);

            if(P.Health >= P.HealthMax)
                BarColor = class'HUD'.default.BlueColor;
            else
            {
                if(P.Health < P.HealthMax * 0.33)
                    BarColor = class'HUD'.default.RedColor;
                else if(P.Health < P.HealthMax)
                    BarColor = class'Util'.static.InterpolateColor(class'HUD'.default.RedColor, class'HUD'.default.GreenColor, (P.Health - P.HealthMax * 0.33) / P.HealthMax);
                else
                    BarColor = class'Util'.static.InterpolateColor(class'HUD'.default.GreenColor, class'HUD'.default.CyanColor, (P.Health - P.HealthMax) / P.HealthMax);
            }

            switch(RPGInteraction.Settings.HealthBarStyle)
            {
                case 1:
                    DrawCenterStyleBar(C, ScreenPos.X, ScreenPos.Y, BarColor, Pct, 10 * Height * RPGInteraction.Settings.BarWidthScale, Height * RPGInteraction.Settings.BarHeightScale, true);
                    break;
                case 0:
                default:
                    DrawBar(C, ScreenPos.X, ScreenPos.Y, BarColor, Pct, 10 * Height * RPGInteraction.Settings.BarWidthScale, Height * RPGInteraction.Settings.BarHeightScale, true);
                    break;
            }
        }
    }
}

defaultproperties
{
    bVisible=True
}
