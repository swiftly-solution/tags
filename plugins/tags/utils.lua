function ToBoolean(value)
    if type(value) == "boolean" then
        return value
    end
    if type(value) == "number" then
        return value ~= 0
    end
    if type(value) == "string" then
        local str = tostring(value):lower()
        return str == "true" or str == "1"
    end
    return false
end

function PrepareColor(stringColor)
    return "{" .. stringColor .. "}"
end

function RefreshScoreboard(playerid)
    local event = Event("OnNextlevelChanged")
    event:FireEventToClient(playerid)
end


function ClearTag(playerid)
    local player = GetPlayer(playerid)
    if not player or not player:IsValid() then return end
    player:SetChatTag("")
    player:SetChatTagColor("{teamcolor}")
    player:SetNameColor("{teamcolor}")
    player:SetChatColor("{default}")
    player:CCSPlayerController().Clan = ""
    RefreshScoreboard(playerid)
end
