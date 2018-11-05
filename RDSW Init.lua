--Author Manaleaf - Sargeras
--Initializing Vars for RDSW

local startupFrame = CreateFrame("FRAME")
startupFrame:RegisterEvent("ADDON_LOADED")
startupFrame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 == "RDSW" then
		--Core Addon Saved Variable
		RDSW = RDSW or {}
		
		--Initial Values
		RDSW.version = 1.0
		RDSW.history = RDSW.history or {}
		RDSW.session = RDSW.session or "none"
		RDSW.encStartTimer = GetTime()
		RDSW.talentInfo = RDSW.talentInfo or {}
		
		--Name and Textures for each talent
		for i = 1, GetMaxTalentTier() do
			local k = 1
			while true do
				local _, name, texture, _ = GetTalentInfo(i,k,1)
				if not name then
					k = 0
					break
				end
				tinsert(RDSW.talentInfo, {[name] = name, [texture] = texture})
				k = k + 1
			end
		end
					
		
		--GUI Initial Values
		RDSW.display_Toggle = RDSW.display_Toggle or true
		RDSW.config_Toggle = RDSW.config_Toggle or false	
		RDSW.option_Lock = RDSW.option_Lock or false
		RDSW.display_XPos = RDSW.display_XPos or 0
		RDSW.display_YPos = RDSW.display_YPos or 0
		RDSW.config_XPos = RDSW.config_XPos or 0
		RDSW.config_YPos = RDSW.config_YPos or 0
		RDSW.calcType = RDSW.CalcType or 1
		RDSW.vixarFont = "interface\\addons\\RDSW\\Font\\vixar.TTF"
		RDSW.displayFontSize = RDSW.displayFontSize or 12
		RDSW.displayOrientation = RDSW.displayOrientation or  "Horizontal"
		RDSW.displayPrecision = RDSW.displayPrecision or 2
		RDSW.activeEncounter = false
		RDSW.inCombat = false
		RDSW.enabledContent = RDSW.enabledContent or 
			{raid = {id = "Raid", name = "Raid", enabled = true},
			mythicdungeon = {id = "Mythic_Dungeon", name = "Mythic Dungeons", enabled = true},
			dungeonnonmythic = {id = "Dungeon_Nonmythic", name = "Dungeon (non-mythic)", enabled = false},
			incombat = {id = "In_Combat", name = "In Combat", enabled = true},
			outofcombat = {id = "Out_Of_Combat", name = "Out of Combat", enabled = true},
			bossencounter = {id = "Boss_Encounter", name = "Boss Encounter", enabled = true}}		
		RDSW.historyPage = RDSW.historyPage or 1
		RDSW.historyEntryNum = #RDSW.history or 1
		
		--Initializing output values
		RDSW.CUR_SP = 0
		RDSW.CUR_MST = 0
		RDSW.CUR_HST_HPM = 0
		RDSW.CUR_HST_HPCT = 0
		RDSW.CUR_CRT = 0
		RDSW.CUR_VRS = 0
		RDSW.CUR_SP_HEAL = 0
		RDSW.CUR_MST_HEAL = 0
		RDSW.CUR_HST_HPM_HEAL = 0
		RDSW.CUR_HST_HPCT_HEAL = 0
		RDSW.CUR_CRT_HEAL = 0
		RDSW.CUR_VRS_HEAL = 0
		RDSW.TTL_SP = 0
		RDSW.TTL_MST = 0
		RDSW.TTL_HST_HPM = 0
		RDSW.TTL_HST_HPCT = 0
		RDSW.TTL_CRT = 0
		RDSW.TTL_VRS = 0
		RDSW.TTL_SP_HEAL = 0
		RDSW.TTL_MST_HEAL = 0
		RDSW.TTL_HST_HPM_HEAL = 0
		RDSW.TTL_HST_HPCT_HEAL = 0
		RDSW.TTL_CRT_HEAL = 0
		RDSW.TTL_VRS_HEAL = 0

		--Set Rating Per 1% value here.
		RDSW.MSTRATINGCONV = 66666.66666
		RDSW.HSTRATINGCONV = 37500
		RDSW.CRTRATINGCONV = 40000
		RDSW.VRSRATINGCONV = 47500

		--Set Regrowth Passive Bonus Crit here.
		RDSW.REGROWTHBASECRT = 0.4
		RDSW.LIVINGSEEDBASEPERCENT = 0.25

		--List of Hots for hCount()
		RDSW.hotList = 
		{774,       --Rejuvenation 
			155777, --Germination
			33763,  --Lifebloom
			8936,   --Regrowth
			48438,  --Wild Growth
			207386, --Spring Blossoms
			200389, --Cultivation
		102352}     --Cenarion Ward

		--Setting spell names for all client versions.
		RDSW.spells = {}
		RDSW.spells.rejuvenation   = select(1, GetSpellInfo(774))
		RDSW.spells.germination    = select(1, GetSpellInfo(155777))
		RDSW.spells.lifebloom      = select(1, GetSpellInfo(33763))
		RDSW.spells.regrowth       = select(1, GetSpellInfo(8936))
		RDSW.spells.wildgrowth     = select(1, GetSpellInfo(48438))
		RDSW.spells.springblossoms = select(1, GetSpellInfo(207386))
		RDSW.spells.cultivation    = select(1, GetSpellInfo(200389))
		RDSW.spells.cenarionward   = select(1, GetSpellInfo(102352))
		RDSW.spells.efflorescence  = select(1, GetSpellInfo(145205))
		RDSW.spells.livingseed     = select(1, GetSpellInfo(48500))
		RDSW.spells.swiftmend      = select(1, GetSpellInfo(18562))
		RDSW.spells.healingtouch   = select(1, GetSpellInfo(5185))
		RDSW.spells.tranquility    = select(1, GetSpellInfo(740))
		RDSW.spells.renewal        = select(1, GetSpellInfo(108238))

		--Percent Values 
		RDSW.mstPerc = GetMasteryEffect() / 100--GetCombatRatingBonus(26) / 100 * hCount  
		RDSW.hstPerc = UnitSpellHaste("player") / 100
		RDSW.crtPerc = GetCritChance() / 100
		RDSW.vrsPerc = (GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100
		--SpellPower
		RDSW.spellPower = GetSpellBonusDamage(4)

		--Set Race Based Characteristics
		if select(1, UnitRace("player")) == "Tauren" then 
			RDSW.taurenRacial = 0.04
		else RDSW.taurenRacial = 0
		end

		RDSW.critBonusOutput = RDSW.critBonusOutput or 0
		if IsEquippedItem("Drape of Shame") then RDSW.critBonusOutput = 0.1 end
	end
end)