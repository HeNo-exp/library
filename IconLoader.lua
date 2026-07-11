--[[
    Roblox Executor-Exclusive Icon Loader (Luau)
    Author: Antigravity

    Features:
    - Automatically checks the executor's workspace directory for cached PNG icons.
    - Automatically downloads missing icons from GitHub and caches them locally.
    - Parses ":icon-name;color:" or ":icon-name:" syntax.
    - Converts hex colors (e.g., "ff0000" or "#00ff00") and standard CSS names to Color3.
    - Handles compatibility between different executors (Wave, Solara, Celery, Codex, etc.).
--]]

local IconLoader = {}
IconLoader.__index = IconLoader

-- Configuration (Adjust as needed)
IconLoader.BaseUrl = "https://raw.githubusercontent.com/HeNo-exp/lucide/master/lucide_white_pngs/"
IconLoader.LocalFolder = "lucide_icons"

-- In-memory cache to avoid redundant filesystem calls during a session
local sessionCache = {}

-- Standard CSS color name to Color3 mapping
local COLOR_MAP = {
    white = Color3.fromRGB(255, 255, 255),
    black = Color3.fromRGB(0, 0, 0),
    red = Color3.fromRGB(239, 68, 68),
    green = Color3.fromRGB(34, 197, 94),
    blue = Color3.fromRGB(59, 130, 246),
    yellow = Color3.fromRGB(234, 179, 8),
    orange = Color3.fromRGB(249, 115, 22),
    purple = Color3.fromRGB(168, 85, 247),
    pink = Color3.fromRGB(236, 72, 153),
    gray = Color3.fromRGB(107, 114, 128),
    grey = Color3.fromRGB(107, 114, 128),
    cyan = Color3.fromRGB(6, 182, 212),
    magenta = Color3.fromRGB(217, 70, 239),
    lime = Color3.fromRGB(132, 204, 22),
    teal = Color3.fromRGB(20, 184, 166),
    brown = Color3.fromRGB(120, 53, 4),
}

-- Check if running in a supported executor environment
local function checkExecutorSupport()
    local missing = {}
    if not isfile then table.insert(missing, "isfile") end
    if not writefile then table.insert(missing, "writefile") end
    if not makefolder then table.insert(missing, "makefolder") end
    
    local assetFuncExists = (getcustomasset ~= nil) or (getsynasset ~= nil)
    if not assetFuncExists then
        table.insert(missing, "getcustomasset / getsynasset")
    end
    
    return #missing == 0, missing
end

-- Helper to get custom asset API function
local function getAssetID(path)
    if getcustomasset then
        return getcustomasset(path)
    elseif getsynasset then
        return getsynasset(path)
    end
    return ""
end

-- Safe HttpGet wrapper
local function httpGet(url)
    if game:HttpGetAsync then
        return game:HttpGetAsync(url)
    elseif game:HttpGet then
        return game:HttpGet(url)
    elseif request then
        local response = request({
            Url = url,
            Method = "GET"
        })
        if response and response.StatusCode == 200 then
            return response.Body
        end
    end
    error("HTTP Request library not available or request failed")
end

-- Helper to parse hex colors
local function parseHexColor(hexStr)
    hexStr = hexStr:gsub("^#", "") -- strip leading '#' if present
    if #hexStr == 3 then
        local r = tonumber(hexStr:sub(1, 1), 16) or 15
        local g = tonumber(hexStr:sub(2, 2), 16) or 15
        local b = tonumber(hexStr:sub(3, 3), 16) or 15
        return Color3.fromRGB(r * 17, g * 17, b * 17)
    elseif #hexStr == 6 then
        local r = tonumber(hexStr:sub(1, 2), 16) or 255
        local g = tonumber(hexStr:sub(3, 4), 16) or 255
        local b = tonumber(hexStr:sub(5, 6), 16) or 255
        return Color3.fromRGB(r, g, b)
    end
    return nil
end

-- Helper to parse a color modifier (could be CSS name or Hex)
local function parseColorModifier(colorStr)
    if not colorStr then return nil end
    colorStr = colorStr:lower():gsub("%s+", "")
    
    -- Check if it matches a predefined CSS color name
    if COLOR_MAP[colorStr] then
        return COLOR_MAP[colorStr]
    end
    
    -- Try to parse as HEX
    local parsedColor = parseHexColor(colorStr)
    if parsedColor then
        return parsedColor
    end
    
    -- Return nil if invalid color syntax
    return nil
end

-- Initial directory setup
local folderCreated = false
local function ensureFolder()
    if folderCreated then return end
    if makefolder then
        pcall(function()
            makefolder(IconLoader.LocalFolder)
        end)
        folderCreated = true
    end
end

--[[
    Loads an icon and returns the Roblox Asset ID (string) and the parsed Color3 (or nil).
    
    Parameters:
    - iconSyntax: String representation of the icon.
      Can be:
        - ":activity:" (with colons)
        - "activity" (name only)
        - ":bell;ff00ff:" (with color modifier)
        - "bell;red" (name + color modifier)
        
    Returns:
    - assetId (string): Ready to be assigned to ImageLabel.Image
    - color (Color3 | nil): The parsed color, or nil if no color was provided.
--]]
function IconLoader:Load(iconSyntax)
    assert(type(iconSyntax) == "string", "Icon name must be a string")
    
    -- Trim leading and trailing colons if present
    local cleanStr = iconSyntax:gsub("^:", ""):gsub(":$", "")
    
    -- Separate icon name and color (e.g., "bell;ff00ff" -> "bell", "ff00ff")
    local parts = cleanStr:split(";")
    local name = parts[1]:lower():gsub("%s+", "")
    local colorStr = parts[2]
    
    -- Parse color
    local imageColor = parseColorModifier(colorStr)
    
    -- Check in-memory session cache first
    if sessionCache[name] then
        return sessionCache[name], imageColor
    end
    
    -- Check if we are running inside a compatible Roblox executor
    local isSupported, missingAPIs = checkExecutorSupport()
    if not isSupported then
        warn("IconLoader Warning: Executor lacks filesystem capabilities (" .. table.concat(missingAPIs, ", ") .. "). Falling back to blank asset.")
        return "", imageColor
    end
    
    ensureFolder()
    
    local localFilePath = string.format("%s/%s.png", IconLoader.LocalFolder, name)
    local assetId = ""
    
    -- 1. Check if the file is already cached in the local executor workspace
    local success, exists = pcall(function()
        return isfile(localFilePath)
    end)
    
    if success and exists then
        -- File is cached, load it
        local assetSuccess, loadedAsset = pcall(function()
            return getAssetID(localFilePath)
        end)
        if assetSuccess then
            assetId = loadedAsset
        end
    else
        -- 2. If not cached, download it from GitHub
        local downloadUrl = string.format("%s%s.png", IconLoader.BaseUrl, name)
        
        print(string.format("[IconLoader] Downloading icon '%s' from remote repo...", name))
        local downloadSuccess, fileData = pcall(function()
            return httpGet(downloadUrl)
        end)
        
        if downloadSuccess and fileData and #fileData > 0 then
            if fileData:sub(1, 4) == "\137PNG" then
                -- Save downloaded file to executor's workspace
                local saveSuccess = pcall(function()
                    writefile(localFilePath, fileData)
                end)
                
                if saveSuccess then
                    -- Load the newly saved file
                    local assetSuccess, loadedAsset = pcall(function()
                        return getAssetID(localFilePath)
                    end)
                    if assetSuccess then
                        assetId = loadedAsset
                    end
                else
                    warn("[IconLoader] Failed to write cache file: " .. localFilePath)
                end
            else
                warn(string.format("[IconLoader] Downloaded data for '%s' is not a valid PNG (likely a 404 page). Not caching.", name))
            end
        else
            warn(string.format("[IconLoader] Failed to download icon '%s' from URL: %s", name, downloadUrl))
        end
    end
    
    -- Save in memory to speed up future requests
    if assetId ~= "" then
        sessionCache[name] = assetId
    end
    
    return assetId, imageColor
end

--[[
    A helper function to apply an icon directly to a Roblox ImageLabel or ImageButton.
    
    Parameters:
    - imageInstance: Instance (ImageLabel or ImageButton)
    - iconSyntax: String representation of the icon (e.g. ":activity;red:")
--]]
function IconLoader:Apply(imageInstance, iconSyntax)
    assert(typeof(imageInstance) == "Instance" and (imageInstance:IsA("ImageLabel") or imageInstance:IsA("ImageButton")), "Target must be an ImageLabel or ImageButton")
    
    local assetId, color = self:Load(iconSyntax)
    if assetId and assetId ~= "" then
        imageInstance.Image = assetId
    end
    if color then
        imageInstance.ImageColor3 = color
    else
        -- If no color specified, reset to white (which shows the default white icon color)
        imageInstance.ImageColor3 = Color3.new(1, 1, 1)
    end
end

return IconLoader
