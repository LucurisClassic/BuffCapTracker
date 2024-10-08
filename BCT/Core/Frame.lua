local BCT = LibStub("AceAddon-3.0"):GetAddon("BCT")
local SM = LibStub:GetLibrary("LibSharedMedia-3.0")

SM:Register("font", "Expressway", [[Interface\AddOns\BCT\Fonts\Expressway.ttf]])
SM:Register("font", "PT Sans Narrow", [[Interface\AddOns\BCT\Fonts\PTSansNarrow.ttf]])

local function UpdateFont()
	BCT.Window.text:SetFont(SM:Fetch("font",BCT.session.db.window.body.font), BCT.session.db.window.body.font_size, BCT.session.db.window.body.font_style)
	BCT.Anchor.text:SetFont(SM:Fetch("font",BCT.session.db.window.anchor.font), BCT.session.db.window.anchor.font_size, BCT.session.db.window.anchor.font_style)
end
BCT.UpdateFont = UpdateFont

local function UpdateWindowState()
	if BCT.Anchor:GetWidth() ~= BCT.session.db.window.anchor.width or
		BCT.Anchor:GetHeight() ~= BCT.session.db.window.anchor.height then
		BCT.Anchor:SetWidth(BCT.session.db.window.anchor.width)
		BCT.Anchor:SetHeight(BCT.session.db.window.anchor.height)
		BCT.Window:SetWidth(BCT.session.db.window.body.width)
		BCT.Window:SetHeight(BCT.session.db.window.body.height)
	end
	if BCT.session.db.window.enable and BCT.session.db.loading.enabled and BCT.session.db.loading.enabledFrames then
		BCT.Anchor:Show()
		BCT.Window:Show()
	else
		BCT.Anchor:Hide()
		BCT.Window:Hide()
	end
	if BCT.session.db.window.body.mouseover then
		BCT.Window:Hide()
	end
	if BCT.session.db.window.lock then
		BCT.Anchor:SetScript("OnDragStart", nil)
		BCT.Anchor:SetScript("OnDragStop", nil)
		BCT.Anchor:SetBackdropColor(0,0,0,0)
	else
		BCT.Anchor:SetScript("OnDragStart", BCT.Anchor.StartMoving)
		BCT.Anchor:SetScript("OnDragStop", BCT.Anchor.StopMovingOrSizing)
		BCT.Anchor:SetBackdropColor(0,0,0,1)
	end
	BCT.Window.text:ClearAllPoints()
	if BCT.session.db.window.body.growup then
		BCT.Window.text:SetPoint("BOTTOMLEFT", BCT.Window, "TOPLEFT", BCT.session.db.window.body.x_offset, BCT.session.db.window.body.y_offset)
	else
		BCT.Window.text:SetPoint("TOPLEFT", BCT.Window, "BOTTOMLEFT", BCT.session.db.window.body.x_offset, BCT.session.db.window.body.y_offset)
	end
	BCT.Anchor.text:SetPoint("LEFT", BCT.Anchor, "LEFT", BCT.session.db.window.anchor.x_offset, BCT.session.db.window.anchor.y_offset)
	
	if BCT.session.db.window.anchor.clickthrough and BCT.session.db.window.lock then
		BCT.Anchor:EnableMouse(false)
	else
		BCT.Anchor:EnableMouse(true)
	end
end
BCT.UpdateWindowState = UpdateWindowState

BCT.Anchor = CreateFrame("Frame","BCTAnchor",UIParent, "BackdropTemplate")
BCT.Anchor:SetMovable(true)
BCT.Anchor:EnableMouse(true)
BCT.Anchor:RegisterForDrag("LeftButton")
BCT.Anchor:SetWidth(200)
BCT.Anchor:SetHeight(35)
BCT.Anchor:SetAlpha(1.)
BCT.Anchor:SetPoint("CENTER",0,0)
BCT.Anchor.text = BCT.Anchor:CreateFontString(nil,"ARTWORK") 
BCT.Anchor.text:SetFont(SM:Fetch("font","Expressway"), 13, "OUTLINE")
BCT.Anchor.text:SetPoint("LEFT", BCT.Anchor, "LEFT", 0, 0)
BCT.Anchor.text:SetJustifyH("LEFT")
BCT.Anchor.text:SetText("BUFF CAP TRACKER")
BCT.Anchor:SetUserPlaced(true)

BCT.Anchor:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
 	tile = true,
 	tileSize = 16,
 	edgeSize = 16,
 	insets = { left = -4, right = 4, top = 4, bottom = 4 },
})

BCT.Anchor:SetScript("OnUpdate", function(self) 

	if not TradeFrame:IsVisible() and not InboxFrame:IsVisible() then
		if GetMouseFoci() ~= nil and BCT.session.db.window.body.mouseover then
			if GetMouseFoci():GetName() == "BCTAnchor" then
				BCT.Window:Show()
			else
				BCT.Window:Hide()
			end
		end
	end
	
	local title = BCT.session.db.window.anchor.value
	local counter = BCT.session.db.window.anchor.counter
	local buffs = BCT.buffsTotal + BCT.enchantsTotal + BCT.hiddenTotal
	
	if string.len(title) > 0 and counter ~= "None" then
		title = title .. " - "
	end
	
	if counter == "3/32" then
		title = title .. buffs .. "/32"
	elseif counter == "3" then
		title = title .. buffs
	end
	
	self.text:SetText(title)
end)

local function UpdateAnchorPoints()
	local point, relativeTo, relativePoint, xOfs, yOfs = BCT.Anchor:GetPoint()

	local wasDisabled =
		(BCT.session.db.window.anchor.point ~= "CENTER" or
		BCT.session.db.window.anchor.relativeTo ~= nil or
		BCT.session.db.window.anchor.relativePoint ~= "CENTER" or
		BCT.session.db.window.anchor.xOfs ~= 0 or
		BCT.session.db.window.anchor.yOfs ~= 0)

	local inDefaultPosition =
		(point == "CENTER" and
		relativeTo == UIParent and
		relativePoint == "CENTER" and
		tonumber(xOfs) == 0 and
		tonumber(yOfs) == 0)

	if not inDefaultPosition then
		BCT.session.db.window.anchor.point = point
		BCT.session.db.window.anchor.relativeTo = relativeTo
		BCT.session.db.window.anchor.relativePoint = relativePoint
		BCT.session.db.window.anchor.xOfs = tonumber(xOfs)
		BCT.session.db.window.anchor.yOfs = tonumber(yOfs)
	end

	if inDefaultPosition and wasDisabled then
		BCT.Anchor:ClearAllPoints()
		BCT.Anchor:SetPoint(
			BCT.session.db.window.anchor.point, 
			BCT.session.db.window.anchor.relativeTo, 
			BCT.session.db.window.anchor.relativePoint,
			BCT.session.db.window.anchor.xOfs, 
			BCT.session.db.window.anchor.yOfs
		)
		BCT.Anchor:SetUserPlaced(true)
	end

end

BCT.Window = CreateFrame("Frame","BCTTxtFrame",UIParent)
BCT.Window:SetWidth(200)
BCT.Window:SetHeight(35)
BCT.Window:SetAlpha(1.)
BCT.Window:SetPoint("CENTER", BCT.Anchor, "CENTER", 0, 0)
BCT.Window.text = BCT.Window:CreateFontString(nil,"ARTWORK") 
BCT.Window.text:SetFont(SM:Fetch("font","Expressway"), 13, "OUTLINE")
BCT.Window.text:SetPoint("TOPLEFT", BCT.Window, "BOTTOMLEFT", 0, 0)
BCT.Window.text:SetJustifyH("LEFT")
BCT.Window.text:SetText("Something is wrong")

local StringBuildTicker = C_Timer.NewTicker(0.1, function() 
	BCT.BuildBuffString()
	BCT.BuildEnchantString()
	BCT.BuildTrackedString()
	BCT.BuildNextFiveString()
	UpdateAnchorPoints()
end)

BCT.Window:SetScript("OnUpdate", function(self) 

	if BCT.session.db.window.text == nil then
		self.text:SetText("Something is wrong (ace)")
		return
	end

	local enchantsLine = (BCT.session.db.window.text["enchants"] and "ENCHANTS: " .. BCT.enchantsStr .. "/" .. BCT.enchantsTotal .. "\n" or "")
	local buffsLine = (BCT.session.db.window.text["buffs"] and "BUFFS: " .. BCT.buffStr .. "/" .. BCT.aurasMax .. "\n" or "")
	local nextLine = (BCT.session.db.window.text["nextone"] and "NEXT: " ..  BCT.nextAura .. "\n" or "")
	local trackedLine = (BCT.session.db.window.text["tracking"] and BCT.trackedStr .. "\n" or "")
	local profileLine = (BCT.session.db.window.text["profile"] and "PROFILE: |cff0080ff" .. BCT.profileStr .. "\n" ..  "|r" or "")

    local txt = (
		enchantsLine ..
        buffsLine ..
        nextLine ..
		trackedLine ..
		profileLine
	)
	
	self.text:SetText(txt)
end)