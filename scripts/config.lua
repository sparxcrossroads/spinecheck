
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 1

-- display FPS stats on screen
DEBUG_FPS = true

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "portrait"

-- design resolution
CONFIG_SCREEN_WIDTH  = 1280
CONFIG_SCREEN_HEIGHT = 720

-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"

--1.本地服务 2.CI服务  3.外网服务
NET_LOCATION = 2

--选服页面开关：
SHOW_SERVER_SELECT = true

CHECK_CSV_DEBUG = true --表格检查工具开关

--默认应该为nil
--输入他人账id可登陆，但对方被踢掉；
--测试期间登陆前请告知对方；
LOGIN_USER_ID = nil

-- 发版本时注释掉 去除视图调试信息 
-- DEBUG_RELEASE = true

--单机战斗测试 联网时注释掉
BATTLE_LOCATION = true 
