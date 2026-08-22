-- ========================================
-- MEGA RAMP - CICLO AUTOMÁTICO COM EVENTO MAIS CARO
-- Clone do megaramp.lua. No lugar do botão "ATIVAR EVENTO 3" (sistema
-- antigo), o INICIAR agora roda o ciclo inteiro sozinho:
--
--   1) Ativa o evento mais caro da lista (último de EventConfig.GetAllEvents(),
--      hoje é SATURN_LUCK_3X_RAINBOW_FOUR_LEAF_CLOVER_MILLIONAIRE, ~1.9M)
--   2) Confirma que ativou, roda os teleportes no JumpCar por 610s
--      (600s de duração do evento + 10s de folga)
--   3) Para os teleportes, vende todos os slimes e confirma que vendeu
--   4) Ativa o evento mais caro de novo e repete, até clicar em PARAR
-- ========================================

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

print("=== MEGA RAMP EVENT LOOP ===")

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
local eventShopUpdateRemote = findRemote("EventShopUpdate")
local eventShopActionRemote = findRemote("EventShopAction")
local selectInventoryItemRemote = findRemote("SelectInventoryItem")

print(sellSlimeOpenRemote and "[+] SellSlimeOpen encontrado" or "[-] SellSlimeOpen NÃO encontrado")
print(sellSlimeActionRemote and "[+] SellSlimeAction encontrado" or "[-] SellSlimeAction NÃO encontrado")
print(equipBestInventoryRemote and "[+] EquipBestInventory encontrado" or "[-] EquipBestInventory NÃO encontrado")
print(eventShopActionRemote and "[+] EventShopAction encontrado" or "[-] EventShopAction NÃO encontrado")
print(eventShopUpdateRemote and "[+] EventShopUpdate encontrado" or "[-] EventShopUpdate NÃO encontrado")
print(retryRunRemote and "[+] RetryRun encontrado" or "[-] RetryRun NÃO encontrado")
print(startBoxRevealRemote and "[+] StartBoxReveal encontrado" or "[-] StartBoxReveal NÃO encontrado")
print(endBoxRevealRemote and "[+] EndBoxReveal encontrado" or "[-] EndBoxReveal NÃO encontrado")
print(boxStarsRevealRemote and "[+] BoxStarsReveal encontrado" or "[-] BoxStarsReveal NÃO encontrado")

local function addLog(msg)
    print("[TRIGGER] " .. msg)
end

-- ========================================
-- ANTI-AFK: pula sozinho a cada 10 minutos, rodando em segundo plano desde
-- que o script carrega -- independente do ciclo master estar RODANDO ou
-- PARADO, pra nunca cair por inatividade enquanto o script tá aberto.
-- ========================================

local VirtualInputManager = game:GetService("VirtualInputManager")
local antiAfkIntervalMinutes = 10
local antiAfkJumpCount = 0

local function antiAfkDoJump()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)

    local character = Players.LocalPlayer.Character
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

-- Pré-declarado bem cedo aqui pois várias funções abaixo (inclusive as de
-- venda) checam config.running pra saber se devem parar. Definido antes de
-- qualquer uma delas pra não cair no mesmo bug de escopo de antes.
local config = {
    running = false,
    loopDelay = 0.3,
    checkpointYOffset = 10,
    intermediateWait = 0.15,
    openBoxClicks = 10,
    openBoxClickDelay = 0.03,
    carSpawnWait = 0.6,
}

-- ========================================
-- EventConfig (pra achar o evento mais caro dinamicamente)
-- ========================================

local function findEventConfig()
    local eventSystem = ReplicatedStorage:FindFirstChild("EventSystem")
    if not eventSystem then
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj.Name == "EventSystem" then
                eventSystem = obj
                break
            end
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
    print("[-] EventConfig NÃO encontrado (ReplicatedStorage.EventSystem.EventConfig)")
end

-- Pega o evento mais caro (último da lista ordenada por custo). Dinâmico:
-- se o catálogo mudar, continua pegando o mais caro certo sem editar nada aqui.
local function findMostExpensiveEvent()
    if not EventConfig then return nil end
    local ok, allEvents = pcall(EventConfig.GetAllEvents)
    if not ok or type(allEvents) ~= "table" or #allEvents == 0 then return nil end
    return allEvents[#allEvents]
end

-- Pré-declarado aqui pois só é definido mais abaixo no arquivo
local equipBestSlimes

-- ========================================
-- ALERTA SONORO: toca um som 3x quando revelar glitterRainbow/limited,
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

local alertKeywords = { "limitedrainbow" }

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
        if obj:IsA("ProximityPrompt") and obj.Name == "SellSlimePrompt" then
            return obj
        end
    end
    return nil
end

local function findSellSlimeFrame()
    return playerGui:FindFirstChild("SellSlimeFrame", true)
end

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

-- Confirmado via log de crash real do Roblox (crashes/attachments + .dmp):
-- no PC, o fireproximityprompt trava/crasha ~0.5s depois de disparado
-- (crash nativo de GPU, driver NVIDIA nvldumdx.dll -- não é erro de Lua).
-- No celular esse pipeline D3D nem existe, por isso lá funciona liso. Por
-- isso: no PC (tem teclado) simula o aperto de tecla de verdade via
-- VirtualInputManager em vez do fireproximityprompt nativo; no celular
-- (sem teclado) mantém o fireproximityprompt, que já é confirmado estável lá.
local isPcPlatform = UserInputService.KeyboardEnabled

local function triggerSellPromptOnPc(prompt)
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

local function triggerSellPrompt(prompt)
    if isPcPlatform then
        return triggerSellPromptOnPc(prompt)
    end

    if typeof(fireproximityprompt) == "function" then
        return pcall(fireproximityprompt, prompt)
    end

    return false
end

local sellingAll = false

-- Bloqueante: vende tudo, fecha o painel e só então devolve o controle.
-- Sem task.spawn interno aqui de propósito -- o ciclo master precisa saber
-- com certeza que a janela de venda já fechou antes de ir pro próximo evento.
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
            if not ok then
                sellFrame.Visible = false
            end
        else
            sellFrame.Visible = false
        end
    end

    -- Confirma de verdade que o painel fechou (até 3s) antes de seguir,
    -- em vez de só assumir que o clique/Visible=false funcionou na hora
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

-- Teleporta até a área de venda, dispara o prompt, espera a lista, vende
-- tudo (bloqueante) e só DEPOIS volta pra posição original. Também
-- bloqueante -- quem chamar só recebe o controle de volta quando a venda +
-- fechamento do painel + volta já terminaram tudo de verdade.
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
        -- Folga maior que o Event Shop de propósito: aqui a gente PRECISA
        -- disparar o ProximityPrompt de verdade, não tem remote direto
        -- equivalente ao "RequestState" do Event Shop pra abrir a lista de
        -- venda. Dar mais tempo pra física/replicação assentar após o
        -- teleporte antes de tocar o prompt.
        task.wait(0.5)
    end

    latestSellList = nil

    local fired = triggerSellPrompt(prompt)

    if not fired then
        addLog("[!] Não consegui disparar o prompt de venda, use o E/toque manualmente perto da área")
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

-- Wrapper não-bloqueante pro botão manual (não trava a thread do clique)
local function autoSellAllSlimes()
    task.spawn(autoSellAllSlimesBlocking)
end

-- ========================================
-- EQUIP BEST
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
-- EVENT SHOP: ativa o evento MAIS CARO da lista (último de
-- EventConfig.GetAllEvents()), sem precisar abrir tabela nenhuma.
-- Duração de todos os eventos é 600s (10min) por padrão do EventConfig.
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
        if obj:IsA("ProximityPrompt") and obj.Name == "EventShopPrompt" then
            return obj
        end
    end
    return nil
end

-- Ativa o evento mais caro. Teleporta até a área do Event Shop antes (por
-- segurança, caso o servidor ainda exija proximidade) e confirma a
-- ativação de verdade olhando o ActiveEventId que volta no EventShopUpdate.
local function activateMostExpensiveEvent()
    if not eventShopActionRemote then
        addLog("[!] EventShopAction não encontrado")
        return false
    end

    local event = findMostExpensiveEvent()
    if not event then
        addLog("[!] Não consegui achar o evento mais caro (EventConfig indisponível?)")
        return false
    end

    addLog("[*] Ativando evento mais caro: " .. tostring(event.Id) .. " (custo " .. tostring(event.Cost) .. " EventCoins)")

    pcall(function() Players.LocalPlayer:SetAttribute("EventShopMenuOpen", true) end)
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
    else
        addLog("[!] EventShopPrompt não encontrado, ativando de onde estiver mesmo")
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

    addLog(confirmed and ("[✓] Evento confirmado ativo: " .. event.Id)
        or "[!] Não confirmei a ativação pelo EventShopUpdate (seguindo mesmo assim)")

    teleportPlayerBack(originalCFrame)
    return confirmed
end

local checkpointSlots = {
    { x = 41.4, y = 11.0, z = 3267.2, enabled = true }
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

local function findPlayerCarModel()
    local character = Players.LocalPlayer.Character
    local userName = Players.LocalPlayer.Name

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("auto") then
            if obj.Name:lower():find(userName:lower()) then
                return obj
            end
        end
    end

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
screenGui.Name = "MegaRampEventLoop"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 430)
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
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.Text = "MEGA RAMP - CICLO EVENTO MAIS CARO"
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
equipBestBtn.Text = "⭐ EQUIP BEST (manual)"
equipBestBtn.Parent = frame

local sellAllBtn = Instance.new("TextButton")
sellAllBtn.Size = UDim2.new(1, -20, 0, 35)
sellAllBtn.Position = UDim2.new(0, 10, 0, 125)
sellAllBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
sellAllBtn.TextColor3 = Color3.new(1, 1, 1)
sellAllBtn.TextSize = 12
sellAllBtn.Font = Enum.Font.GothamBold
sellAllBtn.Text = "💰 VENDER TODOS OS SLIMES (manual)"
sellAllBtn.Parent = frame

-- CAMPOS DE POSIÇÃO DOS CHECKPOINTS
local posContainer = Instance.new("Frame")
posContainer.Size = UDim2.new(1, -20, 0, 60)
posContainer.Position = UDim2.new(0, 10, 0, 165)
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
posLabel.Text = "Checkpoint (X, Y, Z):"
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

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 235)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = "Status: PARADO"
statusLabel.Parent = frame

local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, -20, 0, 25)
countLabel.Position = UDim2.new(0, 10, 0, 270)
countLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
countLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
countLabel.TextSize = 11
countLabel.Font = Enum.Font.GothamBold
countLabel.Text = "Teleportes forçados: 0"
countLabel.Parent = frame

local cycleLabel = Instance.new("TextLabel")
cycleLabel.Size = UDim2.new(1, -20, 0, 25)
cycleLabel.Position = UDim2.new(0, 10, 0, 300)
cycleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
cycleLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
cycleLabel.TextSize = 11
cycleLabel.Font = Enum.Font.GothamBold
cycleLabel.Text = "Ciclos completos: 0"
cycleLabel.Parent = frame

-- ========================================
-- LOOP DE TELEPORTE
-- ========================================

local teleportCount = 0
local cycleCount = 0

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

    local highPosition = Vector3.new(slot.x, slot.y + config.checkpointYOffset, slot.z)
    local ok1 = moveCarTo(car, carPart, highPosition)
    if not ok1 then
        addLog("[!] Erro no teleporte intermediário")
        return false
    end

    task.wait(config.intermediateWait)
    if not config.running then return false end

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

-- Roda o loop de teleporte no JumpCar até acabar o tempo (em segundos) ou
-- até config.running virar false
local function runTeleportLoopForDuration(durationSeconds)
    local deadline = tick() + durationSeconds
    addLog("[*] Rodando teleportes por " .. durationSeconds .. "s...")

    while config.running and tick() < deadline do
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

        if not config.running or tick() >= deadline then break end
        task.wait(config.loopDelay)
    end

    addLog("[*] Janela de teleportes encerrada")
end

-- ========================================
-- CICLO AUTOMÁTICO MASTER
-- ========================================

local function startMasterCycle()
    if config.running then return end
    config.running = true
    statusLabel.Text = "Status: ATIVANDO EVENTO..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    addLog("=== CICLO AUTOMÁTICO INICIADO ===")

    task.spawn(function()
        while config.running do
            statusLabel.Text = "Status: ATIVANDO EVENTO..."
            activateMostExpensiveEvent()
            if not config.running then break end

            statusLabel.Text = "Status: TELEPORTANDO (evento ativo)"
            runTeleportLoopForDuration(EVENT_DURATION_SECONDS + EVENT_DURATION_BUFFER_SECONDS)
            if not config.running then break end

            statusLabel.Text = "Status: VENDENDO SLIMES..."
            addLog("[*] Tempo do evento acabou, vendendo todos os slimes...")
            autoSellAllSlimesBlocking()
            addLog("[✓] Venda do ciclo concluída (painel fechado), reiniciando...")

            cycleCount = cycleCount + 1
            cycleLabel.Text = "Ciclos completos: " .. cycleCount

            if not config.running then break end
            task.wait(1)
        end

        statusLabel.Text = "Status: PARADO"
        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
        addLog("=== CICLO AUTOMÁTICO FINALIZADO ===")
    end)
end

local function stopMasterCycle()
    config.running = false
    addLog("[!] Parando ciclo automático...")
end

startBtn.MouseButton1Click:Connect(startMasterCycle)
stopBtn.MouseButton1Click:Connect(stopMasterCycle)
equipBestBtn.MouseButton1Click:Connect(function()
    equipBestSlimes()
end)
sellAllBtn.MouseButton1Click:Connect(function()
    autoSellAllSlimes()
end)

addLog("Menu carregado. Clique em INICIAR pra rodar o ciclo automático.")
print("[+] MEGA RAMP EVENT LOOP carregado!")
