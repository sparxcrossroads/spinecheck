function tableKeyValyeExchange(table)
    local enumTable = {}
    for i, v in pairs(table) do
        enumTable[v] =  i
    end
    return enumTable
end

actionCodesOrigin = {
    "HeartBeat",
    "ClientDisconnect",
    "SysErrorMsg",
    "SysUpdateTime",
    "MasterKickOff" ,
    "SystemNotify",

    "MasterCreateRequest",
    "MasterCreateResponse",
    "MasterQueryLoginRequest",
    "MasterQueryLoginResponse",
    "MasterLoginRequest",
    "MasterLoginResponse",
    "MasterBuyHealthRequest",
    "MasterBuyHealthResponse",
    "MasterBuyGoldRequest",
    "MasterBuyGoldResponse" ,
    "MasterBuySkillPointRequest" ,
    "MasterBuySkillPointResponse" ,
    "MasterSkillPointInfoRequest" ,
    "MasterSkillPointInfoResponse" ,
    "MasterDailySignRequest",
    "MasterDailySignResponse",
    "MasterUpdateGuiderProgressRequest",
    "MasterUpdateGuiderProgressResponse",
    "MasterUpdatePropertyRequest",
    "MasterUpdatePropertyResponse",
    "MasterSetNameRequest",
    "MasterSetNameResponse",
    "MasterSetPictureIdRequest",
    "MasterSetPictureIdResponse",
    "MasterNeedReloginResponse",

    "HeroSkillLevelUpRequest",
    "HeroSkillLevelUpResponse",
    "HeroUpdateProperty",
    "HeroStarLevelUpRequest",
    "HeroStarLevelUpResponse",
    "HeroEquipRequest",
    "HeroEquipResponse",
    "HeroComposeRequest",
    "HeroComposeResponse",
    "HeroStrengthenRequest",
    "HeroStrengthenResponse",
    "HeroFuseRequest",
    "HeroFuseResponse",
    "HeroAutoEquipRequest",
    "HeroAutoEquipResponse",


    "PackageGetAllItemsRequest",
    "PackageGetAllItemsResponse",
    "PackageSellItemsRequest",
    "PackageSellItemsResponse",
    "PackageUseItemsRequest",
    "PackageUseItemsResponse",

    "CapsuleFreeDrawInfoRequest",
    "CapsuleFreeDrawInfoResponse",
    "CapsuleDrawRequest",
    "CapsuleDrawResponse",

    "SceneFightPrepareRequest",
    "SceneFightPrepareResponse",
    "SceneFightEndRequest",
    "SceneFightEndResponse",
    "SceneEndRequest",
    "SceneEndResponse",
    "SceneResetRequest",
    "SceneResetResponse",
    "SceneSweepRequest",
    "SceneSweepResponse",
    "SceneResetRequest",
    "SceneResetResponse",

    "StoreListRequest",
    "StoreListResponse",
    "StoreManualRefreshRequest",
    "StoreManualRefreshResponse",
    "StoreBuyRequest",
    "StoreBuyResponse",
    "StoreIsOpenRequest",
    "StoreIsOpenResponse",
    "StoreSellGoldenRequest",
    "StoreSellGoldenResponse",

    "GmSetMasterPropertyRequest",
    "GmSetMasterPropertyResponse",
    "GmSetItemPropertyRequest",
    "GmSetItemPropertyResponse",
    "GmSetHeroPropertyRequest",
    "GmSetHeroPropertyResponse",

    "MailClaimRequest",
    "MailClaimResponse",
    "MailReadRequest",
    "MailReadResponse",
    "MailSendRequest",
    "MailSendResponse",
    "MailListRequest",
    "MailListResponse",

    "PvpFightRequest",
    "PvpFightResponse",
    "PvpReplayRequest",
    "PvpReplayResponse",
    "PvpResetCountRequest",
    "PvpResetCountResponse",
    "PvpResetCdRequest",
    "PvpResetCdResponse",
    "PvpSetLineupIdsRequest",
    "PvpSetLineupIdsResponse",
    "PvpFindEnemyRequest",
    "PvpFindEnemyResponse",
    "PvpGetInfoRequest",
    "PvpGetInfoResponse",
    "PvpGetRecordRequest",
    "PvpGetRecordResponse",
    "PvpGetRankListRequest",
    "PvpGetRankListResponse",

    "DailyActivityListRequest",
    "DailyActivityListResponse",
    "DailyActivityClaimRequest",
    "DailyActivityClaimResponse",
    "DailyActivityAutoCompleteRequest",
    "DailyActivityAutoCompleteResponse",
}

actionCodes = tableKeyValyeExchange(actionCodesOrigin)

actionModules = {
    [actionCodes.ClientDisconnect] = "System.disconnectMaster",
    [actionCodes.SysErrorMsg] = "System.handleErrorMsg",
    [actionCodes.SysUpdateTime] = "System.updateTime",
    [actionCodes.SystemNotify] = "System.notify",

    [actionCodes.MasterCreateRequest] = "Master.createRequest",
    [actionCodes.MasterCreateResponse] = "Master.createResponse",
    [actionCodes.MasterQueryLoginRequest] = "Master.queryLoginRequest",
    [actionCodes.MasterQueryLoginResponse] = "Master.queryLoginResponse",
    [actionCodes.MasterLoginRequest] = "Master.loginRequest",
    [actionCodes.MasterLoginResponse] = "Master.loginResponse",
    [actionCodes.MasterBuyHealthRequest] = "Master.buyHealthRequest",
    [actionCodes.MasterBuyHealthResponse] = "Master.buyHealthResponse",
    [actionCodes.MasterBuyGoldRequest] = "Master.buyGoldRequest",
    [actionCodes.MasterBuyGoldResponse] = "Master.buyGoldResponse",
    [actionCodes.MasterKickOff] = "Master.kickOff",
    [actionCodes.MasterBuySkillPointRequest] = "Master.buySkillPointRequest",
    [actionCodes.MasterBuySkillPointResponse] = "Master.buySkillPointResponse",
    [actionCodes.MasterSkillPointInfoRequest] = "Master.skillPointInfoRequest",
    [actionCodes.MasterSkillPointInfoResponse] = "Master.skillPointInfoResponse",
    [actionCodes.MasterDailySignRequest] = "Master.dailySignRequest",
    [actionCodes.MasterDailySignResponse] = "Master.dailySignResponse",
    [actionCodes.MasterUpdateGuiderProgressRequest] = "Master.updateGuiderProgressRequest",
    [actionCodes.MasterUpdateGuiderProgressResponse] = "Master.updateGuiderProgressResponse",
    [actionCodes.MasterUpdatePropertyResponse] = "Master.updatePropertyResponse",
    [actionCodes.MasterSetNameRequest] = "Master.setNameRequest",
    [actionCodes.MasterSetNameResponse] = "Master.setNameResponse",
    [actionCodes.MasterSetPictureIdRequest] = "Master.setPictureIdRequest",
    [actionCodes.MasterSetPictureIdResponse] = "Master.setPictureIdResponse",
    [actionCodes.MasterNeedReloginResponse] = "Master.needReloginResponse",
    

    [actionCodes.HeroSkillLevelUpRequest] = "Hero.skillLevelUpRequest",
    [actionCodes.HeroSkillLevelUpResponse] = "Hero.skillLevelUpResponse",
    [actionCodes.HeroUpdateProperty] = "Hero.updateProperty",
    [actionCodes.HeroStarLevelUpRequest] = "Hero.starLevelUpRequest",
    [actionCodes.HeroStarLevelUpResponse] = "Hero.starLevelUpResponse",
    [actionCodes.HeroEquipRequest] = "Hero.equipRequest",
    [actionCodes.HeroEquipResponse] = "Hero.equipResponse",
    [actionCodes.HeroComposeRequest] = "Hero.composeRequest",
    [actionCodes.HeroComposeResponse] = "Hero.composeResponse",
    [actionCodes.HeroStrengthenRequest] = "Hero.strengthenRequest",
    [actionCodes.HeroStrengthenResponse] = "Hero.strengthenResponse",
    [actionCodes.HeroFuseRequest] = "Hero.fuseRequest",
    [actionCodes.HeroFuseResponse] = "Hero.fuseResponse",
    [actionCodes.HeroAutoEquipRequest] = "Hero.autoEquipRequest",
    [actionCodes.HeroAutoEquipResponse] = "Hero.autoEquipResponse",

    [actionCodes.PackageGetAllItemsRequest] = "Package.getAllItemsRequest",
    [actionCodes.PackageGetAllItemsResponse] = "Package.getAllItemsResponse",
    [actionCodes.PackageSellItemsRequest] = "Package.sellItemsRequest",
    [actionCodes.PackageSellItemsResponse] = "Package.sellItemsResponse",
    [actionCodes.PackageUseItemsRequest] = "Package.useItemsRequest",
    [actionCodes.PackageUseItemsResponse] = "Package.useItemsResponse",

    [actionCodes.CapsuleFreeDrawInfoRequest] = "Capsule.freeDrawInfoRequest",
    [actionCodes.CapsuleFreeDrawInfoResponse] = "Capsule.freeDrawInfoResponse",
    [actionCodes.CapsuleDrawRequest] = "Capsule.drawRequest",
    [actionCodes.CapsuleDrawResponse] = "Capsule.drawResponse",

    [actionCodes.SceneFightPrepareRequest] = "Scene.fightPrepareRequest",
    [actionCodes.SceneFightPrepareResponse] = "Scene.fightPrepareResponse",
    [actionCodes.SceneFightEndRequest] = "Scene.fightEndRequest",
    [actionCodes.SceneFightEndResponse] = "Scene.fightEndResponse",
    [actionCodes.SceneEndRequest] = "Scene.endRequest",
    [actionCodes.SceneEndResponse] = "Scene.endResponse",
    [actionCodes.SceneResetRequest] = "Scene.resetRequest",
    [actionCodes.SceneResetResponse] = "Scene.resetResponse",
    [actionCodes.SceneSweepRequest] = "Scene.sweepRequest",
    [actionCodes.SceneSweepResponse] = "Scene.sweepResponse",
    [actionCodes.SceneResetRequest] = "Scene.resetRequest",
    [actionCodes.SceneResetResponse] = "Scene.resetResponse", 

    [actionCodes.StoreListRequest] = "Store.listRequest",
    [actionCodes.StoreListResponse] = "Store.listResponse",
    [actionCodes.StoreManualRefreshRequest] = "Store.manualRefreshRequest",
    [actionCodes.StoreManualRefreshResponse] = "Store.manualRefreshResponse",
    [actionCodes.StoreBuyRequest] = "Store.buyRequest",
    [actionCodes.StoreBuyResponse] = "Store.buyResponse",
    [actionCodes.StoreIsOpenRequest] = "Store.isOpenRequest",
    [actionCodes.StoreIsOpenResponse] = "Store.isOpenResponse",
    [actionCodes.StoreSellGoldenRequest] = "Store.sellGoldenRequest",
    [actionCodes.StoreSellGoldenResponse] = "Store.sellGoldenResponse",
    
    [actionCodes.GmSetMasterPropertyRequest] = "Gm.setMasterPropertyRequest",
    [actionCodes.GmSetMasterPropertyResponse] = "Gm.setMasterPropertyResponse",
    [actionCodes.GmSetItemPropertyRequest] = "Gm.setItemPropertyRequest",
    [actionCodes.GmSetItemPropertyResponse] = "Gm.setItemPropertyResponse",
    [actionCodes.GmSetHeroPropertyRequest] = "Gm.setHeroPropertyRequest",
    [actionCodes.GmSetHeroPropertyResponse] = "Gm.setHeroPropertyResponse",

    [actionCodes.MailClaimRequest] = "Mail.claimRequest",
    [actionCodes.MailClaimResponse] = "Mail.claimResponse",
    [actionCodes.MailReadRequest] = "Mail.readRequest",
    [actionCodes.MailReadResponse] = "Mail.readResponse",
    [actionCodes.MailSendRequest] = "Mail.sendRequest",
    [actionCodes.MailSendResponse] = "Mail.sendResponse",
    [actionCodes.MailListRequest] = "Mail.listRequest",
    [actionCodes.MailListResponse] = "Mail.listResponse",

    [actionCodes.PvpFightRequest] = "Pvp.fightRequest",
    [actionCodes.PvpFightResponse] = "Pvp.fightResponse",
    [actionCodes.PvpReplayRequest] = "Pvp.replayRequest",
    [actionCodes.PvpReplayResponse] = "Pvp.replayResponse",
    [actionCodes.PvpResetCountRequest] = "Pvp.resetCountRequest",
    [actionCodes.PvpResetCountResponse] = "Pvp.resetCountResponse",
    [actionCodes.PvpResetCdRequest] = "Pvp.resetCdRequest",
    [actionCodes.PvpResetCdResponse] = "Pvp.resetCdResponse",
    [actionCodes.PvpSetLineupIdsRequest] = "Pvp.setLineupIdsRequest",
    [actionCodes.PvpSetLineupIdsResponse] = "Pvp.setLineupIdsResponse",
    [actionCodes.PvpFindEnemyRequest] = "Pvp.findEnemyRequest",
    [actionCodes.PvpFindEnemyResponse] = "Pvp.findEnemyResponse",
    [actionCodes.PvpGetInfoRequest] = "Pvp.getInfoRequest",
    [actionCodes.PvpGetInfoResponse] = "Pvp.getInfoResponse",
    [actionCodes.PvpGetRecordRequest] = "Pvp.getRecordRequest",
    [actionCodes.PvpGetRecordResponse] = "Pvp.getRecordResponse",
    [actionCodes.PvpGetRankListRequest] = "Pvp.getRankListRequest",
    [actionCodes.PvpGetRankListResponse] = "Pvp.getRankListResponse",

    [actionCodes.DailyActivityListRequest] = "DailyActivity.listRequest",
    [actionCodes.DailyActivityListResponse] = "DailyActivity.listResponse",
    [actionCodes.DailyActivityClaimRequest] = "DailyActivity.claimRequest",
    [actionCodes.DailyActivityClaimResponse] = "DailyActivity.claimResponse",
    [actionCodes.DailyActivityAutoCompleteRequest] = "DailyActivity.autoCompleteRequest",
    [actionCodes.DailyActivityAutoCompleteResponse] = "DailyActivity.autoCompleteResponse",   
}
