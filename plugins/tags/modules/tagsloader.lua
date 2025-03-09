AddEventHandler("OnPluginStart", function(event)
    db = Database(tostring(config:Fetch("tags.database.connection")))
    if not db:IsConnected() then return EventResult.Continue end

    db:QueryBuilder():Table(tostring(config:Fetch("tags.database.tablesname.tags") or "sw_tags"))
        :Create({
            identifier = "string|max:255|primary",
            tag = "string|max:255",
            color = "string|max:255",
            name_color = "string|max:255",
            msg_color = "string|max:255",
            scoreboard = "boolean"
        })
        :Execute(function (err, result)
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

    db:QueryBuilder():Table(tostring(config:Fetch("tags.database.tablesname.tags")) or "sw_tags"):Select({'*'}):Execute(function (err, result)
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


function SetPlayerTag(player, tag)
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

    RefreshScoreboard(player:GetSlot())
end

function SetupTag(playerid)
    if not Tags or #Tags == 0 then return end
    local player = GetPlayer(playerid)
    if not player then return end

    ClearTag(playerid)

    local cookieEnabled = exports["cookies"]:GetPlayerCookie(playerid, "tags.enable") or false

    if not cookieEnabled then return end

    local cookieMode = exports["cookies"]:GetPlayerCookie(playerid, "tags.mode")

    if cookieMode == TagsMode_t.AUTO then
        local tag = DetermineLastTag(player)
        SetPlayerTag(player, tag)
    elseif cookieMode == TagsMode_t.MANUAL then
        local cookieSelected = exports["cookies"]:GetPlayerCookie(playerid, "tags.selected")

        if cookieSelected == "auto" then
            local tag = DetermineLastTag(player)
            SetPlayerTag(player, tag)
        else
            local tag = Tags[TagsIndexMap[cookieSelected]]
            SetPlayerTag(player, tag)
        end
    end
end

local function GetPlayerTags(player)
    local tags = {}
    local teamID = player:CBaseEntity().TeamNum
    local steamID = player:GetSteamID()

    local conditions = {

        -- identifier: everyone
        { condition = function() 
            return TagsIndexMap["everyone"], Tags[TagsIndexMap["everyone"]] 
        end },

        -- identifier: team:tt
        { condition = function() 
            return TagsIndexMap["team:tt"] and teamID == Team.T, Tags[TagsIndexMap["team:tt"]] 
        end },

        -- identifier: team:ct
        { condition = function() 
            return TagsIndexMap["team:ct"] and teamID == Team.CT, Tags[TagsIndexMap["team:ct"]] 
        end },

        -- identifier: team:spec
        { condition = function() 
            return TagsIndexMap["team:spec"] and teamID == Team.Spectator, Tags[TagsIndexMap["team:spec"]] 
        end },

        -- identifier: steamid:(steamid64)
        { condition = function() 
            return steamID and TagsIndexMap["steamid:" .. steamID], Tags[TagsIndexMap["steamid:" .. steamID]] 
        end },

        -- identifier: vip:(group_name)
        {
            condition = function()
                if Plugins["vipcore"] then
                    local vipGroup = player:GetVar("vip.group") or "none"
                    if vipGroup ~= "none" then
                        local index = TagsIndexMap["vip:" .. vipGroup]
                        if index then
                            return true, Tags[index]
                        end
                    end
                end
                return false, nil
            end
        },

        -- identifier: admins:flags:(flags_string)
        {
            condition = function()
                if Plugins["admins"] then
                    local adminFlags = player:GetVar("admin.flags") or 0                    
                    if adminFlags ~= 0 then
                        local adminTags = {}
                        for key, _ in next, TagsIndexMap do
                            local flags, flagsCount = key:gsub("admin:flags:", "", 1)
                            if flagsCount ~= 0 and exports["admins"]:HasFlags(player:GetSlot(), flags) then
                                -- Dodajemy tag tylko, jeśli jeszcze go nie mamy
                                if not table.contains(adminTags, key) then
                                    table.insert(adminTags, key)
                                end
                            end
                        end
                        if #adminTags > 0 then
                            table.sort(adminTags)
                            for _, tagKey in ipairs(adminTags) do
                                local index = TagsIndexMap[tagKey]
                                -- Dodajemy tag tylko, jeśli jeszcze go nie mamy
                                if not table.contains(tags, Tags[index]) then
                                    table.insert(tags, Tags[index])
                                end
                            end
                        end
                    end
                end
                return false, nil
            end
        },

        -- identifier: admins:groups:(group_name)
        {
            condition = function()
                if Plugins["admins"] then
                    local adminGroup = exports["admins"]:GetAdminGroup(player:GetSlot()) or "none"
                    if adminGroup ~= "none" then
                        for key, index in next, TagsIndexMap do
                            local group, groupCount = key:gsub("admin:group:", "", 1)
                            if groupCount ~= 0 and group == adminGroup then
                                -- Dodajemy tag tylko, jeśli jeszcze go nie mamy
                                if not table.contains(tags, Tags[index]) then
                                    table.insert(tags, Tags[index])
                                end
                                return true, Tags[index]
                            end
                        end
                    end
                end
                return false, nil
            end
        }
    }

    -- Przejście przez warunki i dodanie wszystkich pasujących tagów
    for _, cond in next, conditions do
        local conditionResult, tag = cond.condition()
        if conditionResult and tag then
            -- Dodajemy tag tylko, jeśli jeszcze go nie mamy
            if not table.contains(tags, tag) then
                table.insert(tags, tag)
            end
        end
    end

    return tags
end

function DetermineTags(player)
    if not player or not player:IsValid() or not player:CBaseEntity():IsValid() then 
        return nil 
    end
    
    return GetPlayerTags(player)
end

function DetermineLastTag(player)
    local tags = DetermineTags(player)
    if not tags then return nil end
    return #tags > 0 and tags[#tags] or nil
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
