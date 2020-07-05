--------------------------------------
-- Namespaces
--------------------------------------
local AP_display_name, AP = ...;
AP.GV = {};
local GV = AP.GV;
--------------------------------------
-- Global Variables
--------------------------------------
GV.printTheme= {
	r = 0, 
	g = 0.8, -- 204/255
	b = 1,
	hex = "00ccff"
}

GV.defaultPlayerLineColor = {1.0,1.0,1.0,1.0}
GV.defaultLevelLineColor = {1.0,1.0,1.0,0.1}

GV.defaultsDB = {
	  profile = {
		setting = true,
		xpChartPoints = "ok"
	  }
	}
	
GV.debug = false;
GV.resetDBOnLogin = false;

GV.MainWinWidth = UIParent:GetWidth() - 500;
GV.MainWinHeight = UIParent:GetHeight() - 300;

GV.OptionWinWidth = 400;
GV.OptionWinHeight = 600;