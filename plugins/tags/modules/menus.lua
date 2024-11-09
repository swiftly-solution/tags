GenerateTagsMenu = function(playerid)
    local player = GetPlayer(playerid)
    if not player or not player:IsValid() or not player:CBaseEntity():IsValid() then return end

    local options = {}

    local cookieEnabled = exports["cookies"]:GetPlayerCookie(playerid, "tags.enable") or false

    switch(cookieEnabled, {

        [true] = function()
            table.insert(options, {FetchTranslation("tags.menu.option.enable", playerid) .. ": ".. FetchTranslation("tags.menu.option.on", playerid), "sw_tags toggle enable"})

            local cookieMode = exports["cookies"]:GetPlayerCookie(playerid, "tags.mode")

            switch(cookieMode,  {
                [TagsMode_t.AUTO] = function()  table.insert(options, {FetchTranslation("tags.menu.option.mode", playerid) .. ": ".. FetchTranslation("tags.menu.option.mode.auto", playerid), "sw_tags toggle mode"}) end,
                [TagsMode_t.MANUAL] = function()
                    table.insert(options, {FetchTranslation("tags.menu.option.mode", playerid) .. ": ".. FetchTranslation("tags.menu.option.mode.manual", playerid), "sw_tags toggle mode"})
                    local cookieSelected = exports["cookies"]:GetPlayerCookie(playerid, "tags.selected")

                    if cookieSelected == "auto" then
                        local lastTag = DetermineLastTag(player)
                        if not lastTag then
                            table.insert(options, {FetchTranslation("tags.menu.option.tag", playerid) .. ": <font color='white'>NONE</font>", "sw_tags list"})
                            return
                         end
                        table.insert(options, {FetchTranslation("tags.menu.option.tag", playerid) .. ": <font color='".. lastTag.color .."'>".. lastTag.tag .. "</font>", "sw_tags list"})                        
                    else
                        if not TagsIndexMap[cookieSelected] then
                            table.insert(options, {FetchTranslation("tags.menu.option.tag", playerid) .. ": <font color='white'>NONE</font>", "sw_tags list"})
                            return
                        end
                        local tag = Tags[TagsIndexMap[cookieSelected]]
                        local item = switch(tag.color, {
                            teamcolor = function()
                                return switch(player:CBaseEntity().TeamNum, {
                                    [Team.CT] = function ()
                                        return "<font color='blue'>".. tag.tag .. "</font>"
                                    end,
                                    [Team.T] = function ()
                                        return "<font color='yellow'>".. tag.tag .. "</font>"
                                    end,
                                    [Team.Spectator] = function ()
                                        return "<font color='white'>".. tag.tag .. "</font>"
                                    end,
                                    [Team.None] = function ()
                                        return "<font color='white'>".. tag.tag .. "</font>"
                                    end
                                })
                            end,
                            default = function ()
                                return "<font color='".. tag.color .."'>".. tag.tag .. "</font>"                                
                            end
                        })
                        table.insert(options, {FetchTranslation("tags.menu.option.tag", playerid) .. ": ".. item, "sw_tags list"})
                    end
                end
            })

        end,
        [false] = function()
            table.insert(options, {FetchTranslation("tags.menu.option.enable", playerid) .. ": ".. FetchTranslation("tags.menu.option.off", playerid), "sw_tags toggle enable"})
        end,
    })


    if #options < 1 then return end

    local menuId = "tags_".. os.clock()

    menus:RegisterTemporary(menuId, tostring(FetchTranslation("tags.menu.title", playerid) or "Tags Menu"), tostring(config:Fetch("tags.menu.color") or "0000FF"), options)
    player:HideMenu()
    player:ShowMenu(menuId)

end


GenerateTagsListMenu = function(playerid)
    local player = GetPlayer(playerid)
    if not player or not player:IsValid() then return end
    local tags = DetermineTags(player)
    if not tags then return GenerateTagsMenu(playerid) end
    local options = {}

    for _, tag in next, tags do

        switch(tag.color, {
            teamcolor = function()
                switch(player:CBaseEntity().TeamNum, {
                    [Team.CT] = function()
                        table.insert(options, {"<font color='blue'>".. tag.tag .. "</font>", "sw_tags set " .. tag.identifier})
                    end,
                    [Team.T] = function()
                        table.insert(options, {"<font color='yellow'>".. tag.tag .. "</font>", "sw_tags set " .. tag.identifier})
                    end,
                    [Team.Spectator] = function()
                        table.insert(options, {"<font color='white'>".. tag.tag .. "</font>", "sw_tags set " .. tag.identifier})
                    end,
                    [Team.None] = function()
                        table.insert(options, {"<font color='white'>".. tag.tag .. "</font>", "sw_tags set " .. tag.identifier})
                    end
                })
            end,
            default = function()
                table.insert(options, {"<font color='".. tag.color .."'>".. tag.tag .. "</font>", "sw_tags set " .. tag.identifier})
            end
        })
    end
    if #options < 1 then return GenerateTagsMenu(playerid) end

    local menuId = "tags_list_".. os.clock()
    menus:RegisterTemporary(menuId, tostring(FetchTranslation("tags.menu.option.tag.list", playerid) or "Tags List Menu"), tostring(config:Fetch("tags.menu.color") or "0000FF"), options)
    player:HideMenu()
    player:ShowMenu(menuId)
end