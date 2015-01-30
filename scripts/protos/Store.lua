GameProtos["store"] =
[[

message StoreListRequest {
    enum StoreType {
        primary = 1;
        middle = 2;
        advanced = 3;
        pvp = 4;
    }
	required StoreType storeType = 1;
}

message StoreListResponse {
	required uint32 status = 1;
	optional string storeListJson = 2;
    optional uint32 refreshUntil = 3;
    optional uint32 refreshProgress = 4;
    optional uint32 expireUntil = 5;
    //expireUntil说明
    //初级商店，pvp商店值一般为0，前端忽略
    //中级商店，高级商店:
    //vip等级不足但是因为打副本而临时开启的情况，会是一个大于当前时间的值，unixtime
    //vip等级满足永久开启中级、高级商店的情况，这个值基本上会是小于当前时间的值，前端也忽略这个值
}

message StoreManualRefreshRequest {
    enum StoreType {
        primary = 1;
        middle = 2;
        advanced = 3;
        pvp = 4;
    }
	required StoreType storeType = 1;
}

message StoreManualRefreshResponse {
	required uint32 status = 1;
	optional string storeListJson = 2;
    optional uint32 gem = 3;
    optional uint32 pvpGold = 4;
    optional uint32 refreshProgress = 5;
}
message StoreBuyRequest {
    enum StoreType {
        primary = 1;
        middle = 2;
        advanced = 3;
        pvp = 4;
    }
	required StoreType storeType = 1;
	required uint32 index = 2;
}

message StoreBuyResponse {
	required uint32 status = 1;
	optional uint32 gold = 2;
	optional uint32 gem = 3;
	optional uint32 pvpGold = 4;
	optional string storeListJson = 5;
    optional ItemDetail item = 6;
}

message StoreIsOpenResponse {
	required uint32 status = 1;
	required bool middle = 2;
	required bool advanced = 3;
}

message StoreSellGoldenResponse {
    required uint32 status = 1;
    optional uint32 gold = 2;
}

]]
