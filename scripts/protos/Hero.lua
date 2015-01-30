GameProtos["hero"] =
[[
message HeroUpdateProperty {
    required uint32 id = 1;
    required string key = 2;
    optional string newValue = 3;
    optional string oldValue = 4;
}

message HeroSkillLevelUpRequest {
	required uint32 heroId = 1;
	required uint32 skillId = 2;
}
message HeroSkillLevelUpResponse {
    required uint32 status = 1;
	optional uint32 gold = 2;
	optional uint32 skillPoint = 3;
	optional uint32 skillId = 4;
	optional uint32 skillLevel = 5;
	optional HeroDetail heroDetail = 6;
}

message HeroStarLevelUpRequest {
	required uint32 heroType = 1;//英灵类型，即unit.csv的英灵id字段
	optional uint32 heroId = 2;//第一次召唤时，即玩家未拥有这个英灵时，可以不用填这个字段，但在英灵的信息界面上再次召唤它时，
	                           //必须填上这个字段，这个id是由后端返回给前端的，可以理解为背包中的id
}

message HeroStarLevelUpResponse {
    required uint32 status = 1;
	optional uint32 gold = 2;
	optional ItemDetail itemDetail = 3;
    optional HeroDetail heroDetail = 4;
}

message HeroEquipRequest {
	required uint32 heroId = 1;
	required uint32 equipmentPos = 2;//英灵身上的装备位
}

message HeroEquipResponse {
    required uint32 status = 1;
	optional ItemDetail itemDetail = 2;
    optional HeroDetail heroDetail = 3;
}

message HeroComposeRequest {
	required uint32 equipmentId = 1;//目标装备
}

message HeroComposeResponse {
    required uint32 status = 1;
	optional uint32 gold = 2;
	repeated ItemDetail items = 3;
}

message StrengthenRequest {
	required uint32 heroId = 1;
	required uint32 equipmentPos = 2;//英灵身上的装备位
	repeated ItemDetail items = 3;//装备，道具等都可以放进来
}

message HeroFuseRequest {
	required uint32 heroId = 1;
}

message HeroFuseResponse {
    required uint32 status = 1;
    optional HeroDetail heroDetail = 2;
    repeated ItemDetail items = 3;//强化过的装备，融合后会返回一定的强化材料
}

message HeroAutoEquipRequest {
	required uint32 heroId = 1;
}

message HeroAutoEquipResponse {
    required uint32 status = 1;
    repeated ItemDetail totalCostItems = 2;//所有消耗掉的道具id及消耗的数量，变动值，包括消耗的金币数量，不包括被装备上去的那件装备，展示用
    repeated uint32 equipedEquipments = 3; //所有被装备的装备的id，展示用
    optional uint32 gold = 4; //账号剩余金币总数
    repeated ItemDetail items = 5;//所有数量有变动的道具及剩余总数
    optional HeroDetail heroDetail = 6;
}

]]