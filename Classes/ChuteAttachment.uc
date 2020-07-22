//=============================================================================
// ChuteAttachment.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class ChuteAttachment extends InventoryAttachment;

defaultproperties
{
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'TURRPG2.Chute.chutemesh'
    AttachmentBone="spine"
    DrawScale=2.000000
}
