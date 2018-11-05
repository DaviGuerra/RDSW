--Author Manaleaf - Sargeras
--Core Calcs for Stat Weights

local startupFrame = CreateFrame("FRAME")
startupFrame:RegisterEvent("ADDON_LOADED")
startupFrame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 == "RDSW" then
	--Returns the current number of Player casted hots on the unit
		function RDSW.hotCounter(name)
			local destUnit
			local grpCount = GetNumGroupMembers()
			if UnitInRaid("player") then
				for i = 1, grpCount  do
					local name2,realm2 = UnitName("raid"..i)
					if realm2 then name2 = name2 .. "-" .. realm2 end
					
					if name2 == name then
						destUnit = "raid" .. i
						break
					end
				end   
			elseif UnitInParty("player") then
				for i = 1, grpCount  do
					local name2,realm2 = UnitName("party"..i)
					if realm2 then name2 = name2 .. "-" .. realm2 end
					
					if name2 == name then
						destUnit = "party" .. i
						break
					end
				end 
			elseif UnitName("player") == name then
				
				destUnit = "player" 
			end
			if not destUnit then
				return -1 --Failure Flag
			end
			local hCount = 0 
			for k,v in ipairs(RDSW.hotList) do
				local spellName = GetSpellInfo(v)
				if UnitBuff(destUnit, spellName, nil, "PLAYER") then hCount = hCount + 1 end 
			end
			return hCount
		end

		--Inserts a row into a chain of tables.
		function RDSW.insert(i, t1, t2, t3)
			tinsert(RDSW.expire, i, t1)
			tinsert(RDSW.guid, i, t2)
			tinsert(RDSW.reduce, i, t3)
		end

		--Removes a row into a chain of tables.
		function RDSW.removet(i, t1, t2, t3)
			table.remove(t1, i)
			table.remove(t2, i)
			table.remove(t3, i)
		end

		--Function finds the lowest non-zero, non-negative value
		--Still returns 0 if all arguements are 0.
		function RDSW.maxButNotZero(n1, n2, n3, n4, n5)
			local max = 1
			if n1 ~= nil and n1 > max then max = n1 end
			if n2 ~= nil and n2 > max then max = n2 end
			if n3 ~= nil and n3 > max then max = n3 end
			if n4 ~= nil and n4 > max then max = n4 end
			if n5 ~= nil and n5 > max then max = n5 end
			return max
		end	
			
		--Allocates stat values
		function RDSW.allocate(spHeal, mstHeal, hstHeal, crtHeal, vrsHeal)
			
			--Total Healing Score Allocation
			RDSW.TTL_SP_HEAL = RDSW.TTL_SP_HEAL + spHeal
			RDSW.TTL_MST_HEAL = RDSW.TTL_MST_HEAL + mstHeal
			RDSW.TTL_HST_HPM_HPM_HEAL = RDSW.TTL_HST_HPM_HPM_HEAL + hstHeal
			RDSW.TTL_CRT_HEAL = RDSW.TTL_CRT_HEAL + crtHeal
			RDSW.TTL_VRS_HEAL = RDSW.TTL_VRS_HEAL + vrsHeal
			
			--Current Encounter Healing Score Allocation
			RDSW.CUR_SP_HEAL = RDSW.CUR_SP_HEAL + spHeal
			RDSW.CUR_MST_HEAL = RDSW.CUR_MST_HEAL + mstHeal
			RDSW.CUR_HST_HPM_HEAL = RDSW.CUR_HST_HPM_HEAL + hstHeal
			RDSW.CUR_CRT_HEAL = RDSW.CUR_CRT_HEAL + crtHeal
			RDSW.CUR_VRS_HEAL = RDSW.CUR_VRS_HEAL + vrsHeal
			
			--Stat Value Score Allocation
			
			local maxCurHeal = maxButNotZero(RDSW.CUR_SP_HEAL, RDSW.CUR_MST_HEAL, RDSW.CUR_HST_HPM_HEAL, RDSW.CUR_CRT_HEAL, RDSW.CUR_VRS_HEAL) 
			local maxTtlHeal = maxButNotZero(RDSW.TTL_SP_HEAL, RDSW.TTL_MST_HEAL, RDSW.TTL_HST_HPM_HPM_HEAL, RDSW.TTL_CRT_HEAL, RDSW.TTL_VRS_HEAL) 
			
			RDSW.CUR_SP = RDSW.CUR_SP_HEAL / maxCurHeal
			RDSW.CUR_MST = RDSW.CUR_MST_HEAL / maxCurHeal
			RDSW.CUR_HST_HPM = RDSW.CUR_HST_HPM_HEAL / maxCurHeal
			RDSW.CUR_CRT = RDSW.CUR_CRT_HEAL / maxCurHeal
			RDSW.CUR_VRS = RDSW.CUR_VRS_HEAL / maxCurHeal    
			
			RDSW.TTL_SP =  RDSW.TTL_SP_HEAL / maxTtlHeal
			RDSW.TTL_MST = RDSW.TTL_MST_HEAL / maxTtlHeal
			RDSW.TTL_HST_HPM = RDSW.TTL_HST_HPM_HPM_HEAL / maxTtlHeal
			RDSW.TTL_CRT = RDSW.TTL_CRT_HEAL / maxTtlHeal
			RDSW.TTL_VRS = RDSW.TTL_VRS_HEAL / maxTtlHeal   
			
			--[[
			print("------------------")
			print(RDSW.CUR_SP)
			print(RDSW.CUR_MST)
			print(RDSW.CUR_HST_HPM)
			print(RDSW.CUR_CRT)
			print(RDSW.CUR_VRS)
			print("------------------")
			print(RDSW.TTL_SP)
			print(RDSW.CUR_MST)
			print(RDSW.CUR_HST_HPM)
			print(RDSW.CUR_CRT)
			print(RDSW.CUR_VRS)
			]]
			
		end	
			
		--Calculates and Sets stat weight values
		function RDSW.decompHeal(heal, overHeal, name, crtFlag, hstFlag, sName, sklFlag, tGuid)
			
			--Mastery Percentage
			local hCount = hotCounter(name)
			if hCount == -1 then return end
			local mstPerc = RDSW.mstPerc * hCount
			
			--Haste Percentage 
			local hstPerc --Only for Hots
			if hstFlag then
				hstPerc = RDSW.hstPerc
			else 
				hstPerc = 0
			end
			
			--Get Base Heal
			if crtFlag == true then
				heal = heal / (2 + RDSW.taurenRacial + RDSW.critBonusOutput)
			end
			
			--Crit Percentage (Bonus)
			local crtPerc 
			if sklFlag == 1 then 
				if overHeal ~= 0 then return end
				crtPerc = RDSW.crtPerc +  RDSW.REGROWTHBASECRT * (1 + RDSW.taurenRacial + RDSW.critBonusOutput)
			else
				crtPerc = RDSW.crtPerc * (1 + RDSW.taurenRacial + RDSW.critBonusOutput)
			end
			
			
			--Spell Coeff.
			local sce = heal / ( RDSW.spellPower * (1 + mstPerc) * (1 + hstPerc) * (1 + RDSW.vrsPerc) * (1 + crtPerc) )
			
			local spellPower  = sce * RDSW.spellPower
			--Haste Calc (Only for Hots)
			if hstFlag then
				hstHeal = spellPower * (1 + mstPerc) * (1 + RDSW.vrsPerc) * (1 + crtPerc) / RDSW.HSTRATINGCONV 
			else 
				hstHeal = 0
			end
			
			--Mastery Calc
			mstHeal = spellPower * (1 + hstPerc) * (1 + RDSW.vrsPerc) * (1 + crtPerc) * hCount / RDSW.MSTRATINGCONV
			
			--Crit Calc
			crtHeal = spellPower * (1 + mstPerc) * (1 + hstPerc) * (1 + RDSW.vrsPerc) * (1 + RDSW.taurenRacial + RDSW.critBonusOutput) / RDSW.CRTRATINGCONV
			
			--Versatility calc
			vrsHeal = spellPower * (1 + mstPerc) * (1 + hstPerc) * (1 + crtPerc) / RDSW.VRSRATINGCONV
			
			--Spell Power Calc
			--1.05 = Primary Stat Bonus from Armor
			spHeal = sce * (1 + mstPerc) * (1 + hstPerc) * (1 + RDSW.vrsPerc) * (1 + crtPerc) * 1.05
			
			--[[
			print("---------------")
			print("spHeal:", spHeal)
			print("mstHeal:", mstHeal)
			print("vrsHeal:", vrsHeal)
			print("hstHeal:", hstHeal)
			print("crtHeal:", crtHeal)
			print("---------------")
			]]
			
			allocate(spHeal, mstHeal, hstHeal, crtHeal, vrsHeal)
		end
			
		
		--Clears the current healing and stat values	
		function RDSW.clearStats()
			RDSW.CUR_SP = 0
			RDSW.CUR_MST = 0
			RDSW.CUR_HST_HPM = 0
			RDSW.CUR_CRT = 0
			RDSW.CUR_VRS = 0
			RDSW.CUR_SP_HEAL = 0
			RDSW.CUR_MST_HEAL = 0
			RDSW.CUR_MST_HEAL = 0
			RDSW.CUR_HST_HPM_HEAL = 0
			RDSW.CUR_CRT_HEAL = 0
			RDSW.CUR_VRS_HEAL = 0
		end
		
		function RDSW.clearAllStats()
			RDSW.CUR_SP = 0
			RDSW.CUR_MST = 0
			RDSW.CUR_HST_HPM = 0
			RDSW.CUR_CRT = 0
			RDSW.CUR_VRS = 0
			RDSW.CUR_SP_HEAL = 0
			RDSW.CUR_MST_HEAL = 0
			RDSW.CUR_MST_HEAL = 0
			RDSW.CUR_HST_HPM_HEAL = 0
			RDSW.CUR_CRT_HEAL = 0
			RDSW.CUR_VRS_HEAL = 0
			
			RDSW.TTL_SP = 0
			RDSW.TTL_MST = 0
			RDSW.TTL_HST_HPM = 0
			RDSW.TTL_CRT = 0
			RDSW.TTL_VRS = 0
			RDSW.TTL_SP_HEAL = 0
			RDSW.TTL_MST_HEAL = 0
			RDSW.TTL_MST_HEAL = 0
			RDSW.TTL_HST_HPM_HEAL = 0
			RDSW.TTL_CRT_HEAL = 0
			RDSW.TTL_VRS_HEAL = 0
		end
			
		function RDSW.updateArtifact()
		if IsEquippedItem(128306) == true and RDSW.apUpdated == false then
				SocketInventoryItem(16)
				seedsPoints, _ = select(3,C_ArtifactUI.GetPowerInfo(131))
				RDSW.apUpdated = true
				RDSW.REGROWTHBASECRT = .4 + .08 * seedsPoints
			end
		end
			
		--Updates Character Stats
		function RDSW.updateStats()
			RDSW.mstPerc = GetMasteryEffect() / 100--GetCombatRatingBonus(26) / 100 * hCount  
			RDSW.hstPerc = UnitSpellHaste("player") / 100
			RDSW.crtPerc = GetCritChance() / 100
			RDSW.vrsPerc = (GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100
			RDSW.spellPower = GetSpellBonusDamage(4)
			RDSW.updateArtifact()
			
			if IsEquippedItem("Drape of Shame") then 
				RDSW.critBonusOutput = 0.1 
			end
		end
		
		--Core Calcs for RDSW display
		function RDSW.statCalc(self, event, ...)
			--If overheal is present and Living Seed table does not need to be updated. Cancel operation.
			if select(16,...) ~= 0 and (sName ~= RDSW.spells.livingseed or sName ~= RDSW.spells.regrowth) then
				RDSW.updateDisplay()
				return
			end
			
			local heal, overHeal, crtFlag, effHeal, sName, hstFlag, sklFlag, tGuid
			sklFlag = 0
			local sType = select(2, ...)
			if select(4, ...) == UnitGUID("player") then 
				sName = select(13,...)
				
				-------------------------DEREGULATE THIS AREA
				--Hot Spells (haste effected)
				if sType == "SPELL_PERIODIC_HEAL" then
					if sName == RDSW.spells.rejuvenation
					or sName == RDSW.spells.germination
					or sName == RDSW.spells.lifebloom
					or sName == RDSW.spells.regrowth
					or sName == RDSW.spells.wildgrowth
					or sName == RDSW.spells.springblossoms
					or sName == RDSW.spells.cultivation
					or sName == RDSW.spells.cenarionward
					then hstFlag = true end
					
					--Direct Healing Spells (Mostly not Haste Effected)   
				elseif sType == "SPELL_HEAL" then 
					sName,_= select(13,...)
					if sName == RDSW.spells.efflorescence then hstFlag = true
						
					elseif sName == RDSW.spells.regrowth then 
						sklFlag = 1
						hstFlag = false
						
					elseif sName == RDSW.spells.livingseed then
						sklFlag = 2
						hstFlag = false
						
					elseif sName == RDSW.spells.swiftmend
					or sName == RDSW.spells.healingtouch
					or sName == RDSW.spells.lifebloom
					or sName == RDSW.spells.tranquility
					then hstFlag = false end
				end
				
				if hstFlag ~= nil then    --If hstFlag == nil, healing was not done by a spell in the above listing. ie: Ysera's gift is uneffected by secondaries
					tGuid, name,_= select(8,...)
					heal,overHeal,_,crtFlag,_ = select(15,...)
					decompHeal(heal, overHeal, name, crtFlag, hstFlag, sName, sklFlag, tGuid)
				end         
			end
			RDSW.updateDisplay()
		end
	end
end)