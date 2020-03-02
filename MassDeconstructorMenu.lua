-- sentry to make sure HWS is declared before use
if MD == nil then MD = {} end

--
-- Register with LibMenu and ESO
--
function MD.MakeMenu()
  -- load the settings->addons menu library
  local menu = LibAddonMenu2
  local set = MD.settings

  -- the panel for the addons menu
  local panel = {
    type = "panel",
    name = "Mass Deconstructor",
    displayName = "Mass Deconstructor",
    author = "Ahmet `Amad` Ertem",
    version = MD.version,
  }

  -- this addons entries in the addon menu
  local options = {
    {
      type = "checkbox",
      name = "Deconstruct items in bank",
      getFunc = function() return set.BankMode end,
      setFunc = function(value) set.BankMode = value end,
    },
    {
      type = "checkbox",
      name = "Deconstruct bound items",
      getFunc = function() return set.DeconstructBound end,
      setFunc = function(value) set.DeconstructBound = value end,
    },
    {
      type = "checkbox",
      name = "Deconstruct set pieces",
      getFunc = function() return set.DeconstructSetPiece end,
      setFunc = function(value) set.DeconstructSetPiece = value end,
    },
    {
      type = "checkbox",
      name = "Deconstruct ornate items",
      getFunc = function() return set.DeconstructOrnate end,
      setFunc = function(value) set.DeconstructOrnate = value end,
    },
    {
    	type = "checkbox",
    	name = "Deconstruct crafted items",
    	getFunc = function() return set.DeconstructCrafted end,
    	setFunc = function(value) set.DeconstructCrafted = value end,
    },
    {
    	type = "checkbox",
    	name = "List items before starting work",
    	getFunc = function() return set.Verbose end,
    	setFunc = function(value) set.Verbose = value end,
    },
    {
      type = "checkbox",
      name = "Debug",
      getFunc = function() return set.Debug end,
      setFunc = function(value) set.Debug = value end,
    },
    {
      type = "submenu",
      name = "Clothing Options",
      controls = {
        {
          type = "slider",
          name = "Maximum item quality to deconstruct",
          tooltip = "Maximum quality at which items will be destroyed (1 = white, 5 = legendary)",
          min = 1, 
          max = 5, 
          getFunc = function() return set.Clothing.maxQuality end,
          setFunc = function( maxQuality ) set.Clothing.maxQuality = maxQuality end,
        },
        {
          type = "checkbox",
          name = "Deconstruct intricate items",
          getFunc = function() return set.Clothing.DeconstructIntricate end,
          setFunc = function(value) set.Clothing.DeconstructIntricate = value end,
        },
      },
    },
    {
      type = "submenu",
      name = "Blacksmithing Options",
      controls = {
        {
          type = "slider",
          name = "Maximum item quality to deconstruct",
          tooltip = "Maximum quality at which items will be destroyed (1 = white, 5 = legendary)",
          min = 1, 
          max = 5, 
          getFunc = function() return set.Blacksmithing.maxQuality end,
          setFunc = function( maxQuality ) set.Blacksmithing.maxQuality = maxQuality end,
        },
        {
          type = "checkbox",
          name = "Deconstruct intricate items",
          getFunc = function() return set.Blacksmithing.DeconstructIntricate end,
          setFunc = function(value) set.Blacksmithing.DeconstructIntricate = value end,
        },
      },
    },
    {
      type = "submenu",
      name = "Woodworking Options",
      controls = {
        {
          type = "slider",
          name = "Maximum item quality to deconstruct",
          tooltip = "Maximum quality at which items will be destroyed (1 = white, 5 = legendary)",
          min = 1, 
          max = 5, 
          getFunc = function() return set.Woodworking.maxQuality end,
          setFunc = function( maxQuality ) set.Woodworking.maxQuality = maxQuality end,
        },
        {
          type = "checkbox",
          name = "Deconstruct intricate items",
          getFunc = function() return set.Woodworking.DeconstructIntricate end,
          setFunc = function(value) set.Woodworking.DeconstructIntricate = value end,
        },
      },
    },
    {
      type = "submenu",
      name = "Enchanting Options",
      controls = {
        {
          type = "slider",
          name = "Maximum item quality to deconstruct",
          tooltip = "Maximum quality at which items will be destroyed (1 = white,5  = legendary)",
          min = 1, 
          max = 5, 
          getFunc = function() return set.Enchanting.maxQuality end,
          setFunc = function( maxQuality ) set.Enchanting.maxQuality = maxQuality end,
        },
        {
          type = "checkbox",
          name = "Deconstruct intricate items",
          getFunc = function() return set.Enchanting.DeconstructIntricate end,
          setFunc = function(value) set.Enchanting.DeconstructIntricate = value end,
        },
      },
    },
    {
      type = "submenu",
      name = "Jewelrycrafting Options",
      controls = {
        {
          type = "slider",
          name = "Maximum item quality to deconstruct",
          tooltip = "Maximum quality at which items will be destroyed (1 = white, 5 = legendary)",
          min = 1,
          max = 5,
          getFunc = function() return set.JewelryCrafting.maxQuality end,
          setFunc = function(value) set.JewelryCrafting.maxQuality = value end,
        },
        {
          type = "checkbox",
          name = "Deconstruct intricate items",
          getFunc = function() return set.JewelryCrafting.DeconstructIntricate end,
            setFunc = function(value) set.JewelryCrafting.DeconstructIntricate = value end,
        },
      },
    },

  }

  menu:RegisterAddonPanel("MassDeconstructor", panel)
  menu:RegisterOptionControls("MassDeconstructor", options)
end