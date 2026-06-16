-- ==========================================
-- 7.3.5 Pure Super Hearthstone (Multi-level Menu Invisible Full Version)
-- ==========================================

local DUMMY_NPC_ID = 19715
local MENU_TEXT_ID = 401

-- Teleport coordinate dictionary [OptionID] = {MapID, X, Y, Z, Orientation, Name}
local TeleportCoords = {
    -- Alliance Capitals (11-14)
    [11] = {0, -8913.23, 554.63, 93.79, 0, "Stormwind"},
    [12] = {0, -4918.88, -940.40, 501.56, 5.4, "Ironforge"},
    [13] = {1, 9951.52, 2280.32, 1341.39, 1.57, "Darnassus"},
    [14] = {530, -3987.29, -11846.6, -2.01, 1.22, "The Exodar"},
    
    -- Horde Capitals (21-24)
    [21] = {1, 1676.21, -4315.92, 21.36, 2.68, "Orgrimmar"},
    [22] = {1, -1277.37, 115.23, 131.28, 5.2, "Thunder Bluff"},
    [23] = {0, 1586.48, 239.56, -52.14, 3.0, "Undercity"},
    [24] = {530, 9487.68, -7279.2, 14.2, 6.1, "Silvermoon City"},
    
    -- Neutral Capitals (31-32)
    [31] = {530, -1862.82, 5426.98, -10.46, 2.3, "Shattrath (Outland)"},
    [32] = {571, 5804.14, 624.77, 647.76, 1.64, "Dalaran (Northrend)"}
}

-- [Menu Renderer] Responsible for generating different menu levels
local function ShowMenu(player, creature, menuType)
    player:GossipClearMenu()
    
    if menuType == "MAIN" then
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\INV_Misc_Rune_01:24|t Save current location as home", 1, 1)
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\INV_Misc_Rune_06:24|t Return to bound home", 1, 2)
        player:GossipMenuAddItem(1, "|TInterface\\Icons\\Achievement_Character_Human_Male:24|t Alliance capital teleport", 1, 10)
        player:GossipMenuAddItem(1, "|TInterface\\Icons\\Achievement_Character_Orc_Male:24|t Horde capital teleport", 1, 20)
        player:GossipMenuAddItem(1, "|TInterface\\Icons\\Achievement_Zone_Dalaran:24|t Neutral capital teleport", 1, 30)

    elseif menuType == "ALLIANCE" then
        player:GossipMenuAddItem(1, "Teleport to Stormwind", 1, 11)
        player:GossipMenuAddItem(1, "Teleport to Ironforge", 1, 12)
        player:GossipMenuAddItem(1, "Teleport to Darnassus", 1, 13)
        player:GossipMenuAddItem(1, "Teleport to The Exodar", 1, 14)
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\UI_ChatIcon_ScrollDown:24|t Back to main menu", 1, 99)

    elseif menuType == "HORDE" then
        player:GossipMenuAddItem(1, "Teleport to Orgrimmar", 1, 21)
        player:GossipMenuAddItem(1, "Teleport to Thunder Bluff", 1, 22)
        player:GossipMenuAddItem(1, "Teleport to Undercity", 1, 23)
        player:GossipMenuAddItem(1, "Teleport to Silvermoon City", 1, 24)
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\UI_ChatIcon_ScrollDown:24|t Back to main menu", 1, 99)

    elseif menuType == "NEUTRAL" then
        player:GossipMenuAddItem(1, "Teleport to Shattrath", 1, 31)
        player:GossipMenuAddItem(1, "Teleport to Dalaran", 1, 32)
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\UI_ChatIcon_ScrollDown:24|t Back to main menu", 1, 99)
    end
    
    player:GossipSendMenu(MENU_TEXT_ID, creature)
end

-- [Fallback Function] Register Event 1 (open initial menu)
local function OnGossipHello(event, player, creature)
    ShowMenu(player, creature, "MAIN")
end

-- [Act One] Intercept secret signal, trigger interrupt and summon
local function OnSecretChatSignal(event, player, msg, Type, lang)
    if msg == "__HEARTHSTONE_START__" then
        local playerName = player:GetName()
        
        CreateLuaEvent(function()
            pcall(function()
                local p = GetPlayerByName(playerName)
                if not p then return end

                if p.InterruptSpell then
                    pcall(function() p:InterruptSpell(0) end)
                    pcall(function() p:InterruptSpell(1) end)
                    pcall(function() p:InterruptSpell(2) end)
                end

                -- Summon temporary carrier, lifespan 15 seconds (auto despawn if unused)
                local dummy = p:SummonCreature(DUMMY_NPC_ID, p:GetX(), p:GetY(), p:GetZ(), p:GetO(), 4, 15000)

                if dummy then
                    dummy:SetReactState(0) 
                    dummy:SetNPCFlags(1)
                    
                    -- [Core Invisibility Fix]: use universal transparent model 11686 to fully disappear from screen
                    dummy:SetDisplayId(11686)
                    
                    CreateLuaEvent(function()
                        local p2 = GetPlayerByName(playerName)
                        if p2 then
                            OnGossipHello(1, p2, dummy)
                        end
                    end, 800, 1)
                end
            end)
        end, 800, 1)
        
        return false 
    end
end

-- [Act Three] Menu click handler
local function OnGossipSelect(event, player, object, sender, intid, code)
    local status, err = pcall(function()
        
        -- Check submenu navigation
        if intid == 10 then
            ShowMenu(player, object, "ALLIANCE")
            return -- return directly, do not despawn NPC
        elseif intid == 20 then
            ShowMenu(player, object, "HORDE")
            return
        elseif intid == 30 then
            ShowMenu(player, object, "NEUTRAL")
            return
        elseif intid == 99 then
            ShowMenu(player, object, "MAIN")
            return
        end

        -- Execute specific function
        if intid == 1 or intid == 0 then 
            player:SetBindPoint(player:GetX(), player:GetY(), player:GetZ(), player:GetMapId(), player:GetAreaId())
            player:SendBroadcastMessage("|cff00FF00Saved successfully! Home has been bound here.|r")

        elseif intid == 2 then 
            player:CastSpell(player, 8690, true)
            
        -- Read coordinate dictionary and execute teleport
        elseif TeleportCoords[intid] then
            local loc = TeleportCoords[intid]
            player:Teleport(loc[1], loc[2], loc[3], loc[4], loc[5])
            player:SendBroadcastMessage("|cff00FF00Teleporting to " .. loc[6] .. "...|r")
        end

        -- After execution, close menu and despawn invisible NPC
        player:GossipComplete() 
        if object.DespawnOrUnsummon then
            object:DespawnOrUnsummon(100) 
        end
    end)
    
    if not status then
        SendWorldMessage("|cffFF0000[Execution Error]|r " .. tostring(err))
    end
end

RegisterPlayerEvent(18, OnSecretChatSignal)
RegisterCreatureGossipEvent(DUMMY_NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(DUMMY_NPC_ID, 2, OnGossipSelect)
RegisterPlayerGossipEvent(MENU_TEXT_ID, 2, OnGossipSelect)