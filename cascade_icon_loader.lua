-- Cascade Icon Loader for Roblox Luau
-- Can be loaded via loadstring(game:HttpGet("https://raw.githubusercontent.com/.../cascade_icon_loader.lua"))()

local HttpService = game:GetService("HttpService")

local GITHUB_REPO = "HeNo-exp/lucide"
local GITHUB_BRANCH = "master"

-- ASSET_MAP_START
local AssetMap = {}
-- ASSET_MAP_END

local CascadeIconLoader = {}
local svgCache = {} -- Caches SVG content to prevent duplicate HTTP requests

-- Resolves a single icon syntax (e.g. ":activity;red:") and returns Roblox AssetID and Color3 object
function CascadeIconLoader.GetRobloxAsset(iconSyntax)
    local iconName, color = string.match(iconSyntax, "^:([%w_%-]+);?([%w_#]*)%:$")
    if not iconName then return nil, nil end
    
    local assetId = AssetMap[string.lower(iconName)]
    if not assetId then return nil, nil end
    
    local color3 = Color3.new(1, 1, 1) -- Default white (no coloration)
    if color ~= "" then
        if string.match(color, "^%x%x%x$") or string.match(color, "^%x%x%x%x%x%x$") then
            color = "#" .. color
        end
        color3 = Color3.fromHex(color)
    end
    
    return assetId, color3
end

-- Resolves a single icon syntax (e.g. ":activity;red:") and returns the styled SVG XML
function CascadeIconLoader.GetSvg(iconSyntax)
    local iconName, color = string.match(iconSyntax, "^:([%w_%-]+);?([%w_#]*)%:$")
    if not iconName then return nil end
    
    if color == "" then
        color = "#1f2937" -- Default dark slate
    else
        -- Prepend '#' if color is 3 or 6 hex digits without it
        if string.match(color, "^%x%x%x$") or string.match(color, "^%x%x%x%x%x%x$") then
            color = "#" .. color
        end
    end
    
    local cacheKey = iconName .. "_" .. color
    if svgCache[cacheKey] then
        return svgCache[cacheKey]
    end
    
    local url = string.format("https://raw.githubusercontent.com/%s/%s/%s.svg", GITHUB_REPO, GITHUB_BRANCH, iconName)
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)
    
    if success and response then
        -- Inject custom stroke color replacing currentColor
        local modifiedSvg = string.gsub(response, 'stroke="currentColor"', 'stroke="' .. color .. '"')
        svgCache[cacheKey] = modifiedSvg
        return modifiedSvg
    end
    return nil
end

-- Resolves a single icon syntax and returns its raw GitHub URL
function CascadeIconLoader.GetUrl(iconSyntax)
    local iconName = string.match(iconSyntax, "^:([%w_%-]+);?[%w_#]*%:$")
    if not iconName then return nil end
    return string.format("https://raw.githubusercontent.com/%s/%s/%s.svg", GITHUB_REPO, GITHUB_BRANCH, iconName)
end

-- Roblox Executor version: downloads raw SVG, saves it locally as white, and returns getcustomasset ID + Color3
function CascadeIconLoader.GetExecutorAsset(iconSyntax)
    local iconName, color = string.match(iconSyntax, "^:([%w_%-]+);?([%w_#]*)%:$")
    if not iconName then return nil, nil end
    
    if color == "" then
        color = "#1f2937" -- Default dark color
    else
        if string.match(color, "^%x%x%x$") or string.match(color, "^%x%x%x%x%x%x$") then
            color = "#" .. color
        end
    end
    
    -- Create workspace folder for storing downloaded SVGs
    if makefolder then
        pcall(function() makefolder("lucide_icons") end)
    end
    
    local filePath = "lucide_icons/" .. iconName .. ".svg"
    local assetId
    
    if not isfile or not isfile(filePath) then
        local url = string.format("https://raw.githubusercontent.com/%s/%s/%s.svg", GITHUB_REPO, GITHUB_BRANCH, iconName)
        -- Executors use game:HttpGet to fetch remote files bypassing CORS/HTTP restrictions
        local success, response = pcall(function()
            return game:HttpGet(url)
        end)
        
        if success and response then
            -- Inject white color so we can color it dynamically via ImageColor3
            local whiteSvg = string.gsub(response, 'stroke="currentColor"', 'stroke="#ffffff"')
            if writefile then
                writefile(filePath, whiteSvg)
            end
        else
            return nil, nil
        end
    end
    
    if getcustomasset then
        assetId = getcustomasset(filePath)
    else
        assetId = filePath
    end
    
    local color3 = Color3.fromHex(color)
    return assetId, color3
end

-- Scans a string and replaces all instances of :icon;color: with their raw SVG XML text
function CascadeIconLoader.ResolveToSvg(text)
    local resolved = text
    for iconSyntax in string.gmatch(text, ":[%w_%-]+;?[%w_#]*:") do
        local svg = CascadeIconLoader.GetSvg(iconSyntax)
        if svg then
            -- Escape Lua string replacement pattern characters (%)
            local escapedSvg = string.gsub(svg, "%%", "%%%%")
            resolved = string.gsub(resolved, iconSyntax, escapedSvg)
        end
    end
    return resolved
end

-- Scans a string and replaces all instances of :icon;color: with their raw GitHub URLs
function CascadeIconLoader.ResolveToUrl(text)
    local resolved = text
    for iconSyntax in string.gmatch(text, ":[%w_%-]+;?[%w_#]*:") do
        local url = CascadeIconLoader.GetUrl(iconSyntax)
        if url then
            resolved = string.gsub(resolved, iconSyntax, url)
        end
    end
    return resolved
end

return CascadeIconLoader
