--------------------------------------
-- Namespaces
--------------------------------------
local AP_display_name, AP = ...
local UI = AP.UI;
local GV = AP.GV;
local MaxXP = AP.MaxXP;
--local originalDisplayTimePlayed = _G.ChatFrame_DisplayTimePlayed
local App = LibStub("AceAddon-3.0"):NewAddon("XpChart", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")


--LDB:Show("XpChart")
-- local XPCIcon = LibStub("LibDataBroker-1.1"):NewDataObject("XpChart", {
-- type = "launcher",
-- text = "XpChart",
-- icon = "Interface\\AddOns\\XpChart\\media\\logo",
-- OnClick = function() print("BUNNIES ARE TAKING OVER THE WORLD") end,
-- })
-- local icon = LibStub("LibDBIcon-1.0")
-- if LDBIcon then
	-- LDBIcon:Register("PoisonCharges", PC_MinimapBtn, PC_MinimapPos) -- PC_MinimapPos is a SavedVariable which is set to 90 as default
-- end
-- icon:Show("XpChart")

--------------------------------------
-- Custom Slash Command
--------------------------------------
local commands = {
	["show"] = UI.Show, 
	["hide"] = UI.Hide, 
	["toggle"] = UI.Toggle, 
	["options"] = UI.ShowOptions, 
	["debug"] = function() GV.debug = not GV.debug end, 	
	["help"] = function()
		print(" ");
		UI:Print("List of commands:");
		UI:Print("|cff00cc66/xpchart show|r - open Xp Chart window");
		UI:Print("|cff00cc66/xpchart hide|r - close Xp Chart window");
		UI:Print("|cff00cc66/xpchart toggle|r - toggle Xp Chart window");
		UI:Print("|cff00cc66/xpchart options|r - open Xp Chart options");
		UI:Print("|cff00cc66/xpchart help|r - shows help info");
		print(" ");
	end,
	
	["example"] = {
		["test"] = function(...)
			core:Print("My Value:", tostringall(...));
		end
	}
};
local function HandleSlashCommands(str)	
--print ("HandleSlashCommands");
	if (#str == 0) then	
		commands.help();
		return;		
	end	
	
	local args = {};
	for _, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg);
		end
	end	
	local path = commands; -- required for updating found table.
	for id, arg in ipairs(args) do
		if (#arg > 0) then -- if string length is greater than 0.
			arg = arg:lower();			
			if (path[arg]) then
				if (type(path[arg]) == "function") then				
					-- all remaining args passed to our function!
					path[arg](select(id + 1, unpack(args))); 
					return;					
				elseif (type(path[arg]) == "table") then				
					path = path[arg]; -- another sub-table found!
				end
			else
				-- does not exist!
				commands.help();
				return;
			end
		end
	end
end

function App:TableSize(tbl)
	local count = 0;
	for k,v in pairs(tbl) do 
		count = count + 1;
	end
	return count;
end

function AP:GetPlayer(playerName)
	for i=1,#AP.DB.players do 	
		if AP.DB.players[i].name == playerName then
			return AP.DB.players[i];
		end
	end
end
--------------------------------------
-- App
--------------------------------------

function App:OnInitialize()
	self:Debug("App:OnInitialize - Start")
	
	--self::RegisterEvent("ADDON_LOADED");
	
	--self:RegisterChatCommand("myslash", "MySlashProcessorFunc")
	
	--originalDisplayTimePlayed = _G.ChatFrame_DisplayTimePlayed
	
	SLASH_FRAMESTK1 = "/fs"; -- new slash command for showing framestack tool
	SlashCmdList.FRAMESTK = function()
		 LoadAddOn("Blizzard_DebugTools");
		 FrameStackTooltip_Toggle();
	 end
	
	SLASH_XpChart1 = "/xpc";
	SLASH_XpChart2 = "/xpchart";
	SlashCmdList.XpChart = HandleSlashCommands;
	 
	local LDB = LibStub("LibDataBroker-1.1", true)
	local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
	if LDB then	
		local XPC_MinimapBtn = LDB:NewDataObject("XpChart", {
			type = "launcher",
			text = "Xp Chart",
			icon = "Interface\\AddOns\\XpChart\\logo",
			OnClick = function(_, button)
				if button == "LeftButton" then 
					UI.Toggle();
				elseif button == "RightButton" then
					UI.ToggleOptions();
				end
			end,
			OnTooltipShow = function(tt)
				tt:AddLine("Xp Chart")
				tt:AddLine("|cffffff00Left click:|r Open Xp Chart window")
				tt:AddLine("|cffffff00Right click:|r Open options window")
			end,
		})
		if LDBIcon then
			LDBIcon:Register("XpChart", XPC_MinimapBtn, XPChartDB) -- PC_MinimapPos is a SavedVariable which is set to 90 as default
		end
	end
	
	self:Debug("App:OnInitialize - End")
end

function App:InitDB()
	AP.DB = XPChartDB
	
	

	if GV.resetDBOnLogin then	
		AP.DB = nil; -- for testing
	end
	if AP.DB == nil then
		self:Debug("AP.DB == nil") 
		AP.DB = {}; 
	else
		self:Debug("AP.DB NOT nil") 
	end
	
	if AP.DB.players == nil then
		self:Debug("AP.DB.players == nil") 
		AP.DB.players = {}; 
	else
		self:Debug("AP.DB.players NOT nil") 
	end
	
	local playerName = UnitName("player");
	local player = AP:GetPlayer(playerName);
	--GV.debug = true;
	if player == nil then
		self:Debug("player == nil") ;
		local p = {
			name = playerName,
			selected = true,
			graphLineColor = GV.defaultPlayerLineColor,
			points = {}
		}		
		AP.DB.players[#AP.DB.players + 1] = p ;
	else
		self:Debug("player NOT nil") 
	end
end

function App:OnEnable()
	self:Debug("App:OnEnable - Start")

	-- Check expansion 
	local expansionLevel= GetAccountExpansionLevel();
	if expansionLevel>0 then
		UI:Print("This addon can only work with World of Warcraft Classic extension. Please disable this addon.");
		return 
	end
	
	self:InitDB();

	UI:Init()
	
    -- Called when the addon is enabled

	self:RegisterEvent("TIME_PLAYED_MSG")
	--self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnStartCombat")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEndCombat")
	self:RegisterEvent("PLAYER_LOGOUT")

	self:ScheduleRepeatingTimer("CustomRequestTimePlayed", 60)
	
	self:Debug("App:OnEnable - End")
end

function App:OnDisable()
	self:Debug("App:OnDisable - Start")
	self:Debug("App:OnDisable - End")
end
function App:ADDON_LOADED(event, args)
	--print("App:ADDON_LOADED") 
	-- self:Debug("ADDON_LOADED ? " .. args);
	-- if event == "ADDON_LOADED" and args == "XpChart" then
		-- self:Debug("ADDON_LOADED");
	-- end
end
function App:PLAYER_LOGOUT(sender, args)
	XPChartDB = AP.DB;
end
function App:TIME_PLAYED_MSG(msg, seconds_played)
	--App:CustomRequestTimePlayed();
	--_G.ChatFrame_DisplayTimePlayed = originalDisplayTimePlayed
	self:RecordGraphPoint(seconds_played);
end
function App:OnStartCombat(sender, args)
	--print("PLAYER_REGEN_DISABLED " .. UnitXP("player"));
end
function App:OnEndCombat(sender, args)
	self:Debug("App:OnEndCombat ");
	self:CustomRequestTimePlayed();
end
function App:RecordGraphPoint(seconds_played)
	self:Debug("RecordGraphPoint ".. seconds_played)

	local playerName = UnitName("player");
	local lvl = UnitLevel("player");
	local totalXp = UnitXP("player") + MaxXP:GetTotalMaxXp(lvl - 1);
	
	local p = AP:GetPlayer(playerName);	
	if #p.points > 2 then 
		-- check last point
		if p.points[#p.points].xp == totalXp and p.points[#p.points - 1].xp == totalXp then
			p.points[#p.points].played = seconds_played;
		else
			p.points[#p.points + 1] = {played = seconds_played, xp = totalXp};
		end
	else
		p.points[#p.points + 1] = {played = seconds_played, xp = totalXp};
	end
	
	UI:UpdateGraph();
end


function App:Debug(txt)
	if GV.debug then
		print(txt);
	end
end


do -- Time Played functions closure
	local requesting
	-- Time Played display function that is hooked to prevent chat spam from AllPlayed
	-- Thanks to Phanx for the code
	local o = _G.ChatFrame_DisplayTimePlayed
	_G.ChatFrame_DisplayTimePlayed = function(...)
		if requesting then
			requesting = false		
			return
		end
		return o(...)
	end
	-- Function that Send a request to the server to get an update of the time played.
	function App:CustomRequestTimePlayed()
		if UnitLevel("player") < 60 then
		--if time() - self.db.global.data[self.faction][self.realm][self.pc].seconds_played_last_update > 10 then
			requesting = true
			_G.RequestTimePlayed()	
		end
	end
end -- Time Played functions closure

--[[
local frame = CreateFrame("FRAME"); -- Need a frame to respond to events
frame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
frame:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out
function frame:OnEvent(event, arg1)
 if event == "ADDON_LOADED" and arg1 == "XpChart" then
	-- Our saved variables are ready at this point. If there are none, both variables will set to nil.
	if HaveWeMetCount == nil then
		HaveWeMetCount = 0; -- This is the first time this addon is loaded; initialize the count to 0.
	end
	if HaveWeMetBool then
		print("Hello again, " .. UnitName("player") .. "!");
	else
		HaveWeMetCount = HaveWeMetCount + 1; -- It's a new character.
		print("Hi; what is your name?");
	end
	elseif event == "PLAYER_LOGOUT" then
		HaveWeMetBool = true; -- We've met; commit it to memory.
	end
end
frame:SetScript("OnEvent", frame.OnEvent);
]]





