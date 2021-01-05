local DMW = DMW
local Rogue = DMW.Rotations.ROGUE
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local Player, Buff, Debuff, Spell, Stance, Target, Talent, Item, GCD, CDs, HUD, EnemyMelee, EnemyMeleeCount, Enemy10Y, Enemy10YC,
      Enemy30Y, Enemy30YC, stealthedRogue, pauseTime, AssassinationOpener, sndCondition, usePriorityRotation, forceStealthed, stopAttacking, ShDthreshold, SkipRupture
local ShouldReturn
local forceroll = false
local TricksCombat = true
DMW.Player.RtbCount = 0
local vanishambush = false
local fhbossPool = false

local cloakPlayerlist = {
    [256106] = true, -- FH 1st boss
    [261439] = true, -- Virulent Pathogen WM
    [261440] = true, -- Virulent Pathogen WM
    [265773] = true -- Spit Gold KR
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
    [260741] = true -- nettles wm
}

local stunList = { -- Stolen from feng pala
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
    [278504] = true, -- Ritual WM

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
    -- [250368] = true,  -- Vol’kaal AD
    [265540] = true, -- Rotten Bile UR
    [257641] = true, -- molten slug
    [265542] = true, -- Rotten Bile UR
    [265376] = true, -- barbed spear
    [267354] = true -- Hail of Flechettes ML
    -- [256060] = true
}
local channelLateList = {
    [257739] = true, -- Fixate FH
    [270839] = true -- test
}

local frame = CreateFrame("FRAME")
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

SLASH_FORCESKIPCHECK1 = "/forceskipcheck"
    SlashCmdList["FORCESKIPCHECK"] = function()
        if UnitExists("target") and not DMW.Enums.SkipChecks[DMW.Player.Target.ObjectID] then
            DMW.Enums.SkipChecks[DMW.Player.Target.ObjectID] = true
        end
    end


local function RtbCache()
    local count = 0
    local time
    local function cacheRTB(Spell)
        if DMW.Player.Buffs[Spell]:Exist() then
            count = count + 1
            -- print(Spell)
            time = select(6, DMW.Player.Buffs[Spell]:Query(DMW.Player))
        end
    end
    cacheRTB("Broadside")
    cacheRTB("BuriedTreasure")
    cacheRTB("GrandMelee")
    cacheRTB("RuthlessPrecision")
    cacheRTB("SkullAndCrossbones")
    cacheRTB("TrueBearing")
    -- print("1")
    DMW.Player.RtbEndTime = time
	DMW.Player.RtbCount = count
	-- print(count, time - DMW.Time)
end

local function TTM()
    local PowerMissing = Player.EnergyMax - Player.Energy
    if PowerMissing > 0 then
        return PowerMissing / GetPowerRegen()
    else
        return 0
    end
end

local function Locals()
    Player = DMW.Player
    if Player.SpecID == "Outlaw" and GetKeyState(0x10) then
        DMWHUDINFO:Toggle(3)
    elseif GetKeyState(0x12) then
        DMWHUDINFO:Toggle(2)
    else
        DMWHUDINFO:Toggle(1)
    end
    HUD = DMW.Settings.profile.HUD
    Buff = Player.Buffs
    Debuff = Player.Debuffs
    Spell = Player.Spells
    Talent = Player.Talents
    Item = Player.Items
    Target = Player.Target or false
    Rage = Player.Rage
    CDs = Player:CDs() and Target and Target.TTD > 5 and Target.Distance < 5 and HUD.Info ~= 3
    EnemyMelee, EnemyMeleeCount = Player:GetEnemies(5)
    Enemy10Y, Enemy10YC = Player:GetEnemies(10)
    Enemy30Y, Enemy30YC = Player:GetEnemies(30)
    GCD = Player:GCDRemain()
    if Player.SpecID == "Assassination" then
        stealthedRogue = Buff.Stealth:Exist() or Buff.Vanish:Exist() or Buff.Subterfuge:Remain() > 0.2
        -- stealthedRogue = GetShapeshiftForm() ~= 0
        EnemyFOK, EnemyFOKcount = Player:GetEnemies(10)
    elseif Player.SpecID == "Outlaw" then
        if not Player.RtbCount then
            RtbCache()
        end
        stealthedRogue = Buff.Stealth:Exist() or Buff.Vanish:Exist()
    elseif Player.SpecID == "Subtlety" then
        stealthedRogue = Buff.Stealth:Exist() or Buff.Vanish:Exist() or Buff.ShadowDance:Exist()
    end
    if not Player.Combat and not TricksCombat then
        TricksCombat = true
    end
end

local function LocalsSubtlety()
    sndCondition = Buff.SliceAndDice:Exist() or Enemy10YC >= 6
    ShDthreshold = Spell.ShadowDance:ChargesFrac() >= 1.75
    SkipRupture = Enemy10YC >= 6 or HUD.RuptureMode == 2 or (not Talent.Nightstalker and Talent.DarkShadow and Buff.ShadowDance:Exist())
end


local function RogueTrinkets()
    if Setting("LustrousGoldenPlumage") then
        Item.LustrousGoldenPlumage:Use()
    end

end

local function num(val)
    if val then return 1 else return 0 end
end

local function bool(val)
    return val ~= 0
end

local function MythicStuff()
    if not Setting("Use Logics") then return end
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

    if Player.EID then
        -- fh 1st boss feint, fisker (c)
        -- if Player.EID == 2093 then
        --     local a, b, c, d = UnitCastID("boss1")
        --     if a == 256106 then
        --         fhbossPool = false
        --         if c == ObjectPointer("player") then CastSpellByID(1966) end
        --     end
        --     if DMW.BossMods.getTimer(256106) <= 1.5 and Spell.Feint:CDUp() then -- pause 1 sec before cast for pooling
        --         -- if GetUnitIsUnit("player", UnitTarget("boss1")) then
        --         fhbossPool = true
        --     end
        --     if fhbossPool then return true end
        -- elseif Player.EID == 2117 then

        -- end
        -- WM gorak cc
        -- if br.player.eID == 2117 then
        -- if enemyTable20 ~= nil then
        -- for i = 1, #enemyTable20 do
        -- local thisUnit = enemyTable20[i]
        -- if thisUnit.id == 135552 and UnitCastingInfo(thisUnit) ~= nil then
        -- if (select(6, UnitCastingInfo(thisUnit)) - br.time) <= 1 then
        -- if not cd.gouge.exists() and getFacing(thisUnit,"player") then
        -- if cast.gouge(thisUnit) then return true end
        -- elseif not cd.betweenTheEyes.exists() and comboDeficit <= 2 then
        -- if cast.betweenTheEyes(thisUnit) then return true end
        -- elseif not cd.blind.exists() then
        -- if cast.blind(thisUnit) then return true end
        -- end
        -- end
        -- end
        -- end
        -- end
        -- end
        -- if br.player.eID == 2093 and isCastingSpell(256106, "boss1") then
        --     fhbossPool = false
        --     if GetUnitIsUnit("player", UnitTarget("boss1")) then
        --         if cast.feint() then print("feint gone");return true end
        --     end
        -- end
        -- if fhbossPool then return true end
        -- print(eID)
        local bosscount = 0
        for i = 1, 5 do if UnitExists("boss" .. i) then bosscount = bosscount + 1 end end
        for i = 1, bosscount do
            local spellname, castEndTime, interruptID, spellnamechannel, castorchan, spellID
            local thisUnit = tostring("boss" .. i)
            --    if select(3, UnitCastID(thisUnit)) == ObjectPointerUnlocked("player") and select(9, UnitCastingInfo(thisUnit)) then
            -- 	print(select(9, UnitCastingInfo(thisUnit)))
            -- end
            if UnitCastingInfo(thisUnit) then
                spellname = UnitCastingInfo(thisUnit)
                -- castStartTime = select(4,UnitCastingInfo(thisUnit)) / 1000
                castEndTime = select(5, UnitCastingInfo(thisUnit)) / 1000
                interruptID = select(9, UnitCastingInfo(thisUnit))
                castorchan = "cast"
            elseif UnitChannelInfo(thisUnit) then
                spellname = UnitChannelInfo(thisUnit)
                -- castStartTime = select(4,UnitChannelInfo(thisUnit)) / 1000
                castEndTime = select(5, UnitChannelInfo(thisUnit)) / 1000
                interruptID = select(9, UnitChannelInfo(thisUnit))
                castorchan = "channel"
            end
            if spellname ~= nil then
                -- print(spellname)
                local castleft = castEndTime - DMW.Time
                -- WriteFile("encountertest.txt", tostring(ObjectName("boss"..i)) .. "," .. tostring(castleft) .. " left," .. tostring(spellname) .. ", spellid =" .. tostring(interruptID) .. "\n", true)
                -- print(castleft.." cast left"..spellname)
                -- print(castleft.." channel left"..spellname)
                -- if castleft <= 3 then
                if (select(3, UnitCastID(thisUnit)) == Player.Pointer or select(4, UnitCastID(thisUnit)) == Player.Pointer) and castleft <= 1.5 then -- GetUnitIsUnit("player", "boss"..i.."target") or   then
                    if cloakPlayerlist[interruptID] then
                        if Player.EID == 2093 then
                            if Spell.Feint:IsReady() or Buff.Feint:Exist() then return end
                        end
                        if Spell.CloakOfShadows:Cast(Player) then return true end
                    elseif evasionPlayerlist[interruptID] then
                        if Spell.Evasion:Cast(Player) then return true end
                    elseif Talent.Elusiveness and feintPlayerList[interruptID] then
                        if Spell.Feint:Pool() and Spell.Feint:CD() <= castleft then return true end
                        if Spell.Feint:Cast(Player) then return true end
                    elseif vanishList[interruptID] then
                        if Spell.Vanish:Cast(Player) then return true end
                    end
                else
                    if cloaklist[interruptID] then
                        if Spell.CloakOfShadows:Cast(Player) then return true end
                    elseif evasionlist[interruptID] then
                        if Spell.Evasion:Cast(Player) then return true end
                    elseif feintlist[interruptID] then
                        if Spell.Feint:Pool() and Spell.Feint:CD() <= castleft then return true end
                        if Spell.Feint:Cast(Player) then return true end
                    end
                end
                -- end
            end
        end
        -- CC units
        -- for i=1, #enemies.yards20 do
        --         local thisUnit = enemies.yards20[i]
        --         local distance = getDistance(thisUnit)
        --         if isChecked("AutoBtE") or isChecked("AutoGouge") or isChecked("AutoBlind") then
        --             local interruptID, castStartTime, spellname, castEndTime
        --             if UnitCastingInfo(thisUnit) then
        --                 spellname = UnitCastingInfo(thisUnit)
        --                 -- castStartTime = select(4,UnitCastingInfo(thisUnit)) / 1000
        --                 castEndTime = select(5, UnitCastingInfo(thisUnit)) / 1000
        --                 interruptID = select(9,UnitCastingInfo("player"))
        --             elseif UnitChannelInfo(thisUnit) then
        --                 spellname = UnitChannelInfo(thisUnit)
        --                 -- castStartTime = select(4,UnitChannelInfo(thisUnit)) / 1000
        --                 castEndTime = select(5,UnitChannelInfo(thisUnit)) / 1000
        --                 interruptID = select(8,UnitChannelInfo(thisUnit))
        --             end
        --             if isChecked("AutoBtE") and interruptID ~= nil and combo > 0 and not spread and
        --                     ((stunList[interruptID] and castEndTime - GetTime() <= 2 ) or
        --                     channelAsapList[interruptID] or
        --                     channelLateList[interruptID] and castEndTime - GetTime() <= 2)
        --                 then
        --                 if cast.betweenTheEyes(thisUnit) then print("bte stun on"..spellname); return true end
        --             end
        --             if isChecked("AutoGouge") and interruptID ~= nil and getFacing(thisUnit,"player") and
        --                     ((stunList[interruptID] and castEndTime - GetTime() <= 2 ) or
        --                     channelAsapList[interruptID] or
        --                     channelLateList[interruptID] and castEndTime - GetTime() <= 2)
        --                 then
        --                 if cast.gouge(thisUnit) then print("gouge on"..spellname) return true end
        --             end
        --             if isChecked("AutoBlind") and interruptID ~= nil and
        --                     ((stunList[interruptID] and castEndTime - GetTime() <= 2 ) or
        --                     channelAsapList[interruptID] or
        --                     (channelLateList[interruptID] and castEndTime - GetTime() <= 2)) then
        --                 if cast.blind(thisUnit) then print("blind on "..spellname) return true end
        --             end
        --         end
        --     end
    end
end

local function RtbRemain()
    local RtbRemains = (DMW.Player.RtbEndTime ~= nil and DMW.Player.RtbEndTime - DMW.Time) or 0
    return RtbRemains
end


local function rtbReroll()
    -- if DMW.Settings.profile.HUD.RollMode == 2 then
    --     if Player.RtbCount > 0 then return false end
    -- elseif EnemyMeleeCount >= 3 then
    --     local skull = num(Buff.SkullAndCrossbones:Exist())
    --    return ((Player.RtbCount - skull) < 2 and (Buff.LoadedDice:Exist() or not (Buff.RuthlessPrecision:Exist() or Buff.GrandMelee:Exist() or (Talent.DeeperStratagem and Buff.Broadside:Exist())))) and true or false
    -- elseif Player:TraitRank("AceUpYourSleeve") >= 1 or Player:TraitRank("Deadshot") >= 1 then
    --     -- print("bteroll")
    --     return (Player.RtbCount < 2 and
    --         (Buff.LoadedDice:Exist() or (Buff.RuthlessPrecision:Remain() <= Spell.BetweenTheEyes:CD()))) and true or false
    --     --rtb_reroll,value=rtb_buffs<2&(buff.loaded_dice.up|!buff.grand_melee.up&!buff.ruthless_precision.up)
    -- else
    --     -- print("last roll")
    --     return (Player.RtbCount < 2 and (Buff.LoadedDice:Exist() or not Buff.GrandMelee:Exist() or not Buff.RuthlessPrecision:Exist())) and true or false
	-- end
	-- rtb_buffs<2&(buff.buried_treasure.up|buff.grand_melee.up|buff.true_bearing.up)
	if Player.RtbCount == 1 and not Buff.Broadside:Exist() and not Buff.RuthlessPrecision:Exist() and not Buff.SkullAndCrossbones:Exist()  then return true end
    if Player.RtbCount >= 2 then return false end
    if Player.RtbCount == 0 then return true end
end

function OutlawShouldFinish()
    -- combo_points>=cp_max_spend-(buff.broadside.up+buff.opportunity.up)*(talent.quick_draw.enabled&(!talent.marked_for_death.enabled|cooldown.marked_for_death.remains>1))*(azerite.ace_up_your_sleeve.rank<2|!cooldown.between_the_eyes.up)|combo_points=animacharged_cp
	-- combo_points>=cp_max_spend-buff.broadside.up-(buff.opportunity.up*talent.quick_draw.enabled)|combo_points=animacharged_cp
    local FinishCPs = num(Buff.Broadside:Exist()) + num(Talent.QuickDraw and Buff.Opportunity:Exist())
    if Player.ComboPointsDeficit <= FinishCPs then
        return true
    end
    return false
end

local function BoteBeforeBte()
    if CDs and Player:EssenceMajor("BloodOfTheEnemy") and Spell.BloodOfTheEnemy:IsCastable() then
        if Spell.BloodOfTheEnemy:Cast(Player) then return true end
    end
end

local sndCP = {
    12,
    18,
    24,
    30,
    36,
    42
}
local function SnDRefresh()
    if Buff.SliceAndDice:Remain(Player) < sndCP[Player.ComboPoints] * 0.3 then
        return true
    end
end

local function OutlawFinishers(anima)

    -- actions.finish=between_the_eyes,if=buff.ruthless_precision.up|(azerite.deadshot.rank>=2&buff.roll_the_bones.up)
    if Spell.BetweenTheEyes:IsCastable(20) and HUD.Info ~= 3  then
        -- if BoteBeforeBte() then return true end
        for _, Unit in ipairs(Player:GetEnemies(20)) do
            if Spell.BetweenTheEyes:Cast(Unit) then
                return true
            end
        end
        return true
    end

    if Spell.SliceAndDice:IsReady() and SnDRefresh() and not anima then
        if Spell.SliceAndDice:Cast(Player) then return true end
        return true
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

    if Spell.Dispatch:IsCastable(5) then --and not forceroll and not rtbReroll() then --and cd.betweenTheEyes.remain() >= 0.2 then
        for _, Unit in ipairs(EnemyMelee) do
            if Spell.Dispatch:Cast(Unit) then
                return true
            end
        end
        return true
    end
end

local function OutlawEssencesAPL()
    if Player:EssenceMajor("FocusedAzeriteBeam") and Spell.FocusedAzeriteBeam:CDUp() and Setting("Auto BEAM") and EnemyMeleeCount >= 1 then
        if Spell.FocusedAzeriteBeam:Cast(Player) then
            return true
        end
    end
end

local function OutlawBuilders()
    if Setting("Vanish on ST") and EnemyMeleeCount == 1 and Player.Combat and not stealthedRogue and Spell.Vanish:CDUp() and Player.ComboPointsDeficit >= 2 + num(Buff.Broadside:Exist()) then
        if GCD > 0 and Player.Energy < 50 then return end
        if Spell.Vanish:Cast(Player) then vanishambush = true; return end
    end
    if Spell.MarkOfDeath:IsCastable(20) then
        for _, Unit in ipairs(Player:GetEnemies(20)) do
            if Unit.TTD <= 2 and Unit.TTD > 0 then
                if Spell.MarkOfDeath:Cast(Unit) then
                    return true
                end
            end
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
    if Spell.PistolShot:IsCastable(20) and Buff.Opportunity:Exist() and (Player.Energy < 45 or Talent.QuickDraw ) then
        for _, Unit in ipairs(Player:GetEnemies(20)) do
            if Spell.PistolShot:Cast(Unit) then
                return true
            end
        end
    end

    if Spell.SinisterStrike:IsCastable("Melee") then
        for _, Unit in ipairs(EnemyMelee) do
            if Debuff.BetweenTheEyes:Exist(Unit) and  Spell.SinisterStrike:Cast(Unit) then
                return true
            end
        end
        for _, Unit in ipairs(EnemyMelee) do
            if Spell.SinisterStrike:Cast(Unit) then
                return true
            end
        end
        return true
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
            for _,v in ipairs(DMW.Enemies) do
                if v.Distance <= 20 then
                    -- if Spell.Stealth:Cast() then return true end
                    CastSpellByName(Spell.Stealth.SpellName)
                    -- CastSpellByName()
                end
            end
        elseif Setting("Auto Stealth") == 3 then
            -- if Spell.Stealth:Cast() then return true end
            CastSpellByName(Spell.Stealth.SpellName)
        end
    end
end

local function PrecombatOutlaw()
    if (Setting("Ambush") ~= 1 or vanishambush) and Spell.Ambush:IsReady() then
        if Setting("Ambush") == 3 then
            for _, Unit in ipairs(DMW.Attackable) do
                if Unit.Distance <= 5 then
                    PotUsage()
                    if Spell.Ambush:Cast(Unit) then return true end
                end
            end
        end
        if Setting("Ambush") == 2 then
            for _, Unit in ipairs(EnemyMelee) do
                PotUsage()
                if Spell.Ambush:Cast(Unit) then return true end
            end
        end
        if vanishambush then
            for _, Unit in ipairs(EnemyMelee) do
                PotUsage()
                if Spell.Ambush:Cast(Unit) then return true end
            end
        end
    end
end

local poisonTime
local function Poisons()
    if not Player.Moving and not Player.Casting then
        if Setting("MH Poison") > 1 then
            local PoisonType = Setting("MH Poison") == 2 and "WoundPoison" or "InstantPoison"
            if (not Buff[PoisonType]:Exist(Player) or (Buff[PoisonType]:Remain(Player) <= 300 and not Player.Combat)) and Spell[PoisonType]:IsReady() then
                if Spell[PoisonType]:Cast(Player) then poisonTime = DMW.Time;return true end
            end
		end
		if Setting("OH Poison") > 1 then
            local PoisonType = Setting("OH Poison") == 2 and "CripplingPoison" or "NumbingPoison"
            if (not Buff[PoisonType]:Exist(Player) or (Buff[PoisonType]:Remain(Player) <= 300 and not Player.Combat)) and Spell[PoisonType]:IsReady() then
                if Spell[PoisonType]:Cast(Player) then poisonTime = DMW.Time;return true end
            end
        end
    end
end

local function Tricks()
    if Setting("Tricks") > 1 and Player.Combat and Spell.Tricks:IsReady() then
        if Setting("Tricks On CD") or Player:IsTankingAoE(30, 3) or (Setting("Tricks once in Combat") and TricksCombat) then
            if Setting("Tricks") == 2 then
                if Player.Focus then
                    if IsSpellInRange(Spell.Tricks.SpellName, Player.Focus.Pointer) == 1 then
                        Spell.Tricks:Cast(Player.Focus)
                        TricksCombat = false
                    end
                end
            elseif Setting("Tricks") == 3 then
                for _, Unit in pairs(DMW.Friends.Units) do
                    if UnitGroupRolesAssigned(Unit.Pointer) == "TANK" then
                        if IsSpellInRange(Spell.Tricks.SpellName, Unit.Pointer) == 1 then
                            Spell.Tricks:Cast(Unit)
                            TricksCombat = false
                        end
                    end
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
        if Setting("Cloak") > 0 and Player.HP <= Setting("Feint") then Spell.CloakOfShadows:Cast(Player) end
    end
end

local function isTotem(unit)
	local creatureType = UnitCreatureType(unit)
	if creatureType ~= nil then
		if creatureType == "Totem" or creatureType == "Tótem" or creatureType == "Totém"
			or creatureType == "Тотем" or creatureType == "토템" or creatureType == "图腾" or creatureType == "圖騰"
		then
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
		local instance = select(2,IsInInstance())
		return unit.Boss or unit.Dummy or (not UnitIsTrivial(unit) and instance ~= "party"
			and ((class == "rare" and healthMax > 4 * pHealthMax) or class == "rareelite" or class == "worldboss"
				or (class == "elite" and healthMax > 4 * pHealthMax and instance ~= "raid")	or UnitLevel(unit) < 0))
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
	(InterruptTarget == 4 and (not GetRaidTargetIndex(unit.Pointer) or GetRaidTargetIndex(unit.Pointer) ~= DMW.Settings.profile.Enemy.InterruptMark)) then
        return false
    end
    -- if hardinterrupt and not unit:CanCC("stun") then return false end
    local castStartTime, castEndTime, interruptID, interruptable, castLeft = 0, 0, 0, false, 999
    if unit.ValidEnemy and unit.Casting then
        -- Get Cast/Channel Info
        if (not unit:CastingInfo(8) or hardinterrupt) then -- Get spell cast time
            -- castStartTime = unit:CastingInfo(4)
            -- castEndTime = unit:CastingInfo(5)
            castLeft = unit:CastRemains() --castEndTime / 1000 - DMW.Time
            interruptID = unit:CastIdCheck()
            -- print(interruptID, castLeft, "casting")
			if HUD.CCMode == 1 and (Setting("Any Cast") or stunList[interruptID] or channelAsapList[interruptID] or channelLateList[interruptID])
			-- or (HUD.CCMode == 2 and
			 then interruptable = true
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
                    willkick = unit
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
                if forpro or (DMW.Time - castStartTime / 1000) >= DMW.Settings.profile.Enemy.InterruptDelay then
                    return true
                end
            end
        end
        return false
    end
end

local function CrowdControlAround()
	for _, Unit in ipairs(DMW.Enemies) do
		if Unit:IsCasting() then
			-- print(Unit.Name)
			-- print(Unit:CastCurrent())
			if Setting("AutoKick") and Unit.Distance <= 5 and Spell.Kick:CDUp() then
				if canInterruptshit(Unit, false) then
					if Setting("Delay") > 0 and Setting("Delay") < Unit:CastCurrent() then
						if Unit:CastRemains() > Player:GCD() + 0.3 then
							return
						else
							if Spell.Kick:Cast(Unit) then Unit.NextUpdate = DMW.Time;return  end
						end
					elseif Setting("Delay") == 0 then
						if Spell.Kick:Cast(Unit) then Unit.NextUpdate = DMW.Time;return  end
					end
				end
			end
			-- if isBoss(Unit.Pointer) or Unit.Boss then return end
			if Player.SpecID == "Outlaw" and Setting("AutoGouge") and Spell.Gouge:IsReady() and Unit.Distance <= 5 and ObjectIsFacing(Unit.Pointer, Player.Pointer) and Unit:CanCC("incapacitate") then
				if canInterruptshit(Unit, true, true) then
					if Setting("Delay") > 0 then
						if Setting("Delay for CC") then
							if Setting("Delay") <= Unit:CastCurrent() and Unit:CastRemains() >= Player:GCD() + 0.5 then
								return
							elseif Setting("Delay") < Unit:CastCurrent() then
								return true
							end
							if Spell.Gouge:Cast(Unit) then Unit.NextUpdate = DMW.Time;return true end
						else
							if Setting("Delay") >= Unit:CastCurrent() then
								if Spell.Gouge:Cast(Unit) then Unit.NextUpdate = DMW.Time;return true end
							end
						end
					elseif Setting("Delay") == 0 then
						if Spell.Gouge:Cast(Unit) then Unit.NextUpdate = DMW.Time;return true end
					end
				end
			end
			if Setting("AutoKidney") and Spell.KidneyShot:IsReady() and Player.ComboPoints > 0 and Unit.Distance <= 5 and Unit:CanCC("stun") then
				if canInterruptshit(Unit, true) then
					if Setting("Delay") > 0 then
						if Setting("Delay for CC") then
							if Setting("Delay") <= Unit:CastCurrent() and Unit:CastRemains() >= Player:GCD() + 0.5 then
								return
							elseif Setting("Delay") < Unit:CastCurrent() then
								return true
							end
							if Spell.KidneyShot:Cast(Unit) then Unit.NextUpdate = DMW.Time;return true end
						else
							if Setting("Delay") >= Unit:CastCurrent() then
								if Spell.KidneyShot:Cast(Unit) then Unit.NextUpdate = DMW.Time;return true end
							end
						end
					elseif Setting("Delay") == 0 then
						if Spell.KidneyShot:Cast(Unit) then Unit.NextUpdate = DMW.Time;return true end
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
							if Spell.CheapShot:Cast(Unit) then Unit.NextUpdate = DMW.Time;return true end
						else
							if Setting("Delay") >= Unit:CastCurrent() then
								if Spell.CheapShot:Cast(Unit) then Unit.NextUpdate = DMW.Time;return true end
							end
						end
					elseif Setting("Delay") == 0 then
						if Spell.CheapShot:Cast(Unit) then Unit.NextUpdate = DMW.Time;return true end
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
							if Spell.Blind:Cast(Unit) then Unit.NextUpdate = DMW.Time;return true end
						else
							if Setting("Delay") >= Unit:CastCurrent() then
								if Spell.Blind:Cast(Unit) then Unit.NextUpdate = DMW.Time;return true end
							end
						end
					elseif Setting("Delay") == 0 then
						if Spell.Blind:Cast(Unit) then Unit.NextUpdate = DMW.Time;return true end
					end
				end
			end
		end
	end
end

local function CrowdControl()
    for i = 1, #DMW.Enemies do
        local thisUnit = DMW.Enemies[i]
        local distance = thisUnit.Distance
        -- print(thisUnit.Name)
        -- if canInterruptshit(thisUnit, true) then
        --     print(thisUnit.Name, thisUnit:CastIdCheck())
        -- end
        if Setting("AutoKick") and distance <= 5 and Spell.Kick:CDUp() then
            if canInterruptshit(thisUnit, false) then if Spell.Kick:Cast(thisUnit) then return true end end
        end
        if isBoss(thisUnit.Pointer) or thisUnit.Boss then return end
        if Player.SpecID == "Outlaw" and Setting("AutoGouge") and Spell.Gouge:CDUp()  then
            if canInterruptshit(thisUnit, true, true) then
                if distance <= 5 and ObjectIsFacing(thisUnit.Pointer, Player.Pointer) then if Spell.Gouge:Cast(thisUnit) then return true end end
            end
        elseif Setting("AutoKidney") and Spell.KidneyShot:CDUp() and Player.ComboPoints > 0 then
            if canInterruptshit(thisUnit, true) then
                if distance <= 5 then if Spell.KidneyShot:Cast(thisUnit) then return true end end
            end
        elseif Setting("AutoCheapShot") and Spell.CheapShot:IsReady() then
            if canInterruptshit(thisUnit, true) then
                if distance <= 5 then if Spell.CheapShot:Cast(thisUnit) then return true end end
            end
        elseif Setting("AutoBlind") and distance <= 15 and Spell.Blind:CDUp() then
            if canInterruptshit(thisUnit, true) then if Spell.Blind:Cast(thisUnit) then return true end end
        end
    end
end

hooksecurefunc(DMW.Functions.AuraCache, "Event", function(...)
    local timeStamp, param, hideCaster, source, sourceName, sourceFlags, sourceRaidFlags, destination, destName, destFlags, destRaidFlags, spell, spellName, _, spellType =
    ...
    if DMW.Player.SpecID == "Outlaw" and destination == DMW.Player.GUID and source == destination then
        if spell == 315508 then
            C_Timer.After(0.2,function () RtbCache() end)
        end
    end
end)

-- hooksecurefunc(DMW.Functions.AuraCache, "Update", function(...)
--     local bleedsCount = 0

-- end)
local function checkBleeds()
    local count = 0
    for _, Unit in ipairs(Player:GetEnemies(15)) do
        if Debuff.DeadlyPoison:Exist(Unit) then--or Debuff.WoundPoison:Exist(Unit)
            if Debuff.Garrote:Exist(Unit) then
                count = count + 1
            end
            if Debuff.Rupture:Exist(Unit) then
                count = count + 1
            end
        end
    end
    return count
end

local function EnemiesInRange(Range)
    return select(2, Player:GetEnemies(Range))
end
local function BleedTickTime()
    return 2 / Player:SpellHaste()
end

local function ExsanguinatedBleedTickTime()
    return 1 / Player:SpellHaste()
end

local function AssassinationEnergyRegenCombined()
    -- actions+=/variable,name=energy_regen_combined,value=energy.regen+poisoned_bleeds*7%(2*spell_haste)
    return GetPowerRegen() and checkBleeds() * 7 / (2 * Player:SpellHaste());
end

local function AssassinationSingleTarget()
    -- actions+=/variable,name=single_target,value=spell_targets.fan_of_knives<2
    return EnemyFOKcount < 2
end

local function AssassinationUseFiller()
    -- actions+=/variable,name=single_target,value=combo_points.deficit>1|energy.deficit<=25+variable.energy_regen_combined|!variable.single_target
    return not AssassinationSingleTarget() or Player.ComboPointsDeficit > 1 or Player.EnergyDeficit <= 25 + AssassinationEnergyRegenCombined()
end


local function AssassinationSkipCycleGarrote()
    -- # Limit Garrotes on non-primrary targets for the priority rotation if 5+ bleeds are already up
    -- actions.dot=variable,name=skip_cycle_garrote,value=priority_rotation&spell_targets.fan_of_knives>3&(dot.garrote.remains<cooldown.garrote.duration|poisoned_bleeds>5)
    return HUD.PriorityMode == 1 and EnemyFOKcount > 3 and (Debuff.Garrote:Remain(Target) <= Spell.Garrote.BaseCD or checkBleeds() >= 5)
end

local function ToxicBladeCheck()
    for _, Unit in ipairs(EnemyMelee) do
        if Debuff.ToxicBlade:Exist(Unit) then
            return true
        end
    end
    return false
end

local function VendettaCheck()
    for _, Unit in ipairs(EnemyMelee) do
        if Debuff.Vendetta:Exist(Unit) then
            return true
        end
    end
    return false
end

local function AssassinationSkipCycleRupture()
    -- # Limit Ruptures on non-primrary targets for the priority rotation if 5+ bleeds are already up
    -- actions.dot+=/variable,name=skip_cycle_rupture,value=priority_rotation&spell_targets.fan_of_knives>3&(debuff.toxic_blade.up|(poisoned_bleeds>5&!azerite.scent_of_blood.enabled))
    return HUD.PriorityMode == 1 and EnemyFOKcount > 3 and ((checkBleeds() > 5 and not Player:TraitActive("ScentOfBlood")) or ToxicBladeCheck())
end

local function AssassinationSkipRupture()
    -- # Limit Ruptures if Vendetta+Toxic Blade/Master Assassin is up and we have 2+ seconds left on the Rupture DoT
    -- actions.dot+=/variable,name=skip_rupture,value=debuff.vendetta.up&(debuff.toxic_blade.up|master_assassin_remains>0)&dot.rupture.remains>2
    return VendettaCheck() and (Buff.MasterAssassin:Exist(Player) or ToxicBladeCheck()) and Debuff.Rupture:Remain(Target) > 2
end

local function AssassinationStealthedAPL()
    -- # Stealthed Actions
    -- # Nighstalker on 1T: Snapshot Rupture
    -- actions.stealthed=rupture,if=talent.nightstalker.enabled&combo_points>=4&target.time_to_die-remains>6
    if Talent.Nightstalker then
        if Target and Player.ComboPoints >= 4 and Target.TTD > 6 then
            if Spell.Rupture:Cast(Target) then return true end
        end
    end
    -- # Subterfuge + Shrouded Suffocation: Ensure we use one global to apply Garrote to the main target if it is not snapshot yet, so all other main target abilities profit.
    -- actions.stealthed+=/pool_resource,for_next=1
    -- actions.stealthed+=/garrote,if=azerite.shrouded_suffocation.enabled&buff.subterfuge.up&buff.subterfuge.remains<1.3&!ss_buffed
    if Talent.Subterfuge and Spell.Garrote:CDUp() and Player:TraitActive("ShroudedSuffocation") and Buff.Subterfuge:Remain(Player) < 1.3 and Target and Target.ValidEnemy and Target.Distance <= 5 and not Debuff.Garrote:SSBuffed(Target) then
        if Spell.Garrote:Pool() then return true end
        if Spell.Garrote:Cast(Target) then return true end
    end
    -- # Subterfuge: Apply or Refresh with buffed Garrotes
    -- actions.stealthed+=/pool_resource,for_next=1
    -- actions.stealthed+=/garrote,target_if=min:remains,if=talent.subterfuge.enabled&(remains<12|pmultiplier<=1)&target.time_to_die-remains>2
    if Talent.Subterfuge and Spell.Garrote:CDUp() then
        for _, Unit in ipairs(EnemyMelee) do
            if (Debuff.Garrote:Remain(Unit) < 12 or Debuff.Garrote:Multiplier(Unit) <= 1) and Unit.TTD - Debuff.Garrote:Remain(Unit) > 2 then
                if Spell.Garrote:Pool() then return true end
                if Spell.Garrote:Cast(Unit) then return true end
            end
        end
    end
    -- # Subterfuge + Shrouded Suffocation in ST: Apply early Rupture that will be refreshed for pandemic
    -- actions.stealthed+=/rupture,if=talent.subterfuge.enabled&azerite.shrouded_suffocation.enabled&!dot.rupture.ticking&variable.single_target
    if Target and Talent.Subterfuge and Player:TraitActive("ShroudedSuffocation") and Player.ComboPoints > 0 and not Debuff.Rupture:Exist(Target) and AssassinationSingleTarget() then
        if Spell.Rupture:Cast(Target) then return true end
    end
    -- # Subterfuge w/ Shrouded Suffocation: Reapply for bonus CP and/or extended snapshot duration.
    -- actions.stealthed+=/pool_resource,for_next=1
    -- actions.stealthed+=/garrote,target_if=min:remains,if=talent.subterfuge.enabled&azerite.shrouded_suffocation.enabled&(active_enemies>1|!talent.exsanguinate.enabled)&target.time_to_die>remains&(remains<18|!ss_buffed)
    if Talent.Subterfuge and Player:TraitActive("ShroudedSuffocation") and Spell.Garrote:CDUp() and (EnemyMeleeCount > 1 or not Talent.Exsanguinate or HUD.TierSevenMode == 2) then
        for _, Unit in ipairs(EnemyMelee) do
            if (Debuff.Garrote:Remain(Unit) < 18 or not Debuff.Garrote:SSBuffed(Unit)) and Unit.TTD > Debuff.Garrote:Remain(Unit) then
                if Spell.Garrote:Pool() then return true end
                if Spell.Garrote:Cast(Unit) then return true end
            end
        end
    end
    -- # Subterfuge + Exsg on 1T: Refresh Garrote at the end of stealth to get max duration before Exsanguinate
    -- actions.stealthed+=/pool_resource,for_next=1
    -- actions.stealthed+=/garrote,if=talent.subterfuge.enabled&talent.exsanguinate.enabled&active_enemies=1&buff.subterfuge.remains<1.3
    if Target and Talent.Subterfuge and Talent.Exsanguinate and HUD.TierSevenMode == 1 and Spell.Garrote:CDUp() and EnemyMeleeCount == 1 and Buff.Subterfuge:Remain(Player) < 1.3 then
        if Spell.Garrote:Pool() then return true end
        if Spell.Garrote:Cast(Target) then return true end
    end
end

local RuptureRefreshes = {
    [4] = 6,
    [5] = 7.2,
    [6] = 8.4
}

local CrimsonTempestRefreshes = {
    [4] = 3,
    [5] = 3.6,
    [6] = 4.2
}

local function RuptureRefreshable(Unit)
    local RefreshTime = RuptureRefreshes[Player.ComboPoints]
    return RefreshTime and Debuff.Rupture:Remain(Unit) <= RefreshTime
end

local function CrimsonTempestRefreshable(Unit)
    local RefreshTime = CrimsonTempestRefreshes[Player.ComboPoints]
    return RefreshTime and Debuff.CrimsonTempest:Remain(Unit) <= RefreshTime
end

local function HoldGarrotesOnPull()
    return Setting("HoldGarrotesOnPull") and Player:TraitActive("EchoingBlades") and EnemyFOKcount >= 3 and Debuff.Rupture:Count(EnemyMelee) < EnemyMeleeCount
end

local function AssassinationDotAPL()
    -- # Damage over time abilities
    -- # Special Garrote and Rupture setup prior to Exsanguinate cast
    -- actions.dot+=/garrote,if=talent.exsanguinate.enabled&!exsanguinated.garrote&dot.garrote.pmultiplier<=1&cooldown.exsanguinate.remains<2&spell_targets.fan_of_knives=1&raid_event.adds.in>6&dot.garrote.remains*0.5<target.time_to_die
    if Talent.Exsanguinate and HUD.TierSevenMode == 1 and Target then
        if Spell.Exsanguinate:CD() < 2 and Debuff.Garrote:Multiplier(Target) <= 1 and EnemyFOKcount == 1 and Debuff.Garrote:Remain(Target) < 2 * Target.TTD then
            if Spell.Garrote:Cast(Target) then return true end
        end
    -- actions.dot+=/rupture,if=talent.exsanguinate.enabled&(combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1&dot.rupture.remains*0.5<target.time_to_die)
        if Player.ComboPointsDeficit == 0 and Spell.Exsanguinate:CD() < 1 and Debuff.Rupture:Remain(Target) < Target.TTD * 2 then
            if Spell.Rupture:Cast(Target) then return true end
        end
    end
    -- # Garrote upkeep, also tries to use it as a special generator for the last CP before a finisher
    -- actions.dot+=/pool_resource,for_next=1
    -- actions.dot+=/garrote,if=refreshable&combo_points.deficit>=1+3*(azerite.shrouded_suffocation.enabled&cooldown.vanish.up)&(pmultiplier<=1|remains<=tick_time&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&(!exsanguinated|remains<=tick_time*2&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&!ss_buffed&(target.time_to_die-remains)>4&(master_assassin_remains=0|!ticking&azerite.shrouded_suffocation.enabled)
    if Target and Target.ValidEnemy and Target.Distance <= 5 and (not Talent.Subterfuge or HUD.VanishMode == 2 or not (Spell.Vanish:CDUp() and Spell.Vendetta:CD() <= 4 )) and Player.ComboPointsDeficit >= 1 + 3 * num(Player:TraitActive("ShroudedSuffocation") and CDs and Spell.Vanish:CDUp()) then
        if Debuff.Garrote:Refresh(Target) and (Debuff.Garrote:Multiplier(Target) <= 1 or Debuff.Garrote:Remain(Target) <= BleedTickTime() and EnemiesInRange(10) >= 3 + num(Player:TraitActive("ShroudedSuffocation"))) and (not Debuff.Garrote:Exsanguinated(Target) or Debuff.Garrote:Remain(Target) <= ExsanguinatedBleedTickTime() * 2 and EnemiesInRange(10) >= 3 +num(Player:TraitActive("ShroudedSuffocation")))  and (Target.TTD - Debuff.Garrote:Remain(Target)) > 4 and not Debuff.Garrote:SSBuffed(Target) and (not Buff.MasterAssassin:Exist(Player) or (not Debuff.Garrote:Exist(Target) and Player:TraitActive("ShroudedSuffocation"))) then
            if Spell.Garrote:Pool() then return true end
            if Spell.Garrote:Cast(Target) then return true end
        end
    end
    -- actions.dot+=/pool_resource,for_next=1
    -- actions.dot+=/garrote,cycle_targets=1,if=!variable.skip_cycle_garrote&target!=self.target&refreshable&combo_points.deficit>=1+3*(azerite.shrouded_suffocation.enabled&cooldown.vanish.up)&(pmultiplier<=1|remains<=tick_time&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&(!exsanguinated|remains<=tick_time*2&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&!ss_buffed&(target.time_to_die-remains)>12&(master_assassin_remains=0|!ticking&azerite.shrouded_suffocation.enabled)
    if not AssassinationSkipCycleGarrote() and not HoldGarrotesOnPull() and (not Talent.Subterfuge or HUD.VanishMode == 2 or not (Spell.Vanish:CDUp() and Spell.Vendetta:CD() <= 4 )) and Player.ComboPointsDeficit >= 1 + 3 * num(Player:TraitActive("ShroudedSuffocation") and HUD.VanishMode == 1 and Spell.Vanish:CDUp()) then
        for _, Unit in pairs(EnemyMelee) do
            if (not Target or Unit.Pointer ~= Target.Pointer) and Debuff.Garrote:Refresh(Unit) and (Debuff.Garrote:Multiplier(Unit) <= 1 or (Debuff.Garrote:Remain(Unit)<=ExsanguinatedBleedTickTime() and EnemyFOKcount >= 3 + num(Player:TraitActive("ShroudedSuffocation")))) and (not Debuff.Garrote:Exsanguinated(Unit) or (Debuff.Garrote:Remain(Unit) <= BleedTickTime() and EnemyFOKcount >= 3 + num(Player:TraitActive("ShroudedSuffocation")))) and (Unit.TTD - Debuff.Garrote:Remain(Unit)) > 12 and not Debuff.Garrote:SSBuffed(Unit) and (not Buff.MasterAssassin:Exist(Player) or (not Debuff.Garrote:Exist(Unit) and Player:TraitActive("ShroudedSuffocation")))
             then
                if Spell.Garrote:Pool() then return true end
                if Spell.Garrote:Cast(Unit) then return true end
            end
        end
    end
    -- # Crimson Tempest on multiple targets at 4+ CP when running out in 2s (up to 4 targets) or 3s (5+ targets)
    -- actions.dot+=/crimson_tempest,if=spell_targets>=2&remains<2+(spell_targets>=5)&combo_points>=4
    if Talent.CrimsonTempest and Player.ComboPoints >= 4 then
        if EnemyFOKcount >= 2 then
            -- local ctRemains = EnemyFOKcount <= 4 and 2 or 3
            for _, Unit in ipairs(EnemyFOK) do
                if Debuff.CrimsonTempest:Remain(Unit) <= 2 + num(EnemyFOKcount >= 5) then
                    if Spell.CrimsonTempest:Cast(Player) then return true end
                end
            end
        end
    end
    -- # Keep up Rupture at 4+ on all targets (when living long enough and not snapshot)
    -- actions.dot+=/rupture,if=!variable.skip_rupture&(combo_points>=4&refreshable|!ticking&(time>10|combo_points>=2))&(pmultiplier<=1|remains<=tick_time&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&(!exsanguinated|remains<=tick_time*2&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&target.time_to_die-remains>4
    if Target and not AssassinationSkipRupture() and Player.ComboPoints >= 4 then
        -- for _, Unit in ipairs(EnemyMelee) do
            if RuptureRefreshable(Target) and (Target.TTD - Debuff.Rupture:Remain(Target)) > 4 and
            (Debuff.Rupture:Multiplier(Target) <= 1 or Debuff.Rupture:Remain(Target) <= BleedTickTime() and EnemiesInRange(10) >= 3 + num(Player:TraitActive("ShroudedSuffocation"))) and
            (not Debuff.Rupture:Exsanguinated(Target) or Debuff.Rupture:Remain(Target) <= ExsanguinatedBleedTickTime() * 2 and EnemiesInRange(10) >= 3 +num(Player:TraitActive("ShroudedSuffocation"))) then
                if Spell.Rupture:Cast(Target) then return true end
            end
        -- end
    end
    -- actions.dot+=/rupture,cycle_targets=1,if=!variable.skip_cycle_rupture&!variable.skip_rupture&target!=self.target&combo_points>=4&refreshable&(pmultiplier<=1|remains<=tick_time&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&(!exsanguinated|remains<=tick_time*2&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&target.time_to_die-remains>4
    if Spell.Rupture:IsCastable("Melee") and not AssassinationSkipCycleRupture() and not AssassinationSkipRupture() and Player.ComboPoints >= 4 then
        for _, Unit in ipairs(EnemyMelee) do
            if (not Target or Unit.Pointer ~= Target.Pointer) and RuptureRefreshable(Unit) and (Debuff.Rupture:Multiplier(Unit) <= 1 or (Debuff.Rupture:Remain(Unit)<=ExsanguinatedBleedTickTime() and EnemyFOKcount >= 3 + num(Player:TraitActive("ShroudedSuffocation")))) and (not Debuff.Rupture:Exsanguinated(Unit) or (Debuff.Rupture:Remain(Unit) <= BleedTickTime() and EnemyFOKcount >= 3 + num(Player:TraitActive("ShroudedSuffocation")))) and (Unit.TTD - Debuff.Rupture:Remain(Unit)) >= 5 then
                if Spell.Rupture:Cast(Unit) then return true end
            end
        end
    end
    -- # Crimson Tempest on ST if in pandemic and it will do less damage than Envenom due to TB/MA/TtK
    -- actions.dot+=/crimson_tempest,if=spell_targets=1&combo_points>=(cp_max_spend-1)&refreshable&!exsanguinated&!debuff.toxic_blade.up&master_assassin_remains=0&!azerite.twist_the_knife.enabled&target.time_to_die-remains>4
    if Setting("CrimsonTempest ST") and Talent.CrimsonTempest and Target and AssassinationSingleTarget() and Player.ComboPointsDeficit <= 1 and CrimsonTempestRefreshable(Target) and not Debuff.ToxicBlade:Exist(Target) and not Buff.MasterAssassin:Exist(Player) and not Player.TraitActive("TwistTheKnife") and (Target.TTD - Debuff.CrimsonTempest:Remain(Target)) > 4 then
        if Spell.CrimsonTempest:Cast(Player) then return true end
    end

end

local function AssassinationDirectAPL()
    -- # Direct damage abilities
    --FOK when EP UP
    if ((Setting("FOK when EP up") and Buff.ElaboratePlanning:Exist()) or (Setting("FOK when Envenom up") and Buff.Envenom:Exist())) and not Buff.Stealth:Exist(Player) and Player:TraitActive("EchoingBlades") and EnemyFOKcount >= 2 + num(VendettaCheck()) + num(Player:TraitRank("EchoingBlades") == 1) then
        if Spell.FanOfKnives:Cast(Player) then return true end
    end
    -- # Envenom at 4+ (5+ with DS) CP. Immediately on 2+ targets, with Vendetta, or with TB; otherwise wait for some energy. Also wait if Exsg combo is coming up.
    -- actions.direct=envenom,if=combo_points>=4+talent.deeper_stratagem.enabled&(debuff.vendetta.up|debuff.toxic_blade.up|energy.deficit<=25+variable.energy_regen_combined|!variable.single_target)&(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)
    if Spell.Envenom:IsCastable("Melee") and Player.ComboPoints >= 4 + num(Talent.DeeperStratagem) and (not Talent.Exsanguinate or HUD.TierSevenMode == 2 or Spell.Exsanguinate:CD() > 2) then
        for _, Unit in ipairs(EnemyMelee) do
            if Debuff.Vendetta:Exist(Unit) or Debuff.ToxicBlade:Exist(Unit) or Player.EnergyDeficit <= 25 + AssassinationEnergyRegenCombined() or not AssassinationSingleTarget() or (Player.ComboPointsDeficit == 0 and Debuff.Garrote:Remain(Unit) <= 2) then
                if Spell.Envenom:Cast(Unit) then return true end
            end
        end
    end
    if AssassinationUseFiller() then
        -- # With Echoing Blades, Fan of Knives at 2+ targets, or 3-4+ targets when Vendetta is up
        -- actions.direct+=/fan_of_knives,if=variable.use_filler&azerite.echoing_blades.enabled&spell_targets.fan_of_knives>=2+(debuff.vendetta.up*(1+(azerite.echoing_blades.rank=1)))
        if Player:TraitActive("EchoingBlades") and not Buff.Stealth:Exist(Player) and EnemyFOKcount >= 2 + num(VendettaCheck()) + num(Player:TraitRank("EchoingBlades") == 1) then
            if Spell.FanOfKnives:Cast(Player) then return true end
        end
        -- # Fan of Knives at 19+ stacks of Hidden Blades or against 4+ (5+ with Double Dose) targets.
        -- actions.direct+=/fan_of_knives,if=variable.use_filler&(buff.hidden_blades.stack>=19|(!priority_rotation&spell_targets.fan_of_knives>=4+(azerite.double_dose.rank>2)+stealthed.rogue))
        if not Buff.Stealth:Exist(Player) and (Buff.HiddenBlades:Stacks() >= 19 or (HUD.PriorityMode == 2 and EnemyFOKcount >= 4 + num(Player:TraitRank("DoubleDose") > 2) + num(stealthedRogue))) then
            if Spell.FanOfKnives:Cast(Player) then return true end
        end
        -- # Fan of Knives to apply Deadly Poison if inactive on any target at 3 targets.
        -- actions.direct+=/fan_of_knives,target_if=!dot.deadly_poison_dot.ticking,if=variable.use_filler&spell_targets.fan_of_knives>=3
        if not Buff.Stealth:Exist(Player) and EnemyFOKcount >= 3 then
            for _, Unit in ipairs(EnemyFOK) do
                if not Debuff.DeadlyPoison:Exist(Unit) then
                    if Spell.FanOfKnives:Cast(Player) then return true end
                end
            end
        end
        -- actions.direct+=/blindside,if=variable.use_filler&(buff.blindside.up|!talent.venom_rush.enabled&!azerite.double_dose.enabled)
        -- # Tab-Mutilate to apply Deadly Poison at 2 targets
        -- actions.direct+=/mutilate,target_if=!dot.deadly_poison_dot.ticking,if=variable.use_filler&spell_targets.fan_of_knives=2
        if Spell.Mutilate:IsCastable("Melee") and EnemyMeleeCount == 2 then
            for _, Unit in ipairs(EnemyMelee) do
                if not Debuff.DeadlyPoison:Exist(Unit) then
                    if Spell.Mutilate:Cast(Unit) then return true end
                end
            end
        end
        -- actions.direct+=/mutilate,if=variable.use_filler
        if Spell.Mutilate:IsCastable("Melee") then
            for _, Unit in ipairs(EnemyMelee) do
                if Spell.Mutilate:Cast(Unit) then return true end
            end
        end
    end
end

--# Vendetta logical conditionals based on current spec
local function VendettaSubterfugeCondition()
    -- actions.cds+=/variable,name=vendetta_subterfuge_condition,value=!talent.subterfuge.enabled|!azerite.shrouded_suffocation.enabled|dot.garrote.pmultiplier>1&(spell_targets.fan_of_knives<6|!cooldown.vanish.up)
    return Target and (not Talent.Subterfuge or not Player:TraitActive("ShroudedSuffocation") or (Debuff.Garrote:Multiplier(Target) > 1 and (EnemyFOKcount < 6 or (HUD.VanishMode == 2 or Spell.Vanish:CDDown()))))
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
        local nonSSbuffedCount, ssBuffedAbovePandemicCount = 0,0
        for _, Unit in ipairs(EnemyMelee) do
            if Unit.TTD >= Setting("Vanish") and not Debuff.Garrote:SSBuffed(Unit) then
                nonSSbuffedCount = nonSSbuffedCount + 1
            else
                if not Debuff.Garrote:Refresh(Unit) then
                    ssBuffedAbovePandemicCount = ssBuffedAbovePandemicCount + 1
                end
            end
        end
        if (nonSSbuffedCount >= 1 or EnemyFOKcount == 3) and (ssBuffedAbovePandemicCount == 0 or EnemyFOKcount >= 6) then
            return true
        end
    end
    return false
end

local function vanishSSDeficitCP()
    if (1 + 2 * num(Player:TraitActive("ShroudedSuffocation"))) * EnemyMeleeCount >= 4 then
        return 4
    end
    return (1 + 2 * num(Player:TraitActive("ShroudedSuffocation"))) * EnemyMeleeCount
end

local function AssassinationEssencesAPL()
    -- actions.essences=concentrated_flame,if=energy.time_to_max>1&!debuff.vendetta.up&(!dot.concentrated_flame_burn.ticking&!action.concentrated_flame.in_flight|full_recharge_time<gcd.max)
    -- # Always use Blood with Vendetta up. Hold for Exsanguinate. Use with TB up before a finisher as long as it runs for 10s during Vendetta.
    -- actions.essences+=/blood_of_the_enemy,if=debuff.vendetta.up&(exsanguinated.garrote|debuff.toxic_blade.up&combo_points.deficit<=1|debuff.vendetta.remains<=10)|target.time_to_die<=10
    if Player:EssenceMajor("BloodOfTheEnemy") then
        if CDs and Setting("BOTE Auto") and Target and Debuff.Rupture:Exist(Target) and Spell.BloodOfTheEnemy:IsCastable() then
            if (EnemyMeleeCount <= 2 and VendettaCheck()) or (checkBleeds() >= EnemyMeleeCount + 3 and EnemyMeleeCount >= 3) then
                if Spell.BloodOfTheEnemy:Cast(Player) then return true end
            end
        end
        if not Buff.Stealth:Exist(Player) and Player:TraitActive("EchoingBlades") and EnemyFOKcount >= 3 and Buff.SeethingRage:Exist(Player) then
            if Spell.FanOfKnives:Cast(Player) then return true end
        end
    end
    if Player:EssenceMajor("FocusedAzeriteBeam") and Spell.FocusedAzeriteBeam:CDUp() and Setting("Auto BEAM") and EnemyMeleeCount >= 1 then
        if Spell.FocusedAzeriteBeam:Cast(Player) then
            return true
        end
    end
    -- # Attempt to align Guardian with Vendetta as long as it won't result in losing a full-value cast over the remaining duration of the fight
    -- actions.essences+=/guardian_of_azeroth,if=cooldown.vendetta.remains<3|debuff.vendetta.up|target.time_to_die<30
    -- actions.essences+=/guardian_of_azeroth,if=floor((target.time_to_die-30)%cooldown)>floor((target.time_to_die-30-cooldown.vendetta.remains)%cooldown)
    -- actions.essences+=/focused_azerite_beam,if=spell_targets.fan_of_knives>=2|raid_event.adds.in>60&energy<70
    -- actions.essences+=/purifying_blast,if=spell_targets.fan_of_knives>=2|raid_event.adds.in>60
    -- actions.essences+=/the_unbound_force,if=buff.reckless_force.up|buff.reckless_force_counter.stack<10
    -- actions.essences+=/ripple_in_space
    -- actions.essences+=/worldvein_resonance
    -- actions.essences+=/memory_of_lucid_dreams,if=energy<50&!cooldown.vendetta.up
    -- # Hold Reaping Flames for execute range or kill buffs, if possible. Always try to get the lowest cooldown based on available enemies.
    -- actions.essences+=/cycling_variable,name=reaping_delay,op=min,if=essence.breath_of_the_dying.major,value=target.time_to_die
    -- actions.essences+=/reaping_flames,target_if=target.time_to_die<1.5|((target.health.pct>80|target.health.pct<=20)&(active_enemies=1|variable.reaping_delay>29))|(target.time_to_pct_20>30&(active_enemies=1|variable.reaping_delay>44))
end

local function AssassinationCooldownsAPL()
    -- actions.cds=use_item,name=azsharas_font_of_power,if=!stealthed.all&master_assassin_remains=0&(cooldown.vendetta.remains<?(cooldown.toxic_blade.remains*equipped.ashvanes_razor_coral))<10+10*equipped.ashvanes_razor_coral&!debuff.vendetta.up&!debuff.toxic_blade.up
    -- actions.cds+=/call_action_list,name=essences,if=!stealthed.all&dot.rupture.ticking&master_assassin_remains=0
    if Target and Target.ValidEnemy and not stealthedRogue and not Buff.MasterAssassin:Exist(Player) then
        if AssassinationEssencesAPL() then return true end
    end
    -- # If adds are up, snipe the one with lowest TTD. Use when dying faster than CP deficit or without any CP.
    -- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=raid_event.adds.up&(target.time_to_die<combo_points.deficit*1.5|combo_points.deficit>=cp_max_spend)
    -- # If no adds will die within the next 30s, use MfD on boss without any CP.
    -- actions.cds+=/marked_for_death,if=raid_event.adds.in>30-raid_event.adds.duration&combo_points.deficit>=cp_max_spend



    -- actions.cds+=/vendetta,if=!stealthed.rogue&dot.rupture.ticking&!debuff.vendetta.up&variable.vendetta_subterfuge_condition&variable.vendetta_nightstalker_condition&variable.vendetta_font_condition
    if Target and HUD.VendettaMode == 1 and Target.TTD >= Setting("Vendetta") and EnemyMeleeCount <= Setting("Vendetta Enemies") and Spell.Vendetta:CDUp() and not stealthedRogue and Debuff.Rupture:Exist(Target) and not Debuff.Vendetta:Exist(Target) and VendettaSubterfugeCondition() and VendettaNightstalkerCondition() and VendettaFontCondition() then
        if Spell.Vendetta:Cast(Target) then return true end
    end
    -- # Vanish with Exsg + Nightstalker: Maximum CP and Exsg ready for next GCD
    -- actions.cds+=/vanish,if=talent.exsanguinate.enabled&talent.nightstalker.enabled&combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1
    -- # Vanish with Nightstalker + No Exsg: Maximum CP and Vendetta up (unless using VoP)
    -- actions.cds+=/vanish,if=talent.nightstalker.enabled&!talent.exsanguinate.enabled&combo_points>=cp_max_spend&(debuff.vendetta.up|essence.vision_of_perfection.enabled)
    -- # See full comment on https://github.com/Ravenholdt-TC/Rogue/wiki/Assassination-APL-Research.

    -- actions.cds+=/pool_resource,for_next=1,extra_amount=45
    -- actions.cds+=/vanish,if=talent.subterfuge.enabled&!stealthed.rogue&cooldown.garrote.up&(variable.ss_vanish_condition|!azerite.shrouded_suffocation.enabled&(dot.garrote.refreshable|debuff.vendetta.up&dot.garrote.pmultiplier<=1))&combo_points.deficit>=((1+2*azerite.shrouded_suffocation.enabled)*spell_targets.fan_of_knives)>?4&raid_event.adds.in>12
    if Talent.Subterfuge and HUD.VanishMode == 1 and Player.Combat and not stealthedRogue and Spell.Vanish:CDUp() and Spell.Garrote:CDUp() and (SSVanishCondition() or not Player:TraitActive("ShroudedSuffocation")) and Player.ComboPointsDeficit >= vanishSSDeficitCP() then
        if Spell.Garrote:Pool() then return true end
        if GCD <= 0.2 then
            if Spell.Vanish:Cast(Player) then return true end
        end
    end
    -- # Vanish with Master Assasin: No stealth and no active MA buff, Rupture not in refresh range, during Vendetta+TB+BotE (unless using VoP)
    -- actions.cds+=/vanish,if=talent.master_assassin.enabled&!stealthed.all&master_assassin_remains<=0&!dot.rupture.refreshable&dot.garrote.remains>3&(debuff.vendetta.up&(!talent.toxic_blade.enabled|debuff.toxic_blade.up)&(!essence.blood_of_the_enemy.major|debuff.blood_of_the_enemy.up)|essence.vision_of_perfection.enabled)
    -- # Shadowmeld for Shrouded Suffocation
    -- actions.cds+=/shadowmeld,if=!stealthed.all&azerite.shrouded_suffocation.enabled&dot.garrote.refreshable&dot.garrote.pmultiplier<=1&combo_points.deficit>=1
    -- # Exsanguinate when not stealthed and both Rupture and Garrote are up for long enough.
    -- actions.cds+=/exsanguinate,if=!stealthed.rogue&(!dot.garrote.refreshable&dot.rupture.remains>4+4*cp_max_spend|dot.rupture.remains*0.5>target.time_to_die)&target.time_to_die>4
    if Talent.Exsanguinate and HUD.TierSevenMode == 1 and Target and not stealthedRogue and (not Debuff.Garrote:Refresh(Target) and Debuff.Rupture:Remain(Target) > 4 + 4 * (4 + num(Talent.DeeperStratagem)) or Debuff.Rupture:Remain(Target) > 2 * Target.TTD) and Target.TTD > 4 then
        if Spell.Exsanguinate:Cast(Target) then return true end
    end
    -- actions.cds+=/toxic_blade,if=dot.rupture.ticking&(!equipped.azsharas_font_of_power|cooldown.vendetta.remains>10)
    if Talent.ToxicBlade and HUD.TierSevenMode == 1 and Spell.ToxicBlade:CDUp() and EnemyMeleeCount <= Setting("Toxic Blade Enemies") and Target and Target.TTD >= Setting("Toxic Blade") and Debuff.Rupture:Exist(Target)then
        if Spell.ToxicBlade:Cast(Target) then return true end
    end
    -- actions.cds+=/potion,if=buff.bloodlust.react|debuff.vendetta.up
    -- actions.cds+=/blood_fury,if=debuff.vendetta.up
    -- actions.cds+=/berserking,if=debuff.vendetta.up
    -- actions.cds+=/fireblood,if=debuff.vendetta.up
    -- actions.cds+=/ancestral_call,if=debuff.vendetta.up
    -- actions.cds+=/use_item,name=galecallers_boon,if=(debuff.vendetta.up|(!talent.exsanguinate.enabled&cooldown.vendetta.remains>45|talent.exsanguinate.enabled&(cooldown.exsanguinate.remains<6|cooldown.exsanguinate.remains>20&fight_remains>65)))&!exsanguinated.rupture
    -- actions.cds+=/use_item,name=ashvanes_razor_coral,if=debuff.razor_coral_debuff.down|target.time_to_die<20
    -- actions.cds+=/use_item,name=ashvanes_razor_coral,if=(!talent.exsanguinate.enabled|!talent.subterfuge.enabled)&debuff.vendetta.remains>10-4*equipped.azsharas_font_of_power
    -- actions.cds+=/use_item,name=ashvanes_razor_coral,if=(talent.exsanguinate.enabled&talent.subterfuge.enabled)&debuff.vendetta.up&(exsanguinated.garrote|azerite.shrouded_suffocation.enabled&dot.garrote.pmultiplier>1)
    -- actions.cds+=/use_item,effect_name=cyclotronic_blast,if=master_assassin_remains=0&!debuff.vendetta.up&!debuff.toxic_blade.up&buff.memory_of_lucid_dreams.down&energy<80&dot.rupture.remains>4
    -- actions.cds+=/use_item,name=lurkers_insidious_gift,if=debuff.vendetta.up
    -- actions.cds+=/use_item,name=lustrous_golden_plumage,if=debuff.vendetta.up
    -- actions.cds+=/use_item,effect_name=gladiators_medallion,if=debuff.vendetta.up
    -- actions.cds+=/use_item,effect_name=gladiators_badge,if=debuff.vendetta.up
    -- # Default fallback for usable items: Use on cooldown.
    -- actions.cds+=/use_items
end

local function OutlawExplosives()
    if HUD.Info == 2 or Setting("Always Take Care of Explosives") then
        for _, Unit in ipairs(EnemyMelee) do
            if Unit.ObjectID == 120651 then
                if OutlawShouldFinish() then
                    if Spell.Dispatch:Cast(Unit) then return true end
                else
                    if Buff.Opportunity:Exist(Player) and not Buff.Deadshot:Exist(Player) then
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
        if DMW.Settings.profile.Enemy.AutoFace  then
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
    if lowestTTDUnit and lowestTTD <= 2 then
        if Spell.MarkedForDeath:Cast(lowestTTDUnit) then return true end
    end
end

local function SubtletyFinisher()
    -- if Spell.SecretTechnique:IsReady() then
    --     for _, Unit in ipairs(EnemyMelee) do
    --         if Spell.SecretTechnique:Cast(Unit) then return true end
    --     end
    -- elseif Spell.Eviscerate:IsReady() then
    --     for _, Unit in ipairs(EnemyMelee) do
    --         if Spell.Eviscerate:Cast(Unit) then return true end
    --     end
    -- end

    -- actions.finish=slice_and_dice,if=spell_targets.shuriken_storm<6&!buff.shadow_dance.up&buff.slice_and_dice.remains<fight_remains&buff.slice_and_dice.remains<(1+combo_points)*1.8
    if Spell.SliceAndDice:IsReady() and Enemy10YC < 6 and not Buff.ShadowDance:Exist() and Buff.SliceAndDice:Remain() < (1 + Player.ComboPoints) * 1.8 then
        if Spell.SliceAndDice:Cast() then return true end
    end
    -- # Helper Variable for Rupture. Skip during Master Assassin or during Dance with Dark and no Nightstalker.
    -- actions.finish+=/variable,name=skip_rupture,value=master_assassin_remains>0|!talent.nightstalker.enabled&talent.dark_shadow.enabled&buff.shadow_dance.up|spell_targets.shuriken_storm>=6
    -- # Keep up Rupture if it is about to run out.
    -- actions.finish+=/rupture,if=!variable.skip_rupture&target.time_to_die-remains>6&refreshable
    if Spell.Rupture:IsReady() and Target and not SkipRupture then
        -- for _, Unit in ipairs(EnemyMelee) do
            if Target.TTD > 8 and RuptureRefreshable(Target) then
                if Spell.Rupture:Cast(Target) then return true end
            end
        -- end
    end
    -- actions.finish+=/secret_technique
    if Talent.SecretTechnique and Spell.SecretTechnique:IsReady() and not GetKeyState(0x10) then
        for _, Unit in ipairs(EnemyMelee) do
            if Debuff.FindWeakness:Exist(Unit) then
                if Spell.SecretTechnique:Cast(Unit) then return true end
            end
        end
        for _, Unit in ipairs(EnemyMelee) do
            if Spell.SecretTechnique:Cast(Unit) then return true end
        end
	end
	if  HUD.PriorityMode == 1 and Target then
		if Spell.Eviscerate:IsReady() and Spell.Eviscerate:Cast(Target) then return true end
		return true
	end
    if Enemy10YC >= 3 and Spell.BlackPowder:IsReady() then
        -- for _, Unit in ipairs(EnemyMelee) do
            if Spell.BlackPowder:Cast(Player) then return true end
        -- end
    end
    -- # Multidotting targets that will live for the duration of Rupture, refresh during pandemic.
    -- actions.finish+=/rupture,cycle_targets=1,if=!variable.skip_rupture&!variable.use_priority_rotation&spell_targets.shuriken_storm>=2&target.time_to_die>=(5+(2*combo_points))&refreshable
    if Spell.Rupture:IsReady() and not SkipRupture and not usePriorityRotation and Enemy10YC >= 2 then
        for _, Unit in ipairs(EnemyMelee) do
            if Unit.TTD > (5 + 2 * Player.ComboPoints) and RuptureRefreshable(Unit) then
                if Spell.Rupture:Cast(Unit) then return true end
            end
        end
    end
    -- # Refresh Rupture early if it will expire during Symbols. Do that refresh if SoD gets ready in the next 5s.
    -- actions.finish+=/rupture,if=!variable.skip_rupture&remains<cooldown.symbols_of_death.remains+10&cooldown.symbols_of_death.remains<=5&target.time_to_die-remains>cooldown.symbols_of_death.remains+5
    if Spell.Rupture:IsReady() and Target and not SkipRupture and Debuff.Rupture:Remain(Target) < Spell.SymbolsOfDeath:CD() + 10 and Target.TTD > Spell.SymbolsOfDeath:CD() + 10 and Spell.SymbolsOfDeath:CD() <= 5 and CDs then
        if Spell.Rupture:Cast(Target) then return true end
    end
    -- actions.finish+=/eviscerate
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
    -- if Enemy10YC >= 3 then
    --     if Spell.ShurikenStorm:IsReady() then
    --         if Spell.ShurikenStorm:Cast() then return true end
    --     end
    -- elseif Spell.ShadowStrike:IsReady() then--Spell.ShadowStrike:IsReady() then
    --     for _, Unit in ipairs(Enemy10Y) do
    --         if Spell.ShadowStrike:Cast(Unit) then return true end
    --     end
    -- elseif Enemy10YC >= 2 then
    --     if Spell.ShurikenStorm:IsReady() then
    --         if Spell.ShurikenStorm:Cast() then return true end
    --     end
    -- else
    --     if Talent.GloomBlade and Spell.GloomBlade:IsReady() then
    --         for _, Unit in ipairs(EnemyMelee) do
    --             if Spell.GloomBlade:Cast(Unit) then return true end
    --         end
    --     elseif Spell.Backstab:IsReady() then
    --         for _, Unit in ipairs(EnemyMelee) do
    --             if Spell.Backstab:Cast(Unit) then return true end
    --         end
    --     end
    -- end
    -- actions.build=shuriken_storm,if=spell_targets>=2+(talent.gloomblade.enabled&azerite.perforate.rank>=2&position_back)
    -- actions.build+=/serrated_bone_spike,if=cooldown.serrated_bone_spike.charges_fractional>=2.75
    -- actions.build+=/gloomblade
    -- actions.build+=/backstab
    if Enemy10YC >= 2 then
        if Spell.ShurikenStorm:IsReady() then
            if Spell.ShurikenStorm:Cast(Player) then return true end
        end
    elseif Talent.Gloomblade and Spell.Gloomblade:IsReady() then
        for _, Unit in ipairs(EnemyMelee) do
            if Spell.Gloomblade:Cast(Unit) then return true end
        end
    elseif Spell.Backstab:IsReady()  then
        for _, Unit in ipairs(EnemyMelee) do
            if Spell.Backstab:Cast(Unit) then return true end
        end
    end
end

local function SubtletyStealthed()
    -- # Stealthed Rotation
    -- # If Stealth/vanish are up, use Shadowstrike to benefit from the passive bonus and Find Weakness, even if we are at max CP (from the precombat MfD).
    -- actions.stealthed=shadowstrike,if=(buff.stealth.up|buff.vanish.up)
    if Buff.Stealth:Exist() or Buff.Vanish:Exist() then
        for _, Unit in ipairs(EnemyMelee) do
            if Spell.ShadowStrike:Cast(Unit) then return true end
        end
    end
    -- # Finish at 3+ CP without DS / 4+ with DS with Shuriken Tornado buff up to avoid some CP waste situations.
    -- actions.stealthed+=/call_action_list,name=finish,if=buff.shuriken_tornado.up&combo_points.deficit<=2
    if Talent.ShurikenTornado and Buff.ShurikenTornado:Exist() and Player.ComboPointsDeficit <= 2 then
        if SubtletyFinisher() then return true end
    end
    -- # Also safe to finish at 4+ CP with exactly 4 targets. (Same as outside stealth.)
    -- actions.stealthed+=/call_action_list,name=finish,if=spell_targets.shuriken_storm=4&combo_points>=4
    if Enemy10YC == 4 and Player.ComboPoints >= 4 then
        if SubtletyFinisher() then return true end
    end
    -- # Finish at 4+ CP without DS, 5+ with DS, and 6 with DS after Vanish
    -- actions.stealthed+=/call_action_list,name=finish,if=combo_points.deficit<=1-(talent.deeper_stratagem.enabled&buff.vanish.up)
    if Player.ComboPointsDeficit <= 1 - num(Talent.DeeperStratagem and Buff.Vanish:Exist()) then
        if SubtletyFinisher() then return true end
    end

	--TODO CHECK
    -- if Target and Target.TTD >= 5 and not Debuff.FindWeakness:Exist(Target) then
    --     if Spell.ShadowStrike:Cast(Target) then return true end
    -- end
    -- # Up to 3 targets keep up Find Weakness by cycling Shadowstrike.
    -- actions.stealthed+=/shadowstrike,cycle_targets=1,if=debuff.find_weakness.remains<1&spell_targets.shuriken_storm<=3&target.time_to_die-remains>6
    if Spell.ShadowStrike:IsReady() and Enemy10YC <= 3 then
        for _, Unit in ipairs(EnemyMelee) do
            if Unit.TTD >= 6 and Debuff.FindWeakness:Remain(Unit) < 1 then
                if Spell.ShadowStrike:Cast(Unit) then return true end
            end
        end
    end
    -- # Without Deeper Stratagem and 3 Ranks of Blade in the Shadows it is worth using Shadowstrike on 3 targets.
    -- actions.stealthed+=/shadowstrike,if=!talent.deeper_stratagem.enabled&azerite.blade_in_the_shadows.rank=3&spell_targets.shuriken_storm=3
    -- if Spell.ShadowStrike:IsReady() and not Talent.DeeperStratagem and  Azerite
    -- # For priority rotation, use Shadowstrike over Storm 1) with WM against up to 4 targets, 2) if FW is running off (on any amount of targets), or 3) to maximize SoD extension with Inevitability on 3 targets (4 with BitS).
    -- actions.stealthed+=/shadowstrike,if=
    -- variable.use_priority_rotation&
    -- (debuff.find_weakness.remains<1|talent.weaponmaster.enabled&spell_targets.shuriken_storm<=4|azerite.inevitability.enabled&buff.symbols_of_death.up&spell_targets.shuriken_storm<=3+azerite.blade_in_the_shadows.enabled)
    if Spell.ShadowStrike:IsReady() and usePriorityRotation then
        if Target and (not (Debuff.FindWeakness:Remain(Target) <= 1) or (Enemy10YC <= 4 and Talent.WeaponMaster) or (Player:TraitActive("Inevitability") and Buff.SymbolsOfDeath:Exist() and Enemy10YC <= 3 + num(Player:TraitActive("BladeInTheShadows")))) then
            if Spell.ShadowStrike:Cast(Target) then return true end
        end
    end
    -- actions.stealthed+=/shuriken_storm,if=spell_targets>=3+(buff.premeditation.up|buff.the_rotten.up|runeforge.akaaris_soul_fragment.equipped&conduit.deeper_daggers.rank>=7)
    if Spell.ShurikenStorm:IsReady() then
        if Enemy10YC >= 3 + num(Buff.Premeditation:Exist()) then
            if Spell.ShurikenStorm:Cast(Player) then return true end
        end
    end
    -- # Shadowstrike to refresh Find Weakness and to ensure we can carry over a full FW into the next SoD if possible.
    -- actions.stealthed+=/shadowstrike,if=debuff.find_weakness.remains<=1|cooldown.symbols_of_death.remains<18&debuff.find_weakness.remains<cooldown.symbols_of_death.remains
    if Target and Spell.ShadowStrike:IsReady() then
        if Debuff.FindWeakness:Remain(Target) <= 1 or (Spell.SymbolsOfDeath:CD() < 18 and Debuff.FindWeakness:Remain() < Spell.SymbolsOfDeath:CD()) then
            if Spell.ShadowStrike:Cast(Target) then return true end
        end
    end
    -- actions.stealthed+=/pool_resource,for_next=1
    -- actions.stealthed+=/gloomblade,if=!runeforge.akaaris_soul_fragment.equipped&buff.perforated_veins.stack>=3&conduit.perforated_veins.rank>=13-(9*conduit.deeper_dagger.enabled+conduit.deeper_dagger.rank)
    -- actions.stealthed+=/gloomblade,if=runeforge.akaaris_soul_fragment.equipped&buff.perforated_veins.stack>=3&(conduit.perforated_veins.rank+conduit.deeper_dagger.rank)>=16
    if Spell.ShadowStrike:IsReady() then
        for _, Unit in ipairs(Enemy10Y) do
            if Spell.ShadowStrike:Cast(Unit) then return true end
        end
    end
    -- actions.stealthed+=/shadowstrike
    return true
end

local function SubtletyStealthCDs()
    -- # Stealth Cooldowns
    -- # Helper Variable
    -- actions.stealth_cds=variable,name=shd_threshold,value=cooldown.shadow_dance.charges_fractional>=1.75
    -- # Vanish if we are capping on Dance charges. Early before first dance if we have no Nightstalker but Dark Shadow in order to get Rupture up (no Master Assassin).
    -- actions.stealth_cds+=/vanish,if=(!variable.shd_threshold|!talent.nightstalker.enabled&talent.dark_shadow.enabled)&combo_points.deficit>1&!runeforge.mark_of_the_master_assassin.equipped

    -- actions.stealth_cds+=/sepsis
    -- # Pool for Shadowmeld + Shadowstrike unless we are about to cap on Dance charges. Only when Find Weakness is about to run out.
    -- actions.stealth_cds+=/pool_resource,for_next=1,extra_amount=40
    -- actions.stealth_cds+=/shadowmeld,if=energy>=40&energy.deficit>=10&!variable.shd_threshold&combo_points.deficit>1&debuff.find_weakness.remains<1

    -- # CP requirement: Dance at low CP by default.
    -- actions.stealth_cds+=/variable,name=shd_combo_points,value=combo_points.deficit>=4

    -- # CP requirement: Dance only before finishers if we have priority rotation.
    -- actions.stealth_cds+=/variable,name=shd_combo_points,value=combo_points.deficit<=1,if=variable.use_priority_rotation
    local ShDComboPoints = HUD.Priority == 1 and Player.ComboPointsDeficit <= 1 or Player.ComboPointsDeficit >= 4
    -- # Dance during Symbols or above threshold.
    -- actions.stealth_cds+=/shadow_dance,if=variable.shd_combo_points&(variable.shd_threshold|buff.symbols_of_death.remains>=1.2|spell_targets.shuriken_storm>=4&cooldown.symbols_of_death.remains>10)
    if Spell.ShadowDance:IsReady() and EnemyMeleeCount >= 1 and sndCondition and ShDComboPoints and (ShDthreshold or Buff.SymbolsOfDeath:Remain()>= 1.2 or (Enemy10YC >= 4 and Spell.SymbolsOfDeath:CD() > 10))
    then
        if Spell.ShadowDance:Cast() then
            forceStealthed = true;
            C_Timer.After(1, function ()
                forceStealthed = false
            end)
            return true end
    end
    -- # Burn remaining Dances before the fight ends if SoD won't be ready in time.
    -- actions.stealth_cds+=/shadow_dance,if=variable.shd_combo_points&fight_remains<cooldown.symbols_of_death.remains
    -- if Spell.ShadowDance:ChargesFrac() >= 1 and ShDComboPoints and
end

local function SubtletyCooldowns()
    -- # Cooldowns
    -- # Use Dance off-gcd before the first Shuriken Storm from Tornado comes in.
    -- actions.cds=shadow_dance,use_off_gcd=1,if=!buff.shadow_dance.up&buff.shuriken_tornado.up&buff.shuriken_tornado.remains<=3.5
    if Talent.ShurikenTornado and Spell.ShadowDance:ChargesFrac() >= 1 and not Buff.ShadowDance:Exist() and Buff.ShurikenTornado:Exist() and Buff.ShurikenTornado:Remain() <= 3.5 then
        if Spell.ShadowDance:Cast() then
            forceStealthed = true;
            C_Timer.After(1, function ()
                forceStealthed = false
            end)
            return true
         end
    end
    -- # (Unless already up because we took Shadow Focus) use Symbols off-gcd before the first Shuriken Storm from Tornado comes in.
    -- actions.cds+=/symbols_of_death,use_off_gcd=1,if=buff.shuriken_tornado.up&buff.shuriken_tornado.remains<=3.5
	if Spell.SymbolsOfDeath:CDUp() and Buff.ShurikenTornado:Exist() and Buff.ShurikenTornado:Remain() <= 3.5 then
		if Setting("Racials") and Spell.BloodFury:IsReady() then
			if Spell.BloodFury:Cast(Player) then return true end
		end
        if Spell.SymbolsOfDeath:Cast() then return true end
    end
    -- actions.cds+=/flagellation,if=variable.snd_condition&!stealthed.mantle
    -- actions.cds+=/flagellation_cleanse,if=debuff.flagellation.remains<2|debuff.flagellation.stack>=40
    -- actions.cds+=/vanish,if=(runeforge.mark_of_the_master_assassin.equipped&combo_points.deficit<=3|runeforge.deathly_shadows.equipped&combo_points<1)&buff.symbols_of_death.up&buff.shadow_dance.up&master_assassin_remains=0&buff.deathly_shadows.down
    -- actions.cds+=/call_action_list,name=essences,if=!stealthed.all&variable.snd_condition|essence.breath_of_the_dying.major&time>=2
    -- # Pool for Tornado pre-SoD with ShD ready when not running SF.
    -- actions.cds+=/pool_resource,for_next=1,if=!talent.shadow_focus.enabled
    -- # Use Tornado pre SoD when we have the energy whether from pooling without SF or just generally.
    -- actions.cds+=/shuriken_tornado,if=energy>=60&variable.snd_condition&cooldown.symbols_of_death.up&cooldown.shadow_dance.charges>=1
    -- actions.cds+=/serrated_bone_spike,cycle_targets=1,if=variable.snd_condition&!dot.serrated_bone_spike_dot.ticking|fight_remains<=5
    -- # Use Symbols on cooldown (after first SnD) unless we are going to pop Tornado and do not have Shadow Focus. Low CP for The Rotten.
    -- actions.cds+=/symbols_of_death,if=variable.snd_condition&!cooldown.shadow_blades.up&(talent.enveloping_shadows.enabled|cooldown.shadow_dance.charges>=1)&(!talent.shuriken_tornado.enabled|talent.shadow_focus.enabled|cooldown.shuriken_tornado.remains>2)&(!essence.blood_of_the_enemy.major|cooldown.blood_of_the_enemy.remains>2)

    if Spell.SymbolsOfDeath:CDUp() and not Buff.Vanish:Exist() and sndCondition and (Talent.EnvelopingShadows or Spell.ShadowDance:ChargesFrac() >= 1) and (not Talent.ShurikenTornado or Talent.ShadowFocus or Spell.ShurikenTornado:CD() > 2)  then
        if not Player:EssenceMajor("BloodOfTheEnemy") or Spell.BloodOfTheEnemy:CD() >= 2 then
            if Spell.SymbolsOfDeath:Cast() then
				RogueTrinkets()
				if Setting("Racials") and Spell.BloodFury:IsReady() then
					if Spell.BloodFury:Cast(Player) then return true end
				end
                Spell.ShadowDance:Cast()
                forceStealthed = true;
                C_Timer.After(1, function ()
                    forceStealthed = false
                end)
                if Setting("ShadowBlades") > 1 and CDs and Spell.ShadowBlades:IsReady() and sndCondition and Player.ComboPointsDeficit >= 2 then
                    if Setting("ShadowBlades") == 3 or (Setting("ShadowBlades") == 2 and Target and Target:IsBoss()) then
                        if Spell.ShadowBlades:Cast() then end
                    end
                end
                return true
            end
        end
    end
    -- # If adds are up, snipe the one with lowest TTD. Use when dying faster than CP deficit or not stealthed without any CP.
    -- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=raid_event.adds.up&(target.time_to_die<combo_points.deficit|!stealthed.all&combo_points.deficit>=cp_max_spend)
    -- # If no adds will die within the next 30s, use MfD on boss without any CP.
    -- actions.cds+=/marked_for_death,if=raid_event.adds.in>30-raid_event.adds.duration&combo_points.deficit>=cp_max_spend
    -- actions.cds+=/shadow_blades,if=variable.snd_condition&combo_points.deficit>=2
    if Setting("ShadowBlades") > 1 and CDs and Spell.ShadowBlades:IsReady() and sndCondition and Player.ComboPointsDeficit >= 2 then
        if Setting("ShadowBlades") == 3 or (Setting("ShadowBlades") == 2 and Target and Target:IsBoss()) then
            if Spell.ShadowBlades:Cast() then end
        end
    end
    -- actions.cds+=/echoing_reprimand,if=variable.snd_condition&combo_points.deficit>=3&(variable.use_priority_rotation|spell_targets.shuriken_storm<=4)
    if Player.Covenant == "Kyrian" and Spell.EchoingReprimand:IsCastable(5) and CDs and sndCondition and Player.ComboPointsDeficit >= 2 and (usePriorityRotation or Enemy10YC <= 4) then
        for _,Unit in ipairs(EnemyMelee) do
            if Spell.EchoingReprimand:Cast(Unit) then return true end
        end
    end
    -- # With SF, if not already done, use Tornado with SoD up.
    -- actions.cds+=/shuriken_tornado,if=talent.shadow_focus.enabled&variable.snd_condition&buff.symbols_of_death.up
    if Spell.ShurikenTornado:IsReady() and Talent.ShadowFocus and sndCondition and Buff.SymbolsOfDeath:Exist() then
        if Spell.ShurikenTornado:Cast() then return true end
    end
    -- actions.cds+=/shadow_dance,if=!buff.shadow_dance.up&fight_remains<=8+talent.subterfuge.enabled
    -- if Spell.ShadowDance:Charges() >= 1 and not Buff.ShadowDance:Exist()

    -- actions.cds+=/potion,if=buff.bloodlust.react|buff.symbols_of_death.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=10)

    -- actions.cds+=/blood_fury,if=buff.symbols_of_death.up
    -- actions.cds+=/berserking,if=buff.symbols_of_death.up
    -- actions.cds+=/fireblood,if=buff.symbols_of_death.up
    -- actions.cds+=/ancestral_call,if=buff.symbols_of_death.up
    -- actions.cds+=/use_item,effect_name=cyclotronic_blast,if=!stealthed.all&variable.snd_condition&!buff.symbols_of_death.up&energy.deficit>=30
    -- actions.cds+=/use_item,name=azsharas_font_of_power,if=!buff.shadow_dance.up&cooldown.symbols_of_death.remains<10
    -- # Very roughly rule of thumbified maths below: Use for Inkpod crit, otherwise with SoD at 25+ stacks or 15+ with also Blood up.
    -- actions.cds+=/use_item,name=ashvanes_razor_coral,if=debuff.razor_coral_debuff.down|debuff.conductive_ink_debuff.up&target.health.pct<32&target.health.pct>=30|!debuff.conductive_ink_debuff.up&(debuff.razor_coral_debuff.stack>=25-10*debuff.blood_of_the_enemy.up|fight_remains<40)&buff.symbols_of_death.remains>8
    -- actions.cds+=/use_item,name=mydas_talisman
    -- # Default fallback for usable items: Use with Symbols of Death.
    -- actions.cds+=/use_items,if=buff.symbols_of_death.up|fight_remains<20
end

local function SubtletyEssences()
    -- actions.essences=concentrated_flame,if=energy.time_to_max>1&!buff.symbols_of_death.up&(!dot.concentrated_flame_burn.ticking&!action.concentrated_flame.in_flight|full_recharge_time<gcd.max)
-- actions.essences+=/blood_of_the_enemy,if=!cooldown.shadow_blades.up&cooldown.symbols_of_death.up|fight_remains<=10
-- actions.essences+=/guardian_of_azeroth
-- actions.essences+=/focused_azerite_beam,if=(spell_targets.shuriken_storm>=2|raid_event.adds.in>60)&!cooldown.symbols_of_death.up&!buff.symbols_of_death.up&energy.deficit>=30
-- actions.essences+=/purifying_blast,if=spell_targets.shuriken_storm>=2|raid_event.adds.in>60
-- actions.essences+=/the_unbound_force,if=buff.reckless_force.up|buff.reckless_force_counter.stack<10
-- actions.essences+=/ripple_in_space
-- actions.essences+=/worldvein_resonance,if=cooldown.symbols_of_death.remains<5|fight_remains<18
-- actions.essences+=/memory_of_lucid_dreams,if=energy<40&buff.symbols_of_death.up
-- # Hold Reaping Flames for execute range or kill buffs, if possible. Always try to get the lowest cooldown based on available enemies.
-- actions.essences+=/cycling_variable,name=reaping_delay,op=min,if=essence.breath_of_the_dying.major,value=target.time_to_die
-- actions.essences+=/reaping_flames,target_if=target.time_to_die<1.5|((target.health.pct>80|target.health.pct<=20)&(active_enemies=1|variable.reaping_delay>29))|(target.time_to_pct_20>30&(active_enemies=1|variable.reaping_delay>44))
    if Setting("Auto BEAM") and Player:EssenceMajor("FocusedAzeriteBeam") and Spell.FocusedAzeriteBeam:CDUp() and Spell.SymbolsOfDeath:CDDown() then
        if EnemyMeleeCount >= 5 or not Buff.SymbolsOfDeath:Exist() then
            if Spell.FocusedAzeriteBeam:Cast(Player) then
                return true
            end
        end
    end
    if Setting("BOTE Auto") and Player:EssenceMajor("BloodOfTheEnemy") and Spell.BloodOfTheEnemy:IsCastable() then
        if Spell.BloodOfTheEnemy:Cast(Player) then return true end
    end
end


local followingTarget = false
function Rogue.Rotation()
    Locals()
    -- if (not Player.Target or Player.Target.Dead) then
        -- for _, Unit in pairs(DMW.Units) do
        --     if Unit.Distance <= 5 and not Unit.Player and Unit.CreatureType ~= "Undead" and Unit.CreatureType ~= "Beast" then
        --         -- Spell.ShadowStrike:Cast(Unit)
        --         InteractUnit(Unit.Pointer)
        --         -- print(Unit.Name)
        --         -- return true
        --     end
        -- end
    -- end

    -- if Setting("AutoBeamAngle") and Player.Casting and (Player.Casting == 198013 or Player.Casting == 295258) then
    --     if BestRektCheck() then return end
    -- end
	if Player.Casting or Buff.Shroud:Exist() then return end

	if Setting("Dont open from Stealth") and Buff.Stealth:Exist() then return end
	if HUD.CCMode ~= 3 then
		if CrowdControlAround() then return end
	end
    if PrecombatShared() then return end
	if Player.Combat then
		if Target and Target:CCed() then
			StopAttack()
			return
		end
        if Setting("AutoTarget") then
            if Player:AutoTargetMelee(5, true) then
                return true
            end
        end
        if Target and Target.ValidEnemy and Target.Distance <= 5 and not IsCurrentSpell(Spell.Attack.SpellID) and not stealthedRogue and Target:Facing() and not stopAttacking then
            -- print("start attack")
            StartAttack()
		end
		if Setting("Use Trinkets on CD") then
			-- MemoryOfPastSins
			Item.Badge:Use()
			Item.MemoryOfPastSins:Use()
			Item.FlameOfBattle:Use()
			Item.SkulkersWing:Use()
			-- BladedancerArmorKit
			-- InscrutableQuantumDevice
			-- BloodSpatteredScale

		end
        if Setting("Follow Target") then
            if Target and Target.Distance > 5 and not followingTarget then
                local followX, followY, followZ = GetPositionBetweenObjects("target", "player", 3)
                MoveTo(followX, followY, followZ)
                followingTarget = true
                C_Timer.After(0.5, function() followingTarget = false end)
            end
            if followingTarget and Target and Target.Distance < 5 then
                StopMoving()
            end
        end
    end
    if Player:InterruptsMode() ~= 4 and Spell.Kick:CDUp()  then
        for _, Unit in pairs(EnemyMelee) do
            if Unit:Interrupt() then
                Spell.Kick:Cast(Unit)
                break
            end
        end
    end
    if HUD.Defensive == 1 then if Defensives() then return end end
    -- if HUD.CCMode == 1 then if CrowdControl() then return end end
    if Poisons() then return end
    if Player.SpecID == "Subtlety" then
        if (Target and Target.ValidEnemy and Target.Distance <= 5) or (DMW.Player.InstanceID ~= nil and DMW.Player.Combat) then
            LocalsSubtlety()
            if Player.Covenant == "Kyrian" then
                if (Buff.Kyrian2p:Stacks() == 2 and Player.ComboPoints == 2) or (Buff.Kyrian3p:Stacks() == 3 and Player.ComboPoints == 3) or (Buff.Kyrian4p:Stacks() == 4 and Player.ComboPoints == 4) then
                    -- print("kyrian".. Player.ComboPoints)
                    if SubtletyFinisher() then return true end
                end
            end
            -- # Executed every time the actor is available.
            -- # Restealth if possible (no vulnerable enemies in combat)
            -- actions=stealth
            -- # Used to determine whether cooldowns wait for SnD based on targets.
            -- actions+=/variable,name=snd_condition,value=buff.slice_and_dice.up|spell_targets.shuriken_storm>=6
            -- # Check CDs at first
            -- actions+=/call_action_list,name=cds
            if Player.CombatTime <= 4 and Target and Talent.Premeditation and not SkipRupture and sndCondition and Player.ComboPoints > 0 and Target.TTD > 8 and not Debuff.Rupture:Exist(Target) and not Spell.Vanish:LastCast() then
                if Spell.Rupture:Cast(Target) then return true end
                return true
            end
            if Talent.MarkedForDeath and Spell.MarkedForDeath:IsReady() and Player.ComboPointsDeficit > 0 then
                if MarkOfDeathAOE() then return true end
            end
            if Spell.Vanish:CDUp() and Target and HUD.VanishMode == 1 and not (Buff.ShadowDance:Exist() or Buff.Stealth:Exist()) and HUD.RuptureMode == 1 and not Debuff.Rupture:Exist(Target) and (not ShDthreshold or (not Talent.Nightstalker and Talent.DarkShadow)) and Player.ComboPointsDeficit > 1 --MA Legendary
            then
                if GCD > 0.1 then return true end
                if Spell.Vanish:Cast() then
                    StopAttack()
                    stopAttacking = true;
                    forceStealthed = true
                    C_Timer.After(1, function ()
                        stopAttacking = false
                        forceStealthed = false
                    end)
                end
                return true
            end
            if (CDs or HUD.BurstMode == 1) and GCD < 0.1 and Enemy10YC > 0 then
                if SubtletyCooldowns() then return true end
            end
            -- ssences,if=!stealthed.all&variable.snd_condition|essence.breath_of_the_dying.major&time>=2
            if CDs and sndCondition then
                if SubtletyEssences() then return true end
            end

            -- # Run fully switches to the Stealthed Rotation (by doing so, it forces pooling if nothing is available).
            -- actions+=/run_action_list,name=stealthed,if=stealthed.all
            if stealthedRogue or forceStealthed then
                if SubtletyStealthed() then return true end
            end
            -- # Apply Slice and Dice at 2+ CP during the first 10 seconds, after that 4+ CP if it expires within the next GCD or is not up
            -- actions+=/slice_and_dice,if=spell_targets.shuriken_storm<6&fight_remains>6&buff.slice_and_dice.remains<gcd.max&combo_points>=4-(time<10)*2
            if Enemy10YC < 6 and Buff.SliceAndDice:Remain() < 1.1 and Player.ComboPoints >= 4 - num(Player.CombatTime < 10)*2 then
                if Spell.SliceAndDice:Cast() then return true end
                return true
            end
            -- # Only change rotation if we have priority_rotation set and multiple targets up.
            -- actions+=/variable,name=use_priority_rotation,value=priority_rotation&spell_targets.shuriken_storm>=2
            usePriorityRotation = HUD.PriorityMode == 1 and Enemy10YC >= 2
            -- # Priority Rotation? Let's give a crap about energy for the stealth CDs (builder still respect it). Yup, it can be that simple.
            -- actions+=/call_action_list,name=stealth_cds,if=variable.use_priority_rotation
            if usePriorityRotation and EnemyMeleeCount >= 1 and GCD < 0.1 then
                if SubtletyStealthCDs() then return true end
            end
            -- # Used to define when to use stealth CDs or builders
            -- actions+=/variable,name=stealth_threshold,value=25+talent.vigor.enabled*20+talent.master_of_shadows.enabled*20+talent.shadow_focus.enabled*25+talent.alacrity.enabled*20+25*(spell_targets.shuriken_storm>=4)
            local StealthThreshold = 25 + 20 * num(Talent.Vigor) + 20 * num(Talent.MasterOfShadows) + 25 * num(Talent.ShadowFocus) + 20*num(Talent.Alacrity) + 20 * num(Talent.Vigor) + 25 * num(Enemy10YC >= 4)
            -- # Consider using a Stealth CD when reaching the energy threshold
            -- actions+=/call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold
            if Player.EnergyDeficit <= StealthThreshold and GCD < 0.1 then
                if SubtletyStealthCDs() then return true end
            end
            -- actions+=/call_action_list,name=finish,if=runeforge.deathly_shadows.equipped&dot.sepsis.ticking&dot.sepsis.remains<=2&combo_points>=2
            -- actions+=/call_action_list,name=finish,if=cooldown.symbols_of_death.remains<=2&combo_points>=2&runeforge.the_rotten.equipped
            -- actions+=/call_action_list,name=finish,if=combo_points=animacharged_cp
            -- # Finish at 4+ without DS, 5+ with DS (outside stealth)
            -- actions+=/call_action_list,name=finish,if=combo_points.deficit<=1|fight_remains<=1&combo_points>=3
            if Player.ComboPointsDeficit <= 1 then
                if SubtletyFinisher() then return true end
            end
            -- # With DS also finish at 4+ against exactly 4 targets (outside stealth)
            -- actions+=/call_action_list,name=finish,if=spell_targets.shuriken_storm=4&combo_points>=4
            if Enemy10YC == 4 and Player.ComboPoints >= 4 then
                if SubtletyFinisher() then return true end
            end
            -- # Use a builder when reaching the energy threshold
            -- actions+=/call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold
            if Player.EnergyDeficit <= StealthThreshold then
                if SubtletyBuilder() then return true end
            end
            -- # Lowest priority in all of the APL because it causes a GCD
            -- actions+=/arcane_torrent,if=energy.deficit>=15+energy.regen
            -- actions+=/arcane_pulse
            -- actions+=/lights_judgment
            -- actions+=/bag_of_tricks
            -- if Player.ComboPointsDeficit <= 1 or Player.ComboPoints>=4 and Enemy10Y == 4 then
            --     if SubtletyFinisher() then return true end
            --     return
            -- end
            -- if SubtletyBuilder() then return true end
        end
    elseif Player.SpecID == "Outlaw" then
        if PrecombatOutlaw() then return end
        if MythicStuff() then return end
        if OutlawExplosives() then return end
        -- if OutlawEssencesAPL() then return true end
        if CDs and EnemyMeleeCount > 0 then
            if Spell.AdrenalineRush:IsReady() and not Buff.AdrenalineRush:Exist() then
                RogueTrinkets()
				Spell.AdrenalineRush:Cast(Player)
				if Setting("Racials") and Spell.BloodFury:IsReady() then
					if Spell.BloodFury:Cast(Player) then return true end
				end
            end
        end
        if HUD.BFMode == 1 and Spell.BladeFlurry:IsReady() and not Buff.BladeFlurry:Exist() and EnemyMeleeCount >= 2 then
            if Spell.BladeFlurry:Cast(Player) then return true end
		end
		if Setting("PreRoll") and Target and Target.Attackable and Target.Distance <= 10 and Player.Moving then
			if Spell.RollTheBones:CDUp() and rtbReroll() then
                if Spell.RollTheBones:Cast(Player) then return true end
            end
		end
        if (Target and Target.ValidEnemy and Target.Distance <= 5) or (DMW.Player.Instance ~= "none" and DMW.Player.Combat) then
            Tricks()
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
            if Spell.RollTheBones:CDUp() and rtbReroll() then
                if Spell.RollTheBones:Cast(Player) then return true end
                return true
            end
            if Setting("BladeRush") and Talent.BladeRush and Target and Target.Distance <= 5 and TTM() > 3 then
                if Spell.BladeRush:Cast(Target) then return true end
			end
			if Player.Covenant == "Kyrian" and Spell.EchoingReprimand:IsCastable(5) and CDs and Player.ComboPointsDeficit >= 2 then
				for _,Unit in ipairs(EnemyMelee) do
					if Spell.EchoingReprimand:Cast(Unit) then return true end
				end
			end
			if Player.Covenant == "Kyrian" then
                if (Buff.Kyrian2p:Stacks() == 2 and Player.ComboPoints == 2) or (Buff.Kyrian3p:Stacks() == 3 and Player.ComboPoints == 3) or (Buff.Kyrian4p:Stacks() == 4 and Player.ComboPoints == 4) then
                    -- print("kyrian".. Player.ComboPoints)
                    if OutlawFinishers(true) then return true end
                end
            end
            if OutlawShouldFinish() then
                if OutlawFinishers() then return end
                return
            end
            if OutlawBuilders() then return end
        end
    elseif Player.SpecID == "Assassination" then
        if MythicStuff() then return end
        if (Target and Target.ValidEnemy and Target.Distance <= 5) or (DMW.Player.InstanceID ~= nil and DMW.Player.Combat) then
            Tricks()
            if stealthedRogue then
                if AssassinationStealthedAPL() then return true end
            end
            if AssassinationExplosives() then return true end
            if AssassinationCooldownsAPL() or AssassinationDotAPL() or AssassinationDirectAPL() then return true end
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
