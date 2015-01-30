GameProtos["gm"] =
[[
message GmSetMasterPropertyRequest {
	required uint32 masterId = 1;	
	required string key = 2; 
	required string value  = 3;
}

message GmSetMasterPropertyResponse {
	required uint32 masterId = 1;	
	required string key = 2; 
	required string value  = 3;
}

message GmSetItemPropertyRequest {
	required uint32 masterId = 1;
	optional uint32 id = 2;
	optional uint32 count = 3;
	optional bool clear = 4;
}

message GmSetItemPropertyResponse {
	required uint32 masterId = 1;
	optional uint32 id = 2;
	optional uint32 count = 3;
	optional bool clear = 4;
}

message GmSetHeroPropertyRequest {
	required uint32 masterId = 1;
	optional uint32 heroId = 2;
	optional string key = 3;
	optional string value = 4;
	optional bool clear = 5;
}

message GmSetHeroPropertyResponse {
	required uint32 masterId = 1;
	optional uint32 heroId = 2;
	optional string key = 3;
	optional uint32 value = 4;
	optional bool clear = 5;
}

]]
