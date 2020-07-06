--------------------------------------
-- Namespaces
--------------------------------------
local AP_display_name, AP = ...
AP.UI = {};
local UI = AP.UI;
local GV = AP.GV;
local MaxXP = AP.MaxXP;

local graph;
local mainWin;
local optionWin;

local YLabels = {}
--------------------------------------
-- Functions
--------------------------------------
function UI:Debug(txt)
	if GV.debug then
		print(txt);
	end
end

function UI:GetThemeColor()
	 local c = GV.printTheme;
	 return c.r, c.g, c.b, c.hex;
end
function UI:Print(...)
	local hex = select(4, self:GetThemeColor());
    local prefix = string.format("|cff%s%s|r", hex:upper(), "Xp Chart:");
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
	
end

function UI:Init()	
	self:Debug("UI:Init - Begin");
	----------
	
	-- Check expansion 
	local expansionLevel= GetAccountExpansionLevel();
	if expansionLevel>0 then
		UI:Print("This addon can only work with World of Warcraft Classic extension. Please disable this addon.");
		return 
	end
	
	mainWin = self:CreateMainWindow()
	optionWin = self:CreateOptionWindow()
	
	graph = self:InitGraph(mainWin)
	self:UpdateGraph()	

	----------
	self:Debug("UI:Init - End");
end

function UI:Show()
	UI:Debug("UI:Show");
	mainWin:SetShown(true);
end
function UI:Hide()
	UI:Debug("UI:Hide");
	mainWin:SetShown(false);
end
function UI:Toggle()
	UI:Debug("UI:Toggle");
	mainWin:SetShown(not mainWin:IsShown());
end
function UI:ShowOptions()
	UI:Debug("UI:Show");
	optionWin:SetShown(true);
end
function UI:HideOptions()
	UI:Debug("UI:Hide");
	optionWin:SetShown(false);
end
function UI:ToggleOptions()
	UI:Debug("UI:ToggleOptions");
	optionWin:SetShown(not optionWin:IsShown());
end
function UI:CreateOptionWindow()	
	local opt = CreateFrame("Frame","XpChart",UIParent,"BasicFrameTemplateWithInset");
	
	opt:SetSize(GV.OptionWinWidth, GV.OptionWinHeight);
	opt:SetPoint("CENTER", UIParent, "CENTER")

	opt:SetMovable(true)
	opt:EnableMouse(true)
	opt:RegisterForDrag("LeftButton")
	opt:SetScript("OnDragStart", opt.StartMoving)
	opt:SetScript("OnDragStop", opt.StopMovingOrSizing)
	
	-- Window title
	opt.title = opt:CreateFontString(nil, "OVERLAY");
	opt.title:SetFontObject("GameFontHighlight");
	opt.title:SetPoint("LEFT", opt.TitleBg, "LEFT", 5, 0);
	opt.title:SetText("Xp Chart options");

	-- Buttons
	opt.CloseOptionBtn = CreateFrame("Button", nil, opt, "GameMenuButtonTemplate" );
	opt.CloseOptionBtn:SetSize(100, 30);
	opt.CloseOptionBtn:SetPoint("BOTTOMRIGHT", opt, "BOTTOMRIGHT", -10, 10)
	opt.CloseOptionBtn:SetText("Close");
	opt.CloseOptionBtn:SetNormalFontObject("GameFontNormal");
	opt.CloseOptionBtn:SetHighlightFontObject("GameFontHighlight");
	opt.CloseOptionBtn:SetScript("OnClick", function(self, arg1) UI:HideOptions() end);


	-- Players
	opt.lblPlayers = opt:CreateFontString(nil, "OVERLAY");
	opt.lblPlayers:SetFontObject("GameFontHighlightLarge");
	opt.lblPlayers:SetPoint("TOPLEFT", opt, "TOPLEFT", 15,-40);
	opt.lblPlayers:SetText("Characters to show:");
	
	local checkbtn;
	for i=1,#AP.DB.players do
		checkbtn = CreateFrame("CheckButton", nil, opt, "UICheckButtonTemplate" );
		checkbtn:SetPoint("TOPLEFT", opt, "TOPLEFT", 25,-30 + (-30 * i));
		checkbtn.text:SetText(AP.DB.players[i].name);
		checkbtn:SetNormalFontObject("GameFontNormalLarge")
		checkbtn:SetChecked(AP.DB.players[i].selected);
		checkbtn:SetScript("OnClick", function(self, arg1) 
				local pName = self.text:GetText();
				local p = AP:GetPlayer(pName);
				p.selected = self:GetChecked();
				UI:UpdateGraph();
			end);
	end

	-- opt.resetBtn = CreateFrame("Button", nil, opt, "GameMenuButtonTemplate" );
	-- opt.resetBtn:SetSize(100, 30);
	-- opt.resetBtn:SetPoint("BOTTOMRIGHT", opt, "BOTTOMRIGHT", 20, 10)
	-- opt.resetBtn:SetText("Reset");
	-- opt.resetBtn:SetNormalFontObject("GameFontNormal");
	-- opt.resetBtn:SetHighlightFontObject("GameFontHighlight");
	--opt.resetBtn:SetNormalFontObject("GameFontNormalLarge");
	--opt.resetBtn:SetHighlightFontObject("GameFontHighlightLarge");

	-- CheckButtons
	-- opt.checkbtn1 =  CreateFrame("CheckButton", nil, opt, "UICheckButtonTemplate" );
	-- opt.checkbtn1:SetPoint("TOPRIGHT", opt, "TOPRIGHT", -100,-40);
	-- opt.checkbtn1.text:SetText("Player 1");
	-- opt.checkbtn1:SetChecked(true);
	
	opt:SetFrameLevel(mainWin:GetFrameLevel() + 10)
	opt:Hide();
	
	return opt;
end

function UI:CreateMainWindow() 
	local win = CreateFrame("Frame","XpChart",UIParent,"BasicFrameTemplateWithInset");
	
	win:SetSize(GV.MainWinWidth, GV.MainWinHeight);
	win:SetPoint("CENTER", UIParent, "CENTER")

	-- Window title
	win.title = win:CreateFontString(nil, "OVERLAY");
	win.title:SetFontObject("GameFontHighlight");
	win.title:SetPoint("LEFT", win.TitleBg, "LEFT", 5, 0);
	win.title:SetText("Xp Chart");

	-- Buttons
	win.optionsBtn = CreateFrame("Button", nil, win, "GameMenuButtonTemplate" );
	win.optionsBtn:SetSize(100, 30);
	win.optionsBtn:SetPoint("BOTTOMRIGHT", win, "BOTTOMRIGHT", -10,10)
	win.optionsBtn:SetText("Options");
	win.optionsBtn:SetNormalFontObject("GameFontNormal");
	win.optionsBtn:SetNormalFontObject("GameFontNormal");
	win.optionsBtn:SetHighlightFontObject("GameFontHighlight");
	win.optionsBtn:SetScript("OnClick", function(self, arg1) UI:ShowOptions() end);
	
	win:SetMovable(true)
	win:EnableMouse(true)
	win:RegisterForDrag("LeftButton")
	win:SetScript("OnDragStart", win.StartMoving)
	win:SetScript("OnDragStop", win.StopMovingOrSizing)

	win:SetFrameLevel(10)
	win:Hide();
	
	return win;
end

function UI:InitGraph(win) -- create win.chart
	self:Debug("UI:CreateChart - Begin");
		
	local graph = LibStub:GetLibrary("LibGraph-2.0");
	
	local g=graph:CreateGraphLine("XpChart-Graph",win,"TOPLEFT","TOPLEFT",	55,			-50,		win:GetWidth()-85,	win:GetHeight()-110)
	g:SetGridColor(GV.defaultPlayedDivisionLineColor)
	g:SetAxisDrawing(false,false)
	g:SetAxisColor({1.0,1.0,1.0,1.0})
	g:SetYLabels(true, false)

	self:Debug("UI:CreateChart - End");
	
	return g;
end

function UI:UpdateGraph()
	local MaxWidth , MaxHeight = UI:GetChartMaxAxis();
	local SpacingWidth = 1;
	graph.XGridIntervalUnit = " sec"
	graph.XGridIntervalMultiple = 1

	if MaxWidth > 86400 then
		SpacingWidth = 86400
		graph.XGridIntervalMultiple = 1
		graph.XGridIntervalUnit = " day"
	elseif MaxWidth > 3600 then
		SpacingWidth = 3600
		graph.XGridIntervalMultiple = 1
		graph.XGridIntervalUnit = " hr"
	elseif MaxWidth > 600 then
		SpacingWidth = 600
		graph.XGridIntervalMultiple = 10
		graph.XGridIntervalUnit = " min"
	elseif MaxWidth > 60 then
		SpacingWidth = 60
		graph.XGridIntervalMultiple = 1
		graph.XGridIntervalUnit = " min"
	elseif MaxWidth > 10 then
		SpacingWidth = 10
		graph.XGridIntervalMultiple = 10
		graph.XGridIntervalUnit = " sec"
	end

	local SpacingHeight = MaxHeight * 1.5; 	
	
	graph:SetYAxis(0,MaxHeight)
	graph:SetXAxis(0,MaxWidth)	
	graph:SetGridSpacing(SpacingWidth, SpacingHeight) 	
	graph:ResetData()
	self:DrawAllLevelLines(MaxHeight, MaxWidth);
	self:DrawPlayerLines();
end

function UI:DrawPlayerLines() 
	for i=1,#AP.DB.players do 
		local p = AP.DB.players[i]
		if p.selected == true then	
			if #p.points > 0 then
				--local lineColor = {1.0,1.0,1.0,1.0}
				local lineColor = p.graphLineColor;				
				local data = {}	
				for y=1,#p.points do
					data[y] = {p.points[y].played, p.points[y].xp}
				end
				graph:AddDataSeries( data , lineColor );
			end
		end
	end
end


function UI:DrawAllLevelLines(maxHeight, maxWidth) 	

	local maxLvlToShow = 1
	
	--Reset Labels
	for i=1,60,1 do	
		if YLabels[i] == nil then
			YLabels[i]= graph:CreateFontString(nil, "OVERLAY");
		end		
		YLabels[i]:ClearAllPoints()
		YLabels[i]:Hide()
	end
	
	-- Find max line
	for i=1,60,1 do	
		maxLvlToShow = i
		local lineLvl = MaxXP:GetTotalMaxXp(i)
		if lineLvl > maxHeight then
			break
		end
	end
	-- only show labels for the last 10 levels
	for i=1,maxLvlToShow,1 do	
		if i==10 or i==20 or i==30 or i==40 or i==50 or (i >= maxLvlToShow - 10 ) then
			local lineLvl = MaxXP:GetTotalMaxXp(i)
			local data={{1,lineLvl},{maxWidth,lineLvl}}
			local lineColor = GV.defaultLevelDivisionLineColor
			graph:AddDataSeries(data,lineColor)
			
			local YPosLbl = (lineLvl * graph:GetHeight()) / (graph.YMax-graph.YMin)	
			YLabels[i]:SetFontObject("GameFontHighlightSmall");
			YLabels[i]:SetPoint("LEFT", graph, "BOTTOMLEFT", -40, YPosLbl);
			YLabels[i]:SetText("Lvl " .. i);
			YLabels[i]:Show()
		end
	end
end


function UI:GetChartMaxAxis() 
	local maxXp = 1;
	local maxPlayed = 1;
	for i=1,#AP.DB.players do 
		local p = AP.DB.players[i]
		if p.selected == true and #p.points > 1 then
			if p.points[#p.points].played > maxPlayed then
				maxPlayed = p.points[#p.points].played
			end		
			if p.points[#p.points].xp > maxXp then
				maxXp = p.points[#p.points].xp
			end
		end
	end
	local maxXpToShow = 1;	
	for i=1,60 do 
		maxXpToShow = MaxXP:GetTotalMaxXp(i);
		if maxXpToShow > maxXp then
			break
		end
	end
	
	return maxPlayed * 1.03 , maxXpToShow * 1.03;	
end

