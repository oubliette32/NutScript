--[[
    NutScript is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    NutScript is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with NutScript.  If not, see <http://www.gnu.org/licenses/>.
--]]

ACCESS_LABELS = {}
ACCESS_LABELS[DOOR_OWNER] = "owner"
ACCESS_LABELS[DOOR_TENANT] = "tenant"
ACCESS_LABELS[DOOR_GUEST] = "guest"
ACCESS_LABELS[DOOR_NONE] = "none"

function PLUGIN:ShouldDrawEntityInfo(entity)
	if (entity:isDoor() and !entity:getNetVar("disabled")) then
		return true
	end
end

function PLUGIN:DrawEntityInfo(entity, alpha)
	if (entity:isDoor()) then
		local position = entity:LocalToWorld(entity:OBBCenter()):ToScreen()
		local x, y = position.x, position.y
		local owner = entity:getNetVar("owner")
		local name = entity:getNetVar("title", entity:getNetVar("name", IsValid(owner) and L"dTitleOwned" or L"dTitle"))
		local faction = entity:getNetVar("faction")
		local color

		if (faction) then
			color = team.GetColor(faction)
		else
			color = nut.config.get("color")
		end

		nut.util.drawText(name, x, y, ColorAlpha(color, alpha), 1, 1)

		if (IsValid(owner)) then
			nut.util.drawText(L("dOwnedBy", owner:Name()), x, y + 16, ColorAlpha(color_white, alpha), 1, 1)
		elseif (faction) then
			local info = nut.faction.indices[faction]

			if (info) then
				nut.util.drawText(L("dOwnedBy", L2(info.name) or info.name), x, y + 16, ColorAlpha(color_white, alpha), 1, 1)
			end
		else
			nut.util.drawText(entity:getNetVar("noSell") and L"dIsNotOwnable" or L"dIsOwnable", x, y + 16, ColorAlpha(color_white, alpha), 1, 1)
		end
	end
end

netstream.Hook("doorMenu", function(entity, access)
	if (IsValid(nut.gui.door)) then
		return nut.gui.door:Remove()
	end

	if (IsValid(entity)) then
		nut.gui.door = vgui.Create("nutDoorMenu")
		nut.gui.door:setDoor(entity, access)
	end
end)

netstream.Hook("doorPerm", function(door, client, access)
	local panel = door.nutPanel

	if (IsValid(panel) and IsValid(client)) then
		panel.access[client] = access

		for k, v in ipairs(panel.access:GetLines()) do
			if (v.player == client) then
				v:SetColumnText(2, L(ACCESS_LABELS[access or 0]))

				return
			end
		end
	end
end)