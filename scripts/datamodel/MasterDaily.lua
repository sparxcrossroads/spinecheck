local MasterDaily = class("MasterDaily")

MasterDaily.pbField = {
	"healthBuytimes", "goldBuytimes","bronzeCapsuleProgress","silverCapsuleProgress","skillPointProgress",
	"primaryStoreRefreshProgress","middleStoreRefreshProgress","advancedStoreRefreshProgress","pvpStoreRefreshProgress",
	"dailySignCounter","dailySignDone","pvpCount","pvpResetCount","pvpResetCdCount","autoCompleteDailyActivitiesProgress"
}

function MasterDaily:ctor(pbSource)
	for _, field in pairs(self.class.pbField) do
		self[field] = pbSource[field]
	end	
end

return MasterDaily