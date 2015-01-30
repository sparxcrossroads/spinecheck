GameProtos["master"] =
[[
message MasterQueryLoginRequest {
	required uint32 masterId = 1;
}

message MasterQueryLoginResponse {
    required uint32 status = 1;	
	optional string ret = 2; //RET_NOT_EXIST,RET_HAS_EXISTED
	optional string gameVersion = 3; 
}

message MasterCreateRequest {
	required string name = 1;
	optional uint32 reserved = 2;
}

message MasterCreateResponse {
	required uint32 status = 1;		
	optional uint32 masterId = 2;
}

message MasterLoginRequest {
	required uint32 masterId = 1;
}

message MasterLoginResponse {
	required uint32 status = 1;	
	optional MasterDetail masterInfo = 2;
	repeated HeroDetail heros = 3;
	repeated KeyValuePair timestamps = 4;
	optional uint32 serverTime = 5;
	repeated ItemDetail items = 6;
	repeated SceneProgress sceneProgress = 7;
	repeated MailDetail mails = 8;
	repeated DailyActivityDetail dailyActivities = 9;
	optional DailyData  dailyData = 10;
}

message MasterUpdateProperty {
	required string key = 1;
	optional string newValue = 2;
	optional string oldValue = 3;
	optional uint32 masterId = 4;
}

message BuyHealthResponse {    
	required uint32 status = 1;	
	optional uint32 gem = 2;
	optional uint32 health = 3;	
	optional uint32 healthBuytimes = 4;	
}

message MasterSkillPointInfoResponse {
	required uint32 status = 1;
	optional uint32 skillPoint = 2;
	optional uint32 count = 3;//当天技能点购买次数
	optional uint32 seconds = 4;//剩余秒数
}

message MasterBuySkillPointResponse {
	required uint32 status = 1;
	optional uint32 gem = 2;
	optional uint32 skillPoint = 3;
    optional uint32 count = 4;
	optional uint32 seconds = 5;
}

message BuyGoldResponse {
	required uint32 status = 1;	
	optional uint32 gem = 2;
	optional uint32 gold = 3;
	optional uint32 goldBuytimes = 4;
}

message PackageGetAllItemsResponse {
	required uint32 status = 1;	
	repeated ItemDetail items = 2;
}

message PackageSellItemsRequest {
	required uint32 id = 1;
	required uint32 count = 2;
}

message PackageSellItemsResponse {
	required uint32 status = 1;	
	optional uint32 totalGold = 2; //返回玩家所有金币
	optional uint32 id = 3;
	optional uint32 count = 4;
}

message PackageUseItemsRequestDetail {
	required uint32 heroId = 1;
	required uint32 count = 2;
	required uint32 id = 3;
}

message PackageUseItemsRequest {
        repeated PackageUseItemsRequestDetail herosUseItems = 1;
}

message PackageUseItemsResponseDetail {
	optional uint32 exp = 1; 
	optional uint32 level = 2;
	optional uint32 id = 3;
	optional uint32 count = 4; 
}

message PackageUseItemsResponse {
	required uint32 status = 1;
    repeated PackageUseItemsResponseDetail herosUseItems = 2;
}

message MasterSetNameRequest  {
	required string name = 1;
	required uint32 masterId = 2;
}

message MasterSetNameResponse {
	required uint32 status = 1;
	optional string name = 2;
}

message MasterSetPictureIdRequest  {
	required uint32 pictureId = 1;
	required uint32 masterId = 2;
}

message MasterSetPictureIdResponse {
	required uint32 status = 1;
	optional uint32 pictureId = 2;
}

message MasterNewerGuiderResponse {
        required uint32 status = 1;
        required uint32 guiderProgress = 2;
}

]]
