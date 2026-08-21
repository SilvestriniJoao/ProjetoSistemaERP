-- ========================================
-- MEGA RAMP - Teleporta o carro na parte "JumpCar"
-- pra disparar o Touch/launch em loop
-- ========================================

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

print("=== MEGA RAMP TELEPORT TRIGGER ===")

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
local jumpLuckStartRemote = findRemote("JumpLuckStart")
local checkpointLuckUpdateRemote = findRemote("CheckpointLuckUpdate")
local openBoxClickRemote = findRemote("OpenBoxClick")
local boxStarsRevealRemote = findRemote("BoxStarsReveal")
local sellSlimeOpenRemote = findRemote("SellSlimeOpen")
local sellSlimeActionRemote = findRemote("SellSlimeAction")
local equipBestInventoryRemote = findRemote("EquipBestInventory")
local openEventShopRemote = findRemote("OpenEventShop")
local eventShopUpdateRemote = findRemote("EventShopUpdate")
local eventShopActionRemote = findRemote("EventShopAction")
print(sellSlimeOpenRemote and "[+] SellSlimeOpen encontrado" or "[-] SellSlimeOpen NÃO encontrado")
print(sellSlimeActionRemote and "[+] SellSlimeAction encontrado" or "[-] SellSlimeAction NÃO encontrado")
print(equipBestInventoryRemote and "[+] EquipBestInventory encontrado" or "[-] EquipBestInventory NÃO encontrado")
print(openEventShopRemote and "[+] OpenEventShop encontrado" or "[-] OpenEventShop NÃO encontrado")
print(eventShopActionRemote and "[+] EventShopAction encontrado" or "[-] EventShopAction NÃO encontrado")
print(retryRunRemote and "[+] RetryRun encontrado" or "[-] RetryRun NÃO encontrado")
print(startBoxRevealRemote and "[+] StartBoxReveal encontrado" or "[-] StartBoxReveal NÃO encontrado")
print(endBoxRevealRemote and "[+] EndBoxReveal encontrado" or "[-] EndBoxReveal NÃO encontrado")
print(boxStarsRevealRemote and "[+] BoxStarsReveal encontrado" or "[-] BoxStarsReveal NÃO encontrado")

local function addLog(msg)
    print("[TRIGGER] " .. msg)
end

-- Pré-declarado aqui pois só é definido mais abaixo no arquivo
local equipBestSlimes

-- ========================================
-- ALERTA SONORO: toca um som 3x quando revelar glitterRainbow,
-- e no final chama Equip Best automaticamente
-- ========================================

local function playDivineAlert()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
    sound.Volume = 1
    sound.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

local playingDivineSequence = false

local function playDivineAlertSequence()
    if playingDivineSequence then return end
    playingDivineSequence = true

    task.spawn(function()
        for i = 1, 3 do
            playDivineAlert()
            task.wait(0.6)
        end

        addLog("[*] glitterRainbow alertado 3x, equipando os melhores slimes...")
        if equipBestSlimes then
            pcall(equipBestSlimes)
        end

        playingDivineSequence = false
    end)
end

local alertKeywords = {"glitterrainbow", "limited"}

if boxStarsRevealRemote then
    boxStarsRevealRemote.OnClientEvent:Connect(function(index, revealed, rarity, name, value)
        if revealed and name then
            local lowerName = name:lower()
            for _, keyword in ipairs(alertKeywords) do
                if lowerName:find(keyword) then
                    print("[ALERTA] Item revelado: " .. name .. " (valor: " .. tostring(value) .. ")")
                    playDivineAlertSequence()
                    break
                end
            end
        end
    end)
end

-- ========================================
-- VENDER TODOS OS SLIMES
-- SellSlimeOpen manda a lista de slimes vendíveis (S->C).
-- Pra vender: SellSlimeAction:FireServer("Sell", item.Index)
-- O servidor reenvia SellSlimeOpen atualizado depois de cada venda.
-- ========================================

local latestSellList = nil

if sellSlimeOpenRemote then
    sellSlimeOpenRemote.OnClientEvent:Connect(function(list)
        latestSellList = list
    end)
end

-- Acha o ProximityPrompt "SellSlimePrompt" (SellSlimeArea1 > SellSlimePromptAttachment > SellSlimePrompt)
local function findSellSlimePrompt()
    local direct = Workspace:FindFirstChild("SellSlimePrompt", true)
    if direct and direct:IsA("ProximityPrompt") then return direct end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Name == "SellSlimePrompt" then
            return obj
        end
    end
    return nil
end

-- Acha o painel visual "SellSlimeFrame" na PlayerGui, pra fechar depois de vender
local function findSellSlimeFrame()
    return playerGui:FindFirstChild("SellSlimeFrame", true)
end

-- Pega a posição de mundo de um ProximityPrompt (via Attachment pai, se houver)
local function getPromptWorldPosition(prompt)
    local parent = prompt.Parent
    if parent and parent:IsA("Attachment") then
        return parent.WorldPosition
    elseif parent and parent:IsA("BasePart") then
        return parent.Position
    end
    return nil
end

-- Teleporta o personagem pra perto de uma posição, retorna o CFrame original
local function teleportPlayerTo(position)
    local character = Players.LocalPlayer.Character
    if not character then return nil end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local original = hrp.CFrame
    hrp.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    return original
end

local function teleportPlayerBack(originalCFrame)
    if not originalCFrame then return end
    local character = Players.LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = originalCFrame end
end

local sellingAll = false

-- Vende usando sempre o PRIMEIRO item da lista mais atual (não uma lista
-- congelada), assim não trava se os índices mudarem no meio da venda
local function sellAllSlimes()
    if not sellSlimeActionRemote then
        addLog("[!] SellSlimeAction não encontrado")
        return
    end
    if sellingAll then
        addLog("[!] Já está vendendo, aguarde terminar")
        return
    end
    if not latestSellList or #latestSellList == 0 then
        addLog("[!] Nenhuma lista de slimes recebida ainda. Abra a tabela 'Sell Slimes' (aperte E no prompt) pelo menos uma vez.")
        return
    end

    sellingAll = true
    addLog("[*] Vendendo todos os slimes...")

    task.spawn(function()
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

            -- Espera a lista atualizar (o tamanho mudar) ou timeout curto
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

        -- Fecha o painel "Sell Slimes" que o próprio jogo abriu sozinho
        task.wait(0.2)
        local sellFrame = findSellSlimeFrame()
        if sellFrame then
            local closeBtn = sellFrame:FindFirstChild("Close", true)
            if closeBtn and closeBtn:IsA("GuiButton") then
                local ok = pcall(function() firesignal(closeBtn.MouseButton1Click) end)
                if not ok then
                    sellFrame.Visible = false
                end
            else
                sellFrame.Visible = false
            end
        end
    end)
end

-- Teleporta até a área de venda, dispara o prompt, espera a lista chegar,
-- vende tudo e depois volta pra posição original
local function autoSellAllSlimes()
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
        task.wait(0.2)
    end

    latestSellList = nil -- força esperar uma lista nova

    local fired = false
    if typeof(fireproximityprompt) == "function" then
        fired = pcall(fireproximityprompt, prompt)
    end

    if not fired then
        addLog("[!] fireproximityprompt não disponível nesse executor, use o E manualmente perto da área")
        teleportPlayerBack(originalCFrame)
        return
    end

    addLog("[*] Prompt disparado, aguardando lista de slimes...")

    task.spawn(function()
        local start = tick()
        while not latestSellList and (tick() - start) < 5 do
            task.wait(0.05)
        end

        if not latestSellList then
            addLog("[!] Timeout esperando SellSlimeOpen")
            teleportPlayerBack(originalCFrame)
            return
        end

        sellAllSlimes()

        -- Espera a venda terminar antes de voltar
        local waitStart = tick()
        while sellingAll and (tick() - waitStart) < 60 do
            task.wait(0.2)
        end

        task.wait(0.3)
        teleportPlayerBack(originalCFrame)
        addLog("[*] Voltou pra posição original")
    end)
end

-- ========================================
-- EQUIP BEST: equipa os melhores slimes sem abrir o inventário
-- EquipBestInventory:FireServer() sem argumento nenhum
-- ========================================

equipBestSlimes = function()
    if not equipBestInventoryRemote then
        addLog("[!] EquipBestInventory não encontrado")
        return
    end
    pcall(function() equipBestInventoryRemote:FireServer() end)
    addLog("[✓] EquipBestInventory disparado (equipando os melhores slimes)")
end

-- ========================================
-- EVENT SHOP: ativa o evento de índice 3 na lista (o que foi
-- adicionado depois, além dos 2 originais KingTrait/SummerTrait)
-- sem precisar abrir a tabela de eventos manualmente
-- ========================================

local latestEventShopPayload = nil

local function onEventShopPayload(payload)
    latestEventShopPayload = payload
end

if openEventShopRemote then
    openEventShopRemote.OnClientEvent:Connect(onEventShopPayload)
end
if eventShopUpdateRemote then
    eventShopUpdateRemote.OnClientEvent:Connect(onEventShopPayload)
end

-- Acha o ProximityPrompt "EventShopPrompt" (EventShopArea1 > EventShopPromptAttachment > EventShopPrompt)
local function findEventShopPrompt()
    local direct = Workspace:FindFirstChild("EventShopPrompt", true)
    if direct and direct:IsA("ProximityPrompt") then return direct end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Name == "EventShopPrompt" then
            return obj
        end
    end
    return nil
end

local function findEventShopFrame()
    return playerGui:FindFirstChild("EventShopFrame", true)
end

local activatingEvent3 = false

local function activateEventIndex3()
    if not eventShopActionRemote then
        addLog("[!] EventShopAction não encontrado")
        return
    end
    if activatingEvent3 then
        addLog("[!] Já está processando o evento, aguarde")
        return
    end

    local prompt = findEventShopPrompt()
    if not prompt then
        addLog("[!] EventShopPrompt não encontrado no Workspace")
        return
    end

    activatingEvent3 = true
    latestEventShopPayload = nil

    local promptPos = getPromptWorldPosition(prompt)
    local originalCFrame = nil
    if promptPos then
        originalCFrame = teleportPlayerTo(promptPos)
        addLog("[*] Teleportado até o Event Shop")
        task.wait(0.2)
    end

    local fired = false
    if typeof(fireproximityprompt) == "function" then
        fired = pcall(fireproximityprompt, prompt)
    end

    if not fired then
        addLog("[!] fireproximityprompt não disponível nesse executor, use o E manualmente perto da área")
        activatingEvent3 = false
        teleportPlayerBack(originalCFrame)
        return
    end

    addLog("[*] Prompt do Event Shop disparado, aguardando lista de eventos...")

    task.spawn(function()
        local start = tick()
        while not latestEventShopPayload and (tick() - start) < 5 do
            task.wait(0.05)
        end

        if not latestEventShopPayload or type(latestEventShopPayload.Events) ~= "table" then
            addLog("[!] Timeout esperando OpenEventShop/EventShopUpdate")
            activatingEvent3 = false
            teleportPlayerBack(originalCFrame)
            return
        end

        local events = latestEventShopPayload.Events
        local event3 = events[3]
        if not event3 or not event3.Id then
            addLog("[!] Evento de índice 3 não encontrado (só " .. #events .. " evento(s) na lista)")
            activatingEvent3 = false
            teleportPlayerBack(originalCFrame)
            return
        end

        pcall(function() eventShopActionRemote:FireServer("Activate", event3.Id) end)
        addLog("[✓] Evento ativado: " .. tostring(event3.Id))

        task.wait(0.3)
        local eventFrame = findEventShopFrame()
        if eventFrame then
            local closeBtn = eventFrame:FindFirstChild("Close", true) or eventFrame:FindFirstChild("eventCloseButton", true)
            if closeBtn and closeBtn:IsA("GuiButton") then
                local ok = pcall(function() firesignal(closeBtn.MouseButton1Click) end)
                if not ok then
                    eventFrame.Visible = false
                end
            else
                eventFrame.Visible = false
            end
        end

        activatingEvent3 = false
        task.wait(0.3)
        teleportPlayerBack(originalCFrame)
        addLog("[*] Voltou pra posição original")
    end)
end

-- Dispara os 3 eventos com os valores exatos capturados
local function fireCapturedEvents()
    local car = findPlayerCarModel()

    if clientCarLaunchRemote then
        pcall(function()
            clientCarLaunchRemote:FireServer(car, Vector3.new(-75.80, 98.00, 248.70), "Auto4", 260, 98)
        end)
    end

    if jumpLuckStartRemote then
        pcall(function()
            jumpLuckStartRemote:FireServer(Vector3.new(-0.04, 123.91, -1535.73))
        end)
    end

    if checkpointLuckUpdateRemote then
        pcall(function()
            checkpointLuckUpdateRemote:FireServer(70000, 68)
        end)
    end
end

local config = {
    running = false,
    loopDelay = 0.3,  -- segundos entre cada teleporte forçado
    checkpointYOffset = 10,   -- altura extra pro teleporte intermediário
    intermediateWait = 0.15,  -- segundos parado na posição alta antes de descer
    openBoxClicks = 10,       -- quantidade de cliques no OpenBoxClick (super click)
    openBoxClickDelay = 0.03, -- segundos entre cada clique (bem rápido)
    carSpawnWait = 0.6,       -- segundos esperando o carro spawnar após RetryRun
}

-- Até 4 posições de checkpoint. Uma é sorteada aleatoriamente a cada ciclo
-- (evita sempre cair no mesmo valor, o que é fácil de detectar em log)
local checkpointSlots = {
    { x = 41.4, y = 11.0, z = 2767.2, enabled = true },
    { x = 41.4, y = 11.0, z = 2767.2, enabled = false },
    { x = 41.4, y = 11.0, z = 1967.2, enabled = false },
    { x = 41.4, y = 11.0, z = 1267.2, enabled = false },
}

local function pickRandomCheckpoint()
    local enabledSlots = {}
    for _, slot in ipairs(checkpointSlots) do
        if slot.enabled then
            table.insert(enabledSlots, slot)
        end
    end
    if #enabledSlots == 0 then return nil end
    return enabledSlots[math.random(1, #enabledSlots)]
end

local RunService = game:GetService("RunService")

-- Procura a parte "JumpCar" (o gatilho da rampa)
local function findJumpCarPart()
    local direct = Workspace:FindFirstChild("JumpCar", true)
    if direct and direct:IsA("BasePart") then return direct end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "JumpCar" and obj:IsA("BasePart") then
            return obj
        end
    end
    return nil
end

-- Procura o Model do carro do jogador (ex: ztamashiro_Auto4)
local function findPlayerCarModel()
    local character = Players.LocalPlayer.Character
    local userName = Players.LocalPlayer.Name

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("auto") then
            -- Prioriza um carro vinculado ao nome do usuário, se existir
            if obj.Name:lower():find(userName:lower()) then
                return obj
            end
        end
    end

    -- fallback: primeiro model com "_auto" no nome
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("_auto") then
            return obj
        end
    end

    return nil
end

local jumpCarPart = findJumpCarPart()
print(jumpCarPart and ("[+] JumpCar encontrado: " .. jumpCarPart:GetFullName()) or "[-] JumpCar NÃO encontrado")

-- ========================================
-- MENU
-- ========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportTrigger"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 470)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 85, 0)
frame.Draggable = true
frame.Active = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Text = "TELEPORT TRIGGER (JumpCar)"
title.BorderSizePixel = 0
title.Parent = frame

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.5, -15, 0, 40)
startBtn.Position = UDim2.new(0, 10, 0, 45)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
startBtn.TextColor3 = Color3.new(1, 1, 1)
startBtn.TextSize = 13
startBtn.Font = Enum.Font.GothamBold
startBtn.Text = "▶ INICIAR"
startBtn.Parent = frame

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.5, -15, 0, 40)
stopBtn.Position = UDim2.new(0.5, 5, 0, 45)
stopBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
stopBtn.TextColor3 = Color3.new(1, 1, 1)
stopBtn.TextSize = 13
stopBtn.Font = Enum.Font.GothamBold
stopBtn.Text = "■ PARAR"
stopBtn.Parent = frame

local equipBestBtn = Instance.new("TextButton")
equipBestBtn.Size = UDim2.new(1, -20, 0, 30)
equipBestBtn.Position = UDim2.new(0, 10, 0, 90)
equipBestBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
equipBestBtn.TextColor3 = Color3.new(1, 1, 1)
equipBestBtn.TextSize = 12
equipBestBtn.Font = Enum.Font.GothamBold
equipBestBtn.Text = "⭐ EQUIP BEST"
equipBestBtn.Parent = frame

local sellAllBtn = Instance.new("TextButton")
sellAllBtn.Size = UDim2.new(1, -20, 0, 35)
sellAllBtn.Position = UDim2.new(0, 10, 0, 125)
sellAllBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
sellAllBtn.TextColor3 = Color3.new(1, 1, 1)
sellAllBtn.TextSize = 12
sellAllBtn.Font = Enum.Font.GothamBold
sellAllBtn.Text = "💰 VENDER TODOS OS SLIMES"
sellAllBtn.Parent = frame

local eventBtn = Instance.new("TextButton")
eventBtn.Size = UDim2.new(1, -20, 0, 30)
eventBtn.Position = UDim2.new(0, 10, 0, 165)
eventBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
eventBtn.TextColor3 = Color3.new(1, 1, 1)
eventBtn.TextSize = 12
eventBtn.Font = Enum.Font.GothamBold
eventBtn.Text = "🎁 ATIVAR EVENTO 3"
eventBtn.Parent = frame

-- CAMPOS DE POSIÇÃO DOS CHECKPOINTS (até 4, sorteado aleatoriamente a cada ciclo)
local posContainer = Instance.new("Frame")
posContainer.Size = UDim2.new(1, -20, 0, 150)
posContainer.Position = UDim2.new(0, 10, 0, 205)
posContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
posContainer.BorderSizePixel = 1
posContainer.BorderColor3 = Color3.fromRGB(100, 100, 100)
posContainer.Parent = frame

local posLabel = Instance.new("TextLabel")
posLabel.Size = UDim2.new(1, -10, 0, 18)
posLabel.Position = UDim2.new(0, 5, 0, 2)
posLabel.BackgroundTransparency = 1
posLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
posLabel.TextSize = 10
posLabel.Font = Enum.Font.GothamBold
posLabel.Text = "Checkpoints (X, Y, Z) — sorteado a cada ciclo:"
posLabel.TextXAlignment = Enum.TextXAlignment.Left
posLabel.Parent = posContainer

local function createCheckpointRow(slotIndex, yPos)
    local slot = checkpointSlots[slotIndex]

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 24, 0, 24)
    toggle.Position = UDim2.new(0, 5, 0, yPos)
    toggle.BackgroundColor3 = slot.enabled and Color3.fromRGB(255, 85, 0) or Color3.fromRGB(60, 60, 60)
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.TextSize = 12
    toggle.Font = Enum.Font.GothamBold
    toggle.Text = slot.enabled and "✓" or ""
    toggle.Parent = posContainer

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
        box.Parent = posContainer

        box.FocusLost:Connect(function()
            local val = tonumber(box.Text)
            if val then slot[field] = val end
        end)

        return box
    end

    makeInput("x", 35, 80)
    makeInput("y", 120, 80)
    makeInput("z", 205, 80)

    toggle.MouseButton1Click:Connect(function()
        slot.enabled = not slot.enabled
        toggle.BackgroundColor3 = slot.enabled and Color3.fromRGB(255, 85, 0) or Color3.fromRGB(60, 60, 60)
        toggle.Text = slot.enabled and "✓" or ""
    end)
end

createCheckpointRow(1, 22)
createCheckpointRow(2, 52)
createCheckpointRow(3, 82)
createCheckpointRow(4, 112)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 365)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = "Status: PARADO"
statusLabel.Parent = frame

local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, -20, 0, 25)
countLabel.Position = UDim2.new(0, 10, 0, 400)
countLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
countLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
countLabel.TextSize = 11
countLabel.Font = Enum.Font.GothamBold
countLabel.Text = "Teleportes forçados: 0"
countLabel.Parent = frame

-- ========================================
-- LOOP DE TELEPORTE
-- ========================================

local teleportCount = 0

-- Espera um OnClientEvent disparar, com timeout (retorna true se disparou)
local function waitForEvent(remote, timeout)
    if not remote then return false end
    local fired = false
    local conn
    conn = remote.OnClientEvent:Connect(function(...) fired = true end)

    local start = tick()
    while not fired and (tick() - start) < timeout do
        if not config.running then break end
        task.wait(0.1)
    end
    conn:Disconnect()
    return fired
end

-- Espera o ClientCarLaunch disparar e retorna os argumentos recebidos
local function waitForLaunchArgs(timeout)
    if not clientCarLaunchRemote then return false end
    local result = nil
    local conn
    conn = clientCarLaunchRemote.OnClientEvent:Connect(function(carInstance, launchVector, carName, forward, up)
        result = { car = carInstance, vector = launchVector, name = carName, forward = forward, up = up }
    end)

    local start = tick()
    while not result and (tick() - start) < timeout do
        if not config.running then break end
        task.wait(0.05)
    end
    conn:Disconnect()
    return result
end

-- Aplica velocidade amplificada no carro durante um tempo, deixando ele
-- voar de verdade antes de teleportar pro checkpoint
local function boostLaunch(carInstance, launchVector)
    local part = carInstance and (carInstance:IsA("BasePart") and carInstance or carInstance:FindFirstChildWhichIsA("BasePart", true))
    if not part or typeof(launchVector) ~= "Vector3" then
        addLog("[!] Não foi possível aplicar boost (parte/vetor inválido)")
        return
    end

    local boosted = launchVector * config.boostMultiplier
    local start = tick()

    addLog("[*] Boost " .. config.boostMultiplier .. "x aplicado, voando por " .. config.boostDuration .. "s...")

    while config.running and part and part.Parent and (tick() - start) < config.boostDuration do
        pcall(function() part.AssemblyLinearVelocity = boosted end)
        RunService.Heartbeat:Wait()
    end
end

-- Move o carro pra uma posição específica, mantendo a rotação atual
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

-- Teleporta o carro pra posição do checkpoint em DUAS etapas:
-- primeiro numa altura maior (evita passar pelos checkpoints baixos
-- durante a transição), depois desce pra posição final real
local function teleportToCheckpoint()
    local slot = pickRandomCheckpoint()
    if not slot then
        addLog("[!] Nenhum checkpoint ativado")
        return false
    end

    local car = findPlayerCarModel()
    if not car then
        addLog("[!] Model do carro não encontrado (checkpoint)")
        return false
    end

    local carPart = car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart", true)
    if not carPart then
        addLog("[!] Nenhuma BasePart no carro (checkpoint)")
        return false
    end

    -- Etapa 1: posição intermediária, mais alta
    local highPosition = Vector3.new(slot.x, slot.y + config.checkpointYOffset, slot.z)
    local ok1 = moveCarTo(car, carPart, highPosition)
    if not ok1 then
        addLog("[!] Erro no teleporte intermediário")
        return false
    end

    task.wait(config.intermediateWait)
    if not config.running then return false end

    -- Etapa 2: posição final real
    local finalPosition = Vector3.new(slot.x, slot.y, slot.z)
    local ok2 = moveCarTo(car, carPart, finalPosition)

    if ok2 then
        addLog("[✓] Teleportado pro checkpoint (" .. slot.x .. ", " .. slot.y .. ", " .. slot.z .. ")")
        return true
    else
        addLog("[!] Erro ao teleportar pro checkpoint final")
        return false
    end
end

-- Dispara vários cliques no OpenBoxClick pra revelar a caixa
local function clickOpenBoxMultiple()
    if not openBoxClickRemote then
        addLog("[!] OpenBoxClick não encontrado")
        return
    end

    for i = 1, config.openBoxClicks do
        if not config.running then break end
        pcall(function() openBoxClickRemote:FireServer() end)
        addLog("[*] OpenBoxClick #" .. i .. "/" .. config.openBoxClicks)
        task.wait(config.openBoxClickDelay)
    end
end

local function forceTeleportToJumpCar()
    -- Garante que existe um carro pra usar antes de tentar teleportar
    if retryRunRemote then
        pcall(function() retryRunRemote:FireServer() end)
        addLog("[*] RetryRun disparado (pegando carro)")
        task.wait(config.carSpawnWait)
    end

    local jumpCar = jumpCarPart or findJumpCarPart()
    if not jumpCar then
        addLog("[!] Parte JumpCar não encontrada")
        return false
    end
    jumpCarPart = jumpCar

    local car = findPlayerCarModel()
    if not car then
        addLog("[!] Model do carro não encontrado")
        return false
    end

    local carPart = car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart", true)
    if not carPart then
        addLog("[!] Nenhuma BasePart no carro " .. car.Name)
        return false
    end

    -- Mantém a ROTAÇÃO atual do carro, só troca a POSIÇÃO
    -- (evita virar o carro de cara errada por causa da rotação da parte JumpCar)
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
        countLabel.Text = "Teleportes forçados: " .. teleportCount
        addLog("[✓] " .. car.Name .. " teleportado pra JumpCar (#" .. teleportCount .. ")")
        return true
    else
        addLog("[!] Erro ao teleportar: " .. tostring(err))
        return false
    end
end

local function startLoop()
    if config.running then return end
    config.running = true
    statusLabel.Text = "Status: RODANDO"
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    addLog("=== LOOP INICIADO ===")

    task.spawn(function()
        while config.running do
            local teleported = forceTeleportToJumpCar()

            if teleported then
                addLog("[*] Aguardando ClientCarLaunch...")
                local launchData = waitForLaunchArgs(5)

                if launchData then
                    addLog("[✓] Lançamento confirmado! Forward=" .. tostring(launchData.forward) .. " Up=" .. tostring(launchData.up))
                    teleportToCheckpoint()
                    addLog("[*] Aguardando StartBoxReveal...")
                    local started = waitForEvent(startBoxRevealRemote, 8)
                    addLog(started and "[✓] StartBoxReveal recebido!" or "[!] Timeout esperando StartBoxReveal")

                    if started then
                        clickOpenBoxMultiple()
                    end

                    addLog("[*] Aguardando EndBoxReveal...")
                    local ended = waitForEvent(endBoxRevealRemote, 12)
                    addLog(ended and "[✓] Ciclo completo!" or "[!] Timeout esperando EndBoxReveal")
                else
                    addLog("[!] Lançamento não confirmado")
                end
            end

            if not config.running then break end
            task.wait(config.loopDelay)
        end
        statusLabel.Text = "Status: PARADO"
        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
        addLog("=== LOOP FINALIZADO ===")
    end)
end

local function stopLoop()
    config.running = false
    addLog("[!] Parando...")
end

startBtn.MouseButton1Click:Connect(startLoop)
stopBtn.MouseButton1Click:Connect(stopLoop)
equipBestBtn.MouseButton1Click:Connect(function()
    equipBestSlimes()
end)
sellAllBtn.MouseButton1Click:Connect(function()
    autoSellAllSlimes()
end)
eventBtn.MouseButton1Click:Connect(function()
    activateEventIndex3()
end)

addLog("Menu carregado. Clique em INICIAR.")
print("[+] MEGA RAMP TELEPORT TRIGGER carregado!")
