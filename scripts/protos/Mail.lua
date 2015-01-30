GameProtos["mail"] =
[[

message MailClaimRequest {
	required uint32 mailId = 1;
}

message MailClaimResponse {
	required uint32 status = 1;
	optional uint32 gem = 2;
	optional uint32 gold = 3;
	repeated ItemDetail items = 4;
    repeated HeroDetail heros = 5;
}

message MailReadRequest {
	required uint32 mailId = 1;
}

message MailReadResponse {
	required uint32 status = 1;
}

message MailSendRequest {
    optional uint32 mailTypeId = 1;
    optional string addresser = 2;
    repeated ItemDetail attachments = 3;
    optional string subject = 4;
    optional string body = 5;
}

message MailSendResponse {
	required uint32 status = 1;
}

message MailListResponse {
	required uint32 status = 1;
	repeated MailDetail mails = 2;
}

]]
