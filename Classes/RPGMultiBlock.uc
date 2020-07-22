//=============================================================================
// RPGMultiBlock.uc
// Copyright (C) 2020 0xC0ncord <concord@fuwafuwatime.moe>
//
// This program is free software; you can redistribute and/or modify
// it under the terms of the Open Unreal Mod License version 1.1.
//=============================================================================

class RPGMultiBlock extends Pawn
    abstract;

var int NumBlocks;

struct BlockConfig
{
    var Class<Pawn> BlockType;
    var int XOffset;
    var int YOffset;
    var int ZOffset;
    var int Angle;      // 0 straight line facing player, 1 right angle to 0, 2 around player, 3 around spawn point
};
var Array<BlockConfig> Blocks;

defaultproperties
{
}
