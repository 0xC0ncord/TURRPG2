class Effect_Repulsion extends Effect_Knockback;

defaultproperties
{
    bAllowOnSelf=False
    bAllowOnVehicles=False

    DamageType=class'DamTypeRepulsion'

    EffectSound=None
    EffectOverlay=Shader'TURRPG2.Overlays.PulseRedShader'
    EffectMessageClass=class'EffectMessage_Repulsion'
}
