local consoleCommands = {

    add = function(playerid, args, argc, silent)
        -- sw_tags add <identifier> <tag> <color> <name_color> <msg_color> <scoreboard (0/1)>
        if argc < 7 then
            return ReplyToCommand(playerid, config:Fetch("tags.prefix"),
                "Syntax: sw_tags add <identifier> <tag> <color> <name_color> <msg_color> <scoreboard (0/1)>")
        end

        local identifier = args[2]
        if TagsIndexMap[identifier] then
            return ReplyToCommand(playerid, config:Fetch("tags.prefix"),
                FetchTranslation("tags.exists"):gsub("{ID}", identifier))
        end

        local tag = args[3]
        local color = args[4]
        local name_color = args[5]
        local msg_color = args[6]
        local scoreboard = tonumber(args[7])
        if not scoreboard and scoreboard ~= 0 or scoreboard ~= 1 then
            return ReplyToCommand(playerid, config:Fetch("tags.prefix"),
                "Syntax: sw_tags add <identifier> <tag> <color> <name_color> <msg_color> <scoreboard (0/1)>")
        end


        local addRowQuery =
        "INSERT INTO @tablename VALUES ('@identifier', '@tag', '@color', '@name_color', '@msg_color', @scoreboard)"
        local addRowParams = {
            ["tablename"] = config:Fetch("tags.database.tablesname.tags"),
            ["identifier"] = identifier,
            ["tag"] = tag,
            ["color"] = color,
            ["name_color"] = name_color,
            ["msg_color"] = msg_color,
            ["scoreboard"] = scoreboard
        }

        db:QueryParams(addRowQuery, addRowParams, function(err, result)
            if #err > 0 then
                return print("{DARKRED} ERROR: {DEFAULT}" .. err)
            end
            ReplyToCommand(playerid, config:Fetch("tags.prefix"), FetchTranslation("tags.added"):gsub("{ID}", identifier))
            ReloadTags()
        end)
    end,

    remove = function(playerid, args, argc, silent)
        -- sw_tags remove <identifier>
        if argc < 2 then
            return ReplyToCommand(playerid, config:Fetch("tags.prefix"), "Syntax: sw_tags remove <identifier>")
        end

        local identifier = args[2]

        if not TagsIndexMap[identifier] then
            return ReplyToCommand(playerid, config:Fetch("tags.prefix"),
                FetchTranslation("tags.not_exists"):gsub("{ID}", identifier))
        end

        local removeRowQuery = "DELETE FROM @tablename WHERE identifier = '@identifier' LIMIT 1;"
        local removeRowParams = {
            ["tablename"] = config:Fetch("tags.database.tablesname.tags"),
            ["identifier"] = identifier
        }

        db:QueryParams(removeRowQuery, removeRowParams, function(err, result)
            if #err > 0 then
                return print("{DARKRED} ERROR: {DEFAULT}" .. err)
            end
            ReplyToCommand(playerid, config:Fetch("tags.prefix"),
                FetchTranslation("tags.removed"):gsub("{ID}", identifier))
            ReloadTags()
        end)
    end,

    edit = function(playerid, args, argc, silent)
        -- sw_tags edit <identifier> <tag/color/name_color/msg_color/scoreboard> <value>
        if argc < 4 then
            return ReplyToCommand(playerid, config:Fetch("tags.prefix"),
                "Syntax: sw_tags edit <identifier> <tag/color/name_color/msg_color/scoreboard> <value>")
        end

        local identifier = args[2]
        if not TagsIndexMap[identifier] then
            return ReplyToCommand(playerid, config:Fetch("tags.prefix"),
                FetchTranslation("tags.not_exists"):gsub("{ID}", identifier))
        end

        local option = args[3]

        if option == "tag" and option ~= "color" and option ~= "name_color" and option ~= "msg_color" and option ~= "scoreboard" then
            return ReplyToCommand(playerid, config:Fetch("tags.prefix"),
                "Syntax: sw_tags edit <identifier> <tag/color/name_color/msg_color/scoreboard> <value>)")
        end
        local value = args[4]


        local updateRowQuery = "UPDATE @tablename SET @option = '@value' WHERE identifier = '@identifier'";
        local updateRowParams = {
            ["tablename"] = config:Fetch("tags.database.tablesname.tags"),
            ["option"] = option,
            ["value"] = value,
            ["identifier"] = identifier
        }

        db:QueryParams(updateRowQuery, updateRowParams, function(err, result)
            if #err > 0 then
                return print("{DARKRED} ERROR: {DEFAULT}" .. err)
            end
            ReplyToCommand(playerid, config:Fetch("tags.prefix"),
                FetchTranslation("tags.updated"):gsub("{ID}", identifier))
            ReloadTags()
        end)
    end,

    list = function(playerid, args, argc, silent)
        if #Tags == 0 then
            return ReplyToCommand(playerid, config:Fetch("tags.prefix"), FetchTranslation("tags.empty_list"))
        end
        local tagsList = {
            { "identifier", "tag", "color", "name_color", "msg_color", "scoreboard" }
        }
        for i = 1, #Tags do
            if type(Tags[i]) == "table" then
                table.insert(tagsList, {
                    Tags[i].identifier,
                    Tags[i].tag,
                    Tags[i].color,
                    Tags[i].name_color,
                    Tags[i].msg_color,
                    tostring(Tags[i].scoreboard)
                })
            end
        end

        print(CreateTextTable(tagsList))
    end,

    reload = function(playerid, args, argc, silent)
        ReloadTags()
        ReplyToCommand(playerid, config:Fetch("tags.prefix"), FetchTranslation("tags.reloaded"))
    end
}

local playerCommands = {
    show = function(playerid, args, argc, silent)
        return GenerateTagsMenu(playerid)
    end,
    toggle = function(playerid, args, argc, silent)

        local player = GetPlayer(playerid)
        if not player or not player:IsValid() then return end

        if argc < 2 then return GenerateTagsMenu(playerid) end

        local option = args[2]

        switch(option, {
            ["enable"] = function()
                local value = exports["cookies"]:GetPlayerCookie(playerid, "tags.enable")
                exports["cookies"]:SetPlayerCookie(playerid, "tags.enable", not value)
            end,
            ["mode"] = function()
                local value = exports["cookies"]:GetPlayerCookie(playerid, "tags.mode")
                switch(value, {
                    [TagsMode_t.AUTO] = function() exports["cookies"]:SetPlayerCookie(playerid, "tags.mode", TagsMode_t.MANUAL) end,
                    [TagsMode_t.MANUAL] = function() exports["cookies"]:SetPlayerCookie(playerid, "tags.mode", TagsMode_t.AUTO) end
                })
            end
        })
        SetupTag(playerid)
        return GenerateTagsMenu(playerid)

    end,
    list = function(playerid, args, argc, silent)
        return GenerateTagsListMenu(playerid)
    end,
    set = function(playerid, args, argc, silent)
        if argc < 2 then 
            return GenerateTagsMenu(playerid)
        end

        local identifier = args[2]

        if not identifier or not TagsIndexMap[identifier] then
            return GenerateTagsMenu(playerid)
        end

        exports["cookies"]:SetPlayerCookie(playerid,"tags.selected", identifier)
        SetupTag(playerid)
        return GenerateTagsMenu(playerid)

    end
}


commands:Register("tags", function(playerid, args, argc, silent, prefix)
    if playerid < 0 then
        if argc < 1 then
            return ReplyToCommand(playerid, config:Fetch("tags.prefix"), "Syntax: sw_tags <add/remove/edit/list/reload>")
        end

        local option = args[1]

        if not consoleCommands[option] then
            ReplyToCommand(playerid, config:Fetch("tags.prefix"), "Syntax: sw_tags <add/remove/edit/list/reload>")
        end

        return consoleCommands[option](playerid, args, argc, silent)
    else
        if argc < 1 then
            return playerCommands["show"](playerid, args, argc, silent)
        end
        local option = args[1]

        if not playerCommands[option] then
            return playerCommands["show"](playerid, args, argc, silent)
        end

        return playerCommands[option](playerid, args, argc, silent)
    end
end)
