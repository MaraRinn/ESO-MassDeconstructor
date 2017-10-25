local wm = GetWindowManager()
local em = GetEventManager()
local _

if MD == nil then MD = {} end
local LII = LibStub:GetLibrary("LibItemInfo-1.0")

MD.name = "MassDeconstructor"
MD.version = "2.0"

MD.settings = {}

MD.defaults = {
  DeconstructOrnate = false,
  DeconstructBound = false,
  DeconstructSetPiece = false,
  Debug = false,
  MassRefineEnabled = false,
  BankMode = false,
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
}

MD.Inventory = {
  items = { },
  clothier = { },
  blacksmith = { },
  enchanter = { },
  woodworker = { },
}
MD.refining = {}

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

  --FCO ItemSaver support
  if FCOIsMarked then
    --Old FCOIS version < 1.0
    if FCOIsMarked and FCOIsMarked(GetItemInstanceId(bagId, slotId), {1,2,3,4,5,6,7,8,10,11,12}) then -- 9 is deconstruct
      return true
    end
  elseif FCOIS and FCOIS.IsDeconstructionLocked then
    --New for FCOIS version >= 1.0
    return FCOIS.IsDeconstructionLocked(bagId, slotId)
  end

  --FilterIt support
  if FilterIt and FilterIt.AccountSavedVariables and FilterIt.AccountSavedVariables.FilteredItems then
    local sUniqueId = Id64ToString(GetItemUniqueId(bagId, slotId))
    if FilterIt.AccountSavedVariables.FilteredItems[sUniqueId] then
      return FilterIt.AccountSavedVariables.FilteredItems[sUniqueId] ~= FILTERIT_VENDOR
    end
  end

  return false
end

function MD:IsOrnate(bagId,slotId)
  return GetItemTrait(bagId,slotId) == ITEM_TRAIT_TYPE_ARMOR_ORNATE or GetItemTrait(bagId,slotId) == ITEM_TRAIT_TYPE_WEAPON_ORNATE
end

function MD:isItemBindable(bagId, slotIndex)
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

function MD.addStuffToInventoryForBag(bagId)
  local GetItemType = GetItemType
  local GetItemInfo = GetItemInfo
  local zo_strformat = zo_strformat
  local GetItemName = GetItemName
  local bagSize = GetBagSize(bagId)
  local usableBagSize = GetBagUseableSize(bagId)
  local bagSlots = GetBagSize(bagId) -1
  for slotIndex = 0, bagSlots do
    local itemType = GetItemType(bagId, slotIndex)
    local _, stack, _, _, _, equipType , _, quality = GetItemInfo(bagId, slotIndex)
    local name = GetItemName(bagId, slotIndex)
    local continue_ = true
    local itemLink = GetItemLink(bagId, slotIndex)
    local _, CraftingSkillType = LII:GetResearchInfo(bagId, slotIndex)
    local isProtected = IsItemProtected(bagId, slotIndex)
    local isOrnated = MD:IsOrnate(bagId, slotIndex)
    local boundType = MD:isItemBindable(bagId, slotIndex)
    local bagCount, bankCount, craftCount = GetItemLinkStacks(itemLink)
    local isSetPc = isSetPiece(itemLink)
    local iTraitType = GetItemLinkTraitInfo(itemLink)
    local isIntricate = iTraitType == 9 or iTraitType == 20
    local isGlyph = LII:IsGlyph(bagId, slotIndex)
    -- is protected skip
    if continue_ then 
      if isProtected then
        continue_ = false
      end 
    end 

    if continue_ then
      if CraftingSkillType == CRAFTING_TYPE_INVALID and isGlyph == false then
        continue_ = false
      end
    end

    -- check settings and skip if bounded
    if continue_ then
      if not MD.settings.DeconstructBound then
        if boundType == 1 then
          continue_ = false
        end
      end
    end

    -- check settings and skip ornate
    if continue_ then 
      if not MD.settings.DeconstructOrnate then
        if isOrnated then
          continue_ = false
        end
      end
    end

    if continue_ then
      if not MD.settings.DeconstructSetPiece and isSetPc then
        continue_ = false
      end
    end
 
    -- check settings maxQuality and skip if greater
    if continue_ then
      if CraftingSkillType == CRAFTING_TYPE_CLOTHIER then
        if quality > MD.settings.Clothing.maxQuality then
          continue_ = false
        end
        if isIntricate and not MD.settings.Clothing.DeconstructIntricate then
          continue_ = false
        end
      elseif CraftingSkillType == CRAFTING_TYPE_BLACKSMITHING then
        if quality > MD.settings.Blacksmithing.maxQuality then
          continue_ = false
        end
        if isIntricate and not MD.settings.Blacksmithing.DeconstructIntricate then
          continue_ = false
        end
      elseif CraftingSkillType == CRAFTING_TYPE_WOODWORKING then 
        if quality > MD.settings.Woodworking.maxQuality then
          continue_ = false
        end
        if isIntricate and not MD.settings.Woodworking.DeconstructIntricate then
          continue_ = false
        end
      elseif isGlyph then
        if quality > MD.settings.Enchanting.maxQuality then
          continue_ = false
        end
        if isIntricate and not MD.settings.Enchanting.DeconstructIntricate then
          continue_ = false
        end
      end
    end

    if continue_ then
      name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
      if MD.isDebug then
        d(string.format("%s - %s" , itemLink, iTraitType))
        --d(isSetPc)
        --.."-"..stack.."-"..bagCount.."-"..bankCount)
        --  d(quality)
        --d(boundType)
        --d("|caaaaaa-----------|r")
      end
      n = {}
      n.bagId = bagId
      n.slotIndex = slotIndex
      n.stack = bagCount + bankCount

      if (CraftingSkillType == CRAFTING_TYPE_CLOTHIER) then
        if MD.Inventory.clothier[itemLink] == nil then
          MD.Inventory.clothier[itemLink] = n
        end
      elseif (CraftingSkillType == CRAFTING_TYPE_BLACKSMITHING) then
        if MD.Inventory.blacksmith[itemLink] == nil then
          MD.Inventory.blacksmith[itemLink] = n
        end
      elseif (CraftingSkillType == CRAFTING_TYPE_WOODWORKING) then
        if MD.Inventory.woodworker[itemLink] == nil then
          MD.Inventory.woodworker[itemLink] = n
        end
      elseif (isGlyph) then
        if MD.Inventory.enchanter[itemLink] == nil then
          MD.Inventory.enchanter[itemLink] = n
        end
      end
      --   end
    end
  end
end

function MD.PrepareForDeconstruction() 
  MD.setCurrentListForWorkstation()
  for itemLink, _ in pairs(MD.currentList) do
    d("|cff0000Deconstructable:|r "..itemLink)
  end
end

function MD.setCurrentListForWorkstation()
  if MD.isClothing then
    MD.currentList = MD.Inventory.clothier
  elseif MD.isBlacksmithing then
    MD.currentList = MD.Inventory.blacksmith
  elseif MD.isWoodworking then
    MD.currentList = MD.Inventory.woodworker
  elseif MD.isEnchanting then
    MD.currentList = MD.Inventory.enchanter
  end
end  

function MD.startDeconstruction() 
  if MD.isEnchanting then
    if ENCHANTING.enchantingMode ~= ENCHANTING_MODE_EXTRACTION then
      ENCHANTING:SetEnchantingMode(ENCHANTING_MODE_EXTRACTION)
    end
  else
    if SMITHING.mode ~= SMITHING_MODE_DECONSTRUCTION then
      SMITHING:SetMode(SMITHING_MODE_DECONSTRUCTION)
    end
  end

  -- : refrest list for getting count
  MD.updateStuffofInventory()
  MD.setCurrentListForWorkstation()

  -- : reset counter
  MD.totalDeconstruct = 0
  for itemLink, tablosu in pairs( MD.currentList ) do
    MD.totalDeconstruct = MD.totalDeconstruct + tablosu.stack
  end
  d("Destructable item count: |cff0000"..(MD.totalDeconstruct).."|r")
  MD.deconstructQueue = {}
  for itemLink, tablosu in pairs( MD.currentList ) do
    table.insert(MD.deconstructQueue, tablosu)
    DebugMessage("bagId:"..tablosu.bagId.."  slot:".. tablosu.slotIndex)
  end
  if #MD.deconstructQueue > 0 then
    MD.ContinueWork()
  end
end

function MD.ContinueWork()
  EVENT_MANAGER:UnregisterForEvent(MD.name, EVENT_CRAFT_COMPLETED)
  itemToDeconstruct = table.remove(MD.deconstructQueue)
  if MD.isEnchanting then
    ExtractEnchantingItem(itemToDeconstruct.bagId, itemToDeconstruct.slotIndex)
  else
    SMITHING:AddItemToCraft(itemToDeconstruct.bagId, itemToDeconstruct.slotIndex)
    if not MD.isDebug then SMITHING.deconstructionPanel:Extract() end
  end
  if #MD.deconstructQueue > 0 or SMITHING.refinementPanel.extractionSlot:HasItem() then
    EVENT_MANAGER:RegisterForEvent(MD.name, EVENT_CRAFT_COMPLETED, MD.ContinueWork)
  end
  DebugMessage("Deconstruct queue count: "..#MD.deconstructQueue)
end

function MD.updateStuffofInventory()
  MD.Inventory = {
    items = { },
    clothier = { },
    blacksmith = { },
    enchanter = { },
    woodworker = { },
  }

  MD.addStuffToInventoryForBag(BAG_BACKPACK)
  if MD.settings.BankMode then 
    -- subscribers get extra bank space
    if IsESOPlusSubscriber() then MD.addStuffToInventoryForBag(BAG_SUBSCRIBER_BANK) end
    -- regular bank
    MD.addStuffToInventoryForBag(BAG_BANK)
  end

end

local function ShouldRefineItem(bagId, slotIndex, itemLink)
  itemType = GetItemLinkItemType(itemLink)
  if (
      itemType == ITEMTYPE_RAW_MATERIAL
      or (MD.isBlacksmithing and itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL)
      or (MD.isClothing and itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL)
      or (MD.isWoodworking and itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL)
      ) then
    local name = GetItemName(bagId, slotIndex)
    local backpackCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
    local totalCount = backpackCount + bankCount + craftBagCount
    DebugMessage(zo_strformat("Should I refine <<2>> <<1>>?", itemLink, totalCount))
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
      slotIndex = GetNextVirtualBagSlotId(slotIndex)
      local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
      if ShouldRefineItem(bagId, slotIndex, itemLink) then
        x = {}
        x.bagId = bagId
        x.slotIndex = slotIndex
        x.itemLink = itemLink
        table.insert(MD.refineQueue, x)
        DebugMessage("Refine queue length: " .. #MD.refineQueue)
      end
    end
end

local function BuildRefiningQueue()
  MD.refineQueue = {}
  if HasCraftBagAccess() then
    AddCraftingBagItemsToRefineQueue()
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
    if StackBigEnoughToRefine then
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
    DebugMessage('(In debug mode. Check that item being refined.)')
  else
    SMITHING.refinementPanel:Extract()
  end
  if StackBigEnoughToRefine() then
    EVENT_MANAGER:RegisterForEvent(MD.name, EVENT_CRAFT_COMPLETED, ProcessRefiningQueue)
  else
    DebugMessage('Nothing left to refine')
    CleanupAfterRefining()
  end
end

function MD.StartRefining()
  if not MD.massRefineEnabled then
    d('Mass Refine is a beta feature. Please enable it in settings at your own risk.')
    return false
  end
  if MD.isEnchanting then
    return
  end
  if SMITHING.mode ~= SMITHING_MODE_REFINMENT then
    SMITHING:SetMode(SMITHING_MODE_REFINEMENT)
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

  if options[1] == "mk" then
    MD.updateStuffofInventory()
  elseif options[1] == "test" then
    MD.test()
  end


end

function MD.test ()
end

function MD.OnCrafting(eventCode, craftingType)
  MD.isDebug = MD.settings.Debug
  MD.massRefineEnabled = MD.settings.MassRefineEnabled
  MD.isStation = 0
  if craftingType == CRAFTING_TYPE_CLOTHIER then
    MD.isStation = 1
    MD.isClothing = true
  elseif craftingType == CRAFTING_TYPE_BLACKSMITHING then
    MD.isStation = 2
    MD.isBlacksmithing = true
  elseif craftingType == CRAFTING_TYPE_WOODWORKING then
    MD.isStation = 3
    MD.isWoodworking = true
  elseif craftingType == CRAFTING_TYPE_ENCHANTING then
    MD.isStation = 4
    MD.isEnchanting = true
  else
    return
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
    end
  end
  KEYBIND_STRIP:AddKeybindButtonGroup(MD.KeybindStripDescriptor)
  KEYBIND_STRIP:UpdateKeybindButtonGroup(MD.KeybindStripDescriptor)
  MD.updateStuffofInventory() 
  MD:PrepareForDeconstruction()
end

function MD.OnCraftEnd()
  MD.isStation = 0
  MD.isBlacksmithing = false
  MD.isClothing = false
  MD.isWoodworking = false
  MD.isEnchanting = false
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
  -- filter for just HWS addon event
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
    { -- I think you can have more than one button in your group if you add more of these sub-groups
      name = GetString(SI_BINDING_NAME_MD_DECONSTRUCTOR_DECON_ALL),
      keybind = "MD_DECONSTRUCTOR_DECON_ALL",
      callback = function() MD.startDeconstruction() end,
      visible = function() return true end,
    },
    {
      name = GetString(SI_BINDING_NAME_MD_DECONSTRUCTOR_REFINE_ALL),
      keybind = "MD_DECONSTRUCTOR_REFINE_ALL",
      callback = function() MD.StartRefining() end,
      visible = function() return not MD.isEnchanting end,
    },
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
  }

  MD.isDebug = false
  MD.isStation = 0
  MD.totalDeconstruct = 0
  MD.currentList = {}
  MD.deconstructQueue = {}
  MD.refineQueue = {}
  MD.itemToDeconstruct = nil
  MD.massRefineEnabled = false
end


-- register our event handler function to be called to do initialization
em:RegisterForEvent(MD.name, EVENT_ADD_ON_LOADED, function(...) MD.Initialize(...) end)
