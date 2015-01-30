local CsvLoader = {
	configs = {
		{name = "itemCsv",  parser = "ItemCsv", file = "csv/item.csv"},
		{name = "gemHealthCsv",  parser = "GemHealthCsv", file = "csv/gem_health.csv"},
		{name = "gemGoldCsv",  parser = "GemGoldCsv", file = "csv/gem_gold.csv"},
		{name = "buffCsv",  parser = "BuffCsv", file = "csv/buff.csv"},
		{name = "bulletCsv",  parser = "BulletCsv", file = "csv/bullet.csv"},
		{name = "skillCsv",  parser = "SkillCsv", file = "csv/skill.csv"},
		{name = "unitCsv",  parser = "UnitCsv", file = "csv/unit.csv"},
		{name = "equipmentCsv",  parser = "EquipmentCsv", file = "csv/equipment.csv"},
		{name = "unitlevelCsv",  parser = "UnitLevelCsv", file = "csv/unit_level.csv"},
		{name = "starCsv",  parser = "StarCsv", file = "csv/star.csv"},
		{name = "masterlevelCsv",  parser = "MasterLevelCsv", file = "csv/master_level.csv"},
		{name = "heroEquipCsv",  parser = "HeroEquipCsv", file = "csv/hero_equipments.csv"},
		{name = "capsuleMainCsv",  parser = "CapsuleMainCsv", file = "csv/capsule_main.csv" },
		{name = "dungeonCsv",  parser = "DungeonCsv", file = "csv/chapter.csv" },
        {name = "sceneCsv",  parser = "SceneCsv", file = "csv/battle.csv" },
        {name = "skillLevelCsv",  parser = "SkillLevelCsv", file = "csv/skill_level.csv" },
        {name = "talkCsv",  parser = "TalkCsv", file = "csv/talk.csv" },
        {name = "gradeCsv",  parser = "GradeCsv", file = "csv/grade.csv" },
        {name = "signCsv",  parser = "SignCsv", file = "csv/sign.csv"},
        {name = "masterCsv",  parser = "MasterCsv", file = "csv/master.csv"},
        {name = "nameCsv",  parser = "NameCsv", file = "csv/name.csv"},
        {name = "arenaCsv",  parser = "ArenaCsv", file = "csv/arena.csv"},
        {name = "storeCsv",  parser = "StoreCsv", file = "csv/store.csv"},
        {name = "pvpcdCsv",  parser = "PvpCdCsv", file = "csv/arena_cd.csv"},
        {name = "pvpticketCsv",  parser = "PvpTicketCsv", file = "csv/arena_ticket.csv"},
        {name = "dailyCsv",  parser = "DailyCsv", file = "csv/daily.csv"},
        {name = "mailCsv",  parser = "MailCsv", file = "csv/mail.csv"},
	},
}

function CsvLoader.loadCsv()
	for i=1,#CsvLoader.configs do
		_G[CsvLoader.configs[i].name] = require("csv." .. CsvLoader.configs[i].parser)
		_G[CsvLoader.configs[i].name]:load(CsvLoader.configs[i].file)
	end
end

return CsvLoader


