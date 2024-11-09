AddEventHandler("OnAllPluginsLoaded", function (event)
    local supportedPlugins = {"vipcore","admins","cookies"}

    for i = 1, #supportedPlugins, 1 do
        local pluginName = supportedPlugins[i]
        if GetPluginState(pluginName) == PluginState_t.Started then
            Plugins[pluginName] = true
            if pluginName == "cookies" then
                exports["cookies"]:RegisterCookie("tags.enable", true)
                exports["cookies"]:RegisterCookie("tags.mode", TagsMode_t.AUTO )
                exports["cookies"]:RegisterCookie("tags.selected", "auto" )
            end
            print("Plugin found: {green}" .. pluginName.."{default}")
        end
    end

end)
