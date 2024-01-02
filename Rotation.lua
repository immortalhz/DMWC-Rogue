local DMW = DMW
local Rogue = DMW.Rotations.ROGUE
local Rotation = DMW.Helpers.Rotation
local Unlocked = DMW.Functions.Unlocked
local Setting = DMW.Helpers.Rotation.Setting
local Player, Buff, Debuff, Spell, Stance, Target, Talent, Item, GCD, CDs, HUD, EnemyMelee, EnemyMeleeCount, Enemy10Y, Enemy10YC, Enemy30Y,
Enemy30YC, stealthedRogue, pauseTime, AssassinationOpener, sndCondition, usePriorityRotation, forceStealthed, stopAttacking,
ShDthreshold, SkipRupture, ComboPoints, bfTTD, shadowDanced, shadowDancedTime, vanished, vanishedTime, thistleTeaed, thistleTeaedTime, tornadoTime, needBTErefresh
local ShouldReturn
local forceroll = false
local TricksCombat = true
DMW.Player.RtbCount = 0
local vanishambush = false
local fhbossPool = false
local brRange = 8
local bfTTDvalue = 4
local RuptureHP = 15 * 3 * 60 * 1000
-- local oldCP = 0
RtbCacheTime = 0

local reportTable = {

}
-- DMW.Helpers.Swing.InitSwingTimer()

local function report(what, ended)
  if reportTable[what] == nil and not ended then
    reportTable[what] = DMW.Time
    print(what .. " starts")
  end
  if ended and reportTable[what] then
    print(what .. " took " .. string.format("%0.1f", DMW.Time - reportTable[what]))
    reportTable[what] = nil
  end
end

local function highestBTE()
  local highestSec
  for _, Unit in ipairs(EnemyMelee) do
    if Debuff.BetweenTheEyes:Exist(Unit) then
      local remainCurrent = Debuff.BetweenTheEyes:Remain(Unit)
      if highestSec == nil or remainCurrent < highestSec then
        highestSec = remainCurrent
      end
    end
  end
  return highestSec or 0
end

local rtbcacheSpells = {
  [315508] = true,
  [193356] = true,
  [193358] = true,
  [193357] = true,
  [199603] = true,
  [193359] = true,
  [199600] = true
}
local cloakPlayerlist = {
  [256106] = true, -- FH 1st boss
  [261439] = true, -- Virulent Pathogen WM
  [261440] = true, -- Virulent Pathogen WM
  [265773] = true  -- Spit Gold KR
}
local evasionPlayerlist = {
  -- [256979] = true, -- pewpew council boss
  [266231] = true -- Severing Axe KR
  -- [256106] = true
}
local feintPlayerList = {
  [256979] = true -- Powder shot FH 2nd
}
local cloaklist = {
  [119300] = true -- test rfc 2
}
local evasionlist = {}
local feintlist = {
  -- [2561066] = true -- FH 1st boss
}
local turtleBuffs = {}
local pveDR = {
  [272659] = true -- ToS lighningh shield thrash
}
local torrentDispell = {}
local vanishList = {
  [260551] = true, -- Soul Thorns WM
  [261440] = true, -- Virulent Pathogen WM
  [266231] = true, -- Severing Axe KR
  [258338] = true, -- Barrel fh 2nd boss
  [263371] = true, -- conduction
  [260741] = true  -- nettles wm
}

local stunList = {
  -- Stolen from feng pala
  [268202] = true, -- WM Last boss death lens
  [274400] = true, -- Duelist Dash fh
  -- [274383] = true, -- Rat Traps fh
  [276292] = true, -- Whirling Slam SotS
  [268273] = true, -- Deep Smash SotS
  [256897] = true, -- Clamping Jaws SoB
  [256957] = true,
  [272542] = true, -- Ricochet SoB
  [272888] = true, -- Ferocity SoB
  -- [269266] = true, -- Slam SoB ????????? tentacle last bos?
  [258864] = true, -- Suppression Fire TD
  -- [259711] = true, -- Lockdown TD
  [264038] = true, -- Uproot WM
  [253239] = true, -- Merciless Assault AD
  [256849] = true, -- Dino Heal AD
  [269931] = true, -- Gust Slash KR ????????
  [270084] = true, -- Axe Barrage KR
  [270506] = true, -- Deadeye Shot KR
  [270507] = true, -- Poison Barrage KR
  -- [267433] = true, -- Activate Mech ML ????????????
  [267354] = true, -- Hail of Flechettes ML
  [269302] = true, -- Poison thrash ML
  [268702] = true, -- Furious Quake ML
  [268846] = true, -- Echo Blade ML
  [268865] = true, -- Force Cannon ML
  [258908] = true, -- Blade Flurry ToS
  [264574] = true, -- Power Shot ToS
  [272655] = true, -- Scouring Sand ToS
  -- [277567] = true, -- infest
  [265542] = true, -- Rotten Bile UR
  [265540] = true, -- Rotten Bile UR
  [257641] = true, -- molten slug
  [265376] = true, -- UR spear
  [257736] = true, -- Thundering Squall FH
  [257870] = true, -- Blade Barrage FH
  [268797] = true, -- ML Transmute: Enemy to Goo
  [263066] = true, -- ML Transfiguration Serum
  [265089] = true, -- Dark Reconstitution UR
  [272183] = true, -- Raise Dead UR
  [258153] = true, -- Watery Dome Td
  [278504] = true  -- Ritual WM
  -- [257397] = true   -- Healing Balm AD
}
-- local kickList = {
-- }
local channelAsapList = {
  [257756] = true, -- Goin' Bananas FH
  [253721] = true, -- Bulwark of Juju AD
  -- [259572] = true, -- 2nd AD channel
  [258317] = true, -- Riot Shield TD ???? only magic
  [258917] = true, -- Righteous Flames TD
  [267357] = true, -- Hail of Flechettes ML
  [267237] = true, -- Drain ToS
  [265568] = true, -- Dark Omen UR
  [265540] = true, -- Rotten Bile UR
  [257641] = true, -- molten slug
  [265542] = true, -- Rotten Bile UR
  [265376] = true, -- barbed spear
  [267354] = true  -- Hail of Flechettes ML
  -- [256060] = true
}
local channelLateList = {
  [257739] = true, -- Fixate FH
  [270839] = true  -- test
}

-- local frame = CreateFrame("FRAME")
-- -- local piggiecatch
-- frame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
-- function frame:OnEvent(event, arg1, arg2, arg3)
--     if arg2 == "Гаргток" or arg2 == "Gurgthock" and not piggiecatch then piggiecatch = true end
-- end
-- frame:SetScript("OnEvent", frame.OnEvent)

SLASH_FORCEROLL1 = "/forceroll"
SlashCmdList["FORCEROLL"] = function()
  if forceroll then
    print("Force roll Disabled")
    forceroll = false
  else
    print("Force roll Enabled")
    forceroll = true
  end
end

SLASH_TARGETKICK1 = "/targetkick"
SlashCmdList["TARGETKICK"] = function()
  if DMW.Player.Target and DMW.Player.Target.Distance <= 0 and DMW.Player.Target.Casting then
    Unlocked.CastSpellByID(1766)
    -- TipsyGuy.SecureCode("CastSpellByID", 1766)
  end
end

SLASH_FORCESKIPCHECK1 = "/forceskipcheck"
SlashCmdList["FORCESKIPCHECK"] = function()
  if UnitExists("target") and not DMW.Enums.SkipChecks[DMW.Player.Target.ObjectID] then
    DMW.Enums.SkipChecks[DMW.Player.Target.ObjectID] = true
  end
end

local function RtbCache()
  local count = 0
  local time
  local function cacheRTB(spell)
    if DMW.Player.Buffs[spell]:Exist() then
      count = count + 1
      -- print(Spell)
      time = select(6, DMW.Player.Buffs[spell]:Query(DMW.Player))
      -- print(spell)
      -- print(time)
    end
  end

  -- print("_________________________________________")
  cacheRTB("Broadside")
  cacheRTB("BuriedTreasure")
  cacheRTB("GrandMelee")
  cacheRTB("RuthlessPrecision")
  cacheRTB("SkullAndCrossbones")
  cacheRTB("TrueBearing")
  -- print("1")
  DMW.Player.RtbEndTime = time
  DMW.Player.RtbCount = count
  -- print(count)
  -- print(count, time - DMW.Time)
end

-- local function TTM()
--   local PowerMissing = Player.EnergyMax - Player.Energy
--   if PowerMissing > 0 then
--     return PowerMissing / select(1, GetPowerRegen())
--   else
--     return 0
--   end
-- end
local function lowest2TTD(max)
  local ttdArray = {}
  for _, Unit in ipairs(EnemyMelee) do
    table.insert(ttdArray, Unit.TTD)
  end
  if #ttdArray >= 2 then
    table.sort(
      ttdArray,
      function(x, y)
        return x > y
      end
    )
  end
  -- print("                     ")
  -- for k, v in pairs(ttdArray) do
  --   print(v)
  -- end
  if max then
    return ttdArray[#ttdArray]
  end
  if #ttdArray >= 2 then
    return ttdArray[2]
  end
end

local ttmCache = {

}
local function TTM(value)
  if value == nil then
    value = Player.EnergyMax
  end
  local PowerMissing = value - Player.Energy
  if PowerMissing > 0 then
    return PowerMissing / select(2, GetPowerRegen())
  else
    return 0
  end
end

-- local oldCount
local function isShadowDanced()
  return shadowDancedTime or Buff.ShadowDance:Exist()
end

local function isVanished()
  return vanishedTime or Buff.Vanish:Exist()
end

local function isThistleTeaed()
  return thistleTeaedTime or Buff.ThistleTea:Exist()
end

local touchTable = {}
local function touchTableAdd(Unit)
  touchTable[Unit.GUID] = DMW.Time + 1
end

local meleeRangeBoost
local function Locals()
  Player = DMW.Player
  if Player.SpecID == "Outlaw" and IsLeftShiftKeyDown() then
    DMWHUDINFO:Toggle(3)
  elseif IsLeftControlKeyDown() then
    DMWHUDINFO:Toggle(2)
  else
    DMWHUDINFO:Toggle(1)
  end
  -- print(DMW.Helpers.Swing.GetSwing(DMW.Player.GUID))
  HUD = DMW.Settings.profile.HUD
  Buff = Player.Buffs
  Debuff = Player.Debuffs
  Spell = Player.Spells
  Talent = Player.Talents
  meleeRangeBoost = 0
  if DMW.Player.Talents.AcrobaticStrikes then
    meleeRangeBoost = meleeRangeBoost + 3
  end
  Item = Player.Items
  Target = Player.Target or false
  -- if Target and not Target.ValidEnemy then
  --   if targetCheckGuID == nil or targetCheckGuID ~= Target.GUID then
  --     targetCheckGuID = Target.GUID
  --     print(DMW.Time, Target.CanAttack, Target.LoS, Target.Attackable, Target.Friend, Target.UnitIsUnitTarget,
  --       Target.isEnemy
  --     )
  --   end
  -- end
  -- Rage = Player.Rage
  CDs = Player:CDs() and Target and Target.TTD > 15 and Target.ValidEnemy and Target.Distance < 15
  EnemyMelee, EnemyMeleeCount = Player:GetEnemies(5)
  Enemy10Y, Enemy10YC = Player:GetAttackable(10 + meleeRangeBoost)
  -- Enemy30Y, Enemy30YC = Player:GetEnemies(30)
  -- if vanishambush and Player.LastCast and Player.LastCast[1] and Player.LastCast[1].SpellID == 8676 then
  --   print("vanishambush false")
  --   vanishambush = false
  -- end
  -- print(Enemy30YC)
  -- if not oldCount or oldCount ~= Enemy30YC then
  --   oldCount = Enemy30YC
  --   print(oldCount)
  -- end
  GCD = Player:GCDRemain()

  ComboPoints = Player.ComboPoints --UnitPower("player", 4) or Player.ComboPoints
  -- shadowDanced = shadowDancedTime or Buff.ShadowDance:Exist()
  if tornadoTime then
    if DMW.Time - tornadoTime >= 4.5 then
      -- print("ended")
      tornadoTime = nil
    end
  end
  if shadowDancedTime then
    if DMW.Time - shadowDancedTime >= 1 then
      shadowDancedTime = nil
    end
  end
  -- vanished = vanished or Buff.Vanish:Exist()
  if vanishedTime then
    if DMW.Time - vanishedTime >= 1 then
      vanishedTime = nil
    end
  end
  -- thistleTeaed = thistleTeaed or Buff.ThistleTea:Exist()
  if thistleTeaedTime then
    if DMW.Time - thistleTeaedTime >= 1 then
      thistleTeaedTime = nil
    end
  end
  -- if Player.ComboPoints ~= oldCP then
  --   oldCP = ComboPoints
  --   print(ComboPoints)
  -- end

  if Player.SpecID == "Assassination" then
    stealthedRogue = Buff.Stealth:Exist() or Buff.StealthSubterfuge:Exist() or Buff.Vanish:Exist() or
        Buff.Subterfuge:Remain() > 0.2 or
        Buff.ImprovedGarrote:Remain() > 0.2
    -- stealthedRogue = GetShapeshiftForm() ~= 0

    if (Buff.Kyrian2p:Exist() and ComboPoints == 2) or
        (Buff.Kyrian3p:Exist() and ComboPoints == 3) or
        (Buff.Kyrian4p:Exist() and ComboPoints == 4) or
        (Buff.Kyrian5p:Exist() and ComboPoints == 5) then
      ComboPoints = 7
    end
    EnemyFOK, EnemyFOKcount = Player:GetEnemies(10)
  elseif Player.SpecID == "Outlaw" then
    bfTTD = Player:GetTTD(EnemyMelee, "lowest2")
    if not Player.RtbCount then RtbCache() end
    stealthedRogue = Buff.Stealth:Exist() or isShadowDanced() or Buff.StealthSubterfuge:Exist() or isVanished() or
        Buff.Subterfuge:Remain() > 0.1
  elseif Player.SpecID == "Subtlety" then
    bfTTD = Player:GetTTD(EnemyMelee)
    stealthedRogue = Buff.Stealth:Exist() or Buff.StealthSubterfuge:Exist() or isVanished() or isShadowDanced()
  end
  if not Player.Combat and not TricksCombat then TricksCombat = true end
end

local function LocalsSubtlety()
  sndCondition = Buff.SliceAndDice:Exist() or Enemy10YC >= 7
  -- ShDthreshold = Spell.ShadowDance:ChargesFrac() >= 1.75
  -- SkipRupture = Enemy10YC >= 6 or HUD.RuptureMode == 2 or
  --     (not Talent.Nightstalker and Talent.DarkShadow and Buff.ShadowDance:Exist())
end

local function RogueTrinkets()
  if Setting("General Usage") then
    Item.Whetstone:Use()
    Item.Manic:Use()
  end
end

local function num(val)
  if val then
    return 1
  else
    return 0
  end
end

local function bool(val) return val ~= 0 end

local function MythicStuff()
  if not Player.Combat then return end
  if Setting("CC Spiteful") then
    if Debuff.SpitefulFixation:Exist() then
      -- for _, Unit in pairs(EnemyMelee) do
      --   if Unit.ObjectID == 174773 then

      --   end
      -- end
    end
  end
  if not Setting("Use Logics") then return end
  if Player.EID then
    if Player.EID == 1807 then      -- fenryr
      for k, v in pairs(DMW.Enemies) do
        if v:IsCasting(197556) then -- juimp

        end
        if v:IsCasting(196512) then -- cleave
          if Spell.Feint:IsReady() then
            if Spell.Feint:Cast(Player) then return true end
          end
        end
      end
    elseif Player.EID == 1805 then  --hymdall
      for k, v in pairs(DMW.Enemies) do
        if v:IsCasting(191284) then -- horn
          if Spell.Feint:IsReady() then
            if Spell.Feint:Cast(Player) then return true end
          end
        end
      end
    end
  end
  -- if fhbossPool and not Player.Combat then fhbossPool = false end
  -- if Setting("Piggie FH") and piggiecatch then
  --     if Player.EID == 2095 then piggiecatch = false end
  --     for i = 1, GetObjectCount() do
  --         local ID = ObjectID(GetObjectWithIndex(i))
  --         local object = GetObjectWithIndex(i)
  --         if ID == 130099 and GetDistanceBetweenObjects(object, "player") <= 5 then
  --             InteractUnit(object)
  --             RunMacroText("/follow")
  --             InteractUnit("target")
  --             return
  --         end
  --     end
  -- end
  -- WriteFile("GetMinimapZoneText.txt", tostring(GetMinimapZoneText()) .. "\n", true)
  --///
  -- if Player.EID then
  --   -- fh 1st boss feint, fisker (c)
  --   -- if Player.EID == 2093 then
  --   --     local a, b, c, d = UnitCastID("boss1")
  --   --     if a == 256106 then
  --   --         fhbossPool = false
  --   --         if c == ObjectPointer("player") then CastSpellByID(1966) end
  --   --     end
  --   --     if DMW.BossMods.getTimer(256106) <= 1.5 and Spell.Feint:CDUp() then -- pause 1 sec before cast for pooling
  --   --         -- if GetUnitIsUnit("player", UnitTarget("boss1")) then
  --   --         fhbossPool = true
  --   --     end
  --   --     if fhbossPool then return true end
  --   -- elseif Player.EID == 2117 then

  --   -- end
  --   -- WM gorak cc
  --   -- if br.player.eID == 2117 then
  --   -- if enemyTable20 ~= nil then
  --   -- for i = 1, #enemyTable20 do
  --   -- local thisUnit = enemyTable20[i]
  --   -- if thisUnit.id == 135552 and UnitCastingInfo(thisUnit) ~= nil then
  --   -- if (select(6, UnitCastingInfo(thisUnit)) - br.time) <= 1 then
  --   -- if not cd.gouge.exists() and getFacing(thisUnit,"player") then
  --   -- if cast.gouge(thisUnit) then return true end
  --   -- elseif not cd.betweenTheEyes.exists() and comboDeficit <= 2 then
  --   -- if cast.betweenTheEyes(thisUnit) then return true end
  --   -- elseif not cd.blind.exists() then
  --   -- if cast.blind(thisUnit) then return true end
  --   -- end
  --   -- end
  --   -- end
  --   -- end
  --   -- end
  --   -- end
  --   -- if br.player.eID == 2093 and isCastingSpell(256106, "boss1") then
  --   --     fhbossPool = false
  --   --     if GetUnitIsUnit("player", UnitTarget("boss1")) then
  --   --         if cast.feint() then print("feint gone");return true end
  --   --     end
  --   -- end
  --   -- if fhbossPool then return true end
  --   -- print(eID)
  --   local bosscount = 0
  --   for i = 1, 5 do if UnitExists("boss" .. i) then bosscount = bosscount + 1 end end
  --   for i = 1, bosscount do
  --     local spellname, castEndTime, interruptID, spellnamechannel, castorchan, spellID
  --     local thisUnit = tostring("boss" .. i)
  --     --    if select(3, UnitCastID(thisUnit)) == ObjectPointerUnlocked("player") and select(9, UnitCastingInfo(thisUnit)) then
  --     -- 	print(select(9, UnitCastingInfo(thisUnit)))
  --     -- end
  --     if UnitCastingInfo(thisUnit) then
  --       spellname = UnitCastingInfo(thisUnit)
  --       -- castStartTime = select(4,UnitCastingInfo(thisUnit)) / 1000
  --       castEndTime = select(5, UnitCastingInfo(thisUnit)) / 1000
  --       interruptID = select(9, UnitCastingInfo(thisUnit))
  --       castorchan = "cast"
  --     elseif UnitChannelInfo(thisUnit) then
  --       spellname = UnitChannelInfo(thisUnit)
  --       -- castStartTime = select(4,UnitChannelInfo(thisUnit)) / 1000
  --       castEndTime = select(5, UnitChannelInfo(thisUnit)) / 1000
  --       interruptID = select(9, UnitChannelInfo(thisUnit))
  --       castorchan = "channel"
  --     end
  --     if spellname ~= nil then
  --       -- print(spellname)
  --       local castleft = castEndTime -
  --           DMW.Time -- WriteFile("encountertest.txt", tostring(ObjectName("boss"..i)) .. "," .. tostring(castleft) .. " left," .. tostring(spellname) .. ", spellid =" .. tostring(interruptID) .. "\n", true)
  --       -- print(castleft.." cast left"..spellname)
  --       -- print(castleft.." channel left"..spellname)


  --       -- WriteFile("encountertest.txt", tostring(ObjectName("boss"..i)) .. "," .. tostring(castleft) .. " left," .. tostring(spellname) .. ", spellid =" .. tostring(interruptID) .. "\n", true)
  --       -- print(castleft.." cast left"..spellname)
  --       -- print(castleft.." channel left"..spellname)

  --       if (select(3, UnitCastID(thisUnit)) == Player.Pointer or select(4, UnitCastID(thisUnit)) == Player.Pointer) and
  --           castleft <= 1.5 then -- GetUnitIsUnit("player", "boss"..i.."target") or   then
  --         if cloakPlayerlist[interruptID] then
  --           if Player.EID == 2093 then if Spell.Feint:IsReady() or Buff.Feint:Exist() then return end end
  --           if Spell.CloakOfShadows:Cast(Player) then return true end
  --         elseif evasionPlayerlist[interruptID] then
  --           if Spell.Evasion:Cast(Player) then return true end
  --         elseif Talent.Elusiveness and feintPlayerList[interruptID] then
  --           if Spell.Feint:Pool() and Spell.Feint:CD() <= castleft then return true end
  --           if Spell.Feint:Cast(Player) then return true end
  --         elseif vanishList[interruptID] then
  --           if Spell.Vanish:Cast(Player) then return true end
  --         end
  --       else
  --         if cloaklist[interruptID] then
  --           if Spell.CloakOfShadows:Cast(Player) then return true end
  --         elseif evasionlist[interruptID] then
  --           if Spell.Evasion:Cast(Player) then return true end
  --         elseif feintlist[interruptID] then
  --           if Spell.Feint:Pool() and Spell.Feint:CD() <= castleft then return true end
  --           if Spell.Feint:Cast(Player) then return true end
  --         end
  --       end
  --       -- end
  --     end
  --   end
  --   -- CC units
  --   -- for i=1, #enemies.yards20 do
  --   --         local thisUnit = enemies.yards20[i]
  --   --         local distance = getDistance(thisUnit)
  --   --         if isChecked("AutoBtE") or isChecked("AutoGouge") or isChecked("AutoBlind") then
  --   --             local interruptID, castStartTime, spellname, castEndTime
  --   --             if UnitCastingInfo(thisUnit) then
  --   --                 spellname = UnitCastingInfo(thisUnit)
  --   --                 -- castStartTime = select(4,UnitCastingInfo(thisUnit)) / 1000
  --   --                 castEndTime = select(5, UnitCastingInfo(thisUnit)) / 1000
  --   --                 interruptID = select(9,UnitCastingInfo("player"))
  --   --             elseif UnitChannelInfo(thisUnit) then
  --   --                 spellname = UnitChannelInfo(thisUnit)
  --   --                 -- castStartTime = select(4,UnitChannelInfo(thisUnit)) / 1000
  --   --                 castEndTime = select(5,UnitChannelInfo(thisUnit)) / 1000
  --   --                 interruptID = select(8,UnitChannelInfo(thisUnit))
  --   --             end
  --   --             if isChecked("AutoBtE") and interruptID ~= nil and combo > 0 and not spread and
  --   --                     ((stunList[interruptID] and castEndTime - GetTime() <= 2 ) or
  --   --                     channelAsapList[interruptID] or
  --   --                     channelLateList[interruptID] and castEndTime - GetTime() <= 2)
  --   --                 then
  --   --                 if cast.betweenTheEyes(thisUnit) then print("bte stun on"..spellname); return true end
  --   --             end
  --   --             if isChecked("AutoGouge") and interruptID ~= nil and getFacing(thisUnit,"player") and
  --   --                     ((stunList[interruptID] and castEndTime - GetTime() <= 2 ) or
  --   --                     channelAsapList[interruptID] or
  --   --                     channelLateList[interruptID] and castEndTime - GetTime() <= 2)
  --   --                 then
  --   --                 if cast.gouge(thisUnit) then print("gouge on"..spellname) return true end
  --   --             end
  --   --             if isChecked("AutoBlind") and interruptID ~= nil and
  --   --                     ((stunList[interruptID] and castEndTime - GetTime() <= 2 ) or
  --   --                     channelAsapList[interruptID] or
  --   --                     (channelLateList[interruptID] and castEndTime - GetTime() <= 2)) then
  --   --                 if cast.blind(thisUnit) then print("blind on "..spellname) return true end
  --   --             end
  --   --         end
  --   --     end
  -- end
  -- --///
end

local function RtbRemain()
  local RtbRemains = (DMW.Player.RtbEndTime ~= nil and DMW.Player.RtbEndTime - DMW.Time) or 0
  return RtbRemains
end

local function rtbReroll(preroll)
  -- # Roll the Bones Reroll Conditions
  -- actions+=/variable,name=rtb_reroll,if=!talent.hidden_opportunity,value=rtb_buffs<2&(!buff.broadside.up&(!talent.fan_the_hammer|!buff.skull_and_crossbones.up)&!buff.true_bearing.up|buff.loaded_dice.up)|rtb_buffs=2&(buff.buried_treasure.up&buff.grand_melee.up|!buff.broadside.up&!buff.true_bearing.up&buff.loaded_dice.up)
  -- # Additional Reroll Conditions for Keep it Rolling or Count the Odds
  -- actions+=/variable,name=rtb_reroll,if=!talent.hidden_opportunity&(talent.keep_it_rolling|talent.count_the_odds),value=variable.rtb_reroll|((rtb_buffs.normal=0&rtb_buffs.longer>=1)&!(buff.broadside.up&buff.true_bearing.up&buff.skull_and_crossbones.up)&!(buff.broadside.remains>39|buff.true_bearing.remains>39|buff.ruthless_precision.remains>39|buff.skull_and_crossbones.remains>39))
  -- # With Hidden Opportunity, prioritize rerolling for Skull and Crossbones over everything else
  -- actions+=/variable,name=rtb_reroll,if=talent.hidden_opportunity,value=!rtb_buffs.will_lose.skull_and_crossbones&(rtb_buffs.will_lose-rtb_buffs.will_lose.grand_melee)<2+buff.loaded_dice.up
  -- # Avoid rerolls when we will not have time remaining on the fight or add wave to recoup the opportunity cost of the global
  -- actions+=/variable,name=rtb_reroll,op=reset,if=!(raid_event.adds.remains>12|raid_event.adds.up&(raid_event.adds.in-raid_event.adds.remains)<6|target.time_to_die>12)|fight_remains<12
  -- if Player:GetTTD(EnemyMelee) < 8 and Player.CombatTime >= 4 and
  --     (not Buff.LoadedDice:Exist() or Buff.LoadedDice:Remain() > 4) then
  --   return false
  -- end
  if not preroll then
    if #DMW.Enemies == 0 then
      return false
    end
    if HUD.Info ~= 1 then
      return false
    end
    if CDs and Spell.AdrenalineRush:CD() <= 5 and not Buff.LoadedDice:Exist() then
      return false
    end
    if isShadowDanced() or Buff.DreadBlades:Exist() or isVanished() or Buff.Subterfuge:Exist() then
      return false
    end
  end
  if Player.RtbCount == 0 then
    return true
  end
  if Buff.Broadside:Duration() < 30 and
      Buff.BuriedTreasure:Duration() < 30 and
      Buff.GrandMelee:Duration() < 30 and
      Buff.RuthlessPrecision:Duration() < 30 and
      Buff.SkullAndCrossbones:Duration() < 30 and
      Buff.TrueBearing:Duration() < 30 then
    return true
  end
  if Buff.SkullAndCrossbones:Exist() then
    return false
  end


  if Player.RtbCount > 2 then
    return false
  end
  -- if not Buff.LoadedDice:Exist() then
  --   if (Buff.Broadside:Exist() or Buff.SkullAndCrossbones:Exist() or Buff.TrueBearing:Exist()) then
  --     return false
  --   end
  --   if (Player.RtbCount == 2) then
  --     if Buff.GrandMelee:Exist() and Buff.BuriedTreasure:Exist() then
  --       return true
  --     end
  --     return false
  --   end
  -- else
  if Player.RtbCount == 1 then
    return true
  end
  -- if Player.RtbCount == 2 then
  --   if Buff.Broadside:Exist() or Buff.SkullAndCrossbones:Exist() or Buff.TrueBearing:Exist() then
  --     return false
  --   else
  --     return true
  --   end
  -- end
  if Player.RtbCount == 2 then
    if Buff.GrandMelee:Exist() then
      return true
    else
      return false
    end
  end
  -- end

  return true
  -- if Player.RtbCount < 2 and not Buff.Broadside:Exist() and not Buff.SkullAndCrossbones:Exist() then
  --   return true
  -- end
  -- if Player.RtbCount == 2 and Buff.GrandMelee:Exist() and Buff.BuriedTreasure:Exist() then return true end
  -- return false
end

function OutlawShouldFinish()
  -- 	variable,name=finish_condition,value=combo_points>=cp_max_spend-buff.broadside.up-(buff.opportunity.up*(talent.quick_draw|talent.fan_the_hammer)|buff.concealed_blunderbuss.up)|effective_combo_points>=cp_max_spend
  -- Finish at max possible CP without overflowing bonus combo points, unless for BtE which always should be 5+ CP

  --   if ComboPoints >= ComboPointsMax - num()
  -- combo_points>=cp_max_spend-(buff.broadside.up+buff.opportunity.up)*(talent.quick_draw.enabled&(!talent.marked_for_death.enabled|cooldown.marked_for_death.remains>1))*(azerite.ace_up_your_sleeve.rank<2|!cooldown.between_the_eyes.up)|combo_points=animacharged_cp
  -- combo_points>=cp_max_spend-buff.broadside.up-(buff.opportunity.up*talent.quick_draw.enabled)|combo_points=animacharged_cp
  if Talent.EchoingReprimand then
    if (Buff.Kyrian2p:Exist() and ComboPoints == 2) or
        (Buff.Kyrian3p:Exist() and ComboPoints == 3) or
        (Buff.Kyrian4p:Exist() and ComboPoints == 4) or
        (Buff.Kyrian5p:Exist() and ComboPoints == 5) then
      return true
    end
  end
  -- effective_combo_points>=cp_max_spend-1-(stealthed.all&talent.crackshot)
  local FinishCPs = Talent.CrackShot and stealthedRogue and 2 or 1
  --num(Buff.Broadside:Exist() or Buff.Opportunity:Exist())
  -- print(Player.ComboPointsDeficit)
  if ComboPoints >= Player.ComboPointsMax - FinishCPs then return true end
  return false
end

local function BoteBeforeBte()
  if CDs and Player:EssenceMajor("BloodOfTheEnemy") and Spell.BloodOfTheEnemy:IsCastable() then
    if Spell.BloodOfTheEnemy:Cast(Player) then return true end
  end
end

local sndCP = { 12, 18, 24, 30, 36, 42, 48 }
local function SnDRefresh()
  if Buff.SliceAndDice:Remain() <= 0.3 * sndCP[Player.ComboPoints] and Player:CombatTime() > 4 then
    -- if Buff.SliceAndDice:Remain() < 12 then
    return true
  end
end

local function OutlawFinishers(anima)
  -- actions.finish=between_the_eyes,if=target.time_to_die>3&(debuff.between_the_eyes.remains<4|(runeforge.greenskins_wickers|talent.greenskins_wickers)&!buff.greenskins_wickers.up|!runeforge.greenskins_wickers&!talent.greenskins_wickers&buff.ruthless_precision.up)
  -- Finishers BtE to keep the Crit debuff up, if RP is up, or for Greenskins, unless the target is about to die.
  -- actions.finish=between_the_eyes,if=!talent.crackshot&(buff.between_the_eyes.remains<4|talent.improved_between_the_eyes|talent.greenskins_wickers|set_bonus.tier30_4pc)&!buff.greenskins_wickers.up
  if not Talent.CrackShot then
  else
    --     # Crackshot builds use Between the Eyes outside of Stealth if Vanish or Dance will not come off cooldown within the next cast
    -- actions.finish+=/between_the_eyes,if=talent.crackshot&(cooldown.vanish.remains>45&cooldown.shadow_dance.remains>12)
    if HUD.Info == 1 and ((Spell.Vanish:CD() > 45 and Spell.ShadowDance:CD() > 12) or not CDs) then
      if Spell.BetweenTheEyes:IsCastable(20) then
        if Setting("BTE HP Check") then
          local hpUnit, hpValue
          for _, Unit in ipairs(EnemyMelee) do
            if not hpValue or Unit.Health >= 1.3 * hpValue then
              hpUnit = Unit
              hpValue = Unit.Health
            end
          end
          if hpUnit then
            if Spell.BetweenTheEyes:Cast(hpUnit) then return true end
          end
        else
          if Target then
            if Spell.BetweenTheEyes:Cast(Target) then
              return true
            end
          end
        end
      end
    end
  end


  if Spell.SliceAndDice:IsReady() and SnDRefresh() and
      (Target and Target.Dummy or Player.InGroup) and (
      -- not Talent.CountTheOdds or
        not Buff.Stealth:Exist() and not Buff.StealthSubterfuge:Exist() and not Buff.ShadowDance:Exist() and
        not Buff.Subterfuge:Exist()) then
    if Spell.SliceAndDice:Cast(Player) then return true end
    -- return true
  end

  -- if Spell.BetweenTheEyes:IsCastable(20) and HUD.Info ~= 3 then
  --     if BoteBeforeBte() then return true end
  --     for _, Unit in ipairs(Player:GetEnemies(20)) do
  --         if Spell.BetweenTheEyes:Cast(Unit) then
  --             return true
  --         end
  --     end
  --     return true
  -- end

  -- if Setting("Pool for BTE") and TTM() >= 4 and TTM() > Spell.BetweenTheEyes:CD() then
  --     return true
  -- end

  if Player.ComboPoints == 6 and Buff.Tier2P:Exist() and Spell.Ambush:IsReady() then
    -- print("Ambush forced 2p")

    for _, Unit in ipairs(EnemyMelee) do
      if Spell.Ambush:Cast(Unit) then return true end
    end
  end
  if Spell.Dispatch:IsCastable(5) then -- and not forceroll and not rtbReroll() then --and cd.betweenTheEyes.remain() >= 0.2 then
    if HUD.Info == 1 and Spell.ColdBlood:IsReady() then
      Spell.ColdBlood:Cast(Player)
    end
    for _, Unit in ipairs(EnemyMelee) do if Spell.Dispatch:Cast(Unit) then return true end end
    -- return true
  end
  if HUD.BladerushMode == 1 and HUD.Info == 1 and Spell.BladeRush:CDUp() then
    for _, Unit in ipairs(EnemyMelee) do
      if TipsyGuy.GetDistance2D("player", Unit.GUID) <= brRange then
        if Spell.BladeRush:Cast(Unit) then return true end
      end
    end
  end
  return true
end

local function OutlawEssencesAPL()
  if Player:EssenceMajor("FocusedAzeriteBeam") and Spell.FocusedAzeriteBeam:CDUp() and Setting("Auto BEAM") and
      EnemyMeleeCount >= 1 then
    if Spell.FocusedAzeriteBeam:Cast(Player) then return true end
  end
end
local function OutlawStealth()
  -- actions.stealth=blade_flurry,if=talent.subterfuge&talent.hidden_opportunity&spell_targets>=2&buff.blade_flurry.remains<gcd
  -- actions.stealth+=/cold_blood,if=variable.finish_condition
  -- actions.stealth+=/between_the_eyes,if=variable.finish_condition&talent.crackshot
  -- actions.stealth+=/dispatch,if=variable.finish_condition
  if OutlawShouldFinish() then
    if Talent.CrackShot and Spell.BetweenTheEyes:IsCastable(5) then
      if Setting("BTE HP Check") then
        local hpUnit, hpValue
        for _, Unit in ipairs(EnemyMelee) do
          if not hpValue or Unit.Health >= 1.3 * hpValue then
            hpUnit = Unit
            hpValue = Unit.Health
          end
        end
        if hpUnit then
          if Spell.BetweenTheEyes:Cast(hpUnit) then return true end
        end
      else
        if Target then
          if Spell.BetweenTheEyes:Cast(Target) then
            return true
          end
        end
      end
    end
    if Spell.Dispatch:IsCastable(5) then -- and not forceroll and not rtbReroll() then --and cd.betweenTheEyes.remain() >= 0.2 then
      if HUD.Info == 1 and Spell.ColdBlood:IsReady() then
        Spell.ColdBlood:Cast(Player)
      end

      for _, Unit in ipairs(EnemyMelee) do if Spell.Dispatch:Cast(Unit) then return true end end
      -- return true
    end
  end
  -- # 2 Fan the Hammer Crackshot builds can consume Opportunity in stealth with max stacks, Broadside, and low CPs, or with Greenskins active
  -- actions.stealth+=/pistol_shot,if=talent.crackshot&talent.fan_the_hammer.rank>=2&buff.opportunity.stack>=6&(buff.broadside.up&combo_points<=1|buff.greenskins_wickers.up)
  if Talent.CrackShot and Talent.FanTheHammer and Buff.Opportunity:Stacks() >= 6 and (Buff.Broadside:Exist() and ComboPoints <= 1 or Buff.Greenskins:Exist()) then
    for _, Unit in ipairs(Player:GetEnemies(20)) do if Spell.PistolShot:Cast(Unit) then return true end end
  end
  -- actions.stealth+=/ambush,if=talent.hidden_opportunity
  if Talent.HiddenOpportunity then
    for _, Unit in ipairs(EnemyMelee) do
      if Spell.Ambush:Cast(Unit) then return true end
    end
  end
end
local function OutlawBuilders()
  if Spell.MarkOfDeath:IsCastable(20) then
    for _, Unit in ipairs(Player:GetEnemies(20)) do
      if Unit.TTD <= 2 and Unit.TTD > 0 then if Spell.MarkOfDeath:Cast(Unit) then return true end end
    end
  end
  -- if Spell.SinisterStrike:IsCastable("Melee") and (Player:HasHeroism() or Buff.AdrenalineRush:Exist()) then
  --     if EnemyMeleeCount >= 4 and not Buff.Deadshot:Exist() and Buff.BladeFlurry:Exist() then
  --         for _, Unit in ipairs(EnemyMelee) do
  --             if Spell.SinisterStrike:Cast(Unit) then
  --                 return true
  --             end
  --         end
  --     end
  -- end
  -- energy<45|talent.quick_draw.enabled&buff.keep_your_wits_about_you.down
  -- ghostly_strike,if=debuff.ghostly_strike.remains<=3&(spell_targets.blade_flurry<=2|buff.dreadblades.up)&!buff.subterfuge.up&target.time_to_die>=5
  if Talent.GhostlyStrike and EnemyMeleeCount == 1 and Target and HUD.GhostlyStrike == 1 then
    if Debuff.GhostlyStrike:Remain(Target) <= 3 and not Buff.Subterfuge:Exist() and not Buff.Stealth:Exist() and
        not Buff.StealthSubterfuge:Exist() and
        not Buff.ShadowDance:Exist() and
        not isVanished() and Target.TTD >= 5 then
      if Spell.GhostlyStrike:Cast(Target) then return true end
    end
  end
  -- ambush,if=talent.hidden_opportunity&buff.audacity.up|talent.find_weakness&debuff.find_weakness.down
  -- if Spell.Ambush:IsReady() and Talent.HiddenOpportunity and Buff.Audacity:Exist() or
  --     Talent.FindWeakness and Target and not Debuff.FindWeakness:Exist(Target) then
  -- end
  -- if Talent.HiddenOpportunity and Buff.Opportunity:Stacks() == 6 and
  --     (not Buff.ShadowDance:Exist() or not Talent.CountTheOdds) then --and not Buff.Subterfuge:Exist()
  --   for _, Unit in ipairs(Player:GetEnemies(20)) do if Spell.PistolShot:Cast(Unit) then return true end end
  -- end
  -- if Talent.HiddenOpportunity and Buff.Opportunity:Stacks() >= 3 and Spell.PistolShot:IsCastable(20) and
  --     not Buff.Subterfuge:Exist() and
  --     not Buff.Stealth:Exist() and not Buff.Vanish:Exist() and not Buff.ShadowDance:Exist() and not Buff.Audacity:Exist() then
  --   for _, Unit in ipairs(EnemyMelee) do
  --     if Debuff.BetweenTheEyes:Exist(Unit) then
  --       if Spell.PistolShot:Cast(Unit) then return true end
  --     end
  --   end
  --   for _, Unit in ipairs(Player:GetEnemies(20)) do if Spell.PistolShot:Cast(Unit) then return true end end
  -- end
  -- if Spell.PistolShot:IsCastable(20) and Buff.Opportunity:Stacks() >= 1 and not Buff.Subterfuge:Exist() and
  --     not Buff.Stealth:Exist() and not Buff.StealthSubterfuge:Exist() and not isVanished() and
  --     not isShadowDanced() and not Buff.Audacity:Exist()
  -- -- and
  -- -- (Player.ComboPointsDeficit >= 4) and HUD.Info ~= 2
  -- then
  --   for _, Unit in ipairs(Player:GetEnemies(20)) do if Spell.PistolShot:Cast(Unit) then return true end end
  -- end
  -- if Spell.Ambush:IsCastable("Melee") then
  if Buff.Audacity:Exist() then
    -- local remainTime = math.max(Buff.ShadowDance:Remain(), Buff.Audacity:Remain(), Buff.Subterfuge:Remain())

    for _, Unit in ipairs(EnemyMelee) do
      if Spell.Ambush:Cast(Unit) then return true end
    end
    if HUD.BladerushMode == 1 and HUD.Info == 1 and Spell.BladeRush:CDUp() then
      if not isShadowDanced() or TTM(50) >= 1 then
        for _, Unit in ipairs(EnemyMelee) do
          if TipsyGuy.GetDistance2D("player", Unit.GUID) <= brRange then
            if Spell.BladeRush:Cast(Unit) then return true end
          end
        end
      end
    end
    -- if TTM(50) <= remainTime then
    --   return true
    -- end
    -- if Spell.PistolShot:IsCastable(20) and Buff.Opportunity:Stacks() > 3 then
    --   for _, Unit in ipairs(Player:GetEnemies(20)) do if Spell.PistolShot:Cast(Unit) then return true end end
    -- end
  end
  -- end
  if Setting("BladeRush on AOE targets") > 0 and HUD.BladerushMode == 1 and EnemyMeleeCount >= Setting("BladeRush on AOE targets") and
      Buff.BladeFlurry:Exist() and TTM() >= 2 then
    if not isShadowDanced() or TTM(50) >= 1 then
      for _, Unit in ipairs(EnemyMelee) do
        if TipsyGuy.GetDistance2D("player", Unit.GUID) <= brRange then
          if Spell.BladeRush:Cast(Unit) then return true end
        end
      end
    end
  end
  if Talent.Audacity and Talent.HiddenOpportunity and Talent.FanTheHammer and Spell.PistolShot:IsCastable(20) and Buff.Opportunity:Exist() and not Buff.Audacity:Exist()
  then
    for _, Unit in ipairs(EnemyMelee) do if Spell.PistolShot:Cast(Unit) then return true end end
  end
  if Spell.PistolShot:IsCastable(20) and Buff.Opportunity:Exist() and
      not Buff.Stealth:Exist() and not Buff.StealthSubterfuge:Exist() and not isVanished() and

      (Player.Energy < 30 or Buff.Opportunity:Stacks() == 6 or Buff.Opportunity:Remain() < 2) then
    for _, Unit in ipairs(Player:GetEnemies(20)) do if Spell.PistolShot:Cast(Unit) then return true end end
  end
  if Buff.Audacity:Exist() then
    return true
  end
  if Spell.SinisterStrike:IsCastable("Melee") then
    for _, Unit in ipairs(EnemyMelee) do if Spell.SinisterStrike:Cast(Unit) then return true end end
  end
end

local function PotUsage()
  if Setting("Pot") > 0 and not Player.Combat then
    if Setting("Pot") == 2 then
      Item.AgiPot:Use()
    elseif Setting("Pot") == 3 then
      Item.FuryPotDPS:Use()
    end
  end
end

local function PrecombatShared()
  -- STEALTH OPTIONS
  if not Player.Combat and not stealthedRogue and Spell.Stealth:CDUp() then
    if Setting("Auto Stealth") == 2 then
      for _, v in ipairs(DMW.Enemies) do
        if v.Distance <= 20 then
          -- if Spell.Stealth:Cast() then return true end
          Unlocked.CastSpellByName(Spell.Stealth.SpellName)
          -- CastSpellByName()
        end
      end
    elseif Setting("Auto Stealth") == 3 then
      -- if Spell.Stealth:Cast() then return true end
      Unlocked.CastSpellByName(Spell.Stealth.SpellName)
    end
  end
end

local function PrecombatOutlaw()
  -- if (Setting("Ambush") ~= 1 or vanishambush) and Spell.Ambush:IsReady() then
  --   if Setting("Ambush") == 3 then
  --     for _, Unit in ipairs(DMW.Attackable) do
  --       if Unit.Distance <= 5 then
  --         PotUsage()
  --         if Spell.Ambush:Cast(Unit) then return true end
  --       end
  --     end
  --   end
  --   if Setting("Ambush") == 2 then
  --     for _, Unit in ipairs(EnemyMelee) do
  --       PotUsage()
  --       if Spell.Ambush:Cast(Unit) then return true end
  --     end
  --   end
  --   if vanishambush then
  --     for _, Unit in ipairs(EnemyMelee) do
  --       PotUsage()
  --       if Spell.Ambush:Cast(Unit) then return true end
  --     end
  --   end
  -- end
end

local poisonTime
local function Poisons()
  if Player:StandingTime() >= 2 and not Player.Casting and DMW.Tables.AuraCache[DMW.Player.GUID] and
      (not poisonTime or DMW.Time - poisonTime >= 5) then
    if Setting("MH") > 1 then
      local PoisonType = Setting("MH") == 2 and "WoundPoison" or "InstantPoison"
      if (not Buff[PoisonType]:Exist(Player) or (Buff[PoisonType]:Remain(Player) <= 300 and not Player.Combat)) and
          Spell[PoisonType]:IsReady() then
        if Spell[PoisonType]:Cast(Player) then
          poisonTime = DMW.Time;
          return true
        end
      end
    end
    if Setting("OH") > 1 then
      local PoisonType = Setting("OH") == 2 and "CripplingPoison" or
          Setting("OH") == 4 and "AtrophicPoison"
          or Setting("OH") == 3 and "NumbingPoison"
      if (not Buff[PoisonType]:Exist(Player) or (Buff[PoisonType]:Remain(Player) <= 300 and not Player.Combat)) and
          Spell[PoisonType]:IsReady() then
        if Spell[PoisonType]:Cast(Player) then
          poisonTime = DMW.Time;
          return true
        end
      end
    end
  end
end

local function Tricks()
  if Setting("Tricks") > 1 and Player.Combat and Spell.Tricks:IsReady() then
    if Setting("Tricks On CD") or Player:IsTanking(30, 3) or (Setting("Tricks once in Combat") and TricksCombat) then
      if Setting("Tricks") == 2 then
        if Player.Focus then
          if Unlocked.IsSpellInRange(Spell.Tricks.SpellName, Player.Focus:ObjectUnit()) == 1 then
            Spell.Tricks:Cast(Player.Focus)
            TricksCombat = false
          end
        end
      elseif Setting("Tricks") == 3 then
        for _, Unit in pairs(DMW.Friends.Tanks) do
          -- if Unlocked.IsSpellInRange(Spell.Tricks.SpellName, Unit.GUID) == 1 and Unit.LoS then
          Spell.Tricks:Cast(Unit)
          TricksCombat = false
          -- end
        end
      end
    end
  end
end

local function Defensives()
  if Setting("Crimson Vial") > 0 and Player.HP <= Setting("Crimson Vial") then if Spell.CrimsonVial:Cast(Player) then return end end
  if Player.Combat then
    if Setting("HealthStone") > 0 and Player.HP <= Setting("HealthStone") then Item.HealthStone:Use() end
    if Setting("HealingPot") > 0 and Player.HP <= Setting("HealingPot") then Item.HealthPot:Use() end
    if Setting("Evasion") > 0 and Player.HP <= Setting("Evasion") then Spell.Evasion:Cast(Player) end
    if Setting("Feint") > 0 and Player.HP <= Setting("Feint") then if Spell.Feint:Cast(Player) then return end end
    if Setting("Cloak") > 0 and Player.HP <= Setting("Cloak") then Spell.CloakOfShadows:Cast(Player) end
  end
end

local function isTotem(unit)
  local creatureType = Unlocked.UnitCreatureType(unit)
  if creatureType ~= nil then
    if creatureType == "Totem" or creatureType == "Tótem" or creatureType == "Totém" or creatureType == "Тотем" or
        creatureType ==
        "토템" or creatureType == "图腾" or creatureType == "圖騰" then
      return true
    end
  end
  return false
end

local function isBoss(unit)
  if UnitExists(unit) and not isTotem(unit) then
    local class = UnitClassification(unit)
    local healthMax = UnitHealthMax(unit)
    local pHealthMax = UnitHealthMax("player")
    local instance = select(2, IsInInstance())
    return unit.Boss or unit.Dummy or (not UnitIsTrivial(unit) and instance ~= "party" and
      ((class == "rare" and healthMax > 4 * pHealthMax) or class == "rareelite" or class == "worldboss" or
        (class == "elite" and healthMax > 4 * pHealthMax and instance ~= "raid") or UnitLevel(unit) < 0))
  end
  return false
end

local willkick = nil
local function canInterruptshit(unit, hardinterrupt, gouge)
  hardinterrupt = hardinterrupt or false
  local timeforcc = (hardinterrupt and 2) or 1
  local InterruptTarget = DMW.Settings.profile.Enemy.InterruptTarget
  if (InterruptTarget == 2 and not UnitIsUnit(unit.Pointer, "target")) or
      (InterruptTarget == 3 and not UnitIsUnit(unit.Pointer, "focus")) or
      (InterruptTarget == 4 and
        (
          not GetRaidTargetIndex(unit.Pointer) or
          GetRaidTargetIndex(unit.Pointer) ~= DMW.Settings.profile.Enemy.InterruptMark)) then
    return false
  end
  -- if hardinterrupt and not unit:CanCC("stun") then return false end
  local castStartTime, castEndTime, interruptID, interruptable, castLeft = 0, 0, 0, false, 999
  if unit.ValidEnemy and unit.Casting then
    -- Get Cast/Channel Info
    if (not unit:CastingInfo(8) or hardinterrupt) then -- Get spell cast time
      -- castStartTime = unit:CastingInfo(4)
      -- castEndTime = unit:CastingInfo(5)
      castLeft = unit:CastRemains() -- castEndTime / 1000 - DMW.Time
      interruptID = unit:CastIdCheck()
      -- print(interruptID, castLeft, "casting")
      if HUD.CCMode == 1 and
          (Setting("Any Cast") or stunList[interruptID] or channelAsapList[interruptID] or channelLateList[interruptID]) -- or (HUD.CCMode == 2 and
      -- or (HUD.CCMode == 2 and

      then
        interruptable = true
        -- else
        -- 	unit.CastChecked = true
      end
      if HUD.CCMode == 2 and not interruptable and Setting("WhiteList CC") ~= nil and Setting("WhiteList CC") ~= "" then
        local castName = unit:CastGetName()
        for k in string.gmatch(Setting("WhiteList CC"), "([^,]+)") do
          if strmatch(string.lower(castName), string.lower(string.trim(k))) then
            -- print(castName, k)
            interruptable = true
            break
          end
        end
      end
    end
    if interruptable then
      if Spell.Kick:CDUp() and not hardinterrupt then
        if willkick == nil then
          willkick = unit -- local wx, wy, wz = ObjectPosition(willkick)
          -- local wx, wy, wz = ObjectPosition(willkick)
          -- local wx, wy, wz = ObjectPosition(willkick)

          -- local wx, wy, wz = ObjectPosition(willkick)

          if unit.Distance > 5 then
            DMW.Helpers.DrawColor(255, 0, 0)
          else
            DMW.Helpers.DrawColor(0, 0, 0)
          end
        end
      end
      -- if gouge and (willkick == nil or willkick ~= unit) then
      --     local ux, uy, uz = unit.PosX, unit.PosY, unit.PosZ
      --     if not ObjectIsFacing(unit, "player") or unit.Distance > 5 then
      --         local truefacing = ObjectFacing(unit.Pointer)
      --         DMW.Helpers.DrawColor(255, 0, 0)
      --         LibDraw.Arc(ux, uy, uz, 7, 210, truefacing)
      --     else
      --         DMW.Helpers.DrawColor(0, 0, 0)
      --     end
      --     DMW.Helpers.DrawText("CC SHIT", "GameFontNormal", ux, uy, uz + 2)
      -- end
      if willkick == unit and hardinterrupt then return false end
      if castLeft <= timeforcc or channelAsapList[interruptID] ~= nil or true then
        -- print(forpro)
        local forpro = true
        if forpro or (DMW.Time - castStartTime / 1000) >= DMW.Settings.profile.Enemy.InterruptDelay then return true end
      end
    end
    return false
  end
end

local function CrowdControlAround()
  for _, Unit in ipairs(DMW.Enemies) do
    -- local castID, channelID = UnitCastID(Unit.Pointer)
    -- if castID > 0 or channelID >  0 then
    if Unit:IsCasting() then
      -- print(Unit:CastCurrent())
      if Setting("AutoKick") and Unit.Distance <= 5 and Spell.Kick:CDUp() then
        if canInterruptshit(Unit, false) then
          if Setting("Delay") > 0 and Setting("Delay") < Unit:CastCurrent() then
            if Unit:CastRemains() > Player:GCD() + 0.3 then
              return
            else
              if Spell.Kick:Cast(Unit) then
                Unit.NextUpdate = DMW.Time;
                return
              end
            end
          elseif Setting("Delay") == 0 then
            if Spell.Kick:Cast(Unit) then
              Unit.NextUpdate = DMW.Time;
              return
            end
          end
        end
      end
      -- if isBoss(Unit.Pointer) or Unit.Boss then return end
      if Player.SpecID == "Outlaw" and Setting("AutoGouge") and Spell.Gouge:IsReady() and Unit.Distance <= 5 and
          ObjectIsFacing(Unit.Pointer, Player.Pointer) and Unit:CanCC("incapacitate") then
        if canInterruptshit(Unit, true, true) then
          if Setting("Delay") > 0 then
            if Setting("Delay for CC") then
              if Setting("Delay") <= Unit:CastCurrent() and Unit:CastRemains() >= Player:GCD() + 0.5 then
                return
              elseif Setting("Delay") < Unit:CastCurrent() then
                return true
              end
              if Spell.Gouge:Cast(Unit) then
                Unit.NextUpdate = DMW.Time;
                return true
              end
            else
              if Setting("Delay") >= Unit:CastCurrent() then
                if Spell.Gouge:Cast(Unit) then
                  Unit.NextUpdate = DMW.Time;
                  return true
                end
              end
            end
          elseif Setting("Delay") == 0 then
            if Spell.Gouge:Cast(Unit) then
              Unit.NextUpdate = DMW.Time;
              return true
            end
          end
        end
      end
      if Setting("AutoKidney") and Spell.KidneyShot:IsReady() and Player.ComboPoints > 0 and Unit.Distance <= 5 and
          Unit:CanCC("stun") then
        if canInterruptshit(Unit, true) then
          if Setting("Delay") > 0 then
            if Setting("Delay for CC") then
              if Setting("Delay") <= Unit:CastCurrent() and Unit:CastRemains() >= Player:GCD() + 0.5 then
                return
              elseif Setting("Delay") < Unit:CastCurrent() then
                return true
              end
              if Spell.KidneyShot:Cast(Unit) then
                Unit.NextUpdate = DMW.Time;
                return true
              end
            else
              if Setting("Delay") >= Unit:CastCurrent() then
                if Spell.KidneyShot:Cast(Unit) then
                  Unit.NextUpdate = DMW.Time;
                  return true
                end
              end
            end
          elseif Setting("Delay") == 0 then
            if Spell.KidneyShot:Cast(Unit) then
              Unit.NextUpdate = DMW.Time;
              return true
            end
          end
        end
      end
      if Setting("AutoCheapShot") and Spell.CheapShot:IsReady() and Unit.Distance <= 5 and Unit:CanCC("stun") then
        if canInterruptshit(Unit, true) then
          if Setting("Delay") > 0 then
            if Setting("Delay for CC") then
              if Setting("Delay") <= Unit:CastCurrent() and Unit:CastRemains() >= Player:GCD() + 0.5 then
                return
              elseif Setting("Delay") < Unit:CastCurrent() then
                return true
              end
              if Spell.CheapShot:Cast(Unit) then
                Unit.NextUpdate = DMW.Time;
                return true
              end
            else
              if Setting("Delay") >= Unit:CastCurrent() then
                if Spell.CheapShot:Cast(Unit) then
                  Unit.NextUpdate = DMW.Time;
                  return true
                end
              end
            end
          elseif Setting("Delay") == 0 then
            if Spell.CheapShot:Cast(Unit) then
              Unit.NextUpdate = DMW.Time;
              return true
            end
          end
        end
      end
      if Setting("AutoBlind") and Unit.Distance <= 15 and Spell.Blind:IsReady() then
        -- print("blind")
        if canInterruptshit(Unit, true) then
          if Setting("Delay") > 0 then
            if Setting("Delay for CC") then
              if Setting("Delay") <= Unit:CastCurrent() and Unit:CastRemains() >= Player:GCD() + 0.5 then
                return
              elseif Setting("Delay") < Unit:CastCurrent() then
                return true
              end
              if Spell.Blind:Cast(Unit) then
                Unit.NextUpdate = DMW.Time;
                return true
              end
            else
              if Setting("Delay") >= Unit:CastCurrent() then
                if Spell.Blind:Cast(Unit) then
                  Unit.NextUpdate = DMW.Time;
                  return true
                end
              end
            end
          elseif Setting("Delay") == 0 then
            if Spell.Blind:Cast(Unit) then
              Unit.NextUpdate = DMW.Time;
              return true
            end
          end
        end
      end
    end
  end
end

local function CrowdControl()
  local Delay = DMW.Settings.profile.Enemy.InterruptDelay
  for _, Unit in pairs(DMW.Enemies) do
    local distance = Unit.Distance -- print(thisUnit.Name)
    -- print(thisUnit.Name)
    if Unit:IsCasting() and (Setting("Any Cast") or DMW.CCLists.AllSpells[Unit:CastIdCheck()]) then
      if distance <= 5 then
        if Setting("AutoKick") and Unit:IsInterruptible() and
            (Unit:CastCurrent() >= Delay or Unit:CastRemains() < 0.2) and Spell.Kick:CDUp() then
          Spell.Kick:Cast(Unit)
          return
        else
          if Unit:CastCurrent() >= Delay or Unit:CastRemains() < 0.2 + GCD then
            if Setting("AutoGouge") and Talent.Gouge and Spell.Gouge:IsReady() and Unit:Facing() and
                Unit:CanCC("incapacitate") then
              if Spell.Gouge:Cast(Unit) then return true end
            end
            if Setting("AutoKidney") and Player.ComboPoints >= 1 and Spell.KidneyShot:IsReady() and
                Unit:CanCC("stun") then
              if Spell.KidneyShot:Cast(Unit) then return true end
            end
            if Setting("AutoCheapShot") and Spell.CheapShot:CDUp() and
                Unit:CanCC("stun") then
              if Spell.CheapShot:IsReady() then
                if Spell.CheapShot:Cast(Unit) then return true end
              else
                if Setting("AutoCheapShot Cds") then
                  if Spell.ShadowDance:IsReady() then
                    if Spell.ShadowDance:Cast(Player) and Spell.CheapShot:Cast(Unit) then return true end
                  elseif Spell.Vanish:IsReady() then
                    if Spell.Vanish:Cast(Player) and Spell.CheapShot:Cast(Unit) then return true end
                  end
                end
              end
            end
            if Setting("AutoBlind") and Spell.Blind:IsReady() and
                Unit:CanCC("stun") then
              if Spell.Blind:Cast(Unit) then return true end
            end
          end

          -- if Setting("AutoGouge") and Talent.Gouge and Spell.Gouge:IsReady() and thisUnit:Facing() and
          --     thisUnit:CanCC("incapacitate") then
          --   if Spell.Gouge:Cast(thisUnit) then return true end
          -- end
        end
      end
    end
    -- if Setting("AutoKick") and distance <= 5 and Spell.Kick:CDUp() then
    --   if canInterruptshit(thisUnit, false) then if Spell.Kick:Cast(thisUnit) then return true end end
    -- end
    -- if isBoss(thisUnit.Pointer) or thisUnit.Boss then return end
    -- if Player.SpecID == "Outlaw" and Setting("AutoGouge") and Spell.Gouge:CDUp() then
    --   if canInterruptshit(thisUnit, true, true) then
    --     if distance <= 5 and ObjectIsFacing(thisUnit.Pointer, Player.Pointer) then if Spell.Gouge:Cast(thisUnit) then return true end end
    --   end
    -- elseif Setting("AutoKidney") and Spell.KidneyShot:CDUp() and Player.ComboPoints > 0 then
    --   if canInterruptshit(thisUnit, true) then if distance <= 5 then if Spell.KidneyShot:Cast(thisUnit) then return true end end end
    -- elseif Setting("AutoCheapShot") and Spell.CheapShot:IsReady() then
    --   if canInterruptshit(thisUnit, true) then if distance <= 5 then if Spell.CheapShot:Cast(thisUnit) then return true end end end
    -- elseif Setting("AutoBlind") and distance <= 15 and Spell.Blind:CDUp() then
    --   if canInterruptshit(thisUnit, true) then if Spell.Blind:Cast(thisUnit) then return true end end
    -- end
  end
end

hooksecurefunc(DMW.Functions.AuraCache, "Event", function(...)
  local timeStamp, param, hideCaster, source, sourceName, sourceFlags, sourceRaidFlags, destination, destName, destFlags, destRaidFlags,
  spell, spellName, _, spellType = ...
  if DMW.Player.SpecID == "Outlaw" then
    if DMW.Time and DMW.Time - RtbCacheTime >= 3 and destination == DMW.Player.GUID and
        source == destination then
      if rtbcacheSpells[spell] then
        RtbCacheTime = DMW.Time;
        C_Timer.After(0.2, function() RtbCache() end)
      end
    end
    -- elseif DMW.Player.SpecID == "Subtlety" then
  end
end)


-- hooksecurefunc(DMW.Functions.AuraCache, "Update", function(...)
--     local bleedsCount = 0

-- end)
local function checkBleeds()
  local count = 0
  for _, Unit in ipairs(Player:GetEnemies(15)) do
    if Debuff.DeadlyPoison:Exist(Unit) then -- or Debuff.WoundPoison:Exist(Unit)
      if Debuff.Garrote:Exist(Unit) then count = count + 1 end
      if Debuff.Rupture:Exist(Unit) then count = count + 1 end
    end
  end
  return count
end

local function EnemiesInRange(Range) return select(2, Player:GetEnemies(Range)) end

local function BleedTickTime() return 2 / Player:SpellHaste() end

local function ExsanguinatedBleedTickTime() return 1 / Player:SpellHaste() end

local function AssassinationEnergyRegenCombined()
  -- actions+=/variable,name=energy_regen_combined,value=energy.regen+poisoned_bleeds*7%(2*spell_haste)
  local regen = select(1, GetPowerRegen()) and checkBleeds() * 7 / (2 * Player:SpellHaste());
  return regen
end

local function AssassinationEnergySaturated()
  return AssassinationEnergyRegenCombined() > 35
end

local function AssassinationSingleTarget()
  -- actions+=/variable,name=single_target,value=spell_targets.fan_of_knives<2
  return EnemyFOKcount < 2
end

local function AssassinationUseFiller()
  -- actions+=/variable,name=single_target,value=combo_points.deficit>1|energy.deficit<=25+variable.energy_regen_combined|!variable.single_target
  return not AssassinationSingleTarget() or Player.ComboPointsDeficit > 1 or
      Player.EnergyDeficit <= 25 + AssassinationEnergyRegenCombined()
end

local function AssassinationSkipCycleGarrote()
  -- # Limit Garrotes on non-primrary targets for the priority rotation if 5+ bleeds are already up
  -- actions.dot=variable,name=skip_cycle_garrote,value=priority_rotation&(dot.garrote.remains<cooldown.garrote.duration|variable.regen_saturated)
  return HUD.PriorityMode == 1 and
      (Debuff.Garrote:Remain(Target) <= Spell.Garrote.BaseCD or AssassinationEnergySaturated())
end

local function ToxicBladeCheck()
  for _, Unit in ipairs(EnemyMelee) do if Debuff.ToxicBlade:Exist(Unit) then return true end end
  return false
end

local function VendettaCheck()
  for _, Unit in ipairs(EnemyMelee) do if Debuff.Vendetta:Exist(Unit) then return true end end
  return false
end

local function AssassinationSkipCycleRupture()
  -- # Limit Ruptures on non-primrary targets for the priority rotation if 5+ bleeds are already up
  -- actions.dot+=/variable,name=skip_cycle_rupture,value=priority_rotation&(debuff.shiv.up&spell_targets.fan_of_knives>2|variable.regen_saturated)
  return HUD.PriorityMode == 1 and (AssassinationEnergySaturated() or EnemyFOKcount > 2 and Debuff.Shiv:Count() >= 1)
end

local function AssassinationSkipRupture()
  -- # Limit Ruptures if Vendetta+Toxic Blade/Master Assassin is up and we have 2+ seconds left on the Rupture DoT
  -- actions.dot+=/variable,name=skip_rupture,value=debuff.vendetta.up&(debuff.toxic_blade.up|master_assassin_remains>0)&dot.rupture.remains>2
  return VendettaCheck() and (Buff.MasterAssassin:Exist(Player) or ToxicBladeCheck()) and
      Debuff.Rupture:Remain(Target) > 2
end

local function AssassinationStealthedAPL()
  -- actions.stealthed=indiscriminate_carnage,if=spell_targets.fan_of_knives>desired_targets|spell_targets.fan_of_knives>1&raid_event.adds.in>60
  --!TODO
  -- # Improved Garrote: Apply or Refresh with buffed Garrotes
  -- actions.stealthed+=/pool_resource,for_next=1
  -- actions.stealthed+=/garrote,target_if=min:remains,if=stealthed.improved_garrote&!will_lose_exsanguinate&(remains<12%exsanguinated_rate|pmultiplier<=1)&target.time_to_die-remains>2
  if Spell.Garrote:IsCastable("Melee") and Buff.ImprovedGarrote:Exist() then
    for _, Unit in ipairs(EnemyMelee) do
      if (Debuff.Garrote:Remain(Unit) < 12 or Debuff.Garrote:Multiplier(Unit) <= 1) and
          Unit.TTD - Debuff.Garrote:Remain(Unit) > 2 then
        if Spell.Garrote:Pool() then return true end
        if Spell.Garrote:Cast(Unit) then return true end
      end
    end
  end
  -- # Improved Garrote + Exsg on 1T: Refresh Garrote at the end of stealth to get max duration before Exsanguinate
  -- actions.stealthed+=/pool_resource,for_next=1
  -- actions.stealthed+=/garrote,if=talent.exsanguinate.enabled&stealthed.improved_garrote&active_enemies=1&!will_lose_exsanguinate&improved_garrote_remains<1.3
  if Talent.Exsanguinate and CDs and Spell.Garrote:IsCastable("Melee")
      and Buff.ImprovedGarrote:Exist() and EnemyMeleeCount == 1 and Spell.Exsanguinate:CDUp() and
      Buff.ImprovedGarrote:Remain() < 1.3 then
    for _, Unit in ipairs(EnemyMelee) do
      if Spell.Garrote:Pool() then return true end
      if Spell.Garrote:Cast(Unit) then return true end
    end
  end






  -- -- # Stealthed Actions
  -- -- # Nighstalker on 1T: Snapshot Rupture
  -- -- actions.stealthed=rupture,if=talent.nightstalker.enabled&combo_points>=4&target.time_to_die-remains>6
  -- if Talent.Nightstalker then
  --   if Target and Player.ComboPoints >= 4 and Target.TTD > 6 then if Spell.Rupture:Cast(Target) then return true end end
  -- end
  -- -- # Subterfuge + Shrouded Suffocation: Ensure we use one global to apply Garrote to the main target if it is not snapshot yet, so all other main target abilities profit.
  -- -- actions.stealthed+=/pool_resource,for_next=1
  -- -- actions.stealthed+=/garrote,if=azerite.shrouded_suffocation.enabled&buff.subterfuge.up&buff.subterfuge.remains<1.3&!ss_buffed
  -- if Talent.Subterfuge and Spell.Garrote:CDUp() and Player:TraitActive("ShroudedSuffocation") and
  --     Buff.Subterfuge:Remain(Player) < 1.3 and
  --     Target and Target.ValidEnemy and Target.Distance <= 5 and not Debuff.Garrote:SSBuffed(Target) then
  --   if Spell.Garrote:Pool() then return true end
  --   if Spell.Garrote:Cast(Target) then return true end
  -- end
  -- -- # Subterfuge: Apply or Refresh with buffed Garrotes
  -- -- actions.stealthed+=/pool_resource,for_next=1
  -- -- actions.stealthed+=/garrote,target_if=min:remains,if=talent.subterfuge.enabled&(remains<12|pmultiplier<=1)&target.time_to_die-remains>2
  -- if Talent.Subterfuge and Spell.Garrote:CDUp() then
  --   for _, Unit in ipairs(EnemyMelee) do
  --     if (Debuff.Garrote:Remain(Unit) < 12 or Debuff.Garrote:Multiplier(Unit) <= 1) and
  --         Unit.TTD - Debuff.Garrote:Remain(Unit) > 2 then
  --       if Spell.Garrote:Pool() then return true end
  --       if Spell.Garrote:Cast(Unit) then return true end
  --     end
  --   end
  -- end
  -- -- # Subterfuge + Shrouded Suffocation in ST: Apply early Rupture that will be refreshed for pandemic
  -- -- actions.stealthed+=/rupture,if=talent.subterfuge.enabled&azerite.shrouded_suffocation.enabled&!dot.rupture.ticking&variable.single_target
  -- if Target and Talent.Subterfuge and Player:TraitActive("ShroudedSuffocation") and Player.ComboPoints > 0 and
  --     not Debuff.Rupture:Exist(Target) and AssassinationSingleTarget() then if Spell.Rupture:Cast(Target) then return true end end
  -- -- # Subterfuge w/ Shrouded Suffocation: Reapply for bonus CP and/or extended snapshot duration.
  -- -- actions.stealthed+=/pool_resource,for_next=1
  -- -- actions.stealthed+=/garrote,target_if=min:remains,if=talent.subterfuge.enabled&azerite.shrouded_suffocation.enabled&(active_enemies>1|!talent.exsanguinate.enabled)&target.time_to_die>remains&(remains<18|!ss_buffed)
  -- if Talent.Subterfuge and Player:TraitActive("ShroudedSuffocation") and Spell.Garrote:CDUp() and
  --     (EnemyMeleeCount > 1 or not Talent.Exsanguinate or HUD.TierSevenMode == 2) then
  --   for _, Unit in ipairs(EnemyMelee) do
  --     if (Debuff.Garrote:Remain(Unit) < 18 or not Debuff.Garrote:SSBuffed(Unit)) and
  --         Unit.TTD > Debuff.Garrote:Remain(Unit) then
  --       if Spell.Garrote:Pool() then return true end
  --       if Spell.Garrote:Cast(Unit) then return true end
  --     end
  --   end
  -- end
  -- -- # Subterfuge + Exsg on 1T: Refresh Garrote at the end of stealth to get max duration before Exsanguinate
  -- -- actions.stealthed+=/pool_resource,for_next=1
  -- -- actions.stealthed+=/garrote,if=talent.subterfuge.enabled&talent.exsanguinate.enabled&active_enemies=1&buff.subterfuge.remains<1.3
  -- if Target and Talent.Subterfuge and Talent.Exsanguinate and HUD.TierSevenMode == 1 and Spell.Garrote:CDUp() and
  --     EnemyMeleeCount == 1 and
  --     Buff.Subterfuge:Remain(Player) < 1.3 then
  --   if Spell.Garrote:Pool() then return true end
  --   if Spell.Garrote:Cast(Target) then return true end
  -- end
end

local RuptureRefreshes = { [4] = 6, [5] = 7.2, [6] = 8.4, [7] = 9.6 }

local CrimsonTempestRefreshes = { [4] = 3, [5] = 3.6, [6] = 4.2, [7] = 4.8 }

local function RuptureRefreshable(Unit)
  local RefreshTime = RuptureRefreshes[Player.ComboPoints]
  return RefreshTime and Debuff.Rupture:Remain(Unit) <= RefreshTime
end

local function CrimsonTempestRefreshable(Unit)
  local RefreshTime = CrimsonTempestRefreshes[Player.ComboPoints]
  return RefreshTime and Debuff.CrimsonTempest:Remain(Unit) <= RefreshTime
end

local function HoldGarrotesOnPull()
  return Setting("HoldGarrotesOnPull") and Player:TraitActive("EchoingBlades") and EnemyFOKcount >= 3 and
      Debuff.Rupture:Count(EnemyMelee) <
      EnemyMeleeCount
end

local function AssassinationDotAPL()
  -- #Limit secondary Garrotes for priority rotation if we have 35 energy regen or Garrote will expire on the primary target
  -- actions.dot=variable,name=skip_cycle_garrote,value=priority_rotation&(dot.garrote.remains<cooldown.garrote.duration|variable.regen_saturated)

  -- # Limit secondary Ruptures for priority rotation if we have 35 energy regen or Shiv is up on 2T+
  -- actions.dot+=/variable,name=skip_cycle_rupture,value=priority_rotation&(debuff.shiv.up&spell_targets.fan_of_knives>2|variable.regen_saturated)

  -- # Limit Ruptures when appropriate, not currently used
  -- actions.dot+=/variable,name=skip_rupture,value=0

  -- # Special Garrote and Rupture setup prior to Exsanguinate cast
  -- actions.dot+=/garrote,if=talent.exsanguinate.enabled&!will_lose_exsanguinate&dot.garrote.pmultiplier<=1&cooldown.exsanguinate.remains<2&spell_targets.fan_of_knives=1&raid_event.adds.in>6&dot.garrote.remains*0.5<target.time_to_die
  if Talent.Exsanguinate and CDs and Target and Debuff.Garrote:Multiplier(Target) <= 1 and Spell.Exsanguinate:CD() < 2
      and
      Debuff.Garrote:Remain(Target) * 0.5 < Target.TTD then
    if Spell.Garrote:Cast(Target) then return true end
  end
  -- actions.dot+=/rupture,if=talent.exsanguinate.enabled&!will_lose_exsanguinate&dot.rupture.pmultiplier<=1&cooldown.exsanguinate.remains<1&effective_combo_points>=variable.exsanguinate_rupture_cp&dot.rupture.remains*0.5<target.time_to_die
  if Talent.Exsanguinate and CDs and Target and Debuff.Rupture:Multiplier(Target) <= 1 and Spell.Exsanguinate:CD() < 1
      and
      ComboPoints == 7 and
      Debuff.Rupture:Remain(Target) * 0.5 < Target.TTD then
    if Spell.Rupture:Cast(Target) then return true end
  end
  -- # Garrote upkeep, also tries to use it as a special generator for the last CP before a finisher
  -- actions.dot+=/pool_resource,for_next=1
  -- actions.dot+=/garrote,if=refreshable&combo_points.deficit>=1&(pmultiplier<=1|remains<=tick_time&spell_targets.fan_of_knives>=3)&(!will_lose_exsanguinate|remains<=tick_time*2&spell_targets.fan_of_knives>=3)&(target.time_to_die-remains)>4&master_assassin_remains=0
  if Spell.Garrote:IsCastable("Melee") and (Player.ComboPointsDeficit >= 1 and ComboPoints ~= 7) then
    for _, Unit in ipairs(EnemyMelee) do
      if Debuff.Garrote:Remain(Unit) <= 5.4 and not Debuff.Garrote:Exsanguinated(Unit) and
          Debuff.Garrote:Multiplier(Unit) <= 1 and
          Unit.TTD - Debuff.Garrote:Remain(Unit) > 4 then
        if Spell.Garrote:Pool() then return true end
        if Spell.Garrote:Cast(Unit) then return true end
      end
    end
  end
  -- actions.dot+=/pool_resource,for_next=1
  -- actions.dot+=/garrote,cycle_targets=1,if=!variable.skip_cycle_garrote&target!=self.target&refreshable&combo_points.deficit>=1&(pmultiplier<=1|remains<=tick_time&spell_targets.fan_of_knives>=3)&(!will_lose_exsanguinate|remains<=tick_time*2&spell_targets.fan_of_knives>=3)&(target.time_to_die-remains)>12&master_assassin_remains=0
  if Spell.Garrote:IsCastable("Melee") and AssassinationSkipCycleGarrote() and
      (Player.ComboPointsDeficit >= 1 and ComboPoints ~= 7) then
    for _, Unit in ipairs(EnemyMelee) do
      if (not Target or Unit.GUID ~= Target.GUID) and Debuff.Garrote:Remain(Unit) <= 5.4 and
          not Debuff.Garrote:Exsanguinated(Unit) and
          Debuff.Garrote:Multiplier(Unit) <= 1 and
          Unit.TTD - Debuff.Garrote:Remain(Unit) > 4 then
        if Spell.Garrote:Pool() then return true end
        if Spell.Garrote:Cast(Unit) then return true end
      end
    end
  end
  -- # Crimson Tempest on multiple targets at 4+ CP when running out in 2-5s as long as we have enough regen and aren't setting up for Deathmark
  -- actions.dot+=/crimson_tempest,target_if=min:remains,if=spell_targets>=2&effective_combo_points>=4&energy.regen_combined>20&(!cooldown.deathmark.ready|dot.rupture.ticking)&remains<(2+3*(spell_targets>=4))
  if Talent.CrimsonTempest and Spell.CrimsonTempest:IsReady() and EnemyFOKcount >= 2 and ComboPoints >= 4 and
      AssassinationEnergyRegenCombined() > 20 and
      (Spell.DeathMark:CDDown() or (not Target or Debuff.Rupture:Exist(Target))) and
      Debuff.CrimsonTempest:Remain(Target) > (2 + 3 * num(EnemyFOKcount >= 4)) then
    if Spell.CrimsonTempest:Cast(Player) then return true end
  end
  -- # Keep up Rupture at 4+ on all targets (when living long enough and not snapshot)
  -- actions.dot+=/rupture,if=!variable.skip_rupture&effective_combo_points>=4&refreshable&(pmultiplier<=1|remains<=tick_time&spell_targets.fan_of_knives>=3)&(!will_lose_exsanguinate|remains<=tick_time*2&spell_targets.fan_of_knives>=3)&target.time_to_die-remains>(4+(talent.dashing_scoundrel*5)+(talent.doomblade*5)+(variable.regen_saturated*6))
  if Spell.Rupture:IsCastable("Melee") and ComboPoints >= 4 then
    for _, Unit in ipairs(EnemyMelee) do
      if not Debuff.Rupture:Exsanguinated(Unit) and
          RuptureRefreshable(Unit) and
          Unit.TTD - Debuff.Rupture:Remain(Unit) > 5 then
        if Spell.Rupture:Cast(Unit) then return true end
      end
    end
  end
  -- if Spell.Rupture:IsCastable("Melee")  and ComboPoints >= 4 and Target then
  --   for _, Unit in ipairs(EnemyMelee) do
  --     if (not Target or Unit.GUID ~= Target.GUID) and not Debuff.Garrote:Exsanguinated(Unit) and
  --         Debuff.Garrote:Multiplier(Unit) <= 1 and
  --         Unit.TTD - Debuff.Garrote:Remain(Unit) > 4 then
  --       if Spell.Rupture:Cast(Unit) then return true end
  --     end
  --   end
  -- end


  -- # Fallback AoE Crimson Tempest with the same logic as above, but ignoring the energy conditions if we aren't using Rupture
  -- actions.dot+=/crimson_tempest,if=spell_targets>=2&effective_combo_points>=4&remains<2+3*(spell_targets>=4)
  if Talent.CrimsonTempest and Spell.CrimsonTempest:IsReady() and ComboPoints >= 4 and EnemyFOKcount >= 2 then
    for _, Unit in ipairs(EnemyFOK) do
      if Debuff.CrimsonTempest:Remain(Unit) < (2 + 3 * num(EnemyFOKcount >= 4)) then
        if Spell.CrimsonTempest:Cast(Player) then return true end
      end
    end
  end
  -- # Crimson Tempest on ST if in pandemic and nearly max energy and if Envenom won't do more damage due to TB/MA
  -- actions.dot+=/crimson_tempest,if=spell_targets=1&!talent.dashing_scoundrel&effective_combo_points>=(cp_max_spend-1)&refreshable&!will_lose_exsanguinate&!debuff.shiv.up&debuff.amplifying_poison.stack<15&target.time_to_die-remains>4
  -- if Talent.CrimsonTempest and ComboPoints >= 4 and EnemyFOKcount == 1 and
  --     select(2, Debuff.CrimsonTempest:Lowest()) > (2 + 3 * num(EnemyMeleeCount >= 4)) then
  --   if























  -- -- # Damage over time abilities
  -- -- # Special Garrote and Rupture setup prior to Exsanguinate cast
  -- -- actions.dot+=/garrote,if=talent.exsanguinate.enabled&!exsanguinated.garrote&dot.garrote.pmultiplier<=1&cooldown.exsanguinate.remains<2&spell_targets.fan_of_knives=1&raid_event.adds.in>6&dot.garrote.remains*0.5<target.time_to_die
  -- if Talent.Exsanguinate and HUD.TierSevenMode == 1 and Target then
  --   if Spell.Exsanguinate:CD() < 2 and Debuff.Garrote:Multiplier(Target) <= 1 and EnemyFOKcount == 1 and
  --       Debuff.Garrote:Remain(Target) < 2 *
  --       Target.TTD then if Spell.Garrote:Cast(Target) then return true end end
  --   -- actions.dot+=/rupture,if=talent.exsanguinate.enabled&(combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1&dot.rupture.remains*0.5<target.time_to_die)
  --   if Player.ComboPointsDeficit == 0 and Spell.Exsanguinate:CD() < 1 and Debuff.Rupture:Remain(Target) < Target.TTD * 2 then
  --     if Spell.Rupture:Cast(Target) then return true end
  --   end
  -- end
  -- -- # Garrote upkeep, also tries to use it as a special generator for the last CP before a finisher
  -- -- actions.dot+=/pool_resource,for_next=1
  -- -- actions.dot+=/garrote,if=refreshable&combo_points.deficit>=1+3*(azerite.shrouded_suffocation.enabled&cooldown.vanish.up)&(pmultiplier<=1|remains<=tick_time&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&(!exsanguinated|remains<=tick_time*2&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&!ss_buffed&(target.time_to_die-remains)>4&(master_assassin_remains=0|!ticking&azerite.shrouded_suffocation.enabled)
  -- if Target and Target.ValidEnemy and Target.Distance <= 5 and
  --     (not Talent.Subterfuge or HUD.VanishMode == 2 or not (Spell.Vanish:CDUp() and Spell.Vendetta:CD() <= 4)) and
  --     Player.ComboPointsDeficit >=
  --     1 + 3 * num(Player:TraitActive("ShroudedSuffocation") and CDs and Spell.Vanish:CDUp()) then
  --   if Debuff.Garrote:Refresh(Target) and
  --       (
  --       Debuff.Garrote:Multiplier(Target) <= 1 or
  --           Debuff.Garrote:Remain(Target) <= BleedTickTime() and EnemiesInRange(10) >= 3 +
  --           num(Player:TraitActive("ShroudedSuffocation"))) and
  --       (
  --       not Debuff.Garrote:Exsanguinated(Target) or
  --           Debuff.Garrote:Remain(Target) <= ExsanguinatedBleedTickTime() * 2 and
  --           EnemiesInRange(10) >= 3 + num(Player:TraitActive("ShroudedSuffocation"))) and
  --       (Target.TTD - Debuff.Garrote:Remain(Target)) > 4 and
  --       not Debuff.Garrote:SSBuffed(Target) and
  --       (
  --       not Buff.MasterAssassin:Exist(Player) or
  --           (not Debuff.Garrote:Exist(Target) and Player:TraitActive("ShroudedSuffocation"))) then
  --     if Spell.Garrote:Pool() then return true end
  --     if Spell.Garrote:Cast(Target) then return true end
  --   end
  -- end
  -- -- actions.dot+=/pool_resource,for_next=1
  -- -- actions.dot+=/garrote,cycle_targets=1,if=!variable.skip_cycle_garrote&target!=self.target&refreshable&combo_points.deficit>=1+3*(azerite.shrouded_suffocation.enabled&cooldown.vanish.up)&(pmultiplier<=1|remains<=tick_time&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&(!exsanguinated|remains<=tick_time*2&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&!ss_buffed&(target.time_to_die-remains)>12&(master_assassin_remains=0|!ticking&azerite.shrouded_suffocation.enabled)
  -- if not AssassinationSkipCycleGarrote() and not HoldGarrotesOnPull() and
  --     (not Talent.Subterfuge or HUD.VanishMode == 2 or not (Spell.Vanish:CDUp() and Spell.Vendetta:CD() <= 4)) and
  --     Player.ComboPointsDeficit >=
  --     1 + 3 * num(Player:TraitActive("ShroudedSuffocation") and HUD.VanishMode == 1 and Spell.Vanish:CDUp()) then
  --   for _, Unit in pairs(EnemyMelee) do
  --     if (not Target or Unit.Pointer ~= Target.Pointer) and Debuff.Garrote:Refresh(Unit) and
  --         (Debuff.Garrote:Multiplier(Unit) <= 1 or
  --             (Debuff.Garrote:Remain(Unit) <= ExsanguinatedBleedTickTime() and EnemyFOKcount >= 3 +
  --                 num(Player:TraitActive("ShroudedSuffocation")))) and (not Debuff.Garrote:Exsanguinated(Unit) or
  --             (
  --             Debuff.Garrote:Remain(Unit) <= BleedTickTime() and
  --                 EnemyFOKcount >= 3 + num(Player:TraitActive("ShroudedSuffocation")))) and
  --         (Unit.TTD - Debuff.Garrote:Remain(Unit)) > 12 and not Debuff.Garrote:SSBuffed(Unit) and
  --         (
  --         not Buff.MasterAssassin:Exist(Player) or
  --             (not Debuff.Garrote:Exist(Unit) and Player:TraitActive("ShroudedSuffocation"))) then
  --       if Spell.Garrote:Pool() then return true end
  --       if Spell.Garrote:Cast(Unit) then return true end
  --     end
  --   end
  -- end
  -- -- # Crimson Tempest on multiple targets at 4+ CP when running out in 2s (up to 4 targets) or 3s (5+ targets)
  -- -- actions.dot+=/crimson_tempest,if=spell_targets>=2&remains<2+(spell_targets>=5)&combo_points>=4
  -- if Talent.CrimsonTempest and Player.ComboPoints >= 4 then
  --   if EnemyFOKcount >= 2 then
  --     -- local ctRemains = EnemyFOKcount <= 4 and 2 or 3
  --     for _, Unit in ipairs(EnemyFOK) do
  --       if Debuff.CrimsonTempest:Remain(Unit) <= 2 + num(EnemyFOKcount >= 5) then
  --         if Spell.CrimsonTempest:Cast(Player) then return true end
  --       end
  --     end
  --   end
  -- end
  -- -- # Keep up Rupture at 4+ on all targets (when living long enough and not snapshot)
  -- -- actions.dot+=/rupture,if=!variable.skip_rupture&(combo_points>=4&refreshable|!ticking&(time>10|combo_points>=2))&(pmultiplier<=1|remains<=tick_time&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&(!exsanguinated|remains<=tick_time*2&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&target.time_to_die-remains>4
  -- if Target and not AssassinationSkipRupture() and Player.ComboPoints >= 4 then
  --   -- for _, Unit in ipairs(EnemyMelee) do
  --   if RuptureRefreshable(Target) and (Target.TTD - Debuff.Rupture:Remain(Target)) > 4 and
  --       (
  --       Debuff.Rupture:Multiplier(Target) <= 1 or
  --           Debuff.Rupture:Remain(Target) <= BleedTickTime() and EnemiesInRange(10) >= 3 +
  --           num(Player:TraitActive("ShroudedSuffocation"))) and
  --       (
  --       not Debuff.Rupture:Exsanguinated(Target) or
  --           Debuff.Rupture:Remain(Target) <= ExsanguinatedBleedTickTime() * 2 and
  --           EnemiesInRange(10) >= 3 + num(Player:TraitActive("ShroudedSuffocation"))) then
  --     if Spell.Rupture:Cast(Target) then return true end
  --   end
  --   -- end
  -- end
  -- -- actions.dot+=/rupture,cycle_targets=1,if=!variable.skip_cycle_rupture&!variable.skip_rupture&target!=self.target&combo_points>=4&refreshable&(pmultiplier<=1|remains<=tick_time&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&(!exsanguinated|remains<=tick_time*2&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&target.time_to_die-remains>4
  -- if Spell.Rupture:IsCastable("Melee") and not AssassinationSkipCycleRupture() and not AssassinationSkipRupture() and
  --     Player.ComboPoints >=
  --     4 then
  --   for _, Unit in ipairs(EnemyMelee) do
  --     if (not Target or Unit.Pointer ~= Target.Pointer) and RuptureRefreshable(Unit) and
  --         (Debuff.Rupture:Multiplier(Unit) <= 1 or
  --             (Debuff.Rupture:Remain(Unit) <= ExsanguinatedBleedTickTime() and EnemyFOKcount >= 3 +
  --                 num(Player:TraitActive("ShroudedSuffocation")))) and (not Debuff.Rupture:Exsanguinated(Unit) or
  --             (
  --             Debuff.Rupture:Remain(Unit) <= BleedTickTime() and
  --                 EnemyFOKcount >= 3 + num(Player:TraitActive("ShroudedSuffocation")))) and
  --         (Unit.TTD - Debuff.Rupture:Remain(Unit)) >= 5 then if Spell.Rupture:Cast(Unit) then return true end end
  --   end
  -- end
  -- -- # Crimson Tempest on ST if in pandemic and it will do less damage than Envenom due to TB/MA/TtK
  -- -- actions.dot+=/crimson_tempest,if=spell_targets=1&combo_points>=(cp_max_spend-1)&refreshable&!exsanguinated&!debuff.toxic_blade.up&master_assassin_remains=0&!azerite.twist_the_knife.enabled&target.time_to_die-remains>4
  -- if Setting("CrimsonTempest ST") and Talent.CrimsonTempest and Target and AssassinationSingleTarget() and
  --     Player.ComboPointsDeficit <= 1 and
  --     CrimsonTempestRefreshable(Target) and not Debuff.ToxicBlade:Exist(Target) and not Buff.MasterAssassin:Exist(Player)
  --     and
  --     not Player.TraitActive("TwistTheKnife") and (Target.TTD - Debuff.CrimsonTempest:Remain(Target)) > 4 then
  --   if Spell.CrimsonTempest:Cast(Player) then return true end
  -- end
end

local function AssassinationDirectAPL()
  -- Envenom at 4+ (5+ with DS) CP. Immediately on 2+ targets, with Deathmark, or with TB; otherwise wait for some energy. Also wait if Exsg combo is coming up.
  -- actions.direct=envenom,if=effective_combo_points>=4+talent.deeper_stratagem.enabled&
  -- (debuff.deathmark.up|debuff.shiv.up|debuff.amplifying_poison.stack>=10|energy.deficit<=25+energy.regen_combined|!variable.single_target|effective_combo_points>cp_max_spend)
  -- &(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2|talent.resounding_clarity&(cooldown.echoing_reprimand.ready&combo_points>2|effective_combo_points>5))
  if Spell.Envenom:IsCastable("Melee") and ComboPoints >= 4 + num(Talent.DeeperStratagem) and
      (
        not Talent.Exsanguinate or Spell.Exsanguinate:CD() > 2 or
        Talent.ResoundingClarity and (Spell.EchoingReprimand:CDUp() and CDs and ComboPoints > 2 or ComboPoints > 5)
      )
  then
    for _, Unit in ipairs(EnemyMelee) do
      if Debuff.DeathMark:Exist(Unit) or Debuff.Shiv:Exist(Unit) or Debuff.AmplifyingPoison:Stacks(Unit) >= 10 then
        if Debuff.DeathMark:Exist(Unit) then
        end
        if Debuff.Shiv:Exist(Unit) then
        end
        if Debuff.AmplifyingPoison:Stacks(Unit) >= 10 then
        end
        if Spell.Envenom:Cast(Unit) then return true end
      end
    end
    if Player.EnergyDeficit <= 25 + AssassinationEnergyRegenCombined() or EnemyFOKcount > 2 or
        ComboPoints == 7 then
      for _, Unit in ipairs(EnemyMelee) do
        if Spell.Envenom:Cast(Unit) then return true end
      end
    end
  end
  -- actions.direct+=/variable,name=use_filler,value=combo_points.deficit>1|energy.deficit<=25+energy.regen_combined|!variable.single_target
  local useFiller = (Player.ComboPointsDeficit > 1 and ComboPoints ~= 7) or
      Player.EnergyDeficit <= 25 + AssassinationEnergyRegenCombined() or
      not AssassinationSingleTarget()
  -- # Apply SBS to all targets without a debuff as priority, preferring targets dying sooner after the primary target
  -- actions.direct+=/serrated_bone_spike,if=variable.use_filler&!dot.serrated_bone_spike_dot.ticking
  if useFiller then
    if Talent.SerratedBoneSpike and Spell.SerratedBoneSpike:CDUp() and useFiller then
      for _, Unit in ipairs(EnemyMelee) do
        if not Debuff.SerratedBoneSpike:Exist(Unit) then
          if Spell.SerratedBoneSpike:Cast(Unit) then return true end
        end
      end
    end
    -- actions.direct+=/serrated_bone_spike,target_if=min:target.time_to_die+(dot.serrated_bone_spike_dot.ticking*600),if=variable.use_filler&!dot.serrated_bone_spike_dot.ticking
    -- # Keep from capping charges or burn at the end of fights
    -- actions.direct+=/serrated_bone_spike,if=variable.use_filler&master_assassin_remains<0.8&(fight_remains<=5|cooldown.serrated_bone_spike.max_charges-charges_fractional<=0.25)
    if Talent.SerratedBoneSpike and Spell.SerratedBoneSpike:CDUp() and useFiller and
        Spell.SerratedBoneSpike:Charges() == 3 then
      for _, Unit in ipairs(EnemyMelee) do
        if not Debuff.SerratedBoneSpike:Exist(Unit) then
          if Spell.SerratedBoneSpike:Cast(Unit) then return true end
        end
      end
    end
    -- # When MA is not at high duration, sync with Shiv
    -- actions.direct+=/serrated_bone_spike,if=variable.use_filler&master_assassin_remains<0.8&!variable.single_target&debuff.shiv.up
    if Talent.SerratedBoneSpike and Spell.SerratedBoneSpike:CDUp() and useFiller and not AssassinationSingleTarget() then
      for _, Unit in ipairs(EnemyMelee) do
        if not Debuff.SerratedBoneSpike:Exist(Unit) and Debuff.Shiv:Exist(Unit) then
          if Spell.SerratedBoneSpike:Cast(Unit) then return true end
        end
      end
    end
    -- # Fan of Knives at 19+ stacks of Hidden Blades or against 4+ targets.
    -- actions.direct+=/fan_of_knives,if=variable.use_filler&(!priority_rotation&spell_targets.fan_of_knives>=3+stealthed.rogue+talent.dragontempered_blades)
    if Spell.FanOfKnives:CDUp() and useFiller and
        EnemyFOKcount >= 3 + num(stealthedRogue) + num(Talent.DragonTemperedBlades) then
      if Spell.FanOfKnives:Cast(Player) then return true end
    end
    -- # Fan of Knives to apply poisons if inactive on any target (or any bleeding targets with priority rotation) at 3T
    -- actions.direct+=/fan_of_knives,target_if=!dot.deadly_poison_dot.ticking&(!priority_rotation|dot.garrote.ticking|dot.rupture.ticking),if=variable.use_filler&spell_targets.fan_of_knives>=3
    if Spell.FanOfKnives:CDUp() and useFiller and
        EnemyFOKcount >= 3 then
      for _, Unit in ipairs(EnemyMelee) do
        if not Debuff.DeadlyPoison:Exist(Unit) and
            (not usePriorityRotation or Debuff.Garrote:Exist(Unit) or Debuff.Rupture:Exist(Unit)) then
          if Spell.FanOfKnives:Cast(Player) then return true end
        end
      end
    end
    -- actions.direct+=/echoing_reprimand,if=(!talent.exsanguinate|!talent.resounding_clarity)&variable.use_filler&cooldown.deathmark.remains>10|fight_remains<20
    if Talent.EchoingReprimand and Spell.EchoingReprimand:IsReady() and
        (not Talent.Exsanguinate or not Talent.ResoundingClarity) and useFiller and
        Spell.DeathMark:CD() > 10 then
      for _, Unit in ipairs(EnemyMelee) do
        if Spell.EchoingReprimand:Cast(Unit) then return true end
      end
    end
    -- actions.direct+=/ambush,if=variable.use_filler
    if Spell.Ambush:IsReady() and useFiller then
      for _, Unit in ipairs(EnemyMelee) do
        if Spell.Ambush:Cast(Unit) then return true end
      end
    end
    -- # Tab-Mutilate to apply Deadly Poison at 2 targets
    -- actions.direct+=/mutilate,target_if=!dot.deadly_poison_dot.ticking&!debuff.amplifying_poison.up,if=variable.use_filler&spell_targets.fan_of_knives=2
    if Spell.Mutilate:IsReady() and EnemyFOKcount == 2 and useFiller then
      for _, Unit in ipairs(EnemyMelee) do
        if not Debuff.DeadlyPoison:Exist(Unit) or not Debuff.AmplifyingPoison:Exist(Unit) then
          if Spell.Mutilate:Cast(Unit) then return true end
        end
      end
    end
    -- actions.direct+=/mutilate,if=variable.use_filler
    if Spell.Mutilate:IsReady() and useFiller then
      for _, Unit in ipairs(EnemyMelee) do
        if Spell.Mutilate:Cast(Unit) then return true end
      end
    end
  end













  -- -- # Direct damage abilities
  -- -- FOK when EP UP
  -- if (
  --     (Setting("FOK when EP up") and Buff.ElaboratePlanning:Exist()) or
  --         (Setting("FOK when Envenom up") and Buff.Envenom:Exist())) and
  --     not Buff.Stealth:Exist(Player) and Player:TraitActive("EchoingBlades") and
  --     EnemyFOKcount >= 2 + num(VendettaCheck()) +
  --     num(Player:TraitRank("EchoingBlades") == 1) then if Spell.FanOfKnives:Cast(Player) then return true end end
  -- -- # Envenom at 4+ (5+ with DS) CP. Immediately on 2+ targets, with Vendetta, or with TB; otherwise wait for some energy. Also wait if Exsg combo is coming up.
  -- -- actions.direct=envenom,if=combo_points>=4+talent.deeper_stratagem.enabled&(debuff.vendetta.up|debuff.toxic_blade.up|energy.deficit<=25+variable.energy_regen_combined|!variable.single_target)&(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)
  -- if Spell.Envenom:IsCastable("Melee") and Player.ComboPoints >= 4 + num(Talent.DeeperStratagem) and
  --     (not Talent.Exsanguinate or HUD.TierSevenMode == 2 or Spell.Exsanguinate:CD() > 2) then
  --   for _, Unit in ipairs(EnemyMelee) do
  --     if Debuff.Vendetta:Exist(Unit) or Debuff.ToxicBlade:Exist(Unit) or
  --         Player.EnergyDeficit <= 25 + AssassinationEnergyRegenCombined() or
  --         not AssassinationSingleTarget() or (Player.ComboPointsDeficit == 0 and Debuff.Garrote:Remain(Unit) <= 2) then
  --       if Spell.Envenom:Cast(Unit) then return true end
  --     end
  --   end
  -- end
  -- if AssassinationUseFiller() then
  --   -- # With Echoing Blades, Fan of Knives at 2+ targets, or 3-4+ targets when Vendetta is up
  --   -- actions.direct+=/fan_of_knives,if=variable.use_filler&azerite.echoing_blades.enabled&spell_targets.fan_of_knives>=2+(debuff.vendetta.up*(1+(azerite.echoing_blades.rank=1)))
  --   if Player:TraitActive("EchoingBlades") and not Buff.Stealth:Exist(Player) and
  --       EnemyFOKcount >= 2 + num(VendettaCheck()) +
  --       num(Player:TraitRank("EchoingBlades") == 1) then if Spell.FanOfKnives:Cast(Player) then return true end end
  --   -- # Fan of Knives at 19+ stacks of Hidden Blades or against 4+ (5+ with Double Dose) targets.
  --   -- actions.direct+=/fan_of_knives,if=variable.use_filler&(buff.hidden_blades.stack>=19|(!priority_rotation&spell_targets.fan_of_knives>=4+(azerite.double_dose.rank>2)+stealthed.rogue))
  --   if not Buff.Stealth:Exist(Player) and (Buff.HiddenBlades:Stacks() >= 19 or
  --       (HUD.PriorityMode == 2 and EnemyFOKcount >= 4 + num(Player:TraitRank("DoubleDose") > 2) + num(stealthedRogue))) then
  --     if Spell.FanOfKnives:Cast(Player) then return true end
  --   end
  --   -- # Fan of Knives to apply Deadly Poison if inactive on any target at 3 targets.
  --   -- actions.direct+=/fan_of_knives,target_if=!dot.deadly_poison_dot.ticking,if=variable.use_filler&spell_targets.fan_of_knives>=3
  --   if not Buff.Stealth:Exist(Player) and EnemyFOKcount >= 3 then
  --     for _, Unit in ipairs(EnemyFOK) do
  --       if not Debuff.DeadlyPoison:Exist(Unit) then if Spell.FanOfKnives:Cast(Player) then return true end end
  --     end
  --   end
  --   -- actions.direct+=/blindside,if=variable.use_filler&(buff.blindside.up|!talent.venom_rush.enabled&!azerite.double_dose.enabled)
  --   -- # Tab-Mutilate to apply Deadly Poison at 2 targets
  --   -- actions.direct+=/mutilate,target_if=!dot.deadly_poison_dot.ticking,if=variable.use_filler&spell_targets.fan_of_knives=2
  --   if Spell.Mutilate:IsCastable("Melee") and EnemyMeleeCount == 2 then
  --     for _, Unit in ipairs(EnemyMelee) do
  --       if not Debuff.DeadlyPoison:Exist(Unit) then if Spell.Mutilate:Cast(Unit) then return true end end
  --     end
  --   end
  --   -- actions.direct+=/mutilate,if=variable.use_filler
  --   if Spell.Mutilate:IsCastable("Melee") then for _, Unit in ipairs(EnemyMelee) do if Spell.Mutilate:Cast(Unit) then return true end end end
  -- end
end

local function AssassinationSND()
  -- actions+=/slice_and_dice,if=!buff.slice_and_dice.up&combo_points>=2|!talent.cut_to_the_chase&refreshable&combo_points>=4
  if Spell.SliceAndDice:IsReady() and (Target and Target.Dummy or Player.InGroup) then
    if not Buff.SliceAndDice:Exist() and ComboPoints >= 2 or
        not Talent.CutToTheChase and ComboPoints >= 4 and Buff.SliceAndDice:Remain() <= 0.3 * sndCP[ComboPoints] then
      if Spell.SliceAndDice:Cast(Player) then return true end
    end
  end
  -- actions+=/envenom,if=talent.cut_to_the_chase&buff.slice_and_dice.up&buff.slice_and_dice.remains<5&combo_points>=4
  if Spell.Envenom:IsCastable("Melee") then
    if Talent.CutToTheChase and ComboPoints >= 4 and Buff.SliceAndDice:Exist() and Buff.SliceAndDice:Remain() <= 5 then
      for _, Unit in ipairs(EnemyMelee) do
        if Spell.Envenom:Cast(Unit) then return true end
      end
    end
  end
end

-- # Vendetta logical conditionals based on current spec
local function VendettaSubterfugeCondition()
  -- actions.cds+=/variable,name=vendetta_subterfuge_condition,value=!talent.subterfuge.enabled|!azerite.shrouded_suffocation.enabled|dot.garrote.pmultiplier>1&(spell_targets.fan_of_knives<6|!cooldown.vanish.up)
  return Target and (not Talent.Subterfuge or not Player:TraitActive("ShroudedSuffocation") or
    (Debuff.Garrote:Multiplier(Target) > 1 and (EnemyFOKcount < 6 or (HUD.VanishMode == 2 or Spell.Vanish:CDDown()))))
end

local function VendettaNightstalkerCondition()
  -- actions.cds+=/variable,name=vendetta_nightstalker_condition,value=!talent.nightstalker.enabled|!talent.exsanguinate.enabled|cooldown.exsanguinate.remains<5-2*talent.deeper_stratagem.enabled
  -- return Target and
  return true
end

local function VendettaFontCondition()
  -- actions.cds+=/variable,name=variable,name=vendetta_font_condition,value=!equipped.azsharas_font_of_power|azerite.shrouded_suffocation.enabled|debuff.razor_coral_debuff.down|trinket.ashvanes_razor_coral.cooldown.remains<10&(cooldown.toxic_blade.remains<1|debuff.toxic_blade.up)
  -- return Target
  return true
end

local function SSVanishCondition()
  -- actions.cds+=/variable,name=ss_vanish_condition,value=azerite.shrouded_suffocation.enabled&(non_ss_buffed_targets>=1|spell_targets.fan_of_knives=3)&(ss_buffed_targets_above_pandemic=0|spell_targets.fan_of_knives>=6)
  if Player:TraitActive("ShroudedSuffocation") and EnemyMeleeCount > 0 then
    local nonSSbuffedCount, ssBuffedAbovePandemicCount = 0, 0
    for _, Unit in ipairs(EnemyMelee) do
      if Unit.TTD >= Setting("Vanish") and not Debuff.Garrote:SSBuffed(Unit) then
        nonSSbuffedCount = nonSSbuffedCount + 1
      else
        if not Debuff.Garrote:Refresh(Unit) then ssBuffedAbovePandemicCount = ssBuffedAbovePandemicCount + 1 end
      end
    end
    if (nonSSbuffedCount >= 1 or EnemyFOKcount == 3) and (ssBuffedAbovePandemicCount == 0 or EnemyFOKcount >= 6) then return true end
  end
  return false
end

local function vanishSSDeficitCP()
  if (1 + 2 * num(Player:TraitActive("ShroudedSuffocation"))) * EnemyMeleeCount >= 4 then return 4 end
  return (1 + 2 * num(Player:TraitActive("ShroudedSuffocation"))) * EnemyMeleeCount
end

local function AssassinationCooldownsAPL()
  --  actions.cds=marked_for_death,line_cd=1.5,target_if=min:target.time_to_die,if=raid_event.adds.up&(!variable.single_target|target.time_to_die<30)&(target.time_to_die<combo_points.deficit*1.5|combo_points.deficit>=cp_max_spend)
  -- # If no adds will die within the next 30s, use MfD for max CP.
  -- actions.cds+=/marked_for_death,if=raid_event.adds.in>30-raid_event.adds.duration&combo_points.deficit>=cp_max_spend
  -- # Sync Deathmark window with Exsanguinate if applicable
  -- actions.cds+=/variable,name=deathmark_exsanguinate_condition,value=!talent.exsanguinate|cooldown.exsanguinate.remains>15|exsanguinated.rupture|exsanguinated.garrote
  local deathMarkExsanguinateCondition = Target and
      (
        not Talent.Exsanguinate or Spell.Exsanguinate:CD() > 15 or Debuff.Rupture:Exsanguinated(Target) or
        Debuff.Garrote:Exsanguinated(Target))
  -- # Wait on Deathmark for Garrote with MA
  -- actions.cds+=/variable,name=deathmark_ma_condition,value=!talent.master_assassin.enabled|dot.garrote.ticking
  -- actions.cds+=/sepsis,if=!stealthed.rogue&dot.garrote.ticking&(target.time_to_die>10|fight_remains<10)
  -- # Deathmark to be used if not stealthed, Rupture is up, and all other talent conditions are satisfied
  -- actions.cds+=/variable,name=deathmark_condition,value=!stealthed.rogue&dot.rupture.ticking&!debuff.deathmark.up&variable.deathmark_exsanguinate_condition&variable.deathmark_ma_condition
  local deathmarkCondition = not stealthedRogue and Debuff.Rupture:Exist(Target) and deathMarkExsanguinateCondition
  -- # Sync the priority stat buff trinket with Deathmark, otherwise use on cooldown
  -- actions.cds+=/use_items,slots=trinket1,if=(variable.trinket_sync_slot=1&(debuff.deathmark.up|fight_remains<=20)|(variable.trinket_sync_slot=2&(!trinket.2.cooldown.ready|!debuff.deathmark.up&cooldown.deathmark.remains>20))|!variable.trinket_sync_slot)
  -- actions.cds+=/use_items,slots=trinket2,if=(variable.trinket_sync_slot=2&(debuff.deathmark.up|fight_remains<=20)|(variable.trinket_sync_slot=1&(!trinket.1.cooldown.ready|!debuff.deathmark.up&cooldown.deathmark.remains>20))|!variable.trinket_sync_slot)
  -- actions.cds+=/deathmark,if=variable.deathmark_condition
  if Target and Spell.DeathMark:IsReady() and deathmarkCondition then
    if Spell.DeathMark:Cast(Target) then return true end
  end
  -- actions.cds+=/kingsbane,if=(debuff.shiv.up|cooldown.shiv.remains<6)&buff.envenom.up&(cooldown.deathmark.remains>=50|dot.deathmark.ticking)
  if Talent.KingsBane and Spell.KingsBane:IsCastable("Melee") then
    if Buff.Envenom:Exist() and Spell.DeathMark:CD() >= 50 then
      if Spell.Shiv:CD() < 6 then
        for _, Unit in ipairs(EnemyMelee) do
          if Spell.KingsBane:Cast(Unit) then return true end
        end
      else
        for _, Unit in ipairs(EnemyMelee) do
          if Debuff.Shiv:Exist(Unit) then
            if Spell.KingsBane:Cast(Unit) then return true end
          end
        end
      end
    end
  end
  -- # Exsanguinate when not stealthed and both Rupture and Garrote are up for long enough. Attempt to sync with Echoing Reprimand if using Resounding Clarity.
  -- actions.cds+=/variable,name=exsanguinate_condition,value=talent.exsanguinate&!stealthed.rogue&!stealthed.improved_garrote&!dot.deathmark.ticking&target.time_to_die>cooldown.exsanguinate.remains+4
  local exsanguinateCondition = Target and Talent.Exsanguinate and not stealthedRogue and
      not Buff.ImprovedGarrote:Exist() and not Debuff.DeathMark:Exist(Target)
  -- actions.cds+=/echoing_reprimand,if=talent.exsanguinate&talent.resounding_clarity&(variable.exsanguinate_condition&combo_points<=2&cooldown.exsanguinate.remains<=2&!dot.garrote.refreshable&dot.rupture.remains>9.6|cooldown.exsanguinate.remains>40)
  if Target and Talent.Exsanguinate and Talent.ResoundingClarity and
      (
        exsanguinateCondition and ComboPoints <= 2 and Spell.Exsanguinate:CD() <= 2 and Debuff.Garrote:Remain(Target) > 5.4
        and Debuff.Rupture:Remain() > 9.6 or Spell.Exsanguinate:CD() > 40
      ) then
    if Spell.EchoingReprimand:Cast(Target) then return true end
  end
  -- actions.cds+=/exsanguinate,if=variable.exsanguinate_condition&(!dot.garrote.refreshable&dot.rupture.remains>4+4*variable.exsanguinate_rupture_cp|dot.rupture.remains*0.5>target.time_to_die)
  if Target and exsanguinateCondition and
      (Debuff.Garrote:Remain(Target) > 5.4 and Debuff.Rupture:Remain(Target) > 32) then
    if Spell.Exsanguinate:Cast(Target) then return true end
  end
  -- # Shiv if DoTs are up; Always Shiv with Kingsbane, otherwise attempt to sync with Sepsis or Deathmark if we won't waste more than half Shiv's cooldown
  -- actions.cds+=/shiv,if=talent.kingsbane&!debuff.shiv.up&dot.kingsbane.ticking&dot.garrote.ticking&dot.rupture.ticking&(!talent.crimson_tempest.enabled|variable.single_target|dot.crimson_tempest.ticking)
  if Talent.KingsBane and Spell.Shiv:IsReady() and Target and not Debuff.Shiv:Exist(Target) and
      Debuff.KingsBane:Exist(Target) and Debuff.Garrote:Exist(Target) and Debuff.Rupture:Exist(Target) and
      (not Talent.CrimsonTempest or AssassinationSingleTarget() or Debuff.CrimsonTempest:Exist()) then
    if Spell.Shiv:Cast(Target) then return true end
  end
  -- actions.cds+=/shiv,if=!talent.kingsbane&!talent.sepsis&!debuff.shiv.up&dot.garrote.ticking&dot.rupture.ticking&(!talent.crimson_tempest.enabled|variable.single_target|dot.crimson_tempest.ticking)
  if not Talent.KingsBane and not Talent.Sepsis and Spell.Shiv:IsReady() and Target and not Debuff.Shiv:Exist(Target) and
      Debuff.Garrote:Exist(Target) and Debuff.Rupture:Exist(Target) and
      (not Talent.CrimsonTempest or AssassinationSingleTarget() or Debuff.CrimsonTempest:Exist()) then
    if Spell.Shiv:Cast(Target) then return true end
  end
  -- actions.cds+=/shiv,if=!talent.kingsbane&talent.sepsis&!debuff.shiv.up&dot.garrote.ticking&dot.rupture.ticking&((cooldown.sepsis.ready|cooldown.sepsis.remains>12)+(cooldown.deathmark.ready|cooldown.deathmark.remains>12)=2)
  -- actions.cds+=/thistle_tea,if=!buff.thistle_tea.up&(energy.deficit>=100|charges=3&(dot.kingsbane.ticking|debuff.deathmark.up)|fight_remains<charges*6)
  if Talent.ThistleTea and Spell.ThistleTea:IsReady() and not Buff.ThistleTea:Exist() then
    if Player.EnergyDeficit >= 100 and GCD <= 0.15 then
      if Spell.ThistleTea:Cast(Player) then return true end
    end
    if Spell.ThistleTea:Charges() == 3 then
      for _, Unit in ipairs(EnemyMelee) do
        if (Debuff.KingsBane:Exist(Unit) or Debuff.DeathMark:Exist(Unit)) then
          if Spell.ThistleTea:Cast(Player) then return true end
        end
      end
    end
  end
  -- actions.cds+=/indiscriminate_carnage,if=(spell_targets.fan_of_knives>desired_targets|spell_targets.fan_of_knives>1&raid_event.adds.in>60)&(!talent.improved_garrote|cooldown.vanish.remains>45)
  --!TODO
  -- actions.cds+=/potion,if=buff.bloodlust.react|fight_remains<30|debuff.deathmark.up
  -- actions.cds+=/blood_fury,if=debuff.deathmark.up
  -- actions.cds+=/berserking,if=debuff.deathmark.up
  -- actions.cds+=/fireblood,if=debuff.deathmark.up
  -- actions.cds+=/ancestral_call,if=debuff.deathmark.up
  -- actions.cds+=/call_action_list,name=vanish,if=!stealthed.all&master_assassin_remains=0
  -- actions.cds+=/cold_blood,if=combo_points>=4














  -- actions.cds=use_item,name=azsharas_font_of_power,if=!stealthed.all&master_assassin_remains=0&(cooldown.vendetta.remains<?(cooldown.toxic_blade.remains*equipped.ashvanes_razor_coral))<10+10*equipped.ashvanes_razor_coral&!debuff.vendetta.up&!debuff.toxic_blade.up
  -- actions.cds+=/call_action_list,name=essences,if=!stealthed.all&dot.rupture.ticking&master_assassin_remains=0
  -- if Target and Target.ValidEnemy and not stealthedRogue and not Buff.MasterAssassin:Exist(Player) then
  --   if AssassinationEssencesAPL() then return true end
  -- end
  -- -- # If adds are up, snipe the one with lowest TTD. Use when dying faster than CP deficit or without any CP.
  -- -- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=raid_event.adds.up&(target.time_to_die<combo_points.deficit*1.5|combo_points.deficit>=cp_max_spend)
  -- -- # If no adds will die within the next 30s, use MfD on boss without any CP.
  -- -- actions.cds+=/marked_for_death,if=raid_event.adds.in>30-raid_event.adds.duration&combo_points.deficit>=cp_max_spend

  -- -- actions.cds+=/vendetta,if=!stealthed.rogue&dot.rupture.ticking&!debuff.vendetta.up&variable.vendetta_subterfuge_condition&variable.vendetta_nightstalker_condition&variable.vendetta_font_condition
  -- if Target and HUD.VendettaMode == 1 and Target.TTD >= Setting("Vendetta") and
  --     EnemyMeleeCount <= Setting("Vendetta Enemies") and
  --     Spell.Vendetta:CDUp() and not stealthedRogue and Debuff.Rupture:Exist(Target) and not Debuff.Vendetta:Exist(Target)
  --     and
  --     VendettaSubterfugeCondition() and VendettaNightstalkerCondition() and VendettaFontCondition() then
  --   if Spell.Vendetta:Cast(Target) then return true end
  -- end
  -- -- # Vanish with Exsg + Nightstalker: Maximum CP and Exsg ready for next GCD
  -- -- actions.cds+=/vanish,if=talent.exsanguinate.enabled&talent.nightstalker.enabled&combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1
  -- -- # Vanish with Nightstalker + No Exsg: Maximum CP and Vendetta up (unless using VoP)
  -- -- actions.cds+=/vanish,if=talent.nightstalker.enabled&!talent.exsanguinate.enabled&combo_points>=cp_max_spend&(debuff.vendetta.up|essence.vision_of_perfection.enabled)
  -- -- # See full comment on https://github.com/Ravenholdt-TC/Rogue/wiki/Assassination-APL-Research.

  -- -- actions.cds+=/pool_resource,for_next=1,extra_amount=45
  -- -- actions.cds+=/vanish,if=talent.subterfuge.enabled&!stealthed.rogue&cooldown.garrote.up&(variable.ss_vanish_condition|!azerite.shrouded_suffocation.enabled&(dot.garrote.refreshable|debuff.vendetta.up&dot.garrote.pmultiplier<=1))&combo_points.deficit>=((1+2*azerite.shrouded_suffocation.enabled)*spell_targets.fan_of_knives)>?4&raid_event.adds.in>12
  -- if Talent.Subterfuge and HUD.VanishMode == 1 and Player.Combat and not stealthedRogue and Spell.Vanish:CDUp() and
  --     Spell.Garrote:CDUp() and
  --     (SSVanishCondition() or not Player:TraitActive("ShroudedSuffocation")) and
  --     Player.ComboPointsDeficit >= vanishSSDeficitCP() then
  --   if Spell.Garrote:Pool() then return true end
  --   if GCD <= 0.2 then if Spell.Vanish:Cast(Player) then return true end end
  -- end
  -- -- # Vanish with Master Assasin: No stealth and no active MA buff, Rupture not in refresh range, during Vendetta+TB+BotE (unless using VoP)
  -- -- actions.cds+=/vanish,if=talent.master_assassin.enabled&!stealthed.all&master_assassin_remains<=0&!dot.rupture.refreshable&dot.garrote.remains>3&(debuff.vendetta.up&(!talent.toxic_blade.enabled|debuff.toxic_blade.up)&(!essence.blood_of_the_enemy.major|debuff.blood_of_the_enemy.up)|essence.vision_of_perfection.enabled)
  -- -- # Shadowmeld for Shrouded Suffocation
  -- -- actions.cds+=/shadowmeld,if=!stealthed.all&azerite.shrouded_suffocation.enabled&dot.garrote.refreshable&dot.garrote.pmultiplier<=1&combo_points.deficit>=1
  -- -- # Exsanguinate when not stealthed and both Rupture and Garrote are up for long enough.
  -- -- actions.cds+=/exsanguinate,if=!stealthed.rogue&(!dot.garrote.refreshable&dot.rupture.remains>4+4*cp_max_spend|dot.rupture.remains*0.5>target.time_to_die)&target.time_to_die>4
  -- if Talent.Exsanguinate and HUD.TierSevenMode == 1 and Target and not stealthedRogue and
  --     (
  --     not Debuff.Garrote:Refresh(Target) and Debuff.Rupture:Remain(Target) > 4 + 4 * (4 + num(Talent.DeeperStratagem)) or
  --         Debuff.Rupture:Remain(Target) > 2 * Target.TTD) and Target.TTD > 4 then if Spell.Exsanguinate:Cast(Target) then return true end end
  -- -- actions.cds+=/toxic_blade,if=dot.rupture.ticking&(!equipped.azsharas_font_of_power|cooldown.vendetta.remains>10)
  -- if Talent.ToxicBlade and HUD.TierSevenMode == 1 and Spell.ToxicBlade:CDUp() and
  --     EnemyMeleeCount <= Setting("Toxic Blade Enemies") and
  --     Target and Target.TTD >= Setting("Toxic Blade") and Debuff.Rupture:Exist(Target) then
  --   if Spell.ToxicBlade:Cast(Target) then return true end
  -- end
  -- -- actions.cds+=/potion,if=buff.bloodlust.react|debuff.vendetta.up
  -- -- actions.cds+=/blood_fury,if=debuff.vendetta.up
  -- -- actions.cds+=/berserking,if=debuff.vendetta.up
  -- -- actions.cds+=/fireblood,if=debuff.vendetta.up
  -- -- actions.cds+=/ancestral_call,if=debuff.vendetta.up
  -- -- actions.cds+=/use_item,name=galecallers_boon,if=(debuff.vendetta.up|(!talent.exsanguinate.enabled&cooldown.vendetta.remains>45|talent.exsanguinate.enabled&(cooldown.exsanguinate.remains<6|cooldown.exsanguinate.remains>20&fight_remains>65)))&!exsanguinated.rupture
  -- -- actions.cds+=/use_item,name=ashvanes_razor_coral,if=debuff.razor_coral_debuff.down|target.time_to_die<20
  -- -- actions.cds+=/use_item,name=ashvanes_razor_coral,if=(!talent.exsanguinate.enabled|!talent.subterfuge.enabled)&debuff.vendetta.remains>10-4*equipped.azsharas_font_of_power
  -- -- actions.cds+=/use_item,name=ashvanes_razor_coral,if=(talent.exsanguinate.enabled&talent.subterfuge.enabled)&debuff.vendetta.up&(exsanguinated.garrote|azerite.shrouded_suffocation.enabled&dot.garrote.pmultiplier>1)
  -- -- actions.cds+=/use_item,effect_name=cyclotronic_blast,if=master_assassin_remains=0&!debuff.vendetta.up&!debuff.toxic_blade.up&buff.memory_of_lucid_dreams.down&energy<80&dot.rupture.remains>4
  -- -- actions.cds+=/use_item,name=lurkers_insidious_gift,if=debuff.vendetta.up
  -- -- actions.cds+=/use_item,name=lustrous_golden_plumage,if=debuff.vendetta.up
  -- -- actions.cds+=/use_item,effect_name=gladiators_medallion,if=debuff.vendetta.up
  -- -- actions.cds+=/use_item,effect_name=gladiators_badge,if=debuff.vendetta.up
  -- -- # Default fallback for usable items: Use on cooldown.
  -- -- actions.cds+=/use_items
end

local function OutlawExplosives()
  if HUD.Info == 2 or Setting("Always Take Care of Explosives") then
    for _, Unit in ipairs(DMW.Attackable) do
      if Unit.ObjectID == 120651 and Unit.Distance <= 5 then
        if OutlawShouldFinish() then
          if Spell.Dispatch:Cast(Unit) then return true end
        else
          if Buff.Opportunity:Exist(Player) then
            if Spell.PistolShot:Cast(Unit) then return true end
          end
          if Spell.SinisterStrike:Cast(Unit) then return true end
        end
      end
    end
  end
end

local function AssassinationExplosives()
  if HUD.Info == 2 or Setting("Always Take Care of Explosives") then
    for _, Unit in ipairs(EnemyMelee) do
      if Unit.ObjectID == 120651 then
        if Player.ComboPointsDeficit <= 1 then
          if Spell.Envenom:Cast(Unit) then return true end
        else
          if Spell.Mutilate:Pool() or Spell.Mutilate:Cast(Unit) then return true end
        end
      end
    end
  end
end

local oldFacing, MouselookActive
local function BestRektCheck()
  local currentCount = Player:GetEnemiesRect(20, 3)
  local bestAngle, bestCount = Player:GetBestEnemiesRect(20, 3)
  if bestCount > currentCount then
    -- print(bestCount)
    if DMW.Settings.profile.Enemy.AutoFace then
      oldFacing = ObjectFacing("Player")
      MouselookActive = false
      if IsMouselooking() then
        MouselookActive = true
        MouselookStop()
      end
      FaceDirection(bestAngle, true)
      return true
    end
  end
end

local function MarkOfDeathAOE()
  local lowestTTD, lowestTTDUnit
  for _, Unit in ipairs(Enemy30Y) do
    if Unit.TTD and (not lowestTTD or Unit.TTD < lowestTTD) and Unit.Health <= 2500 then
      lowestTTD = Unit.TTD
      lowestTTDUnit = Unit
    end
  end
  if lowestTTDUnit and lowestTTD <= 1 then if Spell.MarkedForDeath:Cast(lowestTTDUnit) then return true end end
end

local function SubtletyFinisher()
  -- actions.finish=variable,name=premed_snd_condition,value=talent.premeditation.enabled&spell_targets.shuriken_storm<5
  local premedSndCondition = Talent.Premeditation and Enemy10YC < 5
  -- actions.finish+=/slice_and_dice,if=!variable.premed_snd_condition&spell_targets.shuriken_storm<6&!buff.shadow_dance.up&buff.slice_and_dice.remains<fight_remains&refreshable
  if not premedSndCondition and Enemy10YC < 6 and not isShadowDanced() and not isVanished() and
      Buff.SliceAndDice:Remain() < 20 and SnDRefresh() then
    if Spell.SliceAndDice:Cast() then return true end
  end
  -- actions.finish+=/slice_and_dice,if=variable.premed_snd_condition&cooldown.shadow_dance.charges_fractional<1.75&buff.slice_and_dice.remains<cooldown.symbols_of_death.remains&(cooldown.shadow_dance.ready&buff.symbols_of_death.remains-buff.shadow_dance.remains<1.2)
  -- if premedSndCondition and Spell.ShadowDance:ChargesFrac() < 1.75 and
  --     Buff.SliceAndDice:Remain() < Spell.SymbolsOfDeath:CD() and
  --     (Spell.ShadowDance:CDUp() and Buff.SymbolsOfDeath:Remain() - Buff.ShadowDance:Remain() < 1.2) then
  --   if Spell.SliceAndDice:Cast() then return true end
  -- end
  -- actions.finish+=/variable,name=skip_rupture,value=buff.thistle_tea.up&spell_targets.shuriken_storm=1|buff.shadow_dance.up&(spell_targets.shuriken_storm=1|dot.rupture.ticking&spell_targets.shuriken_storm>=2)
  local skipRupture = HUD.RuptureMode == 2 or Buff.ThistleTea:Exist() and Enemy10YC == 1 or
      isShadowDanced() and (Enemy10YC == 1 or Debuff.Rupture:Count() >= 1 and Enemy10YC >= 2)
  -- # Keep up Rupture if it is about to run out.
  -- actions.finish+=/rupture,if=(!variable.skip_rupture|variable.priority_rotation)&target.time_to_die-remains>6&refreshable
  if (not skipRupture or usePriorityRotation) and Spell.Rupture:IsReady() and not isShadowDanced() then
    if Talent.ReplicatingShadows then
      if EnemyMeleeCount > 1 then
        local closestTarget, closestDistance
        for _, Unit in ipairs(EnemyMelee) do
          Unit.Distance2D = Unit:GetDistance3D()
          if closestDistance == nil or Unit.Distance2D < closestDistance then
            closestDistance = Unit.Distance2D
            closestTarget = Unit
          end
        end
        if closestTarget then
          if closestTarget.TTD - Debuff.Rupture:Remain(closestTarget) > 6 and RuptureRefreshable(closestTarget)
              and closestTarget.Health >= RuptureHP then
            for _, Unit in ipairs(EnemyMelee) do
              if Unit.GUID ~= closestTarget.GUID and Unit.TTD - Debuff.Rupture:Remain(Unit) > 6 and
                  RuptureRefreshable(Unit)
                  and Unit.Health >= RuptureHP then
                if Spell.Rupture:Cast(Unit) then return true end
              end
            end
          end
          -- if closestTarget.TTD - Debuff.Rupture:Remain(closestTarget) > 6 and RuptureRefreshable(closestTarget)
          --     and closestTarget.Health >= RuptureHP then
          --   if Spell.Rupture:Cast(closestTarget) then return true end
          -- end
        end
      else
        for _, Unit in ipairs(EnemyMelee) do
          if Unit.TTD - Debuff.Rupture:Remain(Unit) > 6 and RuptureRefreshable(Unit) and Unit.Health >= RuptureHP then
            if Spell.Rupture:Cast(Unit) then return true end
          end
        end
      end
    else
      for _, Unit in ipairs(EnemyMelee) do
        if Unit.TTD - Debuff.Rupture:Remain(Unit) > 6 and RuptureRefreshable(Unit) and Unit.Health >= RuptureHP then
          if Spell.Rupture:Cast(Unit) then return true end
        end
      end
    end
  end
  -- # Refresh Rupture early for Finality
  -- actions.finish+=/rupture,if=!variable.skip_rupture&buff.finality_rupture.up&cooldown.shadow_dance.remains<12&cooldown.shadow_dance.charges_fractional<=1&spell_targets.shuriken_storm=1&(talent.dark_brew|talent.danse_macabre)
  if (not skipRupture and Buff.FinalityRupture:Exist()) and Spell.ShadowDance:CD() < 12 and (CDs or HUD.BurstMode == 1)
      and
      Spell.ShadowDance:ChargesFrac() <= 1 and Enemy10YC == 1 and (Talent.DanseMacabre or Talent.DarkBrew) and
      Spell.Rupture:IsReady() then
    for _, Unit in ipairs(EnemyMelee) do
      if Unit.TTD - Debuff.Rupture:Remain(Unit) > 6 and not Debuff.Rupture:Exist(Unit) and Unit.Health >= RuptureHP then
        if Spell.Rupture:Cast(Unit) then return true end
      end
    end
    for _, Unit in ipairs(EnemyMelee) do
      if Unit.TTD - Debuff.Rupture:Remain(Unit) > 6 and RuptureRefreshable(Unit) and Unit.Health >= RuptureHP then
        if Spell.Rupture:Cast(Unit) then return true end
      end
    end
    for _, Unit in ipairs(EnemyMelee) do
      if Unit.TTD - Debuff.Rupture:Remain(Unit) > 6 and Unit.Health >= RuptureHP then
        if Spell.Rupture:Cast(Unit) then return true end
      end
    end
  end
  -- # Sync Cold Blood with Secret Technique when possible
  -- actions.finish+=/cold_blood,if=buff.shadow_dance.up&(buff.danse_macabre.stack>=3|!talent.danse_macabre)&cooldown.secret_technique.ready
  -- actions.finish+=/secret_technique,if=buff.shadow_dance.up&(buff.danse_macabre.stack>=3|!talent.danse_macabre)&(!talent.cold_blood|cooldown.cold_blood.remains>buff.shadow_dance.remains-2)
  if CDs and GCD <= 0.15 and (Talent.ThistleTea and Spell.ThistleTea:Charges() >= 1 and Spell.SymbolsOfDeath:CD() >= 3 and
        not isThistleTeaed() and
        (Player.EnergyDeficit >= 100 or Spell.ThistleTea:ChargesFrac() >= 2.75 and isShadowDanced()) or
        Buff.ShadowDance:Remain() >= 4 and not isThistleTeaed() and Enemy10YC >= 3) then
    if Spell.ThistleTea:Cast(Player) then thistleTeaedTime = DMW.Time end
  end
  if Spell.SecretTechnique:IsReady() and Player.ComboPointsDeficit == 0 and isShadowDanced() and
      (Buff.DanseMacabre:Stacks() >= 3 or not Talent.DanseMacabre) and
      (not Talent.ColdBlood or Spell.ColdBlood:CD() > Buff.ShadowDance:Remain() or Spell.ColdBlood:CDUp()) then
    if Spell.ColdBlood:IsReady() then
      Spell.ColdBlood:Cast(Player)
    end
    -- local closestTarget, closestDistance
    -- for _, Unit in ipairs(EnemyMelee) do
    --   Unit.Distance2D = Unit:GetDistance3D()
    --   if closestDistance == nil or Unit.Distance2D < closestDistance then
    --     closestDistance = Unit.Distance2D
    --     closestTarget = Unit
    --   end
    -- end
    -- if Target and Target.ValidEnemy then
    --   print(Target:GetDistance3D())
    for _, Unit in ipairs(EnemyMelee) do
      if Spell.SecretTechnique:Cast(Unit) then return true end
    end
    -- end
  end
  -- # Multidotting targets that will live for the duration of Rupture, refresh during pandemic.
  -- actions.finish+=/rupture,cycle_targets=1,if=!variable.skip_rupture&!variable.priority_rotation&spell_targets.shuriken_storm>=2&target.time_to_die>=(2*combo_points)&refreshable
  if (not skipRupture and not usePriorityRotation) and Enemy10YC >= 2 and Spell.Rupture:IsReady() then
    if Talent.ReplicatingShadows then
      local closestTarget, closestDistance
      for _, Unit in ipairs(EnemyMelee) do
        Unit.Distance2D = Unit:GetDistance2D()
        if closestDistance == nil or Unit.Distance2D < closestDistance then
          closestDistance = Unit.Distance2D
          closestTarget = Unit
        end
      end
      if closestTarget then
        if closestTarget.TTD > Player.ComboPoints * 2 and RuptureRefreshable(closestTarget)
            and closestTarget.Health >= RuptureHP then
          for _, Unit in ipairs(EnemyMelee) do
            if Unit.GUID ~= closestTarget.GUID and Unit.TTD >= Player.ComboPoints * 2 and
                RuptureRefreshable(Unit)
                and Unit.Health >= RuptureHP then
              if Spell.Rupture:Cast(Unit) then return true end
            end
          end
        end
        -- if closestTarget.TTD > 6 and RuptureRefreshable(closestTarget)
        --     and closestTarget.Health >= RuptureHP then
        --   if Spell.Rupture:Cast(closestTarget) then return true end
        -- end
      end
    else
      for _, Unit in ipairs(EnemyMelee) do
        if Unit.TTD >= Player.ComboPoints * 2 and RuptureRefreshable(Unit) and Unit.Health >= RuptureHP then
          if Spell.Rupture:Cast(Unit) then return true end
        end
      end
    end
  end
  -- # Refresh Rupture early if it will expire during Symbols. Do that refresh if SoD gets ready in the next 5s.
  -- actions.finish+=/rupture,if=!variable.skip_rupture&remains<cooldown.symbols_of_death.remains+10&cooldown.symbols_of_death.remains<=5&target.time_to_die-remains>cooldown.symbols_of_death.remains+5
  if Target and Target.Health >= RuptureHP and not skipRupture and Enemy10YC == 1 and Spell.Rupture:IsReady() then
    if Debuff.Rupture:Remain(Target) < Spell.SymbolsOfDeath:CD() + 10 and Spell.SymbolsOfDeath:CD() <= 5 and
        Target.TTD - Debuff.Rupture:Remain() > Spell.SymbolsOfDeath:CD() + 5 then
      if Spell.Rupture:Cast(Target) then return true end
    end
  end
  -- actions.finish+=/black_powder,if=!variable.priority_rotation&spell_targets>=3
  if Spell.BlackPowder:IsReady() and Enemy10YC >= 3 and not usePriorityRotation then
    if Spell.BlackPowder:Cast(Player) then return true end
  end
  -- actions.finish+=/eviscerate

  if Spell.Eviscerate:IsReady() then
    if HUD.PriorityMode == 2 then
      table.sort(
        EnemyMelee,
        function(x, y)
          return x.Health > y.Health
        end
      )
      for _, Unit in ipairs(EnemyMelee) do
        if Debuff.FindWeakness:Exist(Unit) then
          if Spell.Eviscerate:Cast(Unit) then return true end
        end
      end
      for _, Unit in ipairs(EnemyMelee) do
        if Spell.Eviscerate:Cast(Unit) then return true end
      end
    elseif HUD.PriorityMode == 1 then
      if Target and Target.ValidEnemy and Target.Distance < 5 then
        if Spell.Eviscerate:Cast(Target) then return true end
      end
      for _, Unit in ipairs(EnemyMelee) do
        if Debuff.FindWeakness:Exist(Unit) then
          if Spell.Eviscerate:Cast(Unit) then return true end
        end
      end
      for _, Unit in ipairs(EnemyMelee) do
        if Spell.Eviscerate:Cast(Unit) then return true end
      end
    end
  end

  if Spell.BlackPowder:IsReady() and Enemy10YC >= 3 then
    if Spell.BlackPowder:Cast(Player) then return true end
  end
  if Spell.Eviscerate:IsReady() then
    for _, Unit in ipairs(EnemyMelee) do
      if Debuff.FindWeakness:Exist(Unit) then
        if Spell.Eviscerate:Cast(Unit) then return true end
      end
    end
    for _, Unit in ipairs(EnemyMelee) do
      if Spell.Eviscerate:Cast(Unit) then return true end
    end
  end
end

local function SubtletyBuilder()
  -- actions.build=shuriken_storm,if=spell_targets>=2+(buff.lingering_shadow.remains>=6|buff.perforated_veins.up)
  -- # Build immediately unless the next CP is Animacharged and we won't cap energy waiting for it.
  -- actions.build+=/variable,name=anima_helper,value=!talent.echoing_reprimand.enabled|!(variable.is_next_cp_animacharged&(time_to_sht.3.plus<0.5|time_to_sht.4.plus<1)&energy<60)
  -- actions.build+=/gloomblade,if=variable.anima_helper
  -- actions.build+=/backstab,if=variable.anima_helper
  if Spell.ShurikenStorm:IsReady() and
      Enemy10YC >= 2 + num(Buff.LingeringShadow:Remain() >= 6 or Buff.PerforatedVeins:Exist()) then
    if Spell.ShurikenStorm:Cast(nil, nil, true) then return true end
  end
  local animaHelper = not Talent.EchoingReprimand
  if animaHelper then
    if Talent.GloomBlade then
      if Spell.GloomBlade:IsReady() then
        for _, Unit in ipairs(EnemyMelee) do
          if Spell.GloomBlade:Cast(Unit) then return true end
        end
      end
    else
      if Spell.Backstab:IsReady() then
        for _, Unit in ipairs(EnemyMelee) do
          if Spell.Backstab:Cast(Unit) then return true end
        end
      end
    end
  end
end

local function SubtletyStealthed()
  -- # Stealthed Rotation  If Stealth/vanish are up, use Shadowstrike to benefit from the passive bonus and Find Weakness, even if we are at max CP (unless using Master Assassin)
  -- actions.stealthed=shadowstrike,if=(buff.stealth.up|buff.vanish.up)&(spell_targets.shuriken_storm<4|variable.priority_rotation)
  if isVanished() and Spell.ShadowStrike:IsReady() then
    for _, Unit in ipairs(EnemyMelee) do
      if Spell.ShadowStrike:Cast(Unit) then return true end
    end
  end

  if Spell.ShadowStrike:IsReady() and isShadowDanced() and Spell.SecretTechnique:CD() <= 4 and Buff.Premeditation:Exist() and Enemy10YC < 7 and Player.ComboPoints <= 1 and Buff.SliceAndDice:Exist() then
    for _, Unit in ipairs(EnemyMelee) do
      if Spell.ShadowStrike:Cast(Unit) then return true end
    end
  end
  -- # Variable to Gloomblade / Backstab when on 4 or 5 combo points with premediation and when the combo point is not anima charged
  -- actions.stealthed+=/variable,name=gloomblade_condition,value=buff.danse_macabre.stack<5&(combo_points.deficit=2|combo_points.deficit=3)&(buff.premeditation.up|effective_combo_points<7)&(spell_targets.shuriken_storm<=8|talent.lingering_shadow)
  local gloombladeCondition = Buff.DanseMacabre:Stacks() < 5 and
      (Player.ComboPointsDeficit == 2 or Player.ComboPointsDeficit == 3) and
      (Buff.Premeditation:Exist() or Player.ComboPoints < 7) and (Talent.LingeringShadow or Enemy10YC <= 8)
  -- actions.stealthed+=/shuriken_storm,if=variable.gloomblade_condition&buff.silent_storm.up&!debuff.find_weakness.remains&talent.improved_shuriken_storm.enabled
  if gloombladeCondition and EnemyMeleeCount <= 2 and Buff.SilentStorm:Exist() and Talent.ImprovedShurikenStorm and
      Spell.ShurikenStorm:IsReady() then
    for _, Unit in ipairs(Enemy10Y) do
      if not Debuff.FindWeakness:Exist(Unit) then
        if Spell.ShurikenStorm:Cast(nil, nil, true) then return true end
      end
    end
  end
  -- actions.stealthed+=/gloomblade,if=variable.gloomblade_condition
  if Talent.GloomBlade then
    if gloombladeCondition and Spell.GloomBlade:IsReady() and Enemy10YC == 1 then
      for _, Unit in ipairs(EnemyMelee) do
        if Spell.GloomBlade:Cast(Unit) then return true end
      end
    else
      -- actions.stealthed+=/backstab,if=variable.gloomblade_condition&talent.danse_macabre&buff.danse_macabre.stack<=2&spell_targets.shuriken_storm<=2
      if gloombladeCondition and Talent.DanseMacabre and Buff.DanseMacabre:Stacks() <= 2 and Enemy10YC <= 2 and
          Spell.Backstab:IsReady() then
        for _, Unit in ipairs(EnemyMelee) do
          if Spell.Backstab:Cast(Unit) then return true end
        end
      end
    end
  end
  -- actions.stealthed+=/call_action_list,name=finish,if=variable.effective_combo_points>=cp_max_spend
  if Player.ComboPoints >= Player.ComboPointsMax then
    if SubtletyFinisher() then return true end
    return
  end
  -- # Finish earlier with Shuriken tornado up.
  -- actions.stealthed+=/call_action_list,name=finish,if=buff.shuriken_tornado.up&combo_points.deficit<=2
  if tornadoTime and Enemy10YC >= 4 and Player.ComboPointsDeficit <= 2 then
    if SubtletyFinisher() then return true end
    return
  end
  -- # Also safe to finish at 4+ CP with exactly 4 targets. (Same as outside stealth.)
  -- actions.stealthed+=/call_action_list,name=finish,if=spell_targets.shuriken_storm>=4-talent.seal_fate&variable.effective_combo_points>=4
  if Enemy10YC >= 4 - num(Talent.SealFate) and Player.ComboPoints >= 4 then
    if SubtletyFinisher() then return true end
    return
  end
  -- # Finish at lower combo points if you are talented in DS, SS or Seal Fate
  -- actions.stealthed+=/call_action_list,name=finish,if=combo_points.deficit<=1+(talent.seal_fate|talent.deeper_stratagem|talent.secret_stratagem)
  if Player.ComboPointsDeficit <= 1 + num(Talent.SealFate or Talent.DeeperStratagem or Talent.SecretStratagem) then
    if SubtletyFinisher() then return true end
    return
  end
  -- if Talent.ShurikenTornado and Enemy10YC >= 4 and Buff.ShurikenTornado:Exist() then
  --   if SubtletyFinisher() then return true end
  --   return
  -- end
  -- # Use Gloomblade or Backstab when close to hitting max PV stacks
  -- actions.stealthed+=/gloomblade,if=buff.perforated_veins.stack>=5&spell_targets.shuriken_storm<3
  if Buff.PerforatedVeins:Stacks() >= 5 and Enemy10YC < 3 then
    if Talent.GloomBlade then
      if Spell.GloomBlade:IsReady() then
        for _, Unit in ipairs(EnemyMelee) do
          if Spell.GloomBlade:Cast(Unit) then return true end
        end
      end
    else
      for _, Unit in ipairs(EnemyMelee) do
        if Spell.Backstab:Cast(Unit) then return true end
      end
    end
  end

  -- actions.stealthed+=/shadowstrike,if=stealthed.sepsis&spell_targets.shuriken_storm<4
  -- actions.stealthed+=/shuriken_storm,if=spell_targets>=3+buff.the_rotten.up&(!buff.premeditation.up|spell_targets>=7)
  if Enemy10YC >= 3 + num(Buff.TheRotten:Exist()) and (not Buff.Premeditation:Exist() or Enemy10YC >= 7) and
      (not Talent.ShurikenTornado or not Buff.ShurikenTornado:Exist()) then
    if Spell.ShurikenStorm:Cast(Player) then return true end
  end
  -- # Shadowstrike to refresh Find Weakness and to ensure we can carry over a full FW into the next SoD if possible.
  -- actions.stealthed+=/shadowstrike,if=debuff.find_weakness.remains<=1|cooldown.symbols_of_death.remains<18&debuff.find_weakness.remains<cooldown.symbols_of_death.remains
  if Spell.ShadowStrike:IsReady() and EnemyMeleeCount <= 2 then
    for _, Unit in ipairs(EnemyMelee) do
      if Debuff.FindWeakness:Remain(Unit) <= 1 or
          Spell.SymbolsOfDeath:CD() < 18 and Debuff.FindWeakness:Remain(Unit) < Spell.SymbolsOfDeath:CD() then
        if Spell.ShadowStrike:Cast(Unit) then return true end
      end
    end
    -- actions.stealthed+=/shadowstrike
    if (isVanished() or
          isShadowDanced()) and (not Talent.ShurikenTornado or not (tornadoTime or Buff.Premeditation:Exist())) then
      for _, Unit in ipairs(EnemyMelee) do
        if Spell.ShadowStrike:Cast(Unit) then return true end
      end
    end
  end
end

local function SubtletyStealthCDs()
  -- # Stealth Cooldowns  Helper Variable
  -- actions.stealth_cds=variable,name=shd_threshold,value=cooldown.shadow_dance.charges_fractional>=0.75+talent.shadow_dance
  local shDthreshold = Spell.ShadowDance:ChargesFrac() >= 0.75 + num(Talent.ShadowDance)
  -- # Vanish if we are capping on Dance charges. Early before first dance if we have no Nightstalker but Dark Shadow in order to get Rupture up (no Master Assassin).
  -- actions.stealth_cds+=/vanish,if=(!talent.danse_macabre|spell_targets.shuriken_storm>=3)&!variable.shd_threshold&combo_points.deficit>1
  if HUD.VanishMode == 1 and Spell.Vanish:CDUp() and (not Talent.DanseMacabre or Enemy10YC >= 3) and not shDthreshold and
      (not Talent.ShurikenTornado or not Buff.ShurikenTornado:Exist()) and
      Player.ComboPointsDeficit > 1 and GCD <= 0.15 and isShadowDanced() and Buff.ShadowDance:Remain() >= 1 and
      EnemyMeleeCount <= 7 and
      (not Setting("KeepOneVanishSub") or Spell.Vanish:Charges() == 2) and
      Spell.SecretTechnique:CD() >= 55 then
    if Spell.Vanish:Cast() then
      vanishedTime = DMW.Time
    end
  end
  -- # Pool for Shadowmeld + Shadowstrike unless we are about to cap on Dance charges. Only when Find Weakness is about to run out.
  -- actions.stealth_cds+=/pool_resource,for_next=1,extra_amount=40,if=race.night_elf
  -- actions.stealth_cds+=/shadowmeld,if=energy>=40&energy.deficit>=10&!variable.shd_threshold&combo_points.deficit>4
  -- # CP thresholds for entering Shadow Dance Default to start dance with 0 or 1 combo point
  -- actions.stealth_cds+=/variable,name=shd_combo_points,value=combo_points<=1
  -- # Use stealth cooldowns with high combo points when playing shuriken tornado or with high target counts
  -- actions.stealth_cds+=/variable,name=shd_combo_points,value=combo_points.deficit<=1,if=spell_targets.shuriken_storm>(4-2*talent.shuriken_tornado.enabled)|variable.priority_rotation&spell_targets.shuriken_storm>=4
  -- # Use stealth cooldowns on any combo point on 4 targets
  -- actions.stealth_cds+=/variable,name=shd_combo_points,value=1,if=spell_targets.shuriken_storm=(4-talent.seal_fate)
  local ShDComboPoints = false
  if Enemy10YC > (4 - 2 * num(Talent.ShurikenTornado and Spell.ShurikenTornado:CDUp())) or
      usePriorityRotation and Enemy10YC >= 4 then
    ShDComboPoints = Player.ComboPointsDeficit <= 1
  elseif Enemy10YC >= (4 - num(Talent.SealFate)) then
    ShDComboPoints = true
  else
    ShDComboPoints = Player.ComboPoints <= 1
  end
  -- # Dance during Symbols or above threshold.
  -- actions.stealth_cds+=/shadow_dance,if=(variable.shd_combo_points&(buff.symbols_of_death.remains>=(2.2-talent.flagellation.enabled)|variable.shd_threshold)|buff.flagellation.up|buff.flagellation_persist.remains>=6|spell_targets.shuriken_storm>=4&cooldown.symbols_of_death.remains>10)&!buff.the_rotten.up
  if (CDs or HUD.BurstMode == 1) and not isVanished() and Spell.ShadowDance:ChargesFrac() >= 1 and GCD <= 0.15 and
      (
        ShDComboPoints and (Buff.SymbolsOfDeath:Remain() > (2.2 - num(Talent.Flagellation)) or shDthreshold) or
        Buff.Flagellation:Exist() or Enemy10YC >= 4 and Spell.SymbolsOfDeath:CD() > 10) and not Buff.TheRotten:Exist() then
    if Spell.ShadowDance:Cast() then shadowDancedTime = DMW.Time end
  end
  -- # Burn Dances charges if before the fight ends if SoD won't be ready in time.
  -- actions.stealth_cds+=/shadow_dance,if=variable.shd_combo_points&fight_remains<cooldown.symbols_of_death.remains|!talent.shadow_dance&dot.rupture.ticking&spell_targets.shuriken_storm<=4&!buff.the_rotten.up
end

local function SubtletyCooldowns()
  -- # Cooldowns  Use Dance off-gcd before the first Shuriken Storm from Tornado comes in.
  -- actions.cds=shadow_dance,use_off_gcd=1,if=!buff.shadow_dance.up&buff.shuriken_tornado.up&buff.shuriken_tornado.remains<=3.5
  if Talent.ShurikenTornado and GCD <= 0.15 and Buff.ShurikenTornado:Exist() and
      Buff.ShurikenTornado:Remain() <= 3.5 and
      GCD <= 0.15 then
    if Spell.ShadowDance:ChargesFrac() >= 1 and not isShadowDanced() then
      if Spell.ShadowDance:Cast() then shadowDancedTime = DMW.Time end
    end
    if Setting("Racials") and Spell.BloodFury:IsReady() then if Spell.BloodFury:Cast(Player) then return true end end
    -- # (Unless already up because we took Shadow Focus) use Symbols off-gcd before the first Shuriken Storm from Tornado comes in.
    -- actions.cds+=/symbols_of_death,use_off_gcd=1,if=buff.shuriken_tornado.up&buff.shuriken_tornado.remains<=3.5
    if Spell.SymbolsOfDeath:CDUp() then
      Spell.SymbolsOfDeath:Cast(Player)
    end
  end
  -- # Vanish for Shadowstrike with Danse Macabre at adaquate stacks
  -- actions.cds+=/vanish,if=buff.danse_macabre.stack>3&combo_points<=2
  if HUD.VanishMode == 1 and Buff.DanseMacabre:Stacks() > 3 and Player.ComboPoints <= 2 and Spell.Vanish:CDUp() and
      Buff.ShadowDance:Remain() >= 1 and
      EnemyMeleeCount <= 7 and
      (not Setting("KeepOneVanishSub") or Spell.Vanish:Charges() == 2) and
      Spell.SecretTechnique:CD() >= 55 then
    if GCD > 0.15 then
      return true
    end
    if Spell.Vanish:Cast(Player) then
      vanishambush = DMW.Time
      vanishedTime = DMW.Time
      DMW.Player.VanishAmbush = nil
      StopAttack()
      return true
    end
  end
  -- # Cold Blood on 5 combo points when not playing Secret Technique
  -- actions.cds+=/cold_blood,if=!talent.secret_technique&combo_points>=5
  if CDs and Talent.ColdBlood and Spell.ColdBlood:CDUp() and not Talent.SecretTechnique and Player.ComboPoints >= 5 then
    Spell.ColdBlood:Cast(Player)
  end
  -- actions.cds+=/flagellation,target_if=max:target.time_to_die,if=variable.snd_condition&combo_points>=5&target.time_to_die>10
  -- # Pool for Tornado pre-SoD with ShD ready when not running SF.
  -- actions.cds+=/pool_resource,for_next=1,if=talent.shuriken_tornado.enabled&!talent.shadow_focus.enabled
  -- # Use Tornado pre SoD when we have the energy whether from pooling without SF or just generally.
  -- actions.cds+=/shuriken_tornado,if=spell_targets.shuriken_storm<=1&energy>=60&variable.snd_condition&cooldown.symbols_of_death.up&cooldown.shadow_dance.charges>=1&(!talent.flagellation.enabled&!cooldown.flagellation.up|buff.flagellation_buff.up|spell_targets.shuriken_storm>=5)&combo_points<=2&!buff.premeditation.up
  if CDs and Talent.ShurikenTornado and Enemy10YC <= 1 and sndCondition and Spell.SymbolsOfDeath:CDUp() and
      Spell.ShadowDance:Charges() >= 1 and
      (not Talent.Flagellation or Spell.Flagellation:CDUp() or Buff.Flagellation:Exist() or Enemy10YC >= 5) and
      Player.ComboPoints <= 2 and not Buff.Premeditation:Exist() then
    if Player.Energy < 60 then return true end
    if Spell.ShurikenTornado:Cast() then
      tornadoTime = DMW.Time;
      return true
    end
  end
  -- actions.cds+=/sepsis,if=variable.snd_condition&combo_points.deficit>=1&target.time_to_die>=16
  -- # Use Symbols on cooldown (after first SnD) unless we are going to pop Tornado and do not have Shadow Focus.
  -- actions.cds+=/symbols_of_death,if=variable.snd_condition&(!talent.flagellation|cooldown.flagellation.remains>10|cooldown.flagellation.up&combo_points>=5)
  if (CDs or HUD.BurstMode == 1) and sndCondition and Spell.SymbolsOfDeath:CDUp() and GCD <= 0.15 and Target and
      Target.TTD >= 10 and
      (not Talent.Flagellation or Spell.Flagellation:CD() > 10 or Spell.Flagellation:CDUp() and Player.ComboPoints >= 5) then
    if Spell.SymbolsOfDeath:Cast(Player) then
    end
  end
  -- # If adds are up, snipe the one with lowest TTD. Use when dying faster than CP deficit or not stealthed without any CP.
  -- actions.cds+=/marked_for_death,line_cd=1.5,target_if=min:target.time_to_die,if=raid_event.adds.up&(target.time_to_die<combo_points.deficit|!stealthed.all&combo_points.deficit>=cp_max_spend)
  -- # If no adds will die within the next 30s, use MfD on boss without any CP.
  -- actions.cds+=/marked_for_death,if=raid_event.adds.in>30-raid_event.adds.duration&combo_points.deficit>=cp_max_spend
  -- actions.cds+=/shadow_blades,if=variable.snd_condition&combo_points.deficit>=2&target.time_to_die>=10&(dot.sepsis.ticking|cooldown.sepsis.remains<=8|!talent.sepsis)|fight_remains<=20
  if CDs and Talent.ShadowBlades and Spell.ShadowBlades:CDUp() and sndCondition and Player.ComboPointsDeficit >= 2 and
      GCD <= 0.15 then
    if Spell.ShadowBlades:Cast(Player) then
    end
  end
  -- actions.cds+=/echoing_reprimand,if=variable.snd_condition&combo_points.deficit>=3&(variable.priority_rotation|spell_targets.shuriken_storm<=4|talent.resounding_clarity)&(buff.shadow_dance.up|!talent.danse_macabre)
  -- # With SF, if not already done, use Tornado with SoD up.
  -- actions.cds+=/shuriken_tornado,if=variable.snd_condition&buff.symbols_of_death.up&combo_points<=2&(!buff.premeditation.up|spell_targets.shuriken_storm>4)
  if CDs and Talent.ShurikenTornado and Spell.ShurikenTornado:CDUp() and sndCondition and Buff.SymbolsOfDeath:Exist() and
      Player.ComboPoints <= 2 and (not Buff.Premeditation:Exist() or Enemy10YC > 4) then
    if Spell.ShurikenTornado:Cast(Player) then
      tornadoTime = DMW.Time;
      return true
    end
  end
  -- actions.cds+=/shuriken_tornado,if=cooldown.shadow_dance.ready&!stealthed.all&spell_targets.shuriken_storm>=3&!talent.flagellation.enabled
  if CDs and Talent.ShurikenTornado and Spell.ShurikenTornado:CDUp() and Spell.ShadowDance:CDUp() and not stealthedAll
      and
      Enemy10YC >= 3 and not Talent.Flagellation then
    if Spell.ShurikenTornado:Cast(Player) then
      tornadoTime = DMW.Time;
      return true
    end
  end
  -- actions.cds+=/shadow_dance,if=!buff.shadow_dance.up&fight_remains<=8+talent.subterfuge.enabled
  -- actions.cds+=/thistle_tea,if=cooldown.symbols_of_death.remains>=3&!buff.thistle_tea.up&(energy.deficit>=100|cooldown.thistle_tea.charges_fractional>=2.75&buff.shadow_dance.up)|buff.shadow_dance.remains>=4&!buff.thistle_tea.up&spell_targets.shuriken_storm>=3|!buff.thistle_tea.up&fight_remains<=(6*cooldown.thistle_tea.charges)
  -- if CDs and (Talent.ThistleTea and Spell.ThistleTea:Charges() >= 1 and Spell.SymbolsOfDeath:CD() >= 3 and
  --     not isThistleTeaed() and
  --     (Player.EnergyDeficit >= 100 or Spell.ThistleTea:ChargesFrac() >= 2.75 and isShadowDanced()) or
  --     Buff.ShadowDance:Remain() >= 4 and not isThistleTeaed() and Enemy10YC >= 3) and GCD <= 0.15 then
  --   if Spell.ThistleTea:Cast(Player) then thistleTeaedTime = DMW.Time end
  -- end
  -- actions.cds+=/potion,if=buff.bloodlust.react|fight_remains<30|buff.symbols_of_death.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=10)
  -- actions.cds+=/blood_fury,if=buff.symbols_of_death.up
  -- actions.cds+=/berserking,if=buff.symbols_of_death.up
  -- actions.cds+=/fireblood,if=buff.symbols_of_death.up
  -- actions.cds+=/ancestral_call,if=buff.symbols_of_death.up
  -- actions.cds+=/use_item,name=manic_grieftorch,use_off_gcd=1,if=gcd.remains>gcd.max-0.1,if=!stealthed.all
  -- # Default fallback for usable items: Use with Symbols of Death.
  -- actions.cds+=/use_items,if=buff.symbols_of_death.up|fight_remains<20
end

-- local followingTarget = false
function Rogue.Rotation()
  Locals()
  if MythicStuff() then return true end
  if Player.Casting or Buff.Shroud:Exist() then return end
  if Setting("PreRoll") and Player.SpecID == "Outlaw" and Target and Target.Attackable and Target.Distance <= 10 and
      Player.Moving and (Buff.Stealth:Exist() or Buff.StealthSubterfuge:Exist()) then
    Tricks()
    if Spell.SliceAndDice:IsReady() and Player.ComboPoints >= 3 and
        Buff.SliceAndDice:Remain(Player) < 12 then
      if Spell.SliceAndDice:Cast(Player) then return true end
    end

    if not CDs then
      if Spell.RollTheBones:CDUp() and rtbReroll(true) and (Spell.AdrenalineRush:CDDown() or Buff.LoadedDice:Exist()) then
        if Spell.RollTheBones:Cast(Player) then return true end
      end
    else
      if Spell.AdrenalineRush:CDUp() and Spell.RollTheBones:CDUp() and not Buff.LoadedDice:Exist() then
        Spell.AdrenalineRush:Cast()
      end
      if Spell.RollTheBones:CDUp() and rtbReroll(true) then
        if Spell.RollTheBones:Cast(Player) then return true end
      end
    end
  end
  if Setting("Dont open from Stealth") and Player.SpecID ~= "Outlaw" and
      (Buff.Stealth:Exist() or Buff.StealthSubterfuge:Exist()) then
    return
  end
  -- if HUD.CCMode ~= 3 then if CrowdControlAround() then return end end
  if PrecombatShared() then return end
  if Player.Combat then
    if Target and Target:CCed() then
      if IsCurrentSpell(Spell.Attack.SpellID) then
        StopAttack()
      end
      return
    end
    if HUD.CCMode == 1 then if CrowdControl() then return end end
    if Setting("AutoTarget") then
      if not Target or Target.Dead then
        if Player:AutoTargetMelee(5, true) then return true end
      end
    end
    if Target and Target.ValidEnemy and Target.Distance <= 5 and not IsCurrentSpell(Spell.Attack.SpellID) and
        not stealthedRogue and
        Target:Facing(0.5) and not stopAttacking then
      -- StartAttack()
      TipsyGuy.SecureCode("StartAttack")
      -- Unlocked.StartAttack()
    end

    -- if Setting("Use Trinkets on CD") then

    -- end
    -- if Setting("Follow Target") then
    --   if Target and Target.Distance > 5 and not followingTarget then
    --     local followX, followY, followZ = GetPositionBetweenObjects("target", "player", 3)
    --     MoveTo(followX, followY, followZ)
    --     followingTarget = true
    --     C_Timer.After(0.5, function() followingTarget = false end)
    --   end
    --   if followingTarget and Target and Target.Distance < 5 then StopMoving() end
    -- end
  end
  if Player:InterruptsMode() ~= 4 and Spell.Kick:CDUp() then
    for _, Unit in pairs(EnemyMelee) do
      if Unit:Interrupt() then
        Spell.Kick:Cast(Unit)
        break
      end
    end
  end

  if HUD.Defensive == 1 then
    if Defensives() then return end
  end

  if Poisons() then return end
  if Player.SpecID == "Subtlety" then
    if (Target and Target.ValidEnemy and Target.Distance <= 5) or Player:CombatTime() > 0 or Player:CombatLeftTime() < 3 then
      LocalsSubtlety()
      -- # Executed every time the actor is available.
      -- # Restealth if possible (no vulnerable enemies in combat)
      -- actions=stealth
      -- # Interrupt on cooldown to allow simming interactions with that
      -- actions+=/kick
      -- # Used to determine whether cooldowns wait for SnD based on targets.
      -- actions+=/variable,name=snd_condition,value=buff.slice_and_dice.up|spell_targets.shuriken_storm>=cp_max_spend
      -- # Check to see if the next CP (in the event of a ShT proc) is Animacharged
      -- actions+=/variable,name=is_next_cp_animacharged,if=talent.echoing_reprimand.enabled,value=combo_points=1&buff.echoing_reprimand_2.up|combo_points=2&buff.echoing_reprimand_3.up|combo_points=3&buff.echoing_reprimand_4.up|combo_points=4&buff.echoing_reprimand_5.up
      -- # Account for ShT reaction time by ignoring low-CP animacharged matches in the 0.5s preceeding a potential ShT proc
      -- actions+=/variable,name=effective_combo_points,value=effective_combo_points
      -- actions+=/variable,name=effective_combo_points,if=talent.echoing_reprimand.enabled&effective_combo_points>combo_points&combo_points.deficit>2&time_to_sht.4.plus<0.5&!variable.is_next_cp_animacharged,value=combo_points
      -- # Check CDs at first
      -- actions+=/call_action_list,name=cds
      usePriorityRotation = HUD.PriorityMode ~= 3 --and Enemy10YC >= 2
      -- if CDs then
      if EnemyMeleeCount >= 1 and SubtletyCooldowns() then return true end
      -- end
      -- # Apply Slice and Dice at 4+ CP if it expires within the next GCD or is not up
      -- actions+=/slice_and_dice,if=spell_targets.shuriken_storm<cp_max_spend&buff.slice_and_dice.remains<gcd.max&fight_remains>6&combo_points>=4
      if Spell.SliceAndDice:IsReady() and not isShadowDanced() and not isVanished() and Enemy10YC < 5 and Player.ComboPoints >= 4 and SnDRefresh() and --Buff.SliceAndDice:Remain() < 1 and
          Player.ComboPoints >= 4 and bfTTD > 10 then
        if Spell.SliceAndDice:Cast() then return true end
      end
      -- # Run fully switches to the Stealthed Rotation (by doing so, it forces pooling if nothing is available).
      -- actions+=/run_action_list,name=stealthed,if=stealthed.all
      if Buff.Stealth:Exist() or isVanished() or isShadowDanced() then
        if SubtletyStealthed() then return true end
        return
      end
      -- # Only change rotation if we have priority_rotation set.
      -- actions+=/variable,name=priority_rotation,value=priority_rotation

      -- # Used to define when to use stealth CDs or builders
      -- actions+=/variable,name=stealth_threshold,value=25+talent.vigor.enabled*20+talent.master_of_shadows.enabled*20+talent.shadow_focus.enabled*25+talent.alacrity.enabled*20+25*(spell_targets.shuriken_storm>=4)
      local stealthThreshold = 25 + num(Talent.Vigor) * 20 + num(Talent.MasterOfShadows) * 20 +
          num(Talent.ShadowFocus) * 25 +
          num(Talent.Alacrity) * 20 + 25 * num(Enemy10YC >= 4)
      -- # Consider using a Stealth CD when reaching the energy threshold
      -- actions+=/call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold
      if Player.EnergyDeficit <= stealthThreshold and EnemyMeleeCount >= 1 then
        if SubtletyStealthCDs() then return true end
      end
      -- actions+=/call_action_list,name=finish,if=variable.effective_combo_points>=cp_max_spend
      if Player.ComboPoints >= 7 then
        if SubtletyFinisher() then return true end
      end
      -- # Finish at maximum or close to maximum combo point value
      -- actions+=/call_action_list,name=finish,if=combo_points.deficit<=1+buff.the_rotten.up|fight_remains<=1&variable.effective_combo_points>=3
      if Player.ComboPointsDeficit <= 1 + num(Buff.TheRotten:Exist()) or bfTTD <= 1 and Player.ComboPoints >= 3 then --!TODO + num(Buff.TheRotten:Exist())
        if SubtletyFinisher() then return true end
      end
      -- # Finish at 4+ against 4 targets (outside stealth)
      -- actions+=/call_action_list,name=finish,if=spell_targets.shuriken_storm>=(4-talent.seal_fate)&variable.effective_combo_points>=4
      if Enemy10YC >= (4 - num(Talent.SealFate)) and Player.ComboPoints >= 4 then
        if SubtletyFinisher() then return true end
      end
      if Talent.ShurikenTornado and Enemy10YC >= 4 and tornadoTime then
        if SubtletyFinisher() then return true end
      end
      -- # Use a builder when reaching the energy threshold
      -- actions+=/call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold
      if Player.EnergyDeficit <= stealthThreshold then
        if SubtletyBuilder() then return true end
      end
      -- # Lowest priority in all of the APL because it causes a GCD
      -- actions+=/arcane_torrent,if=energy.deficit>=15+energy.regen
      -- actions+=/arcane_pulse
      -- actions+=/lights_judgment
      -- actions+=/bag_of_tricks
    end
  elseif Player.SpecID == "Outlaw" then
    if PrecombatOutlaw() then return end
    if Player.SpecID == "Outlaw" and vanishambush then
      if DMW.Time - vanishambush > 1 then
        -- print(DMWishambush off vanish1sec", DMW.Time)

        vanishambush = false
        return
      end
      if DMW.Player.VanishAmbush and DMW.Time - DMW.Player.VanishAmbush <= 0.2 then
        vanishambush = false
        return
      end
      if Target then
        -- print("cast ambush")
        -- TipsyGuy.SecureCode("CastSpellByID", 8676, Target.GUID)
        Unlocked.CastSpellByID(8676, Target.Object)
        return
      end
      return true
    end
    if Buff.Stealth:Exist() or Buff.StealthSubterfuge:Exist() then
      if IsCurrentSpell(Spell.Attack.SpellID) then
        StopAttack()
      end
      if Setting("Dont open from Stealth") then
        return true
      else
        if Target and Target.ValidEnemy and Target.Distance < 5 then
          if Talent.Subterfuge and Enemy10YC > 1 then
            if Spell.BladeFlurry:Cast(Player) then return true end
          else
            if Spell.Ambush:IsReady() then
              for _, Unit in ipairs(EnemyMelee) do
                if Spell.Ambush:Cast(Unit) then return true end
              end
            end
          end
        end
      end
      return true
    end

    if OutlawExplosives() then return end
    if CDs and EnemyMeleeCount > 0 then
      -- if Setting("General Usage") then
      --   if highestBTE() > 0 then --Debuff.BetweenTheEyes:Exist(Target) then
      --     if TTM() >= 2 and not Buff.Subterfuge:Exist() and not isShadowDanced() and not isVanished() and
      --         (not Buff.Stealth:Exist() and not Buff.StealthSubterfuge:Exist()) and
      --         Player:StandingTime() >= 1 and
      --         Item.Manic:Equipped() and
      --         Item.Manic:IsReady() then
      --       Item.Manic:Use(Target)
      --       return
      --     end
      --     Item.Whetstone:Use()
      --   end
      -- end
      if Spell.AdrenalineRush:IsReady() and not Buff.LoadedDice:Exist() then
        Spell.AdrenalineRush:Cast(Player)
      end
    end

    if (Target and Target.ValidEnemy and Target.Distance <= 5) or Player:CombatTime() > 0 or Player:CombatLeftTime() < 3
    -- or        (DMW.Player.CombatLeft and DMW.Time - DMW.Player.CombatLeft < 3)
    then -- (Target and Target.ValidEnemy and Target.Distance <= 5)
      Tricks()
      -- if HUD.Info == 2 then
      --   if Player.EnergyDeficit >= 30 then
      --     if Spell.BladeRush:CDUp() then
      --       for _, Unit in ipairs(EnemyMelee) do
      --         if TipsyGuy.GetDistance2D("player", Unit.GUID) <= 8 then
      --           if Spell.BladeRush:Cast(Unit) then return true end
      --         end
      --       end
      --     end
      --     return true
      --   end
      -- end
      -- master_assassin_remains=0&buff.dreadblades.down&(!buff.roll_the_bones.up|variable.rtb_reroll)
      if Spell.RollTheBones:CDUp() and rtbReroll() then
        if Spell.RollTheBones:Cast(Player) then return true end
        return true
      end
      if HUD.BFMode == 1 and Buff.BladeFlurry:Remain() <= 1 and EnemyMeleeCount >= 2 and bfTTD > bfTTDvalue then
        if Spell.BladeFlurry:Cast(Player) then return true end
      end
      -- local rtbRerollVar = rtbReroll()
      -- ghostly_strike,if=combo_points.deficit>=1+buff.broadside.up
      if Talent.GhostlyStrike and HUD.GhostlyStrike == 1 and Spell.GhostlyStrike:IsReady() then
        if Target and Target.TTD >= 8 and Player.ComboPointsDeficit >= 1 + num(Buff.Broadside:Exist()) then
          if Spell.GhostlyStrike:Cast(Target) then return true end
        end
      end

      if Talent.MarkOfDeath and Spell.MarkOfDeath:IsReady() and Player.ComboPointsDeficit > 0 then
        if MarkOfDeathAOE() then return true end
      end
      -- print(rtbRerollVar)


      -- if Player.Covenant == "Kyrian" and Spell.EchoingReprimand:IsCastable(5) and CDs and Player.ComboPointsDeficit >= 2 then
      --   for _, Unit in ipairs(EnemyMelee) do if Spell.EchoingReprimand:Cast(Unit) then return true end end
      -- end
      -- if Player.Covenant == "Venthyr" and Spell.Flagellation:IsCastable(5) and Player.ComboPointsDeficit == 0 then
      --   for _, Unit in ipairs(EnemyMelee) do if Spell.Flagellation:Cast(Unit) then return true end end
      -- end
      -- if Player.Covenant == "Kyrian" then
      --   if (Buff.Kyrian2p:Stacks() == 2 and Player.ComboPoints == 2) or
      --       (Buff.Kyrian3p:Stacks() == 3 and Player.ComboPoints == 3) or
      --       (Buff.Kyrian4p:Stacks() == 4 and Player.ComboPoints == 4) then
      --     -- print("kyrian".. Player.ComboPoints)
      --     if OutlawFinishers(true) then return true end
      --   end
      -- end

      -- For HO builds, Vanish > Ambush is used when Audacity is not active and you are not capped on Opportunity stacks. Even if you use Find Weakness, FW uptime is so high you don't need to plan around it for Vanish.
      -- shadow_dance,if=!talent.keep_it_rolling&variable.shadow_dance_condition&buff.slice_and_dice.up&(variable.finish_condition|talent.hidden_opportunity)&(!talent.hidden_opportunity|!cooldown.vanish.ready)
      -- print(vanishambush)
      if HUD.VanishMode == 1 and HUD.Info == 1 and EnemyMeleeCount >= 1 and Target and Target.TTD >= 10 and
          Buff.SliceAndDice:Exist() and
          not Buff.Stealth:Exist() and not Buff.StealthSubterfuge:Exist()
          -- and GCD <= 0.2
          and not Buff.Subterfuge:Exist() and not isShadowDanced()
          and Player.ComboPointsDeficit >= 3 and
          ((Player.Energy > 50 and Buff.Opportunity:Stacks() == 3) or Buff.Opportunity:Stacks() == 0)
          and
          (
            Spell.Vanish:CDUp() or
            Spell.Vanish:CD() < TTM(100) and Spell.Vanish:CD() < 2 and Buff.Opportunity:Stacks() == 0) and
          not Buff.Audacity:Exist() and GCD < 0.4 and
          (not Buff.Opportunity:Exist() or not Talent.Subterfuge and Buff.Opportunity:Stacks() <= 3) then
        if Setting("Pooling for SD/Vanish") and (Player.Energy <= 50 or Talent.Subterfuge and TTM(150) > 2) then
          if HUD.BladerushMode == 1 and Spell.BladeRush:CDUp() then
            for _, Unit in ipairs(EnemyMelee) do
              if TipsyGuy.GetDistance2D("player", Unit.GUID) <= brRange then
                if Spell.BladeRush:Cast(Unit) then return true end
              end
            end
          end
          if (
                HUD.BFMode == 1 and EnemyMeleeCount >= 2 and bfTTD > bfTTDvalue and
                (
                  Buff.BladeFlurry:Remain() < 1.5 or Buff.BladeFlurry:Remain() < 4 and Talent.Subterfuge and TTM(150) < 3
                )
              ) then
            if Spell.BladeFlurry:Cast(Player) then return true end
            -- if Spell.BladeFlurry:CD() < 2 and Spell.BladeFlurry:CD() < TTM() then
            --   return true
            -- end
          end
          report("Pooling Vanish")
          return true
        end
        if (
              HUD.BFMode == 1 and EnemyMeleeCount >= 2 and bfTTD > bfTTDvalue and
              Buff.BladeFlurry:Remain() < 4 and Talent.Subterfuge
            ) then
          if Spell.BladeFlurry:Cast(Player) then return true end
          if Spell.BladeFlurry:CD() < 2 and Spell.BladeFlurry:CD() < TTM() then
            return true
          end
          -- return
        end
        if GCD > 0.15 then
          return true
        end
        if Spell.Vanish:Cast(Player) then
          report("Pooling Vanish", true)

          vanishedTime = DMW.Time

          vanishambush = DMW.Time
          DMW.Player.VanishAmbush = nil
          Unlocked.StopAttack()
          -- C_Timer.After(1, function() vanishambush = false
          -- end)
          -- if Spell.Ambush:CDUp() then
          --   print("ready")
          --   for _, Unit in ipairs(EnemyMelee) do
          --     if Debuff.BetweenTheEyes:Exist(Unit) then
          --       if Spell.Ambush:Cast(Unit) then return true end
          --     end
          --   end
          --   for _, Unit in ipairs(EnemyMelee) do if Spell.Ambush:Cast(Unit) then return true end end
          -- end
          -- print("vanish cast ", DMW.Time)
          return true
        end
      end
      if HUD.ShadowDance == 1 and HUD.Info == 1 and EnemyMeleeCount >= 1 and Target and Target.TTD >= 8 and
          Buff.SliceAndDice:Exist() and
          not Buff.Stealth:Exist() and not Buff.StealthSubterfuge:Exist()
          and GCD <= 0.15
          and not Buff.Subterfuge:Exist()
          and not isVanished()
          and Player.ComboPointsDeficit >= 3 and
          (Spell.ShadowDance:CDUp() or Spell.ShadowDance:CD() < TTM(150) and Spell.ShadowDance:CD() < 2) and
          not Buff.Audacity:Exist() and GCD < 0.1 and
          (not Buff.Opportunity:Exist() or Setting("IgnoreFTH")) then
        -- if Player.Energy <= 80 then
        if Setting("Pooling for SD/Vanish") and TTM(150) > 2 then
          if HUD.BladerushMode == 1 and Spell.BladeRush:CDUp() then
            for _, Unit in ipairs(EnemyMelee) do
              if TipsyGuy.GetDistance2D("player", Unit.GUID) <= brRange then
                if Spell.BladeRush:Cast(Unit) then return true end
              end
            end
          end
          if (HUD.BFMode == 1 and Buff.BladeFlurry:Remain() <= 7 and EnemyMeleeCount >= 2 and bfTTD > bfTTDvalue) and
              TTM(150) < 4 then
            if Spell.BladeFlurry:Cast(Player) then return true end
            -- if Spell.BladeFlurry:CD() < 2 and Spell.BladeFlurry:CD() < TTM() then
            --   return true
            -- end
          end
          report("Pooling ShadowDance")
          return true
        end
        if (HUD.BFMode == 1 and Buff.BladeFlurry:Remain() <= 7 and EnemyMeleeCount >= 2 and bfTTD > bfTTDvalue)
        then
          if Spell.BladeFlurry:Cast(Player) then return true end
          if Spell.BladeFlurry:CD() < 2 and Spell.BladeFlurry:CD() < TTM() then
            return true
          end
        end
        if Spell.ShadowDance:Cast(Player) then
          shadowDancedTime = DMW.Time
          vanishambush = DMW.Time
          report("Pooling ShadowDance", true)
          DMW.Player.VanishAmbush = nil
          return true
        end
      end
      if GCD > 0.2 then return true end
      if HUD.BladerushMode == 1 and HUD.Info == 1 and not isShadowDanced() and
          not Buff.Subterfuge:Exist() and TTM() > 4 - EnemyMeleeCount / 3 and TTM() > 3 and
          Spell.BladeRush:CDUp() and --(not Buff.Opportunity:Exist() or TTM() > 4) and
          (Buff.BladeFlurry:Exist() or EnemyMeleeCount == 1) then
        -- print(TTM(), EnemyMeleeCount, 4 - EnemyMeleeCount / 3)
        for _, Unit in ipairs(EnemyMelee) do
          if TipsyGuy.GetDistance2D("player", Unit.GUID) <= brRange then
            if Spell.BladeRush:Cast(Unit) then return true end --print(TTM());
          end
        end
      end
      if stealthedRogue then
        OutlawStealth()
        return true
      end
      if OutlawShouldFinish() then --or DMW.Time - Spell.PistolShot.LastCastTime <= 0.4 then
        if OutlawFinishers() then return true end
        return true
      end
      if OutlawBuilders() then return end
      -- if Setting("BladeRush") and HUD.Info == 1 and Spell.BladeRush:CDUp() then
      --   for _, Unit in ipairs(EnemyMelee) do
      --     if TipsyGuy.GetDistance2D("player", Unit.GUID) <= brRange then
      --       if Spell.BladeRush:Cast(Unit) then return true end
      --     end
      --   end
      -- end
    end
  elseif Player.SpecID == "Assassination" then
    if MythicStuff() then return end
    if (Target and Target.ValidEnemy and Target.Distance <= 5) or (DMW.Player.InstanceID ~= nil and DMW.Player.Combat) or
        (Target and Target.Dummy) then
      Tricks()
      if stealthedRogue then if AssassinationStealthedAPL() then return true end end
      -- if AssassinationExplosives() then return true end

      if CDs and AssassinationCooldownsAPL() then return true end
      if AssassinationSND() then return true end
      if AssassinationDotAPL() then return true end
      if AssassinationDirectAPL() then return true end
      -- or AssassinationSND() or AssassinationDotAPL() or AssassinationDirectAPL() then return true end
    end
    -- if PrecombatAssassination() then return end
    -- if (Target and Target.ValidEnemy and Target.Distance <= 5) or (DMW.Player.InstanceID ~= nil and DMW.Player.Combat) then
    --     Tricks()
    --     if stealthedRogue then
    --         if AssassinationStealthedAPL() then return true end
    --     end
    --     if AssassinationDotAPL() or AssassinationDirectAPL() then return true end
    -- end
  end
end

-- local chars = { "Disorient", "Fear", "Root", "Silence", "Slow", "Stun", "Taunt", "Incapacitate"  }
-- for _, char in pairs(chars) do
--   TipsyGuy.WriteFile(TipsyGuy.GetExeDirectory() .. char .. ".txt",
--     "",
--     false)
--   local dungeons = { 51, 50, 49, 48, 47, 46, 45, 44, 43, 42, 6 }
--   for _, dung in pairs(dungeons) do
--     for _, unit in pairs(MDT.dungeonEnemies[dung]) do
--       if unit.characteristics and unit.characteristics[char] then
--         print(unit.id)
--         TipsyGuy.WriteFile(TipsyGuy.GetExeDirectory() .. char .. ".txt",
--           "[" .. unit.id .. "] = true,",
--           true)
--       end
--     end
--   end
-- end
