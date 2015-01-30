--[[--

Split a string by string to map, string format like "123=2 222=3"

@param string str
@param string delimiter
@return map(note: type(key) == "string")

]]
function string.tomap(str, delimiter)
    str = str or ""
    delimiter = delimiter or " "
    local map = {}
    local array = string.split(string.trim(str), delimiter)
    for _, value in ipairs(array) do
        value = string.split(string.trim(value), "=")
        if #value == 2 then
            map[value[1]] = value[2]
        elseif value[1] ~= "" then
            print("string.tomap  "..str )
            print(debug.traceback())
        end
    end

    return map
end

--以数字形式存储
function string.toNumMap(str, delimiter)
    str = str or ""
    delimiter = delimiter or " "
    local map = {}
    local array = string.split(string.trim(str), delimiter)
    for _, value in ipairs(array) do
        value = string.split(string.trim(value), "=")
        if #value == 2 then
            map[tonumber(value[1])] = tonumber(value[2])
        elseif string.trim(value[1])~="" then
            print("string.toNumMap  "..str )
            print(debug.traceback())
        end
    end

    return map
end

-- 1=2001:2;2002:1 2=2001:2;2002:1 3=2001:2;2002:2
--   map[1] = {2001 = 2, 2002 = 1}
function string.toNestedNumMap(str, delimiter)
    str = str or ""
    delimiter = delimiter or " "
    local map = {}
    local array = string.split(string.trim(str), delimiter)
    for _, value in ipairs(array) do
        local value1 = string.split(string.trim(value), "=")
        if #value1 == 2 then
            local subValue = string.gsub(string.trim(value1[2]), ":", "=")
            local subValue1 = string.gsub(string.trim(subValue), ";", " ")
            map[tonumber(value1[1])] = string.toNumMap(subValue1)
        elseif string.trim(value1[1])~="" then
            print("string.toNestedNumMap  "..str )
            print(debug.traceback())
        end
    end
    return map
end

-- 将"1 2 3 4" 分割成{"1", "2", "3", "4"}，默认分隔符，空格
-- 若传入第三个参数为"number"，则分割成{1,2,3,4}
function string.toArray(str, delimiter, elemeType,sum)
    --TODO表格检查
    str = str or ""
    delimiter = delimiter or " "
    local array = {}
    local tempArray = string.split(string.trim(str), delimiter)
    if sum ~= nil and #tempArray ~= sum then
        print("string.toArray  "..str )
        print(debug.traceback())
    end
    for _, value in ipairs(tempArray) do
        if string.trim(value) ~= "" then
            if elemeType and elemeType == "number" then value = tonumber(value) end
            table.insert(array, value)
        end
    end

    return array
end

-- 将"1=2=3 4=5=6" 分割成{{"1", "2", "3"}, {"4", "5", "6"}}
function string.toTableArray(str, delimiter, sum)
    --TODO
    str = str or ""
    delimiter = delimiter or " "
    local array = {}
    local tempArray = string.split(string.trim(str), delimiter)
    for _, value in ipairs(tempArray) do
        local trimValue = string.trim(value)
        if trimValue ~= "" then
            value = string.split(trimValue, "=")
            if sum ~= nil then
                if sum == #value then
                    table.insert(array, value)
                else
                    print("string.toTableArray  "..str )
                    print(debug.traceback())
                end
            else
                table.insert(array, value)
            end
        end
    end

    return array
end

-- 将string转化为多行
function string.toLineArray(s)
    local ts = {}
    local posa = 1
    while 1 do
        local pos, chars = s:match('()([\r\n].?)', posa)
        if pos then
            local line = s:sub(posa, pos - 1)
            ts[#ts + 1] = line
            if chars == '\r\n' then pos = pos + 1 end
            posa = pos + 1
        else
            local line = s:sub(posa)
            if line ~= '' then ts[#ts + 1] = line end
            break
        end
	end
	return ts
end
