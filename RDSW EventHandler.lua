--Author Manaleaf - Sargeras
--Event Handeling for RDSW

local startupFrame = CreateFrame("FRAME")
startupFrame:RegisterEvent("ADDON_LOADED")
startupFrame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 == "RDSW" then
		--Sets Encounter data to be printed to file.
		--Para mode: sets print out to stat either "WIPE" if mode - 0 or "KILL" if mode = 1
		function RDSW.saveSession(eID, eName, difficulty, groupSize, duration, mode) 
			RDSW.historyEntryNum = RDSW.historyEntryNum + 1
			local outcome
			if mode == 0 then 
				outcome = "WIPE"
			elseif mode == 1 then 
				outcome = "KILL"
			elseif mode == 2 then --Dungeon (non-boss encounter) 
				outcome = nil
				eID = RDSW.dungeonInfo["eID"]
				eName = RDSW.dungeonInfo["eName"]
				difficulty = RDSW.dungeonInfo["difficulty"]
				groupSize = 5
			end
			
			local talentCode = ""
			for i = 1, GetMaxTalentTier() do
				local k = 1
				while true do
					local _, name, _, selected, _ = GetTalentInfo(i,k,1)
					if not name then
						k = 0
						break
					end
					k = k + 1
					if selected then
						talentCode = talentCode .. "1"
					else
						talentCode = talentCode .. "0"
					end
				end
			end
			
			tinsert(RDSW.history, RDSW.historyEntryNum,
			{
			encounter = eName,
			encounterid = eID,
			date = date("*t"),
			playername = UnitName("player"),
			dungeonmode = difficulty,
			groupSize = groupSize,
			outcome = outcome,
			int = RDSW.CUR_SP,
			mst = RDSW.CUR_MST,
			hst = RDSW.CUR_HST_HPM,
			crt = RDSW.CUR_CRT,
			vrs = RDSW.CUR_VRS,
			mstperc = RDSW.mstPerc,
			hstperc = RDSW.hstPerc,
			crtperc = RDSW.crtPerc,
			vrsperc = RDSW.vrsPerc,
			talents = talentCode,
			duration = duration
			})
			
		  
		end	
		
		--Checks player location
		--Returns 	1 for Raid
		--			2 for Mythic Dungeon
		--			3 for Non-mythic Dungeon 
		--			0 for non-instance
		local function instanceCheck()
			local location, instanceType, difficulty = GetInstanceInfo()
			if location == "Eastern Kingdoms" 
			or location == "Kalimdor" 
			or location == "Northrend"
			or location == "Outland"
			or location == "Draenor"
			or location == "Broken Isles" then
				return 0
			elseif instanceType == "party" then
				if difficulty == 23 then
					if RDSW.enabledContent["mythicdungeon"] then
						return 2
					end
				else
					if RDSW.enabledContent["dungeonnonmythic"] then
						return 3
					end
				end
			elseif instanceType == "raid" then
				if RDSW.enabledContent["raid"] then
					return 1
				end
			end
		end		
		
		function RDSW.eventHandler(self, event, ...)
			if event == "COMBAT_LOG_EVENT_UNFILTERED" and 
			RDSW.session ~= "none" then
				RDSW.statCalc(...)
				
			elseif event == "PLAYER_REGEN_DISABLED" then
				--Settings: Hide while in combat
				local displayShown = RDSW_Display_Frame:IsVisible()
				if RDSW.enabledContent["incombat"].enabled and not displayShown then
					RDSW_Display_Frame:Show()
				elseif not RDSW.enabledContent["incombat"].enabled and displayShown then
					RDSW_Display_Frame:Hide()
				end
				RDSW.inCombat = true
				RDSW.updateDisplay()
				
			elseif event == "PLAYER_REGEN_ENABLED" then
				--Settings: Hide while out of combat
				local displayShown = RDSW_Display_Frame:IsVisible()
				if RDSW.enabledContent["outofcombat"].enabled and not displayShown then
					RDSW_Display_Frame:Show()
				elseif not RDSW.enabledContent["outofcombat"].enabled and displayShown then
					RDSW_Display_Frame:Hide()
				end
				RDSW.inCombat = false
				RDSW.updateDisplay()
				
			elseif event == "ARTIFACT_UPDATE" then
				RDSW.updateArtifact()
				
			elseif event == "PLAYER_ENTERING_WORLD" then
				local instance = instanceCheck()
				--Player in Mythic Dungeon
				if instance == 2 and RDSW.contentEnabled[mythicdungeon].enabled then
					local name, _, Difficulty, _, _, _, _, eID = GetInstanceInfo()
					RDSW.dungeonInfo["eID"] = eID
					RDSW.dungeonInfo["eName"] = name
					RDSW.dungeonInfo["difficulty"] = Difficulty
					RDSW.encStartTimer = GetTime()
					RDSW.session = "mythicdungeon"
					RDSW.clearStats()
				--Player in Non-Mythic Dungeon
				elseif instance == 3 and RDSW.contentEnabled[dungeonnonmythic].enabled then
					local name, _, Difficulty, _, _, _, _, eID = GetInstanceInfo()
					RDSW.dungeonInfo["eID"] = eID
					RDSW.dungeonInfo["eName"] = name
					RDSW.dungeonInfo["difficulty"] = Difficulty
					RDSW.encStartTimer = GetTime()
					RDSW.session = "dungeonnonmythic"
					RDSW.clearStats()
				--Player in Open World	
				elseif 	instance == 0 and 
				(RDSW.session == "mythicdungeon" 
				or RDSW.session == "dungeonnonmythic") 
				and (RDSW.encStartTimer - GetTime) > 300 then --Player must be in dungeon for more than 5 minutes to count as a session
					local encTime = tostring(floor(string.format("02.f", (GetTime() - RDSW.encStartTimer) / 60)))
									.. ":" .. tostring(floor(string.format("02.f",(GetTime() - RDSW.encStartTimer) % 60)))
					RDSW.saveSession(RDSW.dungeonInfo["eID"], RDSW.dungeonInfo["eName"], RDSW.dungeonInfo["difficulty"], 5, encTime, 2) 
					RDSW.session = "none"
					RDSW.dungeonInfo = {}
				end		
				RDSW.updateStats()
				RDSW.updateDisplay()
				
			elseif event == "ENCOUNTER_START" and RDSW.session == "raid" then
				--Settings: Hide during Boss Encounter
				local displayShown = RDSW_Display_Frame:IsVisible()
				if RDSW.enabledContent["bossencounter"].enabled and not displayShown then
					RDSW_Display_Frame:Show()
				elseif not RDSW.enabledContent["bossencounter"].enabled and displayShown then
					RDSW_Display_Frame:Hide()
				end
				if instanceCheck() == 1 then
					RDSW.session = "raid"
				end
				RDSW.clearStats()
				RDSW.updateStats()
				RDSW.updateDisplay()
				
			elseif event == "ENCOUNTER_END" and RDSW.session == "raid" then 
				if RDSW.session == "raid" then
					local eID, eName, difficulty, raidSize, _ = ...
					RDSW.saveSession(eID, eName, difficulty, raidSize, encTime, 2) 
					RDSW.session = "none"
				end
				RDSW.updateStats()
				RDSW.updateDisplay()
			elseif event == "UNIT_STATS" or event == "COMBAT_RATING_UPDATE" then      
				RDSW.updateStats()
				
			elseif event == "PLAYER_LOGOUT" then
				display_XPos, display_YPos = select(3, f:GetPoint())
			end
			RDSW.updateStats()
		end
		
		local f = CreateFrame("FRAME", "RDSW_EVENT_Frame", UIParent)
		--RegisterEvents to displayframe
		f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		f:RegisterEvent("ENCOUNTER_START")
		f:RegisterEvent("ENCOUNTER_END")
		f:RegisterEvent("COMBAT_RATING_UPDATE")
		f:RegisterEvent("UNIT_STATS")
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f:RegisterEvent("ARTIFACT_UPDATE")
		f:RegisterEvent("PLAYER_LOGOUT")
		f:RegisterEvent("PLAYER_REGEN_DISABLED")
		f:RegisterEvent("PLAYER_REGEN_ENABLED")
		f:RegisterEvent("PLAYER_TALENT_UPDATE")
		f:SetScript("OnEvent", RDSW.eventHandler);
		
		--Slash Command Declaration
		SLASH_RDSW1 = "/rdsw"
		SlashCmdList["RDSW"] = function(msg, editbox)
			if strlower(msg) == "lock" then
				if RDSW.Option_Lock then
					RDSW.Option_Lock = false
					RDSW_Display_BG:SetAlpha(0)
					RDSW_Display_Frame:RegisterForDrag()
					print("RDSW: Display Locked")
				else
					RDSW.Option_Lock = true
					RDSW_Display_BG:SetAlpha(1)
					RDSW_Display_Frame:RegisterForDrag("LeftButton")
					print("RDSW: Display Unlocked")
				end
			elseif strlower(msg) == "reset" then
				RDSW.clearAllStats()
				RDSW.updateDisplay()
				print("RDSW: Stats have been reset")
			elseif strlower(msg) == "toggle" then
				if RDSW.display_Toggle then
					RDSW.display_Toggle = false
					RDSW_Display_Frame:Hide()
					print("RDSW: Hiding Display")
				else
					RDSW.display_Toggle = true
					RDSW_Display_Frame:Show()
					print("RDSW: Showing Display")
				end
			elseif strlower(msg) == "help" then
				print("RDSW Commands:"
						.. "\n     \'/rdsw\'         -Open config" 
						.. "\n     \'/rdsw lock\'    -Locks the display" 
						.. "\n     \'/rdsw toggle\'  -Toggle display" 
						.. "\n     \'/rdsw reset\'   -Reset \'Total\' Stat Weights" )
			else
				if RDSW.config_Toggle then
					RDSW.config_Toggle = false
					RDSW_Config_Frame:Hide()
				else
					RDSW.config_Toggle = true
					RDSW_Config_Frame:Show()
				end
			end
		end
		
	end
end)