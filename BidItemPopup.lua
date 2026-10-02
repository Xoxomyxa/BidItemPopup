local ADDON = "BidItemPopup"

-- Auction subclass indexes from GetAuctionItemSubClasses (WotLK 3.3.5).
local W = {
  AXE1 = 1, AXE2 = 2, BOW = 3, GUN = 4,
  MACE1 = 5, MACE2 = 6, POLE = 7,
  SWORD1 = 8, SWORD2 = 9, STAFF = 10,
  FIST = 11, MISC = 12, DAGGER = 13,
  THROWN = 14, XBOW = 15, WAND = 16, FISH = 17,
}
local A = {
  MISC = 1, CLOTH = 2, LEATHER = 3, MAIL = 4, PLATE = 5,
  SHIELD = 6, LIBRAM = 7, IDOL = 8, TOTEM = 9, SIGIL = 10,
}

-- Slots every class can wear; armor subtype is ignored (cloaks are Cloth).
local FREE_SLOTS = {
  INVTYPE_NECK = true,
  INVTYPE_FINGER = true,
  INVTYPE_TRINKET = true,
  INVTYPE_CLOAK = true,
  INVTYPE_BODY = true,
  INVTYPE_TABARD = true,
  INVTYPE_BAG = true,
}

local CLASS_GEAR = {
  WARRIOR = {
    armor = { [A.MISC] = true, [A.CLOTH] = true, [A.LEATHER] = true, [A.MAIL] = true, [A.PLATE] = true, [A.SHIELD] = true },
    weapon = {
      [W.AXE1] = true, [W.AXE2] = true, [W.BOW] = true, [W.GUN] = true,
      [W.MACE1] = true, [W.MACE2] = true, [W.POLE] = true,
      [W.SWORD1] = true, [W.SWORD2] = true, [W.STAFF] = true, [W.FIST] = true,
      [W.MISC] = true, [W.DAGGER] = true, [W.THROWN] = true, [W.XBOW] = true, [W.FISH] = true,
    },
    holdable = false,
  },
  PALADIN = {
    armor = { [A.MISC] = true, [A.CLOTH] = true, [A.LEATHER] = true, [A.MAIL] = true, [A.PLATE] = true, [A.SHIELD] = true, [A.LIBRAM] = true },
    weapon = {
      [W.AXE1] = true, [W.AXE2] = true, [W.MACE1] = true, [W.MACE2] = true, [W.POLE] = true,
      [W.SWORD1] = true, [W.SWORD2] = true, [W.MISC] = true, [W.FISH] = true,
    },
    holdable = false,
  },
  HUNTER = {
    armor = { [A.MISC] = true, [A.CLOTH] = true, [A.LEATHER] = true, [A.MAIL] = true },
    weapon = {
      [W.AXE1] = true, [W.AXE2] = true, [W.BOW] = true, [W.GUN] = true, [W.POLE] = true,
      [W.SWORD1] = true, [W.SWORD2] = true, [W.STAFF] = true, [W.FIST] = true,
      [W.MISC] = true, [W.DAGGER] = true, [W.THROWN] = true, [W.XBOW] = true, [W.FISH] = true,
    },
    holdable = false,
  },
  ROGUE = {
    armor = { [A.MISC] = true, [A.CLOTH] = true, [A.LEATHER] = true },
    weapon = {
      [W.AXE1] = true, [W.BOW] = true, [W.GUN] = true, [W.MACE1] = true, [W.SWORD1] = true,
      [W.FIST] = true, [W.MISC] = true, [W.DAGGER] = true, [W.THROWN] = true, [W.XBOW] = true, [W.FISH] = true,
    },
    holdable = false,
  },
  PRIEST = {
    armor = { [A.MISC] = true, [A.CLOTH] = true },
    weapon = { [W.MACE1] = true, [W.STAFF] = true, [W.MISC] = true, [W.DAGGER] = true, [W.WAND] = true, [W.FISH] = true },
    holdable = true,
  },
  DEATHKNIGHT = {
    armor = { [A.MISC] = true, [A.CLOTH] = true, [A.LEATHER] = true, [A.MAIL] = true, [A.PLATE] = true, [A.SIGIL] = true },
    weapon = {
      [W.AXE1] = true, [W.AXE2] = true, [W.MACE1] = true, [W.MACE2] = true, [W.POLE] = true,
      [W.SWORD1] = true, [W.SWORD2] = true, [W.MISC] = true, [W.FISH] = true,
    },
    holdable = false,
  },
  SHAMAN = {
    armor = { [A.MISC] = true, [A.CLOTH] = true, [A.LEATHER] = true, [A.MAIL] = true, [A.SHIELD] = true, [A.TOTEM] = true },
    weapon = {
      [W.AXE1] = true, [W.AXE2] = true, [W.MACE1] = true, [W.MACE2] = true, [W.STAFF] = true,
      [W.FIST] = true, [W.MISC] = true, [W.DAGGER] = true, [W.FISH] = true,
    },
    holdable = false,
  },
  MAGE = {
    armor = { [A.MISC] = true, [A.CLOTH] = true },
    weapon = { [W.SWORD1] = true, [W.STAFF] = true, [W.MISC] = true, [W.DAGGER] = true, [W.WAND] = true, [W.FISH] = true },
    holdable = true,
  },
  WARLOCK = {
    armor = { [A.MISC] = true, [A.CLOTH] = true },
    weapon = { [W.SWORD1] = true, [W.STAFF] = true, [W.MISC] = true, [W.DAGGER] = true, [W.WAND] = true, [W.FISH] = true },
    holdable = true,
  },
  DRUID = {
    armor = { [A.MISC] = true, [A.CLOTH] = true, [A.LEATHER] = true, [A.IDOL] = true },
    weapon = {
      [W.MACE1] = true, [W.MACE2] = true, [W.POLE] = true, [W.STAFF] = true,
      [W.FIST] = true, [W.MISC] = true, [W.DAGGER] = true, [W.FISH] = true,
    },
    holdable = true,
  },
}

local function SubclassIndex(classIndex, subTypeName)
  if not subTypeName then
    return nil
  end
  local subs = { GetAuctionItemSubClasses(classIndex) }
  for i, name in ipairs(subs) do
    if name == subTypeName then
      return i
    end
  end
  return nil
end

local function AuctionClassIndex(itemType)
  if not itemType then
    return nil
  end
  local classes = { GetAuctionItemClasses() }
  for i, name in ipairs(classes) do
    if name == itemType then
      return i
    end
  end
  return nil
end

local scanner = CreateFrame("GameTooltip", "BidItemPopupScanner", nil, "GameTooltipTemplate")
scanner:SetOwner(UIParent, "ANCHOR_NONE")

local function AllowedByClassLine(itemLink)
  if not ITEM_CLASSES_ALLOWED or not itemLink then
    return nil
  end
  scanner:ClearLines()
  scanner:SetOwner(UIParent, "ANCHOR_NONE")
  scanner:SetHyperlink(itemLink)

  local pattern = ITEM_CLASSES_ALLOWED:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
  pattern = "^" .. pattern:gsub("%%%%s", "(.+)")

  local playerClass = UnitClass("player")
  for i = 1, scanner:NumLines() do
    local line = _G["BidItemPopupScannerTextLeft" .. i]
    local text = line and line:GetText()
    if text then
      local listed = text:match(pattern)
      if listed then
        for name in listed:gmatch("[^,/]+") do
          name = name:gsub("^%s+", ""):gsub("%s+$", "")
          if name == playerClass then
            return true
          end
        end
        return false
      end
    end
  end
  return nil
end

local function CanPlayerUseItem(itemLink)
  local name, _, _, _, _, itemType, itemSubType, _, equipLoc = GetItemInfo(itemLink)
  if not name then
    scanner:SetOwner(UIParent, "ANCHOR_NONE")
    scanner:SetHyperlink(itemLink)
    name, _, _, _, _, itemType, itemSubType, _, equipLoc = GetItemInfo(itemLink)
  end

  local classAllowed = AllowedByClassLine(itemLink)
  if classAllowed == false then
    return false
  end
  if not name then
    return true
  end

  local _, classToken = UnitClass("player")
  local spec = CLASS_GEAR[classToken]
  if not spec then
    return true
  end

  if equipLoc == "INVTYPE_HOLDABLE" then
    return spec.holdable
  end
  if equipLoc and FREE_SLOTS[equipLoc] then
    return true
  end

  local auctionClass = AuctionClassIndex(itemType)
  if auctionClass == 1 then
    local idx = SubclassIndex(1, itemSubType)
    if not idx then
      return true
    end
    return spec.weapon[idx] == true
  end
  if auctionClass == 2 then
    local idx = SubclassIndex(2, itemSubType)
    if not idx then
      return true
    end
    return spec.armor[idx] == true
  end

  return true
end

local TITLE_H = 32
local BTN_H = 24
local ROW_H = 30
local PAD = 16
local MIN_WIDTH = 340
local PLUS_W = 58
local PLUS_GAP = 4
local PLUS_AMOUNTS = { 10, 100, 300, 500, 1000 }
local LIST_ROW_H = 22
local LIST_FONT = 14
local LIST_FONT_LEAD = 17
local NAME_H = 22
local TOSS_H = 24
local TRADE_GOLD = 10 * 10000
local TOSS_NAMES = {
  "Mopoka", "Kacmopka", "Kykapeka", "Xoxomyxa", "Cupomka", "Bemka", "Tpecka",
}
local TOSS_LOOKUP = {}
for _, n in ipairs(TOSS_NAMES) do
  TOSS_LOOKUP[n] = true
end
local pendingTradeGold = false
local tradeWatch = false
local tradeMoneyAtShow = 0
local tradePartner = nil
local offeredCopper = 0
local settleTrade = false
local settleWait = 0
local bothAccepted = false
local tossTradeIntent = false
local pendingMailName = nil
local pendingMailCopper = 0
local goldTicker
local partnerPoll
local settleTicker

local currentBid
local currentBidder
local iHaveBid
local myOwnBid
local lastHref
local lastItemName
local lastItemQuality
local itemHidden = false
local uiMinimized = false
local bidOrder = {}
local bidByName = {}
local listRows = {}
local RelayoutKeepTop
local UpdateBidUI
local CancelCloseTimer
local StartCloseTimer
local RecalcLead
local CollectVisibleBids
local AlertOutbid

local function PlayerKey()
  return (GetRealmName() or "?") .. "-" .. (UnitName("player") or "?")
end

local function HasTossPaid()
  return BidItemPopupDB and BidItemPopupDB.tossPaid and BidItemPopupDB.tossPaid[PlayerKey()]
end

local function MarkTossPaid()
  BidItemPopupDB = BidItemPopupDB or {}
  BidItemPopupDB.tossPaid = BidItemPopupDB.tossPaid or {}
  BidItemPopupDB.tossPaid[PlayerKey()] = true
end

local function SendRaid(text)
  if GetNumRaidMembers() > 0 then
    SendChatMessage(text, "RAID")
  elseif GetNumPartyMembers() > 0 then
    SendChatMessage(text, "PARTY")
  else
    SendChatMessage(text, "SAY")
  end
end

local function ParseBidAmount(msg)
  if type(msg) ~= "string" then
    return nil
  end
  local n = tonumber(msg:match("^%s*(%d+)%s*$"))
  if n and n > 0 then
    return n
  end
  return nil
end

local function IsWithdrawMessage(msg)
  return type(msg) == "string" and msg:match("^%s*%-%s*$") ~= nil
end

local function IsAllInMessage(msg)
  if type(msg) ~= "string" then
    return false
  end
  local s = msg:gsub("^%s+", ""):gsub("%s+$", ""):lower():gsub("%s+", " ")
  return s == "all in" or s == "allin"
end

local function NormalizeName(name)
  if type(name) ~= "string" then
    return nil
  end
  name = name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
  name = name:match("([^%-]+)") or name
  return name
end

local function IsTossName(name)
  name = NormalizeName(name)
  return name and TOSS_LOOKUP[name] == true
end

local function MaybeMarkPaid(spent, partner)
  if HasTossPaid() then
    return
  end
  if not IsTossName(partner) then
    return
  end
  if not spent or spent < TRADE_GOLD then
    return
  end
  MarkTossPaid()
  if RelayoutKeepTop then
    RelayoutKeepTop()
  end
end

local function GetRaidClassFile(name)
  name = NormalizeName(name)
  if not name then
    return nil
  end
  local n = GetNumRaidMembers() or 0
  for i = 1, n do
    local rname, _, _, _, _, fileName = GetRaidRosterInfo(i)
    if NormalizeName(rname) == name then
      return fileName
    end
  end
  if NormalizeName(UnitName("player")) == name then
    local _, token = UnitClass("player")
    return token
  end
  return nil
end

local function ParseNet(note)
  if type(note) ~= "string" then
    return nil
  end
  return tonumber(note:match("[Nn]et:%s*(%d+)"))
end

local function GetGuildNetAndClass(name)
  name = NormalizeName(name)
  if not name then
    return nil, nil
  end
  local total = GetNumGuildMembers() or 0
  for i = 1, total do
    local gname, _, _, _, _, _, _, officernote, _, _, classFile = GetGuildRosterInfo(i)
    if NormalizeName(gname) == name then
      return ParseNet(officernote), classFile
    end
  end
  return nil, nil
end

local function ClassColor(fileName)
  local c = fileName and RAID_CLASS_COLORS and RAID_CLASS_COLORS[fileName]
  if c then
    return c.r, c.g, c.b
  end
  return 1, 1, 1
end

local function PlayerClassFile()
  local _, token = UnitClass("player")
  return token
end

local function ShowAllBids()
  return BidItemPopupDB and BidItemPopupDB.showAllBids == true
end

local function BidMatchesClassFilter(info)
  if ShowAllBids() then
    return true
  end
  local mine = PlayerClassFile()
  if not mine then
    return true
  end
  if not info or not info.classFile then
    return true
  end
  return info.classFile == mine
end

function CollectVisibleBids()
  local names = {}
  for _, name in ipairs(bidOrder) do
    local info = bidByName[name]
    if info and BidMatchesClassFilter(info) then
      names[#names + 1] = name
    end
  end
  return names
end

function RecalcLead()
  currentBid = nil
  currentBidder = nil
  for _, name in ipairs(bidOrder) do
    local info = bidByName[name]
    if info and not info.withdrawn and BidMatchesClassFilter(info) then
      if not currentBid or info.amount > currentBid then
        currentBid = info.amount
        currentBidder = name
      end
    end
  end
end

local function SavePosition(self)
  if not BidItemPopupDB or not self:GetLeft() or not self:GetTop() then
    return
  end
  local scale = self:GetEffectiveScale()
  BidItemPopupDB.x = self:GetLeft() * scale
  BidItemPopupDB.y = self:GetTop() * scale
end

local function RestorePosition(self)
  self:ClearAllPoints()
  if BidItemPopupDB and BidItemPopupDB.x and BidItemPopupDB.y then
    local scale = self:GetEffectiveScale()
    self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", BidItemPopupDB.x / scale, BidItemPopupDB.y / scale)
  else
    self:SetPoint("CENTER", UIParent, "CENTER", 220, 80)
  end
end

local FRAME_BACKDROP = {
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true,
  tileSize = 32,
  edgeSize = 32,
  insets = { left = 8, right = 8, top = 8, bottom = 8 },
}

local frame = CreateFrame("Frame", "BidItemPopupFrame", UIParent)
frame:SetFrameStrata("DIALOG")
frame:SetWidth(220)
frame:SetHeight(180)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetBackdrop(FRAME_BACKDROP)
frame:SetBackdropColor(0, 0, 0, 1)
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  ValidateFramePosition(self)
  SavePosition(self)
end)
frame:SetScript("OnHide", function()
  if CancelCloseTimer then
    CancelCloseTimer()
  end
  if flashFrame then
    flashFrame:Hide()
  end
end)
frame:Hide()

local flashFrame = CreateFrame("Frame", nil, frame)
flashFrame:SetAllPoints(frame)
flashFrame:EnableMouse(false)
flashFrame:Hide()
local flashTex = flashFrame:CreateTexture(nil, "OVERLAY")
flashTex:SetAllPoints()
flashTex:SetTexture("Interface\\Buttons\\WHITE8X8")
flashTex:SetVertexColor(1, 0.18, 0.05)
flashTex:SetAlpha(0.7)
local flashRemain = 0
flashFrame:SetScript("OnUpdate", function(self, elapsed)
  flashRemain = flashRemain - elapsed
  if flashRemain <= 0 then
    self:Hide()
    return
  end
  local a = 0.7 * (flashRemain / 0.45)
  if a < 0 then
    a = 0
  end
  flashTex:SetAlpha(a)
end)

function AlertOutbid()
  if not frame:IsShown() or uiMinimized then
    return
  end
  local flashOn = not BidItemPopupDB or BidItemPopupDB.flashOnOutbid ~= false
  local soundOn = not BidItemPopupDB or BidItemPopupDB.playOutbidSound ~= false
  if flashOn then
    flashFrame:SetFrameLevel(frame:GetFrameLevel() + 30)
    flashRemain = 0.45
    flashTex:SetAlpha(0.7)
    flashFrame:Show()
  end
  if soundOn then
    PlaySound("igQuestFailed")
  end
end

local title = frame:CreateFontString(nil, "OVERLAY")
title:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")
title:SetText("Now bidding")
title:SetTextColor(1, 1, 0.15)
title:SetShadowOffset(1, -1)
title:SetPoint("TOP", frame, "TOP", 0, -12)

local itemNameText = frame:CreateFontString(nil, "OVERLAY")
itemNameText:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
itemNameText:SetPoint("TOP", frame, "TOP", 0, -TITLE_H)
itemNameText:Hide()

local showItemBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
showItemBtn:SetWidth(48)
showItemBtn:SetHeight(20)
showItemBtn:SetText("item")
showItemBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
showItemBtn:SetFrameLevel(frame:GetFrameLevel() + 5)
showItemBtn:Hide()

local quietCloseBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
quietCloseBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 4, 4)
quietCloseBtn:SetFrameLevel(frame:GetFrameLevel() + 6)
quietCloseBtn:SetScript("OnClick", function()
  frame:Hide()
end)

local minBtn = CreateFrame("Button", nil, frame)
minBtn:SetWidth(20)
minBtn:SetHeight(20)
minBtn:SetFrameLevel(frame:GetFrameLevel() + 7)
minBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -2)
minBtn:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP")
minBtn:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-DOWN")
minBtn:SetHighlightTexture("Interface\\Buttons\\UI-MinusButton-Hilight")
minBtn:SetScript("OnClick", function()
  uiMinimized = not uiMinimized
  if uiMinimized then
    RelayoutKeepTop()
  else
    UpdateBidUI()
  end
end)

local tip = CreateFrame("GameTooltip", "BidItemPopupTip", frame, "GameTooltipTemplate")
tip:SetFrameLevel(frame:GetFrameLevel() + 2)
tip:EnableMouse(false)

local hideTipBtn = CreateFrame("Button", nil, tip)
hideTipBtn:SetWidth(24)
hideTipBtn:SetHeight(24)
hideTipBtn:SetPoint("TOPRIGHT", tip, "TOPRIGHT", 2, 2)
hideTipBtn:SetFrameLevel(tip:GetFrameLevel() + 5)
hideTipBtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-Minimize-Up")
hideTipBtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-Minimize-Down")
hideTipBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
if hideTipBtn:GetHighlightTexture() then
  hideTipBtn:GetHighlightTexture():SetBlendMode("ADD")
end

local noBidText = frame:CreateFontString(nil, "OVERLAY")
noBidText:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")
noBidText:SetText("No bids")
noBidText:SetTextColor(0.85, 0.85, 0.85)

local listHolder = CreateFrame("Frame", nil, frame)
listHolder:SetHeight(LIST_ROW_H)

local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
closeBtn:SetWidth(90)
closeBtn:SetHeight(BTN_H)
closeBtn:SetText("skip")
do
  local gray = 0.55
  local function Tint(tex)
    if tex and tex.SetVertexColor then
      tex:SetVertexColor(gray, gray, gray)
    end
  end
  Tint(closeBtn:GetNormalTexture())
  Tint(closeBtn:GetPushedTexture())
  Tint(closeBtn:GetDisabledTexture())
  Tint(closeBtn:GetHighlightTexture())
  for _, region in ipairs({ closeBtn:GetRegions() }) do
    if region:GetObjectType() == "Texture" then
      Tint(region)
    end
  end
  local fs = closeBtn:GetFontString()
  if fs then
    fs:SetTextColor(0.75, 0.75, 0.75)
  end
end
closeBtn:SetScript("OnClick", function()
  if iHaveBid then
    SendRaid("-")
  end
  frame:Hide()
end)

local tenBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
tenBtn:SetWidth(90)
tenBtn:SetHeight(BTN_H)
tenBtn:SetText("10")
tenBtn:SetScript("OnClick", function()
  local net = GetGuildNetAndClass(UnitName("player"))
  if net and 10 > net then
    return
  end
  iHaveBid = true
  myOwnBid = 10
  SendRaid("10")
  quietCloseBtn:Show()
end)

local plusButtons = {}
local plusRow = CreateFrame("Frame", nil, frame)
plusRow:SetHeight(ROW_H)

local tossBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
tossBtn:SetHeight(TOSS_H)
tossBtn:SetWidth(200)
tossBtn:SetText("Toss a coin to Mopoka")
do
  local fs = tossBtn:GetFontString()
  if fs then
    fs:SetTextColor(1, 0.85, 0.15)
  end
end

local function UnitForTossName(name)
  if NormalizeName(UnitName("player")) == name then
    return nil
  end
  local n = GetNumRaidMembers() or 0
  for i = 1, n do
    if NormalizeName(GetRaidRosterInfo(i)) == name then
      return "raid" .. i
    end
  end
  local p = GetNumPartyMembers() or 0
  for i = 1, p do
    if NormalizeName(UnitName("party" .. i)) == name then
      return "party" .. i
    end
  end
  if UnitExists("target") and NormalizeName(UnitName("target")) == name then
    return "target"
  end
  return nil
end

local function FindTossUnitInRange()
  for _, name in ipairs(TOSS_NAMES) do
    local unit = UnitForTossName(name)
    if unit and CheckInteractDistance(unit, 2) then
      return unit
    end
  end
  return nil
end

local function GetTradePartnerName()
  local label = _G["TradeFrameRecipientNameText"]
  if label and label.GetText then
    local n = NormalizeName(label:GetText())
    if n and n ~= "" then
      return n
    end
  end
  local npc = NormalizeName(UnitName("NPC"))
  if npc and npc ~= "" then
    return npc
  end
  if UnitExists("target") then
    local t = NormalizeName(UnitName("target"))
    if IsTossName(t) then
      return t
    end
  end
  return nil
end

local function SnapshotTrade()
  local p = GetTradePartnerName()
  if p then
    tradePartner = p
  end
  if GetPlayerTradeMoney then
    local m = tonumber(GetPlayerTradeMoney()) or 0
    if m > (offeredCopper or 0) then
      offeredCopper = m
    end
  end
end

local function ClearTradeSession()
  tradeWatch = false
  settleTrade = false
  settleWait = 0
  pendingTradeGold = false
  tossTradeIntent = false
  bothAccepted = false
  tradePartner = nil
  tradeMoneyAtShow = 0
  offeredCopper = 0
  if goldTicker then
    goldTicker:Hide()
  end
  if partnerPoll then
    partnerPoll:Hide()
  end
  if settleTicker then
    settleTicker:Hide()
  end
end

local function TrySettleTrade()
  if not settleTrade then
    return false
  end
  local spent = (tradeMoneyAtShow or 0) - (GetMoney() or 0)
  if spent < TRADE_GOLD and bothAccepted and (offeredCopper or 0) >= TRADE_GOLD then
    spent = offeredCopper
  end
  local partner = tradePartner
  if spent >= TRADE_GOLD and (IsTossName(partner) or tossTradeIntent) then
    MaybeMarkPaid(spent, IsTossName(partner) and partner or "Mopoka")
    ClearTradeSession()
    return true
  end
  return false
end

local function PutTradeGold()
  if SetTradeMoney then
    SetTradeMoney(TRADE_GOLD)
  end
  if MoneyInputFrame_SetCopper and TradePlayerInputMoneyFrame then
    MoneyInputFrame_SetCopper(TradePlayerInputMoneyFrame, TRADE_GOLD)
  end
  local goldBox = _G["TradePlayerInputMoneyFrameGold"]
  if goldBox and goldBox.SetText then
    goldBox:SetText("10")
    if _G["TradePlayerInputMoneyFrameSilver"] then
      _G["TradePlayerInputMoneyFrameSilver"]:SetText("0")
    end
    if _G["TradePlayerInputMoneyFrameCopper"] then
      _G["TradePlayerInputMoneyFrameCopper"]:SetText("0")
    end
  end
end

local goldWait = 0
goldTicker = CreateFrame("Frame")
goldTicker:Hide()
goldTicker:SetScript("OnUpdate", function(self, elapsed)
  if tradeWatch then
    SnapshotTrade()
  end
  goldWait = goldWait - elapsed
  if pendingTradeGold then
    PutTradeGold()
  end
  if goldWait <= 0 then
    pendingTradeGold = false
    self:Hide()
  end
end)

partnerPoll = CreateFrame("Frame")
partnerPoll:Hide()
partnerPoll:SetScript("OnUpdate", function(self)
  if not tradeWatch then
    self:Hide()
    return
  end
  SnapshotTrade()
end)

settleTicker = CreateFrame("Frame")
settleTicker:Hide()
settleTicker:SetScript("OnUpdate", function(self, elapsed)
  if TradeFrame and TradeFrame:IsShown() then
    SnapshotTrade()
    return
  end
  settleWait = settleWait - elapsed
  if settleWait <= 1.6 then
    TrySettleTrade()
  end
  if settleWait <= 0 then
    ClearTradeSession()
  end
end)

tossBtn:SetScript("OnClick", function()
  local unit = FindTossUnitInRange()
  if unit then
    pendingTradeGold = true
    tossTradeIntent = true
    tradePartner = NormalizeName(UnitName(unit))
    InitiateTrade(unit)
    return
  end
  local info = ChatTypeInfo and ChatTypeInfo["SYSTEM"]
  local r, g, b = 1, 1, 0
  if info then
    r, g, b = info.r, info.g, info.b
  end
  DEFAULT_CHAT_FRAME:AddMessage(
    "Отправь 10 золотых почтой или в трейд персонажу Mopoka в благодарность за этот удобный аддончик, и будет тебе счастье :)",
    r, g, b
  )
end)

local function EnsureListRow(i)
  local row = listRows[i]
  if row then
    return row
  end
  row = CreateFrame("Frame", nil, listHolder)
  row:SetHeight(LIST_ROW_H)
  local nameFS = row:CreateFontString(nil, "OVERLAY")
  nameFS:SetFont(STANDARD_TEXT_FONT, LIST_FONT, "OUTLINE")
  nameFS:SetJustifyH("LEFT")
  nameFS:SetPoint("LEFT", row, "LEFT", 6, 0)
  nameFS:SetPoint("RIGHT", row, "CENTER", -20, 0)
  local bidFS = row:CreateFontString(nil, "OVERLAY")
  bidFS:SetFont(STANDARD_TEXT_FONT, LIST_FONT, "OUTLINE")
  bidFS:SetJustifyH("CENTER")
  bidFS:SetTextColor(1, 1, 0.15)
  bidFS:SetPoint("CENTER", row, "CENTER", 24, 0)
  local netFS = row:CreateFontString(nil, "OVERLAY")
  netFS:SetFont(STANDARD_TEXT_FONT, LIST_FONT, "OUTLINE")
  netFS:SetJustifyH("RIGHT")
  netFS:SetTextColor(0.75, 0.75, 0.75)
  netFS:SetPoint("RIGHT", row, "RIGHT", -6, 0)
  row.nameFS = nameFS
  row.bidFS = bidFS
  row.netFS = netFS
  local strikeHolder = CreateFrame("Frame", nil, row)
  strikeHolder:SetFrameLevel(row:GetFrameLevel() + 5)
  strikeHolder:EnableMouse(false)
  local strike = strikeHolder:CreateTexture(nil, "OVERLAY")
  strike:SetTexture("Interface\\Buttons\\WHITE8X8")
  strike:SetVertexColor(0.95, 0.95, 0.95)
  strike:SetHeight(2)
  strike:Hide()
  row.strikeHolder = strikeHolder
  row.strike = strike
  listRows[i] = row
  return row
end

local function Layout()
  local tw = MIN_WIDTH
  local th = 0
  local headerH = TITLE_H
  if uiMinimized then
    title:Hide()
    tip:Hide()
    hideTipBtn:Hide()
    showItemBtn:Hide()
    closeBtn:Hide()
    tenBtn:Hide()
    plusRow:Hide()
    listHolder:Hide()
    noBidText:Hide()
    tossBtn:Hide()
    frame:SetBackdrop(FRAME_BACKDROP)
    frame:SetBackdropColor(0, 0, 0, 1)
    minBtn:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP")
    minBtn:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-DOWN")
    minBtn:ClearAllPoints()
    quietCloseBtn:Show()
    minBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -2)
    if lastItemName then
      itemNameText:SetText(lastItemName)
      local q = lastItemQuality or 1
      local c = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[q]
      if c then
        itemNameText:SetTextColor(c.r, c.g, c.b)
      else
        itemNameText:SetTextColor(1, 1, 1)
      end
      itemNameText:Show()
      itemNameText:ClearAllPoints()
      itemNameText:SetPoint("LEFT", frame, "LEFT", 20, 0)
      itemNameText:SetPoint("RIGHT", minBtn, "LEFT", -4, 0)
      itemNameText:SetJustifyH("CENTER")
    else
      itemNameText:Hide()
    end
    local compactW = MIN_WIDTH
    if frame:GetWidth() and frame:GetWidth() >= MIN_WIDTH then
      compactW = frame:GetWidth()
    end
    frame:SetWidth(compactW)
    frame:SetHeight(44)
    return
  end

  closeBtn:Show()
  plusRow:Show()
  listHolder:Show()
  if HasTossPaid() then
    tossBtn:Hide()
  else
    tossBtn:Show()
  end
  itemNameText:ClearAllPoints()
  itemNameText:SetPoint("TOP", frame, "TOP", 0, -TITLE_H)
  itemNameText:SetJustifyH("CENTER")

  title:Show()
  frame:SetBackdrop(FRAME_BACKDROP)
  frame:SetBackdropColor(0, 0, 0, 1)
  minBtn:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP")
  minBtn:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-DOWN")
  if not itemHidden then
      if lastHref then
        tip:SetOwner(frame, "ANCHOR_NONE")
        tip:SetHyperlink(lastHref)
      end
      tip:ClearAllPoints()
      tip:SetPoint("TOP", frame, "TOP", 0, -TITLE_H)
      tip:Show()
      tw = tip:GetWidth() or 200
      th = tip:GetHeight() or 80
      itemNameText:Hide()
      hideTipBtn:Show()
      showItemBtn:Hide()
    else
      th = NAME_H
      if lastItemName then
        itemNameText:SetText(lastItemName)
        local q = lastItemQuality or 1
        local c = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[q]
        if c then
          itemNameText:SetTextColor(c.r, c.g, c.b)
        else
          itemNameText:SetTextColor(1, 1, 1)
        end
        itemNameText:Show()
      else
        itemNameText:Hide()
      end
      tip:Hide()
      hideTipBtn:Hide()
      showItemBtn:Show()
      showItemBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -52, -10)
      if frame:GetWidth() and frame:GetWidth() > 1 then
        tw = frame:GetWidth() - 24
      end
    end
  local width = tw + 24
  if width < MIN_WIDTH then
    width = MIN_WIDTH
  end
  local vis = CollectVisibleBids()
  local n = #vis
  local listH = LIST_ROW_H
  if n > 0 then
    listH = n * LIST_ROW_H
  end
  local tossSpace = 0
  if not HasTossPaid() then
    tossSpace = TOSS_H + 8
  end
  local footerH = ROW_H + ROW_H + PAD + listH + 8 + tossSpace
  frame:SetWidth(width)
  frame:SetHeight(headerH + th + footerH)
  tip:ClearAllPoints()
  tip:SetPoint("TOP", frame, "TOP", 0, -TITLE_H)

  minBtn:ClearAllPoints()
  minBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -2)

  local buttonsY = headerH + th + 4
  closeBtn:ClearAllPoints()
  closeBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -buttonsY)
  tenBtn:ClearAllPoints()
  tenBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -18, -buttonsY)

  plusRow:ClearAllPoints()
  plusRow:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -(buttonsY + ROW_H))
  plusRow:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -(buttonsY + ROW_H))
  plusRow:SetHeight(ROW_H)
  local rowW = plusRow:GetWidth()
  if not rowW or rowW < 1 then
    rowW = width - 32
  end
  local total = (#PLUS_AMOUNTS * PLUS_W) + ((#PLUS_AMOUNTS - 1) * PLUS_GAP)
  local x = (rowW - total) / 2
  for i, btn in ipairs(plusButtons) do
    btn:ClearAllPoints()
    btn:SetPoint("LEFT", plusRow, "LEFT", x + (i - 1) * (PLUS_W + PLUS_GAP), 0)
  end

  listHolder:ClearAllPoints()
  listHolder:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -(buttonsY + ROW_H + ROW_H))
  listHolder:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -(buttonsY + ROW_H + ROW_H))
  listHolder:SetHeight(listH)

  noBidText:ClearAllPoints()
  noBidText:SetPoint("TOP", listHolder, "TOP", 0, 0)

  for i = 1, math.max(n, #listRows) do
    local row = listRows[i]
    if row then
      if i <= n then
        row:Show()
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", listHolder, "TOPLEFT", 0, -((i - 1) * LIST_ROW_H))
        row:SetPoint("TOPRIGHT", listHolder, "TOPRIGHT", 0, -((i - 1) * LIST_ROW_H))
      else
        row:Hide()
      end
    end
  end

  tossBtn:ClearAllPoints()
  tossBtn:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
end

function RelayoutKeepTop()
  local left, top
  if frame:GetLeft() and frame:GetTop() then
    left = frame:GetLeft()
    top = frame:GetTop()
  end
  Layout()
  if left and top then
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
  else
    RestorePosition(frame)
  end
end

hideTipBtn:SetScript("OnClick", function()
  itemHidden = true
  RelayoutKeepTop()
end)

showItemBtn:SetScript("OnClick", function()
  itemHidden = false
  if lastHref then
    tip:SetOwner(frame, "ANCHOR_NONE")
    tip:SetHyperlink(lastHref)
  end
  RelayoutKeepTop()
end)

function UpdateBidUI()
  RecalcLead()
  local vis = CollectVisibleBids()
  local n = #vis
  if n > 0 then
    noBidText:Hide()
  else
    noBidText:Show()
  end
  if currentBid then
    for _, btn in ipairs(plusButtons) do
      btn:Show()
    end
  else
    for _, btn in ipairs(plusButtons) do
      btn:Hide()
    end
  end
  if not myOwnBid or myOwnBid <= 10 then
    tenBtn:Show()
  else
    tenBtn:Hide()
  end
  quietCloseBtn:Show()

  for i = 1, n do
    local name = vis[i]
    local info = bidByName[name]
    local row = EnsureListRow(i)
    local withdrawn = info and info.withdrawn
    local isLead = info and not withdrawn and currentBidder == name
    row.nameFS:SetFont(STANDARD_TEXT_FONT, LIST_FONT, "OUTLINE")
    row.netFS:SetFont(STANDARD_TEXT_FONT, LIST_FONT, "OUTLINE")
    if isLead then
      row.bidFS:SetFont(STANDARD_TEXT_FONT, LIST_FONT_LEAD, "OUTLINE")
    else
      row.bidFS:SetFont(STANDARD_TEXT_FONT, LIST_FONT, "OUTLINE")
    end
    row.nameFS:SetText(name)
    local r, g, b = ClassColor(info.classFile)
    row.nameFS:SetTextColor(r, g, b)
    row.bidFS:SetText(tostring(info.amount))
    if info.net then
      row.netFS:SetText(tostring(info.net))
    else
      row.netFS:SetText("-")
    end
    row.netFS:SetTextColor(0.75, 0.75, 0.75)
    if withdrawn then
      row.bidFS:SetTextColor(0.75, 0.75, 0.75)
      if row.strike then
        local w = row.bidFS:GetStringWidth() or 20
        if w < 8 then
          w = 8
        end
        row.strike:ClearAllPoints()
        row.strike:SetWidth(w + 2)
        row.strike:SetHeight(2)
        row.strike:SetPoint("CENTER", row.bidFS, "CENTER", 0, 0)
        if row.strikeHolder then
          row.strikeHolder:SetFrameLevel(row:GetFrameLevel() + 5)
        end
        row.strike:Show()
      end
    else
      row.bidFS:SetTextColor(1, 1, 0.15)
      if row.strike then
        row.strike:Hide()
      end
    end
  end
  RelayoutKeepTop()
end

function BidItemPopup_ApplySettings()
  RecalcLead()
  if frame:IsShown() then
    UpdateBidUI()
  end
end

local function ResetAuction()
  currentBid = nil
  currentBidder = nil
  iHaveBid = false
  myOwnBid = nil
  itemHidden = false
  wipe(bidOrder)
  wipe(bidByName)
  if GuildRoster then
    GuildRoster()
  end
  UpdateBidUI()
end

local function WithdrawBid(sender)
  local name = NormalizeName(sender)
  if not name then
    return
  end
  local prev = bidByName[name]
  if not prev then
    return
  end
  prev.withdrawn = true
  if name == NormalizeName(UnitName("player")) then
    iHaveBid = false
    myOwnBid = nil
  end
  RecalcLead()
  UpdateBidUI()
end

local function RegisterBid(amount, sender)
  if not amount then
    return
  end
  local name = NormalizeName(sender)
  if not name then
    return
  end
  local net, guildClass = GetGuildNetAndClass(name)
  if net and amount > net then
    return
  end
  local classFile = GetRaidClassFile(name) or guildClass
  local me = NormalizeName(UnitName("player"))
  local wasMyLead = currentBidder == me and myOwnBid and currentBid
  local prev = bidByName[name]
  if prev then
    if not prev.withdrawn and amount <= prev.amount then
      return
    end
    prev.amount = amount
    prev.net = net or prev.net
    prev.classFile = classFile or prev.classFile
    prev.withdrawn = false
  else
    bidOrder[#bidOrder + 1] = name
    bidByName[name] = {
      amount = amount,
      net = net,
      classFile = classFile,
      withdrawn = false,
    }
  end
  RecalcLead()
  if name == me then
    iHaveBid = true
    myOwnBid = amount
  end
  if wasMyLead and currentBidder and currentBidder ~= me and name ~= me then
    AlertOutbid()
  end
  UpdateBidUI()
end

for i, inc in ipairs(PLUS_AMOUNTS) do
  local add = inc
  local btn = CreateFrame("Button", nil, plusRow, "UIPanelButtonTemplate")
  btn:SetWidth(PLUS_W)
  btn:SetHeight(BTN_H)
  btn:SetText("+" .. add)
  btn:SetScript("OnClick", function()
    if not currentBid then
      return
    end
    local nextBid = currentBid + add
    local net = GetGuildNetAndClass(UnitName("player"))
    if net and nextBid > net then
      return
    end
    iHaveBid = true
    myOwnBid = nextBid
    SendRaid(tostring(nextBid))
    quietCloseBtn:Show()
    UpdateBidUI()
  end)
  btn:Hide()
  plusButtons[i] = btn
end

local function ShowItemWindow(href, full)
  if not href then
    return false
  end
  local itemLink = full or ("|H" .. href .. "|h[item]|h")
  if not CanPlayerUseItem(itemLink) then
    return false
  end

  ResetAuction()
  CancelCloseTimer()
  lastHref = href
  lastItemName = nil
  lastItemQuality = nil
  local iname, _, iquality = GetItemInfo(itemLink)
  if iname then
    lastItemName = iname
    lastItemQuality = iquality
  end
  itemHidden = false
  uiMinimized = false
  frame:Show()
  RestorePosition(frame)
  tip:SetOwner(frame, "ANCHOR_NONE")
  tip:SetHyperlink(href)
  tip:Show()
  if not lastItemName then
    local line = _G["BidItemPopupTipTextLeft1"]
    local t = line and line:GetText()
    if t and t ~= "" then
      lastItemName = t
    end
  end
  Layout()
  RestorePosition(frame)
  UpdateBidUI()
  return true
end

local function IsBidAnnounce(msg)
  if type(msg) ~= "string" then
    return false
  end
  if msg:find("Bidding for", 1, true) then
    if msg:find("started", 1, true) or msg:find("bets", 1, true) then
      return true
    end
  end
  return false
end

local function IsWinAnnounce(msg)
  if type(msg) ~= "string" then
    return false
  end
  if not msg:find(" won ", 1, true) then
    return false
  end
  if msg:match("with%s+%d+%s+DKP") then
    return true
  end
  return false
end

local closeRemain = nil
local closeTicker = CreateFrame("Frame")
closeTicker:Hide()
closeTicker:SetScript("OnUpdate", function(self, elapsed)
  if not closeRemain then
    self:Hide()
    return
  end
  closeRemain = closeRemain - elapsed
  if closeRemain <= 0 then
    closeRemain = nil
    self:Hide()
    frame:Hide()
  end
end)

function CancelCloseTimer()
  closeRemain = nil
  closeTicker:Hide()
end

function StartCloseTimer(sec)
  closeRemain = sec or 5
  closeTicker:Show()
end

local function ExtractItemLink(msg)
  local full = msg:match("|c%x+|Hitem:.-|h%[.-%]|h|r")
  if not full then
    full = msg:match("|Hitem:.-|h%[.-%]|h")
  end
  if not full then
    return nil, nil
  end
  local href = full:match("|H(item:[^|]+)|h")
  return href, full
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_RAID_WARNING")
eventFrame:RegisterEvent("CHAT_MSG_RAID")
eventFrame:RegisterEvent("CHAT_MSG_RAID_LEADER")
eventFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
eventFrame:RegisterEvent("TRADE_SHOW")
eventFrame:RegisterEvent("TRADE_CLOSED")
eventFrame:RegisterEvent("TRADE_UPDATE")
eventFrame:RegisterEvent("TRADE_ACCEPT_UPDATE")
eventFrame:RegisterEvent("PLAYER_MONEY")
eventFrame:RegisterEvent("MAIL_SEND_SUCCESS")
eventFrame:RegisterEvent("MAIL_FAILED")
eventFrame:SetScript("OnEvent", function(_, event, arg1, arg2)
  if event == "ADDON_LOADED" then
    if arg1 == ADDON then
      BidItemPopupDB = BidItemPopupDB or {}
      BidItemPopupDB.tossPaid = BidItemPopupDB.tossPaid or {}
      if BidItemPopupDB.showAllBids == nil then
        BidItemPopupDB.showAllBids = false
      end
      if BidItemPopupDB.playOutbidSound == nil then
        BidItemPopupDB.playOutbidSound = true
      end
      if BidItemPopupDB.flashOnOutbid == nil then
        BidItemPopupDB.flashOnOutbid = true
      end
      if GuildRoster then
        GuildRoster()
      end
    end
    return
  end
  if event == "TRADE_SHOW" then
    settleTrade = false
    if settleTicker then
      settleTicker:Hide()
    end
    tradeWatch = true
    offeredCopper = 0
    bothAccepted = false
    tradeMoneyAtShow = GetMoney() or 0
    SnapshotTrade()
    partnerPoll:Show()
    if pendingTradeGold then
      PutTradeGold()
      goldWait = 0.3
      goldTicker:Show()
    end
    return
  end
  if event == "TRADE_UPDATE" then
    if tradeWatch then
      SnapshotTrade()
    end
    return
  end
  if event == "TRADE_ACCEPT_UPDATE" then
    if tradeWatch then
      SnapshotTrade()
      if tonumber(arg1) == 1 and tonumber(arg2) == 1 then
        bothAccepted = true
      end
    end
    return
  end
  if event == "PLAYER_MONEY" then
    if tradeWatch or settleTrade then
      SnapshotTrade()
    end
    return
  end
  if event == "TRADE_CLOSED" then
    pendingTradeGold = false
    goldTicker:Hide()
    SnapshotTrade()
    if tradeWatch then
      settleTrade = true
      settleWait = 2.0
      settleTicker:Show()
    end
    return
  end
  if event == "MAIL_SEND_SUCCESS" then
    MaybeMarkPaid(pendingMailCopper, pendingMailName)
    pendingMailName = nil
    pendingMailCopper = 0
    return
  end
  if event == "MAIL_FAILED" then
    pendingMailName = nil
    pendingMailCopper = 0
    return
  end
  if event == "GUILD_ROSTER_UPDATE" then
    if frame:IsShown() and #bidOrder > 0 then
      for _, name in ipairs(bidOrder) do
        local info = bidByName[name]
        if info then
          local net, classFile = GetGuildNetAndClass(name)
          info.net = net or info.net
          info.classFile = info.classFile or classFile
        end
      end
      UpdateBidUI()
    end
    return
  end
  if IsBidAnnounce(arg1) then
    local href, full = ExtractItemLink(arg1)
    if href then
      ShowItemWindow(href, full)
    end
    return
  end
  if not frame:IsShown() then
    return
  end
  if IsWinAnnounce(arg1) then
    StartCloseTimer(5)
    return
  end
  if event ~= "CHAT_MSG_RAID" and event ~= "CHAT_MSG_RAID_LEADER" then
    return
  end
  if IsWithdrawMessage(arg1) then
    WithdrawBid(arg2)
    return
  end
  local amount
  if IsAllInMessage(arg1) then
    local net = GetGuildNetAndClass(arg2)
    if net and net > 0 then
      amount = net
    end
  else
    amount = ParseBidAmount(arg1)
  end
  if amount then
    RegisterBid(amount, arg2)
  end
end)

SLASH_BIDITEMPOPUP1 = "/biditem"
SlashCmdList.BIDITEMPOPUP = function(msg)
  msg = msg and msg:gsub("^%s+", ""):gsub("%s+$", "")
  if msg == "" then
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00" .. ADDON .. "|r: окно бида. Перетащи мышкой — позиция запомнится.")
    DEFAULT_CHAT_FRAME:AddMessage("Настройки: /biditem options")
    DEFAULT_CHAT_FRAME:AddMessage("Проверка: /biditem и Shift-клик по вещи")
    return
  end
  if msg == "options" or msg == "opt" or msg == "config" then
    if BidItemPopup_OpenOptions then
      BidItemPopup_OpenOptions()
    end
    return
  end
  local href, full = ExtractItemLink(msg)
  if not href then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000" .. ADDON .. "|r: нет ссылки на предмет. Shift-клик по вещи после /biditem")
    return
  end
  if not ShowItemWindow(href, full) then
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00" .. ADDON .. "|r: этот предмет твой класс не может надеть — окно не показываю.")
  end
end

if hooksecurefunc then
  if SetSendMailMoney then
    hooksecurefunc("SetSendMailMoney", function(copper)
      pendingMailCopper = copper or 0
    end)
  end
  hooksecurefunc("SendMail", function(recipient)
    pendingMailName = NormalizeName(recipient)
    if GetSendMailMoney then
      local attached = GetSendMailMoney()
      if attached and attached > 0 then
        pendingMailCopper = attached
      end
    end
    if GetSendMailCOD and GetSendMailCOD() > 0 and (not pendingMailCopper or pendingMailCopper == 0) then
      pendingMailCopper = 0
    end
  end)
end
