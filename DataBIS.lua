-- Словарь: имя из таблицы -> token, tab
-- Вар | Warrior | Fury -> WARRIOR, 2
-- Пал | Paladin | Retribution -> PALADIN, 3
-- Пал | Paladin | Holy -> PALADIN, 1
-- Пал | Paladin | Protection -> PALADIN, 2
-- Хант | Hunter | Marksmanship -> HUNTER, 2
-- Хант | Hunter | Survival -> HUNTER, 3
-- Рог | Rogue | Combat 2p -> ROGUE, 2
-- Прист | Priest | Holy -> PRIEST, 2
-- Прист | Priest | Discipline -> PRIEST, 1
-- Прист | Priest | Shadow -> PRIEST, 3
-- ДК | Death Knight | Frost -> DEATHKNIGHT, 2
-- ДК | Death Knight | Unholy -> DEATHKNIGHT, 3
-- ДК | Death Knight | Blood Tank -> DEATHKNIGHT, 1
-- Шаман | Shaman | Restoration -> SHAMAN, 3
-- Шаман | Shaman | Enhance -> SHAMAN, 2
-- Шаман | Shaman | Elemental -> SHAMAN, 1
-- Маг | Mage | Fire -> MAGE, 2
-- Маг | Mage | Arcane -> MAGE, 1
-- Лок | Warlock | Demonology -> WARLOCK, 2
-- Лок | Warlock | Affliction -> WARLOCK, 1
-- Друид | Druid | Restoration -> DRUID, 3
-- Друид | Druid | Cat -> DRUID, 2
-- Друид | Druid | Bear -> DRUID, "feral_tank" -- та же вкладка 2
-- Друид | Druid | Balance -> DRUID, 1

BidItemPopupBIS = {
  WARRIOR = {
    [2] = { -- fury
      53132, -- Neck, Penumbra Pendant, обычный
      54581, -- Neck, Penumbra Pendant, героический
      47545, -- Cloak, Vereesa's Dexterity, героический
      53126, -- Bracers, Umbrage Armbands / Toskk's, обычный
      54580, -- Bracers, Umbrage Armbands / Toskk's, героический
      50333, -- Bracers alt, Toskk's, обычный
      50670, -- Bracers alt, Toskk's, героический
      50021, -- Gloves, Aldrianas Gloves of Secrecy, обычный
      50675, -- Gloves, Aldrianas Gloves of Secrecy, героический
      50187, -- Belt, Coldwraith Links, обычный
      50620, -- Belt, Coldwraith Links, героический
      53125, -- Feet, Apocalypse Advance, обычный
      54578, -- Feet, Apocalypse Advance, героический
      50402, -- Ring, Ashen Band of Endless Vengeance, обычный
      50186, -- Ring, Frostbrood Sapphire Ring, обычный
      50618, -- Ring, Frostbrood Sapphire Ring, героический
      50362, -- Trinket, Deathbringer's Will, обычный
      50363, -- Trinket, Deathbringer's Will, героический
      54569, -- Trinket, STS, обычный
      54590, -- Trinket, STS, героический
      49623, -- Weapon, Shadowmourne, обычный
      50070, -- Weapon 2, Glorenzelg, High-Blade of the Silver Hand, обычный
      50730, -- Weapon 2, Glorenzelg, High-Blade of the Silver Hand, героический
      49981, -- Ranged, Fal'inrush, Defender of Quel'thalas, обычный
      50733, -- Ranged, Fal'inrush, Defender of Quel'thalas, героический
    },
  },
  PALADIN = {
    [1] = { -- holy
      50182, -- Neck, Bloodqueen's Crimson Choker, обычный
      50724, -- Neck, Bloodqueen's Crimson Choker, героический
      50027, -- Chest, Rot-Resistant Breastplate, обычный
      50680, -- Chest, Rot-Resistant Breastplate, героический
      49995, -- Gloves, Fallen Lord's Handguards, обычный
      50650, -- Gloves, Fallen Lord's Handguards, героический
      50056, -- Legs, Plaguebringer's Stained Pants, обычный
      50694, -- Legs, Plaguebringer's Stained Pants, героический
      50400, -- Ring, Ashen Band of Endless Wisdom, обычный
      50008, -- Ring, Ring of Rapid Ascent, обычный
      50664, -- Ring, Ring of Rapid Ascent, героический
      46051, -- Trinket, Meteorite Crystal, обычный
      37111, -- Trinket, Soul Preserver, обычный
      54573, -- Trinket alt, GTS, обычный
      54589, -- Trinket alt, GTS, героический
      46017, -- Weapon, Valanir, обычный
      50427, -- Weapon alt, Bloodsurge, обычный
      50732, -- Weapon alt, Bloodsurge, героический
      49976, -- Shield, Bulwark of Smouldering Steel, обычный
      50616, -- Shield, Bulwark of Smouldering Steel, героический
      40705, -- Libram, Libram of Renewal, обычный
      47662, -- Libram alt, Libram of Veracity, обычный
    },
    [2] = { -- prot
      49986, -- Helm, Broken Ram Skull Helm (LDW), обычный
      50640, -- Helm, Broken Ram Skull Helm (LDW), героический
      50023, -- Neck, Bile-Encrusted Medalion (Rot), обычный
      50682, -- Neck, Bile-Encrusted Medalion (Rot), героический
      50074, -- Cloak, Royal Crimson Cloak (BPC), обычный
      50718, -- Cloak, Royal Crimson Cloak (BPC), героический
      50466, -- Cloak alt, Sentinel's Winter Cloak (Frosts), обычный
      49960, -- Bracers, Bracers of Dark Reckoning, обычный
      50611, -- Bracers, Bracers of Dark Reckoning, героический
      50802, -- Bracers alt, Gargoyle Spit Bracers, обычный
      51901, -- Bracers alt, Gargoyle Spit Bracers, героический
      50036, -- Belt, Belt of Broken Bones, обычный
      50691, -- Belt, Belt of Broken Bones, героический
      50991, -- Belt alt, Verdigris Chain Belt, обычный
      53129, -- Feet, Treads of Impending Resurrection (Halion), обычный
      54579, -- Feet, Treads of Impending Resurrection (Halion), героический
      50185, -- Ring, Devium's Eternally Cold Ring (VDW), обычный
      50622, -- Ring, Devium's Eternally Cold Ring (VDW), героический
      50404, -- Ring, Ashen Band of Endless Courage, обычный
      50361, -- Trinket, Sindragosa's Flawless Fang, обычный
      50364, -- Trinket, Sindragosa's Flawless Fang, героический
      54571, -- Trinket, Petrified Twilight Scale, обычный
      54591, -- Trinket, Petrified Twilight Scale, героический
      49997, -- Weapon, Mithrios, Bronzebeard's Legacy, обычный
      50738, -- Weapon, Mithrios, Bronzebeard's Legacy, героический
      50065, -- Shield, Icecrown Glacial Wall, обычный
      50729, -- Shield, Icecrown Glacial Wall, героический
      47661, -- Libram, Libram of Valiance, обычный
    },
    [3] = { -- ret
      53132, -- Neck, Penumbra Pendant, обычный
      54581, -- Neck, Penumbra Pendant, героический
      49998, -- Cloak, Shadowvault Slayer's Cloak, обычный
      50653, -- Cloak, Shadowvault Slayer's Cloak, героический
      53126, -- Bracers, Umbrage Armbands, обычный
      54580, -- Bracers, Umbrage Armbands, героический
      50188, -- Gloves, Anub'ar Stalker's Gloves, обычный
      50619, -- Gloves, Anub'ar Stalker's Gloves, героический
      50067, -- Belt, Astrylian's Sutured Cinch, обычный
      50707, -- Belt, Astrylian's Sutured Cinch, героический
      53125, -- Feet, Apocalypse Advance, обычный
      54578, -- Feet, Apocalypse Advance, героический
      50402, -- Ring, Ashen Band of Endless Vengeance, обычный
      50186, -- Ring, Frostbrood Sapphire Ring, обычный
      50618, -- Ring, Frostbrood Sapphire Ring, героический
      54569, -- Trinket, Sharpened Twilight Scale, обычный
      54590, -- Trinket, Sharpened Twilight Scale, героический
      50351, -- Trinket, Tiny Abomination in a Jar, обычный
      50706, -- Trinket, Tiny Abomination in a Jar, героический
      49623, -- Weapon, Shadowmourne, обычный
      50425, -- Weapon alt, Oathbinder, обычный
      50735, -- Weapon alt, Oathbinder, героический
      47661, -- Libram, Libram of Valiance, обычный
    },
  },
  HUNTER = {
    [2] = { -- mm
      50421, -- Neck, Sindragosa's Cruel Claw, обычный
      50633, -- Neck, Sindragosa's Cruel Claw, героический
      47545, -- Cloak, Vereesa's Dexterity > Frost Back, героический
      50000, -- Bracers, Scourge Hunter's Vambracers, обычный
      50655, -- Bracers, Scourge Hunter's Vambracers, героический
      50413, -- Belt, Nerub'ar Stalker's Cord, обычный
      50688, -- Belt, Nerub'ar Stalker's Cord, героический
      49988, -- Legs, Leggings of Northern Lights, обычный
      50645, -- Legs, Leggings of Northern Lights, героический
      53127, -- Feet, Returning Footfalls, обычный
      54577, -- Feet, Returning Footfalls, героический
      50402, -- Ring, Ashen Band of Endless Vengeance, обычный
      50186, -- Ring, Frostbrood Sapphire Ring, обычный
      50618, -- Ring, Frostbrood Sapphire Ring, героический
      50362, -- Trinket, Deathbringer's Will, обычный
      50363, -- Trinket, Deathbringer's Will, героический
      54569, -- Trinket, Sharpened Twilight Scale, обычный
      54590, -- Trinket, Sharpened Twilight Scale, героический
      50425, -- Weapon, Oathbinder, Charge of the Ranger-General, обычный
      50735, -- Weapon, Oathbinder, Charge of the Ranger-General, героический
      49981, -- Ranged, Fal'inrush, Defender of Quel'thalas, обычный
      50733, -- Ranged, Fal'inrush, Defender of Quel'thalas, героический
    },
    [3] = { -- surv
      50421, -- Neck, Sindragosa's Cruel Claw, обычный
      50633, -- Neck, Sindragosa's Cruel Claw, героический
      47545, -- Cloak, Vereesa's Dexterity > Frost Back, героический
      50000, -- Bracers, Scourge Hunter's Vambracers, обычный
      50655, -- Bracers, Scourge Hunter's Vambracers, героический
      50413, -- Belt, Nerub'ar Stalker's Cord, обычный
      50688, -- Belt, Nerub'ar Stalker's Cord, героический
      49988, -- Legs, Leggings of Northern Lights, обычный
      50645, -- Legs, Leggings of Northern Lights, героический
      53127, -- Feet, Returning Footfalls, обычный
      54577, -- Feet, Returning Footfalls, героический
      50402, -- Ring, Ashen Band of Endless Vengeance, обычный
      50186, -- Ring, Frostbrood Sapphire Ring, обычный
      50618, -- Ring, Frostbrood Sapphire Ring, героический
      50362, -- Trinket, Deathbringer's Will, обычный
      50363, -- Trinket, Deathbringer's Will, героический
      54569, -- Trinket, Sharpened Twilight Scale, обычный
      54590, -- Trinket, Sharpened Twilight Scale, героический
      50425, -- Weapon, Oathbinder, Charge of the Ranger-General, обычный
      50735, -- Weapon, Oathbinder, Charge of the Ranger-General, героический
      49981, -- Ranged, Fal'inrush, Defender of Quel'thalas, обычный
      50733, -- Ranged, Fal'inrush, Defender of Quel'thalas, героический
    },
  },
  ROGUE = {
    [2] = { -- combat
      50421, -- Neck, Sindragosa's Cruel Claw, обычный
      50633, -- Neck, Sindragosa's Cruel Claw, героический
      47545, -- Cloak, Vereesa's Dexterity, героический
      50001, -- Chest, Ikfirus's Sack of Wonder, обычный
      50656, -- Chest, Ikfirus's Sack of Wonder, героический
      50333, -- Bracers, Toskk's Maximized Wristguards, обычный
      50670, -- Bracers, Toskk's Maximized Wristguards, героический
      50021, -- Gloves, Aldriana's Gloves of Secrecy, обычный
      50675, -- Gloves, Aldriana's Gloves of Secrecy, героический
      50067, -- Belt, Astrylian's Sutured Cinch, обычный
      50707, -- Belt, Astrylian's Sutured Cinch, героический
      50042, -- Legs, Gangrenous Leggings, обычный
      50697, -- Legs, Gangrenous Leggings, героический
      49950, -- Feet, Frostbitten Fur Boots, обычный
      50607, -- Feet, Frostbitten Fur Boots, героический
      50402, -- Ring, Ashen Band of Endless Vengeance, обычный
      50186, -- Ring, Frostbrood sapphire ring, обычный
      50618, -- Ring, Frostbrood sapphire ring, героический
      50362, -- Trinket, Deathbringer's Will, обычный
      50363, -- Trinket, Deathbringer's Will, героический
      54569, -- Trinket, Sharpened Twilight Scale, обычный
      54590, -- Trinket, Sharpened Twilight Scale, героический
      50012, -- Weapon, Havoc's Call, обычный
      50737, -- Weapon, Havoc's Call, героический
      50411, -- Weapon 2, Scourgeborne Waraxe, обычный
      50654, -- Weapon 2, Scourgeborne Waraxe, героический
      49981, -- Ranged, Fal'inrush, Defender of Quel'thalas, обычный
      50733, -- Ranged, Fal'inrush, Defender of Quel'thalas, героический
    },
  },
  PRIEST = {
    [1] = { -- disc
      50182, -- Neck, Bloodqueen's Crimson Choker, обычный
      50724, -- Neck, Bloodqueen's Crimson Choker, героический
      53486, -- Bracers, Bracers of Fiery Night, обычный
      54582, -- Bracers, Bracers of Fiery Night, героический
      50176, -- Gloves, San'layn Ritualist Gloves, обычный
      50722, -- Gloves, San'layn Ritualist Gloves, героический
      49978, -- Belt, Crushing Coldwraith Belt, обычный
      50613, -- Belt, Crushing Coldwraith Belt, героический
      50062, -- Feet, Plague Scientist's Boots, обычный
      50699, -- Feet, Plague Scientist's Boots, героический
      50400, -- Ring, Ashen Band of Endless Wisdom, обычный
      50008, -- Ring, Ring of Rapid Ascent, обычный
      50664, -- Ring, Ring of Rapid Ascent, героический
      54573, -- Trinket, Glowing Twilight Scale, обычный
      54589, -- Trinket, Glowing Twilight Scale, героический
      50359, -- Trinket, Abacus, обычный
      50366, -- Trinket, Abacus, героический
      50428, -- Weapon, Royal Scepter of Terenas II, обычный
      50734, -- Weapon, Royal Scepter of Terenas II, героический
      50173, -- Off-hand, Shadowsilk Spindle, обычный
      50719, -- Off-hand, Shadowsilk Spindle, героический
      50033, -- Wand, Corpse Impaling Spike, обычный
      50684, -- Wand, Corpse Impaling Spike, героический
    },
    [2] = { -- holy
      49975, -- Neck, Bone Sentinel's Amulet, обычный
      50609, -- Neck, Bone Sentinel's Amulet, героический
      50014, -- Cloak, Greatcloak of the Turned Champion, обычный
      50668, -- Cloak, Greatcloak of the Turned Champion, героический
      50172, -- Chest, Sanguine Silk Robes, обычный
      50717, -- Chest, Sanguine Silk Robes, героический
      50032, -- Bracers, Death Surgeon's Sleeves, обычный
      50686, -- Bracers, Death Surgeon's Sleeves, героический
      49978, -- Belt, Crushing Coldwraith Belt, обычный
      50613, -- Belt, Crushing Coldwraith Belt, героический
      50062, -- Feet, Plague Scientist's Boots, обычный
      50699, -- Feet, Plague Scientist's Boots, героический
      50400, -- Ring, Ashen Band of Endless Wisdom, обычный
      54573, -- Trinket, Glowing Twilight Scale, обычный
      54589, -- Trinket, Glowing Twilight Scale, героический
      50428, -- Weapon, Royal Scepter of Terenas II, обычный
      50734, -- Weapon, Royal Scepter of Terenas II, героический
      50423, -- Off-hand, Sundial of Eternal Dusk, обычный
      50635, -- Off-hand, Sundial of Eternal Dusk, героический
      50033, -- Wand, Corpse Impaling Spike, обычный
      50684, -- Wand, Corpse Impaling Spike, героический
    },
    [3] = { -- shadow
      53486, -- Bracers, Bracers of Fiery Night, обычный
      54582, -- Bracers, Bracers of Fiery Night, героический
      49978, -- Belt, Crushing Coldwraith Belt, обычный
      50613, -- Belt, Crushing Coldwraith Belt, героический
      50056, -- Legs, Plaguebringer's Stained Pants, обычный
      50694, -- Legs, Plaguebringer's Stained Pants, героический
      50062, -- Feet, Plague Scientist's Boots, обычный
      50699, -- Feet, Plague Scientist's Boots, героический
      50398, -- Ring, Ashen Band of Endless Destruction, обычный
      50360, -- Trinket, Phylactery of the Nameless Lich, обычный
      50365, -- Trinket, Phylactery of the Nameless Lich, героический
      54572, -- Trinket, Charred Twilight Scale, обычный
      54588, -- Trinket, Charred Twilight Scale, героический
      50428, -- Weapon, Royal Scepter of Terenas II, обычный
      50734, -- Weapon, Royal Scepter of Terenas II, героический
      50173, -- Off-hand, Shadowsilk Spindle, обычный
      50719, -- Off-hand, Shadowsilk Spindle, героический
      50033, -- Wand, Corpse Impaling Spike, обычный
      50684, -- Wand, Corpse Impaling Spike, героический
    },
  },
  DEATHKNIGHT = {
    [1] = { -- blood
      49986, -- Helm, Broken Ram Skull Helm, обычный
      50640, -- Helm, Broken Ram Skull Helm, героический
      50023, -- Neck, Bile Encrusted Medallion, обычный
      50682, -- Neck, Bile Encrusted Medallion, героический
      50074, -- Cloak, Royal Crimson Cloak, обычный
      50718, -- Cloak, Royal Crimson Cloak, героический
      49960, -- Bracers, Bracers of Dark Reckoning, обычный
      50611, -- Bracers, Bracers of Dark Reckoning, героический
      50802, -- Bracers alt, Gargoyle Spit Bracers, обычный
      51901, -- Bracers alt, Gargoyle Spit Bracers, героический
      50036, -- Belt, Belt of Broken Bones, обычный
      50691, -- Belt, Belt of Broken Bones, героический
      53129, -- Feet, Treads of Impending Resurrection, обычный
      54579, -- Feet, Treads of Impending Resurrection, героический
      50185, -- Ring, Devium's Eternally Cold Ring, обычный
      50622, -- Ring, Devium's Eternally Cold Ring, героический
      50404, -- Ring, Ashen Band of Endless Courage, обычный
      50361, -- Trinket, Sindragosa's Flawless Fang, обычный
      50364, -- Trinket, Sindragosa's Flawless Fang, героический
      50070, -- Weapon, Glorenzelg, High-Blade of the Silver Hand, обычный
      50730, -- Weapon, Glorenzelg, High-Blade of the Silver Hand, героический
      47672, -- Sigil, Sigil of Insolence, обычный
    },
    [2] = { -- frost
      50180, -- Neck, Lana'thel's Chain of Flagellation, обычный
      50728, -- Neck, Lana'thel's Chain of Flagellation, героический
      50333, -- Bracers, Tosk, обычный
      50670, -- Bracers, Tosk, героический
      50021, -- Gloves, Aldiana's Gloves of Secrecy, обычный
      50675, -- Gloves, Aldiana's Gloves of Secrecy, героический
      50187, -- Belt, Coldwraith Links, обычный
      50620, -- Belt, Coldwraith Links, героический
      52572, -- Ring, Ashen Band of Endless Might, обычный
      50414, -- Ring, Might of Blight, обычный
      50693, -- Ring, Might of Blight, героический
      54569, -- Trinket, Sharpened Twilight Scale, обычный
      54590, -- Trinket, Sharpened Twilight Scale, героический
      50362, -- Trinket, Deathbringer's Will, обычный
      50363, -- Trinket, Deathbringer's Will, героический
      50012, -- Weapon, Havoc's Call, Blade of Lordaeron Kings, обычный
      50737, -- Weapon, Havoc's Call, Blade of Lordaeron Kings, героический
      40207, -- Sigil, Sigil of Awareness, обычный
    },
    [3] = { -- unholy
      50180, -- Neck, Lana'thel's Chain, обычный
      50728, -- Neck, Lana'thel's Chain, героический
      50019, -- Cloak, Winding Sheet, обычный
      50677, -- Cloak, Winding Sheet, героический
      50002, -- Bracers, Polar Bear Claw Bracers, обычный
      50659, -- Bracers, Polar Bear Claw Bracers, героический
      50187, -- Belt, Coldwraith links, обычный
      50620, -- Belt, Coldwraith links, героический
      50192, -- Legs, Scourge Reavers, обычный
      50624, -- Legs, Scourge Reavers, героический
      53125, -- Feet, Apocalypse Advance, обычный
      54578, -- Feet, Apocalypse Advance, героический
      52572, -- Ring, Ashen Band of Endless Might, обычный
      50414, -- Ring, Might of Blight, обычный
      50693, -- Ring, Might of Blight, героический
      54569, -- Trinket, STS, обычный
      54590, -- Trinket, STS, героический
      50362, -- Trinket, DBW, обычный
      50363, -- Trinket, DBW, героический
      49623, -- Weapon, Shadowmourne, обычный
      50070, -- Or, Glorenzelg, High-Blade of the Silver Hand (No SM), обычный
      50730, -- Or, Glorenzelg, High-Blade of the Silver Hand (No SM), героический
      50459, -- Sigil, Sigil of the Hanged Man, обычный
    },
  },
  SHAMAN = {
    [1] = { -- elem
      50005, -- Neck, Amulet of the Silent Eulogy, обычный
      50658, -- Neck, Amulet of the Silent Eulogy, героический
      50059, -- Shoulder, Horrific Flesh Epaulets / T10, обычный
      50698, -- Shoulder, Horrific Flesh Epaulets / T10, героический
      50030, -- Bracers, Bloodsunder's Bracers, обычный
      50687, -- Bracers, Bloodsunder's Bracers, героический
      50011, -- Gloves, T10 / Gunship Captain's Mittens, обычный
      50663, -- Gloves, T10 / Gunship Captain's Mittens, героический
      49978, -- Belt, Crushing Coldwraith Belt, обычный
      50613, -- Belt, Crushing Coldwraith Belt, героический
      50056, -- Legs, T10 / Plaguebringer's Stained Pants, обычный
      50694, -- Legs, T10 / Plaguebringer's Stained Pants, героический
      50062, -- Feet, Plague Scientist's Boots, обычный
      50699, -- Feet, Plague Scientist's Boots, героический
      50398, -- Ring, Ashen Band of Endless Destruction, обычный
      50008, -- Ring, Ring of Rapid Ascent, обычный
      50664, -- Ring, Ring of Rapid Ascent, героический
      50360, -- Trinket, Phylactery of the Nameless Lich, обычный
      50365, -- Trinket, Phylactery of the Nameless Lich, героический
      50353, -- Trinket, Dislodged Foreign Object, обычный
      50348, -- Trinket, Dislodged Foreign Object, героический
      50428, -- Weapon, Royal Scepter of Terenas II, обычный
      50734, -- Weapon, Royal Scepter of Terenas II, героический
      49976, -- Shield, Bulwark of Smouldering Steel, обычный
      50616, -- Shield, Bulwark of Smouldering Steel, героический
      50458, -- Totem, Bizuri's Totem of Shattered Ice, обычный
    },
    [2] = { -- enh
      50005, -- Neck, Amulet of the Silent Eulogy, обычный
      50658, -- Neck, Amulet of the Silent Eulogy, героический
      49998, -- Cloak, VDV BACK / Shadowvault Slayer's Cloak, обычный
      50653, -- Cloak, VDV BACK / Shadowvault Slayer's Cloak, героический
      50001, -- Chest, Ikfirus / T10 / Carapace, обычный
      50656, -- Chest, Ikfirus / T10 / Carapace, героический
      50030, -- Bracers, Bloodsunder's Bracers, обычный
      50687, -- Bracers, Bloodsunder's Bracers, героический
      50188, -- Gloves, T10 / Anub'ar Stalker's Gloves, обычный
      50619, -- Gloves, T10 / Anub'ar Stalker's Gloves, героический
      49978, -- Belt, Crushing Coldwraith Belt, обычный
      50613, -- Belt, Crushing Coldwraith Belt, героический
      50071, -- Feet, Treads of the Wasteland, обычный
      50711, -- Feet, Treads of the Wasteland, героический
      49949, -- Ring, Band of the Bone Colossus, обычный
      50604, -- Ring, Band of the Bone Colossus, героический
      50398, -- Ring, Ashen Band of Endless Destruction / Valanar ring, обычный
      50353, -- Trinket, Dislodged Foreign Object, обычный
      50348, -- Trinket, Dislodged Foreign Object, героический
      50360, -- Trinket, Phylactery of the Nameless Lich, обычный
      50365, -- Trinket, Phylactery of the Nameless Lich, героический
      50428, -- Weapon, Royal Scepter of Terenas, обычный
      50734, -- Weapon, Royal Scepter of Terenas, героический
      50012, -- Off-hand, Havoc's Call, Blade of Lordaeron Kings, обычный
      50737, -- Off-hand, Havoc's Call, Blade of Lordaeron Kings, героический
      50458, -- Totem, Bizuri's Totem of Shattered Ice, обычный
    },
    [3] = { -- restor
      50182, -- Neck, Bloodqueen's Crimson Choker, обычный
      50724, -- Neck, Bloodqueen's Crimson Choker, героический
      50064, -- Gloves, Unclean Surgical Gloves, обычный
      50703, -- Gloves, Unclean Surgical Gloves, героический
      49978, -- Belt, Crushing Coldwraith Belt, обычный
      50613, -- Belt, Crushing Coldwraith Belt, героический
      50062, -- Feet, Plague Scientist's Boots, обычный
      50699, -- Feet, Plague Scientist's Boots, героический
      50400, -- Ring, Ashen Band of Endless Wisdom, обычный
      50008, -- Ring, Ring of Rapid Ascent, обычный
      50664, -- Ring, Ring of Rapid Ascent, героический
      54573, -- Trinket, Glowing Twilight Scale, обычный
      54589, -- Trinket, Glowing Twilight Scale, героический
      50359, -- Trinket, Solace of the Fallen HC / Abacus, обычный
      50366, -- Trinket, Solace of the Fallen HC / Abacus, героический
      46017, -- Weapon, Valanyr, обычный
      50428, -- Weapon alt, Terenas, обычный
      50734, -- Weapon alt, Terenas, героический
      49976, -- Shield, Bulwark of Smouldering Steel, обычный
      50616, -- Shield, Bulwark of Smouldering Steel, героический
      47665, -- Totem, Totem of Calming Tides, обычный
      50464, -- Totem alt, Totem of the Surging Sea (FOR RS), обычный
    },
  },
  MAGE = {
    [1] = { -- arcane
      50182, -- Neck, Bloodqueen's Crimson Choker, обычный
      50724, -- Neck, Bloodqueen's Crimson Choker, героический
      53486, -- Bracers, Bracers of Fiery Night, обычный
      54582, -- Bracers, Bracers of Fiery Night, героический
      49978, -- Belt, Crushing Coldwraith Belt, обычный
      50613, -- Belt, Crushing Coldwraith Belt, героический
      50056, -- Legs, Plaguebringer's stainedpants, обычный
      50694, -- Legs, Plaguebringer's stainedpants, героический
      50062, -- Feet, Plague Scientist's Boots, обычный
      50699, -- Feet, Plague Scientist's Boots, героический
      50398, -- Ring, Ashen Band of Endless Destruction, обычный
      50008, -- Ring, Ring of Rapid Ascent, обычный
      50664, -- Ring, Ring of Rapid Ascent, героический
      50353, -- Trinket, Dislodged Foreign Object, обычный
      50348, -- Trinket, Dislodged Foreign Object, героический
      54572, -- Trinket, Charred Twilight Scale, обычный
      54588, -- Trinket, Charred Twilight Scale, героический
      50427, -- Weapon, LK sword, обычный
      50732, -- Weapon, LK sword, героический
      50173, -- Off-hand, Shadowsilk Spindle, обычный
      50719, -- Off-hand, Shadowsilk Spindle, героический
      50033, -- Wand, Corpse Impaling Spike, обычный
      50684, -- Wand, Corpse Impaling Spike, героический
    },
    [2] = { -- fire
      50182, -- Neck, Bloodqueen's Crimson Choker, обычный
      50724, -- Neck, Bloodqueen's Crimson Choker, героический
      50418, -- Chest, Robe of the Waking Nightmare, обычный
      50629, -- Chest, Robe of the Waking Nightmare, героический
      53486, -- Bracers, Bracers of Fiery Night, обычный
      54582, -- Bracers, Bracers of Fiery Night, героический
      49978, -- Belt, Crushing Coldwraith Belt, обычный
      50613, -- Belt, Crushing Coldwraith Belt, героический
      50062, -- Feet, Plague Scientist's Boots, обычный
      50699, -- Feet, Plague Scientist's Boots, героический
      50398, -- Ring, Ashen Band of Endless Destruction, обычный
      50008, -- Ring, Ring of Rapid Ascent, обычный
      50664, -- Ring, Ring of Rapid Ascent, героический
      50360, -- Trinket, Phylactery of the Nameless Lich, обычный
      50365, -- Trinket, Phylactery of the Nameless Lich, героический
      54572, -- Trinket, Charred Twilight Scale, обычный
      54588, -- Trinket, Charred Twilight Scale, героический
      50427, -- Weapon, LK SWORD, обычный
      50732, -- Weapon, LK SWORD, героический
      50173, -- Off-hand, Shadowsilk Spindle, обычный
      50719, -- Off-hand, Shadowsilk Spindle, героический
      50033, -- Wand, Corpse Impaling Spike, обычный
      50684, -- Wand, Corpse Impaling Spike, героический
    },
  },
  WARLOCK = {
    [1] = { -- affli
      50182, -- Neck, Blood Queen's Crimson Choker, обычный
      50724, -- Neck, Blood Queen's Crimson Choker, героический
      53486, -- Bracers, Bracers of Fiery Night, обычный
      54582, -- Bracers, Bracers of Fiery Night, героический
      49978, -- Belt, Crushing Coldwraith Belt, обычный
      50613, -- Belt, Crushing Coldwraith Belt, героический
      50056, -- Legs, Plaguebringer's Stained Pants, обычный
      50694, -- Legs, Plaguebringer's Stained Pants, героический
      50062, -- Feet, Plague Scientist's Boots, обычный
      50699, -- Feet, Plague Scientist's Boots, героический
      50398, -- Ring, Ashen Band of Endless Destruction, обычный
      50008, -- Ring, Ring of Rapid Ascent, обычный
      50664, -- Ring, Ring of Rapid Ascent, героический
      50360, -- Trinket, Phylactery of the Nameless Lich, обычный
      50365, -- Trinket, Phylactery of the Nameless Lich, героический
      54572, -- Trinket, Charred Twilight Scale / DFO, обычный
      54588, -- Trinket, Charred Twilight Scale / DFO, героический
      50353, -- Trinket alt, DFO, обычный
      50348, -- Trinket alt, DFO, героический
      50427, -- Weapon, Bloodsurge, обычный
      50732, -- Weapon, Bloodsurge, героический
      50173, -- Off-hand, Shadowsilk Spindle, обычный
      50719, -- Off-hand, Shadowsilk Spindle, героический
      50033, -- Wand, Corpse Impaling Spike, обычный
      50684, -- Wand, Corpse Impaling Spike, героический
    },
    [2] = { -- demo
      50005, -- Neck, Amulet of Silent Eulogy, обычный
      50658, -- Neck, Amulet of Silent Eulogy, героический
      53486, -- Bracers, Bracers of Fiery Night, обычный
      54582, -- Bracers, Bracers of Fiery Night, героический
      49978, -- Belt, Crushing Coldwraith Belt, обычный
      50613, -- Belt, Crushing Coldwraith Belt, героический
      50056, -- Legs, Plaguebringer's Stained Pants, обычный
      50694, -- Legs, Plaguebringer's Stained Pants, героический
      50062, -- Feet, Plague Scientist's Boots, обычный
      50699, -- Feet, Plague Scientist's Boots, героический
      50398, -- Ring, Ashen Band of Endless Destruction, обычный
      50170, -- Ring, Valanar's Other Signet Ring, обычный
      50714, -- Ring, Valanar's Other Signet Ring, героический
      50360, -- Trinket, Phylactery of the Nameless Lich, обычный
      50365, -- Trinket, Phylactery of the Nameless Lich, героический
      54572, -- Trinket, Charred Twilight Scale / DFO, обычный
      54588, -- Trinket, Charred Twilight Scale / DFO, героический
      50353, -- Trinket alt, DFO, обычный
      50348, -- Trinket alt, DFO, героический
      50427, -- Weapon, Bloodsurge, обычный
      50732, -- Weapon, Bloodsurge, героический
      50173, -- Off-hand, Shadowsilk Spindle, обычный
      50719, -- Off-hand, Shadowsilk Spindle, героический
      50033, -- Wand, Corpse Impaling Spike, обычный
      50684, -- Wand, Corpse Impaling Spike, героический
    },
  },
  DRUID = {
    [1] = { -- balance
      50182, -- Neck, Bloodqueen's Crimson Choker, обычный
      50724, -- Neck, Bloodqueen's Crimson Choker, героический
      53486, -- Bracers, Bracers of Fiery Night, обычный
      54582, -- Bracers, Bracers of Fiery Night, героический
      49978, -- Belt, Crushing Coldwraith Belt, обычный
      50613, -- Belt, Crushing Coldwraith Belt, героический
      50062, -- Feet, Plague Scientist's Boots, обычный
      50699, -- Feet, Plague Scientist's Boots, героический
      50398, -- Ring, Ashen Band of Endless Destruction, обычный
      50008, -- Ring, Ring of rapid ascent, обычный
      50664, -- Ring, Ring of rapid ascent, героический
      50360, -- Trinket, Phylactery of the Nameless Lich, обычный
      50365, -- Trinket, Phylactery of the Nameless Lich, героический
      54572, -- Trinket, Charred Twilight Scale, обычный
      54588, -- Trinket, Charred Twilight Scale, героический
      50428, -- Weapon, Royal Scepter Terenas II, обычный
      50734, -- Weapon, Royal Scepter Terenas II, героический
      50173, -- Off-hand, Shadowsilk Spindle, обычный
      50719, -- Off-hand, Shadowsilk Spindle, героический
      50457, -- Relic, Idol of the Lunar Eclipse, обычный
    },
    [2] = { -- cat
      50421, -- Neck, Sindragosa's Cruel Claw (H), обычный
      50633, -- Neck, Sindragosa's Cruel Claw (H), героический
      47545, -- Cloak, Vereesa's Dexterity, героический
      50333, -- Bracers, Toskk's Maximized Wristguards, обычный
      50670, -- Bracers, Toskk's Maximized Wristguards, героический
      50021, -- Gloves, Aldriana's Gloves of Secrecy, обычный
      50675, -- Gloves, Aldriana's Gloves of Secrecy, героический
      50067, -- Belt, Astylians Sutured Cinch, обычный
      50707, -- Belt, Astylians Sutured Cinch, героический
      49950, -- Feet, Frostbitten Fur Boots, обычный
      50607, -- Feet, Frostbitten Fur Boots, героический
      50402, -- Ring, Ashen Band of Endless Vengeance, обычный
      49949, -- Ring, Band of the Bone Colossus (H), обычный
      50604, -- Ring, Band of the Bone Colossus (H), героический
      50362, -- Trinket, Deathbringer's Will, обычный
      50363, -- Trinket, Deathbringer's Will, героический
      54569, -- Trinket, Sharpened Twilight Scale, обычный
      54590, -- Trinket, Sharpened Twilight Scale, героический
      50425, -- Weapon, Oathbinder, Charge of the Ranger-General, обычный
      50735, -- Weapon, Oathbinder, Charge of the Ranger-General, героический
      50456, -- Relic, Idol of the Crying Moon, обычный
    },
    ["feral_tank"] = { -- та же вкладка 2
      50023, -- Neck, Bile Encrusted Medallion, обычный
      50682, -- Neck, Bile Encrusted Medallion, героический
      50074, -- Cloak, Royal Crimson Cloak, обычный
      50718, -- Cloak, Royal Crimson Cloak, героический
      50001, -- Chest, Ikfirus's Sack of Wonder, обычный
      50656, -- Chest, Ikfirus's Sack of Wonder, героический
      53126, -- Bracers, Umbrage Armbands, обычный
      54580, -- Bracers, Umbrage Armbands, героический
      50067, -- Belt, Astylians Sutured Cinch, обычный
      50707, -- Belt, Astylians Sutured Cinch, героический
      49950, -- Feet, Frostbitten Fur Boots, обычный
      50607, -- Feet, Frostbitten Fur Boots, героический
      50361, -- Trinket, Sindragosa's Flawless Fang, обычный
      50364, -- Trinket, Sindragosa's Flawless Fang, героический
      47290, -- Trinket, Juggernaut's Vitality, обычный
      47451, -- Trinket, Juggernaut's Vitality, героический
      50425, -- Weapon, Oathbinder, Charge of the Ranger-General, обычный
      50735, -- Weapon, Oathbinder, Charge of the Ranger-General, героический
      51481, -- Weapon alt, Wrathful Gladiator's Halberd (Optional), обычный
      50456, -- Relic, Idol of the Crying Moon, обычный
    },
    [3] = { -- restor
      49975, -- Neck, Bone Sentinel's Amulet, обычный
      50609, -- Neck, Bone Sentinel's Amulet, героический
      50014, -- Cloak, Greatcloak of the Turned Champion, обычный
      50668, -- Cloak, Greatcloak of the Turned Champion, героический
      50172, -- Chest, Sanguine Silk Robes, обычный
      50717, -- Chest, Sanguine Silk Robes, героический
      50417, -- Bracers, Bracers of Eternal Dreaming, обычный
      50630, -- Bracers, Bracers of Eternal Dreaming, героический
      50069, -- Belt, Professor's Bloodied Smock, обычный
      50705, -- Belt, Professor's Bloodied Smock, героический
      50009, -- Feet, Boots of Unnatural Growth, обычный
      50665, -- Feet, Boots of Unnatural Growth, героический
      50400, -- Ring, Ashen Band of Endless Wisdom, обычный
      50424, -- Ring, Memory of Malygos, обычный
      50636, -- Ring, Memory of Malygos, героический
      50359, -- Trinket, Althor's Abacus, обычный
      50366, -- Trinket, Althor's Abacus, героический
      54573, -- Trinket, Glowing Twilight Scale, обычный
      54589, -- Trinket, Glowing Twilight Scale, героический
      50428, -- Weapon, Terenas, обычный
      50734, -- Weapon, Terenas, героический
      50028, -- Weapon alt, Trauma, обычный
      50685, -- Weapon alt, Trauma, героический
      50423, -- Off-hand, Sundial of Eternal Dusk, обычный
      50635, -- Off-hand, Sundial of Eternal Dusk, героический
      50454, -- Relic, Idol of the Black Willow, обычный
    },
  },
}
