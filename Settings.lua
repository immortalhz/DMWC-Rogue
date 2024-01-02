local DMW = DMW
DMW.Rotations.ROGUE = {}
local Rogue = DMW.Rotations.ROGUE
local UI = DMW.UI

local optN = 0
local function getOptionNumber()
  optN = optN + 1
  return optN
end

function Rogue.Settings()
  DMW.Helpers.Rotation.CastingCheck = false
  UI.HUD.Options = {}
  UI.HUD.Options[getOptionNumber()] = {
    Defensive = {
      [1] = { Text = "|cFF00FF00Defensives On", Tooltip = "" },
      [2] = { Text = "|cFFFFFF00No Defensives", Tooltip = "" }
    }
  }
  UI.HUD.Options[getOptionNumber()] = {
    Info = {
      [1] = { Text = "", Tooltip = "" },
      [2] = { Text = "|cffFF4500Explosives", Tooltip = "" },
      [3] = { Text = "|cffFF4500Holding AoE", Tooltip = "" }
    }
  }
  UI.HUD.Options[getOptionNumber()] = {
    CCMode = {
      [1] = { Text = "|cFF00FF00Enabled CC", Tooltip = "" },
      [2] = { Text = "|cffffffffWhiteList CC", Tooltip = "" },
      [3] = { Text = "no CC", Tooltip = "" }
    }
  }
  if DMW.Player.SpecID == "Outlaw" then
    UI.HUD.Options[getOptionNumber()] = {
      BFMode = {
        [1] = { Text = "|cFF00FF00Auto BF", Tooltip = "" },
        [2] = { Text = "Manual BF", Tooltip = "" }
      }
    }

    if DMW.Player.Talents.GhostlyStrike then
      UI.HUD.Options[getOptionNumber()] = {
        GhostlyStrike = {
          [1] = { Text = "|cFF00FF00Ghostly", Tooltip = "" },
          [2] = { Text = "Ghostly", Tooltip = "" }
        }
      }
    end
    UI.HUD.Options[getOptionNumber()] = {
      BladerushMode = {
        [1] = { Text = "|cFF00FF00 Bladerush", Tooltip = "" },
        [2] = { Text = "Bladerush", Tooltip = "" }
      }
    }
    if DMW.Player.Talents.ShadowDance then
      UI.HUD.Options[getOptionNumber()] = {
        ShadowDance = {
          [1] = { Text = "|cFF00FF00 ShD", Tooltip = "" },
          [2] = { Text = "no ShD", Tooltip = "" }
        }
      }
    end
    UI.HUD.Options[getOptionNumber()] = {
      VanishMode = {
        [1] = { Text = "|cFF00FF00 Vanish", Tooltip = "" },
        [2] = { Text = "Vanish", Tooltip = "" }
      }
    }
  elseif DMW.Player.SpecID == "Assassination" then
    UI.HUD.Options[getOptionNumber()] = {
      PriorityMode = { [1] = { Text = "|cFF00FF00Priority", Tooltip = "" },
        [2] = { Text = "AoE", Tooltip = "" } }
    }
    UI.HUD.Options[getOptionNumber()] = {
      TierSevenMode = { [1] = { Text = "|cFF00FF00TB/Exsang", Tooltip = "" },
        [2] = { Text = "TB/Exsang", Tooltip = "" } }
    }
    UI.HUD.Options[getOptionNumber()] = {
      VendettaMode = { [1] = { Text = "|cFF00FF00Vendetta Enabled", Tooltip = "" },
        [2] = { Text = "No Vendetta", Tooltip = "" } }
    }
    UI.HUD.Options[getOptionNumber()] = {
      VanishMode = { [1] = { Text = "|cFF00FF00Vanish Enabled", Tooltip = "" },
        [2] = { Text = "No Vanish", Tooltip = "" } }
    }
    -- UI.HUD.Options[getOptionNumber()] = {
    --     CCMode = {
    --         [1] = { Text = "|cFF00FF00Enabled CC", Tooltip = "" },
    --         [2] = { Text = "|cffffffffWhiteList CC", Tooltip = "" },
    --         [3] = { Text = "no CC", Tooltip = "" }
    --     }
    -- }
  elseif DMW.Player.SpecID == "Subtlety" then
    UI.HUD.Options[getOptionNumber()] = {
      PriorityMode = {
        [1] = { Text = "|cFF00FF00Priority Target", Tooltip = "" },
        [2] = { Text = "|cFF00FF00Priority HighestHP", Tooltip = "" },
        [3] = { Text = "AoE", Tooltip = "" }
      }
    }
    UI.HUD.Options[getOptionNumber()] = {
      RuptureMode = {
        [1] = { Text = "|cFF00FF00Rupture", Tooltip = "" },
        [2] = { Text = "No Rupture", Tooltip = "" }
      }
    }
    UI.HUD.Options[getOptionNumber()] = {
      VanishMode = {
        [1] = { Text = "|cFF00FF00 Vanish", Tooltip = "" },
        [2] = { Text = "Vanish", Tooltip = "" }
      }
    }
    -- UI.HUD.Options[getOptionNumber()] = {
    --   CCMode = {
    --     [1] = { Text = "|cFF00FF00Enabled CC", Tooltip = "" },
    --     [2] = { Text = "|cffffffffWhiteList CC", Tooltip = "" },
    --     [3] = { Text = "no CC", Tooltip = "" }
    --   }
    -- }
    UI.HUD.Options[getOptionNumber()] = {
      BurstMode = {
        [1] = { Text = "|cFF00FF00Burst", Tooltip = "" },
        [2] = { Text = "Burst", Tooltip = "" }
      }
    }
    -- UI.HUD.Options[4] = {
    --     RollMode = {
    --         [1] = {Text = "|cFF00FF00Simc rolls", Tooltip = ""},
    --         [2] = {Text = "Roll for one", Tooltip = ""}
    --     }
    -- }
    -- UI.HUD.Options[5] = {
    --     CCMode = {
    --         [1] = {Text = "|cFF00FF00Enabled CC", Tooltip = ""},
    --         [2] = {Text = "no cc", Tooltip = ""}
    --     }
    -- }
  end
  if DMW.Player.Talents.MarkedForDeath then
    UI.HUD.Options[getOptionNumber()] = {
      MFD = { [1] = { Text = "|cFF00FF00MFD reset", Tooltip = "" },
        [2] = { Text = "MFD any", Tooltip = "" } }
    }
  end
  UI.AddHeader("General Options")

  -- UI.AddToggle("Follow Target", nil, false)

  UI.AddToggle("Pooling for SD/Vanish", nil, false)
  UI.AddToggle("PreRoll", nil, false)
  UI.AddHeader("Poisons")
  UI.AddDropdown("MH", "", { "Disable", "Wound", "Instant" }, 1)
  UI.AddDropdown("OH", "", { "Disable", "Crippling", "Numbing", "Atrophic" }, 1)
  UI.AddHeader("")
  UI.AddToggle("Dont open from Stealth", nil, false)
  if DMW.Player.SpecID == "Outlaw" then
    UI.AddToggle("BTE HP Check", nil, false)
    UI.AddToggle("IgnoreFTH", nil, false)
    -- UI.AddToggle("FastBladeFlurry", nil, false)
    UI.AddToggle("BladeRush", nil, false)
    UI.AddRange("BladeRush on AOE targets", "Will use if Enemy Count >=", 0, 20, 1, 0)
  elseif DMW.Player.SpecID == "Assassination" then
    UI.AddToggle("FOK when Envenom up", nil, false)
    UI.AddToggle("FOK when EP up", nil, false)
    UI.AddToggle("CrimsonTempest ST", nil, false)
    UI.AddToggle("HoldGarrotesOnPull", "Hold default Garrotes on AoE", false)
  end
  UI.AddToggle("Always Take Care of Explosives", nil, false)
  UI.AddToggle("AutoTarget", nil, false)
  UI.AddDropdown("Tricks", "", { "Disable", "Focus", "Tank" }, 1)
  UI.AddToggle("Tricks On CD", nil, false)
  UI.AddToggle("Tricks once in Combat", nil, false)
  UI.AddDropdown("Pot", "", { "Disable", "Agility", "ST" }, 1)
  UI.AddTab("Stealth")
  UI.AddHeader("Stealth Options")
  UI.AddDropdown("Auto Stealth", "", { "Disable", "Enemy in 20 yards", "Always" }, 1)
  if DMW.Player.SpecID == "Outlaw" then
    UI.AddDropdown("Ambush", "Will Use Ambush if Target", { "Disable", "In Combat", "Always" }, 1)
    -- UI.AddToggle("Vanish on ST", nil, false)
  end
  UI.AddTab("Cooldowns")
  -- UI.AddHeader("Use CDS When TTD > ")
  UI.AddToggle("Use Trinkets on CD")
  UI.AddToggle("Racials")
  if DMW.Player.SpecID == "Assassination" then
    UI.AddRange("Vendetta", "", 0, 100, 1, 15)
    UI.AddRange("Vendetta Enemies", "Will use if Enemy Count <=", 0, 100, 1, 5)
    UI.AddRange("Toxic Blade", "", 0, 100, 1, 5)
    UI.AddRange("Toxic Blade Enemies", "Will use if Enemy Count <=", 0, 100, 1, 3)
    UI.AddHeader("Use CDS When TTD > ")
    UI.AddRange("Vanish", "", 0, 100, 1, 15)
  elseif DMW.Player.SpecID == "Subtlety" then
    UI.AddDropdown("ShadowBlades", nil, { "Disable", "On Bosses", "Always" }, 1)
    UI.AddToggle("KeepOneVanishSub", nil, false)
    UI.AddDropdown("Tea Usage", nil, { "Disable", "AoE only", "Always" }, 3)
  end
  -- UI.AddTab("Essences")
  -- UI.AddToggle("Auto BEAM", nil, false)
  -- UI.AddToggle("AutoBeamAngle", nil, false)
  -- UI.AddToggle("BOTE Auto", nil, false)
  UI.AddTab("Trinkets")
  UI.AddToggle("General Usage", nil, false)
  UI.AddTab("Defensives")
  UI.AddHeader("Player HP to Use")
  UI.AddRange("Crimson Vial", "", 0, 100, 10, 0)
  UI.AddRange("HealthStone", "", 0, 100, 10, 0)
  UI.AddRange("HealingPot", "", 0, 100, 10, 0)
  UI.AddRange("Evasion", "", 0, 100, 10, 0)
  UI.AddRange("Feint", "", 0, 100, 10, 0)
  UI.AddRange("Cloak", "", 0, 100, 10, 0)
  UI.AddTab("CC Options")
  UI.AddHeader("Use following To Interrupt Spells")
  UI.AddToggle("AutoKick", nil, false)
  UI.AddToggle("AutoBlind", nil, false)
  if DMW.Player.SpecID == "Outlaw" then UI.AddToggle("AutoGouge", nil, false) end
  UI.AddToggle("AutoCheapShot", nil, false)
  UI.AddToggle("AutoCheapShot Cds", nil, false)
  UI.AddToggle("AutoKidney", nil, false)
  UI.AddToggle("Any Cast", nil, false)
  UI.AddTextBox("WhiteList CC", true, true)
  UI.AddRange("Delay", nil, 0, 5, 0.1, 1)
  UI.AddToggle("Delay for CC", nil, false)
  UI.AddTab("M+ Logics")
  -- UI.AddToggle("Piggie FH", nil, false)
  UI.AddToggle("Use Logics", nil, false)
  UI.AddToggle("CC Spiteful", nil, false)
end
