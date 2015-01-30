GameProtos["capsule"] =
[[

message CapsuleFreeDrawInfo {
    optional uint32 count = 1;//当天已经使用是次数
    optional uint32 seconds = 2;//剩余秒数
}

message CapsuleFreeDrawInfoResponse {
	required uint32 status = 1;
    optional CapsuleFreeDrawInfo bronze = 2;
    optional CapsuleFreeDrawInfo silver = 3;
}

message CapsuleDrawRequest {
    enum CapsuleType {
        bronze = 1;
        silver = 2;
        gold = 3;
    }
    enum DrawType {
        single = 1;
        multiple = 2;
    }
	required CapsuleType capsuleType = 1;
	required DrawType drawType = 2;
}

message CapsuleDrawResponse {
	required uint32 status = 1;
	optional uint32 gold = 2;
	optional uint32 gem = 3;
    repeated ItemDetail additionalItems = 4;
    optional ItemDetail defaultItem = 5;
    repeated HeroDetail heros = 6;
    optional CapsuleFreeDrawInfo bronze = 7;
    optional CapsuleFreeDrawInfo silver = 8;
}

]]
