
local SceneProgress = class("SceneProgress")

SceneProgress.pbField = {
    "id", "star", "count", "resetCount"
}

function SceneProgress:ctor(pbSource)
	if pbSource ~= nil then
    	for _, field in pairs(self.class.pbField) do
        	self[field] = pbSource[field]
    	end 
	end
end

function SceneProgress:getSceneType()
	return math.floor(self.id/SCENE_TYPE_RATE)
end

function SceneProgress:getChapter()
	return math.floor(self.id/SCENE_CHAPTER_RATE)
end

return SceneProgress
