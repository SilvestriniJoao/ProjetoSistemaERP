-- ========================================
-- MEGA RAMP HUB - painel único com abas (Ramp / Games / Cam / Webhook /
-- Jogadores), responsivo (celular e PC), com botão de minimizar.
-- Junta megaramp_event_loop.lua + minigames_farm.lua + freecam.lua num só
-- script, mais notificação por Discord Webhook e spectate de jogadores.
-- ========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

print("=== MEGA RAMP HUB ===")

local function addLog(msg)
    print("[HUB] " .. msg)
end

local existingGui = playerGui:FindFirstChild("MegaRampHub")
if existingGui then
    existingGui:Destroy()
end

-- ========================================
-- REMOTES
-- ========================================

local function findRemote(name)
    local r = ReplicatedStorage:FindFirstChild(name)
    if r then return r end
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj.Name == name then return obj end
    end
    return nil
end

local retryRunRemote = findRemote("RetryRun")
local endBoxRevealRemote = findRemote("EndBoxReveal")
local startBoxRevealRemote = findRemote("StartBoxReveal")
local clientCarLaunchRemote = findRemote("ClientCarLaunch")
local openBoxClickRemote = findRemote("OpenBoxClick")
local boxStarsRevealRemote = findRemote("BoxStarsReveal")
local sellSlimeOpenRemote = findRemote("SellSlimeOpen")
local sellSlimeActionRemote = findRemote("SellSlimeAction")
local equipBestInventoryRemote = findRemote("EquipBestInventory")
local eventShopUpdateRemote = findRemote("EventShopUpdate")
local eventShopActionRemote = findRemote("EventShopAction")
local selectInventoryItemRemote = findRemote("SelectInventoryItem")
local miniGameMemoryEvent = findRemote("MiniGame1MemoryEvent")
local miniGameButton = Workspace:WaitForChild("MiniGame1Button")
local leaderboardUpdateRemote = findRemote("LeaderboardUpdate")

-- Top 5 leaderboard (Cash/renda base/carros de cada jogador) que o próprio
-- jogo já transmite pra todo mundo -- só precisamos ouvir o mesmo remote,
-- sem precisar construir nada do zero.
local latestLeaderboardData = nil
local refreshLeaderboardUI -- atribuída lá na aba JOGADORES, mais abaixo

if leaderboardUpdateRemote then
    leaderboardUpdateRemote.OnClientEvent:Connect(function(list)
        latestLeaderboardData = list
        if refreshLeaderboardUI then refreshLeaderboardUI() end
    end)
end

-- ========================================
-- DISCORD WEBHOOK
-- ========================================

local webhookConfig = { url = "" }
local webhookToggles = {}

local function getHttpRequestFn()
    if typeof(request) == "function" then return request end
    if typeof(http_request) == "function" then return http_request end
    if typeof(syn) == "table" and typeof(syn.request) == "function" then return syn.request end
    if typeof(fluxus) == "table" and typeof(fluxus.request) == "function" then return fluxus.request end
    return nil
end

local function sendDiscordWebhook(title, description, color3)
    if not webhookConfig.url or webhookConfig.url == "" then return end

    local reqFn = getHttpRequestFn()
    if not reqFn then
        addLog("[WEBHOOK] [!] Executor não suporta request HTTP (request/http_request/syn.request)")
        return
    end

    local c = color3 or Color3.fromRGB(0, 190, 100)
    local colorInt = math.floor(c.R * 255) * 65536 + math.floor(c.G * 255) * 256 + math.floor(c.B * 255)

    local ok, body = pcall(function()
        return HttpService:JSONEncode({
            embeds = {
                { title = title, description = description, color = colorInt }
            }
        })
    end)
    if not ok then return end

    task.spawn(function()
        local sent, err = pcall(function()
            reqFn({
                Url = webhookConfig.url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body,
            })
        end)
        if sent then
            addLog("[WEBHOOK] [✓] Enviado: " .. title)
        else
            addLog("[WEBHOOK] [!] Falha ao enviar: " .. tostring(err))
        end
    end)
end

-- ========================================
-- ANTI-AFK (10 em 10 minutos, sempre rodando)
-- ========================================

local antiAfkIntervalMinutes = 10
local antiAfkJumpCount = 0

local function antiAfkDoJump()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)

    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function() humanoid.Jump = true end)
        end
    end

    antiAfkJumpCount = antiAfkJumpCount + 1
    addLog("[ANTI-AFK] Pulo #" .. antiAfkJumpCount)
end

task.spawn(function()
    while true do
        task.wait(antiAfkIntervalMinutes * 60)
        antiAfkDoJump()
    end
end)

-- ========================================
-- EventConfig (evento mais caro)
-- ========================================

local function findEventConfig()
    local eventSystem = ReplicatedStorage:FindFirstChild("EventSystem")
    if not eventSystem then
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj.Name == "EventSystem" then eventSystem = obj break end
        end
    end
    if not eventSystem then return nil end
    local moduleScript = eventSystem:FindFirstChild("EventConfig")
    if not moduleScript then return nil end
    local ok, cfg = pcall(require, moduleScript)
    if ok and type(cfg) == "table" then return cfg end
    return nil
end

local EventConfig = findEventConfig()
if EventConfig then
    local ok, allEvents = pcall(EventConfig.GetAllEvents)
    print("[+] EventConfig carregado (" .. (ok and #allEvents or 0) .. " eventos)")
else
    print("[-] EventConfig NÃO encontrado")
end

local function findMostExpensiveEvent()
    if not EventConfig then return nil end
    local ok, allEvents = pcall(EventConfig.GetAllEvents)
    if not ok or type(allEvents) ~= "table" or #allEvents == 0 then return nil end
    return allEvents[#allEvents]
end

-- ========================================
-- HELPERS COMPARTILHADOS: teleporte, prompt dual-platform, clique de botão
-- ========================================

local function getPromptWorldPosition(prompt)
    local parent = prompt.Parent
    if parent and parent:IsA("Attachment") then
        return parent.WorldPosition
    elseif parent and parent:IsA("BasePart") then
        return parent.Position
    end
    return nil
end

local function teleportPlayerTo(position)
    local character = LocalPlayer.Character
    if not character then return nil end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local original = hrp.CFrame
    hrp.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    return original
end

local function teleportPlayerBack(originalCFrame)
    if not originalCFrame then return end
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = originalCFrame end
end

local isPcPlatform = UserInputService.KeyboardEnabled

local function triggerPromptGeneric(prompt)
    if isPcPlatform then
        local keyCode = prompt.KeyboardKeyCode
        if not keyCode or keyCode == Enum.KeyCode.Unknown then
            keyCode = Enum.KeyCode.E
        end
        local holdDuration = math.max(tonumber(prompt.HoldDuration) or 0, 0)
        local pressed = pcall(function()
            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        end)
        if not pressed then return false end
        task.wait(holdDuration + 0.15)
        pcall(function()
            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
        end)
        return true
    end

    if typeof(fireproximityprompt) == "function" then
        return pcall(fireproximityprompt, prompt)
    end

    return false
end

local function fireAllConnections(signal)
    local ok, conns = pcall(getconnections, signal)
    if not ok or not conns or #conns == 0 then return false end
    local firedAny = false
    for _, conn in ipairs(conns) do
        local fireOk = pcall(function() conn:Fire() end)
        firedAny = firedAny or fireOk
    end
    return firedAny
end

local function simulateButtonClick(button)
    if fireAllConnections(button.MouseButton1Click) then return true end
    if fireAllConnections(button.Activated) then return true end

    local absPos = button.AbsolutePosition
    local absSize = button.AbsoluteSize
    local x = absPos.X + absSize.X / 2
    local y = absPos.Y + absSize.Y / 2

    local ok = pcall(function()
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)

    if ok then return true end
    return pcall(function() firesignal(button.MouseButton1Click) end)
end

-- ========================================
-- ALERTA: glitterrainbow/limited
-- ========================================

local equipBestSlimes

local function playDivineAlert()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
    sound.Volume = 1
    sound.Parent = playerGui
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

local playingDivineSequence = false
local alertKeywords = { "limitedrainbow" }

local function playDivineAlertSequence(itemName, itemValue)
    if playingDivineSequence then return end
    playingDivineSequence = true

    task.spawn(function()
        for i = 1, 3 do
            playDivineAlert()
            task.wait(0.6)
        end

        addLog("[*] " .. tostring(itemName) .. " alertado 3x, equipando os melhores slimes...")
        if equipBestSlimes then pcall(equipBestSlimes) end

        if webhookToggles.limited and webhookToggles.limited.enabled then
            sendDiscordWebhook("🌟 Item raro encontrado!", tostring(itemName) .. " (valor: " .. tostring(itemValue) .. ")", Color3.fromRGB(255, 200, 0))
        end

        playingDivineSequence = false
    end)
end

if boxStarsRevealRemote then
    boxStarsRevealRemote.OnClientEvent:Connect(function(index, revealed, rarity, name, value)
        if revealed and name then
            local lowerName = name:lower()
            for _, keyword in ipairs(alertKeywords) do
                if lowerName:find(keyword) then
                    print("[ALERTA] Item revelado: " .. name .. " (valor: " .. tostring(value) .. ")")
                    playDivineAlertSequence(name, value)
                    break
                end
            end
        end
    end)
end

-- ========================================
-- VENDER TODOS OS SLIMES
-- ========================================

local latestSellList = nil

if sellSlimeOpenRemote then
    sellSlimeOpenRemote.OnClientEvent:Connect(function(list)
        latestSellList = list
    end)
end

local function findSellSlimePrompt()
    local direct = Workspace:FindFirstChild("SellSlimePrompt", true)
    if direct and direct:IsA("ProximityPrompt") then return direct end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Name == "SellSlimePrompt" then return obj end
    end
    return nil
end

local function findSellSlimeFrame()
    return playerGui:FindFirstChild("SellSlimeFrame", true)
end

local sellingAll = false

local function sellAllSlimesBlocking()
    if not sellSlimeActionRemote then
        addLog("[!] SellSlimeAction não encontrado")
        return
    end
    if sellingAll then
        addLog("[!] Já está vendendo, aguarde terminar")
        return
    end
    if not latestSellList or #latestSellList == 0 then
        addLog("[!] Nenhuma lista de slimes recebida ainda.")
        return
    end

    sellingAll = true
    addLog("[*] Vendendo todos os slimes...")

    local sold = 0
    local stuckCount = 0

    while latestSellList and #latestSellList > 0 and stuckCount < 20 do
        local sizeBefore = #latestSellList
        local item = latestSellList[1]
        local index = item and item.Index

        if index then
            pcall(function() sellSlimeActionRemote:FireServer("Sell", index) end)
            sold = sold + 1
            addLog("[✓] Vendido slime #" .. sold .. " (Index=" .. tostring(index) .. ", restam ~" .. (sizeBefore - 1) .. ")")
        end

        local start = tick()
        while latestSellList and #latestSellList >= sizeBefore and (tick() - start) < 1.5 do
            task.wait(0.05)
        end

        if latestSellList and #latestSellList >= sizeBefore then
            stuckCount = stuckCount + 1
        else
            stuckCount = 0
        end
    end

    addLog("[+] Venda finalizada! Total vendido: " .. sold)
    sellingAll = false

    task.wait(0.2)
    local sellFrame = findSellSlimeFrame()
    if sellFrame then
        local closeBtn = sellFrame:FindFirstChild("Close", true)
        if closeBtn and closeBtn:IsA("GuiButton") then
            local ok = pcall(function() firesignal(closeBtn.MouseButton1Click) end)
            if not ok then sellFrame.Visible = false end
        else
            sellFrame.Visible = false
        end
    end

    local closeStart = tick()
    while true do
        local frame = findSellSlimeFrame()
        if not frame or not frame.Visible then break end
        if (tick() - closeStart) > 3 then
            addLog("[!] Painel de venda não confirmou fechamento, seguindo mesmo assim")
            break
        end
        task.wait(0.1)
    end
end

local function autoSellAllSlimesBlocking()
    if sellingAll then
        addLog("[!] Já está vendendo, aguarde terminar")
        return
    end

    local prompt = findSellSlimePrompt()
    if not prompt then
        addLog("[!] SellSlimePrompt não encontrado no Workspace")
        return
    end

    local promptPos = getPromptWorldPosition(prompt)
    local originalCFrame = nil
    if promptPos then
        originalCFrame = teleportPlayerTo(promptPos)
        addLog("[*] Teleportado até a área de venda")
        task.wait(0.5)
    end

    latestSellList = nil
    local fired = triggerPromptGeneric(prompt)

    if not fired then
        addLog("[!] Não consegui disparar o prompt de venda")
        teleportPlayerBack(originalCFrame)
        return
    end

    addLog("[*] Prompt disparado, aguardando lista de slimes...")

    local start = tick()
    while not latestSellList and (tick() - start) < 5 do
        task.wait(0.05)
    end

    if not latestSellList then
        addLog("[!] Timeout esperando SellSlimeOpen")
        teleportPlayerBack(originalCFrame)
        return
    end

    sellAllSlimesBlocking()

    task.wait(0.3)
    teleportPlayerBack(originalCFrame)
    addLog("[*] Voltou pra posição original (venda)")
end

local function autoSellAllSlimes()
    task.spawn(autoSellAllSlimesBlocking)
end

equipBestSlimes = function()
    if not equipBestInventoryRemote then
        addLog("[!] EquipBestInventory não encontrado")
        return
    end
    pcall(function() equipBestInventoryRemote:FireServer() end)
    addLog("[✓] EquipBestInventory disparado")
end

-- ========================================
-- EVENT SHOP (compartilhado entre a aba Ramp e Bata o Slime)
-- ========================================

local EVENT_DURATION_SECONDS = 600
local EVENT_DURATION_BUFFER_SECONDS = 10

local latestEventShopPayload = nil
if eventShopUpdateRemote then
    eventShopUpdateRemote.OnClientEvent:Connect(function(payload)
        latestEventShopPayload = payload
    end)
end

local function findEventShopPrompt()
    local direct = Workspace:FindFirstChild("EventShopPrompt", true)
    if direct and direct:IsA("ProximityPrompt") then return direct end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Name == "EventShopPrompt" then return obj end
    end
    return nil
end

local function activateMostExpensiveEvent()
    if not eventShopActionRemote then
        addLog("[EVENTO] [!] EventShopAction não encontrado")
        return false
    end

    local event = findMostExpensiveEvent()
    if not event then
        addLog("[EVENTO] [!] Não consegui achar o evento mais caro")
        return false
    end

    addLog("[EVENTO] [*] Ativando evento mais caro: " .. tostring(event.Id) .. " (custo " .. tostring(event.Cost) .. ")")

    pcall(function() LocalPlayer:SetAttribute("EventShopMenuOpen", true) end)
    if selectInventoryItemRemote then
        pcall(function() selectInventoryItemRemote:FireServer(0) end)
    end

    local prompt = findEventShopPrompt()
    local originalCFrame = nil
    if prompt then
        local promptPos = getPromptWorldPosition(prompt)
        if promptPos then
            originalCFrame = teleportPlayerTo(promptPos)
            task.wait(0.2)
        end
    end

    latestEventShopPayload = nil
    pcall(function() eventShopActionRemote:FireServer("RequestState") end)
    task.wait(0.1)
    pcall(function() eventShopActionRemote:FireServer("Activate", event.Id) end)

    local start = tick()
    local confirmed = false
    while (tick() - start) < 5 do
        if latestEventShopPayload and latestEventShopPayload.ActiveEventId == event.Id then
            confirmed = true
            break
        end
        task.wait(0.2)
    end

    if confirmed then
        addLog("[EVENTO] [✓] Evento confirmado ativo: " .. event.Id)
        if webhookToggles.event and webhookToggles.event.enabled then
            sendDiscordWebhook("🎡 Evento ativado", tostring(event.Id) .. " (custo " .. tostring(event.Cost) .. ")", Color3.fromRGB(0, 150, 255))
        end
    else
        addLog("[EVENTO] [!] Não confirmei a ativação")
    end

    teleportPlayerBack(originalCFrame)
    return confirmed
end

local function getActiveEventRemainingSeconds()
    if not eventShopActionRemote then return nil end
    latestEventShopPayload = nil
    pcall(function() eventShopActionRemote:FireServer("RequestState") end)
    local start = tick()
    while not latestEventShopPayload and (tick() - start) < 3 do
        task.wait(0.1)
    end
    if not latestEventShopPayload then return nil end
    if tostring(latestEventShopPayload.ActiveEventId or "") == "" then return nil end
    local endsAt = tonumber(latestEventShopPayload.ActiveEventEndsAt) or 0
    if endsAt <= 0 then return nil end
    local remaining = math.floor(endsAt - os.time())
    if remaining <= 0 then return nil end
    return remaining, latestEventShopPayload.ActiveEventId
end

local function waitWhileRunning(seconds, cfg)
    local deadline = tick() + seconds
    while cfg.running and tick() < deadline do
        task.wait(1)
    end
end

-- ========================================
-- AUTO-PAUSA (genérico, usado pelas 3 automações)
-- ========================================

local function otherPlayersCount()
    return #Players:GetPlayers() - 1
end

local function makeAutoPauseGuards(cfg, getStatusLabel, startFn, stopFn, label)
    local autoResumeWhenAlone = false

    local function pauseIfRunning()
        if cfg.running then
            addLog("[" .. label .. "] [!] Outro jogador entrou, pausando...")
            autoResumeWhenAlone = true
            stopFn()
            local statusLabel = getStatusLabel()
            if statusLabel then
                statusLabel.Text = "Status: PAUSADO (outro jogador)"
                statusLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
            end
        end
    end

    local function resumeIfWaiting()
        if autoResumeWhenAlone then
            addLog("[" .. label .. "] [*] Sozinho de novo, retomando...")
            autoResumeWhenAlone = false
            startFn()
        end
    end

    local function guardedStart()
        if otherPlayersCount() > 0 then
            addLog("[" .. label .. "] [!] Tem outro jogador, vai iniciar quando ficar só.")
            autoResumeWhenAlone = true
            local statusLabel = getStatusLabel()
            if statusLabel then
                statusLabel.Text = "Status: PAUSADO (outro jogador)"
                statusLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
            end
            return
        end
        startFn()
    end

    local function guardedStop()
        autoResumeWhenAlone = false
        stopFn()
    end

    return pauseIfRunning, resumeIfWaiting, guardedStart, guardedStop
end

-- ========================================
-- ABA RAMP: ciclo do evento mais caro + JumpCar
-- ========================================

local rampStatusLabel, rampCountLabel, rampCycleLabel

local rampConfig = {
    running = false,
    loopDelay = 0.3,
    checkpointYOffset = 10,
    intermediateWait = 0.15,
    openBoxClicks = 10,
    openBoxClickDelay = 0.03,
    carSpawnWait = 0.6,
}

local checkpointSlots = { { x = 41.4, y = 11.0, z = 3267.2, enabled = true } }

local function pickRandomCheckpoint()
    local enabledSlots = {}
    for _, slot in ipairs(checkpointSlots) do
        if slot.enabled then table.insert(enabledSlots, slot) end
    end
    if #enabledSlots == 0 then return nil end
    return enabledSlots[math.random(1, #enabledSlots)]
end

local function findJumpCarPart()
    local direct = Workspace:FindFirstChild("JumpCar", true)
    if direct and direct:IsA("BasePart") then return direct end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "JumpCar" and obj:IsA("BasePart") then return obj end
    end
    return nil
end

local jumpCarPart = findJumpCarPart()
print(jumpCarPart and ("[+] JumpCar encontrado: " .. jumpCarPart:GetFullName()) or "[-] JumpCar NÃO encontrado")

local function findPlayerCarModel()
    local userName = LocalPlayer.Name

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("auto") then
            if obj.Name:lower():find(userName:lower()) then return obj end
        end
    end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("_auto") then return obj end
    end

    return nil
end

local teleportCount = 0
local cycleCount = 0

local function waitForEvent(remote, timeout)
    if not remote then return false end
    local fired = false
    local conn
    conn = remote.OnClientEvent:Connect(function(...) fired = true end)

    local start = tick()
    while not fired and (tick() - start) < timeout do
        if not rampConfig.running then break end
        task.wait(0.1)
    end
    conn:Disconnect()
    return fired
end

local function waitForLaunchArgs(timeout)
    if not clientCarLaunchRemote then return false end
    local result = nil
    local conn
    conn = clientCarLaunchRemote.OnClientEvent:Connect(function(carInstance, launchVector, carName, forward, up)
        result = { car = carInstance, vector = launchVector, name = carName, forward = forward, up = up }
    end)

    local start = tick()
    while not result and (tick() - start) < timeout do
        if not rampConfig.running then break end
        task.wait(0.05)
    end
    conn:Disconnect()
    return result
end

local function moveCarTo(car, carPart, position)
    local currentRotation = carPart.CFrame - carPart.CFrame.Position
    local targetCFrame = CFrame.new(position) * currentRotation

    return pcall(function()
        if car.PrimaryPart then
            car:SetPrimaryPartCFrame(targetCFrame)
        else
            carPart.CFrame = targetCFrame
        end
    end)
end

local function teleportToCheckpoint()
    local slot = pickRandomCheckpoint()
    if not slot then
        addLog("[RAMP] [!] Nenhum checkpoint ativado")
        return false
    end

    local car = findPlayerCarModel()
    if not car then
        addLog("[RAMP] [!] Model do carro não encontrado (checkpoint)")
        return false
    end

    local carPart = car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart", true)
    if not carPart then
        addLog("[RAMP] [!] Nenhuma BasePart no carro (checkpoint)")
        return false
    end

    local highPosition = Vector3.new(slot.x, slot.y + rampConfig.checkpointYOffset, slot.z)
    local ok1 = moveCarTo(car, carPart, highPosition)
    if not ok1 then
        addLog("[RAMP] [!] Erro no teleporte intermediário")
        return false
    end

    task.wait(rampConfig.intermediateWait)
    if not rampConfig.running then return false end

    local finalPosition = Vector3.new(slot.x, slot.y, slot.z)
    local ok2 = moveCarTo(car, carPart, finalPosition)

    if ok2 then
        addLog("[RAMP] [✓] Teleportado pro checkpoint")
        return true
    else
        addLog("[RAMP] [!] Erro ao teleportar pro checkpoint final")
        return false
    end
end

local function clickOpenBoxMultiple()
    if not openBoxClickRemote then
        addLog("[RAMP] [!] OpenBoxClick não encontrado")
        return
    end

    for i = 1, rampConfig.openBoxClicks do
        if not rampConfig.running then break end
        pcall(function() openBoxClickRemote:FireServer() end)
        task.wait(rampConfig.openBoxClickDelay)
    end
end

local function forceTeleportToJumpCar()
    if retryRunRemote then
        pcall(function() retryRunRemote:FireServer() end)
        task.wait(rampConfig.carSpawnWait)
    end

    local jumpCar = jumpCarPart or findJumpCarPart()
    if not jumpCar then
        addLog("[RAMP] [!] Parte JumpCar não encontrada")
        return false
    end
    jumpCarPart = jumpCar

    local car = findPlayerCarModel()
    if not car then
        addLog("[RAMP] [!] Model do carro não encontrado")
        return false
    end

    local carPart = car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart", true)
    if not carPart then
        addLog("[RAMP] [!] Nenhuma BasePart no carro " .. car.Name)
        return false
    end

    local currentRotation = carPart.CFrame - carPart.CFrame.Position
    local targetPosition = jumpCar.Position + Vector3.new(0, jumpCar.Size.Y / 2 + 2, 0)
    local targetCFrame = CFrame.new(targetPosition) * currentRotation

    local success, err = pcall(function()
        if car.PrimaryPart then
            car:SetPrimaryPartCFrame(targetCFrame)
        else
            carPart.CFrame = targetCFrame
        end
    end)

    if success then
        teleportCount = teleportCount + 1
        if rampCountLabel then rampCountLabel.Text = "Teleportes forçados: " .. teleportCount end
        return true
    else
        addLog("[RAMP] [!] Erro ao teleportar: " .. tostring(err))
        return false
    end
end

local function runTeleportLoopForDuration(durationSeconds)
    local deadline = tick() + durationSeconds
    addLog("[RAMP] [*] Rodando teleportes por " .. durationSeconds .. "s...")

    while rampConfig.running and tick() < deadline do
        local teleported = forceTeleportToJumpCar()

        if teleported then
            local launchData = waitForLaunchArgs(5)

            if launchData then
                teleportToCheckpoint()
                local started = waitForEvent(startBoxRevealRemote, 8)

                if started then
                    clickOpenBoxMultiple()
                end

                waitForEvent(endBoxRevealRemote, 12)
            end
        end

        if not rampConfig.running or tick() >= deadline then break end
        task.wait(rampConfig.loopDelay)
    end

    addLog("[RAMP] [*] Janela de teleportes encerrada")
end

local function startMasterCycle()
    if rampConfig.running then return end
    rampConfig.running = true
    if rampStatusLabel then
        rampStatusLabel.Text = "Status: ATIVANDO EVENTO..."
        rampStatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    end
    addLog("[RAMP] === CICLO AUTOMÁTICO INICIADO ===")

    task.spawn(function()
        while rampConfig.running do
            local remaining, activeEventId = getActiveEventRemainingSeconds()

            if remaining then
                addLog("[RAMP] [*] Evento já ativo, restam ~" .. remaining .. "s. Retomando sem reativar.")
                if rampStatusLabel then rampStatusLabel.Text = "Status: TELEPORTANDO (evento ativo)" end
                runTeleportLoopForDuration(remaining + EVENT_DURATION_BUFFER_SECONDS)
            else
                if rampStatusLabel then rampStatusLabel.Text = "Status: ATIVANDO EVENTO..." end
                activateMostExpensiveEvent()
                if not rampConfig.running then break end

                if rampStatusLabel then rampStatusLabel.Text = "Status: TELEPORTANDO (evento ativo)" end
                runTeleportLoopForDuration(EVENT_DURATION_SECONDS + EVENT_DURATION_BUFFER_SECONDS)
            end
            if not rampConfig.running then break end

            if rampStatusLabel then rampStatusLabel.Text = "Status: VENDENDO SLIMES..." end
            addLog("[RAMP] [*] Tempo do evento acabou, vendendo todos os slimes...")
            autoSellAllSlimesBlocking()

            cycleCount = cycleCount + 1
            if rampCycleLabel then rampCycleLabel.Text = "Ciclos completos: " .. cycleCount end

            if not rampConfig.running then break end
            task.wait(1)
        end

        if rampStatusLabel then
            rampStatusLabel.Text = "Status: PARADO"
            rampStatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
        end
        addLog("[RAMP] === CICLO AUTOMÁTICO FINALIZADO ===")
    end)
end

local function stopMasterCycle()
    rampConfig.running = false
    addLog("[RAMP] [!] Parando ciclo automático...")
end

-- ========================================
-- DISPATCHER DO REMOTE COMPARTILHADO (Memória + Bata o Slime)
-- ========================================

local memoryLastRejected, memoryLastReward = nil, nil
local hitSlimeToken, hitSlimeLastRejected, hitSlimeLastReward = nil, nil, nil

if miniGameMemoryEvent then
    miniGameMemoryEvent.OnClientEvent:Connect(function(kind, gameType, a, b, c, d)
        kind = tostring(kind or "")
        gameType = tostring(gameType or "")

        if gameType == "Memory" then
            if kind == "RoundRejected" then
                memoryLastRejected = tostring(a or "motivo desconhecido")
                addLog("[MEMORIA] [!] Recusado: " .. memoryLastRejected)
            elseif kind == "RewardResult" then
                memoryLastReward = { success = a == true, amount = b, errorMsg = d }
                if a == true then
                    addLog("[MEMORIA] [✓] Recompensa: +" .. tostring(b))
                    if webhookToggles.memory and webhookToggles.memory.enabled then
                        sendDiscordWebhook("🧠 Memória vencida", "Recompensa: +" .. tostring(b), Color3.fromRGB(0, 190, 100))
                    end
                else
                    addLog("[MEMORIA] [!] Recompensa falhou: " .. tostring(d or "erro"))
                end
            end
        elseif gameType == "HitTheSlime" then
            if kind == "RoundStarted" then
                hitSlimeToken = tostring(a or "")
            elseif kind == "RoundRejected" then
                hitSlimeLastRejected = tostring(a or "motivo desconhecido")
                addLog("[HITSLIME] [!] Recusado: " .. hitSlimeLastRejected)
            elseif kind == "RewardResult" then
                hitSlimeLastReward = { success = a == true, amount = b, errorMsg = d }
                if a == true then
                    addLog("[HITSLIME] [✓] Recompensa: +" .. tostring(b))
                    if webhookToggles.hitslime and webhookToggles.hitslime.enabled then
                        sendDiscordWebhook("🎯 Bata o Slime vencido", "Recompensa: +" .. tostring(b), Color3.fromRGB(0, 185, 235))
                    end
                else
                    addLog("[HITSLIME] [!] Recompensa falhou: " .. tostring(d or "erro"))
                end
            end
        end
    end)
end

-- ========================================
-- ABA GAMES: Memória de Slime
-- ========================================

local memoryStatusLabel, memoryCountLabel

local memoryConfig = {
    running = false,
    studyDelayMin = 1.2,
    studyDelayMax = 2.0,
    clickGapMin = 0.25,
    clickGapMax = 0.4,
    pairGapMin = 0.5,
    pairGapMax = 0.8,
    roundCooldown = 3,
    rejectedCooldown = 15,
}

local function randomRange(min, max)
    return min + math.random() * (max - min)
end

local function findSlimeGameGui()
    return playerGui:FindFirstChild("SlimeGameGui")
end

local function findHubPlayButton(slimeGameGui, targetOrder)
    local hub = slimeGameGui:FindFirstChild("SlimeMinigamesHub", true)
    if not hub then return nil end

    local scroll = hub:FindFirstChild("MinigamesScroll", true)
    if not scroll then return nil end

    local cards = {}
    for _, card in ipairs(scroll:GetChildren()) do
        if card:IsA("Frame") then table.insert(cards, card) end
    end
    table.sort(cards, function(a, b) return a.LayoutOrder < b.LayoutOrder end)

    local card = cards[targetOrder]
    if not card then return nil end

    for _, btn in ipairs(card:GetDescendants()) do
        if btn:IsA("TextButton") then return btn end
    end

    return nil
end

local function openMemoryMinigame()
    local prompt = miniGameButton:FindFirstChild("MiniGame1Prompt", true)
    if not prompt then
        addLog("[MEMORIA] [!] MiniGame1Prompt não encontrado")
        return false
    end

    local fired = triggerPromptGeneric(prompt)
    if not fired then
        addLog("[MEMORIA] [!] Não consegui disparar o prompt")
        return false
    end

    task.wait(0.4)

    local slimeGameGui = findSlimeGameGui()
    if not slimeGameGui then
        addLog("[MEMORIA] [!] SlimeGameGui não encontrado")
        return false
    end

    local playBtn = findHubPlayButton(slimeGameGui, 1)
    if not playBtn then
        addLog("[MEMORIA] [!] Botão PLAY não encontrado no hub")
        return false
    end

    task.wait(0.1)
    if not simulateButtonClick(playBtn) then
        addLog("[MEMORIA] [!] Falha ao clicar PLAY")
        return false
    end

    return true
end

local function waitForMemoryGameFrame(timeout)
    local start = tick()
    while (tick() - start) < timeout do
        local frame = playerGui:FindFirstChild("MemoryGameFrame", true)
        if frame and frame.Visible then return frame end
        task.wait(0.1)
    end
    return nil
end

local function collectCardPairs(memoryGameFrame)
    local groups, order = {}, {}

    for _, obj in ipairs(memoryGameFrame:GetDescendants()) do
        if obj:IsA("Frame") and obj.Name:sub(1, 11) == "MemoryCard_" then
            local clickBtn = obj:FindFirstChild("ClickButton")
            if clickBtn then
                local cardName = obj.Name:sub(12)
                if not groups[cardName] then
                    groups[cardName] = {}
                    table.insert(order, cardName)
                end
                table.insert(groups[cardName], clickBtn)
            end
        end
    end

    local pairsFound = {}
    for _, name in ipairs(order) do
        local buttons = groups[name]
        if #buttons == 2 then
            table.insert(pairsFound, { a = buttons[1], b = buttons[2] })
        end
    end

    return pairsFound
end

local function shufflePairs(list)
    for i = #list, 2, -1 do
        local j = math.random(1, i)
        list[i], list[j] = list[j], list[i]
    end
    return list
end

local function solveMemoryGame()
    local memoryGameFrame = waitForMemoryGameFrame(5)
    if not memoryGameFrame then
        addLog("[MEMORIA] [!] Timeout esperando o grid abrir")
        return
    end

    task.wait(0.2)
    local cardPairs = shufflePairs(collectCardPairs(memoryGameFrame))

    local studyDelay = randomRange(memoryConfig.studyDelayMin, memoryConfig.studyDelayMax)
    task.wait(studyDelay)

    for _, pair in ipairs(cardPairs) do
        if not memoryConfig.running then return end
        if not memoryGameFrame.Visible then break end

        simulateButtonClick(pair.a)
        task.wait(randomRange(memoryConfig.clickGapMin, memoryConfig.clickGapMax))
        simulateButtonClick(pair.b)
        task.wait(randomRange(memoryConfig.pairGapMin, memoryConfig.pairGapMax))
    end
end

local memoryRoundCount = 0

local function runOneMemoryRound()
    memoryLastRejected = nil
    memoryLastReward = nil

    if not openMemoryMinigame() then return end
    solveMemoryGame()

    local start = tick()
    while memoryConfig.running and not memoryLastReward and not memoryLastRejected and (tick() - start) < 6 do
        task.wait(0.2)
    end

    memoryRoundCount = memoryRoundCount + 1
    if memoryCountLabel then memoryCountLabel.Text = "Rodadas: " .. memoryRoundCount end
end

local function startMemoryLoop()
    if memoryConfig.running then return end
    memoryConfig.running = true
    if memoryStatusLabel then
        memoryStatusLabel.Text = "Status: RODANDO"
        memoryStatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    end
    addLog("[MEMORIA] === INICIADO ===")

    task.spawn(function()
        while memoryConfig.running do
            runOneMemoryRound()
            if not memoryConfig.running then break end
            local cooldown = memoryLastRejected and memoryConfig.rejectedCooldown or memoryConfig.roundCooldown
            task.wait(cooldown)
        end
        if memoryStatusLabel then
            memoryStatusLabel.Text = "Status: PARADO"
            memoryStatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
        end
        addLog("[MEMORIA] === FINALIZADO ===")
    end)
end

local function stopMemoryLoop()
    memoryConfig.running = false
    if memoryStatusLabel then
        memoryStatusLabel.Text = "Status: PARADO"
        memoryStatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    end
    addLog("[MEMORIA] Parando...")
end

-- ========================================
-- ABA GAMES: Bata o Slime
-- ========================================

local hitSlimeStatusLabel, hitSlimeCountLabel

local CUMULATIVE_COMPLETED_BY_LEVEL = { 30, 66, 108, 156, 212, 275, 345, 425, 515, 611 }

local hitSlimeConfig = {
    running = false,
    secondsPerRound = 18,
    roundCooldown = 3,
    rejectedCooldown = 15,
}

local hitSlimeRoundCount = 0

local function runHitSlimeAttempt()
    hitSlimeToken = nil
    hitSlimeLastRejected = nil
    hitSlimeLastReward = nil

    pcall(function() miniGameMemoryEvent:FireServer("StartRound", "HitTheSlime") end)

    local start = tick()
    while hitSlimeConfig.running and not hitSlimeToken and not hitSlimeLastRejected and (tick() - start) < 5 do
        task.wait(0.1)
    end

    if not hitSlimeToken then
        addLog("[HITSLIME] [!] Não recebi ServerToken")
        return
    end

    for level, cumulative in ipairs(CUMULATIVE_COMPLETED_BY_LEVEL) do
        if not hitSlimeConfig.running then return end

        task.wait(hitSlimeConfig.secondsPerRound)

        pcall(function()
            miniGameMemoryEvent:FireServer("Progress", "HitTheSlime", hitSlimeToken, level, cumulative)
        end)

        if hitSlimeLastRejected then
            addLog("[HITSLIME] [!] Recusado no nível " .. level .. ", abortando")
            return
        end
    end

    pcall(function() miniGameMemoryEvent:FireServer("WinRound", "HitTheSlime", hitSlimeToken) end)

    local waitStart = tick()
    while hitSlimeConfig.running and not hitSlimeLastReward and (tick() - waitStart) < 6 do
        task.wait(0.2)
    end

    hitSlimeRoundCount = hitSlimeRoundCount + 1
    if hitSlimeCountLabel then hitSlimeCountLabel.Text = "Rodadas: " .. hitSlimeRoundCount end
end

local function startHitSlimeLoop()
    if hitSlimeConfig.running then return end
    hitSlimeConfig.running = true
    if hitSlimeStatusLabel then
        hitSlimeStatusLabel.Text = "Status: RODANDO"
        hitSlimeStatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    end
    addLog("[HITSLIME] === INICIADO === (" .. hitSlimeConfig.secondsPerRound .. "s por nível)")

    task.spawn(function()
        while hitSlimeConfig.running do
            runHitSlimeAttempt()
            if not hitSlimeConfig.running then break end
            local cooldown = hitSlimeLastRejected and hitSlimeConfig.rejectedCooldown or hitSlimeConfig.roundCooldown
            task.wait(cooldown)
        end
        if hitSlimeStatusLabel then
            hitSlimeStatusLabel.Text = "Status: PARADO"
            hitSlimeStatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
        end
        addLog("[HITSLIME] === FINALIZADO ===")
    end)

    task.spawn(function()
        while hitSlimeConfig.running do
            activateMostExpensiveEvent()
            if not hitSlimeConfig.running then break end
            waitWhileRunning(EVENT_DURATION_SECONDS + EVENT_DURATION_BUFFER_SECONDS, hitSlimeConfig)
        end
    end)
end

local function stopHitSlimeLoop()
    hitSlimeConfig.running = false
    if hitSlimeStatusLabel then
        hitSlimeStatusLabel.Text = "Status: PARADO"
        hitSlimeStatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    end
    addLog("[HITSLIME] Parando...")
end

-- ========================================
-- CRIA OS GUARDS DE AUTO-PAUSA (só agora que start/stop de todos já existem)
-- ========================================

local rampPause, rampResume, rampGuardedStart, rampGuardedStop =
    makeAutoPauseGuards(rampConfig, function() return rampStatusLabel end, startMasterCycle, stopMasterCycle, "RAMP")
local memoryPause, memoryResume, memoryGuardedStart, memoryGuardedStop =
    makeAutoPauseGuards(memoryConfig, function() return memoryStatusLabel end, startMemoryLoop, stopMemoryLoop, "MEMORIA")
local hitSlimePause, hitSlimeResume, hitSlimeGuardedStart, hitSlimeGuardedStop =
    makeAutoPauseGuards(hitSlimeConfig, function() return hitSlimeStatusLabel end, startHitSlimeLoop, stopHitSlimeLoop, "HITSLIME")

Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then return end
    rampPause()
    memoryPause()
    hitSlimePause()
end)

Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then return end
    task.wait(0.2)
    rampResume()
    memoryResume()
    hitSlimeResume()
end)

-- ========================================
-- ABA CAM: Free Cam + ABA JOGADORES: Spectate
-- ========================================

local freecamConfig = { active = false, baseSpeed = 60, boostMultiplier = 3 }
local freecamAnchoredHrp = nil
local freecamSavedHrpAnchored = false
local freecamSavedCameraType = Enum.CameraType.Custom
local freecamYaw, freecamPitch = 0, 0
local freecamLooking = false
local freecamConnections = {}
local freecamStatusLabel

local spectatingPlayer = nil
local playersStatusLabel

local enableFreecam, disableFreecam, toggleFreecam
local startSpectate, stopSpectate

local function freecamDisconnectAll()
    for _, conn in ipairs(freecamConnections) do
        conn:Disconnect()
    end
    freecamConnections = {}
end

local function getCharacterHrp()
    local character = LocalPlayer.Character
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart")
end

enableFreecam = function()
    if freecamConfig.active then return end
    if spectatingPlayer then stopSpectate() end

    local camera = Workspace.CurrentCamera
    freecamSavedCameraType = camera.CameraType

    local hrp = getCharacterHrp()
    if hrp then
        freecamAnchoredHrp = hrp
        freecamSavedHrpAnchored = hrp.Anchored
        hrp.Anchored = true
    end

    local lookVector = camera.CFrame.LookVector
    freecamPitch = math.asin(math.clamp(lookVector.Y, -1, 1))
    freecamYaw = math.atan2(-lookVector.X, -lookVector.Z)

    camera.CameraType = Enum.CameraType.Scriptable
    freecamConfig.active = true
    if freecamStatusLabel then
        freecamStatusLabel.Text = "Status: ATIVO (F5 pra sair)"
        freecamStatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    end
    addLog("[CAM] Freecam ativado")

    table.insert(freecamConnections, UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            freecamLooking = true
            pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter end)
        end
    end))

    table.insert(freecamConnections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            freecamLooking = false
            pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.Default end)
        end
    end))

    table.insert(freecamConnections, UserInputService.InputChanged:Connect(function(input)
        if freecamLooking and input.UserInputType == Enum.UserInputType.MouseMovement then
            freecamYaw = freecamYaw - input.Delta.X * 0.0025
            freecamPitch = math.clamp(freecamPitch - input.Delta.Y * 0.0025, -math.rad(89), math.rad(89))
        end
    end))

    table.insert(freecamConnections, RunService.RenderStepped:Connect(function(dt)
        local cam = Workspace.CurrentCamera
        local rotation = CFrame.Angles(0, freecamYaw, 0) * CFrame.Angles(freecamPitch, 0, 0)

        local moveVector = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector += Vector3.new(0, 0, -1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector += Vector3.new(0, 0, 1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector += Vector3.new(-1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector += Vector3.new(1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.C) then
            moveVector += Vector3.new(0, -1, 0)
        end

        if moveVector.Magnitude > 0 then moveVector = moveVector.Unit end

        local speed = freecamConfig.baseSpeed
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            speed = speed * freecamConfig.boostMultiplier
        end

        local worldMove = rotation:VectorToWorldSpace(moveVector) * speed * dt
        cam.CFrame = CFrame.new(cam.CFrame.Position + worldMove) * rotation
    end))
end

disableFreecam = function()
    if not freecamConfig.active then return end
    freecamConfig.active = false

    freecamDisconnectAll()
    freecamLooking = false
    pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.Default end)

    local camera = Workspace.CurrentCamera
    camera.CameraType = freecamSavedCameraType == Enum.CameraType.Scriptable and Enum.CameraType.Custom or freecamSavedCameraType

    if freecamAnchoredHrp and freecamAnchoredHrp.Parent then
        freecamAnchoredHrp.Anchored = freecamSavedHrpAnchored
    end
    freecamAnchoredHrp = nil

    if freecamStatusLabel then
        freecamStatusLabel.Text = "Status: DESATIVADO"
        freecamStatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    end
    addLog("[CAM] Freecam desativado")
end

toggleFreecam = function()
    if freecamConfig.active then disableFreecam() else enableFreecam() end
end

startSpectate = function(player)
    if not player or player == LocalPlayer then return end
    if freecamConfig.active then disableFreecam() end

    local character = player.Character
    if not character then
        addLog("[PLAYERS] [!] " .. player.Name .. " não tem personagem carregado")
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local camera = Workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid or character:FindFirstChild("Head") or character.PrimaryPart

    spectatingPlayer = player
    if playersStatusLabel then
        playersStatusLabel.Text = "Status: ASSISTINDO " .. player.Name
        playersStatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    end
    addLog("[PLAYERS] Espectando " .. player.Name)
end

stopSpectate = function()
    if not spectatingPlayer then return end
    spectatingPlayer = nil

    local camera = Workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom
    local myChar = LocalPlayer.Character
    camera.CameraSubject = myChar and myChar:FindFirstChildOfClass("Humanoid")

    if playersStatusLabel then
        playersStatusLabel.Text = "Status: NENHUM (câmera normal)"
        playersStatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    end
    addLog("[PLAYERS] Spectate desativado")
end

LocalPlayer.CharacterAdded:Connect(function()
    if freecamConfig.active then disableFreecam() end
    if spectatingPlayer then stopSpectate() end
end)

Players.PlayerRemoving:Connect(function(player)
    if spectatingPlayer == player then stopSpectate() end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.F5 then
        toggleFreecam()
    end
end)

-- ========================================
-- ESP: ver outros jogadores através de parede (100% visual, só na sua
-- tela -- Highlight + BillboardGui são API padrão do Roblox, não depende
-- de nenhuma função especial do executor).
-- ========================================

local espConfig = { enabled = false, maxDistance = 1000 }
local espObjects = {}
local espCharAddedConns = {}
local espPlayerAddedConn = nil
local espHeartbeatConn = nil
local espStatusLabel

local ESP_COLOR = Color3.fromRGB(255, 60, 60)

local function removeEspFor(player)
    local data = espObjects[player]
    if not data then return end
    if data.highlight then data.highlight:Destroy() end
    if data.billboard then data.billboard:Destroy() end
    espObjects[player] = nil
end

local function attachEspFor(player)
    if player == LocalPlayer then return end
    if espObjects[player] then return end

    local character = player.Character
    if not character then return end
    local head = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    if not head then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "HubESP"
    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0
    highlight.FillColor = ESP_COLOR
    highlight.OutlineColor = ESP_COLOR
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HubESPTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 160, 0, 36)
    billboard.StudsOffset = Vector3.new(0, 1, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = player.Name
    label.Parent = billboard

    espObjects[player] = { highlight = highlight, billboard = billboard, label = label, head = head }
end

local function espHeartbeatStep()
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for player, data in pairs(espObjects) do
        if not player.Character or not data.head or not data.head.Parent then
            removeEspFor(player)
        else
            local dist = nil
            if myHrp then
                local ok, d = pcall(function() return (data.head.Position - myHrp.Position).Magnitude end)
                if ok then dist = d end
            end

            local visible = (not dist) or dist <= espConfig.maxDistance
            data.highlight.Enabled = visible
            data.billboard.Enabled = visible

            if dist then
                data.label.Text = player.Name .. " [" .. math.floor(dist) .. "m]"
            else
                data.label.Text = player.Name
            end
        end
    end
end

local function enableEsp()
    if espConfig.enabled then return end
    espConfig.enabled = true

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            attachEspFor(plr)
            espCharAddedConns[plr] = plr.CharacterAdded:Connect(function()
                task.wait(0.3)
                attachEspFor(plr)
            end)
        end
    end

    espPlayerAddedConn = Players.PlayerAdded:Connect(function(plr)
        attachEspFor(plr)
        espCharAddedConns[plr] = plr.CharacterAdded:Connect(function()
            task.wait(0.3)
            attachEspFor(plr)
        end)
    end)

    espHeartbeatConn = RunService.Heartbeat:Connect(espHeartbeatStep)

    if espStatusLabel then
        espStatusLabel.Text = "Status: ATIVO"
        espStatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    end
    addLog("[ESP] Ativado")
end

local function disableEsp()
    if not espConfig.enabled then return end
    espConfig.enabled = false

    if espHeartbeatConn then espHeartbeatConn:Disconnect() espHeartbeatConn = nil end
    if espPlayerAddedConn then espPlayerAddedConn:Disconnect() espPlayerAddedConn = nil end

    for plr, conn in pairs(espCharAddedConns) do
        conn:Disconnect()
    end
    espCharAddedConns = {}

    for plr in pairs(espObjects) do
        removeEspFor(plr)
    end

    if espStatusLabel then
        espStatusLabel.Text = "Status: DESATIVADO"
        espStatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    end
    addLog("[ESP] Desativado")
end

Players.PlayerRemoving:Connect(function(player)
    if espCharAddedConns[player] then
        espCharAddedConns[player]:Disconnect()
        espCharAddedConns[player] = nil
    end
    removeEspFor(player)
end)

-- ========================================
-- ANIMAÇÕES CUSTOM: edita os IDs de idle/andar/correr DENTRO do script
-- "Animate" do personagem (ele tem um slot separado pra cada estado), em
-- vez de forçar uma animação por cima de tudo -- assim pular/etc continua
-- normal, só idle/andar/correr trocam.
-- ========================================

local animConfig = {
    enabled = false,
    idleId = "",
}

local function normalizeAnimId(id)
    if not id or id == "" then return nil end
    id = tostring(id)
    if not id:match("^rbxassetid://") then
        id = "rbxassetid://" .. id
    end
    return id
end

local function debugAnimateStructure()
    local character = LocalPlayer.Character
    if not character then
        addLog("[ANIM] [!] Sem personagem")
        return
    end

    local animateScript = character:FindFirstChild("Animate")
    if not animateScript then
        addLog("[ANIM] [!] Script 'Animate' NÃO existe nesse personagem")
        return
    end

    local lines = { "Estrutura do Animate (" .. animateScript.ClassName .. "):" }

    local function dump(obj, depth)
        for _, child in ipairs(obj:GetChildren()) do
            local extra = ""
            if child:IsA("Animation") then
                extra = " -> AnimationId=" .. tostring(child.AnimationId)
            elseif child:IsA("StringValue") then
                extra = " = " .. tostring(child.Value)
            end
            table.insert(lines, string.rep("  ", depth) .. child.Name .. " (" .. child.ClassName .. ")" .. extra)
            dump(child, depth + 1)
        end
    end
    dump(animateScript, 1)

    local fullText = table.concat(lines, "\n")
    print("[ANIM-DEBUG]\n" .. fullText)

    if typeof(setclipboard) == "function" then
        local copied = pcall(setclipboard, fullText)
        addLog(copied and "[ANIM] Estrutura copiada pro clipboard! (também tá no console)" or "[ANIM] [!] setclipboard falhou -- veja no console")
    else
        addLog("[ANIM] [!] Esse executor não suporta setclipboard -- veja no console mesmo")
    end
end

-- Não precisa de um CharacterAdded manual aqui: o Heartbeat watcher do
-- IDLE FORÇADO (abaixo) já detecta o personagem novo sozinho e reaplica
-- assim que ele fica parado de novo.

-- ========================================
-- IDLE FORÇADO: toca separado do resto, com prioridade Action4 (a mais
-- alta), looped, sem nunca reiniciar sozinho -- assim não briga com o
-- esquema de troca aleatória do jogo (que causava aquele "soco" voltando
-- pro idle normal). Só fica ativo enquanto o personagem tá parado de
-- verdade -- solta sozinho assim que você anda/corre/pula, pra não
-- atropelar o WalkAnim/RunAnim.
-- ========================================

local idleTrack = nil

local function stopForcedIdle()
    if idleTrack then
        pcall(function() idleTrack:Stop() end)
        idleTrack = nil
    end
end

local function applyForcedIdle()
    stopForcedIdle()

    local id = normalizeAnimId(animConfig.idleId)
    if not id then return end

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = id

    local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
    if not ok or not track then return end

    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = true
    track:Play()
    idleTrack = track
end

RunService.Heartbeat:Connect(function()
    if not animConfig.enabled or not animConfig.idleId or animConfig.idleId == "" then
        if idleTrack then stopForcedIdle() end
        return
    end

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local isStandingStill = humanoid.MoveDirection.Magnitude < 0.05
        and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping
        and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall

    if isStandingStill then
        if not idleTrack or not idleTrack.IsPlaying then
            applyForcedIdle()
        end
    else
        if idleTrack then stopForcedIdle() end
    end
end)

-- Pra não precisar caçar o ID manualmente: toca o emote/animação que
-- você já tem (equipado ou comprado no jogo) e captura o que tiver
-- tocando no seu Humanoid nesse instante.
local function getCurrentPlayingAnimId()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not animator then return nil end

    local ok, tracks = pcall(function() return animator:GetPlayingAnimationTracks() end)
    if not ok or not tracks then return nil end

    for _, track in ipairs(tracks) do
        if track.Animation and track.Animation.AnimationId and track.Animation.AnimationId ~= "" then
            return track.Animation.AnimationId
        end
    end
    return nil
end

-- ========================================
-- MENU: painel único responsivo com abas
--
-- Tudo isso vai dentro de uma função própria (chamada logo em seguida) só
-- por causa de um limite real do Luau: uma única função só aceita até 200
-- variáveis locais, e o resto do script (CORE) sozinho já usa quase todas.
-- Como essa função continua definida no mesmo lugar do arquivo, ela ainda
-- enxerga e escreve normalmente em tudo que já existia antes (rampStatusLabel,
-- alertKeywords, etc.) -- só isola o REGISTRO das variáveis daqui de dentro.
-- ========================================

local function setupMenu()

local hubCamera = Workspace.CurrentCamera

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MegaRampHub"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local TITLE_HEIGHT = 34
local TABBAR_HEIGHT = 32

local frame = Instance.new("Frame")
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 150, 255)
frame.Position = UDim2.new(0, 16, 0, 16)
frame.Draggable = true
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = screenGui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, TITLE_HEIGHT)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "MEGA RAMP HUB"
title.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, TITLE_HEIGHT)
minimizeBtn.Position = UDim2.new(1, -32, 0, 0)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.TextSize = 16
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Text = "—"
minimizeBtn.Parent = titleBar

local body = Instance.new("Frame")
body.Position = UDim2.new(0, 0, 0, TITLE_HEIGHT)
body.Size = UDim2.new(1, 0, 1, -TITLE_HEIGHT)
body.BackgroundTransparency = 1
body.Parent = frame

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, TABBAR_HEIGHT)
tabBar.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
tabBar.BorderSizePixel = 0
tabBar.Parent = body

local contentArea = Instance.new("Frame")
contentArea.Position = UDim2.new(0, 0, 0, TABBAR_HEIGHT)
contentArea.Size = UDim2.new(1, 0, 1, -TABBAR_HEIGHT)
contentArea.BackgroundTransparency = 1
contentArea.Parent = body

local TAB_DEFS = {
    { key = "ramp", icon = "🎡" },
    { key = "games", icon = "🎮" },
    { key = "cam", icon = "📷" },
    { key = "esp", icon = "🎯" },
    { key = "anim", icon = "🕺" },
    { key = "webhook", icon = "🔔" },
    { key = "players", icon = "👥" },
}

local tabButtons = {}
local tabFrames = {}

local function makeTabScroll(key)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = key
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 5
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = false
    scroll.Parent = contentArea

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = scroll

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = scroll

    return scroll
end

for _, def in ipairs(TAB_DEFS) do
    tabFrames[def.key] = makeTabScroll(def.key)
end

local function selectTab(key)
    for k, f in pairs(tabFrames) do
        f.Visible = (k == key)
    end
    for k, b in pairs(tabButtons) do
        b.BackgroundColor3 = (k == key) and Color3.fromRGB(55, 55, 55) or Color3.fromRGB(24, 24, 24)
    end
end

local tabW = 1 / #TAB_DEFS
for i, def in ipairs(TAB_DEFS) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(tabW, 0, 1, 0)
    btn.Position = UDim2.new(tabW * (i - 1), 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.Text = def.icon
    btn.Parent = tabBar

    btn.MouseButton1Click:Connect(function() selectTab(def.key) end)
    tabButtons[def.key] = btn
end

-- --- helpers de widget ---

-- Instances do Roblox (ScrollingFrame etc.) não aceitam campos Lua soltos
-- tipo tab._n = 0 -- por isso o contador de LayoutOrder de cada aba fica
-- numa tabela à parte, indexada pela própria Instance da aba.
local tabOrderCounters = {}

local function tabOrder(tab)
    local n = (tabOrderCounters[tab] or 0) + 1
    tabOrderCounters[tab] = n
    return n
end

local function addSectionLabel(tab, text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color or Color3.fromRGB(0, 190, 100)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.LayoutOrder = tabOrder(tab)
    lbl.Parent = tab
    return lbl
end

local function addButton(tab, text, color, height)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, height or 36)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.LayoutOrder = tabOrder(tab)
    btn.Parent = tab
    return btn
end

local function addTwoButtons(tab, textA, colorA, textB, colorB, height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, height or 36)
    row.BackgroundTransparency = 1
    row.LayoutOrder = tabOrder(tab)
    row.Parent = tab

    local a = Instance.new("TextButton")
    a.Size = UDim2.new(0.5, -4, 1, 0)
    a.BackgroundColor3 = colorA
    a.TextColor3 = Color3.new(1, 1, 1)
    a.TextSize = 12
    a.Font = Enum.Font.GothamBold
    a.Text = textA
    a.Parent = row

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.5, -4, 1, 0)
    b.Position = UDim2.new(0.5, 4, 0, 0)
    b.BackgroundColor3 = colorB
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.Text = textB
    b.Parent = row

    return a, b
end

local function addFullLabel(tab, initialText, textColor)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    lbl.TextColor3 = textColor or Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = initialText
    lbl.LayoutOrder = tabOrder(tab)
    lbl.Parent = tab
    return lbl
end

local function addTextField(tab, labelText, initialValue)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = labelText
    lbl.LayoutOrder = tabOrder(tab)
    lbl.Parent = tab

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 28)
    box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.TextSize = 12
    box.Font = Enum.Font.Gotham
    box.Text = tostring(initialValue)
    box.ClearTextOnFocus = false
    box.LayoutOrder = tabOrder(tab)
    box.Parent = tab

    return box
end

local function addDivider(tab)
    local d = Instance.new("Frame")
    d.Size = UDim2.new(1, 0, 0, 1)
    d.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    d.BorderSizePixel = 0
    d.LayoutOrder = tabOrder(tab)
    d.Parent = tab
end

local function addInfoLabel(tab, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    lbl.TextSize = 9
    lbl.TextWrapped = true
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.Text = text
    lbl.LayoutOrder = tabOrder(tab)
    lbl.Parent = tab
    return lbl
end

local function addToggleRow(tab, labelText, initialEnabled)
    local state = { enabled = initialEnabled }
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = initialEnabled and Color3.fromRGB(0, 110, 60) or Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Text = (initialEnabled and "✓ " or "✗ ") .. labelText
    btn.LayoutOrder = tabOrder(tab)
    btn.Parent = tab

    btn.MouseButton1Click:Connect(function()
        state.enabled = not state.enabled
        btn.BackgroundColor3 = state.enabled and Color3.fromRGB(0, 110, 60) or Color3.fromRGB(60, 60, 60)
        btn.Text = (state.enabled and "✓ " or "✗ ") .. labelText
    end)

    return state
end

-- --- ABA RAMP ---

local rampTab = tabFrames.ramp
addSectionLabel(rampTab, "CICLO EVENTO MAIS CARO", Color3.fromRGB(255, 140, 60))
local rampStartBtn, rampStopBtn = addTwoButtons(rampTab, "▶ INICIAR", Color3.fromRGB(0, 150, 0), "■ PARAR", Color3.fromRGB(150, 0, 0))
local toggleAlertBtn = addButton(rampTab, "🔔 ALERTA: LIMITED RAINBOW", Color3.fromRGB(150, 100, 0), 30)
local sellAllBtn = addButton(rampTab, "💰 VENDER TODOS OS SLIMES (manual)", Color3.fromRGB(0, 150, 100), 34)

addSectionLabel(rampTab, "Checkpoint (X, Y, Z):", Color3.fromRGB(200, 200, 200))
local checkpointContainer = Instance.new("Frame")
checkpointContainer.Size = UDim2.new(1, 0, 0, 30)
checkpointContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
checkpointContainer.BorderSizePixel = 1
checkpointContainer.BorderColor3 = Color3.fromRGB(100, 100, 100)
checkpointContainer.LayoutOrder = tabOrder(rampTab)
checkpointContainer.Parent = rampTab

do
    local slot = checkpointSlots[1]
    local yPos = 3

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 24, 0, 24)
    toggle.Position = UDim2.new(0, 3, 0, yPos)
    toggle.BackgroundColor3 = slot.enabled and Color3.fromRGB(255, 85, 0) or Color3.fromRGB(60, 60, 60)
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.TextSize = 12
    toggle.Font = Enum.Font.GothamBold
    toggle.Text = slot.enabled and "✓" or ""
    toggle.Parent = checkpointContainer

    local function makeInput(field, xPos, width)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0, width, 0, 24)
        box.Position = UDim2.new(0, xPos, 0, yPos)
        box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        box.TextColor3 = Color3.new(1, 1, 1)
        box.TextSize = 11
        box.Font = Enum.Font.Gotham
        box.Text = tostring(slot[field])
        box.PlaceholderText = field:upper()
        box.ClearTextOnFocus = false
        box.Parent = checkpointContainer

        box.FocusLost:Connect(function()
            local val = tonumber(box.Text)
            if val then slot[field] = val end
        end)
        return box
    end

    makeInput("x", 32, 78)
    makeInput("y", 114, 78)
    makeInput("z", 196, 90)

    toggle.MouseButton1Click:Connect(function()
        slot.enabled = not slot.enabled
        toggle.BackgroundColor3 = slot.enabled and Color3.fromRGB(255, 85, 0) or Color3.fromRGB(60, 60, 60)
        toggle.Text = slot.enabled and "✓" or ""
    end)
end

rampStatusLabel = addFullLabel(rampTab, "Status: PARADO", Color3.fromRGB(100, 200, 100))
rampCountLabel = addFullLabel(rampTab, "Teleportes forçados: 0", Color3.fromRGB(200, 200, 255))
rampCycleLabel = addFullLabel(rampTab, "Ciclos completos: 0", Color3.fromRGB(255, 200, 100))
addInfoLabel(rampTab, "Ativa o evento mais caro, teleporta no JumpCar até acabar, vende tudo e repete sozinho até PARAR. Pausa sozinho se outro jogador entrar na sala.")

rampStartBtn.MouseButton1Click:Connect(rampGuardedStart)
rampStopBtn.MouseButton1Click:Connect(rampGuardedStop)
toggleAlertBtn.MouseButton1Click:Connect(function()
    if alertKeywords[1] == "limitedrainbow" then
        alertKeywords = { "limited" }
        toggleAlertBtn.Text = "🔔 ALERTA: TODOS OS LIMITED"
    else
        alertKeywords = { "limitedrainbow" }
        toggleAlertBtn.Text = "🔔 ALERTA: LIMITED RAINBOW"
    end
end)
sellAllBtn.MouseButton1Click:Connect(function() autoSellAllSlimes() end)

-- --- ABA GAMES ---

local gamesTab = tabFrames.games
addSectionLabel(gamesTab, "MEMÓRIA DE SLIME", Color3.fromRGB(0, 190, 100))
local memoryStartBtnUi, memoryStopBtnUi = addTwoButtons(gamesTab, "▶ JOGAR", Color3.fromRGB(0, 150, 0), "■ PARAR", Color3.fromRGB(150, 0, 0))
memoryStatusLabel = addFullLabel(gamesTab, "Status: PARADO", Color3.fromRGB(100, 200, 100))
memoryCountLabel = addFullLabel(gamesTab, "Rodadas: 0", Color3.fromRGB(200, 200, 255))

addDivider(gamesTab)

addSectionLabel(gamesTab, "BATA O SLIME", Color3.fromRGB(0, 185, 235))
local secondsInput = addTextField(gamesTab, "Segundos por rodada (nível):", hitSlimeConfig.secondsPerRound)
secondsInput.FocusLost:Connect(function()
    local val = tonumber(secondsInput.Text)
    if val and val >= 0 then
        hitSlimeConfig.secondsPerRound = val
    else
        secondsInput.Text = tostring(hitSlimeConfig.secondsPerRound)
    end
end)
local hitSlimeStartBtnUi, hitSlimeStopBtnUi = addTwoButtons(gamesTab, "▶ JOGAR", Color3.fromRGB(0, 150, 0), "■ PARAR", Color3.fromRGB(150, 0, 0))
hitSlimeStatusLabel = addFullLabel(gamesTab, "Status: PARADO", Color3.fromRGB(100, 200, 100))
hitSlimeCountLabel = addFullLabel(gamesTab, "Rodadas: 0", Color3.fromRGB(200, 200, 255))

addInfoLabel(gamesTab, "Memória joga de verdade. Bata o Slime é atalho por remote (~180s totais pra não cair no \"Too fast\"). Só existe UMA rodada ativa por vez no servidor. Os dois repetem sozinhos até PARAR e pausam se outro jogador entrar.")

memoryStartBtnUi.MouseButton1Click:Connect(memoryGuardedStart)
memoryStopBtnUi.MouseButton1Click:Connect(memoryGuardedStop)
hitSlimeStartBtnUi.MouseButton1Click:Connect(hitSlimeGuardedStart)
hitSlimeStopBtnUi.MouseButton1Click:Connect(hitSlimeGuardedStop)

-- --- ABA CAM ---

local camTab = tabFrames.cam
addSectionLabel(camTab, "FREE CAM", Color3.fromRGB(0, 150, 255))
local speedInput = addTextField(camTab, "Velocidade base (studs/s):", freecamConfig.baseSpeed)
speedInput.FocusLost:Connect(function()
    local val = tonumber(speedInput.Text)
    if val and val > 0 then
        freecamConfig.baseSpeed = val
    else
        speedInput.Text = tostring(freecamConfig.baseSpeed)
    end
end)
local camEnableBtn, camDisableBtn = addTwoButtons(camTab, "▶ ATIVAR", Color3.fromRGB(0, 150, 0), "■ DESATIVAR", Color3.fromRGB(150, 0, 0))
freecamStatusLabel = addFullLabel(camTab, "Status: DESATIVADO", Color3.fromRGB(100, 200, 100))
addInfoLabel(camTab, "Botão direito + mover = olhar. WASD move, Space/Ctrl sobe e desce, Shift acelera. F5 liga/desliga a qualquer momento, em qualquer aba. Personagem fica ancorado (parado) enquanto ativo.")

camEnableBtn.MouseButton1Click:Connect(enableFreecam)
camDisableBtn.MouseButton1Click:Connect(disableFreecam)

-- --- ABA ESP ---

local espTab = tabFrames.esp
addSectionLabel(espTab, "ESP (VER JOGADORES)", Color3.fromRGB(255, 60, 60))
local espEnableBtn, espDisableBtn = addTwoButtons(espTab, "▶ ATIVAR", Color3.fromRGB(0, 150, 0), "■ DESATIVAR", Color3.fromRGB(150, 0, 0))
espStatusLabel = addFullLabel(espTab, "Status: DESATIVADO", Color3.fromRGB(100, 200, 100))
local espDistanceInput = addTextField(espTab, "Distância máxima (studs):", espConfig.maxDistance)
espDistanceInput.FocusLost:Connect(function()
    local val = tonumber(espDistanceInput.Text)
    if val and val > 0 then
        espConfig.maxDistance = val
    else
        espDistanceInput.Text = tostring(espConfig.maxDistance)
    end
end)
addInfoLabel(espTab, "Mostra um contorno colorido + nome/distância de cada jogador através de parede. 100% visual, só na SUA tela -- não afeta o jogo de ninguém, nem aparece pros outros.")

espEnableBtn.MouseButton1Click:Connect(enableEsp)
espDisableBtn.MouseButton1Click:Connect(disableEsp)

-- --- ABA ANIM ---

local animTab = tabFrames.anim
addSectionLabel(animTab, "ANIMAÇÃO CUSTOM (SÓ IDLE)", Color3.fromRGB(255, 200, 0))

local idleBox = addTextField(animTab, "Animation ID do IDLE (parado):", animConfig.idleId)
idleBox.FocusLost:Connect(function() animConfig.idleId = idleBox.Text end)

local captureBtn = addButton(animTab, "📋 CAPTURAR ANIMAÇÃO ATUAL → IDLE (toque o emote antes de clicar)", Color3.fromRGB(90, 90, 200), 32)
captureBtn.MouseButton1Click:Connect(function()
    local id = getCurrentPlayingAnimId()
    if id then
        animConfig.idleId = id
        idleBox.Text = id
        addLog("[ANIM] Capturado: " .. id)
    else
        addLog("[ANIM] [!] Nenhuma animação tocando agora -- toque o emote primeiro")
    end
end)

local diagBtn = addButton(animTab, "🔍 DIAGNOSTICAR (mostra estrutura do Animate no console)", Color3.fromRGB(150, 100, 0), 32)
diagBtn.MouseButton1Click:Connect(function() debugAnimateStructure() end)

local animToggleBtn = Instance.new("TextButton")
animToggleBtn.Size = UDim2.new(1, 0, 0, 30)
animToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
animToggleBtn.TextColor3 = Color3.new(1, 1, 1)
animToggleBtn.TextSize = 12
animToggleBtn.Font = Enum.Font.GothamBold
animToggleBtn.Text = "✗ APLICAR (só idle -- o resto continua normal)"
animToggleBtn.LayoutOrder = tabOrder(animTab)
animToggleBtn.Parent = animTab
animToggleBtn.MouseButton1Click:Connect(function()
    animConfig.enabled = not animConfig.enabled
    animToggleBtn.BackgroundColor3 = animConfig.enabled and Color3.fromRGB(0, 130, 60) or Color3.fromRGB(60, 60, 60)
    animToggleBtn.Text = (animConfig.enabled and "✓ " or "✗ ") .. "APLICAR (só idle -- o resto continua normal)"
    if animConfig.enabled then applyForcedIdle() end
end)

local animReapplyBtn = addButton(animTab, "🔄 REAPLICAR (depois de mudar o ID)", Color3.fromRGB(90, 90, 200), 32)
animReapplyBtn.MouseButton1Click:Connect(function()
    animConfig.enabled = true
    animToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 60)
    animToggleBtn.Text = "✓ APLICAR (só idle -- o resto continua normal)"
    applyForcedIdle()
end)

addInfoLabel(animTab, "IDLE toca separado (prioridade alta, sem reiniciar sozinho) e só fica ativo enquanto você tá parado -- solta na hora que anda/corre/pula, então não briga com o jogo. ANDAR/CORRER voltaram a ser 100% do jogo (sem forçação). Não precisa caçar o ID: toque o emote/animação que você já tem e clique CAPTURAR pra preencher o IDLE sozinho. Só funciona com animações que você tem direito de usar -- é permissão do próprio Roblox no ID. Reaplica sozinho se você morrer/respawnar.")

-- --- ABA WEBHOOK ---

local webhookTab = tabFrames.webhook
addSectionLabel(webhookTab, "DISCORD WEBHOOK", Color3.fromRGB(114, 137, 218))
local webhookUrlBox = addTextField(webhookTab, "URL do Webhook:", "")
webhookUrlBox.FocusLost:Connect(function()
    webhookConfig.url = webhookUrlBox.Text
end)
local webhookTestBtn = addButton(webhookTab, "🧪 TESTAR", Color3.fromRGB(90, 90, 200), 32)
webhookTestBtn.MouseButton1Click:Connect(function()
    webhookConfig.url = webhookUrlBox.Text
    sendDiscordWebhook("✅ Teste", "Webhook configurado com sucesso no MEGA RAMP HUB!", Color3.fromRGB(0, 190, 100))
end)

addDivider(webhookTab)
addSectionLabel(webhookTab, "NOTIFICAR QUANDO:", Color3.fromRGB(200, 200, 200))
webhookToggles.limited = addToggleRow(webhookTab, "Achar Limited/Rainbow", true)
webhookToggles.memory = addToggleRow(webhookTab, "Ganhar na Memória", false)
webhookToggles.hitslime = addToggleRow(webhookTab, "Ganhar no Bata o Slime", false)
webhookToggles.event = addToggleRow(webhookTab, "Ativar evento (Ramp)", false)

addInfoLabel(webhookTab, "Precisa que o executor suporte request/http_request/syn.request pra funcionar. Clique TESTAR pra confirmar que o link tá certo.")

-- --- ABA JOGADORES ---

local playersTab = tabFrames.players
addSectionLabel(playersTab, "JOGADORES NA PARTIDA", Color3.fromRGB(0, 150, 255))
playersStatusLabel = addFullLabel(playersTab, "Status: NENHUM (câmera normal)", Color3.fromRGB(100, 200, 100))
local stopSpectateBtnUi = addButton(playersTab, "⏹ PARAR SPECTATE", Color3.fromRGB(150, 0, 0), 32)
stopSpectateBtnUi.MouseButton1Click:Connect(function() stopSpectate() end)

addInfoLabel(playersTab, "Spectate é 100% real: só muda SUA câmera pra seguir o jogador escolhido, seu personagem continua parado onde estava. NÃO dá pra ativar automações (tipo o ciclo do Mega Ramp) no client de outro jogador remotamente -- cada um precisaria rodar o próprio script pra isso.")

local rowsContainer = Instance.new("Frame")
rowsContainer.Size = UDim2.new(1, 0, 0, 0)
rowsContainer.AutomaticSize = Enum.AutomaticSize.Y
rowsContainer.BackgroundTransparency = 1
rowsContainer.LayoutOrder = tabOrder(playersTab)
rowsContainer.Parent = playersTab

local rowsLayout = Instance.new("UIListLayout")
rowsLayout.SortOrder = Enum.SortOrder.LayoutOrder
rowsLayout.Padding = UDim.new(0, 4)
rowsLayout.Parent = rowsContainer

local function rebuildPlayerRows()
    for _, child in ipairs(rowsContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local order = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            order = order + 1

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 32)
            row.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            row.LayoutOrder = order
            row.Parent = rowsContainer

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(0.55, -6, 1, 0)
            nameLbl.Position = UDim2.new(0, 6, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.TextColor3 = Color3.new(1, 1, 1)
            nameLbl.TextSize = 11
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Text = plr.Name
            nameLbl.Parent = row

            local specBtn = Instance.new("TextButton")
            specBtn.Size = UDim2.new(0.45, -6, 1, -6)
            specBtn.Position = UDim2.new(0.55, 0, 0, 3)
            specBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
            specBtn.TextColor3 = Color3.new(1, 1, 1)
            specBtn.TextSize = 10
            specBtn.Font = Enum.Font.GothamBold
            specBtn.Text = "👁 SPECTATE"
            specBtn.Parent = row

            specBtn.MouseButton1Click:Connect(function()
                startSpectate(plr)
            end)
        end
    end

    if order == 0 then
        local emptyLbl = Instance.new("TextLabel")
        emptyLbl.Size = UDim2.new(1, 0, 0, 28)
        emptyLbl.BackgroundTransparency = 1
        emptyLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
        emptyLbl.TextSize = 10
        emptyLbl.Font = Enum.Font.Gotham
        emptyLbl.Text = "Nenhum outro jogador na partida."
        emptyLbl.LayoutOrder = 1
        emptyLbl.Parent = rowsContainer
    end
end

Players.PlayerAdded:Connect(function() task.wait(0.1) rebuildPlayerRows() end)
Players.PlayerRemoving:Connect(function() task.wait(0.15) rebuildPlayerRows() end)

rebuildPlayerRows()

addDivider(playersTab)
addSectionLabel(playersTab, "🏆 TOP 5 (CASH) - AO VIVO", Color3.fromRGB(255, 215, 0))
addInfoLabel(playersTab, "Vem direto do placar Top 5 que o servidor já manda pra todo mundo (remote LeaderboardUpdate) -- não precisei construir nada, só escutei o mesmo remote que o próprio jogo usa pra desenhar aquele painel.")

local leaderboardRowsContainer = Instance.new("Frame")
leaderboardRowsContainer.Size = UDim2.new(1, 0, 0, 0)
leaderboardRowsContainer.AutomaticSize = Enum.AutomaticSize.Y
leaderboardRowsContainer.BackgroundTransparency = 1
leaderboardRowsContainer.LayoutOrder = tabOrder(playersTab)
leaderboardRowsContainer.Parent = playersTab

local leaderboardRowsLayout = Instance.new("UIListLayout")
leaderboardRowsLayout.SortOrder = Enum.SortOrder.LayoutOrder
leaderboardRowsLayout.Padding = UDim.new(0, 3)
leaderboardRowsLayout.Parent = leaderboardRowsContainer

local function shortNumberDisplay(n)
    n = tonumber(n) or 0
    local abs = math.abs(n)
    if abs >= 1e12 then
        return string.format("%.2fT", n / 1e12)
    elseif abs >= 1e9 then
        return string.format("%.2fB", n / 1e9)
    elseif abs >= 1e6 then
        return string.format("%.2fM", n / 1e6)
    elseif abs >= 1e3 then
        return string.format("%.2fK", n / 1e3)
    else
        return tostring(math.floor(n))
    end
end

refreshLeaderboardUI = function()
    for _, child in ipairs(leaderboardRowsContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local list = latestLeaderboardData or {}
    if #list == 0 then
        local emptyLbl = Instance.new("TextLabel")
        emptyLbl.Size = UDim2.new(1, 0, 0, 20)
        emptyLbl.BackgroundTransparency = 1
        emptyLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
        emptyLbl.TextSize = 10
        emptyLbl.Font = Enum.Font.Gotham
        emptyLbl.Text = "Aguardando dados do servidor..."
        emptyLbl.LayoutOrder = 1
        emptyLbl.Parent = leaderboardRowsContainer
        return
    end

    for i, entry in ipairs(list) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 24)
        row.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        row.LayoutOrder = i
        row.Parent = leaderboardRowsContainer

        local name = tostring(entry.Name or entry.DisplayName or "?")
        if entry.VIP then name = "[VIP] " .. name end
        local cashText = "$" .. shortNumberDisplay(entry.Cash or 0)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -8, 1, 0)
        lbl.Position = UDim2.new(0, 4, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.TextSize = 10
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = "#" .. tostring(entry.Position or i) .. "  " .. name .. "  —  " .. cashText
        lbl.Parent = row
    end
end

refreshLeaderboardUI()

-- --- RESPONSIVO + MINIMIZAR ---

local MIN_W, MAX_W = 290, 380
local MIN_H, MAX_H = 320, 560

local expandedHeight = 420
local minimized = false

local function computeSize()
    local viewport = hubCamera.ViewportSize
    local w = math.clamp(viewport.X - 24, MIN_W, MAX_W)
    local h = math.clamp(viewport.Y - 90, MIN_H, MAX_H)
    return w, h
end

local function applyResponsiveSize()
    local w, h = computeSize()
    expandedHeight = h
    frame.Size = UDim2.new(0, w, 0, minimized and TITLE_HEIGHT or h)

    local viewport = hubCamera.ViewportSize
    local absPos = frame.AbsolutePosition
    local clampedX = math.clamp(absPos.X, 0, math.max(0, viewport.X - w))
    local clampedY = math.clamp(absPos.Y, 0, math.max(0, viewport.Y - TITLE_HEIGHT))
    if clampedX ~= absPos.X or clampedY ~= absPos.Y then
        frame.Position = UDim2.new(0, clampedX, 0, clampedY)
    end
end

applyResponsiveSize()
hubCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveSize)

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    body.Visible = not minimized
    frame.Size = UDim2.new(0, frame.AbsoluteSize.X, 0, minimized and TITLE_HEIGHT or expandedHeight)
    minimizeBtn.Text = minimized and "▢" or "—"
end)

selectTab("ramp")

addLog("Hub carregado. Use as abas pra navegar. F5 liga/desliga a Free Cam a qualquer momento.")
print("[+] MEGA RAMP HUB carregado!")

end

setupMenu()
