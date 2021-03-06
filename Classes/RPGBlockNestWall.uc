//=============================================================================
// RPGBlockNestWall.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGBlockNestWall extends RPGMultiBlock;

defaultproperties
{
     NumBlocks=8
     Blocks(0)=(BlockType=Class'RPGBlock',XOffset=125,ZOffset=20,Angle=1)
     Blocks(1)=(BlockType=Class'RPGBlock',XOffset=65,YOffset=120,ZOffset=20,Angle=3)
     Blocks(2)=(BlockType=Class'RPGBlock',XOffset=-65,YOffset=120,ZOffset=20,Angle=3)
     Blocks(3)=(BlockType=Class'RPGBlock',XOffset=-125,ZOffset=20,Angle=1)
     Blocks(4)=(BlockType=Class'RPGBlock',XOffset=125,ZOffset=100,Angle=1)
     Blocks(5)=(BlockType=Class'RPGBlock',XOffset=65,YOffset=120,ZOffset=100,Angle=3)
     Blocks(6)=(BlockType=Class'RPGBlock',XOffset=-65,YOffset=120,ZOffset=100,Angle=3)
     Blocks(7)=(BlockType=Class'RPGBlock',XOffset=-125,ZOffset=100,Angle=1)
}
