--Author Manaleaf - Sargeras
--GUI for RDSW

local startupFrame = CreateFrame("FRAME")
startupFrame:RegisterEvent("ADDON_LOADED")
startupFrame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 == "RDSW" then 
		--GUI specific variables
		RDSW.activeWindowCode = RDSW.activeWindowCode or 1
		local buttonNormalTexture = "Interface\\Addons\\RDSW\\Media\\Images\\Button Unpressed Leaf Texture"
		local buttonHighlightTexture = "Interface\\Addons\\RDSW\\Media\\Images\\Button Pressed Glow"
		local buttonPressedTexture = "Interface\\Addons\\RDSW\\Media\\Images\\Button Pressed Glow"
		local directoryItems = {"Settings", "History", "FAQ", "Utility"}
		local raidcontentTypeItems = {"raid", "mythicdungeon", "dungeonnonmythic"}
		local hideLocationItems = {"incombat", "bossencounter", "outofcombat"}
		local historyButtonNum = 10
		local activeWindowList = {"RDSW_Settings_Window_Frame", "RDSW_History_Window_Frame",
			"RDSW_FAQ_Window_Frame", "RDSW_Utility_Window_Frame"}
		local historyCap = 1000
		
		
		--Updates Display Frame  Text 
		function RDSW.updateDisplay()
			local displayShown = RDSW_Display_Frame:IsVisible()
			if RDSW.inCombat then
				if RDSW.enabledContent["incombat"].enabled and not displayShown and RDSW.inCombat then
					RDSW_Display_Frame:Show()
				elseif not RDSW.enabledContent["incombat"].enabled and displayShown and RDSW.inCombat then
					RDSW_Display_Frame:Hide()
				end
			else --if not in combat
				if RDSW.enabledContent["outofcombat"].enabled and not displayShown and not RDSW.inCombat then
					RDSW_Display_Frame:Show()
				elseif not RDSW.enabledContent["outofcombat"].enabled and displayShown and not RDSW.inCombat then
					RDSW_Display_Frame:Hide()
				end
			end		
			if RDSW.activeEncounter then
				if RDSW.enabledContent["bossencounter"].enabled and not displayShown and RDSW.activeEncounter then
					RDSW_Display_Frame:Show()
				elseif not RDSW.enabledContent["bossencounter"].enabled and displayShown and RDSW.activeEncounter then
					RDSW_Display_Frame:Hide()
				end
			end
			
			if displayShown then
				local strFormat = 	"\n%15s: %-5." .. tostring(RDSW.displayPrecision) .. "f"
				local outString, hstCurText1, hstCurText2, hstTTLText1, hstTTLText2
				if RDSW.calcType == 1 then
					hstCurText1 = string.format(strFormat, "Haste[HPM]", RDSW.CUR_HST_HPM)
					hstCurText2 = string.format(strFormat, "Haste[HPCT]",RDSW.CUR_HST_HPCT)
					hstTTLText1 = string.format(strFormat, "Haste[HPM]",RDSW.TTL_HST_HPM)
					hstTTLText2 = string.format(strFormat, "Haste[HPCT]",RDSW.TTL_HST_HPCT)
				elseif RDSW.calcType == 2 then
					hstCurText1 = string.format(strFormat, "Haste[HPM]", RDSW.CUR_HST_HPM)
					hstCurText2 = ""
					hstTTLText1 = string.format(strFormat, "Haste[HPM]",RDSW.TTL_HST_HPM)
					hstTTLText2 = ""
				elseif RDSW.calcType == 3 then
					hstCurText1 = format(strFormat, "Haste[HPCT]",RDSW.CUR_HST_HPCT)
					hstCurText2 = ""
					hstTTLText1 = string.format(strFormat, "Haste[HPCT]",RDSW.TTL_HST_HPCT)
					hstTTLText2 = ""
				end	
				outString1 = string.format("%-28s"
							.. strFormat
							.. strFormat
							.. "%s%s"
							.. strFormat
							.. strFormat,
							"Current",
							"Intellect", RDSW.CUR_SP,
							"Crit", RDSW.CUR_CRT, 
							hstCurText1, hstCurText2, 
							"Mastery", RDSW.CUR_MST,
							"Versatility", RDSW.CUR_VRS
							)
				outString2 = string.format("%-30s"
							.. strFormat
							.. strFormat
							.. "%s%s"
							.. strFormat
							.. strFormat,
							"Total",
							"Intellect", RDSW.TTL_SP,
							"Crit", RDSW.TTL_CRT,
							hstTTLText1, hstTTLText2, 
							"Mastery", RDSW.TTL_MST,
							"Versatility", RDSW.TTL_VRS
							)
				RDSW_Display_Text1:SetText(outString1)
				RDSW_Display_Text2:SetText(outString2)
			end
		end
		
		--Implements Directory Window Button functions on click
		local function directoryWindow(mode, frameNum)
			RDSW.activeWindowCode = mode
			local frame
			for i = 1, frameNum do
				frame = _G["RDSW_Directory_Button" .. i]
				if i == mode then
					frame:SetNormalTexture(buttonPressedTexture)
				else
					frame:SetNormalTexture(buttonNormalTexture)
				end
			end
			
			for i,v in ipairs(activeWindowList) do
				if RDSW.activeWindowCode == i then
					_G[v]:Show()
				else
					_G[v]:Hide()
				end
			end
		end	

		--Implements History Window Button functions on click
		local function historyWindow(mode, frameNum)
			local frame
			for i = 1, frameNum do
				frame = _G["RDSW_History_Button" .. i]
				if i == mode then
					frame:SetNormalTexture(buttonPressedTexture)
				else
					frame:SetNormalTexture(buttonNormalTexture)
				end
			end
			----------------------------IMPLEMENT HISTORY WINDOW FUNCTIONS
		end
		
		--Updates History Buttons to include a new page of History Entries
		local function historyPageSet(page)
			for i = 1, min(10,historyButtonNum) do
				frame = _G["RDSW_History_Button_Font" .. i]
				entry = #RDSW.history + 1 - i
				local outString = "%d- %s-%s-%s [%s:%s]
				
				entry,
				RDSW.history[entry].date.month,
				RDSW.history[entry].date.day,
				RDSW.history[entry].date.year,
				RDSW.history[entry].date.hour,
				RDSW.history[entry].date.min,
				RDSW.history[entry].encounter,
				RDSW.history[entry].encounterid,
				RDSW.history[entry].playername,
				RDSW.history[entry].dungeonmode,
				RDSW.history[entry].groupSize,
				RDSW.history[entry].int,
				RDSW.history[entry].mst,
				RDSW.history[entry].hst,
				RDSW.history[entry].crt,
				RDSW.history[entry].vrs,
				RDSW.history[entry].mstperc,
				RDSW.history[entry].hstperc,
				RDSW.history[entry].crtperc,
				RDSW.history[entry].vrsperc,
				RDSW.history[entry].talents,
				RDSW.history[entry].duration
				
				
				frame:SetText(
		
		
		
		--Creates a index style set of button frames.
		local function indexGen(items, parent, name, width, ttlHeight, justify, align, xOff, yOff, fontSize)
			if type(items) == "number" then
				local height = ttlHeight / items
				local bfFontString
				local frame = _G[parent]
				for i = 1, items do
					local bf = CreateFrame("Button", name .. "_Button" .. i, frame)
					bf:SetFrameStrata("MEDIUM")
					bf:SetFrameLevel(10)
					bf:SetPoint(align, frame, align, xOff, ((i-1) * height * -1) + yOff)
					bf:SetSize(width, height)
					bf:SetNormalTexture(buttonNormalTexture)
					bf:SetHighlightTexture(buttonHighlightTexture)
					bf:SetPushedTexture(buttonPressedTexture)
					bfFontString = bf:CreateFontString(name .. "_Button_Font" .. i)
					bfFontString:SetFont(RDSW.vixarFont, fontSize, "OUTLINE")
					bfFontString:SetPoint("LEFT", bf, "LEFT", 10, 0)
					bfFontString:SetSize(width, height)
					bfFontString:SetJustifyH("LEFT")
					bfFontString:SetDrawLayer("OVERLAY")
				end
			elseif type(items) == "table" then
				local height = ttlHeight / #items
				local frame = _G[parent]
				for i,v in pairs(items) do
					local bf = CreateFrame("Button", name .. "_Button" .. i, frame)
					bf:SetFrameStrata("MEDIUM")
					bf:SetFrameLevel(10)
					bf:SetPoint(align, frame, align, xOff, ((i-1) * height * -1) + yOff)
					bf:SetSize(width, height)
					bf:SetNormalTexture(buttonNormalTexture)
					bf:SetHighlightTexture(buttonHighlightTexture)
					bf:SetPushedTexture(buttonPressedTexture)
					bfFontString = bf:CreateFontString(name .. "_Button_Font" .. i)
					bfFontString:SetFont(RDSW.vixarFont, 10, "OUTLINE")
					bfFontString:SetPoint("LEFT", bf, "LEFT", 10, 0)
					bfFontString:SetSize(width, height)
					bfFontString:SetJustifyH("LEFT")
					bfFontString:SetDrawLayer("OVERLAY")
					bfFontString:SetText(v)
				end
			end
		end
		
		--Implements checkbox functions on click
		local function checkButtoncontentTypeEnable(frameName, contentType)
			if _G[frameName .. contentType.id .. "_CheckBox"]:GetChecked() then
				contentType.enabled = false
			else 
				contentType.enabled = true
			end			
			RDSW.updateDisplay()
		end
		
		--Creates a row-col box style set of checkbox frames.
		local function checkBoxGen(items, parent, frameName, title, ttlWidth, ttlHeight, justify, align, xOff, yOff, fontSize, cols)
			local indent = 10
			local buttonSize = 25
			local rows = math.ceil(#items / cols)
			local height = (ttlHeight - buttonSize - indent * 2) / (rows-1)
			local width = (ttlWidth - buttonSize - indent * 2) / (cols)
			
			local cbfFontString, cbfTitleString, colPos, rowPos
			
			local brd = CreateFrame("FRAME", frameName .. "_Checkbox_Frame", parent)
			brd:SetPoint(align, parent, align, xOff, yOff)
			brd:SetSize(ttlWidth, ttlHeight)
			brd:SetBackdrop{
					edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
					tile = false,
					tileSize = nil,
					edgeSize = 10,
					insets = {left = 1, right = 1, top = 1, bottom = 1}
			}
			cbfTitleString = brd:CreateFontString(frameName .. "CheckBox_Title")
			cbfTitleString:SetFont(RDSW.vixarFont, fontSize, "OUTLINE")
			cbfTitleString:SetPoint("TOPLEFT", brd, "TOPLEFT", 10, 25)
			cbfTitleString:SetSize(ttlWidth, 50)
			cbfTitleString:SetJustifyH("LEFT")
			cbfTitleString:SetDrawLayer("OVERLAY")
			cbfTitleString:SetText(title)
			for i,v in ipairs(items) do
				colPos = mod(i-1, cols)
				rowPos = math.floor((i-1)/rows)
				local contentType = RDSW.enabledContent[v]
				local cbf = CreateFrame("CheckButton", frameName .. contentType.id .. "_CheckBox", brd, "UICheckButtonTemplate")
				cbf:SetPoint("TOPLEFT", brd, "TOPLEFT", 
				colPos * width + indent,
				rowPos * height * -1 - indent)
				cbf:SetSize(buttonSize, buttonSize)
				cbf:SetScript("OnMouseUp", function() checkButtoncontentTypeEnable(frameName, contentType) end)
				if contentType.enabled == true then
					cbf:SetChecked(true)
				else 
					cbf:SetChecked(false)
				end
				cbfFontString = cbf:CreateFontString(frameName .. contentType.id .. "CheckBox_Font")
				cbfFontString:SetFont(RDSW.vixarFont, fontSize, "OUTLINE")
				cbfFontString:SetPoint("LEFT", cbf, "LEFT", 28, 0)
				cbfFontString:SetSize(200, height)
				cbfFontString:SetJustifyH("LEFT")
				cbfFontString:SetDrawLayer("OVERLAY")
				cbfFontString:SetText(contentType.name)
			end
		end


		--Display Frame
		local df = CreateFrame("FRAME", "RDSW_Display_Frame", UIParent)
		df:SetPoint("CENTER", RDSW.Display_XPos, RDSW.Display_YPos)
		df:SetSize(210, 95)
		df:SetFrameStrata("BACKGROUND")
		df:SetFrameLevel(10)
		df:SetMovable(true)
		df:EnableMouse(true)
		df:SetScript("OnDragStart", df.StartMoving)
		df:SetScript("OnDragStop", df.StopMovingOrSizing)

		--Create Display Texture
		local bg = df:CreateTexture("RDSW_Display_BG", "BACKGROUND")
		bg:SetAllPoints(df)
		bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
		if RDSW.Option_Lock then
			bg:SetAlpha(1) 
			df:RegisterForDrag("LeftButton")
		else 
			bg:SetAlpha(0) 
			df:RegisterForDrag()
		end
		
		--Create Left Text Display
		local displayText1 = df:CreateFontString("RDSW_Display_Text1") 
		local displayText2 = df:CreateFontString("RDSW_Display_Text2") 
		local displayText3 = df:CreateFontString("RDSW_Display_Text3") 
		displayText1:SetSize(200, 300)
		displayText1:SetFont(RDSW.vixarFont, RDSW.displayFontSize, "OUTLINE")
		displayText1:SetJustifyH("RIGHT")
		--Create Right Text Display
		displayText2:SetSize(200, 300)
		displayText2:SetFont(RDSW.vixarFont, RDSW.displayFontSize, "OUTLINE")
		displayText2:SetJustifyH("RIGHT")
		--Create Title Text Display
		displayText3:SetSize(150, 10)
		displayText3:SetFont(RDSW.vixarFont, RDSW.displayFontSize, "OUTLINE")
		displayText3:SetJustifyH("CENTER")
		displayText3:SetText(string.format("RDSW V: %.1f", RDSW.version))
		--Sets Display Text Position and Orientation.
		function RDSW.SetDisplayTextPos()
			if RDSW.displayOrientation == "Horizontal" then
				displayText1:SetPoint("LEFT", df, 0, 0)
				displayText2:SetPoint("LEFT", df, 175, 0)
				displayText3:SetPoint("TOP", df, 0, 10)
			elseif RDSW.displayOrientation == "Vertical" then
				displayText1:SetPoint("LEFT", df, 0, 0)
				displayText2:SetPoint("LEFT", df, 0, -100)
				displayText3:SetPoint("TOP", df, 0, 10)
			end
		end

		--Config Main Frame
		local cf = CreateFrame("FRAME", "RDSW_Config_Frame", UIParent)
		cf:SetPoint("CENTER", RDSW.Config_XPos, RDSW.Config_YPos)
		cf:SetSize(900, 550)
		cf:SetFrameStrata("MEDIUM")	
		cf:SetFrameLevel(5)
		cf:SetMovable(true)
		cf:EnableMouse(true)
		cf:SetScript("OnDragStart", df.StartMoving)
		cf:SetScript("OnDragStop", df.StopMovingOrSizing)
		cf:RegisterForDrag("LeftButton")
		cf:SetBackdrop{
				bgFile="Interface\\Addons\\RDSW\\Media\\Images\\Green Forest" ,
				edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
				tile = false,
				tileSize = nil,
				edgeSize = 10,
				insets = {left = 1, right = 1, top = 1, bottom = 1}
		}
		local cbg = cf:CreateTexture("RDSW_Config_Frame", "MEDIUM")
		cbg:SetAllPoints(cf)
		cbg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
		
		--Directory Window Frame
		local dirf = CreateFrame("FRAME", "RDSW_Directory_Frame", cf)
		dirf:SetPoint("TOPLEFT", 10, -10)
		dirf:SetSize(170, 170)
		dirf:SetFrameStrata("MEDIUM")	
		dirf:SetFrameLevel(10)
		dirf:SetBackdrop{
				bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
				tile = false,
				tileSize = nil,
				edgeSize = 10
		}

		--Active Window Frame
		local actf = CreateFrame("FRAME", "RDSW_Active_Frame", cf)
		actf:SetPoint("TOPRIGHT", -10, -10)
		actf:SetSize(700, 350)
		actf:SetFrameStrata("MEDIUM")	
		actf:SetFrameLevel(10)
		actf:SetBackdrop{
			bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = false,
			tileSize = nil,
			edgeSize = 10
		}
		
		
		--Generate Active Window Frames
		local curF
		for k,v in ipairs(directoryItems) do
			curF = CreateFrame("FRAME", "RDSW_" .. v .. "_Window_Frame", actf)
			curF:SetAllPoints(actf)
			curF:SetFrameLevel(12)
			curF:SetBackdrop({
				bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
				tile = false,
				tileSize = nil,
				edgeSize = 10
				})
		end 
		
		--Aux Window Frame
		local auxf = CreateFrame("FRAME", "RDSW_Active_Frame", cf)
		auxf:SetPoint("BOTTOMLEFT", 10, 10)
		auxf:SetSize(880, 175)
		auxf:SetFrameStrata("MEDIUM")	
		auxf:SetFrameLevel(7)
		auxf:SetBackdrop{
			bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = false,
			tileSize = nil,
			edgeSize = 10
		}
		
		--Banner Texture
		local cbanner = CreateFrame("FRAME", "RDSW_Banner", RDSW_Config_Frame)
		cbanner:SetPoint("TOP", actf, "CENTER", 0 , 150)
		cbanner:SetSize(300, 75)
		cbanner:SetFrameStrata("MEDIUM")	
		cbanner:SetFrameLevel(14)
		--cbanner:SetBackdrop{
		--		bgFile="Interface\\addons\\RDSW\\Media\\Images\\RDSW Banner",
		--		tile = false,
		--		tileSize = nil
		--[[

		--Settings Window Elements
		local swf = _G["RDSW_Settings_Window_Frame"]
		--swf Dropdown 1 
		local swfDropdown1 = CreateFrame("Button", "RDSW_SWF_Dropdown1", swf, "UIDropDownMenuTemplate")
		swfDropdown1:ClearAllPoints()
		swfDropdown1:SetPoint("CENTER",-210, 0)
		swfDropdown1:Show()
		swfDropdown1Items = {"Both", "HPM: Healing Per Mana", "HPCT: Healing Per Cast Time"}
		local function swfDropDownClick1(self, item)
			UIDropDownMenu_SetSelectedID(RDSW_SWF_Dropdown1, self:GetID())
			if item == "Both" then
				RDSW.calcType = 1
			elseif item == "HPM: Healing Per Mana" then
				RDSW.calcType = 2
			elseif item == "HPCT: Healing Per Cast Time" then
				RDSW.calcType = 3
			end
			RDSW.updateDisplay()
		end
		local function swfDropdown1Initialize(self, level)
		   local info = UIDropDownMenu_CreateInfo()
		   for k,v in ipairs(swfDropdown1Items) do
			  info = UIDropDownMenu_CreateInfo()
			  info.text = v
			  info.value = v
			  info.func = swfDropDownClick1
			  info.arg1 = v
			  info.arg2 = 
			  UIDropDownMenu_AddButton(info, level)
		   end
		end
		UIDropDownMenu_Initialize(swfDropdown1, swfDropdown1Initialize)
		UIDropDownMenu_SetWidth(swfDropdown1, 100);
		UIDropDownMenu_SetButtonWidth(swfDropdown1, 124)
		UIDropDownMenu_SetSelectedID(swfDropdown1, 1)
		UIDropDownMenu_JustifyText(swfDropdown1, "LEFT")
		--swf Dropdown 1 title
		local swfDropdown1Title = swf:CreateFontString("RDSW_SWF_Dropdown1_Title") 
		swfDropdown1Title:SetPoint("CENTER", swfDropdown1, 0, 25)
		swfDropdown1Title:SetSize(300, 75)
		swfDropdown1Title:SetJustifyH("CENTER")
		swfDropdown1Title:SetFont(RDSW.vixarFont, 12, "OUTLINE")
		swfDropdown1Title:SetText("Display Type:")
		swfDropdown1Title:SetTextColor(1, 1, 1, 1)

		--swf Dropdown 2
		local swfDropdown2 = CreateFrame("Button", "RDSW_SWF_Dropdown2", swf, "UIDropDownMenuTemplate")
		swfDropdown2:ClearAllPoints()
		swfDropdown2:SetPoint("CENTER", -70, 0)
		swfDropdown2:Show()
		swfDropdown2Items = {"Horizontal", "Vertical"}
		local function swfDropDownClick2(self, item)
			UIDropDownMenu_SetSelectedID(swfDropdown2, self:GetID())
			if item == "Horizontal" then 
				RDSW.displayOrientation = "Horizontal"
			elseif item == "Vertical" then 
				RDSW.displayOrientation = "Vertical"
			end
			RDSW.SetDisplayTextPos()
		end
		local function swfDropdown2Initialize(self, level)
		   local info = UIDropDownMenu_CreateInfo()
		   for k,v in ipairs(swfDropdown2Items) do
			  info = UIDropDownMenu_CreateInfo()
			  info.text = v
			  info.value = v
			  info.func = swfDropDownClick2
			  info.arg1 = v
			  UIDropDownMenu_AddButton(info, level)
		   end
		end
		UIDropDownMenu_Initialize(swfDropdown2, swfDropdown2Initialize)
		UIDropDownMenu_SetWidth(swfDropdown2, 100);
		UIDropDownMenu_SetButtonWidth(swfDropdown2, 124)
		UIDropDownMenu_SetSelectedID(swfDropdown2, 1)
		UIDropDownMenu_JustifyText(swfDropdown2, "LEFT")
		--swf Dropdown 2 title
		local swfDropdown2Title = swf:CreateFontString("RDSW_SWF_Dropdown2_Title") 
		swfDropdown2Title:SetPoint("CENTER", swfDropdown2, 0, 25)
		swfDropdown2Title:SetSize(300, 75)
		swfDropdown2Title:SetJustifyH("CENTER")
		swfDropdown2Title:SetFont(RDSW.vixarFont, 12, "OUTLINE")
		swfDropdown2Title:SetText("Orientation:")
		swfDropdown2Title:SetTextColor(1, 1, 1, 1)

		--swf Dropdown 3
		local swfDropdown3 = CreateFrame("Button", "RDSW_SWF_Dropdown3", swf, "UIDropDownMenuTemplate")
		swfDropdown3:ClearAllPoints()
		swfDropdown3:SetPoint("CENTER", 70, 0)
		swfDropdown3:Show()
		swfDropdown3Items = {"0.123", "0.12", "0.1"}
		local function swfDropDownClick3(self, item)
			UIDropDownMenu_SetSelectedID(RDSW_SWF_Dropdown3, self:GetID())
			if item == "0.123" then
				RDSW.displayPrecision = 3
			elseif item == "0.12" then
				RDSW.displayPrecision = 2
			elseif item == "0.1" then
				RDSW.displayPrecision = 1
			end
			RDSW.updateDisplay()
		end
		local function swfDropdown3Initialize(self, level)
		   local info = UIDropDownMenu_CreateInfo()
		   for k,v in ipairs(swfDropdown3Items) do
			  info = UIDropDownMenu_CreateInfo()
			  info.text = v
			  info.value = v
			  info.func = swfDropDownClick3
			  info.arg1 = v
			  info.arg2 = 
			  UIDropDownMenu_AddButton(info, level)
		   end
		end
		UIDropDownMenu_Initialize(swfDropdown3, swfDropdown3Initialize)
		UIDropDownMenu_SetWidth(swfDropdown3, 100);
		UIDropDownMenu_SetButtonWidth(swfDropdown3, 124)
		UIDropDownMenu_SetSelectedID(swfDropdown3, 1)
		UIDropDownMenu_JustifyText(swfDropdown3, "LEFT")
		--swf Dropdown 3 title
		local swfDropdown3Title = swf:CreateFontString("RDSW_SWF_Dropdown3_Title") 
		swfDropdown3Title:SetPoint("CENTER", swfDropdown3, 0, 25)
		swfDropdown3Title:SetSize(300, 75)
		swfDropdown3Title:SetJustifyH("CENTER")
		swfDropdown3Title:SetFont(RDSW.vixarFont, 12, "OUTLINE")
		swfDropdown3Title:SetText("Display Precision:")
		swfDropdown3Title:SetTextColor(1, 1, 1, 1)
		
		--swf Edit Box 1
		local swfEditBox1 = CreateFrame("EditBox", "RDSW_SWF_EDITBOX1", swf, "InputBoxTemplate")
		swfEditBox1:SetAutoFocus(false)
		swfEditBox1:SetSize(40,40)
		swfEditBox1:SetPoint("CENTER", swf, 210, 0)
		swfEditBox1:SetFont(RDSW.vixarFont, 12, "OUTLINE")
		swfEditBox1:SetFont(RDSW.vixarFont, 12, "OUTLINE")
		swfEditBox1:SetNumeric()
		swfEditBox1:SetNumber(RDSW.displayFontSize)
		--Font Size Edit Box
		local function swfEditBox1_OnEnterPressed()
			RDSW.displayFontSize = swfEditBox1:GetNumber()
			displayText1:SetFont(RDSW.vixarFont, RDSW.displayFontSize, "OUTLINE")
			displayText2:SetFont(RDSW.vixarFont, RDSW.displayFontSize, "OUTLINE")
			swfEditBox1:SetNumber(RDSW.displayFontSize)
			swfEditBox1:ClearFocus()
		end
		local function swfEditBox1_OnEscapePressed()
			swfEditBox1:ClearFocus()
		end
		swfEditBox1:SetScript("OnEnterPressed", swfEditBox1_OnEnterPressed)
		swfEditBox1:SetScript("OnEscapePressed", swfEditBox1_OnEscapePressed)
		--swf Edit Box 1 title
		local swfEditBox1Title = swfEditBox1:CreateFontString("RDSW_SWF_EditBox1_Title") 
		swfEditBox1Title:SetPoint("CENTER", swfEditBox1, 0, 25)
		swfEditBox1Title:SetSize(150, 75)
		swfEditBox1Title:SetJustifyH("CENTER")
		swfEditBox1Title:SetFont(RDSW.vixarFont, 12, "OUTLINE")
		swfEditBox1Title:SetText("Display Font Size:")
		swfEditBox1Title:SetTextColor(1, 1, 1, 1)
		
		--Updates text field on History Window Buttons
		local function updateHistoryPage(page)	
			RDSW.historyPage = page
			local entryNum 
			local outString
			for i = 1, historyButtonNum do
				entryNum = (RDSW.historyPage - 1) * historyButtonNum + i
				entry = RDSW.history[RDSW.historyEntryNum - entryNum + 1]
				if not entry then
					outString = "--No Session--"
				else 
					outString = string.format("%13d- %15d%: %s\n[%d] %5s %s",
					entryNum, 
					entry.date,
					entry.outcome,
					entry.eName,
					entry.dungeonmode,
					entry.duration)
				end

				_G["RDSW_History_Button_Font" .. i]:SetText(outString)
			end
		end
		
		--History Frame Elements
		local hwf = _G["RDSW_History_Window_Frame"]
			
		--Implement aux frame display on history window button press
		--Implement turn page button and text field
		--Implement search for date on history
		
		--Initialing functions
		----Display
		RDSW.SetDisplayTextPos()
		RDSW.updateDisplay()
		----Directory and History Buttons
		indexGen(directoryItems, 	"RDSW_Directory_Frame", 		"RDSW_Directory", 	160, 160, "LEFT", "TOPLEFT", 5, -5, 18)
		indexGen(historyButtonNum,	"RDSW_History_Window_Frame", 	"RDSW_History", 	670, 338, "LEFT", "TOPLEFT", 5, -5, 18)
		----Setting Checkboxs
		checkBoxGen(raidcontentTypeItems, swf, 	"RDSW_Enabled_Content_", "Content Type:", 300, 80, "CENTER", "CENTER", -175, -125, 12, 2)
		checkBoxGen(hideLocationItems, swf, 	"RDSW_Enabled_Content_", "Show Display:", 300, 80, "CENTER", "CENTER", 175, -125, 12, 2)
		--Button Click Registry
		----Binds function for  Directory Buttons
		for i = 1, #activeWindowList do 
			_G["RDSW_Directory_Button" .. i]:SetScript("OnMouseUp", function() directoryWindow(i, #activeWindowList) end)
		end
		----Binds function for History Buttons
		for i = 1, historyButtonNum do 
			_G["RDSW_History_Button" .. i]:SetScript("OnMouseUp", function() historyWindow(i, historyButtonNum) end)
		end
		--Sets Initial Active Window
		directoryWindow(RDSW.activeWindowCode, #activeWindowList)
		--Text Initial History Button Text
		updateHistoryPage(RDSW.historyPage)
		
		--Set Config Hide/Show stat on load.
		if not RDSW.config_Toggle then 
			RDSW_Config_Frame:Hide()
		end]]
	end
end)