GameProtos["dailyActivity"] =
[[

message DailyActivityListResponse {
	required uint32 status = 1;
    repeated DailyActivityDetail dailyActivities = 2;
}

message DailyActivityClaimRequest {
	required uint32 dailyActivityId = 1;
}

message DailyActivityClaimResponse {
	required uint32 status = 1;
	repeated ItemDetail items = 2;
	optional MasterDetail masterInfo = 3;
    optional DailyActivityDetail dailyActivity = 4;
}

message DailyActivityAutoCompleteResponse {
	required uint32 status = 1;
	repeated ItemDetail items = 2;
	optional MasterDetail masterInfo = 3;
    repeated DailyActivityDetail dailyActivities = 4;
    optional uint32 progress = 5;
}
]]
