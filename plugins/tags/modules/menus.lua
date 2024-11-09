GenerateTagsMenu = function(playerid)
    local player = GetPlayer(playerid)
    if not player or not player:IsValid() then return end

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
                        local lastTag = DetermineLastTag(playerid)
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
                        table.insert(options, {FetchTranslation("tags.menu.option.tag", playerid) .. ": <font color='".. tag.color .."'>".. tag.tag .. "</font>", "sw_tags list"})
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
    local tags = DetermineTags(playerid)
    if not tags then return GenerateTagsMenu(playerid) end

    local options = {}

    for _, tag in next, tags do
        table.insert(options, {"<font color='".. tag.color .."'>".. tag.tag .. "</font>", "sw_tags set " .. tag.identifier})
    end
    if #options < 1 then return GenerateTagsMenu(playerid) end

    local menuId = "tags_list_".. os.clock()
    menus:RegisterTemporary(menuId, tostring(FetchTranslation("tags.menu.option.tag.list", playerid) or "Tags List Menu"), tostring(config:Fetch("tags.menu.color") or "0000FF"), options)
    player:HideMenu()
    player:ShowMenu(menuId)
end