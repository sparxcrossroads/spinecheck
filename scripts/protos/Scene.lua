GameProtos["scene"] =
[[

message FightItems{
    required uint32 heroId = 1;
    repeated ItemDetail items = 2; //战斗掉落
}

message FightResult{
    message frameOp {    
        required uint32 frameIndex = 1;               //某一帧
        repeated uint32 soldiersIndex = 2;             //该帧对应的玩家操作
    }

    message SoldierStatistics
    {
        required uint32 soldierIndex = 1;               //队员编号
        required uint32 soldierHurt = 2;                //伤害统计
        required uint32 soldierCurhp = 3;               //当前生命
        required uint32 soldierCurEnergy = 4;           //当前能量

    }

    required uint32 endFrameIndex = 1;                  //战斗在第几帧结束了
    repeated frameOp userops = 2;                       //左军操作
    repeated SoldierStatistics herosStatistics = 3;     //左军伤害，生命，能量
    repeated SoldierStatistics enemiesStatistics = 4;   //右军伤害，生命，能量
    required uint32 magicNumber = 5;                    //下一次随机= =!
}

message SceneFightPrepareRequest {
    required uint32 sceneId = 1;
    optional uint32 fightNo = 2;    //副本第几次战斗
    repeated uint32 heroIds = 3;  // fightNo = 1时才读取 
}

message SceneFightPrepareResponse {
    required uint32 status = 1;
    optional uint32 sceneId = 2;
    optional uint32 fightNo = 3; 
    optional uint32 seed = 4;   
    repeated UnitDetail heros = 5;
    repeated UnitDetail enemies = 6;
    repeated FightItems fightItems = 7;  //掉落
    optional uint32 health = 8; 
}

message SceneFightEndRequest {
    required uint32 sceneId = 1; 
    optional uint32 fightNo = 2;     
    optional FightResult endInfo = 3; 
}

message SceneFightEndResponse {
    required uint32 status = 1;
    optional uint32 sceneId = 2; 
    optional uint32 fightNo = 3;            
}

message SceneEndRequest {
    required uint32 sceneId = 1;
}

message SceneEndResponse {
 
    required uint32 status = 1; 
    optional uint32 sceneId = 2;    
    optional int32 star = 3;  //star = 0 表示超时，-1表示副本失败
    repeated FightItems fightItems = 4;
    optional uint32 exp = 5; 
    optional uint32 level = 6;  
    repeated HeroExp heroExps = 7;
    optional uint32 gold = 8; 
    required uint32 health = 9;
    required uint32 count = 10; 
}

message SceneResetRequest {
    required uint32 sceneId = 1;   
}

message SceneResetResponse {
    required uint32 status = 1;
    optional uint32 sceneId = 2;
    optional uint32 count = 3;     
}

message SceneSweepRequest{
    required uint32 sceneId = 1; 
    optional uint32 count = 2;
}

message SweepItems {
    optional uint32 seq = 1;
    repeated ItemDetail items = 2;
}
message SceneSweepResponse {
    required uint32 status = 1; 
    optional uint32 sceneId = 2;
    repeated SweepItems sweepItems = 3;
    optional uint32 exp = 4; 
    optional uint32 level = 5;  
    repeated ItemDetail extreItems = 6;
    optional uint32 gold = 7; 
    optional uint32 health = 8; 
    optional uint32 count = 9;
    optional uint32 sweepItemsCount = 10;
}

]]
