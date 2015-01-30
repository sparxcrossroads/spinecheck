local MapHight = 240 --地图高度
local MapWidth = 1280 --地图宽度

BattleConstants = {}

-- 行列值为两边行列数，多生成一行中间行
BattleConstants.RowMax = 3
BattleConstants.cellSize = MapHight/(2*3+1)
BattleConstants.ColMax = math.floor((MapWidth / BattleConstants.cellSize - 1) / 2)
BattleConstants.Positions = {}

--重力常数
BattleConstants.ConstantG = 0.05

function BattleConstants:generateMap()
	for col=-self.ColMax,self.ColMax do
		table.insert(self.Positions,col,{})
		for row=-self.RowMax, self.RowMax do
			local y = display.cy + self.cellSize*(row-0.5)
			local x = MapWidth/2 + col*self.cellSize
			table.insert(self.Positions[col],row,{x = x, y = y})
		end
	end
	return self.Positions
end


--根据anchPoint得到像素坐标
function BattleConstants:anchToPosition(anchPoint)
	local y = display.cy + self.cellSize * (anchPoint.y - 0.5)
	local x = MapWidth/2 + anchPoint.x * self.cellSize
	return {x = x, y = y}
end



--根据队员编号index和阵营camp得到战场的格子坐标
--参数限制
--index: 1 2 3 4 5
--camp:  "left" "right"
function BattleConstants:indexToAnch(index, camp)
--	local ret = {
--		["leftAnchConfig"] = {
--			[1] = {-18, 1},
--			[2] = {-21, -1},
--			[3] = {-24, 1},
--			[4] = {-27, -1},
--			[5] = {-30, 1}
--		},

--		["rightAnchConfig"] = {
--			[1] = {18, 1},
--			[2] = {21, -1},
--			[3] = {24, 1},
--			[4] = {27, -1},
--			[5] = {30, 1},
--		}
--	}

--	if index <=0 or index > 5 or 
--		(camp ~= "left" and camp ~= "right") then
--		print("index="..tostring(index))
--		print("camp="..tostring(camp))
--		print("indexToAnch异常:"..debug.traceback())
--		return
--	end 
	local x = 15 + 3 * index
	local y = -1 + (index % 2) * 2
	if camp == "left" then x = - x end
	return x,y

	--return unpack(ret[camp.."AnchConfig"][index])
end

function BattleConstants:positionToAnch(x,y)
	local col = math.round((x-MapWidth/2)/self.cellSize)
	local row = math.round((y-display.cy)/self.cellSize)
	return col,row
end

DEBUG_LEVEL=3
