//=============================================================================
// RPGBlockCurveWall.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGBlockCurveWall extends RPGMultiBlock;

defaultproperties
{
     NumBlocks=9
     Blocks(0)=(BlockType=Class'RPGBlock',XOffset=174,ZOffset=20,Angle=3)
     Blocks(1)=(BlockType=Class'RPGBlock',XOffset=125,YOffset=125,ZOffset=20,Angle=3)
     Blocks(2)=(BlockType=Class'RPGBlock',YOffset=174,ZOffset=20,Angle=3)
     Blocks(3)=(BlockType=Class'RPGBlock',XOffset=-125,YOffset=125,ZOffset=20,Angle=3)
     Blocks(4)=(BlockType=Class'RPGBlock',XOffset=-174,ZOffset=20,Angle=3)
     Blocks(5)=(BlockType=Class'RPGBlock',XOffset=174,ZOffset=100,Angle=3)
     Blocks(6)=(BlockType=Class'RPGBlock',XOffset=85,YOffset=143,ZOffset=100,Angle=3)
     Blocks(7)=(BlockType=Class'RPGBlock',XOffset=-85,YOffset=143,ZOffset=100,Angle=3)
     Blocks(8)=(BlockType=Class'RPGBlock',XOffset=-174,ZOffset=100,Angle=3)
}
