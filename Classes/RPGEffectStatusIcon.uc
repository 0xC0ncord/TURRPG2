class RPGEffectStatusIcon extends RPGStatusIcon;

var RPGEffect Effect;
var class<RPGEffect> EffectClass;
var bool bDevoid;

function bool IsVisible()
{
    return true;
}

function bool IsPersistent()
{
    return false;
}

function Initialize()
{
    if(!bDevoid)
        Effect = default.EffectClass.static.GetFor(RPRI.Controller.Pawn);
}

function string GetText()
{
    if(Effect != None)
    {
        if(Effect.bClientActivated || Effect.IsInState('Activated'))
            return class'Util'.static.FormatTime(Effect.Duration);
    }
    else if(!bDevoid)
    {
        Initialize();
        if(Effect == None)
            RPRI.ClientRemoveStatusIcon(Class);
    }
}

defaultproperties
{
}
