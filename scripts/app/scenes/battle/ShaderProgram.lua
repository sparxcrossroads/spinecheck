local ShaderProgram = {}
local ShaderRes = "res/resource/shader/"
function ShaderProgram.init(shaderName)
    local shader = CCGLProgram:new()
    shader:initWithVertexShaderFilename(ShaderRes..shaderName..".vsh",ShaderRes..shaderName..".fsh")
    shader:addAttribute("a_position",0)
    shader:addAttribute("a_color",1)
    shader:addAttribute("a_texCoord",2)
    shader:link()
    shader:updateUniforms()
    return shader
end

function ShaderProgram.clear()
    -- 原始shader
    return  CCShaderCache:sharedShaderCache():programForKey("ShaderPositionTextureColor")
end

return ShaderProgram

