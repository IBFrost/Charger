local ChargerFrame = CreateFrame('Frame')

local ZoneMap = {
    ["Zul'Gurub"] = {"Spider", "Frog", "Jungle Toad", "Snake", "Toad"},
    ["Naxxrammas"] = {"Spider", "Rat", "Maggot", "Larva"},
    ["Maraudon"] = {"Frog", "Snake", "School of Fish"},
    ["Dire Maul"] = {"Frog", "Snake", "Rat", "Roach", "Deer", "Squirrel", "Rabbit"},
    ["Wetlands"] = {"Ram", "Toad"},
    ["Loch Modan"] = {"Ram", "Sheep"},
    ["Arathi Highlands"] = {"Ram", "Prairie Dog", "Toad", "Cow", "Cat"},
    ["Westfall"] = {"Mouse", "Prairie Dog", "Cow", "Deer", "Sheep", "Chicken"},
    ["Mulgore"] = {"Prairie Dog"},
    ["Western Plaguelands"] = {"Infected Deer", "Infected Squirrel", "Deer"},
    ["Silverpine Forest"] = {"Infected Deer", "Infected Squirrel"},
    ["Wailing Caverns"] = {"Snake", "Biletoad"},
    ["Un'Goro Crater"] = {"Parrot"},
    ["The Barrens"] = {"Prairie Dog", "Dig Rat", "Sickly Gazelle", "Gazelle", "Chicken", "Swine", "Adder",
                       "School of Fish"},
    ["Swamp of Sorrows"] = {"Toad", "Moccasin", "Huge Toad"},
    ["Dustwallow Marsh"] = {"Toad", "Squirrel", "Chicken", "School of Fish"},
    ["Teldrassil"] = {"Toad", "Deer", "Rabbit"},
    ["Darnassus"] = {"Toad", "Deer", "Squirrel"},
    ["Stratholme"] = {"Plagued Maggot", "Plagued Insect", "Plagued Rat"},
    ["Stranglethorn Vale"] = {"Rat"},
    ["Scarlet Monastery"] = {"Rat", "Rabbit"},
    ["Stormwind City"] = {"Rat"},
    ["Scholomance"] = {"Rat"},
    ["The Deadmines"] = {"Rat"},
    ["Arathi Basin"] = {"Rat", "Chicken", "Deeprun Rat"},
    ["Shadowfang Keep"] = {"Black Rat"},
    ["Razorfen Downs"] = {"Black Rat", "Roach"},
    ["Blackrock Spire"] = {"Black Rat", "Roach"},
    ["Felwood"] = {"Tainted Cockroach", "Tainted Rat"},
    ["Elwynn Forest"] = {"Cow", "Deer", "Cat", "Sheep", "Fawn", "Chicken", "Rabbit"},
    ["Hillsbrad Foothills"] = {"Cow", "Sheep", "Chicken"},
    ["Redridge Mountains"] = {"Cow", "Horse", "Sheep", "Chicken", "Rabbit"},
    ["Tirisfal Glades"] = {"Chicken"},
    ["Darkshore"] = {"Deer", "School of Fish", "Sickly Deer"},
    ["Moonglade"] = {"Deer", "Rabbit"},
    ["Ashenvale"] = {"Deer"},
    ["Stonetalon Mountains"] = {"Deer", "Squirrel", "Rabbit"},
    ["Alterac Mountains"] = {"Deer", "Sheep"},
    ["Durotar"] = {"Swine", "Adder", "School of Fish", "Hare"},
    ["Dun Morogh"] = {"Rabbit"},
    ["Burning Steppes"] = {"Lava Crab", "Fire Beetle"},
    ["Searing Gorge"] = {"Lava Crab", "Fire Beetle"},
    ["Warsong Gulch"] = {"Deeprun Rat"},
    ["Ahn'Qiraj"] = {"Scorpion", "Beetle"},
    ["Ruins of Ahn'Qiraj"] = {"Scorpion", "Beetle"}
}

ChargerFrame:SetScript('OnEvent', function(self, event, ...)
    self[event](...)
end)

local enabled, debugMode, firstRunComplete

function ChargerFrame:ReportDebugInfo(type, info, force) -- force is unused unless it is set to TRUE, which overrides debug mode to ALWAYS print the message.
    if not debugMode and not force then
        return
    end
    if (type == "GOOD") then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00FF80Charger: " .. info)
    elseif (type == "BAD") then
        DEFAULT_CHAT_FRAME:AddMessage("|cffFF0080Charger: " .. info)
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff80FFFFCharger: " .. info)
    end
end

local function ToggleDebugMode()
    debugMode = not debugMode
    ChargerDebug = debugMode
end
local function ToggleUpdates()
    enabled = not enabled
    ChargerEnabled = enabled
end


-- SLASH COMMAND REGISTRATION
SLASH_CHARGER1 = "/charger"
SlashCmdList["CHARGER"] = function(msg)
    if msg:lower() == "debug" then
        ToggleDebugMode()
        if debugMode then
            ChargerFrame:ReportDebugInfo("OTHER", "Debug mode is |cff74ff23ENABLED", true)
        else
            ChargerFrame:ReportDebugInfo("OTHER", "Debug mode is now |cffff2323DISABLED", true)
        end
    elseif msg:lower() == "toggle" then
        ToggleUpdates()
        if enabled then
            ChargerFrame:ReportDebugInfo("OTHER", "Automatic macro updates |cff74ff23ENABLED", true)
        else
            ChargerFrame:ReportDebugInfo("OTHER", "Automatic macro updates |cffff2323DISABLED", true)
        end
    else
        ChargerFrame:ReportDebugInfo("OTHER",
            "Unknown command. Use '/charger toggle' to toggle the automation or use '/charger debug' to toggle debug mode.",
            true)
    end
end

local inCombat, macroID, lastZoneUpdate, combatHold

-- EVENT REGISTRATION HELPER
function ChargerFrame:Register(event, func)
    if type(func) ~= "function" then
        return
    end
    self:RegisterEvent(event)
    self[event] = function(...)
        func(...)
    end
    ChargerFrame:ReportDebugInfo("OTHER", "" .. event .. " successfully registered.")
end

-- EVENT REGISTRATION
ChargerFrame:Register('ADDON_LOADED', function()
    firstRunComplete = ChargerFirstRunComplete or false
    debugMode = ChargerDebug or false
    enabled = ChargerEnabled or true
    macroID = ChargerMacroID or nil
    inCombat = UnitAffectingCombat("player") or false
    combatHold = inCombat
end)

ChargerFrame:Register('PLAYER_REGEN_DISABLED', function()
    inCombat = true
    ChargerFrame:ReportDebugInfo("OTHER", 'PLAYER_REGEN_DISABLED')
end)

ChargerFrame:Register('PLAYER_REGEN_ENABLED', function()
    inCombat = false
    ChargerFrame:ReportDebugInfo("OTHER", 'PLAYER_REGEN_ENABLED')
    if combatHold then
        ChargerFrame:UpdateMacro('PLAYER_REGEN_ENABLED')
        combatHold = false
    end
end)

ChargerFrame:Register('ZONE_CHANGED_NEW_AREA', function()
    ChargerFrame:ReportDebugInfo("OTHER", 'ZONE_CHANGED_NEW_AREA')
    ChargerFrame:UpdateMacro('ZONE_CHANGED_NEW_AREA')
end)

-- MACRO HANDLING
function ChargerFrame:UpdateMacro(event)
    if not enabled then
        return
    end

    local currentZone
    local isInInstance, _ = IsInInstance()
    if isInInstance then
        local instanceName, _, _, _, _, _, _, _, _, _, _ = GetInstanceInfo()
        if not instanceName then
            ChargerFrame:ReportDebugInfo("BAD", "Failed to retrieve instance name. Aborting...")
            return
        end
        currentZone = instanceName
    else
        local mapID = C_Map.GetBestMapForUnit("player")
        if not mapID then
            ChargerFrame:ReportDebugInfo("BAD", "Failed to retrieve the map ID. Aborting...")
            return
        end

        local mapInfo = C_Map.GetMapInfo(mapID)
        if not mapInfo or not mapInfo.name then
            ChargerFrame:ReportDebugInfo("BAD", "Failed to retrieve the map name. Aborting...")
            return
        end
        currentZone = mapInfo.name
    end

    if currentZone == lastZoneUpdate then -- Makes sure zone isn't the same as the previous.
        ChargerFrame:ReportDebugInfo("BAD", "Macro already set up for zone! Aborting...")
        return
    end

    if debugMode then
        ChargerFrame:ReportDebugInfo("GOOD", "Macro update triggered for " .. currentZone .. "...")
    end

    if inCombat then
        if not firstRunComplete then
            ChargerFrame:ReportDebugInfo("OTHER", "I'll get started once you're out of combat!", not firstRunComplete)
        else
            ChargerFrame:ReportDebugInfo("BAD", "Player in combat (inCombat = true). Aborting...")
        end
        combatHold = true
        return
    end

    if not macroID then 
        if not firstRunComplete then
            ChargerFrame:ReportDebugInfo("GOOD", "To get started I'm going to try to register the macro: |cffffffff!Charger", not firstRunComplete)
        else
            ChargerFrame:ReportDebugInfo("BAD", "No Macro found! Registering a macro ID...")
        end
        ChargerFrame:RegisterMacro(event)
    else
        local macroIDName, _, _ = GetMacroInfo(macroID)
        if not (macroIDName == "!Charger") then
            ChargerFrame:ReportDebugInfo("BAD", "Macro ID does not match template. Scanning entire catalog...")
            local fallbackMacroID = GetMacroIndexByName("!Charger")
            if fallbackMacroID == 0 then
                ChargerFrame:ReportDebugInfo("BAD", "No macro ID matches template. Rebuilding...")
                ChargerFrame:RegisterMacro()
            else
               ChargerFrame:ReportDebugInfo("GOOD", "Macro located! Continuing...")
                macroID = fallbackMacroID
                ChargerMacroID = macroID
            end
        end
    end

    if not macroID then
        ChargerFrame:ReportDebugInfo("BAD", "Macro failed to build!", not firstRunComplete)
        local globalSlots, localSlots = GetNumMacros()
        if globalSlots >= 120 then
            ChargerFrame:ReportDebugInfo("BAD",
                "Insufficient macro slots available! Aborting and disabling to lower overhead... (use `/charger toggle` to re-enable)",
                true)
            enabled = false
            ChargerEnabled = enabled
        end
        return
    end

    local critterNames = ZoneMap[currentZone]
    if not critterNames then
        ChargerFrame:ReportDebugInfo("BAD", "No critters found for zone: " .. currentZone .. ". Aborting...", not firstRunComplete)
        return
    end

    local macroString = "#showcooldown Charge\n"
    local reportString = "("
    for index, value in ipairs(critterNames) do
        macroString = macroString .. "/tar " .. value .. "\n"
        reportString = reportString .. " " .. value .. " "
    end

    macroString = macroString .. "/cast [exists, nodead] Charge" -- [exists] used to prevent accidental use on nearby hostile enemies.
    reportString = reportString .. ")"
    ChargerFrame:ReportDebugInfo("GOOD", "Attempting to update macro to target " .. reportString, not firstRunComplete)
    EditMacro(macroID, nil, nil, macroString)
    lastZoneUpdate = currentZone
    ChargerFrame:ReportDebugInfo("GOOD", "Successfully edited macro!", not firstRunComplete)
    firstRunComplete = true
    ChargerFirstRunComplete = firstRunComplete
end

function ChargerFrame:RegisterMacro(event)
    macroID = CreateMacro("!Charger", 132171, "/run print('Macro not built yet...')", false)
    if macroID then
        ChargerMacroID = macroID
        ChargerFrame:ReportDebugInfo("GOOD", "Successfully registered macro: |cffffffff!Charger|r!", not firstRunComplete)
    end
end

