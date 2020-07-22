//=============================================================================
// RPGBlockHighWall.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGBlockHighWall extends RPGMultiBlock;

defaultproperties
{
     NumBlocks=7
     Blocks(0)=(BlockType=Class'RPGBlock',XOffset=-120,ZOffset=20)
     Blocks(1)=(BlockType=Class'RPGBlock',ZOffset=20)
     Blocks(2)=(BlockType=Class'RPGBlock',XOffset=120,ZOffset=20)
     Blocks(3)=(BlockType=Class'RPGBlock',XOffset=-120,ZOffset=100)
     Blocks(4)=(BlockType=Class'RPGBlock',XOffset=120,ZOffset=100)
     Blocks(5)=(BlockType=Class'RPGBlock',XOffset=-60,ZOffset=180)
     Blocks(6)=(BlockType=Class'RPGBlock',XOffset=60,ZOffset=180)
}
