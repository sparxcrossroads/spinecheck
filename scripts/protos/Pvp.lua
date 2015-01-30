GameProtos["pvp"] =
[[

message PvpHero{
    optional uint32 id = 1;
    optional uint32 level = 2;
    optional uint32 grade = 3;
    optional uint32 starLevel = 4;
    optional uint32 score = 5;
    optional uint32 type = 6;
}

message PVpRecord {
    required uint32 pvpNo = 1;   
    optional uint32 seed = 2;   
    repeated UnitDetail heros = 3;
    repeated UnitDetail enemies = 4;
    optional uint32 deltaRank = 5; //rank变化，根据result结果取正负
    optional uint32 time = 6;
    optional uint32 enemyId = 7;  //等于自己则是被打
    optional string enemyName = 8;
    optional uint32 enemyLevel = 9;  
    optional int32 star = 10; //0 表示超时，-1表示副本失败, >0 表示赢了 被打则刚好相反
    optional uint32 enemyPictureId = 11;
}

message PvpFightRequest {   
    required uint32 enemyMasterId = 1;
    repeated uint32 heroIds = 2;  
}

message PvpFightResponse {
    required uint32 status = 1;
    optional PVpRecord pvpRecord = 2;
    repeated HeroExp heroExps = 3;
    optional uint32 pvpCount = 4;
    optional uint32 seconds = 5;
}

message PvpSetLineupIdsRequest {
    repeated uint32 heroIds = 1; 
}

message PvpSetLineupIdsResponse {
    required uint32 status = 1;
}

message PvpReplayRequest {
    required uint32 pvpNo = 1; 
}

message PvpReplayResponse {
    required uint32 status = 1;
    optional PVpRecord pvpRecord = 2; 
}

message PvpFindEnemyResponse {
    message PvpEnemyUnit{
    optional uint32 enemyId = 2;
    optional uint32 level = 3;
    optional string name = 4;
    optional uint32 rank = 5;
    optional uint32 pictureId = 6;
    repeated PvpHero heros = 7;
    }
    required uint32 status = 1;
    repeated PvpEnemyUnit pvpEnemyUnits = 2;
}

message PvpResetCountResponse {
    required uint32 status = 1;
    optional uint32 gem = 2;
    optional uint32 pvpCount = 3; 
    optional uint32 pvpResetCount = 4;  
}

message PvpResetCdResponse {
    required uint32 status = 1;
    optional uint32 gem = 2;
    optional uint32 pvpResetCdCount = 3;
    optional uint32 seconds = 4;  //下次可用时间，=当前服务器时间
}

message PvpGetRecordResponse {
    required uint32 status = 1;
    repeated PVpRecord pVpRecords = 2;
}

message PvpGetRankListResponse {
    message rankUnit {
    optional string name = 1;
    optional uint32 level = 2;
    optional uint32 rank = 3;
    optional uint32 pictureId = 4;
    repeated PvpHero pvpHeros = 5;
}
    required uint32 status = 1;
    repeated rankUnit rankUnits = 2;
    optional int32 deltaYestodayRank = 3;
}

message PvpGetInfoResponse {
    required uint32 status = 1;
    optional uint32 seconds = 2;
    optional uint32 pvpCount = 3;
    optional uint32 rank = 4;
    repeated PvpHero pvpHeros = 5;
    optional uint32 pvpResetCount = 6;
    optional uint32 pvpResetCdCount = 7;
    optional uint32 pvpGold = 8;
    repeated uint32 pvpLastLineupIds = 9;
}

]]