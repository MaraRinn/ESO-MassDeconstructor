
--Register LAM with LibStub
local MAJOR, MINOR = "LibItemInfo-1.0", 7
local lii, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lii then return end	--the same or newer version of this lib is already loaded into memory 


local tEquipTypes = {
	[ITEMTYPE_ARMOR] = {
		[ARMORTYPE_NONE] 	= {
			["CRAFTINGSKILLTYPE"] 	= CRAFTING_TYPE_JEWELRYCRAFTING,
			[EQUIP_TYPE_RING]   = 1,
			[EQUIP_TYPE_NECK]   = 2,
		},
		[ARMORTYPE_LIGHT] 	= {
			["CRAFTINGSKILLTYPE"] 	= CRAFTING_TYPE_CLOTHIER,
			[EQUIP_TYPE_CHEST]		= 1,
			[EQUIP_TYPE_FEET]		= 2,
			[EQUIP_TYPE_HAND]		= 3,
			[EQUIP_TYPE_HEAD]		= 4,
			[EQUIP_TYPE_LEGS]		= 5,
			[EQUIP_TYPE_SHOULDERS]	= 6,
			[EQUIP_TYPE_WAIST]		= 7,
		},
		[ARMORTYPE_MEDIUM] 	= {
			["CRAFTINGSKILLTYPE"] 	= CRAFTING_TYPE_CLOTHIER,
			[EQUIP_TYPE_CHEST]		= 8,
			[EQUIP_TYPE_FEET]		= 9,
			[EQUIP_TYPE_HAND]		= 10,
			[EQUIP_TYPE_HEAD]		= 11,
			[EQUIP_TYPE_LEGS]		= 12,
			[EQUIP_TYPE_SHOULDERS]	= 13,
			[EQUIP_TYPE_WAIST]		= 14,
		},
		[ARMORTYPE_HEAVY] 	= {
			["CRAFTINGSKILLTYPE"] 	= CRAFTING_TYPE_BLACKSMITHING,
			[EQUIP_TYPE_CHEST]		= 8,
			[EQUIP_TYPE_FEET]		= 9,
			[EQUIP_TYPE_HAND]		= 10,
			[EQUIP_TYPE_HEAD]		= 11,
			[EQUIP_TYPE_LEGS]		= 12,
			[EQUIP_TYPE_SHOULDERS]	= 13,
			[EQUIP_TYPE_WAIST]		= 14,
		},
	},
	[ITEMTYPE_WEAPON] = {
		[WEAPONTYPE_SHIELD]				= {
			[EQUIP_TYPE_OFF_HAND] = 6, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_WOODWORKING},
		[WEAPONTYPE_AXE]				= {
			[EQUIP_TYPE_ONE_HAND] = 1, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_BLACKSMITHING},
		[WEAPONTYPE_DAGGER]				= {
			[EQUIP_TYPE_ONE_HAND] = 7, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_BLACKSMITHING},
		[WEAPONTYPE_HAMMER]				= {
			[EQUIP_TYPE_ONE_HAND] = 2, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_BLACKSMITHING},
		[WEAPONTYPE_SWORD]				= {
			[EQUIP_TYPE_ONE_HAND] = 3, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_BLACKSMITHING},
		[WEAPONTYPE_TWO_HANDED_AXE]		= {
			[EQUIP_TYPE_TWO_HAND] = 4, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_BLACKSMITHING},
		[WEAPONTYPE_TWO_HANDED_HAMMER]	= {
			[EQUIP_TYPE_TWO_HAND] = 5, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_BLACKSMITHING},
		[WEAPONTYPE_TWO_HANDED_SWORD]	= {
			[EQUIP_TYPE_TWO_HAND] = 6, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_BLACKSMITHING},
		[WEAPONTYPE_BOW]				= {
			[EQUIP_TYPE_TWO_HAND] = 1, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_WOODWORKING},
		[WEAPONTYPE_FIRE_STAFF]			= {
			[EQUIP_TYPE_TWO_HAND] = 2, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_WOODWORKING},
		[WEAPONTYPE_FROST_STAFF]		= {
			[EQUIP_TYPE_TWO_HAND] = 3, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_WOODWORKING},
		[WEAPONTYPE_LIGHTNING_STAFF] 	= {
			[EQUIP_TYPE_TWO_HAND] = 4, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_WOODWORKING},
		[WEAPONTYPE_HEALING_STAFF]		= {
			[EQUIP_TYPE_TWO_HAND] = 5, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_WOODWORKING},
	},
}

local tIsTraitResearchable = {
	[ITEM_TRAIT_TYPE_ARMOR_DIVINES] 		= true,
	[ITEM_TRAIT_TYPE_ARMOR_EXPLORATION] 	= true,
	[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] 	= true,
	[ITEM_TRAIT_TYPE_ARMOR_INFUSED] 		= true,
	[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] 		= false,
	[ITEM_TRAIT_TYPE_ARMOR_ORNATE] 			= false,
	[ITEM_TRAIT_TYPE_ARMOR_REINFORCED]		= true,
	[ITEM_TRAIT_TYPE_ARMOR_STURDY] 			= true,
	[ITEM_TRAIT_TYPE_ARMOR_TRAINING] 		= true,
	[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED]		= true,
	[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] 		= true,
	
	[ITEM_TRAIT_TYPE_WEAPON_CHARGED] 		= true,
	[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] 		= true,
	[ITEM_TRAIT_TYPE_WEAPON_INFUSED] 		= true,
	[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] 		= false,
	[ITEM_TRAIT_TYPE_WEAPON_ORNATE] 		= false,
	[ITEM_TRAIT_TYPE_WEAPON_POWERED] 		= true,
	[ITEM_TRAIT_TYPE_WEAPON_PRECISE] 		= true,
	[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] 		= true,
	[ITEM_TRAIT_TYPE_WEAPON_TRAINING] 		= true,
	[ITEM_TRAIT_TYPE_WEAPON_WEIGHTED]	 	= true,
	[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] 		= true,
	
	[ITEM_TRAIT_TYPE_JEWELRY_ARCANE]			= true,
	[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY]	= true,
	[ITEM_TRAIT_TYPE_JEWELRY_HARMONY]		= true,
	[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]		= true,
	[ITEM_TRAIT_TYPE_JEWELRY_INFUSED]		= true,
	[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE]		= true,
	[ITEM_TRAIT_TYPE_JEWELRY_ORNATE]			= false,
	[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE]	= true,
	[ITEM_TRAIT_TYPE_JEWELRY_ROBUST]			= true,
	[ITEM_TRAIT_TYPE_JEWELRY_SWIFT]			= true,
	[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE]			= true,

	[ITEM_TRAIT_TYPE_NONE] 					= false,
}

-- All functions may depend on lii:GetItemLink to function properly.
-- Any other library dependent functions are marked with a preceding comment.

------------------------------------------------------------------------
-- 	General Functions  --
------------------------------------------------------------------------
-- Returns an unformatted link of the item
function lii:GetItemLink(_BagIdOrLink, _iSlotId)
	if _iSlotId then
		return GetItemLink(_BagIdOrLink,_iSlotId)
	end
	return _BagIdOrLink
end

-- Returns a zo_strformat(..)'d Link --
function lii:GetFormattedItemLink(_BagIdOrLink, _iSlotId)
	if _iSlotId then
		return zo_strformat("<<t:1>>", GetItemLink(_BagIdOrLink,_iSlotId))
	end
	return zo_strformat("<<t:1>>", _BagIdOrLink)
end

-- Returns the zo_strformat(..)'d ToolTipName of the item
function lii:GetItemToolTipName(_BagIdOrLink, _iSlotId)
	if _iSlotId then
		return zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(_BagIdOrLink, _iSlotId))
	end
	return zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(_BagIdOrLink))
end

local function GetMyLinkItemInfo(_lItemLink)
	local sIcon, iSellPrice, bMeetsUsageRequirement, iEquipType, iItemStyle = GetItemLinkInfo(_lItemLink)
	local iItemQuality = GetItemLinkQuality(_lItemLink)
	
	return sIcon, iStack, iSellPrice, bMeetsUsageRequirement, bLocked, iEquipType, iItemStyle, iItemQuality
end

-- Same returns as the built in GetItemInfo
-- sIcon, iStack, iSellPrice, bMeetsUsageRequirement, bLocked, iEquipType, iItemStyle, iItemQuality
-- Links do not have stack sizes or a locked property
-- If you pass in a link iStack & bLocked will return nil
function lii:GetItemInfo(_BagIdOrLink, _iSlotId)
	if _iSlotId then
		return GetItemInfo(_BagIdOrLink, _iSlotId)
    end
	return GetMyLinkItemInfo(_BagIdOrLink)
end



------------------------------------------------------------------------
-- 	Item SubType (ArmorType/WeaponType) Info  --
------------------------------------------------------------------------
-- GetSubType is depended on by several functions
-- Returns the appropriate ArmorType, WeaponType, 
-- or 0 if not a piece of Armor or Weapon
-- 0 is the same value as WEAPONTYPE_NONE & ARMORTYPE_NONE 
function lii:GetSubType(_BagIdOrLink, _iSlotId)
	local lLink = self:GetItemLink(_BagIdOrLink, _iSlotId)
	local iItemType = GetItemLinkItemType(lLink)
	
	if iItemType == ITEMTYPE_ARMOR then
		return GetItemLinkArmorType(lLink)
	elseif iItemType == ITEMTYPE_WEAPON then
		return GetItemLinkWeaponType(lLink)
	end
	-- 0 is the same return as WEAPONTYPE_NONE & ARMORTYPE_NONE 
	return 0
end



------------------------------------------------------------------------
-- 	ItemType Group Properties  --
------------------------------------------------------------------------
-- Returns: True/False if the item is jewelry
function lii:IsJewelry(_BagIdOrLink, _iSlotId)
	local lLink = self:GetItemLink(_BagIdOrLink, _iSlotId)
	local sIcon, iStack, iSellPrice, bMeetsUsageRequirement, isLocked, iEquipType , iItemStyle, quality = GetItemInfo(bagId, slotIndex)
	local iItemType = GetItemLinkItemType(lLink)
	
	if iItemType == ITEMTYPE_ARMOR then
		local iArmorType = GetItemLinkArmorType(lLink)
		if iArmorType == ARMORTYPE_NONE then
			if iEquipType == EQUIP_TYPE_RING or iEquipType == EQUIP_TYPE_NECK then
				return true
			end
		end
	end
	return false
end

-- Returns true/false if the item is a one handed weapon
function lii:IsWeaponOneHanded(_BagIdOrLink, _iSlotId)
	local lLink = self:GetItemLink(_BagIdOrLink, _iSlotId)
	local iItemType = GetItemLinkItemType(lLink)
	local iEquipType = GetItemLinkEquipType(lLink)
	
	if ((iItemType == ITEMTYPE_WEAPON) and (iEquipType == EQUIP_TYPE_ONE_HAND)) then
		return true
	end
	return false
end

-- Returns true/false if the item is a two handed weapon
function lii:IsWeaponTwoHanded(_BagIdOrLink, _iSlotId)
	local lLink = self:GetItemLink(_BagIdOrLink, _iSlotId)
	local iItemType = GetItemLinkItemType(lLink)
	local iEquipType = GetItemLinkEquipType(lLink)
	
	if ((iItemType == ITEMTYPE_WEAPON) and (iEquipType == EQUIP_TYPE_TWO_HAND)) then
		return true
	end
	return false
end

-- Returns true/false if the item is a crafting mat
function lii:IsCrafingMaterial(_BagIdOrLink, _iSlotId)
	local lLink = self:GetItemLink(_BagIdOrLink, _iSlotId)
	
	if GetItemLinkCraftingSkillType(lLink) ~= CRAFTING_TYPE_INVALID then
		return true
	end
	return false
end

-- returns true/false if the item is a glyph
function lii:IsGlyph(_BagIdOrLink, _iSlotId)
	local lLink = self:GetItemLink(_BagIdOrLink, _iSlotId)
	local iItemType = GetItemLinkItemType(lLink)
	
	if ((iItemType == ITEMTYPE_GLYPH_ARMOR) or (iItemType == ITEMTYPE_GLYPH_WEAPON) 
	or (iItemType == ITEMTYPE_GLYPH_JEWELRY)) then
		return true
	end
	return false
end



------------------------------------------------------------------------
-- 	Crafting Info Functions --
------------------------------------------------------------------------
-- Returns a zo_strFormat(..)'d name for the CraftingSkillType in the games current language or CRAFTING_TYPE_INVALID
-- In English it returns:
-- CRAFTING_TYPE_ALCHEMY returns "Alchemy"
-- CRAFTING_TYPE_BLACKSMITHING returns "Blacksmithing"
-- CRAFTING_TYPE_CLOTHIER returns "Clothing"
-- CRAFTING_TYPE_ENCHANTING returns "Enchanting"
-- CRAFTING_TYPE_INVALID returns CRAFTING_TYPE_INVALID (NOT a formatted string, which is 0)
-- CRAFTING_TYPE_PROVISIONING returns "Provisioning"
-- CRAFTING_TYPE_WOODWORKING  returns "Woodworking"
function lii:GetCraftingSkillTypeLabelName(_iCraftingSkillType)
-- Returns Name of Crafting Skill Type. Used for labelling things --
	-- 0 is CRAFTING_TYPE_INVALID & there are only 6 consecutively numbered crafting skill types --
	if ((_iCraftingSkillType > 0) and (_iCraftingSkillType < 7)) then
		local SkillType, skillIndex = GetCraftingSkillLineIndices(_iCraftingSkillType)
		local name, rank = GetSkillLineInfo(SkillType, skillIndex)
		return zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
	end
	return CRAFTING_TYPE_INVALID
end

-- Dependence on  lii:GetSubType & IsResearchableItemType
-- Possible Returns: CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_WOODWORKING, or CRAFTING_TYPE_INVALID
-- Returns: the CraftingSkillType of an item IF it is a researchable ItemType
-- Returns: CRAFTING_TYPE_INVALID if it is not a researchable ItemType
function lii:GetResearchableCraftingSkillType(_BagIdOrLink, _iSlotId)
	if not self:IsResearchableItemType(_BagIdOrLink, _iSlotId) then return CRAFTING_TYPE_INVALID end
	
	local lLink 	= self:GetItemLink(_BagIdOrLink, _iSlotId)
	local iSubType 	= self:GetSubType(_BagIdOrLink, _iSlotId)
	local iItemType = GetItemLinkItemType(lLink)
	
	return tEquipTypes[iItemType][iSubType]["CRAFTINGSKILLTYPE"]
end





------------------------------------------------------------------------
-- 	Research Specific Functions --
------------------------------------------------------------------------
-- Dependence on IsResearchableItem, GetResearchLineIndex, GetTraitIndex, GetResearchableCraftingSkillType
-- Returns: bool IsResearchableItem, integer CraftingSkillType, Integer ResearchLineIndex, integer TraitIndex
--  IsResearchableItem: Returns: True if itemType is researchable AND has a researchable trait on it, But that does not mean it is an unknown trait --
-- CraftingSkillType: Returns the CraftingSkillType of an item IF it is a researchable ItemType or CRAFTING_TYPE_INVALID (item does not have to have a trait on it to return a CraftingSkillType) 
-- GetResearchLineIndex: Returns the ResearchLineIndex for an item if it is a researchable ItemType Or returns CRAFTING_TYPE_INVALID (item does not have to have a trait on it to return a ResearchLineIndex) --
-- TraitIndex: Returns the TraitIndex of the trait on the item or CRAFTING_TYPE_INVALID (Armor/Weapon Trait Stones will return a TraitIndex)
function lii:GetResearchInfo(_BagIdOrLink, _iSlotId)
	local bIsResearchableItem 	= self:IsResearchableItem(_BagIdOrLink, _iSlotId)
	local iCraftingSkillType 	= self:GetResearchableCraftingSkillType(_BagIdOrLink, _iSlotId)
	local iResearchLineIndex 	= self:GetResearchLineIndex(_BagIdOrLink, _iSlotId)
	local iTraitIndex 			= self:GetTraitIndex(_BagIdOrLink, _iSlotId)
	
	return bIsResearchableItem, iCraftingSkillType, iResearchLineIndex, iTraitIndex
end

-- Dependence on lii:GetSubType
-- Returns: True if the ItemType is Armor or Weapon and the subtype is not WEAPONTYPE_RUNE or xxx_NONE --
function lii:IsResearchableItemType(_BagIdOrLink, _iSlotId)
	local lLink 	= self:GetItemLink(_BagIdOrLink, _iSlotId)
	local iItemType = GetItemLinkItemType(lLink)
	if ((iItemType ~= ITEMTYPE_ARMOR) and (iItemType ~= ITEMTYPE_WEAPON)) then return false end
	
	local iSubType 	= self:GetSubType(lLink)
	
	if tEquipTypes[iItemType][iSubType] then
		return true
	end
	return false
end

-- Dependence on  lii:GetSubType & IsResearchableItemType
-- Returns: True if itemType is researchable AND has a researchable trait on it --
-- That does not mean it is an unknown trait --
-- Make sure you note the distinction between this & HasResearchableTrait, they are not the same --
function lii:IsResearchableItem(_BagIdOrLink, _iSlotId)
	if not self:IsResearchableItemType(_BagIdOrLink, _iSlotId) then return false end
	local lLink = self:GetItemLink(_BagIdOrLink, _iSlotId)
	
	return tIsTraitResearchable[GetItemLinkTraitInfo(lLink)]
end

-- Dependence on GetResearchInfo
-- Returns: True or False
-- True if the item is a researchable ItemType, it has a researchable trait
--   on it that is unknown, and that trait is not currently being researched
function lii:NeedForResearch(_BagIdOrLink, _iSlotId)
	local bIsResearchableItem, iCraftingSkillType, iResearchLineIndex, iTraitIndex = self:GetResearchInfo(_BagIdOrLink, _iSlotId) 
	local _, _, bIsTraitKnown = GetSmithingResearchLineTraitInfo(iCraftingSkillType, iResearchLineIndex, iTraitIndex)
	
	if (bIsResearchableItem and (not bIsTraitKnown) and 
	(GetSmithingResearchLineTraitTimes(iCraftingSkillType, iResearchLineIndex, iTraitIndex) == nil)) then
		return true
	end
	return false
end

-- Dependence on  lii:GetSubType & IsResearchableItemType
-- Possible Returns: The Items ResearchLine Index or CRAFTING_TYPE_INVALID
-- Returns: The ResearchLineIndex for an item if it is a researchable ItemType
-- 		This does not mean it has a trait on it.
-- Returns: CRAFTING_TYPE_INVALID if the item is not a Researchable ItemType
function lii:GetResearchLineIndex(_BagIdOrLink, _iSlotId)
	if not self:IsResearchableItemType(_BagIdOrLink, _iSlotId) then return CRAFTING_TYPE_INVALID end
	
	local lLink 		= self:GetItemLink(_BagIdOrLink, _iSlotId)
	local iSubType 		= self:GetSubType(_BagIdOrLink, _iSlotId)
	local iItemType 	= GetItemLinkItemType(lLink)
	local iEquipType 	= GetItemLinkEquipType(lLink)
	
	return tEquipTypes[iItemType][iSubType][iEquipType]
end



------------------------------------------------------------------------
-- 	Item Trait Specific Functions --
------------------------------------------------------------------------
-- Returns: the TraitIndex of the trait on an item or CRAFTING_TYPE_INVALID
-- Does not mean the ItemType is researchable (Armor/Weapon Trait Stones will return a TraitIndex)
function lii:GetTraitIndex(_BagIdOrLink, _iSlotId)
	local lLink = self:GetItemLink(_BagIdOrLink, _iSlotId)
	local iTraitType = GetItemLinkTraitInfo(lLink)
	if not tIsTraitResearchable[iTraitType] then return CRAFTING_TYPE_INVALID end
	
	if ((iTraitType == ITEM_TRAIT_TYPE_WEAPON_NIRNHONED) 
	or (iTraitType == ITEM_TRAIT_TYPE_ARMOR_NIRNHONED)) then
		return 9
	end
	return (iTraitType % 10)
end

-- Dependence on GetResearchInfo
-- Returns true if the item is researchable and has a known researchable trait
function lii:HasKnownTrait(_BagIdOrLink, _iSlotId) 
	local bIsResearchableItem, iCraftingSkillType, iResearchLineIndex, iTraitIndex = self:GetResearchInfo(_BagIdOrLink, _iSlotId)
	local _, _, bHasKnownTrait = GetSmithingResearchLineTraitInfo(iCraftingSkillType, iResearchLineIndex, iTraitIndex)
	
	return bHasKnownTrait
end

-- Dependence on GetResearchInfo
-- Returns true/false if the item is researchable and has an unknown researchable trait
function lii:HasUnKnownTrait(_BagIdOrLink, _iSlotId) 
	local bIsResearchableItem, iCraftingSkillType, iResearchLineIndex, iTraitIndex = self:GetResearchInfo(_BagIdOrLink, _iSlotId)
	
	if bIsResearchableItem then 
		local _, _, bIsKnown = GetSmithingResearchLineTraitInfo(iCraftingSkillType, iResearchLineIndex, iTraitIndex)
		return not bIsKnown
	end
	return false
end

-- Returns true/false if the item has a researchable trait
-- 		This does not mean the trait is unknown to you or that it is
-- a researchable ItemType only that it is one of the researchable
-- TraitTypes (Armor/Weapon Trait Stones will return true)
-- Make sure you note the distinction between this & IsResearchableItem, they are not the same --
function lii:HasResearchableTrait(_BagIdOrLink, _iSlotId)
	local lLink = self:GetItemLink(_BagIdOrLink, _iSlotId)
	return tIsTraitResearchable[GetItemLinkTraitInfo(lLink)]
end

-- Dependence on GetResearchInfo
-- If the TraitType on the item is currently being researched
-- 		Returns: True, TotalResearchTime, timeLeftInSeconds 
-- If the TraitType on the item is not currently being researched
-- 		Returns: False, nil, nil
function lii:IsItemTraitBeingResearched(_BagIdOrLink, _iSlotId)
	local bIsResearchableItem, iCraftingSkillType, iResearchLineIndex, iTraitIndex = self:GetResearchInfo(_BagIdOrLink, _iSlotId)
	local iTotalResearchTime, iTimeLeftInSecs = GetSmithingResearchLineTraitTimes(iCraftingSkillType, iResearchLineIndex, iTraitIndex)
	
	if iTotalResearchTime then
		return true, iTotalResearchTime, iTimeLeftInSecs
	end
	return false
end



------------------------------------------------------------------------
-- 	Recipe Functions  --
------------------------------------------------------------------------

-- Returns: bool IsKnownRecipe, string (ToolTipFormatted)RecipeName, integer RecipeListIndex, integer RecipeIndex
-- Returns: false, nil, nil, nil if the recipe is unknown or if the item is not a recipe
-- Returns: true, (ToolTipFormatted)RecipeName, RecipeListIndex, RecipeIndex if the recipe is known
function lii:GetRecipeInfo(_BagIdOrLink, _iSlotId)
	local lLink = self:GetItemLink(_BagIdOrLink, _iSlotId)
	local iItemType = GetItemLinkItemType(lLink)
	if iItemType ~= ITEMTYPE_RECIPE then return false end 
	
	local lRecipeResultItemLink = GetItemLinkRecipeResultItemLink(lLink)
	local iNumRecipeLists = GetNumRecipeLists() 
	
	for iRecipeListIndex = 1, iNumRecipeLists do
		local _, iNumRecipes = GetRecipeListInfo(iRecipeListIndex)
			
		for iRecipeIndex = 1, iNumRecipes do
			local sRecipeResultIndexLink = GetRecipeResultItemLink(iRecipeListIndex,iRecipeIndex)
			if lRecipeResultItemLink == sRecipeResultIndexLink then
				local _,sRecipeName = GetRecipeInfo(iRecipeListIndex,iRecipeIndex)
				local sFormattedRecipeName = zo_strformat(SI_TOOLTIP_ITEM_NAME, sRecipeName)
				
				return true, sFormattedRecipeName, iRecipeListIndex, iRecipeIndex
			end
		end
	end
	return false
end









