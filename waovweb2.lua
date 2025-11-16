-- 🎯 Advanced Discord Webhook Script 🎯
-- Fotoğraftaki gibi detaylı bilgi gönderir

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local player = Players.LocalPlayer

-- ⚙️ WEBHOOK URL (Kendi webhook URL'inizi buraya yapıştırın)
local WEBHOOK_URL = 'https://discord.com/api/webhooks/1411459046875074642/1ZjrqLDfom1TM1zIRmzmOWIRqbd333TN3e6_RydVbrj-8K1WcOpDMoyrKiM6LKroXkbZ'

-- 📅 Tarih/Saat (GMT+3 Türkiye saati)
local OSTime = os.time() + (3 * 3600) -- GMT+3 için 3 saat ekle
local Time = os.date('!*t', OSTime)
local currentDateTime = string.format('%04d-%02d-%02d %02d:%02d:%02d', 
    Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec)

-- 🎮 Oyuncu bilgilerini topla
local function getPlayerInfo()
    local accountAge = player.AccountAge
    local accountCreated = os.date("%Y-%m-%d", os.time() - (accountAge * 24 * 60 * 60))
    local premium = player.MembershipType == Enum.MembershipType.Premium and "Premium" or "Non-Premium"
    
    return {
        username = player.Name,
        displayName = player.DisplayName,
        userId = player.UserId,
        accountAge = accountAge .. " days",
        accountCreated = accountCreated,
        premium = premium
    }
end

-- 🌐 Network bilgilerini al
local function getNetworkInfo()
    local ping = 0
    if Stats.Network:FindFirstChild("ServerStatsItem") then
        local serverStats = Stats.Network.ServerStatsItem
        if serverStats:FindFirstChild("Data Ping") then
            ping = math.floor(serverStats["Data Ping"]:GetValue())
        end
    end
    
    return {
        ping = ping .. " ms",
        dataType = "(74*CV)"
    }
end

-- 💻 System bilgilerini al
local function getSystemInfo()
    local resolution = workspace.CurrentCamera.ViewportSize
    local memory = Stats:GetTotalMemoryUsageMb()
    
    return {
        resolution = math.floor(resolution.X) .. "x" .. math.floor(resolution.Y),
        memory = math.floor(memory) .. " MB",
        executor = identifyexecutor and identifyexecutor() or "Unknown"
    }
end

-- 🔧 Gerçek Hardware ID al
local function getHardwareID()
    local success, hwid = pcall(function()
        return RbxAnalyticsService:GetClientId()
    end)
    
    if success and hwid then
        return hwid
    else
        return "Unable to retrieve HWID"
    end
end

-- 📊 Server bilgilerini al
local function getServerInfo()
    local serverTime = workspace.DistributedGameTime
    local hours = math.floor(serverTime / 3600)
    local minutes = math.floor((serverTime % 3600) / 60)
    local seconds = math.floor(serverTime % 60)
    local uptimeStr = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    
    return {
        playersInServer = #Players:GetPlayers() .. " / " .. Players.MaxPlayers,
        serverTime = uptimeStr
    }
end

-- 🎯 Ana webhook fonksiyonu
local function sendWebhook()
    local playerInfo = getPlayerInfo()
    local networkInfo = getNetworkInfo()
    local systemInfo = getSystemInfo()
    local serverInfo = getServerInfo()
    local hardwareID = getHardwareID()
    
    -- Embed oluştur
    local embed = {
        title = "Executed",
        description = string.format("**Executed**\n\n%s | A player has ran your script.", playerInfo.username),
        color = 9109504, -- Mavi renk
        timestamp = string.format('%04d-%02d-%02dT%02d:%02d:%02dZ', 
            Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec),
        
        fields = {
            -- Script Info
            {
                name = "🔷 Script Info",
                value = string.format("```📘 Script Name: WaowHub V2\n👤 Executed At: %s```", currentDateTime),
                inline = false
            },
            
            -- Player Details
            {
                name = "👤 Player Details", 
                value = string.format("```🟡 Username: %s\n👤 Display Name: %s\n📅 Account Age: %s\n📆 Account Created: %s\n💎 Premium Status: %s```",
                    playerInfo.username, playerInfo.displayName, playerInfo.accountAge, playerInfo.accountCreated, playerInfo.premium),
                inline = false
            },
            
            -- Game Details
            {
                name = "🎮 Game Details",
                value = string.format("```⚽ Game Name: %s ⚽\n🔗 Game Link: https://www.roblox.com/games/%s```", 
                    game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, 
                    game.PlaceId),
                inline = false
            },
            
            -- Server, Network, System Info
            {
                name = "🔴 Server Info",
                value = string.format("```👥 Players in Server: %s\n⏰ Server Time: %s```", 
                    serverInfo.playersInServer, serverInfo.serverTime),
                inline = true
            },
            {
                name = "💠 Network Info", 
                value = string.format("```📶 Ping: %s %s```", networkInfo.ping, networkInfo.dataType),
                inline = true
            },
            {
                name = "⚙️ System Info",
                value = string.format("```📺 Resolution: %s\n🧠 Memory Usage: %s\n⚡ Executor: %s```", 
                    systemInfo.resolution, systemInfo.memory, systemInfo.executor),
                inline = true
            },
            
            -- Hardware ID
            {
                name = "🔷 Hardware ID",
                value = string.format("```%s```", hardwareID),
                inline = false
            }
        },
        
        footer = {
            text = string.format("NERD SCRIPTER| %s", currentDateTime)
        }
    }
    
    -- Webhook gönder
    local success, result = pcall(function()
        (syn and syn.request or http_request or request) {
            Url = WEBHOOK_URL,
            Method = 'POST',
            Headers = {
                ['Content-Type'] = 'application/json',
            },
            Body = HttpService:JSONEncode({
                content = "",
                embeds = { embed }
            })
        }
    end)
    
    if success then
        -- Webhook başarıyla gönderildi (sessiz)
    else
        -- Webhook gönderilemedi (sessiz)
    end
end

-- 🚀 Script'i çalıştır
sendWebhook()