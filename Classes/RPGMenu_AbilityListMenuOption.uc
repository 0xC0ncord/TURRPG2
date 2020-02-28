class RPGMenu_AbilityListMenuOption extends GUIMenuOption;

var(Option) noexport editconst GUIButton MyButton;

var() RPGAbility LinkedAbility;
var() int Index;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    MyButton = GUIButton(MyComponent);
    MyButton.OnClick = InternalOnClick;

    FocusInstead = MyButton;
}

function bool InternalOnClick(GUIComponent Sender)
{
    if(Sender == MyButton)
    {
        InternalOnChange(Self);
        return true;
    }
    return false;
}

defaultproperties
{
    ComponentClassName="XInterface.GUIButton"
    CaptionWidth=0.0
    ComponentWidth=1.0
    bStandardized=False
    bBoundToParent=False
    bScaleToParent=False
    bNeverFocus=True
    OnClickSound=CS_None
    bAutoSizeCaption=False
}
