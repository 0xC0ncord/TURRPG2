class RPGMenu_Abilities extends RPGMenu_TabPage;

const NUM_COLUMNS = 9;

struct GridPosition
{
    var int Row;
    var int Column;
};

enum EAbilityState
{
    AS_None,
    AS_Available,
    AS_Disabled,
    AS_Blocked,
    AS_Purchased,
};

struct AbilityInfo
{
    var RPGAbility LinkedAbility;
    var int Row;
    var int Column;
    var string Name;
    var int Cost;
    var int NextLevel;
    var int RelationshipIndex;
    var EAbilityState State;
    var array<RPGClass.ForbiddenStruct> ForbidsAbilities;
    var array<RPGClass.RequiredStruct> RequiredByAbilities;
    var bool bDisjunctiveRequirements;
};
var array<AbilityInfo> AbilityInfos;

const RFLAG_FORBIDDEN = 1;
const RFLAG_REQUIRED = 2;
const RFLAG_DISJUNCTIVE = 4;

struct AbilityRelationshipStruct
{
    var int FromIndex;
    var array<int> ToIndex;
    var array<byte> Flags;
};
var array<AbilityRelationshipStruct> Relationships;

struct ClassInfo
{
    var class<RPGClass> RPGClass;
    var string Name;
};
var array<ClassInfo> ClassInfos;

var class<RPGClass> CurrentClass;
var int SelectedIndex;
var int LastSelectedClass, LastSelectedAbility;

var bool bInitialized;

var Color DisabledColor;
var Color AvailableColor;
var Color PurchasedColor;
var Color ForbiddenColor;
var Color DisabledForbiddenColor;
var Color BlockedColor;

var Shader IconSelectedShader;
var Material IconSelectionMaterial;

var automated GUISectionBackground sbAbilities, sbDesc;
var automated GUIScrollTextBox lblDesc;
var automated GUILabel lblStats;
var automated GUIMultiOptionListBox lstAbilities;
var automated GUIMultiOptionList Abilities;
var automated GUIButton btBuy;
var automated GUIComboBox cbTree;
var automated GUIImage imgAbilities;

var localized string 
    Text_Buy, Text_BuyX, Text_Level, Text_Stats, Text_CantBuy, Text_Requirements, Text_AlreadyMax, Text_Max, Text_Forbidden, Text_DoNotHaveThisYet,
    Text_PointsAvailable, Text_Intro, Text_Description, Text_NoClassSelected, Text_Cost;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    OnDraw = SetListScaling;
    
    lstAbilities.NumColumns = NUM_COLUMNS;
    lstAbilities.MyScrollbar.WinWidth = 0.015;
    Abilities = lstAbilities.List;
    Abilities.NumColumns = NUM_COLUMNS;
    Abilities.ItemPadding = 0.0;
    Abilities.SelectedStyle = MyController.GetStyle("RPGAbilityListSelected", FontScale);
    Abilities.OnClickSound = CS_None;
    Abilities.OnDraw = DrawAbilityRelationships;
    Abilities.OnDrawItem = DrawAbilityIcon;

    cbTree.Edit.bReadOnly = true;
    cbTree.OnChange = SelectClassTree;
}

final function bool SetListScaling(Canvas Canvas)
{
    //hack to make list options square
    if(Abilities.GetItem(0) != None && Abilities.Elements[0].WinHeight != Abilities.Elements[0].WinWidth)
        Abilities.ItemScaling = Abilities.Elements[0].WinWidth / Canvas.ClipY;
    return false;
}

static final function int LayoutToIndex(int Row, int Column)
{
    return (NUM_COLUMNS * (Row - 1)) + (Column - 1);
}

static final function GridPosition IndexToLayout(int idx)
{
    local GridPosition Layout;

    Layout.Row = Ceil(float(idx + 1) / NUM_COLUMNS);
    Layout.Column = NUM_COLUMNS - (idx % NUM_COLUMNS);

    return Layout;
}

static final function float GetLineClippedX(float X1, float Y1, float X2, float Y2, float VC)
{
    return ((VC - Y1) / ((Y2 - Y1) / (X2 - X1))) + X1;
}

function InitMenu()
{
    local int i, x;
    local int OwnedIdx;

    if(!bInitialized)
    {
        OwnedIdx = -1;
        for(i = 0; i < RPGMenu.RPRI.AllAbilities.Length; i++)
        {
            if(RPGClass(RPGMenu.RPRI.AllAbilities[i]) != None)
            {
                x = ClassInfos.Length;
                ClassInfos.Length = x + 1;
                ClassInfos[x].RPGClass = RPGClass(RPGMenu.RPRI.AllAbilities[i]).Class;
                ClassInfos[x].Name = ClassInfos[x].RPGClass.default.AbilityName;

                cbTree.AddItem(ClassInfos[x].Name);

                if(RPGMenu.RPRI.AllAbilities[i].AbilityLevel > 0)
                    OwnedIdx = x;
            }
        }
        if(OwnedIdx != -1)
            cbTree.SetIndex(OwnedIdx);
        else
            cbTree.SetText(Text_NoClassSelected);

        bInitialized = true;
    }
    else
        cbTree.SetIndex(LastSelectedClass);

    SelectClassTree(None);
    SelectedIndex = LastSelectedAbility;
    SelectAbility(None);

    lblStats.Caption = Text_PointsAvailable @ string(RPGMenu.RPRI.AbilityPointsAvailable);
}

final function LoadClassTree(class<RPGClass> RPGClass)
{
    local int i, x, y;
    local int MaxRow, MaxColumn;
    local int NumItems;
    local int idx;
    local RPGMenu_AbilityListMenuOption Option;
    local array<string> Tip;

    if(RPGClass == None)
        return;

    CurrentClass = RPGClass;

    Abilities.Clear();
    AbilityInfos.Length = 0;
    
    for(i = 0; i < RPGClass.default.ClassTreeInfos.Length; i++)
    {
        y = AbilityInfos.Length;
        AbilityInfos.Length = y + 1;
        AbilityInfos[y].Row = RPGClass.default.ClassTreeInfos[i].Row;
        AbilityInfos[y].Column = RPGClass.default.ClassTreeInfos[i].Column;
        AbilityInfos[y].ForbidsAbilities = RPGClass.default.ClassTreeInfos[i].ForbidsAbilities;
        AbilityInfos[y].RequiredByAbilities = RPGClass.default.ClassTreeInfos[i].RequiredByAbilities;
        AbilityInfos[y].bDisjunctiveRequirements = RPGClass.default.ClassTreeInfos[i].bDisjunctiveRequirements;
        
        MaxRow = Max(MaxRow, AbilityInfos[y].Row);
        MaxColumn = Max(MaxColumn, AbilityInfos[y].Column);

        for(x = 0; x < RPGMenu.RPRI.AllAbilities.Length; x++)
        {
            if(RPGMenu.RPRI.AllAbilities[x].Class == RPGClass.default.ClassTreeInfos[i].AbilityClass)
            {
                AbilityInfos[y].LinkedAbility = RPGMenu.RPRI.AllAbilities[x];
                AbilityInfos[y].Cost = AbilityInfos[y].LinkedAbility.Cost(CurrentClass);
                if(AbilityInfos[y].LinkedAbility.AbilityLevel < AbilityInfos[y].LinkedAbility.MaxLevel)
                    AbilityInfos[y].NextLevel = AbilityInfos[y].LinkedAbility.AbilityLevel + 1;
                AbilityInfos[y].Name = AbilityInfos[y].LinkedAbility.AbilityName;
            }
        }
    }

    NumItems = LayoutToIndex(MaxRow, MaxColumn) + 1;
    for(i = 0; i < NumItems; i++)
    {
        Option = RPGMenu_AbilityListMenuOption(Abilities.AddItem(string(class'RPGMenu_AbilityListMenuOption')));
        Option.SetVisibility(false);
        Option.MyButton.ToolTip.SetTip("");
        Option.ComponentJustification = TXTA_Center;
    }
    for(i = 0; i < AbilityInfos.Length; i++)
    {
        idx = LayoutToIndex(AbilityInfos[i].Row, AbilityInfos[i].Column);
        Option = RPGMenu_AbilityListMenuOption(Abilities.GetItem(idx));
        Option.Index = i;
        Option.LinkedAbility = AbilityInfos[i].LinkedAbility;
        Option.OnChange = SelectAbility;
        Option.SetVisibility(true);
        Option.bNeverFocus = false;
        Option.OnClickSound = CS_Click;

        if(AbilityInfos[i].LinkedAbility != None)
        {
            Tip[0] = AbilityInfos[i].Name;
            Tip[1] = Text_Level $ ":" @ AbilityInfos[i].LinkedAbility.AbilityLevel $ "/" $ AbilityInfos[i].LinkedAbility.MaxLevel;
            if(AbilityInfos[i].Cost == 0)
                Tip[2] = Text_Cost $ ":" @ Text_CantBuy;
            else if(AbilityInfos[i].NextLevel == 0)
                Tip[2] = Text_Cost $ ":" @ Text_AlreadyMax;
            else
                Tip[2] = Text_Cost $ ":" @ AbilityInfos[i].Cost;

            Option.MyButton.ToolTip.SetTip("a");
            Option.ToolTip.Lines.Length = 0;
            for(x = 0; x < Tip.Length; x++)
                Option.MyButton.ToolTip.Lines[x] = Tip[x];
        }
    }

    CalculateAbilityStates();
}

final function CalculateAbilityStates()
{
    local int i;

    for(i = 0; i < AbilityInfos.Length; i++)
    {
        if(AbilityInfos[i].State > AS_None)
            continue;

        CalculateSingleAbilityState(i, i);
    }
}

final function CalculateSingleAbilityState(int FromIdx, int ToIdx)
{
    local int i, x;
    local int Cost;

    //Check for circular relationship in forbidden abilities
    if(AbilityInfos[ToIdx].State == AS_Blocked && AbilityInfos[FromIdx].State == AS_Blocked)
        for(i = 0; i < AbilityInfos[ToIdx].ForbidsAbilities.Length; i++)
            if(AbilityInfos[ToIdx].ForbidsAbilities[i].Index == FromIdx)
                return;

    else if(AbilityInfos[FromIdx].State > AbilityInfos[ToIdx].State)
        AbilityInfos[ToIdx].State = AbilityInfos[FromIdx].State;

    if(AbilityInfos[ToIdx].LinkedAbility.AbilityLevel > 0)
        AbilityInfos[ToIdx].State = AS_Purchased;
    else
    {
        Cost = AbilityInfos[ToIdx].LinkedAbility.Cost(CurrentClass);
        if(Cost == class'RPGAbility'.default.ForbiddenAbilityPurchasedCost)
            AbilityInfos[ToIdx].State = AS_Blocked;
        else if(Cost == class'RPGAbility'.default.CantBuyCost)
            AbilityInfos[ToIdx].State = AS_Disabled;
        else
            AbilityInfos[ToIdx].State = AS_Available;
    }

    for(x = 0; x < AbilityInfos[ToIdx].ForbidsAbilities.Length; x++)
        CalculateSingleAbilityState(ToIdx, AbilityInfos[ToIdx].ForbidsAbilities[x].Index);

    for(x = 0; x < AbilityInfos[ToIdx].RequiredByAbilities.Length; x++)
        CalculateSingleAbilityState(ToIdx, AbilityInfos[ToIdx].RequiredByAbilities[x].Index);
}

static final function CalcRelationshipLine(GUIMultiOptionList List, GridPosition Pos1, GridPosition Pos2, out float X1, out float Y1, out float X2, out float Y2)
{
    local int RowDist;
    local int FromIdx, ToIdx;
    local float Width, Height;

    Width = List.ItemWidth;
    Height = List.ItemHeight;

    FromIdx = LayoutToIndex(Pos1.Row, Pos1.Column);
    if(List.ElementVisible(FromIdx))
    {
        X1 = RPGMenu_AbilityListMenuOption(List.GetItem(FromIdx)).MyButton.ActualLeft() + (Width * 0.5);
        Y1 = RPGMenu_AbilityListMenuOption(List.GetItem(FromIdx)).MyButton.ActualTop() + (Height * 0.5);
    }
    else
    {
        X1 = List.ActualLeft() + (Pos1.Column * Width) - (Width * 0.5);

        RowDist = abs(Pos1.Row - IndexToLayout(List.Top).Row);
        if(List.Top > FromIdx)
            RowDist *= -1;

        Y1 = List.ActualTop() + (RowDist * Height) + (Height * 0.5);
    }

    ToIdx = LayoutToIndex(Pos2.Row, Pos2.Column);
    if(List.ElementVisible(ToIdx))
    {
        X2 = RPGMenu_AbilityListMenuOption(List.GetItem(ToIdx)).MyButton.ActualLeft() + (Width * 0.5);
        Y2 = RPGMenu_AbilityListMenuOption(List.GetItem(ToIdx)).MyButton.ActualTop() + (Height * 0.5);
    }
    else
    {
        X2 = List.ActualLeft() + (Pos2.Column * Width) - (Width * 0.5);

        RowDist = abs(Pos2.Row - IndexToLayout(List.Top).Row);
        if(List.Top > ToIdx)
            RowDist *= -1;

        Y2 = List.ActualTop() + (RowDist * Height) + (Height * 0.5);
    }

    if(Y1 < List.ActualTop())
    {
        X1 = GetLineClippedX(X1, Y1, X2, Y2, List.ActualTop());
        Y1 = List.ActualTop();
    }
    else if(Y1 > List.ActualTop() + List.ActualHeight())
    {
        X1 = GetLineClippedX(X1, Y1, X2, Y2, List.ActualTop() + List.ActualHeight());
        Y1 = List.ActualTop() + List.ActualHeight();
    }

    if(Y2 < List.ActualTop())
    {
        X2 = GetLineClippedX(X1, Y1, X2, Y2, List.ActualTop());
        Y2 = List.ActualTop();
    }
    else if(Y2 > List.ActualTop() + List.ActualHeight())
    {
        X2 = GetLineClippedX(X1, Y1, X2, Y2, List.ActualTop() + List.ActualHeight());
        Y2 = List.ActualTop() + List.ActualHeight();
    }
}

final function bool DrawAbilityRelationships(Canvas Canvas)
{
    local int i, x;
    local int TopRow, BottomRow;
    local GridPosition Pos1, Pos2;
    local float X1, Y1, X2, Y2;
    local Color Color;

    TopRow = IndexToLayout(Abilities.Top).Row;
    BottomRow = IndexToLayout(Abilities.Top + Abilities.ItemsPerPage - 1).Row;

    for(i = 0; i < AbilityInfos.Length; i++)
    {
        for(x = 0; x < AbilityInfos[i].ForbidsAbilities.Length; x++)
        {
            Pos1.Row = AbilityInfos[i].Row;
            Pos1.Column = AbilityInfos[i].Column;

            Pos2.Row = AbilityInfos[AbilityInfos[i].ForbidsAbilities[x].Index].Row;
            Pos2.Column = AbilityInfos[AbilityInfos[i].ForbidsAbilities[x].Index].Column;

            if((TopRow > Pos1.Row && TopRow > Pos2.Row) || (BottomRow < Pos1.Row && BottomRow < Pos2.Row))
                continue;

            if(AbilityInfos[AbilityInfos[i].ForbidsAbilities[x].Index].State == AS_Blocked)
                Color = BlockedColor;
            else if(AbilityInfos[AbilityInfos[i].ForbidsAbilities[x].Index].State == AS_Disabled)
                Color = DisabledForbiddenColor;
            else
                Color = ForbiddenColor;

            CalcRelationshipLine(Abilities, Pos1, Pos2, X1, Y1, X2, Y2);

            class'HUD'.static.StaticDrawCanvasLine(Canvas, X1, Y1, X2, Y2, Color);
        }

        for(x = 0; x < AbilityInfos[i].RequiredByAbilities.Length; x++)
        {
            Pos1.Row = AbilityInfos[i].Row;
            Pos1.Column = AbilityInfos[i].Column;

            Pos2.Row = AbilityInfos[AbilityInfos[i].RequiredByAbilities[x].Index].Row;
            Pos2.Column = AbilityInfos[AbilityInfos[i].RequiredByAbilities[x].Index].Column;

            if((TopRow > Pos1.Row && TopRow > Pos2.Row) || (BottomRow < Pos1.Row && BottomRow < Pos2.Row))
                continue;

            if(AbilityInfos[AbilityInfos[i].RequiredByAbilities[x].Index].State == AS_Purchased)
                Color = PurchasedColor;
            else if(AbilityInfos[AbilityInfos[i].RequiredByAbilities[x].Index].State == AS_Disabled)
                Color = DisabledColor;
            else
                Color = AvailableColor;

            CalcRelationshipLine(Abilities, Pos1, Pos2, X1, Y1, X2, Y2);

            class'HUD'.static.StaticDrawCanvasLine(Canvas, X1, Y1, X2, Y2, Color);
        }
    }

    return false;
}

final function DrawAbilityIcon(Canvas Canvas, int Item, float X, float Y, float W, float HT, bool bSelected, bool bPending)
{
    local RPGMenu_AbilityListMenuOption Option;
    local float Width, Height;
    local float IconSize;
    local Material Material;

    Option = RPGMenu_AbilityListMenuOption(Abilities.GetItem(Item));
    if(Option == None || Option.LinkedAbility == None)
        return;

    Width = Abilities.ItemWidth;
    Height = Abilities.ItemHeight;
    IconSize = FMin(Width, Height) * Option.LinkedAbility.IconScale;

    Canvas.Style = 5; //STY_Alpha
    Canvas.SetPos(Option.MyButton.ActualLeft() + Option.MyButton.ActualWidth() * 0.5, Option.MyButton.ActualTop() + Option.MyButton.ActualHeight() * 0.5);

    Canvas.SetPos(
        Canvas.CurX - (IconSize * 0.5),
        Canvas.CurY - (IconSize * 0.5)
    );

    if(Option.Index == SelectedIndex)
    {
        Canvas.DrawColor = Canvas.MakeColor(255, 255, 255);
        Material = IconSelectedShader;
    }
    else
    {
        Material = Option.LinkedAbility.IconMaterial;

        switch(AbilityInfos[Option.Index].State)
        {
            case AS_Disabled:
                Canvas.DrawColor = Canvas.MakeColor(48, 48, 48);
                break;
            case AS_Blocked:
                Canvas.DrawColor = Canvas.MakeColor(255, 0, 0);
                break;
            case AS_Available:
                Canvas.DrawColor = Canvas.MakeColor(128, 128, 128);
                break;
            case AS_Purchased:
            case AS_None:
                Canvas.DrawColor = Canvas.MakeColor(255, 255, 255);
                break;
        }
    }

    Canvas.DrawTile(Material, IconSize, IconSize, 0, 0, Material.MaterialUSize(), Material.MaterialVSize());

    if(Option.Index == SelectedIndex)
    {
        Canvas.DrawColor = Canvas.MakeColor(255, 255, 255);
        Canvas.SetPos(Option.MyButton.ActualLeft(), Option.MyButton.ActualTop());
        Material = IconSelectionMaterial;
        Canvas.DrawTileStretched(Material, Width, Height);
    }
}

function CloseMenu()
{
    Abilities.Clear();
    AbilityInfos.Length = 0;
}

final function SelectClassTree(GUIComponent Sender)
{
    local int i;

    if(!bInitialized)
        return;

    RPGMenu.RPRI.ServerNoteActivity(); //Disable idle kicking when actually doing something

    for(i = 0; i < ClassInfos.Length; i++)
    {
        if(ClassInfos[i].Name == cbTree.TextStr)
        {
            LastSelectedClass = cbTree.GetIndex();
            LoadClassTree(ClassInfos[i].RPGClass);
            break;
        }
    }

    if(Sender != None)
    {
        SelectedIndex = 0;
        SelectAbility(None);
    }
}

final function SelectAbility(GUIComponent Sender)
{
    local AbilityInfo AInfo;
    
    RPGMenu.RPRI.ServerNoteActivity(); //Disable idle kicking when actually doing something
    
    if(Sender != None)
        SelectedIndex = RPGMenu_AbilityListMenuOption(Sender).Index;
    if(SelectedIndex >= 0 && AbilityInfos.Length > 0)
    {
        LastSelectedAbility = SelectedIndex;
        AInfo = AbilityInfos[SelectedIndex];
    }
    
    if(AInfo.LinkedAbility != None && AInfo.Cost > 0 && AInfo.NextLevel > 0 && RPGMenu.RPRI.AbilityPointsAvailable >= AInfo.Cost)
    {
        btBuy.Caption = Repl(Text_BuyX, "$1", AInfo.Name @ string(AInfo.NextLevel));
        btBuy.MenuState = MSAT_Blurry;
    }
    else
    {
        btBuy.Caption = Text_Buy;
        btBuy.MenuState = MSAT_Disabled;
    
        lblDesc.MyScrollText.SetContent(Text_Intro);
        sbDesc.Caption = "";
    }    
    
    if(AInfo.LinkedAbility != None)
    {
        lblDesc.MyScrollText.SetContent(AInfo.LinkedAbility.DescriptionText());
        sbDesc.Caption = AInfo.Name;

        IconSelectedShader.Diffuse = AInfo.LinkedAbility.IconMaterial;
        IconSelectedShader.Opacity = AInfo.LinkedAbility.IconMaterial;
        IconSelectedShader.SpecularityMask = AInfo.LinkedAbility.IconMaterial;
    }
}

final function bool BuyAbility(GUIComponent Sender)
{
    local AbilityInfo AInfo;

    RPGMenu.RPRI.ServerNoteActivity(); //Disable idle kicking when actually doing something
    if(SelectedIndex >= 0)
    {
        AInfo = AbilityInfos[SelectedIndex];
        
        if(AInfo.LinkedAbility != None)
        {
            if(AInfo.LinkedAbility.Buy() && RPGMenu.RPRI.Role < ROLE_Authority) //simulate for a pingless update if client
                RPGMenu.RPRI.ServerBuyAbility(AInfo.LinkedAbility);
        }
    }

    return true;
}

defaultproperties
{
    Text_PointsAvailable="Available Ability Points:"
    Text_Buy="Buy"
    Text_BuyX="Buy $1"
    Text_Level="Level"
    Text_Stats="Stats"
    Text_CantBuy="Can't buy"
    Text_AlreadyMax="Already at max"
    Text_Max="(MAX)"
    Text_Forbidden="Not allowed"
    Text_Requirements="Not available"
    Text_DoNotHaveThisYet="---"
    Text_Intro="Select an ability and see here for detailed information on it."
    Text_Description="Description"
    Text_NoClassSelected="No class ability tree selected"
    Text_Cost="Cost"
    DisabledColor=(R=32,G=32,B=32,A=255)
    BlockedColor=(R=255,A=255)
    AvailableColor=(R=224,G=255,B=224,A=255)
    PurchasedColor=(G=255,A=255)
    ForbiddenColor=(R=255,G=255,A=255)
    DisabledForbiddenColor=(R=32,G=32,A=255)

    Begin Object Class=AltSectionBackground Name=sbAbilities_
        Caption="Available Abilities"
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.503737
        WinHeight=0.831425
        WinLeft=0.000085
        WinTop=0.013567
        OnPreDraw=sbAbilities_.InternalPreDraw
    End Object
    sbAbilities=AltSectionBackground'sbAbilities_'

    Begin Object Class=GUIMultiOptionListBox Name=lstAbilities_
        bAcceptsInput=True
        bVisibleWhenEmpty=True
        OnCreateComponent=lstAbilities_.InternalOnCreateComponent
        WinWidth=0.474912
        WinHeight=0.712825
        WinLeft=0.013702
        WinTop=0.069684
    End Object
    lstAbilities=GUIMultiOptionListBox'lstAbilities_'
    
    Begin Object Class=AltSectionBackground Name=sbDesc_
        LeftPadding=0.000000
        RightPadding=0.000000
        WinWidth=0.492000
        WinHeight=0.779109
        WinLeft=0.505806
        WinTop=0.013567
        OnPreDraw=sbDesc_.InternalPreDraw
    End Object
    sbDesc=AltSectionBackground'sbDesc_'
    
    Begin Object Class=GUIScrollTextBox Name=lblDesc_
        bNoTeletype=False
        CharDelay=0.001250
        EOLDelay=0.001250
        OnCreateComponent=lblDesc_.InternalOnCreateComponent
        FontScale=FNS_Small
        WinWidth=0.463460
        WinHeight=0.667102
        WinLeft=0.520971
        WinTop=0.069684
        bNeverFocus=True
    End Object
    lblDesc=GUIScrollTextBox'lblDesc_'

    Begin Object Class=GUIButton Name=btBuy_
        WinWidth=0.474561
        WinHeight=0.060028
        WinLeft=0.514525
        WinTop=0.868341
        OnClick=BuyAbility
        OnKeyEvent=btBuy_.InternalOnKeyEvent
    End Object
    btBuy=GUIButton'btBuy_'

    Begin Object Class=GUIComboBox Name=cbTree_
        WinWidth=0.479020
        WinHeight=0.042526
        WinLeft=0.012494
        WinTop=0.875815
    End Object
    cbTree=GUIComboBox'cbTree_'
    
    Begin Object Class=GUILabel Name=lblStats_
        WinWidth=0.476529
        WinHeight=0.070657
        WinLeft=0.518262
        WinTop=0.793360
        StyleName="NoBackground"
    End Object
    lblStats=GUILabel'lblStats_'

    Begin Object Class=GUIImage Name=imgAbilities_
        ImageStyle=ISTY_Scaled
        WinWidth=0.503702
        WinHeight=0.754053
        WinLeft=0.000000
        WinTop=0.049684
        StyleName="NoBackground"
    End Object
    imgAbilities=GUIImage'imgAbilities_'

    WinHeight=0.700000
    SelectedIndex=-1
}
