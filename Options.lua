local panel = CreateFrame("Frame", "BidItemPopupOptions", UIParent)
panel.name = "Bid Item Popup"
panel:Hide()

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Bid Item Popup")

local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
sub:SetText("Auction bid window. Slash: /biditem options")

local function Check(name, label, y, getter, setter)
  local cb = CreateFrame("CheckButton", name, panel, "InterfaceOptionsCheckButtonTemplate")
  cb:SetPoint("TOPLEFT", 16, y)
  _G[name .. "Text"]:SetText(label)
  cb:SetScript("OnClick", function(self)
    setter(self:GetChecked() and true or false)
    if BidItemPopup_ApplySettings then
      BidItemPopup_ApplySettings()
    end
  end)
  cb.Refresh = function(self)
    self:SetChecked(getter() and true or false)
  end
  return cb
end

local showAll = Check("BidItemPopupShowAllCheck", "Show items I cannot equip", -72, function()
  return BidItemPopupDB and BidItemPopupDB.showCannotEquip == true
end, function(v)
  BidItemPopupDB = BidItemPopupDB or {}
  BidItemPopupDB.showCannotEquip = v
end)

local flash = Check("BidItemPopupFlashCheck", "Flash when I am outbid", -104, function()
  return not BidItemPopupDB or BidItemPopupDB.flashOnOutbid ~= false
end, function(v)
  BidItemPopupDB = BidItemPopupDB or {}
  BidItemPopupDB.flashOnOutbid = v
end)

local sound = Check("BidItemPopupSoundCheck", "Sound when I am outbid", -136, function()
  return not BidItemPopupDB or BidItemPopupDB.playOutbidSound ~= false
end, function(v)
  BidItemPopupDB = BidItemPopupDB or {}
  BidItemPopupDB.playOutbidSound = v
end)

local hint = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
hint:SetPoint("TOPLEFT", 16, -182)
hint:SetJustifyH("LEFT")
hint:SetText("If the box is off, the window opens only for items you can equip.\nIf it is on, mail, plate and other unsuitable auctions open too.\nA raid \"-\" strikes through the current bid; a new number or all in makes it live again.")

panel.refresh = function()
  showAll:Refresh()
  flash:Refresh()
  sound:Refresh()
end

panel:SetScript("OnShow", panel.refresh)

InterfaceOptions_AddCategory(panel)

function BidItemPopup_OpenOptions()
  InterfaceOptionsFrame_OpenToCategory(panel)
  InterfaceOptionsFrame_OpenToCategory(panel)
end
