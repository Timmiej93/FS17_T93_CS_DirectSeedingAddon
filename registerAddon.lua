-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --
--
-- Purpose: This file adds the 'processStrawArea' function to the 'updateDirectSowingArea' function.
-- 
-- Authors: Timmiej93
--
-- Copyright (c) Timmiej93, 2017
-- For more information on copyright for this mod, please check the readme file on Github
--
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

CS_DirectSeedingAddon = {};
local modItem = ModsUtil.findModItemByModName(g_currentModName);

local CSModName = "";

function CS_DirectSeedingAddon:loadMap(name)
	self.version = 'Direct Seeding Addon v'..((modItem and modItem.version) and modItem.version or "?.?.?").." | ";

	self.choppedStrawFound = false;
	self.notFoundInteration = 0;
	self.notFoundFinal = false;
	self.timeout = 100;

	self:search();
end;

function CS_DirectSeedingAddon:update(dt)
	if not self.choppedStrawFound and self.notFoundInteration < self.timeout then
		self:search();

		self.notFoundInteration = self.notFoundInteration + 1;
	end

	if self.notFoundInteration >= self.timeout and not self.notFoundFinal then
		print("ChoppedStraw_DirectSeedingAddon: ATTENTION! ChoppedStraw mod not found, addon disabled!")
		self.notFoundFinal = true;
	end
end

function CS_DirectSeedingAddon:overwriteFunctions()
	Utils.updateDirectSowingArea = Utils.overwrittenFunction(Utils.updateDirectSowingArea, CS_DirectSeedingAddon.updateDirectSowingArea);
end	

function CS_DirectSeedingAddon:updateDirectSowingArea(superFunc, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, angle, plantValue)
	_G[CSModName].ChoppedStraw_Register.processStrawArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
	local realArea, area = superFunc(self, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, angle, plantValue);
	return realArea, area;
end;

function CS_DirectSeedingAddon:CS_LogInfo(message)
	if _G[CSModName] ~= nil and g_modIsLoaded[CSModName] and g_currentMission.cs_version ~= nil then
		_G[CSModName].logInfo(5, self.version..message)
	else
		print("*** ChoppedStraw embedded in map | "..self.version..message)
	end
end

function CS_DirectSeedingAddon:search()
	for _,mod in pairs(ModsUtil.modList) do
		if SpecializationUtil.getSpecialization(tostring(mod.modName)..".ChoppedStraw") ~= nil then
			if g_modIsLoaded[mod.modName] then		-- Probably not needed, but can't hurt.
				self.choppedStrawFound = true;
				CSModName = tostring(mod.modName);

				self:overwriteFunctions()

				self:CS_LogInfo("ChoppedStraw mod found, addon loaded")
				break;
			end
		end
	end
end

function CS_DirectSeedingAddon:deleteMap() end;
function CS_DirectSeedingAddon:keyEvent(unicode, sym, modifier, isDown) end;
function CS_DirectSeedingAddon:mouseEvent(posX, posY, isDown, isUp, button) end;
function CS_DirectSeedingAddon:draw() end;

addModEventListener(CS_DirectSeedingAddon);
