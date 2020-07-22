//=============================================================================
// RPGBlockSingleRow.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGBlockSingleRow extends RPGMultiBlock;

defaultproperties
{
     NumBlocks=3
     Blocks(0)=(BlockType=Class'RPGBlock',XOffset=-120,ZOffset=20)
     Blocks(1)=(BlockType=Class'RPGBlock',ZOffset=20)
     Blocks(2)=(BlockType=Class'RPGBlock',XOffset=120,ZOffset=20)
}
