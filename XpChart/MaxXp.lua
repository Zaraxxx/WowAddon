--------------------------------------
-- Namespaces
--------------------------------------
local AP_display_name, AP = ...;
AP.MaxXP = {};

local MaxXP = AP.MaxXP;


--------------------------------------
-- LVL constants
--------------------------------------
MaxXP[0] = 0;
MaxXP[1] = 400;
MaxXP[2] = 900;
MaxXP[3] = 1400;
MaxXP[4] = 2100;
MaxXP[5] = 2800;
MaxXP[6] = 3600;
MaxXP[7] = 4500;
MaxXP[8] = 5400;
MaxXP[9] = 6500;
MaxXP[10] =	7600;
MaxXP[11] =	8800;
MaxXP[12] =	10100;
MaxXP[13] =	11400;
MaxXP[14] =	12900;
MaxXP[15] =	14400;
MaxXP[16] =	16000;
MaxXP[17] =	17700;
MaxXP[18] =	19400;
MaxXP[19] =	21300;
MaxXP[20] =	23200;
MaxXP[21] =	25200;
MaxXP[22] =	27300;
MaxXP[23] =	29400;
MaxXP[24] =	31700;
MaxXP[25] =	34000;
MaxXP[26] =	36400;
MaxXP[27] =	38900;
MaxXP[28] =	41400;
MaxXP[29] =	44300;
MaxXP[30] =	47400;
MaxXP[31] =	50800;
MaxXP[32] =	54500;
MaxXP[33] =	58600;
MaxXP[34] =	62800;
MaxXP[35] =	67100;
MaxXP[36] =	71600;
MaxXP[37] =	76100;
MaxXP[38] =	80800;
MaxXP[39] =	85700;
MaxXP[40] =	90700;
MaxXP[41] =	95800;
MaxXP[42] =	101000;
MaxXP[43] =	106300;
MaxXP[44] =	111800;
MaxXP[45] =	117500;
MaxXP[46] =	123200;
MaxXP[47] =	129100;
MaxXP[48] =	135100;
MaxXP[49] =	141200;
MaxXP[50] =	147500;
MaxXP[51] =	153900;
MaxXP[52] =	160400;
MaxXP[53] =	167100;
MaxXP[54] =	173900;
MaxXP[55] =	180800;
MaxXP[56] =	187900;
MaxXP[57] =	195000;
MaxXP[58] =	202300;
MaxXP[59] =	209800;
MaxXP[60] =	494000;
MaxXP[61] =	574700;
MaxXP[62] =	614400;
MaxXP[63] =	650300;
MaxXP[64] =	682300;
MaxXP[65] =	710200;
MaxXP[66] =	734100;
MaxXP[67] =	753700;
MaxXP[68] =	768900;
MaxXP[69] =	779700;
MaxXP[70] =	0;

function MaxXP:GetTotalMaxXp(lvl)
	local total = 0;
	for i=1,lvl,1 do 
		total = total +MaxXP[i]; 
	end
	return total;
end