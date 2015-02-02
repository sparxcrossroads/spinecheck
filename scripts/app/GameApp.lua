
require("config")
require("framework.init")
require("framework.shortcodes")
-- require("pub.init")
require("utils.init")



local gameApp = class("gameApp", cc.mvc.AppBase)

function gameApp:ctor()
    gameApp.super.ctor(self)

end

function gameApp:run()
	CCFileUtils:sharedFileUtils():addSearchPath(device.writablePath .. "res/")
    CCFileUtils:sharedFileUtils():addSearchPath("res/")
    -- switchScene("battle",{battleType = "PVE"})
    self:enterScene("battle.scene")


end

return gameApp
