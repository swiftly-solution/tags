AddEventHandler("OnPluginStart", function(event)
    db = Database(tostring(config:Fetch("tags.database.connection")))
    if not db:IsConnected() then return EventResult.Continue end

    local createTableQuery = [[
        CREATE TABLE IF NOT EXISTS @tablename (
            identifier VARCHAR(255) PRIMARY KEY,
            tag VARCHAR(255) NOT NULL,
            color VARCHAR(255) NOT NULL,
            name_color VARCHAR(255) NOT NULL,
            msg_color VARCHAR(255) NOT NULL,
            scoreboard TINYINT(1) NOT NULL DEFAULT 0
        );
    ]]

    local createTableParams = {
        ["tablename"] = config:Fetch("tags.database.tablesname.tags"),
    }

    db:QueryParams(createTableQuery, createTableParams, function(err, result)
        if #err > 0 then
            return print("{DARKRED} ERROR: {DEFAULT}" .. err)
        end
        TagsLoader()
    end)
    return EventResult.Continue
end)



function TagsLoader(cb)
    if not db:IsConnected() then return end

    Tags = {}
    TagsIndexMap = {}

    local selectTableQuery = "SELECT * from @tablename"
    local selectTableParams = {
        ["tablename"] = config:Fetch("tags.database.tablesname.tags")
    }

    db:QueryParams(selectTableQuery, selectTableParams, function (err, result)
        if #err > 0 then
            return print("{DARKRED} ERROR: {DEFAULT}" .. err)
        end
        for i = 1, #result, 1 do
            Tags[i] = result[i]
            local scoreboard = Tags[i].scoreboard
            Tags[i].scoreboard = ToBoolean(scoreboard)
            TagsIndexMap[result[i].identifier] = i
        end

        if type(cb) == "function" then
            cb()
        end

        local out, _ = FetchTranslation("tags.loaded"):gsub("{COUNT}", #Tags)
        print(out)
    end)

end

function ReloadTags()
    TagsLoader(function()
        for i = 0, playermanager:GetPlayerCap() - 1, 1 do
            local player = GetPlayer(i)
            if not player then goto continue end
            SetupTag(i)
            ::continue::
        end
    end)
end


function SetupTag(playerid)
    if #Tags == 0 then return end
    local player = GetPlayer(playerid)
    if not player then return end

    local tag = DetermineTag(playerid)
    if not tag then return end

    player:SetChatTag(tag.tag)
    player:SetChatTagColor(PrepareColor(tag.color))
    player:SetNameColor(PrepareColor(tag.name_color))
    player:SetChatColor(PrepareColor(tag.msg_color))

    if tag.scoreboard then
        player:CCSPlayerController().Clan = tag.tag
    else
        player:CCSPlayerController().Clan = ""
    end
    RefreshScoreboard()
end

function DetermineTag(playerid)
    local lastTag = nil
    local player = GetPlayer(playerid)
    if not player then return nil end

    -- local isBot = player:IsFakeClient()
    local isValid = player:IsValid()
    local teamID = player:CBaseEntity().TeamNum
    local steamID = player:GetSteamID()


local conditions = {
    -- identifier : bots -- not works
    -- { condition = function() return isBot and TagsIndexMap["bots"], Tags[TagsIndexMap["bots"]] end },

    -- identifier: everyone
    { condition = function() return isValid and TagsIndexMap["everyone"], Tags[TagsIndexMap["everyone"]] end },

    -- identifier: team:tt
    { condition = function() return isValid and TagsIndexMap["team:tt"] and teamID == Team.T, Tags[TagsIndexMap["team:tt"]] end },

    -- identifier: team:ct
    { condition = function() return isValid and TagsIndexMap["team:ct"] and teamID == Team.CT, Tags[TagsIndexMap["team:ct"]] end },

    -- identifier: team:spec
    { condition = function() return isValid and TagsIndexMap["team:spec"] and teamID == Team.Spectator, Tags[TagsIndexMap["team:spec"]] end },

    -- identifier: steamid:(steamid64)
    { condition = function() return isValid and steamID and TagsIndexMap["steamid:" .. steamID], Tags[TagsIndexMap["steamid:" .. steamID]] end },

    -- identifier: vip:(group_name)
    {
        condition = function()
            if isValid and Plugins["vipcore"] then
                local vipGroup = player:GetVar("vip.group") or "none"
                if vipGroup ~= nil and vipGroup ~= "none" then
                    local index = TagsIndexMap["vip:" .. vipGroup]
                    if index then
                        return true, Tags[index]
                    end
                end
            end
            return false, nil
        end
    },

    -- identifier: admins:flags:(flags_string) or admins:group:(group_name)
    {
        condition = function()
            if isValid and Plugins["admins"] then
                local adminFlags = player:GetVar("admin.flags") or 0
                local adminGroup = exports["admins"]:GetAdminGroup(playerid) or "none"
                local latestAdminTag = nil
                
                if adminGroup ~= "none" then
                    for key, index in pairs(TagsIndexMap) do
                        local group, groupCount = string.gsub(key, "admin:group:", "", 1)
                        if groupCount ~= 0 and group == adminGroup then
                            latestAdminTag = Tags[index]
                            return true, latestAdminTag
                        end
                    end
                end

                
                if adminFlags ~= 0 then
                    for key, index in pairs(TagsIndexMap) do
                        local flags, flagsCount = string.gsub(key, "admin:flags:", "", 1)
                        if flagsCount ~= 0 and exports["admins"]:HasFlags(playerid, flags) then
                            latestAdminTag = Tags[index]
                            return true, latestAdminTag
                        end
                    end
                end
                return false, nil
            end
            return false, nil
        end
    }
}

    for i, cond in ipairs(conditions) do
        local conditionResult, tag = cond.condition()
        if conditionResult then
            if tag then
                lastTag = tag
            end
        end
    end

    return lastTag
end


AddEventHandler("OnPlayerConnectFull", function (event)
    local playerid = event:GetInt("userid")
    local player = GetPlayer(playerid)
    if not player then return end
    SetTimeout(1000, function()
        SetupTag(playerid)
    end)
end)

AddEventHandler("OnPlayerTeam", function(event)
    local playerid = event:GetInt("userid")
    local player = GetPlayer(playerid)
    if not player then return end
    SetTimeout(500, function()
        SetupTag(playerid)
    end)
end)
