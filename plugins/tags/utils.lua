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
