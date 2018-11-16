local _

if MD == nil then MD = {} end
local LII = LibStub:GetLibrary("LibItemInfo-1.0")

MD.name = "MassDeconstructor"
MD.version = "4.1"

MD.settings = {}

MD.defaults = {
  DeconstructOrnate = false,
  DeconstructBound = false,
  DeconstructSetPiece = false,
  DeconstructCrafted = false,
  Debug = false,
  BankMode = false,
  Verbose = false,
  Clothing = {
    maxQuality = 4,
    DeconstructIntricate = false,
  },
  Blacksmithing = {
    maxQuality = 4,
    DeconstructIntricate = false,
  },
  Woodworking = {
    maxQuality = 4,
    DeconstructIntricate = false,
  },
  Enchanting = {
    maxQuality = 4,
    DeconstructIntricate = false,
  },
  JewelryCrafting = {
    maxQuality = 4,
    DesconstructIntricate = false,
  },
}

MD.Inventory = {
  items = { },
  clothier = { },
  blacksmith = { },
  enchanter = { },
  woodworker = { },
}

local function DebugMessage(message)
  if MD.isDebug then
    d(message)
  end
end

local function IsItemProtected(bagId, slotId)
  --Item Saver support
  if ItemSaver_IsItemSaved and ItemSaver_IsItemSaved(bagId, slotId) then
    return true
  end

  -- If an item has any FCOIS marks apart from "deconstruct" then it's proteected
  if FCOIsMarked and FCOIsMarked(GetItemInstanceId(bagId, slotId), {1,2,3,4,5,6,7,8,10,11,12}) then -- 9 is deconstruct
    --Old FCOIS version < 1.0
      return true
  elseif FCOIS and FCOIS.IsMarked and FCOIS.IsMarked(bagId, slotId, {1,2,3,4,5,6,7,8,10,11,12}, nil)then
    --New for FCOIS version >= 1.0
    return true
  end

  --FilterIt support
  if FilterIt and FilterIt.AccountSavedVariables and FilterIt.AccountSavedVariables.FilteredItems then
    local sUniqueId = Id64ToString(GetItemUniqueId(bagId, slotId))
    if FilterIt.AccountSavedVariables.FilteredItems[sUniqueId] then
      return FilterIt.AccountSavedVariables.FilteredItems[sUniqueId] ~= FILTERIT_VENDOR
    end
  end

  if IsItemPlayerLocked(bagId, slotId) then
    DebugMessage(' - item is player locked')
    return true
  else
    DebugMessage(' - item is not player locked')
  end

  return false
end

local function IsMarkedForBreaking(bagId, slotId)
  if FCOIS and FCOIS.IsMarked then
    isMarked, markedArray = FCOIS.IsMarked(bagId, slotId, {9}, nil)
    return isMarked
  end
  return false
end

local function IsOrnate(bagId,slotId)
  local traitInformation = GetItemTraitInformation(bagId, slotId)
  if traitInformation == ITEM_TRAIT_INFORMATION_ORNATE then
    DebugMessage(' - ornate through GetItemTraitInformation')
    return true
  end
  local trait = GetItemTrait(bagid, slotId)
  if trait == ITEM_TRAIT_TYPE_ARMOR_ORNATE or trait == ITEM_TRAIT_TYPE_WEAPON_ORNATE or trait == ITEM_TRAIT_TYPE_JEWELRY_ORNATE then
    DebugMessage(' - ornate through GetItemTrait')
    return true
  end
  return false
end

local function IsIntricate(bagId, slotId)
  local traitInformation = GetItemTraitInformation(bagId, slotId)
  if traitInformation == ITEM_TRAIT_INFORMATION_INTRICATE then
    DebugMessage(' - intricate through GetItemTraitInformation')
    return true
  end
  local trait = GetItemTrait(bagId, slotId)
  if trait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or trait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE or trait == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE then
    DebugMessage(' - intricate through GetItemTrait')
    return true
  end
  return false
end

local function isItemBindable(bagId, slotIndex)
  local itemLink = GetItemLink(bagId, slotIndex)
  if itemLink then
    --Bound
    if(IsItemLinkBound(itemLink)) then
      --Item is already bound
      return 1
    else
      local bindType = GetItemLinkBindType(itemLink)
      if(bindType ~= BIND_TYPE_NONE and bindType ~= BIND_TYPE_UNSET) then
        --Item can still be bound
        return 2
      else
        --Item is already bound or got no bind type
        return 3
      end
    end
  else
    return 0
  end
end

local function isSetPiece(itemLink)
  local hasSet, _, numBonuses, _, _ = GetItemLinkSetInfo(itemLink)
  return hasSet
end

local function ShouldDeconstructItem(bagId, slotIndex, itemLink)
  local _, CraftingSkillType = LII:GetResearchInfo(bagId, slotIndex)
  local sIcon, iStack, iSellPrice, bMeetsUsageRequirement, isLocked, iEquipType , iItemStyle, quality = GetItemInfo(bagId, slotIndex)
  local itemLink = GetItemLink(bagId, slotIndex)
  local boundType = isItemBindable(bagId, slotIndex)
  local isSetPc = isSetPiece(itemLink)
  local isIntricateItem = IsIntricate(bagId, slotIndex)
  local isOrnateItem = IsOrnate(bagId, slotIndex)
  local isGlyph = LII:IsGlyph(bagId, slotIndex)

  -- Sanity check: don't even consider items that don't belong in the queue
  if  (MD.isBlacksmithing and CraftingSkillType ~= CRAFTING_TYPE_BLACKSMITHING) or
      (MD.isClothing and CraftingSkillType ~= CRAFTING_TYPE_CLOTHIER) or
      (MD.isWoodworking and CraftingSkillType ~= CRAFTING_TYPE_WOODWORKING) or
      (MD.isJewelryCrafting and CraftingSkillType ~= CRAFTING_TYPE_JEWELRYCRAFTING) or
      (MD.isEnchanting and not isGlyph) then
    return false
  end

  DebugMessage(itemLink .. " -- Crafting Skill Type: " .. CraftingSkillType .. " Equip type: " .. iEquipType)

  if IsItemProtected(bagId, slotIndex) then
    DebugMessage(" - Item is protected")
    return false
  end
  
  if CanItemBeSmithingExtractedOrRefined(bagId, slotIndex, CraftingSkillType) or isGlyph then
    DebugMessage(" - can be deconstructed")
  else
    DebugMessage(" - can NOT be deconstructed")
    return false
  end

  -- Marking an item for deconstruction using FCOIS voids all warranties
  if IsMarkedForBreaking(bagId, slotIndex) then
    DebugMessage(" - Item is doomed")
    return true
  end

  if CraftingSkillType == CRAFTING_TYPE_INVALID and not isGlyph then
    DebugMessage(" - Invalid crafting type")
    return false
  end

  if boundType == 1 and not MD.settings.DeconstructBound then
    DebugMessage(" - item is bound")
    return false
  end

  if isOrnateItem and not MD.settings.DeconstructOrnate then
    DebugMessage(" - item is ornate")
    return false
  end

  if isSetPc and not MD.settings.DeconstructSetPiece then
    DebugMessage(" - item is part of a set")
    return false
  end

  if IsItemLinkCrafted(itemLink) and not MD.settings.DeconstructCrafted then
    DebugMessage(" - item is crafted")
    return false
  end
  
  if CraftingSkillType == CRAFTING_TYPE_CLOTHIER then
    if not MD.isClothing then
      return false
    end
    if quality > MD.settings.Clothing.maxQuality then
      return false
    end
    if isIntricateItem and not MD.settings.Clothing.DeconstructIntricate then
      DebugMessage('Skipping intrictate clothing item: ' .. itemLink)
      return false
    end
  elseif CraftingSkillType == CRAFTING_TYPE_BLACKSMITHING then
    if not MD.isBlacksmithing then
      return false
    end
    if quality > MD.settings.Blacksmithing.maxQuality then
      return false
    end
    if isIntricateItem and not MD.settings.Blacksmithing.DeconstructIntricate then
      DebugMessage('Skipping intrictate blacksmithing item: ' .. itemLink)
      return false
    end
  elseif CraftingSkillType == CRAFTING_TYPE_WOODWORKING then
    if not MD.isWoodworking then
      return false
    end
    if quality > MD.settings.Woodworking.maxQuality then
      return false
    end
    if isIntricateItem and not MD.settings.Woodworking.DeconstructIntricate then
      DebugMessage('Skipping intrictate woodworking item: ' .. itemLink)
      return false
    end
  elseif CraftingSkillType == CRAFTING_TYPE_JEWELRYCRAFTING then
    if not MD.isJewelryCrafting then
      return false
    end
    if quality > MD.settings.JewelryCrafting.maxQuality then
      return false
    end
    if isIntricateItem and not MD.settings.JewelryCrafting.DeconstructIntricate then
      DebugMessage('Skipping intricate jewellery item: ' .. itemLink)
      return false
    end
  elseif isGlyph then
    if quality > MD.settings.Enchanting.maxQuality then
      return false
    end
    if not MD.isEnchanting then
      return false
    end
  end
  DebugMessage("Adding " .. itemLink)
  return true
end

local function AddItemsToDeconstructionQueue(bagId)
    DebugMessage("AddItemsToDeconstructionQueue " .. bagId)
    local bagSlots = GetBagSize(bagId)
    for slotIndex = 0, bagSlots do
      local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
      if ShouldDeconstructItem(bagId, slotIndex, itemLink) then
        x = {}
        x.bagId = bagId
        x.slotIndex = slotIndex
        x.itemLink = itemLink
        table.insert(MD.deconstructQueue, x)
      end
    end
    DebugMessage("Deconstruct queue length: " .. #MD.deconstructQueue)
end

local function ListItemsInQueue()
  itemString = #MD.deconstructQueue == 1 and 'item' or 'items'
  d('Mass Deconstruct will destroy:')
  for index, thing in ipairs(MD.deconstructQueue) do
    d(' - ' .. thing.itemLink)
  end
  d(#MD.deconstructQueue .. ' ' .. itemString)
end

local function BuildDeconstructionQueue()
  MD.deconstructQueue = {}

  AddItemsToDeconstructionQueue(BAG_BACKPACK)
  if MD.settings.BankMode then 
    -- subscribers get extra bank space
    if IsESOPlusSubscriber() then AddItemsToDeconstructionQueue(BAG_SUBSCRIBER_BANK) end
    -- regular bank
    AddItemsToDeconstructionQueue(BAG_BANK)
  end
end

function MD.ContinueWork()
  DebugMessage("Deconstruct queue count: "..#MD.deconstructQueue)
  if SMITHING.deconstructionPanel.extractionSlot:HasItem() then
    DebugMessage("Extracting item already in deconstruction slot")
    EVENT_MANAGER:RegisterForEvent(MD.name, EVENT_CRAFT_COMPLETED, MD.ContinueWork)
    if not MD.isDebug then SMITHING.deconstructionPanel:Extract() end
  elseif #MD.deconstructQueue > 0 then
    itemToDeconstruct = table.remove(MD.deconstructQueue)
    DebugMessage("Deconstructing: " .. itemToDeconstruct.itemLink)
    EVENT_MANAGER:RegisterForEvent(MD.name, EVENT_CRAFT_COMPLETED, MD.ContinueWork)
    if MD.isEnchanting then
      ExtractEnchantingItem(itemToDeconstruct.bagId, itemToDeconstruct.slotIndex)
    else
      SMITHING:AddItemToCraft(itemToDeconstruct.bagId, itemToDeconstruct.slotIndex)
      if not MD.isDebug then SMITHING.deconstructionPanel:Extract() end
    end
  else
    DebugMessage("Deconstruction done.")
    EVENT_MANAGER:UnregisterForEvent(MD.name, EVENT_CRAFT_COMPLETED) 
  end
end

function MD.StartDeconstruction() 
  if MD.isEnchanting then
    if ENCHANTING.enchantingMode ~= ENCHANTING_MODE_EXTRACTION then
      ENCHANTING:SetEnchantingMode(ENCHANTING_MODE_EXTRACTION)
    end
  else
    if SMITHING.mode ~= SMITHING_MODE_DECONSTRUCTION then
      SMITHING:SetMode(SMITHING_MODE_DECONSTRUCTION)
    end
  end
  
  BuildDeconstructionQueue()

  -- : reset counter
  if #MD.deconstructQueue > 0 then
    MD.ContinueWork()
  end
end

local function ShouldRefineItem(bagId, slotIndex, itemLink)
  local itemType = GetItemLinkItemType(itemLink)
  local name = GetItemName(bagId, slotIndex)
  local backpackCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
  local totalCount = backpackCount + bankCount + craftBagCount
  if totalCount == 27 then
    DebugMessage(zo_strformat("Should I refine <<2>> <<1>>? <<4>> is itemType <<3>>.", itemLink, totalCount, itemType, name))
  end
  if (
      itemType == ITEMTYPE_RAW_MATERIAL
      or (MD.isBlacksmithing and itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL)
      or (MD.isClothing and itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL)
      or (MD.isWoodworking and itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL)
      or (MD.isJewelryCrafting and itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL)
      or (MD.isJewelryCrafting and itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER)
      or (MD.isJewelryCrafting and itemType == ITEMTYPE_JEWELRY_RAW_TRAIT)
      ) then
    if totalCount >= GetRequiredSmithingRefinementStackSize() then
      return true
    end
  end
  return false
end

local function AddCraftingBagItemsToRefineQueue()
  local bagId = BAG_VIRTUAL
  DebugMessage("Checking crafting bag for refinable items")
  slotIndex = GetNextVirtualBagSlotId(nil)
  while slotIndex ~= nil do
    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
    if ShouldRefineItem(bagId, slotIndex, itemLink) then
      x = {}
      x.bagId = bagId
      x.slotIndex = slotIndex
      x.itemLink = itemLink
      table.insert(MD.refineQueue, x)
      DebugMessage("Refine queue length: " .. #MD.refineQueue)
    end
    slotIndex = GetNextVirtualBagSlotId(slotIndex)
  end
end

local function BuildRefiningQueue()
  MD.refineQueue = {}
  if HasCraftBagAccess() then
    AddCraftingBagItemsToRefineQueue()
  else
    DebugMessage("This account doesn't have a crafting bag")
  end
end

local function StackBigEnoughToRefine()
  local stackSize = SMITHING.refinementPanel.extractionSlot:GetStackCount()
  local refiningQuantity = GetRequiredSmithingRefinementStackSize()
  DebugMessage("Stack size: " .. stackSize .. ", Qty reqd: " .. refiningQuantity)
  return (stackSize >= refiningQuantity)
end

local function NeedsNewStack()
  if SMITHING.refinementPanel:IsExtractable() then
    if StackBigEnoughToRefine() then
      -- Current stack is fine
      return false
    end
  end
  -- Need a new stack
  return true
end

local function CleanupAfterRefining()
  SMITHING.refinementPanel:ClearSelections()
end

local function ProcessRefiningQueue()
  EVENT_MANAGER:UnregisterForEvent(MD.name, EVENT_CRAFT_COMPLETED)
  if NeedsNewStack() and #MD.refineQueue > 0 then
    DebugMessage('Selecting item to extract')
    local itemToRefine = table.remove(MD.refineQueue)
    SMITHING:AddItemToCraft(itemToRefine.bagId, itemToRefine.slotIndex)
  end
  if MD.isDebug then
    DebugMessage('(In debug mode. Check that a refinable quantity is about to be refined.)')
  elseif StackBigEnoughToRefine() then
    EVENT_MANAGER:RegisterForEvent(MD.name, EVENT_CRAFT_COMPLETED, ProcessRefiningQueue)
    SMITHING.refinementPanel:Extract()
  else
    DebugMessage('Nothing left to refine')
    CleanupAfterRefining()
  end
end

function MD.StartRefining()
  if MD.isEnchanting then
    return
  end
  if SMITHING.mode ~= SMITHING_MODE_REFINMENT then
    SMITHING:SetMode(SMITHING_MODE_REFINMENT)
    EVENT_MANAGER:RegisterForEvent(MD.name, EVENT_CRAFT_COMPLETED, ProcessRefiningQueue)
  end
  BuildRefiningQueue()
  if #MD.refineQueue > 0 then
    ProcessRefiningQueue()
  end
end

local function processSlashCommands(option)
  local options = {}
  local searchResult = { string.match(option,"^(%S*)%s*(.-)$") }
  for i,v in pairs(searchResult) do
    if (v ~= nil and v ~= "") then
      options[i] = string.lower(v)
    end
  end

  if options[1] == "test" then
    MD.test()
  end


end

function MD.test ()
end

function MD.OnCrafting(eventCode, craftingType)
  MD.isDebug = MD.settings.Debug
  if craftingType == CRAFTING_TYPE_CLOTHIER then
    MD.isClothing = true
  elseif craftingType == CRAFTING_TYPE_BLACKSMITHING then
    MD.isBlacksmithing = true
  elseif craftingType == CRAFTING_TYPE_WOODWORKING then
    MD.isWoodworking = true
  elseif craftingType == CRAFTING_TYPE_ENCHANTING then
    MD.isEnchanting = true
  elseif craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
    MD.isJewelryCrafting = true
  end

  if MD.isDebug then
    d('Checking station type')
    if MD.isClothing then
      d("MD Clothier")
    elseif MD.isBlacksmithing then
      d("MD Blacksmith")
    elseif MD.isWoodworking then
      d("MD Woodworker")
    elseif MD.isEnchanting then
      d("MD Enchanter")
   elseif MD.isJewelryCrafting then
      d("MD Jewelry Crafting")
    else
      d("MD unknown: " .. craftingType)
      return
    end
  end

  if MD.settings.Verbose and (MD.isBlacksmithing or MD.isClothing or MD.isWoodworking or MD.isEnchanting or MD.isJewelryCrafting). then
    BuildDeconstructionQueue()
    ListItemsInQueue()

    KEYBIND_STRIP:AddKeybindButtonGroup(MD.KeybindStripDescriptor)
    KEYBIND_STRIP:UpdateKeybindButtonGroup(MD.KeybindStripDescriptor)
  end
end

function MD.OnCraftEnd()
  MD.isBlacksmithing = false
  MD.isClothing = false
  MD.isWoodworking = false
  MD.isEnchanting = false
  MD.isJewelryCrafting = false
  if MD.isDebug then
    d("MD station leave")
  end
  KEYBIND_STRIP:RemoveKeybindButtonGroup(MD.KeybindStripDescriptor)
  EVENT_MANAGER:UnregisterForEvent(MD.name, EVENT_CRAFT_COMPLETED)
end

function MD:RegisterEvents()
  EVENT_MANAGER:RegisterForEvent(MD.name, EVENT_CRAFTING_STATION_INTERACT, MD.OnCrafting)
  EVENT_MANAGER:RegisterForEvent(MD.name, EVENT_END_CRAFTING_STATION_INTERACT, MD.OnCraftEnd)
end

--
-- This function that will initialize our addon with ESO
--
function MD.Initialize(event, addon)
  if addon ~= MD.name then return end
  SLASH_COMMANDS["/md"] = processSlashCommands

  EVENT_MANAGER:UnregisterForEvent("MassDeconstructorInitialize", EVENT_ADD_ON_LOADED)
  MD:RegisterEvents()
  -- load our saved variables
  MD.settings = ZO_SavedVars:New("MassDeconstructorSavedVars", 1, nil, MD.defaults)

  -- make a label for our keybinding
  ZO_CreateStringId("SI_BINDING_NAME_MD_DECONSTRUCTOR_DECON_ALL", "Mass Deconstruct")
  ZO_CreateStringId("SI_BINDING_NAME_MD_DECONSTRUCTOR_REFINE_ALL", "Mass Refine")

  -- make our options menu
  MD.MakeMenu()
  MD.KeybindStripDescriptor =
  {
    {
      name = GetString(SI_BINDING_NAME_MD_DECONSTRUCTOR_DECON_ALL),
      keybind = "MD_DECONSTRUCTOR_DECON_ALL",
      callback = function() MD.StartDeconstruction() end,
      visible = function() return MD.isClothing or MD.isBlacksmithing or MD.isWoodworking or MD.isEnchanting or MD.isJewelryCrafting end,
    },
    {
      name = GetString(SI_BINDING_NAME_MD_DECONSTRUCTOR_REFINE_ALL),
      keybind = "MD_DECONSTRUCTOR_REFINE_ALL",
      callback = function() MD.StartRefining() end,
      visible = function() return MD.isClothing or MD.isBlacksmithing or MD.isWoodworking or MD.isJewelryCrafting end,
    },
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
  }

  MD.isDebug = false
  MD.totalDeconstruct = 0
  MD.currentList = {}
  MD.deconstructQueue = {}
  MD.refineQueue = {}
  MD.itemToDeconstruct = nil
end


-- register our event handler function to be called to do initialization
EVENT_MANAGER:RegisterForEvent(MD.name, EVENT_ADD_ON_LOADED, function(...) MD.Initialize(...) end)
