//=============================================================================
// RPGBlockLowWall.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGBlockLowWall extends RPGMultiBlock;

defaultproperties
{
     NumBlocks=4
     Blocks(0)=(BlockType=Class'RPGSmallBlock',XOffset=-45,ZOffset=20)
     Blocks(1)=(BlockType=Class'RPGSmallBlock',XOffset=-135,ZOffset=20)
     Blocks(2)=(BlockType=Class'RPGSmallBlock',XOffset=45,ZOffset=20)
     Blocks(3)=(BlockType=Class'RPGSmallBlock',XOffset=135,ZOffset=20)
}
