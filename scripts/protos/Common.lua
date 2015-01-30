GameProtos["common"] = 
[[
message SceneProgress {
    optional uint32 id = 1;
    optional int32 star = 2;
    optional uint32 count = 3;
    optional uint32 resetCount = 4;
}
message MasterDetail {
	required uint32 id = 1;
	optional string name = 2;
	optional uint32 level = 3;
	optional uint32 exp = 4;
	optional uint32 health = 5;
	optional uint32 gold = 6;
	optional uint32 gem = 7;
	optional uint32 family = 8;
	optional uint32 daemoneStar = 9;
	optional uint32 magicRound = 10;
	optional uint32 magicCountermark = 11;
	optional uint32 element = 12;
	optional uint32 faction = 13;
	optional uint32 magicInherit = 14;
	optional uint32 skillPoint = 15;
    optional uint32 dailySignDone = 16;
    optional uint32 dailySignCounter = 17;
    optional uint32 guiderProgress = 18;
    repeated uint32 sceneLastLineupIds = 19;
    optional uint32 pictureId = 20;
}

message HeroDetail {
    required uint32 id = 1;
    optional uint32 type = 2;
    optional uint32 level = 3;
    optional uint32 exp = 4;
    optional uint32 starLevel = 5;
    optional uint32 grade = 6;
    optional string skillLevelJson = 7;
    optional string equipmentJson = 8;
    optional uint32 str1 = 9;
    optional uint32 str2 = 10;
    optional uint32 agi1 = 11;
    optional uint32 agi2 = 12;
    optional uint32 intl1 = 13;
    optional uint32 intl2 = 14;
    optional uint32 hp1 = 15;
    optional uint32 hp2 = 16;
    optional uint32 dc1 = 17;
    optional uint32 dc2 = 18;
    optional uint32 mc1 = 19;
    optional uint32 mc2 = 20;
    optional uint32 def1 = 21;
    optional uint32 def2 = 22;
    optional uint32 mdef1 = 23;
    optional uint32 mdef2 = 24;
    optional uint32 crit1 = 25;
    optional uint32 crit2 = 26;
    optional uint32 mcrit1 = 27;
    optional uint32 mcrit2 = 28;
    optional uint32 hprec1 = 29;
    optional uint32 hprec2 = 30;
    optional uint32 mprec1 = 31;
    optional uint32 mprec2 = 32;
    optional uint32 eva1 = 33;
    optional uint32 eva2 = 34;
    optional uint32 hit1 = 35;
    optional uint32 hit2 = 36;
    optional uint32 idef1 = 37;
    optional uint32 idef2 = 38;
    optional uint32 imdef1 = 39;
    optional uint32 imdef2 = 40;
    optional uint32 treatAddition1 = 41;
    optional uint32 treatAddition2 = 42;
    optional uint32 manaCostReduce1 = 43;
    optional uint32 manaCostReduce2 = 44;
    optional uint32 suck1 = 45;
    optional uint32 suck2 = 46;
    optional uint32 skillLevelInc = 47;
    optional uint32 score = 48;
}

message UnitDetail {
    message Skill {
        optional uint32 id = 1;
        optional uint32 level =2;
    }
    optional uint32 id = 1;
    optional uint32 type = 2;
    optional uint32 level = 3;
    optional uint32 exp = 4;
    optional uint32 starLevel = 5;
    optional uint32 grade = 6;
    repeated Skill  skills = 7;
    optional uint32 curHp = 8;
    optional uint32 str = 9;
    optional uint32 agi = 10;
    optional uint32 intl = 11;
    optional uint32 hp = 12;
    optional uint32 dc = 13;
    optional uint32 mc = 14;
    optional uint32 def = 15;
    optional uint32 mdef = 16;
    optional uint32 crit = 17;
    optional uint32 mcrit = 18;
    optional uint32 hprec = 19;
    optional uint32 mprec = 20;
    optional uint32 eva = 21;
    optional uint32 hit = 22;
    optional uint32 idef = 23;
    optional uint32 imdef = 24;
    optional uint32 treatAddition = 25;
    optional uint32 manaCostReduce = 26;
    optional uint32 suck = 27;
    optional uint32 curMana = 28;
    optional uint32 score = 29;
}

message KeyValuePair {
	optional string key = 1;
	optional uint32 value = 2;
}

message SysErrMsg {
	required uint32 errCode = 1;
	optional uint32 param1 = 2;
	optional uint32 param2 = 3;
	optional uint32 param3 = 4;
	optional uint32 param4 = 5;
}

message SimpleEvent {
	optional uint32 masterId = 1;
	optional uint32 param1 = 2;
	optional uint32 param2 = 3;
	optional uint32 param3 = 4;
	optional uint32 param4 = 5;
}

message ItemDetail {
	optional uint32 id = 1;
	optional uint32 count = 2;
}


message MailDetail {
    required uint32 id = 1;
    optional string addresser = 2;
    repeated ItemDetail attachments = 3;
	optional string subject = 4;
	optional string body = 5;
    optional uint32 createTime = 6;
    optional uint32 readTime = 7;//这个值等于0未读，大于0已读，已读的邮件就别发readRequest了
}

message DailySignResponse {
    optional uint32 masterId = 1;
    optional uint32 status = 2;
    optional uint32 dailySignCounter = 3;
    optional uint32 gem = 4;
    repeated ItemDetail items = 5;
    repeated HeroDetail heros = 6;
}

message HeroExp {
    optional uint32 id = 1;
    optional uint32 level = 2;
    optional uint32 exp = 3;
}


message SystemNotify {
    enum NotifyType {
        mail = 1;//有新邮件时推送，前端调用MailListRequest接口即可
        dailyActivity = 2;//有每日活动完成时推送，前端调用DailyActivityListRequest接口即可
        dailyReset = 3;//每日数据清理，具体数据如下：
        //所有每日活动数据重置，只需要调用DailyActivityListRequest接口刷新本地每日活动所有数据
        //体力购买次数，
        //金币购买次数，
        //青铜、白银法阵免费次数
        //技能点购买次数，
        //初级、中级、高级，pvp商店手动刷新次数
        //一键完成每日任务的每天使用次数
        //todo
        //待补充...
    }
    required NotifyType type = 1;
}
message DailyActivityDetail {
    optional uint32 id = 1;
    optional uint32 count = 2;
    optional uint32 isClaimed = 3; //0-未领取，1-已经领取
}

message DailyData {
    optional uint32 healthBuytimes = 1;
    optional uint32 goldBuytimes = 2;
    optional uint32 bronzeCapsuleProgress = 3;
    optional uint32 silverCapsuleProgress = 4;
    optional uint32 skillPointProgress = 5;
    optional uint32 primaryStoreRefreshProgress = 6;
    optional uint32 middleStoreRefreshProgress = 7;
    optional uint32 advancedStoreRefreshProgress = 8;
    optional uint32 pvpStoreRefreshProgress = 9;
    optional uint32 dailySignCounter = 10;
    optional uint32 dailySignDone = 11;
    optional uint32 pvpCount = 12;
    optional uint32 pvpResetCount = 13;
    optional uint32 pvpResetCdCount = 14;
    optional uint32 autoCompleteDailyActivitiesProgress = 15;
}

]]
