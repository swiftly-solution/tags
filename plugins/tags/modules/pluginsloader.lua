AddEventHandler("OnAllPluginsLoaded", function (event)
    local supportedPlugins = {"vipcore","admins"}

    for i = 1, #supportedPlugins, 1 do
        local pluginName = supportedPlugins[i]
        if GetPluginState(pluginName) == PluginState_t.Started then
            Plugins[pluginName] = true
            print("Plugin found: {green}" .. pluginName.."{default}")
        end
    end

end)
