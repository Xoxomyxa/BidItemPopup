local ADDON = "BidItemPopup"

SLASH_BIDITEMPOPUP1 = "/biditem"
SlashCmdList["BIDITEMPOPUP"] = function(msg)
  if BidItemPopup_OnSlash then
    return BidItemPopup_OnSlash(msg)
  end
  DEFAULT_CHAT_FRAME:AddMessage("|cffff0000" .. ADDON .. "|r: файл оборвался при загрузке, окно открыть нечем.")
end
if hash_SlashCmdList then
  hash_SlashCmdList["/BIDITEM"] = SlashCmdList["BIDITEMPOPUP"]
end

local scanner = CreateFrame("GameTooltip", "BidItemPopupScanner", nil, "GameTooltipTemplate")
scanner:SetOwner(UIParent, "ANCHOR_NONE")

local function CanPlayerUseItem(itemLink)
  local name, _, _, _, _, _, _, _, equipLoc = GetItemInfo(itemLink)
  if not name then
    return true
  end
  if not IsEquippableItem(itemLink) then
    if not equipLoc or equipLoc == "" then
      return true
    end
    return false
  end
  scanner:SetOwner(UIParent, "ANCHOR_NONE")
  scanner:ClearLines()
  scanner:SetHyperlink(itemLink)
  local tipName = scanner:GetName()
  local levelPrefix
  if type(ITEM_MIN_LEVEL) == "string" then
    levelPrefix = ITEM_MIN_LEVEL:match("^(.-)%%d")
  end
  local usable = true
  local lines = scanner:NumLines() or 0
  for i = 2, lines do
    local right = _G[tipName .. "TextRight" .. i]
    local rightText = right and right:GetText()
    if rightText and rightText ~= "" then
      local r, g, b = right:GetTextColor()
      if r and r > 0.85 and g < 0.25 and b < 0.25 then
        usable = false
        break
      end
    end
    local left = _G[tipName .. "TextLeft" .. i]
    local leftText = left and left:GetText()
    if leftText and leftText ~= "" then
      local skipLevel = levelPrefix and levelPrefix ~= "" and leftText:sub(1, #levelPrefix) == levelPrefix
      if not skipLevel then
        local r, g, b = left:GetTextColor()
        if r and r > 0.85 and g < 0.25 and b < 0.25 then
          usable = false
          break
        end
      end
    end
  end
  scanner:Hide()
  if lines < 2 then
    return true
  end
  return usable
end

local TITLE_H = 32
local BTN_H = 24
local ROW_H = 30
local PAD = 16
local MIN_WIDTH = 340
local PLUS_W = 58
local PLUS_GAP = 4
local PLUS_AMOUNTS = { 10, 100, 500, 1000 }
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
local cmp = {
  on = false,
  slots = 0,
  known = false,
  pad = 0,
  rows = {},
  lineText = {},
  laidTipH = 0,
}
local uiMinimized = false
local bidOrder = {}
local bidByName = {}
local listRows = {}

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

local guildByName = {}
local guildCacheBuilt = false

local function RebuildGuildCache()
  wipe(guildByName)
  local total = GetNumGuildMembers() or 0
  for i = 1, total do
    local gname, _, _, _, _, _, _, officernote, _, _, classFile = GetGuildRosterInfo(i)
    local name = NormalizeName(gname)
    if name then
      guildByName[name] = {
        net = ParseNet(officernote),
        classFile = classFile,
      }
    end
  end
  guildCacheBuilt = true
end

local function GetGuildNetAndClass(name)
  name = NormalizeName(name)
  if not name then
    return nil, nil
  end
  if not guildCacheBuilt then
    RebuildGuildCache()
  end
  local info = guildByName[name]
  if not info then
    return nil, nil
  end
  return info.net, info.classFile
end

local function ClassColor(fileName)
  local c = fileName and RAID_CLASS_COLORS and RAID_CLASS_COLORS[fileName]
  if c then
    return c.r, c.g, c.b
  end
  return 1, 1, 1
end

local function ShowAllBids()
  return BidItemPopupDB and BidItemPopupDB.showCannotEquip == true
end

function CollectVisibleBids()
  local names = {}
  for _, name in ipairs(bidOrder) do
    if bidByName[name] then
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
    if info and not info.withdrawn then
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

local compareBtn = CreateFrame("Button", nil, tip, "UIPanelButtonTemplate")
compareBtn:SetWidth(78)
compareBtn:SetHeight(20)
compareBtn:SetText("compare")
compareBtn:SetFrameLevel(tip:GetFrameLevel() + 6)
compareBtn:Hide()
compareBtn:SetScript("OnClick", function()
  cmp.on = not cmp.on
  compareBtn:SetText(cmp.on and "item" or "compare")
  RelayoutKeepTop()
end)

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
local roundBtn

local function RoundBidPlace(amount)
  amount = math.floor((amount or 0) + 0.5)
  if amount < 1 then
    return amount
  end
  local step = 1
  local n = amount
  while n >= 10 do
    n = math.floor(n / 10)
    step = step * 10
  end
  if step < 100 then
    step = 100
  end
  local rem = amount % step
  if rem == 0 then
    return amount
  end
  return amount + (step - rem)
end
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

local partnerPollAcc = 0
partnerPoll = CreateFrame("Frame")
partnerPoll:Hide()
partnerPoll:SetScript("OnUpdate", function(self, elapsed)
  if not tradeWatch then
    self:Hide()
    return
  end
  partnerPollAcc = partnerPollAcc + elapsed
  if partnerPollAcc < 0.25 then
    return
  end
  partnerPollAcc = 0
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
  row.leadFont = false
  listRows[i] = row
  return row
end

local CLASS_SHORT = {
  WARRIOR = "War",
  PALADIN = "Pal",
  HUNTER = "Hunt",
  ROGUE = "Rog",
  PRIEST = "Priest",
  DEATHKNIGHT = "DK",
  SHAMAN = "Sham",
  MAGE = "Mage",
  WARLOCK = "Lock",
  DRUID = "Dru",
}

local SPEC_NAME = {
  WARRIOR = { [1] = "Arms", [2] = "Fury", [3] = "Prot" },
  PALADIN = { [1] = "Holy", [2] = "Prot", [3] = "Ret" },
  HUNTER = { [1] = "Bm", [2] = "Mm", [3] = "Surv" },
  ROGUE = { [1] = "Assa", [2] = "Combat", [3] = "Sub" },
  PRIEST = { [1] = "Disc", [2] = "Holy", [3] = "Shadow" },
  DEATHKNIGHT = { [2] = "Frost", [3] = "Unholy" },
  SHAMAN = { [1] = "Elem", [2] = "Enh", [3] = "Restor" },
  MAGE = { [1] = "Arcane", [2] = "Fire", [3] = "Frost" },
  WARLOCK = { [1] = "Affli", [2] = "Demo", [3] = "Destro" },
  DRUID = { [1] = "Balance", [3] = "Restor" },
}

local CLASS_ORDER = {
  "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
  "DEATHKNIGHT", "SHAMAN", "MAGE", "WARLOCK", "DRUID",
}

local SPEC_KEY_ORDER = {
  WARRIOR = { 1, 2, 3 },
  PALADIN = { 1, 2, 3 },
  HUNTER = { 1, 2, 3 },
  ROGUE = { 1, 2, 3 },
  PRIEST = { 1, 2, 3 },
  DEATHKNIGHT = { 1, "blood_dps", 2, 3 },
  SHAMAN = { 1, 2, 3 },
  MAGE = { 1, 2, 3 },
  WARLOCK = { 1, 2, 3 },
  DRUID = { 1, "feral_tank", 2, 3 },
}

local BASE_ARMOR_LOC = {
  INVTYPE_HEAD = true,
  INVTYPE_SHOULDER = true,
  INVTYPE_CHEST = true,
  INVTYPE_ROBE = true,
  INVTYPE_WAIST = true,
  INVTYPE_LEGS = true,
  INVTYPE_FEET = true,
  INVTYPE_WRIST = true,
  INVTYPE_HAND = true,
  INVTYPE_CLOAK = true,
  INVTYPE_SHIELD = true,
}

local BIS_R, BIS_G, BIS_B = 1, 0.82, 0
local PRIO_R, PRIO_G, PRIO_B = 0.1, 1, 0.1
local SPEC_LINE_H = 16
local MAX_STAT_TRIES = 8

local playerClass
local playerSpecKeys = {}
local specsReady = false
local bisIndex
local statsCacheLink
local statsCache
local statTries = 0
local statAcc = 0

local statWait = CreateFrame("Frame")
statWait:Hide()

local specHolder = CreateFrame("Frame", nil, frame)
specHolder:SetWidth(480)
specHolder:SetHeight(SPEC_LINE_H)
specHolder:Hide()

local specLineFS = {}
for i = 1, 3 do
  local fs = specHolder:CreateFontString(nil, "OVERLAY")
  fs:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
  fs:SetJustifyH("CENTER")
  fs:SetWordWrap(false)
  fs:SetWidth(480)
  fs:Hide()
  specLineFS[i] = fs
end

local bisOwnerFS = specHolder:CreateFontString(nil, "OVERLAY")
bisOwnerFS:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
bisOwnerFS:SetJustifyH("CENTER")
bisOwnerFS:SetWordWrap(true)
bisOwnerFS:SetTextColor(0.62, 0.62, 0.62)
bisOwnerFS:Hide()

local function HideSpecLines()
  specHolder:Hide()
  for i = 1, 3 do
    specLineFS[i]:Hide()
  end
  bisOwnerFS:Hide()
end

local function ItemIdFromLink(link)
  if type(link) ~= "string" then
    return nil
  end
  return tonumber(link:match("item:(%d+)"))
end

local function EnsureBISIndex()
  if bisIndex then
    return
  end
  bisIndex = {}
  if type(BidItemPopupBIS) ~= "table" then
    return
  end
  for classToken, specs in pairs(BidItemPopupBIS) do
    local byKey = {}
    bisIndex[classToken] = byKey
    for key, ids in pairs(specs) do
      local set = {}
      byKey[key] = set
      if type(ids) == "table" then
        for n = 1, #ids do
          set[ids[n]] = true
        end
      end
    end
  end
end

local function IsSpecBIS(classToken, key, itemId)
  EnsureBISIndex()
  local byKey = bisIndex[classToken]
  local set = byKey and byKey[key]
  return set ~= nil and set[itemId] == true
end

local function HasBaseArmor(link)
  local _, _, _, _, _, _, _, _, equipLoc = GetItemInfo(link)
  return equipLoc ~= nil and BASE_ARMOR_LOC[equipLoc] == true
end

local function StatPositive(stats, key)
  local value = stats and stats[key]
  return type(value) == "number" and value > 0
end

local function SlotClosed(slot, stats, armor)
  if type(slot) == "table" then
    for n = 1, #slot do
      local name = slot[n]
      if name == "ARMOR" then
        if armor then
          return true
        end
      elseif StatPositive(stats, name) then
        return true
      end
    end
    return false
  end
  if slot == "ARMOR" then
    return armor
  end
  return StatPositive(stats, slot)
end

local function IsSpecPrio(classToken, key, stats, armor)
  local classTbl = BidItemPopupStats and BidItemPopupStats[classToken]
  local slots = classTbl and classTbl[key]
  if type(slots) ~= "table" or #slots < 3 then
    return false
  end
  for n = 1, 3 do
    if not SlotClosed(slots[n], stats, armor) then
      return false
    end
  end
  return true
end

local function KeysForTab(classToken, tab)
  if classToken == "DEATHKNIGHT" and tab == 1 then
    return { 1, "blood_dps" }
  end
  if classToken == "DRUID" and tab == 2 then
    return { "feral_tank", 2 }
  end
  return { tab }
end

local function RefreshPlayerSpecs()
  specsReady = true
  playerSpecKeys = {}
  local _, classToken = UnitClass("player")
  playerClass = classToken
  if not classToken or not GetTalentTabInfo or not GetNumTalentTabs then
    return
  end
  local active = 1
  if GetActiveTalentGroup then
    active = GetActiveTalentGroup() or 1
  end
  local groups = { active }
  if GetNumTalentGroups and GetNumTalentGroups() == 2 then
    if active == 1 then
      groups[2] = 2
    else
      groups[2] = 1
    end
  end
  local seen = {}
  local nTabs = GetNumTalentTabs() or 0
  for g = 1, #groups do
    local group = groups[g]
    local bestTab = nil
    local bestPts = -1
    for tab = 1, nTabs do
      local _, _, pts = GetTalentTabInfo(tab, false, false, group)
      pts = pts or 0
      if pts > bestPts then
        bestPts = pts
        bestTab = tab
      end
    end
    if bestTab then
      local keys = KeysForTab(classToken, bestTab)
      for n = 1, #keys do
        local key = keys[n]
        if not seen[key] then
          seen[key] = true
          playerSpecKeys[#playerSpecKeys + 1] = key
        end
      end
    end
  end
end

local function SpecTag(classToken, key)
  local short = CLASS_SHORT[classToken] or ""
  if classToken == "DEATHKNIGHT" and key == 1 then
    return "blood DK tank"
  end
  if classToken == "DEATHKNIGHT" and key == "blood_dps" then
    return "blood DK"
  end
  if classToken == "DRUID" and key == "feral_tank" then
    return "Dru bear"
  end
  if classToken == "DRUID" and key == 2 then
    return "Dru cat"
  end
  local names = SPEC_NAME[classToken]
  local spec = names and names[key] or ""
  return spec .. " " .. short:lower()
end

local function SpecLineText(kind, classToken, key)
  local body = kind .. " " .. SpecTag(classToken, key)
  if kind == "BIS" then
    return ">> " .. body .. " <<"
  end
  return "> " .. body .. " <"
end

local bisOwners

local function EnsureBISOwners()
  if bisOwners then
    return
  end
  bisOwners = {}
  if type(BidItemPopupBIS) ~= "table" then
    return
  end
  local seen = {}
  for ci = 1, #CLASS_ORDER do
    local classToken = CLASS_ORDER[ci]
    local specs = BidItemPopupBIS[classToken]
    local keys = SPEC_KEY_ORDER[classToken]
    if type(specs) == "table" and keys then
      for ki = 1, #keys do
        local key = keys[ki]
        local ids = specs[key]
        if type(ids) == "table" then
          local tag = SpecTag(classToken, key)
          local token = classToken .. ":" .. tostring(key)
          for n = 1, #ids do
            local id = ids[n]
            local mark = seen[id]
            if not mark then
              mark = {}
              seen[id] = mark
            end
            if not mark[token] then
              mark[token] = true
              local list = bisOwners[id]
              if not list then
                list = {}
                bisOwners[id] = list
              end
              list[#list + 1] = { tag = tag, classToken = classToken }
            end
          end
        end
      end
    end
  end
end

local function BISOwnerLine(link)
  local itemId = ItemIdFromLink(link)
  if not itemId then
    return nil
  end
  EnsureBISOwners()
  local list = bisOwners[itemId]
  if not list or #list == 0 then
    return nil
  end
  local classes = {}
  local classCount = 0
  for i = 1, #list do
    local classToken = list[i].classToken
    if classToken and not classes[classToken] then
      classes[classToken] = true
      classCount = classCount + 1
    end
  end
  if classCount < 2 then
    return nil
  end
  local parts = {}
  for i = 1, #list do
    parts[#parts + 1] = list[i].tag
  end
  return "BIS: " .. table.concat(parts, ", ")
end

local function CurrentItemStats(link)
  if statsCacheLink ~= link then
    statsCacheLink = link
    statsCache = nil
    statTries = 0
    statAcc = 0
    statWait:Hide()
  end
  if statsCache then
    return statsCache
  end
  local stats = BidItemPopup_ReadCanonicalStats(scanner, link)
  if stats then
    statsCache = stats
    statWait:Hide()
    return stats
  end
  if statTries < MAX_STAT_TRIES then
    statWait:Show()
  end
  return nil
end

statWait:SetScript("OnUpdate", function(self, elapsed)
  statAcc = statAcc + elapsed
  if statAcc < 0.2 then
    return
  end
  statAcc = 0
  local link = statsCacheLink
  if not link or statTries >= MAX_STAT_TRIES then
    self:Hide()
    return
  end
  statTries = statTries + 1
  local stats = BidItemPopup_ReadCanonicalStats(scanner, link)
  if stats then
    statsCache = stats
    self:Hide()
    if frame:IsShown() then
      RelayoutKeepTop()
    end
  elseif statTries >= MAX_STAT_TRIES then
    self:Hide()
  end
end)

local function SpecRowsForItem(link)
  if not specsReady then
    RefreshPlayerSpecs()
  end
  if not link or not playerClass then
    return {}
  end
  if not CanPlayerUseItem(link) then
    return {
      {
        text = "Can not be equipped",
        r = 1,
        g = 0.25,
        b = 0.25,
      },
    }
  end
  local itemId = ItemIdFromLink(link)
  if not itemId then
    return {}
  end
  local stats = CurrentItemStats(link)
  local armor = false
  if stats then
    armor = HasBaseArmor(link)
  end
  local rows = {}
  for n = 1, #playerSpecKeys do
    local key = playerSpecKeys[n]
    local kind = nil
    if IsSpecBIS(playerClass, key, itemId) then
      kind = "BIS"
    elseif stats and CanPlayerUseItem(link) and IsSpecPrio(playerClass, key, stats, armor) then
      kind = "Prio"
    end
    if kind then
      local r, g, b = PRIO_R, PRIO_G, PRIO_B
      if kind == "BIS" then
        r, g, b = BIS_R, BIS_G, BIS_B
      end
      rows[#rows + 1] = {
        text = SpecLineText(kind, playerClass, key),
        r = r,
        g = g,
        b = b,
      }
    end
  end
  return rows
end

local function PaintSpecLines(rows, anchor, relPoint, y)
  local owner = BISOwnerLine(lastHref)
  local n = rows and #rows or 0
  if n == 0 and not owner then
    HideSpecLines()
    return 0
  end
  specHolder:SetFrameLevel(tip:GetFrameLevel() + 5)
  specHolder:ClearAllPoints()
  specHolder:SetPoint("TOP", anchor, relPoint, 0, y)
  specHolder:Show()
  for i = 1, 3 do
    local fs = specLineFS[i]
    local row = rows and rows[i]
    if row then
      fs:ClearAllPoints()
      fs:SetPoint("TOP", specHolder, "TOP", 0, -(i - 1) * SPEC_LINE_H)
      fs:SetText(row.text)
      fs:SetTextColor(row.r, row.g, row.b)
      fs:Show()
    else
      fs:Hide()
    end
  end
  local used = n * SPEC_LINE_H
  if owner then
    local gap = n > 0 and 2 or 0
    local width = MIN_WIDTH
    if tip:IsShown() then
      local tipW = (tip:GetWidth() or 0) + 24
      if tipW > width then
        width = tipW
      end
    elseif frame:GetWidth() and frame:GetWidth() > width then
      width = frame:GetWidth()
    end
    bisOwnerFS:ClearAllPoints()
    bisOwnerFS:SetWidth(width - 36)
    bisOwnerFS:SetPoint("TOP", specHolder, "TOP", 0, -(used + gap))
    bisOwnerFS:SetText(owner)
    bisOwnerFS:Show()
    local textH = bisOwnerFS:GetStringHeight() or 12
    if textH < 12 then
      textH = 12
    end
    used = used + gap + textH
  else
    bisOwnerFS:Hide()
  end
  specHolder:SetHeight(used)
  return used
end

local function TipBoxHeight(t)
  local h = t:GetHeight() or 0
  if t:GetTop() and t:GetBottom() then
    local boxH = t:GetTop() - t:GetBottom()
    if boxH > h then
      h = boxH
    end
  end
  return h
end

local EQUIP_SLOTS = {
  INVTYPE_HEAD = { "HeadSlot" },
  INVTYPE_NECK = { "NeckSlot" },
  INVTYPE_SHOULDER = { "ShoulderSlot" },
  INVTYPE_CLOAK = { "BackSlot" },
  INVTYPE_CHEST = { "ChestSlot" },
  INVTYPE_ROBE = { "ChestSlot" },
  INVTYPE_WRIST = { "WristSlot" },
  INVTYPE_HAND = { "HandsSlot" },
  INVTYPE_WAIST = { "WaistSlot" },
  INVTYPE_LEGS = { "LegsSlot" },
  INVTYPE_FEET = { "FeetSlot" },
  INVTYPE_FINGER = { "Finger0Slot", "Finger1Slot" },
  INVTYPE_TRINKET = { "Trinket0Slot", "Trinket1Slot" },
  INVTYPE_WEAPON = { "MainHandSlot", "SecondaryHandSlot" },
  INVTYPE_WEAPONMAINHAND = { "MainHandSlot" },
  INVTYPE_WEAPONOFFHAND = { "SecondaryHandSlot" },
  INVTYPE_2HWEAPON = { "MainHandSlot" },
  INVTYPE_SHIELD = { "SecondaryHandSlot" },
  INVTYPE_HOLDABLE = { "SecondaryHandSlot" },
  INVTYPE_RANGED = { "RangedSlot" },
  INVTYPE_RANGEDRIGHT = { "RangedSlot" },
  INVTYPE_THROWN = { "RangedSlot" },
  INVTYPE_RELIC = { "RangedSlot" },
}

local STAT_ORDER = {
  "ARMOR",
  "DPS",
  "ITEM_MOD_STRENGTH_SHORT",
  "ITEM_MOD_AGILITY_SHORT",
  "ITEM_MOD_STAMINA_SHORT",
  "ITEM_MOD_INTELLECT_SHORT",
  "ITEM_MOD_SPIRIT_SHORT",
  "ITEM_MOD_HEALTH_SHORT",
  "ITEM_MOD_MANA_SHORT",
  "ITEM_MOD_ATTACK_POWER_SHORT",
  "ITEM_MOD_RANGED_ATTACK_POWER_SHORT",
  "ITEM_MOD_SPELL_POWER_SHORT",
  "ITEM_MOD_SPELL_DAMAGE_DONE_SHORT",
  "ITEM_MOD_SPELL_HEALING_DONE_SHORT",
  "ITEM_MOD_HIT_RATING_SHORT",
  "ITEM_MOD_HIT_MELEE_RATING_SHORT",
  "ITEM_MOD_HIT_RANGED_RATING_SHORT",
  "ITEM_MOD_HIT_SPELL_RATING_SHORT",
  "ITEM_MOD_CRIT_RATING_SHORT",
  "ITEM_MOD_CRIT_MELEE_RATING_SHORT",
  "ITEM_MOD_CRIT_RANGED_RATING_SHORT",
  "ITEM_MOD_CRIT_SPELL_RATING_SHORT",
  "ITEM_MOD_HASTE_RATING_SHORT",
  "ITEM_MOD_HASTE_MELEE_RATING_SHORT",
  "ITEM_MOD_HASTE_RANGED_RATING_SHORT",
  "ITEM_MOD_HASTE_SPELL_RATING_SHORT",
  "ITEM_MOD_EXPERTISE_RATING_SHORT",
  "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
  "ITEM_MOD_SPELL_PENETRATION_SHORT",
  "ITEM_MOD_DEFENSE_SKILL_RATING_SHORT",
  "ITEM_MOD_DODGE_RATING_SHORT",
  "ITEM_MOD_PARRY_RATING_SHORT",
  "ITEM_MOD_BLOCK_RATING_SHORT",
  "ITEM_MOD_BLOCK_VALUE_SHORT",
  "ITEM_MOD_RESILIENCE_RATING_SHORT",
  "ITEM_MOD_MANA_REGENERATION_SHORT",
  "ITEM_MOD_HEALTH_REGENERATION_SHORT",
  "ITEM_MOD_FIRE_RESISTANCE_SHORT",
  "ITEM_MOD_NATURE_RESISTANCE_SHORT",
  "ITEM_MOD_FROST_RESISTANCE_SHORT",
  "ITEM_MOD_SHADOW_RESISTANCE_SHORT",
  "ITEM_MOD_ARCANE_RESISTANCE_SHORT",
}
local STAT_RANK = {}
for i = 1, #STAT_ORDER do
  STAT_RANK[STAT_ORDER[i]] = i
end

local statMapCache = {}
local statMapTries = {}
local ARMOR_PATTERN
local DPS_PATTERN

local function PatternEscape(s)
  return (s:gsub("([%(%)%.%+%-%*%?%[%]%^%$])", "%%%1"))
end

local function NumberCapture(fmt)
  if type(fmt) ~= "string" then
    return nil
  end
  local token = fmt:match("%%%.%d*f") or fmt:match("%%d")
  if not token then
    return nil
  end
  local startAt, endAt = fmt:find(token, 1, true)
  if not startAt then
    return nil
  end
  return PatternEscape(fmt:sub(1, startAt - 1)) .. "([%d%.,]+)" .. PatternEscape(fmt:sub(endAt + 1))
end

local function EnsureTipPatterns()
  if not ARMOR_PATTERN and type(RESISTANCE0_NAME) == "string" then
    ARMOR_PATTERN = "^(%d+)%s+" .. PatternEscape(RESISTANCE0_NAME) .. "%s*$"
  end
  if not DPS_PATTERN and type(DPS_TEMPLATE) == "string" then
    DPS_PATTERN = NumberCapture(DPS_TEMPLATE)
  end
end

local function FullItemLink(href)
  if not href then
    return nil
  end
  if href:find("|H", 1, true) then
    return href
  end
  return "|H" .. href .. "|h[item]|h"
end

local function SafeGetItemInfo(link)
  if type(link) == "number" then
    return GetItemInfo(link)
  end
  if type(link) ~= "string" or link == "" then
    return nil
  end
  local id = tonumber(link:match("item:(%d+)"))
  if id then
    return GetItemInfo(id)
  end
  local ok, name, itemLink, quality, ilvl, req, itemType, subType, stack, equipLoc, texture = pcall(GetItemInfo, link)
  if not ok then
    return nil
  end
  return name, itemLink, quality, ilvl, req, itemType, subType, stack, equipLoc, texture
end

local function NakedItemString(link)
  local body = link and link:match("(item:[%-0-9:]+)")
  if not body then
    return link
  end
  local fields = { strsplit(":", body) }
  if fields[3] then
    fields[3] = "0"
  end
  if fields[4] then
    fields[4] = "0"
  end
  if fields[5] then
    fields[5] = "0"
  end
  if fields[6] then
    fields[6] = "0"
  end
  if fields[7] then
    fields[7] = "0"
  end
  return table.concat(fields, ":")
end

local function ParseTipNumber(text)
  if not text then
    return nil
  end
  text = text:gsub(",", ".")
  return tonumber(text)
end

local function ReadArmorAndDps(link)
  EnsureTipPatterns()
  scanner:SetOwner(UIParent, "ANCHOR_NONE")
  scanner:ClearLines()
  scanner:SetHyperlink(link)
  local armor, dps
  local name = scanner:GetName()
  for i = 2, scanner:NumLines() do
    local fs = _G[name .. "TextLeft" .. i]
    local text = fs and fs:GetText()
    if text and text ~= "" then
      text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
      if not armor and ARMOR_PATTERN then
        armor = tonumber(text:match(ARMOR_PATTERN))
      end
      if not dps and DPS_PATTERN then
        dps = ParseTipNumber(text:match(DPS_PATTERN))
      end
    end
  end
  scanner:Hide()
  return armor, dps
end

local function StatMap(link)
  if not link then
    return {}
  end
  local naked = NakedItemString(link)
  local cached = statMapCache[naked]
  if cached then
    return cached
  end
  SafeGetItemInfo(naked)
  local okStats, stats = pcall(GetItemStats, naked)
  if not okStats then
    stats = nil
  end
  if not stats then
    scanner:SetOwner(UIParent, "ANCHOR_NONE")
    scanner:SetHyperlink(naked)
    okStats, stats = pcall(GetItemStats, naked)
    if not okStats then
      stats = nil
    end
    scanner:Hide()
  end
  if not stats then
    local tries = (statMapTries[naked] or 0) + 1
    statMapTries[naked] = tries
    if tries >= 4 then
      statMapCache[naked] = {}
    end
    return {}
  end
  local map = {}
  local armorFromStats
  for key, value in pairs(stats) do
    local armorKey = key == "ARMOR" or key == "RESISTANCE0_NAME" or key == "ITEM_MOD_ARMOR_SHORT"
    if not armorKey and type(RESISTANCE0_NAME) == "string" then
      armorKey = key == RESISTANCE0_NAME or _G[key] == RESISTANCE0_NAME
    end
    if armorKey then
      if not armorFromStats then
        armorFromStats = value
      end
    else
      map[key] = value
    end
  end
  local armor, dps = ReadArmorAndDps(naked)
  if armor and armor > 0 then
    map.ARMOR = armor
  elseif armorFromStats and armorFromStats > 0 then
    map.ARMOR = armorFromStats
  end
  if dps and dps > 0 then
    map.DPS = dps
  end
  local _, _, _, _, _, _, _, _, equipLoc = SafeGetItemInfo(naked)
  local tries = (statMapTries[naked] or 0) + 1
  statMapTries[naked] = tries
  if not (equipLoc and BASE_ARMOR_LOC[equipLoc] and not map.ARMOR and tries < 4) then
    statMapCache[naked] = map
  end
  return map
end

local function DeltaAgainst(newMap, oldMap)
  local delta = {}
  local seen = {}
  local function add(key)
    if seen[key] then
      return
    end
    seen[key] = true
    local value = (newMap[key] or 0) - (oldMap[key] or 0)
    if math.abs(value) >= 0.05 then
      delta[key] = value
    end
  end
  for key in pairs(newMap) do
    add(key)
  end
  for key in pairs(oldMap) do
    add(key)
  end
  return delta
end

local function OrderedDeltaKeys(columns)
  local have = {}
  for c = 1, #columns do
    for key in pairs(columns[c]) do
      have[key] = true
    end
  end
  local keys = {}
  for key in pairs(have) do
    keys[#keys + 1] = key
  end
  table.sort(keys, function(a, b)
    local ra = STAT_RANK[a] or 1000
    local rb = STAT_RANK[b] or 1000
    if ra ~= rb then
      return ra < rb
    end
    return a < b
  end)
  return keys
end

local STAT_SHORT = {
  ARMOR = "Armor",
  ITEM_MOD_STRENGTH_SHORT = "Str",
  ITEM_MOD_AGILITY_SHORT = "Agi",
  ITEM_MOD_STAMINA_SHORT = "Stam",
  ITEM_MOD_INTELLECT_SHORT = "Int",
  ITEM_MOD_SPIRIT_SHORT = "Spi",
  ITEM_MOD_HEALTH_SHORT = "Health",
  ITEM_MOD_MANA_SHORT = "Mana",
  ITEM_MOD_ATTACK_POWER_SHORT = "AP",
  ITEM_MOD_RANGED_ATTACK_POWER_SHORT = "RAP",
  ITEM_MOD_SPELL_POWER_SHORT = "SP",
  ITEM_MOD_SPELL_DAMAGE_DONE_SHORT = "Spell Dmg",
  ITEM_MOD_SPELL_HEALING_DONE_SHORT = "Healing",
  ITEM_MOD_HIT_RATING_SHORT = "Hit",
  ITEM_MOD_HIT_MELEE_RATING_SHORT = "Melee Hit",
  ITEM_MOD_HIT_RANGED_RATING_SHORT = "Ranged Hit",
  ITEM_MOD_HIT_SPELL_RATING_SHORT = "Spell Hit",
  ITEM_MOD_CRIT_RATING_SHORT = "Crit",
  ITEM_MOD_CRIT_MELEE_RATING_SHORT = "Melee Crit",
  ITEM_MOD_CRIT_RANGED_RATING_SHORT = "Ranged Crit",
  ITEM_MOD_CRIT_SPELL_RATING_SHORT = "Spell Crit",
  ITEM_MOD_HASTE_RATING_SHORT = "Haste",
  ITEM_MOD_HASTE_MELEE_RATING_SHORT = "Melee Haste",
  ITEM_MOD_HASTE_RANGED_RATING_SHORT = "Ranged Haste",
  ITEM_MOD_HASTE_SPELL_RATING_SHORT = "Spell Haste",
  ITEM_MOD_EXPERTISE_RATING_SHORT = "Exp",
  ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT = "ArP",
  ITEM_MOD_SPELL_PENETRATION_SHORT = "Spell Pen",
  ITEM_MOD_DEFENSE_SKILL_RATING_SHORT = "Def",
  ITEM_MOD_DODGE_RATING_SHORT = "Dodge",
  ITEM_MOD_PARRY_RATING_SHORT = "Parry",
  ITEM_MOD_BLOCK_RATING_SHORT = "Block",
  ITEM_MOD_BLOCK_VALUE_SHORT = "BV",
  ITEM_MOD_RESILIENCE_RATING_SHORT = "Resil",
  ITEM_MOD_MANA_REGENERATION_SHORT = "Mp5",
  ITEM_MOD_HEALTH_REGENERATION_SHORT = "Hp5",
  ITEM_MOD_FIRE_RESISTANCE_SHORT = "Fire",
  ITEM_MOD_NATURE_RESISTANCE_SHORT = "Nature",
  ITEM_MOD_FROST_RESISTANCE_SHORT = "Frost",
  ITEM_MOD_SHADOW_RESISTANCE_SHORT = "Shadow",
  ITEM_MOD_ARCANE_RESISTANCE_SHORT = "Arcane",
  EMPTY_SOCKET_META = "Meta",
  EMPTY_SOCKET_RED = "Red",
  EMPTY_SOCKET_YELLOW = "Yellow",
  EMPTY_SOCKET_BLUE = "Blue",
  EMPTY_SOCKET_NO_COLOR = "Prism",
  EMPTY_SOCKET_PRISMATIC = "Prism",
}

local SOCKET_ICON = {
  EMPTY_SOCKET_META = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Meta",
  EMPTY_SOCKET_RED = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Red",
  EMPTY_SOCKET_YELLOW = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Yellow",
  EMPTY_SOCKET_BLUE = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Blue",
  EMPTY_SOCKET_NO_COLOR = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic",
  EMPTY_SOCKET_PRISMATIC = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic",
}

local function DeltaText(delta, key, short)
  if not delta or math.abs(delta) < 0.05 then
    return nil
  end
  local label
  if short and STAT_SHORT[key] then
    label = STAT_SHORT[key]
  elseif key == "ARMOR" then
    label = RESISTANCE0_NAME or "Armor"
  elseif key == "DPS" then
    label = "DPS"
  else
    label = _G[key] or key
  end
  local icon = SOCKET_ICON[key]
  if icon then
    label = "|T" .. icon .. ":14|t " .. label
  end
  local shown
  if key == "DPS" then
    shown = string.format("%.1f", delta)
  else
    if delta > 0 then
      shown = tostring(math.floor(delta + 0.5))
    else
      shown = tostring(math.ceil(delta - 0.5))
    end
  end
  if delta > 0 and shown:sub(1, 1) ~= "+" then
    shown = "+" .. shown
  end
  local r, g, b = 1, 0, 0
  if delta > 0 then
    r, g, b = 0, 1, 0
  end
  return shown .. " " .. label, r, g, b
end

local function ItemIdentity(link)
  if type(link) ~= "string" then
    return nil
  end
  local body = link:match("item:[%-0-9:]+")
  if not body then
    return nil
  end
  local fields = {strsplit(":", body)}
  local id = fields[2]
  if not id or id == "" then
    return nil
  end
  local suffix = fields[8]
  if not suffix or suffix == "" then
    suffix = "0"
  end
  local parts = {id, suffix}
  for i = 11, #fields do
    local value = fields[i]
    if value and value ~= "" and value ~= "0" then
      parts[#parts + 1] = value
    end
  end
  return table.concat(parts, ":")
end

local function FilledSlotLinks(equipLoc)
  local slots = equipLoc and EQUIP_SLOTS[equipLoc]
  local links = {}
  if not slots then
    return links
  end
  for i = 1, #slots do
    local slotId = GetInventorySlotInfo(slots[i])
    local equipped = slotId and GetInventoryItemLink("player", slotId)
    if equipped then
      links[#links + 1] = equipped
    end
  end
  return links
end

local function RefreshCompareSlots()
  if cmp.checkedHref ~= lastHref then
    cmp.checkedHref = lastHref
    cmp.on = false
    cmp.known = false
    cmp.slots = 0
  end
  if cmp.known then
    return cmp.slots
  end
  local name, _, _, _, _, _, _, _, equipLoc = SafeGetItemInfo(lastHref)
  if not name then
    return 0
  end
  cmp.known = true
  local links = FilledSlotLinks(equipLoc)
  local want = ItemIdentity(lastHref)
  cmp.slots = 0
  for i = 1, #links do
    if ItemIdentity(links[i]) ~= want then
      cmp.slots = #links
      break
    end
  end
  return cmp.slots
end

cmp.name = tip:CreateFontString(nil, "OVERLAY", "GameTooltipHeaderText")
cmp.name:SetJustifyH("LEFT")
cmp.name:Hide()

cmp.vs = tip:CreateFontString(nil, "OVERLAY", "GameTooltipText")
cmp.vs:SetJustifyH("LEFT")
cmp.vs:SetWordWrap(false)
cmp.vs:SetText("vs")
cmp.vs:SetTextColor(1, 1, 1)
cmp.vs:Hide()

cmp.equip = tip:CreateFontString(nil, "OVERLAY", "GameTooltipText")
cmp.equip:SetJustifyH("LEFT")
cmp.equip:SetWordWrap(false)
cmp.equip:Hide()

cmp.equipRight = tip:CreateFontString(nil, "OVERLAY", "GameTooltipText")
cmp.equipRight:SetJustifyH("RIGHT")
cmp.equipRight:SetWordWrap(false)
cmp.equipRight:Hide()

local function CompareRow(i)
  local row = cmp.rows[i]
  if row then
    return row
  end
  row = {}
  row.left = tip:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  row.left:SetJustifyH("LEFT")
  row.left:SetWordWrap(false)
  row.right = tip:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  row.right:SetJustifyH("RIGHT")
  row.right:SetWordWrap(false)
  cmp.rows[i] = row
  return row
end

cmp.iconGuard = CreateFrame("Frame")
cmp.iconGuard:Hide()
cmp.iconGuard:SetScript("OnUpdate", function()
  if cmp.on and tip:IsShown() then
    SetExtraIconsShown(false)
  end
end)

local ApplyTipMode

function HideCompareOverlay()
  cmp.iconGuard:Hide()
  cmp.name:Hide()
  cmp.vs:Hide()
  cmp.equip:Hide()
  cmp.equipRight:Hide()
  for i = 1, #cmp.rows do
    cmp.rows[i].left:Hide()
    cmp.rows[i].right:Hide()
  end
  if cmp.pad > 0 and lastHref then
    cmp.pad = 0
    cmp.shownHref = nil
    ApplyTipMode()
  end
end

local function StripInlineTextures(text)
  if not text then
    return ""
  end
  text = text:gsub("\124", "|")
  return (text:gsub("|T.-|t", ""))
end

function SetExtraIconsShown(show)
  for i = 1, 10 do
    local tex = _G["BidItemPopupTipTexture" .. i]
    if tex then
      if show then
        if tex.bidSaved ~= nil then
          tex:SetTexture(tex.bidSaved)
          tex.bidSaved = nil
        end
        tex:SetAlpha(1)
        if tex.bidWasShown then
          tex:Show()
        end
        tex.bidWasShown = nil
      else
        if tex.bidWasShown == nil then
          tex.bidWasShown = tex:IsShown() and true or false
        end
        if tex.bidSaved == nil then
          local path = tex:GetTexture()
          if path then
            tex.bidSaved = path
          end
        end
        tex:SetAlpha(0)
        tex:Hide()
      end
    end
  end
end

local function RememberLine(fs)
  if fs and cmp.lineText[fs] == nil then
    cmp.lineText[fs] = fs:GetText()
  end
end

function SetTipLinesAlpha(alpha)
  local n = tip:NumLines() or 0
  if alpha < 1 then
    for i = 1, n do
      local left = _G["BidItemPopupTipTextLeft" .. i]
      local right = _G["BidItemPopupTipTextRight" .. i]
      if left then
        RememberLine(left)
        left:SetText(StripInlineTextures(cmp.lineText[left]))
        left:SetAlpha(0)
      end
      if right then
        RememberLine(right)
        right:SetText(StripInlineTextures(cmp.lineText[right]))
        right:SetAlpha(0)
      end
    end
    SetExtraIconsShown(false)
    return
  end
  for fs, text in pairs(cmp.lineText) do
    fs:SetText(text)
    fs:SetAlpha(1)
  end
  for fs in pairs(cmp.lineText) do
    cmp.lineText[fs] = nil
  end
  for i = 1, n do
    local left = _G["BidItemPopupTipTextLeft" .. i]
    local right = _G["BidItemPopupTipTextRight" .. i]
    if left then
      left:SetAlpha(1)
    end
    if right then
      right:SetAlpha(1)
    end
  end
  SetExtraIconsShown(true)
end

local function CompareColumns()
  local link = FullItemLink(lastHref)
  local _, _, _, _, _, _, _, _, equipLoc = SafeGetItemInfo(link)
  local newMap = StatMap(link)
  local columns = {}
  local equippedLinks = FilledSlotLinks(equipLoc)
  for i = 1, #equippedLinks do
    columns[i] = DeltaAgainst(newMap, StatMap(equippedLinks[i]))
  end
  return columns, OrderedDeltaKeys(columns), equippedLinks
end

local function EnsureComparePad()
  if cmp.pad >= 2 then
    return
  end
  while cmp.pad < 2 do
    tip:AddLine(" ")
    cmp.pad = cmp.pad + 1
  end
end

local function EquipTitle(link)
  if not link then
    return "empty", 0.55, 0.55, 0.55
  end
  local name, _, quality = SafeGetItemInfo(link)
  if not name or name == "" then
    return "empty", 0.55, 0.55, 0.55
  end
  local color = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality or 1]
  if color then
    return name, color.r, color.g, color.b
  end
  return name, 1, 1, 1
end

local function PlaceOnTipLine(fs, lineIndex, x, rowWidth)
  local anchor = _G["BidItemPopupTipTextLeft" .. lineIndex]
  fs:ClearAllPoints()
  if anchor then
    fs:SetFontObject(anchor:GetFontObject() or GameTooltipText)
    fs:SetPoint("TOPLEFT", anchor, "TOPLEFT", x, 0)
  else
    fs:SetFontObject(GameTooltipText)
    fs:SetPoint("TOPLEFT", cmp.name, "BOTTOMLEFT", x, -2 - (lineIndex - 2) * 16)
  end
  fs:SetWidth(rowWidth)
end

function PaintCompareOverlay()
  EnsureComparePad()
  SetTipLinesAlpha(0)
  cmp.iconGuard:Show()
  local name = lastItemName or ""
  local quality = lastItemQuality or 1
  local infoName, _, infoQ = SafeGetItemInfo(lastHref)
  if infoName then
    name = infoName
    quality = infoQ or quality
  end
  cmp.name:SetText(name)
  local color = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
  if color then
    cmp.name:SetTextColor(color.r, color.g, color.b)
  else
    cmp.name:SetTextColor(1, 1, 1)
  end
  cmp.name:ClearAllPoints()
  local header = _G["BidItemPopupTipTextLeft1"]
  if header then
    cmp.name:SetFontObject(header:GetFontObject() or GameTooltipHeaderText)
    cmp.name:SetPoint("TOPLEFT", header, "TOPLEFT", 0, 0)
    cmp.name:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
  else
    cmp.name:SetPoint("TOPLEFT", tip, "TOPLEFT", 8, -10)
    cmp.name:SetPoint("TOPRIGHT", tip, "TOPRIGHT", -28, -10)
  end
  cmp.name:Show()
  local columns, keys, equippedLinks = CompareColumns()
  local two = #columns >= 2
  local lineH = 16
  local width = (tip:GetWidth() or 200) - 16
  PlaceOnTipLine(cmp.vs, 2, 0, width)
  cmp.vs:SetText("vs")
  cmp.vs:SetTextColor(1, 1, 1)
  cmp.vs:Show()
  local leftName, lr, lg, lb = EquipTitle(equippedLinks and equippedLinks[1])
  PlaceOnTipLine(cmp.equip, 3, 0, two and (width / 2 - 4) or width)
  cmp.equip:SetJustifyH("LEFT")
  cmp.equip:SetText(leftName)
  cmp.equip:SetTextColor(lr, lg, lb)
  cmp.equip:Show()
  if two then
    local rightName, rr, rg, rb = EquipTitle(equippedLinks and equippedLinks[2])
    PlaceOnTipLine(cmp.equipRight, 3, width / 2, width / 2 - 4)
    cmp.equipRight:SetJustifyH("RIGHT")
    cmp.equipRight:SetText(rightName)
    cmp.equipRight:SetTextColor(rr, rg, rb)
    cmp.equipRight:Show()
  else
    cmp.equipRight:Hide()
  end
  for i = 1, #cmp.rows do
    cmp.rows[i].left:Hide()
    cmp.rows[i].right:Hide()
  end
  for i = 1, #keys do
    local row = CompareRow(i)
    local key = keys[i]
    local y = 10 + (#keys - i) * lineH
    local left, lr, lg, lb = DeltaText(columns[1] and columns[1][key], key, two)
    row.left:ClearAllPoints()
    row.left:SetPoint("BOTTOMLEFT", tip, "BOTTOMLEFT", 8, y)
    row.left:SetWidth(two and (width / 2 - 4) or width)
    row.left:SetText(left or "")
    if left then
      row.left:SetTextColor(lr, lg, lb)
    end
    row.left:Show()
    if two then
      local right, rr, rg, rb = DeltaText(columns[2] and columns[2][key], key, true)
      row.right:ClearAllPoints()
      row.right:SetPoint("BOTTOMRIGHT", tip, "BOTTOMRIGHT", -8, y)
      row.right:SetWidth(width / 2 - 4)
      row.right:SetText(right or "")
      if right then
        row.right:SetTextColor(rr, rg, rb)
      end
      row.right:Show()
    end
  end
end

ApplyTipMode = function()
  if not lastHref then
    return
  end
  if cmp.shownHref == lastHref and tip:IsShown() then
    return
  end
  cmp.pad = 0
  tip:SetOwner(frame, "ANCHOR_NONE")
  tip:SetHyperlink(lastHref)
  cmp.shownHref = lastHref
  for i = 1, 10 do
    local tex = _G["BidItemPopupTipTexture" .. i]
    if tex then
      tex.bidSaved = nil
      tex.bidWasShown = nil
      tex:SetAlpha(1)
    end
  end
  HideCompareOverlay()
  for fs in pairs(cmp.lineText) do
    cmp.lineText[fs] = nil
  end
end

local function PlaceTip()
  tip:ClearAllPoints()
  tip:SetPoint("TOP", frame, "TOP", 0, -TITLE_H)
end

local function PlaceCompareExtras()
  if compareBtn:IsShown() then
    compareBtn:ClearAllPoints()
    compareBtn:SetPoint("TOP", tip, "BOTTOM", 0, -4)
  end
end

local function CompareStackHeight()
  return TipBoxHeight(tip)
end

local tipFix = CreateFrame("Frame")
tipFix:Hide()
tipFix:SetScript("OnUpdate", function(self)
  self:Hide()
  if not frame:IsShown() or uiMinimized or itemHidden or not tip:IsShown() then
    return
  end
  if not cmp.known and lastHref and SafeGetItemInfo(lastHref) then
    RelayoutKeepTop()
    return
  end
  if cmp.on and lastHref then
    local naked = NakedItemString(FullItemLink(lastHref))
    if naked and not statMapCache[naked] then
      RelayoutKeepTop()
      return
    end
  end
  local h = CompareStackHeight()
  if h > 1 and math.abs(h - cmp.laidTipH) > 2 then
    RelayoutKeepTop()
  end
end)

local function LayoutToken()
  local plusOn = currentBid and 1 or 0
  local tenOn = (not myOwnBid or myOwnBid <= 10) and 1 or 0
  return table.concat({
    tostring(#CollectVisibleBids()),
    itemHidden and "1" or "0",
    cmp.on and "1" or "0",
    tostring(cmp.slots or 0),
    uiMinimized and "1" or "0",
    tostring(plusOn),
    tostring(tenOn),
    HasTossPaid() and "1" or "0",
    lastHref or "",
  }, "\0")
end

local function NoteLayout()
  cmp.appliedLayout = LayoutToken()
end

local function Layout()
  local tw = MIN_WIDTH
  local th = 0
  local headerH = TITLE_H
  if uiMinimized then
    title:Hide()
    tip:Hide()
    cmp.shownHref = nil
    HideCompareOverlay()
    compareBtn:Hide()
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
    HideSpecLines()
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
    NoteLayout()
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
      RefreshCompareSlots()
      local keepTip = tip:IsShown()
        and cmp.shownHref == lastHref
        and cmp.stackH and cmp.stackH > 1
        and cmp.paintedOn == (cmp.on and true or false)
      if keepTip and cmp.on and lastHref then
        local naked = NakedItemString(FullItemLink(lastHref))
        if naked and not statMapCache[naked] then
          keepTip = false
        end
      end
      if keepTip then
        tw = tip:GetWidth() or 200
        th = cmp.stackH
      else
        ApplyTipMode()
        tip:ClearAllPoints()
        tip:SetPoint("TOP", frame, "TOP", 0, -TITLE_H)
        tip:Show()
        if cmp.on and cmp.slots > 0 then
          PaintCompareOverlay()
        else
          HideCompareOverlay()
          SetTipLinesAlpha(1)
        end
        if cmp.slots > 0 then
          compareBtn:SetText(cmp.on and "item" or "compare")
          compareBtn:Show()
        else
          compareBtn:Hide()
        end
        tw = tip:GetWidth() or 200
        th = CompareStackHeight()
        PlaceTip()
        PlaceCompareExtras()
        if compareBtn:IsShown() then
          th = th + 4 + compareBtn:GetHeight()
        end
        local specAnchor = tip
        if compareBtn:IsShown() then
          specAnchor = compareBtn
        end
        local specH = PaintSpecLines(SpecRowsForItem(lastHref), specAnchor, "BOTTOM", -4)
        if specH > 0 then
          th = th + 4 + specH
        end
        cmp.laidTipH = CompareStackHeight()
        cmp.stackH = th
        cmp.paintedOn = cmp.on and true or false
        tipFix:Show()
      end
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
      cmp.shownHref = nil
      cmp.stackH = nil
      cmp.paintedOn = nil
      HideCompareOverlay()
      compareBtn:Hide()
      hideTipBtn:Hide()
      showItemBtn:Show()
      showItemBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -52, -10)
      if frame:GetWidth() and frame:GetWidth() > 1 then
        tw = frame:GetWidth() - 24
      end
      local specH = PaintSpecLines(SpecRowsForItem(lastHref), itemNameText, "BOTTOM", -2)
      if specH > 0 then
        th = th + 2 + specH
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
  PlaceTip()
  PlaceCompareExtras()

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
  local total = (#plusButtons * PLUS_W) + ((#plusButtons - 1) * PLUS_GAP)
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
  NoteLayout()
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
    cmp.shownHref = lastHref
    cmp.stackH = nil
    cmp.paintedOn = nil
    tip:Show()
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
    if roundBtn then
      local up = RoundBidPlace(currentBid)
      if up > currentBid then
        roundBtn:Enable()
      else
        roundBtn:Disable()
      end
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
    if isLead then
      if not row.leadFont then
        row.bidFS:SetFont(STANDARD_TEXT_FONT, LIST_FONT_LEAD, "OUTLINE")
        row.leadFont = true
      end
    elseif row.leadFont then
      row.bidFS:SetFont(STANDARD_TEXT_FONT, LIST_FONT, "OUTLINE")
      row.leadFont = false
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
      if isLead then
        row.bidFS:SetTextColor(0.2, 1, 0.25)
      else
        row.bidFS:SetTextColor(1, 1, 0.15)
      end
      if row.strike then
        row.strike:Hide()
      end
    end
  end
  if frame:IsShown() and LayoutToken() ~= cmp.appliedLayout then
    RelayoutKeepTop()
  end
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

roundBtn = CreateFrame("Button", nil, plusRow, "UIPanelButtonTemplate")
roundBtn:SetWidth(PLUS_W)
roundBtn:SetHeight(BTN_H)
roundBtn:SetText("round")
roundBtn:Disable()
roundBtn:SetScript("OnClick", function()
  if not currentBid then
    return
  end
  local nextBid = RoundBidPlace(currentBid)
  if nextBid <= currentBid then
    return
  end
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
roundBtn:Hide()
plusButtons[#plusButtons + 1] = roundBtn

local function ShowItemWindow(href, full, force)
  if not href then
    return false
  end
  local itemLink = full or ("|H" .. href .. "|h[item]|h")
  if not force and not ShowAllBids() and not CanPlayerUseItem(itemLink) then
    return false
  end

  ResetAuction()
  CancelCloseTimer()
  lastHref = href
  lastItemName = nil
  lastItemQuality = nil
  local iname, _, iquality = SafeGetItemInfo(itemLink)
  if iname then
    lastItemName = iname
    lastItemQuality = iquality
  end
  itemHidden = false
  cmp.on = false
  cmp.stackH = nil
  cmp.paintedOn = nil
  uiMinimized = false
  frame:Show()
  RestorePosition(frame)
  tip:SetOwner(frame, "ANCHOR_NONE")
  tip:SetHyperlink(href)
  cmp.shownHref = href
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
  if type(msg) ~= "string" or msg == "" then
    return nil, nil
  end
  msg = msg:gsub("\124", "|")
  local full = msg:match("|c%x+|Hitem:[^|]+|h%[[^%]]+%]|h|r")
  if not full then
    full = msg:match("|Hitem:[^|]+|h%[[^%]]+%]|h")
  end
  if full then
    local href = full:match("|H(item:[^|]+)|h")
    if href then
      return href, full
    end
  end
  local body = msg:match("(item:%d[%-0-9:]*)")
  if body then
    return body, "|H" .. body .. "|h[item]|h"
  end
  local plain = msg:match("%[(.-)%]")
  if plain and plain ~= "" then
    local _, link = GetItemInfo(plain)
    if link then
      local href = link:match("item:[^|]+")
      if href then
        return href, link
      end
    end
  end
  return nil, nil
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
eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
eventFrame:RegisterEvent("MAIL_SEND_SUCCESS")
eventFrame:RegisterEvent("MAIL_FAILED")
eventFrame:SetScript("OnEvent", function(_, event, arg1, arg2)
  if event == "ADDON_LOADED" then
    if arg1 == ADDON then
      BidItemPopupDB = BidItemPopupDB or {}
      BidItemPopupDB.tossPaid = BidItemPopupDB.tossPaid or {}
      if BidItemPopupDB.showCannotEquip == nil then
        BidItemPopupDB.showCannotEquip = false
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
      RefreshPlayerSpecs()
    end
    return
  end
  if event == "PLAYER_TALENT_UPDATE" then
    RefreshPlayerSpecs()
    if frame:IsShown() then
      RelayoutKeepTop()
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
    partnerPollAcc = 0
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
    RebuildGuildCache()
    if frame:IsShown() and #bidOrder > 0 then
      local changed = false
      for _, name in ipairs(bidOrder) do
        local info = bidByName[name]
        if info then
          local net, classFile = GetGuildNetAndClass(name)
          if net ~= nil and net ~= info.net then
            info.net = net
            changed = true
          end
          if info.classFile == nil and classFile ~= nil then
            info.classFile = classFile
            changed = true
          end
        end
      end
      if changed then
        UpdateBidUI()
      end
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

local function HandleBidItemCommand(msg)
  msg = msg and msg:gsub("^%s+", ""):gsub("%s+$", "") or ""
  if msg == "" then
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00" .. ADDON .. "|r: /biditem, Shift-клик по вещи в эту строку, Enter.")
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
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000" .. ADDON .. "|r: не вижу предмет. Shift-клик по вещи в строку /biditem.")
    return
  end
  local ok, err = pcall(ShowItemWindow, href, full, true)
  if not ok then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000" .. ADDON .. "|r: " .. tostring(err))
  end
end

BidItemPopup_OnSlash = HandleBidItemCommand

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
