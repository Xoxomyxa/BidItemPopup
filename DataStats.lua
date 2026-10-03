-- Словарь: имя из таблицы -> token, tab
-- Вар | Warrior | Arms -> WARRIOR, 1
-- Вар | Warrior | Fury -> WARRIOR, 2
-- Вар | Warrior | Protection -> WARRIOR, 3
-- Пал | Paladin | Holy -> PALADIN, 1
-- Пал | Paladin | Protection -> PALADIN, 2
-- Пал | Paladin | Retribution -> PALADIN, 3
-- Хант | Hunter | Beast Mastery -> HUNTER, 1
-- Хант | Hunter | Marksmanship -> HUNTER, 2
-- Хант | Hunter | Survival -> HUNTER, 3
-- Рог | Rogue | Assassination -> ROGUE, 1
-- Рог | Rogue | Combat -> ROGUE, 2
-- Рог | Rogue | Subtlety -> ROGUE, 3
-- Прист | Priest | Discipline -> PRIEST, 1
-- Прист | Priest | Holy -> PRIEST, 2
-- Прист | Priest | Shadow -> PRIEST, 3
-- ДК | Death Knight | Blood -> DEATHKNIGHT, "blood_dps" -- та же вкладка 1
-- ДК | Death Knight | Blood Tank -> DEATHKNIGHT, 1
-- ДК | Death Knight | Frost -> DEATHKNIGHT, 2
-- ДК | Death Knight | Unholy -> DEATHKNIGHT, 3
-- Шаман | Shaman | Elemental -> SHAMAN, 1
-- Шаман | Shaman | Enhance -> SHAMAN, 2
-- Шаман | Shaman | Restoration -> SHAMAN, 3
-- Маг | Mage | Arcane -> MAGE, 1
-- Маг | Mage | Fire -> MAGE, 2
-- Маг | Mage | Frost -> MAGE, 3
-- Лок | Warlock | Affliction -> WARLOCK, 1
-- Лок | Warlock | Demonology -> WARLOCK, 2
-- Лок | Warlock | Destruction -> WARLOCK, 3
-- Друид | Druid | Balance -> DRUID, 1
-- Друид | Druid | Cat -> DRUID, 2
-- Друид | Druid | Bear -> DRUID, "feral_tank" -- та же вкладка 2
-- Друид | Druid | Restoration -> DRUID, 3
--
-- Ровно три слота, порядок — приоритет. Выносливости нет: она почти на каждой вещи.
-- Строка — этот стат обязателен. Таблица из двух строк — достаточно любого одного.
-- ARMOR — базовая броня. GetItemStats её не возвращает, код аддона должен смотреть броню отдельно.

BidItemPopupStats = {
  WARRIOR = {
    [1] = { -- arms
      "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
      "ITEM_MOD_STRENGTH_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
    [2] = { -- fury
      "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
      "ITEM_MOD_STRENGTH_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
    [3] = { -- prot
      "ARMOR",
      "ITEM_MOD_BLOCK_VALUE_SHORT",
      "ITEM_MOD_DEFENSE_SKILL_RATING_SHORT",
    },
  },
  PALADIN = {
    [1] = { -- holy
      "ITEM_MOD_INTELLECT_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
      "ITEM_MOD_SPELL_POWER_SHORT",
    },
    [2] = { -- prot
      "ARMOR",
      "ITEM_MOD_BLOCK_RATING_SHORT",
      "ITEM_MOD_AGILITY_SHORT",
    },
    [3] = { -- ret
      "ITEM_MOD_STRENGTH_SHORT",
      "ITEM_MOD_EXPERTISE_RATING_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
  },
  HUNTER = {
    [1] = { -- bm
      "ITEM_MOD_AGILITY_SHORT",
      "ITEM_MOD_ATTACK_POWER_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
    [2] = { -- mm
      "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
      "ITEM_MOD_AGILITY_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
    [3] = { -- surv
      "ITEM_MOD_AGILITY_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
    },
  },
  ROGUE = {
    [1] = { -- assassination
      "ITEM_MOD_ATTACK_POWER_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
    [2] = { -- combat
      "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
      "ITEM_MOD_AGILITY_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
    },
    [3] = { -- subtlety
      "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
      "ITEM_MOD_AGILITY_SHORT",
      "ITEM_MOD_ATTACK_POWER_SHORT",
    },
  },
  PRIEST = {
    [1] = { -- disc
      "ITEM_MOD_SPELL_POWER_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
      "ITEM_MOD_INTELLECT_SHORT",
    },
    [2] = { -- holy
      "ITEM_MOD_SPELL_POWER_SHORT",
      "ITEM_MOD_SPIRIT_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
    },
    [3] = { -- shadow
      "ITEM_MOD_SPELL_POWER_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
  },
  DEATHKNIGHT = {
    ["blood_dps"] = { -- та же вкладка 1
      "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
      "ITEM_MOD_STRENGTH_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
    [1] = { -- blood tank
      "ARMOR",
      "ITEM_MOD_STRENGTH_SHORT",
      "ITEM_MOD_DEFENSE_SKILL_RATING_SHORT",
    },
    [2] = { -- frost
      "ITEM_MOD_STRENGTH_SHORT",
      "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
      { "ITEM_MOD_CRIT_RATING_SHORT", "ITEM_MOD_HASTE_RATING_SHORT" },
    },
    [3] = { -- unholy
      "ITEM_MOD_STRENGTH_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
  },
  SHAMAN = {
    [1] = { -- elem
      "ITEM_MOD_SPELL_POWER_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
    [2] = { -- enh
      "ITEM_MOD_ATTACK_POWER_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
    [3] = { -- restor
      "ITEM_MOD_HASTE_RATING_SHORT",
      "ITEM_MOD_SPELL_POWER_SHORT",
      "ITEM_MOD_MANA_REGENERATION_SHORT",
    },
  },
  MAGE = {
    [1] = { -- arcane
      "ITEM_MOD_HASTE_RATING_SHORT",
      "ITEM_MOD_SPELL_POWER_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
    [2] = { -- fire
      "ITEM_MOD_CRIT_RATING_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
      "ITEM_MOD_SPELL_POWER_SHORT",
    },
    [3] = { -- frost
      "ITEM_MOD_SPELL_POWER_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
  },
  WARLOCK = {
    [1] = { -- affli
      "ITEM_MOD_SPELL_POWER_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
    [2] = { -- demo
      "ITEM_MOD_SPELL_POWER_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
    [3] = { -- destro
      "ITEM_MOD_SPELL_POWER_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
  },
  DRUID = {
    [1] = { -- balance
      "ITEM_MOD_SPELL_POWER_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
      "ITEM_MOD_CRIT_RATING_SHORT",
    },
    [2] = { -- cat
      "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
      "ITEM_MOD_AGILITY_SHORT",
      { "ITEM_MOD_ATTACK_POWER_SHORT", "ITEM_MOD_STRENGTH_SHORT" },
    },
    ["feral_tank"] = { -- та же вкладка 2
      "ITEM_MOD_AGILITY_SHORT",
      "ARMOR",
      { "ITEM_MOD_STRENGTH_SHORT", "ITEM_MOD_ATTACK_POWER_SHORT" },
    },
    [3] = { -- restor
      "ITEM_MOD_SPELL_POWER_SHORT",
      "ITEM_MOD_HASTE_RATING_SHORT",
      "ITEM_MOD_SPIRIT_SHORT",
    },
  },
}

local STAT_CANON = {
  "ITEM_MOD_STRENGTH_SHORT",
  "ITEM_MOD_AGILITY_SHORT",
  "ITEM_MOD_INTELLECT_SHORT",
  "ITEM_MOD_SPIRIT_SHORT",
  "ITEM_MOD_SPELL_POWER_SHORT",
  "ITEM_MOD_HASTE_RATING_SHORT",
  "ITEM_MOD_CRIT_RATING_SHORT",
  "ITEM_MOD_ATTACK_POWER_SHORT",
  "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
  "ITEM_MOD_EXPERTISE_RATING_SHORT",
  "ITEM_MOD_DEFENSE_SKILL_RATING_SHORT",
  "ITEM_MOD_BLOCK_RATING_SHORT",
  "ITEM_MOD_BLOCK_VALUE_SHORT",
  "ITEM_MOD_MANA_REGENERATION_SHORT",
}

local EQUIP_TO_CANON = {
  { "ITEM_MOD_SPELL_POWER", "ITEM_MOD_SPELL_POWER_SHORT" },
  { "ITEM_MOD_SPELL_DAMAGE_DONE", "ITEM_MOD_SPELL_POWER_SHORT" },
  { "ITEM_MOD_SPELL_HEALING_DONE", "ITEM_MOD_SPELL_POWER_SHORT" },
  { "ITEM_MOD_HASTE_RATING", "ITEM_MOD_HASTE_RATING_SHORT" },
  { "ITEM_MOD_HASTE_MELEE_RATING", "ITEM_MOD_HASTE_RATING_SHORT" },
  { "ITEM_MOD_HASTE_RANGED_RATING", "ITEM_MOD_HASTE_RATING_SHORT" },
  { "ITEM_MOD_HASTE_SPELL_RATING", "ITEM_MOD_HASTE_RATING_SHORT" },
  { "ITEM_MOD_CRIT_RATING", "ITEM_MOD_CRIT_RATING_SHORT" },
  { "ITEM_MOD_CRIT_MELEE_RATING", "ITEM_MOD_CRIT_RATING_SHORT" },
  { "ITEM_MOD_CRIT_RANGED_RATING", "ITEM_MOD_CRIT_RATING_SHORT" },
  { "ITEM_MOD_CRIT_SPELL_RATING", "ITEM_MOD_CRIT_RATING_SHORT" },
  { "ITEM_MOD_ATTACK_POWER", "ITEM_MOD_ATTACK_POWER_SHORT" },
  { "ITEM_MOD_RANGED_ATTACK_POWER", "ITEM_MOD_ATTACK_POWER_SHORT" },
  { "ITEM_MOD_ARMOR_PENETRATION_RATING", "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT" },
  { "ITEM_MOD_EXPERTISE_RATING", "ITEM_MOD_EXPERTISE_RATING_SHORT" },
  { "ITEM_MOD_DEFENSE_SKILL_RATING", "ITEM_MOD_DEFENSE_SKILL_RATING_SHORT" },
  { "ITEM_MOD_BLOCK_RATING", "ITEM_MOD_BLOCK_RATING_SHORT" },
  { "ITEM_MOD_BLOCK_VALUE", "ITEM_MOD_BLOCK_VALUE_SHORT" },
  { "ITEM_MOD_MANA_REGENERATION", "ITEM_MOD_MANA_REGENERATION_SHORT" },
  { "ITEM_MOD_STRENGTH", "ITEM_MOD_STRENGTH_SHORT" },
  { "ITEM_MOD_AGILITY", "ITEM_MOD_AGILITY_SHORT" },
  { "ITEM_MOD_INTELLECT", "ITEM_MOD_INTELLECT_SHORT" },
  { "ITEM_MOD_SPIRIT", "ITEM_MOD_SPIRIT_SHORT" },
}

local labelToCanon
local equipPatterns

local function EscapeStatPattern(text)
  return (text:gsub("([%(%)%.%+%-%*%?%[%]%^%$])", "%%%1"))
end

local function EnsureStatMaps()
  if labelToCanon then
    return
  end
  labelToCanon = {}
  for i = 1, #STAT_CANON do
    local key = STAT_CANON[i]
    local label = _G[key]
    if type(label) == "string" then
      labelToCanon[label] = key
    end
  end
  equipPatterns = {}
  for i = 1, #EQUIP_TO_CANON do
    local globalName = EQUIP_TO_CANON[i][1]
    local canon = EQUIP_TO_CANON[i][2]
    local fmt = _G[globalName]
    if type(fmt) == "string" then
      local token = fmt:match("%%%.%d*f") or fmt:match("%%d") or fmt:match("%%s")
      if token then
        local startAt, endAt = fmt:find(token, 1, true)
        if startAt then
          equipPatterns[#equipPatterns + 1] = {
            pat = EscapeStatPattern(fmt:sub(1, startAt - 1))
              .. "([%d%.,]+)"
              .. EscapeStatPattern(fmt:sub(endAt + 1)),
            canon = canon,
          }
        end
      end
    end
  end
end

local function CanonStatKey(key)
  if type(key) ~= "string" then
    return nil
  end
  EnsureStatMaps()
  local byLabel = labelToCanon[key]
  if byLabel then
    return byLabel
  end
  local label = _G[key]
  if type(label) == "string" and labelToCanon[label] == key then
    return key
  end
  return nil
end

local function PutCanonStat(stats, key, value)
  if not key or type(value) ~= "number" or value <= 0 then
    return
  end
  if not stats[key] or value > stats[key] then
    stats[key] = value
  end
end

local function TipStatNumber(text)
  if type(text) ~= "string" then
    return nil
  end
  return tonumber((text:gsub(",", ".")))
end

local function MergeTipStats(stats, tip)
  EnsureStatMaps()
  local name = tip:GetName()
  local socketPrefix
  if type(ITEM_SOCKET_BONUS) == "string" then
    socketPrefix = ITEM_SOCKET_BONUS:match("^(.-)%%")
  end
  local equipPrefix = ITEM_SPELL_TRIGGER_ONEQUIP
  local lines = tip:NumLines() or 0
  for i = 2, lines do
    local fs = _G[name .. "TextLeft" .. i]
    local text = fs and fs:GetText()
    if type(text) == "string" and text ~= "" then
      text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
      local skipSocket = socketPrefix and socketPrefix ~= "" and text:find(socketPrefix, 1, true)
      if not skipSocket then
        local amountText, label = text:match("^%+?([%d%.,]+)%s+(.+)$")
        local canon = label and labelToCanon[label]
        local amount = TipStatNumber(amountText)
        if canon and amount then
          PutCanonStat(stats, canon, amount)
        else
          local body = text
          if type(equipPrefix) == "string" and body:sub(1, #equipPrefix) == equipPrefix then
            body = body:sub(#equipPrefix + 1):gsub("^%s+", "")
          end
          for p = 1, #equipPatterns do
            local row = equipPatterns[p]
            local found = body:match(row.pat)
            local equipAmount = TipStatNumber(found)
            if equipAmount then
              PutCanonStat(stats, row.canon, equipAmount)
              break
            end
          end
        end
      end
    end
  end
end

function BidItemPopup_ReadCanonicalStats(tip, link)
  tip:ClearLines()
  tip:SetOwner(UIParent, "ANCHOR_NONE")
  tip:SetHyperlink(link)
  if (tip:NumLines() or 0) < 2 then
    return nil
  end
  local stats = {}
  local raw = GetItemStats(link)
  if type(raw) == "table" then
    for key, value in pairs(raw) do
      PutCanonStat(stats, CanonStatKey(key), value)
    end
  end
  MergeTipStats(stats, tip)
  return stats
end
