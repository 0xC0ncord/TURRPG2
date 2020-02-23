//An ability a player can buy with stat points
//Abilities are handled similarly to DamageTypes and LocalMessages (abstract to avoid replication)
class RPGAbility extends Actor;

var localized string
    AndText, OrText, ReqPreText, ReqPostText,
    ForbPreText, ForbPostText, CostPerLevelText, MaxLevelText, ReqLevelText, ReqLevelPurchaseText,
    AtLevelText, GrantPreText, GrantPostText;

//game-type specific disabling
var bool bAllowed;

var localized string AbilityName, StatName;
var localized string Description;
var localized array<string> LevelDescription;

var int StartingCost, CostAddPerLevel, MaxLevel;
var bool bUseLevelCost;
var array<int> LevelCost;
var array<int> RequiredLevels;

struct AbilityStruct
{
    var class<RPGAbility> AbilityClass;
    var int Level;
    var int AllowedLevel;
};
var bool bDisjunctiveRequirements; //true = logical OR, false = logical AND
var array<AbilityStruct> RequiredAbilities;
var array<AbilityStruct> ForbiddenAbilities;

struct GrantItemStruct
{
    var int Level;
    var class<Inventory> InventoryClass;
};
var array<GrantItemStruct> GrantItem;

struct ComboReplaceStruct
{
    var array<class<Combo> > ComboClasses;
    var class<Combo> NewComboClass;
};
var array<ComboReplaceStruct> ComboReplacements;

//there is a bonus per level variable declared in so many abilities, I'm just moving it here
var float BonusPerLevel; //general purpose

//Stats redux
var bool bIsStat; //set internally

var localized string StatDescription;

//Replication
var int Index, BuyOrderIndex;
var RPGPlayerReplicationInfo RPRI;
var int AbilityLevel;

var bool bClientReceived;

//Category
var class<RPGAbilityCategory> Category;

//Status icons
var class<RPGStatusIcon> StatusIconClass;

//Internal
var bool bJustBought;

replication
{
    reliable if(Role == ROLE_Authority && bNetInitial)
        RPRI, AbilityLevel, Index, BuyOrderIndex, bAllowed;

    reliable if(Role == ROLE_Authority)
        bIsStat;

    reliable if(Role == ROLE_Authority)
        ClientReplaceCombos;
}

simulated function ClientReceived()
{
    RPRI.ReceiveAbility(Self);
    bClientReceived = true;
}

simulated event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if(Role < ROLE_Authority && !bClientReceived && RPRI != None)
        ClientReceived();
}

simulated event Tick(float dt)
{
    Super.Tick(dt);

    if(Role < ROLE_Authority && !bClientReceived && RPRI != None)
        ClientReceived();
}

simulated event PostBeginPlay()
{
    local int i;
    local class<Inventory> InventoryClass;

    if(StatName == "")
        StatName = AbilityName;

    if(Role == ROLE_Authority) {
        bAllowed = class'MutTURRPG'.static.Instance(Level).GameSettings.AllowAbility(Self.class);

        for(i = 0; i < GrantItem.Length; i++) {
            InventoryClass = Level.Game.BaseMutator.GetInventoryClass(string(GrantItem[i].InventoryClass));
            if(InventoryClass != None) {
                GrantItem[i].InventoryClass = InventoryClass;
            }
        }
    }
}

simulated function bool Buy(optional int Amount)
{
    local int NextCost;

    Amount = Min(Amount, MaxLevel - AbilityLevel);

    if(bIsStat)
        NextCost = StartingCost * Amount;
    else
        NextCost = Cost();

    if(NextCost <= 0 || (bIsStat && NextCost > RPRI.StatPointsAvailable) || (!bIsStat && NextCost > RPRI.AbilityPointsAvailable))
        return false;

    if(bIsStat)
        RPRI.StatPointsAvailable -= NextCost;
    else
        RPRI.AbilityPointsAvailable -= NextCost;

    if(class'Util'.static.InArray(Self, RPRI.Abilities) == -1)
    {
        BuyOrderIndex = RPRI.Abilities.Length;
        RPRI.Abilities[RPRI.Abilities.Length] = Self;
    }

    if(bIsStat)
        AbilityLevel += Amount;
    else
        AbilityLevel++;

    bJustBought = true;

    if(Level.NetMode != NM_DedicatedServer)
        RPRI.ClientReInitMenu();

    if(Role == ROLE_Authority && bAllowed && RPRI.Controller.Pawn != None)
    {
        RPRI.ModifyStats();

        if(Vehicle(RPRI.Controller.Pawn) != None)
        {
            PreModifyPawn(Vehicle(RPRI.Controller.Pawn).Driver);
            ModifyPawn(Vehicle(RPRI.Controller.Pawn).Driver);
            ModifyVehicle(Vehicle(RPRI.Controller.Pawn));
            PostModifyPawn(Vehicle(RPRI.Controller.Pawn).Driver);
        }
        else
        {
            PreModifyPawn(RPRI.Controller.Pawn);
            ModifyPawn(RPRI.Controller.Pawn);
            PostModifyPawn(RPRI.Controller.Pawn);
        }

        if(xPlayer(RPRI.Controller) != None && ComboReplacements.Length > 0)
        {
            ReplaceCombos(xPlayer(RPRI.Controller));
            ClientReplaceCombos();
        }

        RPRI.ProcessGrantQueue(); //give weapons

        if(RPRI.Controller.Pawn.Weapon != None)
            ModifyWeapon(RPRI.Controller.Pawn.Weapon);
    }

    bJustBought = false;

    return true;
}

//Get the ability's name
simulated function string GetName()
{
    if(bIsStat)
        return StatName;
    else
        return AbilityName;
}

/*
    Automatically generates a description text for this ability.
    Includes the Description string, items granted at certain levels, requirements, forbidden abilities, max level and
    finally the cost per level.
*/
simulated function string DescriptionText()
{
    local int x, y, i;
    local array<string> list, listtwo;
    local string text;

    text = Description;

    for(y = 0; y < MaxLevel && y < LevelDescription.Length; y++)
    {
        if(LevelDescription[y] != "")
            text $= "|" $ LevelDescription[y];
    }
    for(y = 1; y <= MaxLevel; y++)
    {
        list.Remove(0, list.Length);
        for(x = 0; x < GrantItem.Length; x++)
        {
            if(GrantItem[x].InventoryClass != None && GrantItem[x].Level == y)
                list[list.Length] = GrantItem[x].InventoryClass.default.ItemName;
        }

        if(list.Length > 0)
        {
            i = 0;
            text $= "|" $ AtLevelText @ string(y) $ GrantPreText;
            for(x = 0; x < list.Length; x++)
            {
                i++;
                text @= list[x];

                if(x + 2 < list.Length)
                    text $= ",";
                else if(i >= 2 && x + 1 < list.Length)
                    text $= "," @ AndText;
                else if(x + 1 < list.Length)
                    text @= AndText;
            }
            text @= GrantPostText;
        }
    }

    list.Length = 0;

    for(x = 0; x < RequiredLevels.Length; x++)
        list[list.Length] = string(RequiredLevels[x]);

    if(list.Length > 0)
    {
        i = 0;
        text $= "||" $ ReqLevelText;
        for(x = 0; x < list.Length; x++)
        {
            if(int(list[x]) > 0)
            {
                i++;
                text @= "level" @ list[x] @ ReqLevelPurchaseText @ x + 1;
                if(x + 2 < list.Length)
                    text $= ",";
                else if(i >= 2 && x + 1 < list.Length)
                    text $= "," @ AndText;
                else if(x + 1 < list.Length)
                    text @= AndText;
            }
        }
        text $= ".";
    }

    list.Length = 0;

    for(x = 0; x < RequiredAbilities.Length && RequiredAbilities[x].AbilityClass != None; x++)
    {
        i = list.Length;
        listtwo.Length = i + 1;
        list[i] = RPRI.GetAbility(RequiredAbilities[x].AbilityClass).GetName();

        if(RequiredAbilities[x].Level > 1)
        {
            list[i] @= string(RequiredAbilities[x].Level);
            if(RequiredAbilities[x].AllowedLevel > 0)
                listtwo[i] = string(RequiredAbilities[x].AllowedLevel);
            else
                listtwo[i] = "1";
        }
    }
    if(list.Length > 0)
    {
        i = 0;
        text $= "||" $ ReqPreText;

        for(x = 0; x < list.Length; x++)
        {
            i++;
            text @= list[x] @ ReqLevelPurchaseText @ listtwo[x];

            if(x + 2 < list.Length)
                text $= ",";
            else if(i >= 2 && x + 1 < list.Length)
            {
                if(bDisjunctiveRequirements)
                    text $= "," @ OrText;
                else
                    text $= "," @ AndText;
            }
            else if(x + 1 < list.Length)
                text @= AndText;
        }
        text @= ReqPostText;
    }

    list.Length = 0;
    for(x = 0; x < ForbiddenAbilities.Length && ForbiddenAbilities[x].AbilityClass != None; x++)
    {
        i = list.Length;
        list[i] = RPRI.GetAbility(ForbiddenAbilities[x].AbilityClass).GetName();

        if(ForbiddenAbilities[x].Level > 1)
            list[i] @= string(ForbiddenAbilities[x].Level);
    }
    if(list.Length > 0)
    {
        i = 0;
        text $= "||" $ ForbPreText;

        for(x = 0; x < list.Length; x++)
        {
            i++;
            text @= list[x];

            if(x + 2 < list.Length)
                text $= ",";
            else if(i >= 2 && x + 1 < list.Length)
                text $= "," @ OrText;
            else if(x + 1 < list.Length)
                text @= OrText;
        }

        text @= ForbPostText;
    }

    if(CostForNextLevel(x) > 0)
        text $= "||" $ MaxLevelText $ ":" @ string(MaxLevel) $ "|" $ CostPerLevelText;
    for(x = 0; x < MaxLevel; x++)
    {
        if(CostForNextLevel(x) <= 0)
            break;
        text @= string(CostForNextLevel(x));

        if(x + 1 < MaxLevel)
            text $= ",";
    }

    return text;
}

//for stats
simulated function string StatDescriptionText()
{
    return StatDescription;
}

simulated function int CostForNextLevel(int x)
{
    //return a cost
    if(bIsStat)
    {
        return StartingCost; //stats have a constant cost
    }
    else
    {
        if(bUseLevelCost)
        {
            if(x < LevelCost.length)
            {
                return LevelCost[x];
            }
            else
            {
                Warn("LevelCost of ability" @ string(default.class) @ "does not provide enough entries for a MaxLevel of" @ string(default.MaxLevel));
                return LevelCost[LevelCost.Length - 1];
            }
        }
        else
        {
            return StartingCost + CostAddPerLevel * x;
        }
    }
}

simulated function int Cost()
{
    local int x, lv;
    local bool bDisjunctiveResult;

    if(AbilityLevel >= MaxLevel)
        return 0;

    if(RPRI != None)
    {
        //check required levels
        if(AbilityLevel < RequiredLevels.Length && RPRI.RPGLevel < RequiredLevels[AbilityLevel])
            return 0;

        //find forbidden abilities
        for(x = 0; x < ForbiddenAbilities.length; x++)
        {
            lv = RPRI.HasAbility(ForbiddenAbilities[x].AbilityClass, true);

            if(lv >= ForbiddenAbilities[x].Level)
                return 0;
        }

        //look for required abilities
        for(x = 0; x < RequiredAbilities.length; x++)
        {
            lv = RPRI.HasAbility(RequiredAbilities[x].AbilityClass, true);

            if(lv < RequiredAbilities[x].Level) {
                return 0;
            } else if(bDisjunctiveRequirements) {
                bDisjunctiveResult = true;
                break;
            }
        }

        if(bDisjunctiveRequirements && !bDisjunctiveResult) {
            return 0;
        }
    }

    //return a cost
    return CostForNextLevel(AbilityLevel);
}

function ModifyRPRI()
{
}

function PreModifyPawn(Pawn Other);

function ModifyPawn(Pawn Other)
{
    local int x, i;
    local Ability_Denial Denial;
    local bool bGotIt;

    Instigator = Other;

    if(StatusIconClass != None)
        RPRI.ClientCreateStatusIcon(StatusIconClass);

    if(GrantItem.Length > 0)
        Denial = Ability_Denial(RPRI.GetOwnedAbility(class'Ability_Denial'));

    for(x = 0; x < GrantItem.Length; x++)
    {
        if(AbilityLevel >= GrantItem[x].Level)
        {
            if(ClassIsChildOf(GrantItem[x].InventoryClass, class'Weapon'))
            {
                // If we have denial, don't grant the same weapon if it's already going to be restored
                if(Denial != None)
                {
                    for(i = 0; i < Denial.StoredWeapons.Length; i++)
                    {
                        if(Denial.StoredWeapons[i].WeaponClass == GrantItem[x].InventoryClass)
                        {
                            bGotIt = true;
                            break;
                        }
                    }
                }
                if(!bGotIt)
                    RPRI.QueueWeapon(class<Weapon>(GrantItem[x].InventoryClass), None, 0, 0, 0,, self);
                else
                    bGotIt = false;
            }
            else
                class'Util'.static.GiveInventory(Other, GrantItem[x].InventoryClass);
        }
    }
}

function PostModifyPawn(Pawn Other);

simulated function ClientReplaceCombos()
{
    if(Role < Role_Authority)
        ReplaceCombos(xPlayer(RPRI.Controller));
}

simulated function ReplaceCombos(xPlayer xP)
{
    local int i, x, y;

    for(x = 0; x < ComboReplacements.Length; x++)
    {
        for(i = 0; i < 16; i++)
        {
            if(ComboReplacements[x].ComboClasses.Length == 0 && xP.ComboList[i] == None)
            {
                xP.ClientReceiveCombo(string(ComboReplacements[x].NewComboClass));
                break;
            }
            else
            {
                for(y = 0; y < ComboReplacements[x].ComboClasses.Length; y++)
                {
                    if(xP.ComboList[i] == ComboReplacements[x].ComboClasses[y])
                    {
                        xP.ComboList[i] = ComboReplacements[x].NewComboClass;
                        xP.ComboNameList[i] = string(ComboReplacements[x].NewComboClass);
                        break;
                    }
                }
            }
        }
    }
}

/* Modify the owning player's current weapon. Called whenever the player's weapon changes.
 */
function ModifyWeapon(Weapon Weapon);

/* Modify any artifact item given to the player.
 */
function ModifyArtifact(RPGArtifact A);


/* Modify a monster summoned by the owning player (Master).
 */
function ModifyMonster(Monster M, Pawn Master);

/* Modify a thing constructed by the owning player.
 */
function ModifyConstruction(Pawn Other);

function ModifyVehicle(Vehicle V);

/* Remove any modifications to this vehicle, because the player is no longer driving it.
 */
function UnModifyVehicle(Vehicle V);

//Override ability to enter or leave a vehicle
function bool CanEnterVehicle(Vehicle V)
{
    return true;
}

/* Allow abilities to modify adrenaline gain and subtraction
 */
function ModifyAdrenalineGain(out float Amount, float OriginalAmount, optional Object Source);
function ModifyAdrenalineDrain(out float Amount, float OriginalAmount, optional Object Source);

/* React to damage about to be done to the injured player's pawn. Called by RPGRules.NetDamage()
 * Note that this is called AFTER the damage has been affected by Damage Bonus/Damage Reduction.
 * Also note that for any damage this is called on the abilities of both players involved.
 * Use bOwnedByInstigator to determine which pawn is the owner of this ability.
 */
//function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator);

/* Dealing damage - NOTE: InstigatedBy is not necessarily the Instigator but whatever is currently controlled by it! */
function AdjustTargetDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType);

/* Taking damage - NOTE: Injured is not necessarily the Instigator but whatever is currently controlled by it! */
function AdjustPlayerDamage(out int Damage, int OriginalDamage, Pawn Injured, Pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType);

/* Killed another player */
function ScoreKill(Controller Killed, class<DamageType> DamageType);

/* Killed by another player */
function Killed(Controller Killer, class<DamageType> DamageType);

/* If this returns true, prevent Killed's death. Called by RPGRules.PreventDeath()
 * NOTE: If a GameRules before RPGRules prevents the death, this probably won't get called
 * bAlreadyPrevented will be true if a GameRules AFTER RPGRules, or an ability, has already prevented the death.
 * If bAlreadyPrevented is true, the return value of this function is ignored. This is called anyway so you have the
 * opportunity to prevent stacking of death preventing abilities (for example, by putting a marker inventory on Killed
 * so next time you know not to prevent his death again because it was already prevented once)
 */
function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, bool bAlreadyPrevented)
{
    return false;
}

/* If this returns true, prevent boneName from being severed from Killed. You should return true here anytime you will be
 * returning true to PreventDeath(), above, as otherwise you will have live pawns running around with no head and other
 * amusing but gameplay-damaging phenomenon.
 */
function bool PreventSever(Pawn Killed, name boneName, int Damage, class<DamageType> DamageType)
{
    return false;
}

/* Called when the player actually dies, not if it's prevented
 * bLogout is true if called as a result of logging out or quitting
 * Killer will be RPRI.Controller.Pawn and DamageType will be class'Suicided' for instances when we really should be dying
 * This primarily provides an interface to let abilities clean up any needed states when the player dies
 */
function PlayerDied(bool bLogout, optional Pawn Killer, optional class<DamageType> DamageType);

/* Called by RPGRules.OverridePickupQuery() and works exactly like that function - if this returns true,
 * bAllowPickup determines if item can be picked up (1 is yes, any other value is no)
 * NOTE: The first function to return true prevents all further abilities in the player's ability list
 * from getting this call on that particular Pickup. Therefore, to maintain maximum compatibility,
 * return true only if you're actually overriding the normal behavior.
 */
function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup)
{
    return false;
}

/*
    Called by RPGPlayerReplicationInfo when a weapon is about to be granted to the
    owning player. If this function returns true, the weapon will be granted with the applied.
    modifications. If it returns false, it will not be granted at all.
*/
function bool OverrideGrantedWeapon(class<Weapon> WeaponClass, out class<RPGWeaponModifier> ModifierClass, out int Modifier, optional Object Source) {
    return true;
}

/*
    Called by RPGPlayerReplicationInfo when a weapon has been granted to the owning
    player.
*/
function ModifyGrantedWeapon(Weapon Weapon, RPGWeaponModifier WeaponModifier, optional Object Source);

/*
    Called by RPGPlayerReplicationInfo when a weapon is about to be granted to the
    owning player. This is called after OverrideGrantedWeapon returned true or if
    the weapon is forced.
*/
function OverrideGrantedWeaponAmmo(class<Weapon> WeaponClass, out int Ammo1, out int Ammo2);

/*
    Called by RPGEffect when it is about to be applied.
    Returns whether or not this effect can be applied when this ability is being owned.
*/
function bool AllowEffect(class<RPGEffect> EffectClass, Controller Causer, float Duration, float Modifier)
{
    return true;
}

defaultproperties
{
    Category=class'AbilityCategory_Misc'

    StartingCost=0
    CostAddPerLevel=0
    bUseLevelCost=False

    bDisjunctiveRequirements=False;

    AndText="and"
    OrText="or"
    ReqPreText="You need at least"
    ReqPostText="of this ability."
    ForbPreText="You cannot have this ability and"
    ForbPostText="at the same time."
    CostPerLevelText="Cost (per level):"
    MaxLevelText="Max Level"
    ReqLevelText="You must be at least"
    ReqLevelPurchaseText="to purchase level"
    AtLevelText="At level"
    GrantPreText=", you are granted the"
    GrantPostText="when you spawn."

    DrawType=DT_None

    bAlwaysRelevant=False
    bOnlyRelevantToOwner=True
    bOnlyDirtyReplication=True
    NetUpdateFrequency=4.000000
    RemoteRole=ROLE_SimulatedProxy
}
