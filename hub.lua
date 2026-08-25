local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

print("=== MEGA RAMP HUB ===")

local function addLog(msg)
    print("[HUB] " .. msg)
end

local Language = { current = "pt" }

local T = {
    tab_ramp = { pt = "Rampa", en = "Ramp", es = "Rampa" },
    tab_games = { pt = "Jogos", en = "Games", es = "Juegos" },
    tab_cam = { pt = "Camera", en = "Camera", es = "Camara" },
    tab_car = { pt = "Carro", en = "Car", es = "Auto" },
    tab_props = { pt = "Objetos", en = "Props", es = "Objetos" },
    tab_esp = { pt = "Jogadores", en = "Players", es = "Jugadores" },
    tab_anim = { pt = "Animacao", en = "Animation", es = "Animacion" },
    tab_webhook = { pt = "Webhook", en = "Webhook", es = "Webhook" },
    tab_players = { pt = "Espectar", en = "Spectate", es = "Espectar" },
    tab_slimes = { pt = "Inventario", en = "Inventory", es = "Inventario" },
    tab_settings = { pt = "Configuracoes", en = "Settings", es = "Ajustes" },
    tab_spy = { pt = "Remote Spy", en = "Remote Spy", es = "Remote Spy" },

    start = { pt = "Iniciar", en = "Start", es = "Iniciar" },
    stop = { pt = "Parar", en = "Stop", es = "Detener" },
    enable = { pt = "Ativar", en = "Enable", es = "Activar" },
    disable = { pt = "Desativar", en = "Disable", es = "Desactivar" },
    play = { pt = "Jogar", en = "Play", es = "Jugar" },
    settings_title = { pt = "IDIOMA", en = "LANGUAGE", es = "IDIOMA" },
    settings_info = {
        pt = "Muda o idioma das abas, botões e status. Textos longos de explicação continuam em português. Feche e abra o hub de novo (rode o script) pra aplicar direito em tudo.",
        en = "Changes the language of tabs, buttons and status. Long explanation texts stay in Portuguese. Close and reopen the hub (run the script again) to apply it everywhere.",
        es = "Cambia el idioma de las pestañas, botones y estado. Los textos largos de explicación siguen en portugués. Cierra y abre el hub de nuevo (ejecuta el script otra vez) para aplicarlo en todo.",
    },

    -- Status dinâmicos (usados tanto no CORE quanto no menu)
    status_stopped = { pt = "Status: PARADO", en = "Status: STOPPED", es = "Estado: DETENIDO" },
    status_running = { pt = "Status: RODANDO", en = "Status: RUNNING", es = "Estado: CORRIENDO" },
    status_activating_event = { pt = "Status: ATIVANDO EVENTO...", en = "Status: ACTIVATING EVENT...", es = "Estado: ACTIVANDO EVENTO..." },
    status_teleporting = { pt = "Status: TELEPORTANDO (evento ativo)", en = "Status: TELEPORTING (event active)", es = "Estado: TELETRANSPORTANDO (evento activo)" },
    status_selling = { pt = "Status: VENDENDO SLIMES...", en = "Status: SELLING SLIMES...", es = "Estado: VENDIENDO SLIMES..." },
    status_paused_other = { pt = "Status: PAUSADO (outro jogador)", en = "Status: PAUSED (other player)", es = "Estado: PAUSADO (otro jugador)" },
    status_active = { pt = "Status: ATIVO", en = "Status: ACTIVE", es = "Estado: ACTIVO" },
    status_inactive = { pt = "Status: DESATIVADO", en = "Status: DISABLED", es = "Estado: DESACTIVADO" },
    status_off = { pt = "Status: DESLIGADO", en = "Status: OFF", es = "Estado: APAGADO" },
    status_on_hold_shift = { pt = "Status: LIGADO (segure SHIFT)", en = "Status: ON (hold SHIFT)", es = "Estado: ACTIVADO (mantén SHIFT)" },
    status_on_no_car = { pt = "Status: LIGADO (carro não encontrado)", en = "Status: ON (car not found)", es = "Estado: ACTIVADO (auto no encontrado)" },
    status_boosting = { pt = "Status: IMPULSIONANDO", en = "Status: BOOSTING", es = "Estado: IMPULSANDO" },
    status_freecam_active = { pt = "Status: ATIVO (F5 pra sair)", en = "Status: ACTIVE (F5 to exit)", es = "Estado: ACTIVO (F5 para salir)" },
    status_none_normal_cam = { pt = "Status: NENHUM (câmera normal)", en = "Status: NONE (normal camera)", es = "Estado: NINGUNO (camara normal)" },
    status_watching = { pt = "Status: ASSISTINDO ", en = "Status: WATCHING ", es = "Estado: VIENDO " },
    label_teleports_forced = { pt = "Teleportes forçados: ", en = "Forced teleports: ", es = "Teletransportes forzados: " },
    label_cycles_complete = { pt = "Ciclos completos: ", en = "Cycles complete: ", es = "Ciclos completos: " },
    label_rounds = { pt = "Rodadas: ", en = "Rounds: ", es = "Rondas: " },
    label_selected = { pt = "Selecionado: ", en = "Selected: ", es = "Seleccionado: " },
    label_none_selected = { pt = "Nenhum objeto selecionado", en = "No object selected", es = "Ningun objeto seleccionado" },

    -- Seções e botões
    sec_ramp_cycle = { pt = "CICLO EVENTO MAIS CARO", en = "MOST EXPENSIVE EVENT CYCLE", es = "CICLO DEL EVENTO MAS CARO" },
    btn_alert_rainbow = { pt = "Alerta: Limited Rainbow", en = "Alert: Limited Rainbow", es = "Alerta: Limited Rainbow" },
    btn_alert_all_limited = { pt = "Alerta: Todos os Limited", en = "Alert: All Limiteds", es = "Alerta: Todos los Limited" },
    btn_sell_all = { pt = "Vender Todos os Slimes (manual)", en = "Sell All Slimes (manual)", es = "Vender Todos los Slimes (manual)" },
    lbl_checkpoint = { pt = "Checkpoint (X, Y, Z):", en = "Checkpoint (X, Y, Z):", es = "Checkpoint (X, Y, Z):" },
    btn_auto_pause = { pt = "Pausar Sozinho se Outro Jogador Entrar", en = "Auto-Pause if Another Player Joins", es = "Pausar Solo si Otro Jugador Entra" },
    sec_memory = { pt = "MEMÓRIA DE SLIME", en = "SLIME MEMORY", es = "MEMORIA DE SLIME" },
    sec_hitslime = { pt = "BATA O SLIME", en = "HIT THE SLIME", es = "GOLPEA AL SLIME" },
    lbl_seconds_per_round = { pt = "Segundos por rodada (nível):", en = "Seconds per round (level):", es = "Segundos por ronda (nivel):" },
    sec_freecam = { pt = "FREE CAM", en = "FREE CAM", es = "CAMARA LIBRE" },
    lbl_freecam_speed = { pt = "Velocidade base (studs/s):", en = "Base speed (studs/s):", es = "Velocidad base (studs/s):" },
    sec_car_boost = { pt = "IMPULSO DA PISTA (BOOST)", en = "TRACK BOOST", es = "IMPULSO DE LA PISTA" },
    lbl_boost_force = { pt = "Força do impulso:", en = "Boost force:", es = "Fuerza del impulso:" },
    btn_enable_boost = { pt = "Ativar Impulso (segure SHIFT pra usar)", en = "Enable Boost (hold SHIFT to use)", es = "Activar Impulso (manten SHIFT para usar)" },
    sec_clone_map = { pt = "CLONAR OBJETO DO MAPA (mira no centro)", en = "CLONE MAP OBJECT (aim in center)", es = "CLONAR OBJETO DEL MAPA (mira al centro)" },
    btn_show_crosshair = { pt = "Mostrar Mira no Centro da Tela", en = "Show Crosshair in Screen Center", es = "Mostrar Mira en el Centro de la Pantalla" },
    btn_clone_looked = { pt = "Clonar o que Estou Olhando (na mira)", en = "Clone What I'm Looking At (aim)", es = "Clonar lo que Estoy Mirando (mira)" },
    lbl_aim_distance = { pt = "Distância máxima da mira (studs):", en = "Max aim distance (studs):", es = "Distancia maxima de la mira (studs):" },
    sec_selected_object = { pt = "OBJETO SELECIONADO", en = "SELECTED OBJECT", es = "OBJETO SELECCIONADO" },
    btn_select_mode = { pt = "Modo Seleção (clique num objeto clonado)", en = "Select Mode (click a cloned object)", es = "Modo Seleccion (clic en un objeto clonado)" },
    btn_carry = { pt = "Segurar na Mão (na frente da câmera)", en = "Carry in Hand (in front of camera)", es = "Sostener en Mano (frente a la camara)" },
    btn_attach = { pt = "Grudar no que Estou Olhando", en = "Attach to What I'm Looking At", es = "Pegar a lo que Estoy Mirando" },
    btn_detach = { pt = "Soltar", en = "Detach", es = "Soltar" },
    btn_toggle_anchor = { pt = "Ancorar/Desancorar", en = "Anchor/Unanchor", es = "Anclar/Desanclar" },
    btn_shrink = { pt = "Diminuir", en = "Shrink", es = "Reducir" },
    btn_grow = { pt = "Aumentar", en = "Grow", es = "Aumentar" },
    btn_delete = { pt = "Deletar", en = "Delete", es = "Eliminar" },
    btn_clear_all = { pt = "Limpar Tudo", en = "Clear All", es = "Limpiar Todo" },
    sec_time_of_day = { pt = "HORÁRIO (DIA/NOITE -- SÓ VOCÊ VÊ)", en = "TIME OF DAY (ONLY YOU SEE)", es = "HORARIO (SOLO TU VES)" },
    btn_keep_fixed = { pt = "Manter Fixo (senão o jogo pode voltar o horário sozinho)", en = "Keep Fixed (game may revert time on its own)", es = "Mantener Fijo (el juego puede revertir la hora solo)" },
    btn_dawn = { pt = "Amanhecer", en = "Dawn", es = "Amanecer" },
    btn_day = { pt = "Dia", en = "Day", es = "Dia" },
    btn_dusk = { pt = "Entardecer", en = "Dusk", es = "Atardecer" },
    btn_night = { pt = "Noite", en = "Night", es = "Noche" },
    lbl_exact_hour = { pt = "Hora exata (0-24):", en = "Exact hour (0-24):", es = "Hora exacta (0-24):" },
    sec_esp = { pt = "ESP (VER JOGADORES)", en = "ESP (SEE PLAYERS)", es = "ESP (VER JUGADORES)" },
    lbl_esp_distance = { pt = "Distância máxima (studs):", en = "Max distance (studs):", es = "Distancia maxima (studs):" },
    sec_anim_idle = { pt = "ANIMAÇÃO CUSTOM (SÓ IDLE)", en = "CUSTOM ANIMATION (IDLE ONLY)", es = "ANIMACION CUSTOM (SOLO IDLE)" },
    lbl_idle_id = { pt = "Animation ID do IDLE (parado):", en = "IDLE Animation ID (standing):", es = "ID de Animacion IDLE (quieto):" },
    btn_capture_anim = { pt = "Capturar Animação Atual para o Idle (toque o emote antes de clicar)", en = "Capture Current Animation for Idle (play the emote before clicking)", es = "Capturar Animacion Actual para el Idle (reproduce el emote antes de hacer clic)" },
    btn_diagnose = { pt = "Diagnosticar (mostra estrutura do Animate no console)", en = "Diagnose (shows Animate structure in console)", es = "Diagnosticar (muestra la estructura del Animate en consola)" },
    btn_apply_idle = { pt = "Aplicar (só idle -- o resto continua normal)", en = "Apply (idle only -- the rest stays normal)", es = "Aplicar (solo idle -- el resto sigue normal)" },
    btn_reapply = { pt = "Reaplicar (depois de mudar o ID)", en = "Reapply (after changing the ID)", es = "Reaplicar (despues de cambiar el ID)" },
    sec_discord_webhook = { pt = "DISCORD WEBHOOK", en = "DISCORD WEBHOOK", es = "DISCORD WEBHOOK" },
    lbl_webhook_url = { pt = "URL do Webhook:", en = "Webhook URL:", es = "URL del Webhook:" },
    btn_test = { pt = "Testar", en = "Test", es = "Probar" },
    sec_notify_when = { pt = "NOTIFICAR QUANDO:", en = "NOTIFY WHEN:", es = "NOTIFICAR CUANDO:" },
    toggle_find_limited = { pt = "Achar Limited/Rainbow", en = "Find Limited/Rainbow", es = "Encontrar Limited/Rainbow" },
    toggle_win_memory = { pt = "Ganhar na Memória", en = "Win at Memory", es = "Ganar en Memoria" },
    toggle_win_hitslime = { pt = "Ganhar no Bata o Slime", en = "Win at Hit the Slime", es = "Ganar en Golpea al Slime" },
    toggle_activate_event = { pt = "Ativar evento (Ramp)", en = "Activate event (Ramp)", es = "Activar evento (Ramp)" },
    sec_players_in_match = { pt = "JOGADORES NA PARTIDA", en = "PLAYERS IN MATCH", es = "JUGADORES EN LA PARTIDA" },
    btn_stop_spectate = { pt = "Parar Spectate", en = "Stop Spectate", es = "Detener Espectar" },
    btn_spectate = { pt = "Spectate", en = "Spectate", es = "Espectar" },
    lbl_no_other_players = { pt = "Nenhum outro jogador na partida.", en = "No other players in the match.", es = "Ningun otro jugador en la partida." },
    sec_top5 = { pt = "TOP 5 (CASH) - AO VIVO", en = "TOP 5 (CASH) - LIVE", es = "TOP 5 (CASH) - EN VIVO" },
    lbl_waiting_server = { pt = "Aguardando dados do servidor...", en = "Waiting for server data...", es = "Esperando datos del servidor..." },
    sec_equip_by_index = { pt = "EQUIPAR SLIME (POR ÍNDICE)", en = "EQUIP SLIME (BY INDEX)", es = "EQUIPAR SLIME (POR INDICE)" },
    lbl_waiting_inventory = { pt = "Aguardando dados do inventário... (abra o inventário no jogo 1x se não vier nada)", en = "Waiting for inventory data... (open the inventory in-game once if nothing shows)", es = "Esperando datos del inventario... (abre el inventario en el juego una vez si no aparece nada)" },
    sec_manual_equip = { pt = "EQUIPAR POR ÍNDICE MANUAL", en = "MANUAL EQUIP BY INDEX", es = "EQUIPAR POR INDICE MANUAL" },
    lbl_index_manual = { pt = "Índice (0 = tirar da mão):", en = "Index (0 = unequip):", es = "Indice (0 = quitar de la mano):" },
    btn_equip_index = { pt = "Equipar Esse Índice", en = "Equip This Index", es = "Equipar Este Indice" },
    sec_send_gift = { pt = "ENVIAR GIFT", en = "SEND GIFT", es = "ENVIAR REGALO" },
    lbl_gift_target = { pt = "Nome (ou parte) do jogador de destino:", en = "Target player's name (or part of it):", es = "Nombre (o parte) del jugador destino:" },
    lbl_gift_index = { pt = "Índice do slime a doar:", en = "Index of the slime to gift:", es = "Indice del slime a regalar:" },
    btn_send_gift = { pt = "Enviar Gift", en = "Send Gift", es = "Enviar Regalo" },
    lbl_equipped = { pt = "Equipado", en = "Equipped", es = "Equipado" },
    lbl_equip = { pt = "Equipar", en = "Equip", es = "Equipar" },

    status_flying = { pt = "Status: VOANDO", en = "Status: FLYING", es = "Estado: VOLANDO" },
    sec_fly = { pt = "FLY / NO-CLIP COM O CARRO", en = "FLY / NO-CLIP WITH CAR", es = "VOLAR / NO-CLIP CON EL AUTO" },
    btn_fly_toggle = { pt = "Ativar Fly (No-Clip)", en = "Enable Fly (No-Clip)", es = "Activar Volar (No-Clip)" },
    sec_checkpoint_dup = { pt = "DUPLICAR CHECKPOINTS", en = "DUPLICATE CHECKPOINTS", es = "DUPLICAR CHECKPOINTS" },
    lbl_offset_z = { pt = "Offset Z entre original e cópia (studs):", en = "Z offset between original and copy (studs):", es = "Offset Z entre original y copia (studs):" },
    btn_dup_checkpoints = { pt = "Duplicar Todos os Checkpoints", en = "Duplicate All Checkpoints", es = "Duplicar Todos los Checkpoints" },
    btn_clear_dup_checkpoints = { pt = "Remover Duplicados", en = "Remove Duplicates", es = "Eliminar Duplicados" },
    sec_checkpoint_extra = { pt = "CRIAR CHECKPOINTS ALÉM DO MÁXIMO", en = "CREATE CHECKPOINTS BEYOND MAX", es = "CREAR CHECKPOINTS MÁS ALLÁ DEL MÁXIMO" },
    lbl_extra_count = { pt = "Quantidade de novos checkpoints:", en = "Number of new checkpoints:", es = "Cantidad de nuevos checkpoints:" },
    lbl_extra_spacing = { pt = "Espaçamento entre eles (studs):", en = "Spacing between them (studs):", es = "Espaciado entre ellos (studs):" },
    btn_create_extra = { pt = "Criar Checkpoints Extras", en = "Create Extra Checkpoints", es = "Crear Checkpoints Extra" },
    btn_auto_trigger_extra = { pt = "Disparar Todos Automaticamente", en = "Auto-Trigger All", es = "Disparar Todos Automáticamente" },

    sec_remote_spy = { pt = "REMOTE SPY (AO VIVO)", en = "REMOTE SPY (LIVE)", es = "REMOTE SPY (EN VIVO)" },
    btn_spy_enable = { pt = "Ativar Spy", en = "Enable Spy", es = "Activar Spy" },
    btn_spy_disable = { pt = "Desativar Spy", en = "Disable Spy", es = "Desactivar Spy" },
    btn_spy_copy = { pt = "Copiar Log", en = "Copy Log", es = "Copiar Log" },
    btn_spy_clear = { pt = "Limpar Log", en = "Clear Log", es = "Limpiar Log" },
    lbl_spy_unsupported = { pt = "Status: EXECUTOR NÃO SUPORTA (falta hookmetamethod)", en = "Status: EXECUTOR NOT SUPPORTED (missing hookmetamethod)", es = "Estado: EXECUTOR NO SOPORTADO (falta hookmetamethod)" },

    sec_function_spy = { pt = "FUNCTION SPY (FUNÇÃO REAL DO CHECKPOINT)", en = "FUNCTION SPY (REAL CHECKPOINT FUNCTION)", es = "FUNCTION SPY (FUNCIÓN REAL DEL CHECKPOINT)" },
    btn_capture_fn = { pt = "Capturar Função Real do Checkpoint", en = "Capture Real Checkpoint Function", es = "Capturar Función Real del Checkpoint" },
    btn_call_fn = { pt = "Chamar Função Real (com o carro)", en = "Call Real Function (with car)", es = "Llamar Función Real (con el auto)" },

    sec_weather = { pt = "CLIMA (SÓ VOCÊ VÊ)", en = "WEATHER (ONLY YOU SEE)", es = "CLIMA (SOLO TU VES)" },
    btn_weather_clear = { pt = "Limpo", en = "Clear", es = "Despejado" },
    btn_weather_rain = { pt = "Chuva", en = "Rain", es = "Lluvia" },
    btn_weather_storm = { pt = "Tempestade", en = "Storm", es = "Tormenta" },
    btn_weather_fog = { pt = "Neblina", en = "Fog", es = "Niebla" },
    btn_weather_snow = { pt = "Neve", en = "Snow", es = "Nieve" },
    btn_weather_sandstorm = { pt = "Tempestade de Areia", en = "Sandstorm", es = "Tormenta de Arena" },
}

local function t(key)
    local entry = T[key]
    if not entry then return key end
    return entry[Language.current] or entry.pt
end

-- Guarda a última aba aberta pra reabrir nela quando o menu inteiro é
-- reconstruído (troca de idioma, por exemplo), em vez de sempre voltar
-- pra Ramp.
local lastSelectedTabKey = "ramp"
local lastFramePosition = UDim2.new(0, 16, 0, 16)

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
local inventoryUpdateRemote = findRemote("InventoryUpdate")
local giftActionRemote = findRemote("GiftAction")
local miniGameMemoryEvent = findRemote("MiniGame1MemoryEvent")
local miniGameButton = Workspace:WaitForChild("MiniGame1Button")
local leaderboardUpdateRemote = findRemote("LeaderboardUpdate")
local miniParkourEventRemote = findRemote("MiniParkourEvent")

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
-- INVENTÁRIO: o próprio jogo já manda a lista completa de slimes (com
-- índice = posição no InventoryUpdate) e o índice do que está "na mão"
-- (equipado) toda vez que muda -- SelectInventoryItem:FireServer(index) é
-- exatamente o que o botão de cada card do inventário do jogo dispara
-- quando você clica nele, então dá pra equipar QUALQUER slime da lista
-- direto por esse remote, sem precisar abrir o inventário e clicar.
-- ========================================

local latestInventoryList = nil
local latestEquippedIndex = nil
local refreshInventoryUI -- atribuída lá na aba SLIMES, mais abaixo

if inventoryUpdateRemote then
    inventoryUpdateRemote.OnClientEvent:Connect(function(list, equippedIndex)
        latestInventoryList = list
        latestEquippedIndex = equippedIndex
        if refreshInventoryUI then refreshInventoryUI() end
    end)
end

local function equipSlimeByIndex(index)
    if not selectInventoryItemRemote then
        addLog("[SLIMES] [!] SelectInventoryItem não encontrado")
        return
    end
    pcall(function() selectInventoryItemRemote:FireServer(index) end)
    addLog("[SLIMES] Pedido pra equipar índice " .. tostring(index))
end

local function findPlayerByNameFragment(text)
    if not text or text == "" then return nil end
    local lower = text:lower()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower() == lower then return plr end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower():find(lower, 1, true) then return plr end
    end
    return nil
end

local function sendGiftByIndex(targetPlayer, index)
    if not giftActionRemote then
        addLog("[GIFT] [!] GiftAction não encontrado")
        return
    end
    if not targetPlayer then
        addLog("[GIFT] [!] Escolha um jogador de destino")
        return
    end
    pcall(function() giftActionRemote:FireServer("RequestGift", targetPlayer, index) end)
    addLog("[GIFT] Pedido de gift enviado: índice " .. tostring(index) .. " -> " .. targetPlayer.Name)
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

-- Move o painel FÍSICO do MiniGame1Button (o mesmo trigger usado tanto
-- pela Memória quanto pelo Bata o Slime) pra cima do EventShopPrompt --
-- isso é 100% client-side (só a SUA tela vê ele nessa posição nova), mas
-- como o Roblox checa a distância do ProximityPrompt usando a posição
-- RENDERIZADA no seu client (é por isso que o prompt "E" aparece/some
-- sozinho conforme você anda), mover a Part localmente é o suficiente
-- pra conseguir disparar o prompt sem precisar sair do lugar. Só roda
-- 1x no carregamento do hub (o painel não se move sozinho no jogo).
local function moveMiniGameButtonToEventShop()
    local prompt = findEventShopPrompt()
    if not prompt then
        addLog("[MINIGAME] [!] EventShopPrompt não encontrado, não deu pra mover o painel de minigames")
        return
    end
    local shopPos = getPromptWorldPosition(prompt)
    if not shopPos then
        addLog("[MINIGAME] [!] Não consegui ler a posição do EventShopPrompt")
        return
    end

    local part = miniGameButton:IsA("BasePart") and miniGameButton or miniGameButton:FindFirstChildWhichIsA("BasePart", true)
    if not part then
        addLog("[MINIGAME] [!] MiniGame1Button não tem nenhuma BasePart pra mover")
        return
    end

    local currentRotation = part.CFrame - part.CFrame.Position
    part.CFrame = CFrame.new(shopPos) * currentRotation
    addLog("[MINIGAME] [✓] Painel de minigames movido pra cima do shop de eventos (só na sua tela)")
end

task.defer(moveMiniGameButtonToEventShop)

local function activateMostExpensiveEvent(stayAtShop, noTeleport)
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

    local originalCFrame = nil
    if not noTeleport then
        local prompt = findEventShopPrompt()
        if prompt then
            local promptPos = getPromptWorldPosition(prompt)
            if promptPos then
                originalCFrame = teleportPlayerTo(promptPos)
                task.wait(0.2)
            end
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

    if not stayAtShop then
        teleportPlayerBack(originalCFrame)
    end
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

-- Toggle geral: liga/desliga a pausa automática quando outro jogador entra
-- na sala. Desativado, os loops ignoram totalmente outros jogadores.
local autoPauseConfig = { enabled = true }

local function makeAutoPauseGuards(cfg, getStatusLabel, startFn, stopFn, label)
    local autoResumeWhenAlone = false

    local function pauseIfRunning()
        if not autoPauseConfig.enabled then return end
        if cfg.running then
            addLog("[" .. label .. "] [!] Outro jogador entrou, pausando...")
            autoResumeWhenAlone = true
            stopFn()
            local statusLabel = getStatusLabel()
            if statusLabel then
                statusLabel.Text = t("status_paused_other")
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
        if autoPauseConfig.enabled and otherPlayersCount() > 0 then
            addLog("[" .. label .. "] [!] Tem outro jogador, vai iniciar quando ficar só.")
            autoResumeWhenAlone = true
            local statusLabel = getStatusLabel()
            if statusLabel then
                statusLabel.Text = t("status_paused_other")
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
-- Forward-declarado aqui (definido de verdade lá embaixo, perto do
-- CheckpointDup) porque startMasterCycle/stopMasterCycle -- definidos
-- logo abaixo, nesta mesma aba -- precisam chamar MegaJumpInsta.enable/
-- disable, e uma função só enxerga uma local como upvalue se ela já
-- tiver sido declarada (com `local`) ANTES do texto da função -- mesmo
-- que a atribuição de valor só aconteça depois.
local MegaJumpInsta

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

-- Auto-clicker independente do ciclo automático: sempre que a caixa abrir
-- (StartBoxReveal), dispara os cliques rápidos na hora, mesmo com o Mega
-- Rampa Loop (aba de automação) desligado.
local autoBoxClickRunning = false
local function autoClickOpenBoxNow()
    if not openBoxClickRemote then return end
    if autoBoxClickRunning then return end
    autoBoxClickRunning = true

    for i = 1, rampConfig.openBoxClicks do
        pcall(function() openBoxClickRemote:FireServer() end)
        task.wait(rampConfig.openBoxClickDelay)
    end

    autoBoxClickRunning = false
end

if startBoxRevealRemote then
    startBoxRevealRemote.OnClientEvent:Connect(function()
        task.spawn(autoClickOpenBoxNow)
    end)
    addLog("[RAMP] [*] Auto-click da caixa ativo (independente do loop)")
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
        if rampCountLabel then rampCountLabel.Text = t("label_teleports_forced") .. teleportCount end
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
                waitForEvent(startBoxRevealRemote, 8)
                -- Os cliques em si são disparados pelo listener global
                -- autoClickOpenBoxNow (StartBoxReveal.OnClientEvent), que
                -- roda sempre, com ou sem o loop ativo.
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
        rampStatusLabel.Text = t("status_activating_event")
        rampStatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    end
    addLog("[RAMP] === CICLO AUTOMÁTICO INICIADO ===")

    -- Mega Jump Insta liga junto com o ciclo (CarSpawn/JumpCar/Checkpoint
    -- 92 colapsados na posição do CarSpawn) e desliga sozinho quando o
    -- ciclo para -- inclusive na pausa automática por outro jogador, já
    -- que ela chama esse mesmo startMasterCycle/stopMasterCycle.
    if MegaJumpInsta and not MegaJumpInsta.isEnabled() then
        local pos = MegaJumpInsta.getDefaultPosition()
        MegaJumpInsta.enable(pos.X, pos.Y, pos.Z)
    end

    task.spawn(function()
        while rampConfig.running do
            local remaining, activeEventId = getActiveEventRemainingSeconds()

            if remaining then
                addLog("[RAMP] [*] Evento já ativo, restam ~" .. remaining .. "s. Retomando sem reativar.")
                if rampStatusLabel then rampStatusLabel.Text = t("status_teleporting") end
                runTeleportLoopForDuration(remaining + EVENT_DURATION_BUFFER_SECONDS)
            else
                if rampStatusLabel then rampStatusLabel.Text = t("status_activating_event") end
                activateMostExpensiveEvent()
                if not rampConfig.running then break end

                if rampStatusLabel then rampStatusLabel.Text = t("status_teleporting") end
                runTeleportLoopForDuration(EVENT_DURATION_SECONDS + EVENT_DURATION_BUFFER_SECONDS)
            end
            if not rampConfig.running then break end

            if rampStatusLabel then rampStatusLabel.Text = t("status_selling") end
            addLog("[RAMP] [*] Tempo do evento acabou, vendendo todos os slimes...")
            autoSellAllSlimesBlocking()

            cycleCount = cycleCount + 1
            if rampCycleLabel then rampCycleLabel.Text = t("label_cycles_complete") .. cycleCount end

            if not rampConfig.running then break end
            task.wait(1)
        end

        if rampStatusLabel then
            rampStatusLabel.Text = t("status_stopped")
            rampStatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
        end
        addLog("[RAMP] === CICLO AUTOMÁTICO FINALIZADO ===")
    end)
end

local function stopMasterCycle()
    rampConfig.running = false
    addLog("[RAMP] [!] Parando ciclo automático...")
    if MegaJumpInsta and MegaJumpInsta.isEnabled() then
        MegaJumpInsta.disable()
    end
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
    if memoryCountLabel then memoryCountLabel.Text = t("label_rounds") .. memoryRoundCount end
end

local function startMemoryLoop()
    if memoryConfig.running then return end
    memoryConfig.running = true
    if memoryStatusLabel then
        memoryStatusLabel.Text = t("status_running")
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
            memoryStatusLabel.Text = t("status_stopped")
            memoryStatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
        end
        addLog("[MEMORIA] === FINALIZADO ===")
    end)
end

local function stopMemoryLoop()
    memoryConfig.running = false
    if memoryStatusLabel then
        memoryStatusLabel.Text = t("status_stopped")
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
    if hitSlimeCountLabel then hitSlimeCountLabel.Text = t("label_rounds") .. hitSlimeRoundCount end
end

local function startHitSlimeLoop()
    if hitSlimeConfig.running then return end
    hitSlimeConfig.running = true
    if hitSlimeStatusLabel then
        hitSlimeStatusLabel.Text = t("status_running")
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
            hitSlimeStatusLabel.Text = t("status_stopped")
            hitSlimeStatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
        end
        addLog("[HITSLIME] === FINALIZADO ===")
    end)

    task.spawn(function()
        while hitSlimeConfig.running do
            -- noTeleport=true: nem teleporta pro shop de eventos -- o
            -- Bata o Slime roda 100% por remote (não precisa estar perto
            -- de nada), e o usuário já fica parado no local de abrir o
            -- evento antes de clicar Jogar, então mover o personagem só
            -- atrapalharia.
            activateMostExpensiveEvent(true, true)
            if not hitSlimeConfig.running then break end
            waitWhileRunning(EVENT_DURATION_SECONDS + EVENT_DURATION_BUFFER_SECONDS, hitSlimeConfig)
        end
    end)
end

local function stopHitSlimeLoop()
    hitSlimeConfig.running = false
    if hitSlimeStatusLabel then
        hitSlimeStatusLabel.Text = t("status_stopped")
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
        freecamStatusLabel.Text = t("status_freecam_active")
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
        freecamStatusLabel.Text = t("status_inactive")
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
        playersStatusLabel.Text = t("status_watching") .. player.Name
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
        playersStatusLabel.Text = t("status_none_normal_cam")
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
        espStatusLabel.Text = t("status_active")
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
        espStatusLabel.Text = t("status_inactive")
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
-- IMPULSO DA PISTA (CARRO): segura SHIFT pra empurrar o carro pra frente
-- com força extra, solta e o impulso para na hora -- reaproveita o mesmo
-- findPlayerCarModel() já usado pelo ciclo do Ramp.
-- ========================================

local carBoostConfig = { enabled = false, force = 120, holding = false }
local carStatusLabel

local function getCarMainPart(car)
    if not car then return nil end
    return car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart", true)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        carBoostConfig.holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        carBoostConfig.holding = false
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if not carBoostConfig.enabled then
        if carStatusLabel then
            carStatusLabel.Text = t("status_off")
            carStatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
        end
        return
    end

    if not carBoostConfig.holding then
        if carStatusLabel then
            carStatusLabel.Text = t("status_on_hold_shift")
            carStatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        end
        return
    end

    local carPart = getCarMainPart(findPlayerCarModel())
    if not carPart then
        if carStatusLabel then
            carStatusLabel.Text = t("status_on_no_car")
            carStatusLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
        end
        return
    end

    local forward = carPart.CFrame.LookVector
    carPart.AssemblyLinearVelocity = carPart.AssemblyLinearVelocity + forward * carBoostConfig.force * dt

    if carStatusLabel then
        carStatusLabel.Text = t("status_boosting")
        carStatusLabel.TextColor3 = Color3.fromRGB(0, 220, 220)
    end
end)

-- ========================================
-- FLY / NO-CLIP COM O CARRO: desliga a colisão do carro inteiro e deixa
-- mover ele livremente (voando) com WASD/Space/Ctrl relativo à câmera,
-- igual o Free Cam -- mas movendo o carro (com você sentado) em vez da
-- câmera. Tudo dentro de uma função própria pra não gastar registro de
-- variável local do chunk principal.
-- ========================================

local function buildCarFlyFeature()
    local flyConfig = { active = false, speed = 90, boostMultiplier = 3 }
    local savedCollide = {}
    local connections = {}
    local statusLabel = nil

    local function disconnectAll()
        for _, conn in ipairs(connections) do conn:Disconnect() end
        connections = {}
    end

    local function setStatus(text, color)
        if statusLabel then
            statusLabel.Text = text
            statusLabel.TextColor3 = color
        end
    end

    local function enable()
        if flyConfig.active then return end
        local car = findPlayerCarModel()
        if not car then
            addLog("[FLY] [!] Model do carro não encontrado")
            return
        end

        savedCollide = {}
        for _, part in ipairs(car:GetDescendants()) do
            if part:IsA("BasePart") then
                savedCollide[part] = part.CanCollide
                part.CanCollide = false
            end
        end

        flyConfig.active = true
        setStatus(t("status_flying"), Color3.fromRGB(0, 220, 220))
        addLog("[FLY] Ativado")

        connections[#connections + 1] = RunService.RenderStepped:Connect(function(dt)
            local currentCar = findPlayerCarModel()
            if not currentCar then return end
            local carPart = currentCar.PrimaryPart or currentCar:FindFirstChildWhichIsA("BasePart", true)
            if not carPart then return end

            local camera = Workspace.CurrentCamera
            local camCFrame = camera.CFrame

            local moveVector = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector += Vector3.new(0, 0, -1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector += Vector3.new(0, 0, 1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector += Vector3.new(-1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector += Vector3.new(1, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.C) then
                moveVector += Vector3.new(0, -1, 0)
            end

            if moveVector.Magnitude == 0 then return end
            moveVector = moveVector.Unit

            local speed = flyConfig.speed
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                speed = speed * flyConfig.boostMultiplier
            end

            local worldMove = camCFrame:VectorToWorldSpace(moveVector) * speed * dt
            local currentRotation = carPart.CFrame - carPart.CFrame.Position
            local newCFrame = CFrame.new(carPart.Position + worldMove) * currentRotation

            local ok = pcall(function()
                if currentCar.PrimaryPart then
                    currentCar:SetPrimaryPartCFrame(newCFrame)
                else
                    carPart.CFrame = newCFrame
                end
            end)
            if ok then
                carPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                carPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end

    local function disable()
        if not flyConfig.active then return end
        flyConfig.active = false
        disconnectAll()

        for part, collide in pairs(savedCollide) do
            if part.Parent then
                part.CanCollide = collide
            end
        end
        savedCollide = {}

        setStatus(t("status_off"), Color3.fromRGB(100, 200, 100))
        addLog("[FLY] Desativado")
    end

    local function toggle()
        if flyConfig.active then disable() else enable() end
    end

    return {
        config = flyConfig,
        toggle = toggle,
        disable = disable,
        setStatusLabel = function(lbl) statusLabel = lbl end,
    }
end

local CarFly = buildCarFlyFeature()

-- ========================================
-- DUPLICAR CHECKPOINTS: a pasta Checkpoints (usada pelo sistema de
-- multiplicador da rampa) tem parts invisíveis que, ao tocar, disparam
-- MiniParkourEvent:FireServer("CheckpointTouched", número) -- o PRÓPRIO
-- CLIENT decide esse número (lido de um Attribute que o script do jogo
-- também seta no client), e o jogo já tem um bloqueio de 1s contra
-- disparar o MESMO número duas vezes rápido demais. Clonando cada
-- checkpoint com um offset em Z, e conectando nosso PRÓPRIO Touched
-- (Clone() não copia conexões de evento), dá pra tocar em duas parts
-- fisicamente diferentes (original + clone) com mais de 1s de intervalo
-- entre elas, cada uma disparando o remote de novo.
-- ========================================

local function buildCheckpointDuplicatorFeature()
    local duplicatedParts = {}

    local function findCheckpointsFolder()
        local direct = Workspace:FindFirstChild("Checkpoints", true)
        if direct and direct:IsA("Folder") then return direct end
        return nil
    end

    local function wireDuplicateTouched(part, checkpointNumber)
        part.CanTouch = true
        part.CanCollide = false
        part.Touched:Connect(function(hit)
            if not hit then return end
            local isMine = false
            local character = LocalPlayer.Character
            if character and hit:IsDescendantOf(character) then
                isMine = true
            else
                local model = hit:FindFirstAncestorOfClass("Model")
                isMine = model ~= nil and model:GetAttribute("OwnerUserId") == LocalPlayer.UserId
            end
            if not isMine then return end
            if not miniParkourEventRemote then return end
            pcall(function() miniParkourEventRemote:FireServer("CheckpointTouched", checkpointNumber) end)
            addLog("[CHECKPOINT-DUP] Disparado checkpoint " .. tostring(checkpointNumber))
        end)
    end

    local function duplicateAll(offsetZ)
        local folder = findCheckpointsFolder()
        if not folder then
            addLog("[CHECKPOINT-DUP] [!] Pasta 'Checkpoints' não encontrada")
            return
        end

        local count = 0
        for _, child in ipairs(folder:GetChildren()) do
            local checkpointNumber = tonumber(child.Name)
            if checkpointNumber then
                local clone = child:Clone()
                clone.Name = child.Name .. "_HubDup"

                if clone:IsA("Model") then
                    clone:PivotTo(child:GetPivot() + Vector3.new(0, 0, offsetZ))
                elseif clone:IsA("BasePart") then
                    clone.CFrame = child.CFrame + Vector3.new(0, 0, offsetZ)
                end

                clone.Parent = folder
                table.insert(duplicatedParts, clone)

                if clone:IsA("BasePart") then
                    wireDuplicateTouched(clone, checkpointNumber)
                else
                    for _, part in ipairs(clone:GetDescendants()) do
                        if part:IsA("BasePart") then
                            wireDuplicateTouched(part, checkpointNumber)
                        end
                    end
                end

                count = count + 1
            end
        end

        addLog("[CHECKPOINT-DUP] " .. count .. " checkpoint(s) duplicado(s) com offset Z=" .. tostring(offsetZ))
    end

    local function clearAll()
        for _, part in ipairs(duplicatedParts) do
            if part.Parent then part:Destroy() end
        end
        duplicatedParts = {}
        addLog("[CHECKPOINT-DUP] Duplicados removidos")
    end

    local function getMaxCheckpoint(folder)
        local maxNumber, maxChild = 0, nil
        for _, child in ipairs(folder:GetChildren()) do
            local n = tonumber(child.Name)
            if n and n >= maxNumber then
                maxNumber, maxChild = n, child
            end
        end
        return maxNumber, maxChild
    end

    local function createBeyondMax(count, spacing)
        local folder = findCheckpointsFolder()
        if not folder then
            addLog("[CHECKPOINT-DUP] [!] Pasta 'Checkpoints' não encontrada")
            return {}
        end

        local maxNumber, template = getMaxCheckpoint(folder)
        if not template then
            addLog("[CHECKPOINT-DUP] [!] Nenhum checkpoint numerado encontrado pra usar de modelo")
            return {}
        end

        local created = {}
        for i = 1, count do
            local newNumber = maxNumber + i
            local clone = template:Clone()
            clone.Name = tostring(newNumber)

            if clone:IsA("Model") then
                clone:PivotTo(template:GetPivot() + Vector3.new(0, 0, spacing * i))
            elseif clone:IsA("BasePart") then
                clone.CFrame = template.CFrame + Vector3.new(0, 0, spacing * i)
            end

            clone.Parent = folder
            table.insert(duplicatedParts, clone)
            table.insert(created, clone)

            if clone:IsA("BasePart") then
                clone:SetAttribute("MiniCheckpointNumber", newNumber)
                wireDuplicateTouched(clone, newNumber)
            else
                for _, part in ipairs(clone:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part:SetAttribute("MiniCheckpointNumber", newNumber)
                        wireDuplicateTouched(part, newNumber)
                    end
                end
            end
        end

        addLog("[CHECKPOINT-DUP] " .. count .. " checkpoint(s) novo(s) criado(s) além do #" .. tostring(maxNumber))
        return created
    end

    local function findTouchablePart(instance)
        if instance:IsA("BasePart") then return instance end
        for _, part in ipairs(instance:GetDescendants()) do
            if part:IsA("BasePart") then return part end
        end
        return nil
    end

    -- O checkpoint precisa ser tocado pelo CARRO (é o carro que tem o
    -- Attribute OwnerUserId que o Touched confere), não pelo seu
    -- personagem andando -- por isso teleportar só o HumanoidRootPart
    -- "bugava" o carro (ele ficava pra trás, ou o jogo tentava corrigir a
    -- posição). Aqui a gente move o MODEL do carro mesmo, igual o ciclo
    -- do Ramp já faz (moveCarTo/teleportToCheckpoint): sobe um pouco
    -- antes de descer pra evitar prender no chão/geometria.
    local function autoTriggerCreated(createdList, delaySeconds)
        task.spawn(function()
            local car = findPlayerCarModel()
            if not car then
                addLog("[CHECKPOINT-DUP] [!] Model do carro não encontrado pra auto-disparo -- entre no carro primeiro")
                return
            end

            local carPart = car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart", true)
            if not carPart then
                addLog("[CHECKPOINT-DUP] [!] Nenhuma BasePart no carro")
                return
            end

            local savedCFrame = carPart.CFrame

            for _, instance in ipairs(createdList) do
                local part = findTouchablePart(instance)
                if part then
                    local currentCar = findPlayerCarModel()
                    local currentCarPart = currentCar and (currentCar.PrimaryPart or currentCar:FindFirstChildWhichIsA("BasePart", true))
                    if not currentCarPart then break end

                    local currentRotation = currentCarPart.CFrame - currentCarPart.CFrame.Position
                    local highCFrame = CFrame.new(part.Position + Vector3.new(0, 10, 0)) * currentRotation
                    pcall(function()
                        if currentCar.PrimaryPart then
                            currentCar:SetPrimaryPartCFrame(highCFrame)
                        else
                            currentCarPart.CFrame = highCFrame
                        end
                    end)

                    task.wait(0.2)

                    local finalCFrame = CFrame.new(part.Position) * currentRotation
                    pcall(function()
                        if currentCar.PrimaryPart then
                            currentCar:SetPrimaryPartCFrame(finalCFrame)
                        else
                            currentCarPart.CFrame = finalCFrame
                        end
                    end)

                    task.wait(delaySeconds)
                end
            end

            local finalCar = findPlayerCarModel()
            local finalCarPart = finalCar and (finalCar.PrimaryPart or finalCar:FindFirstChildWhichIsA("BasePart", true))
            if finalCarPart then
                pcall(function()
                    if finalCar.PrimaryPart then
                        finalCar:SetPrimaryPartCFrame(savedCFrame)
                    else
                        finalCarPart.CFrame = savedCFrame
                    end
                end)
            end
            addLog("[CHECKPOINT-DUP] Auto-disparo concluído")
        end)
    end

    return {
        duplicateAll = duplicateAll,
        clearAll = clearAll,
        createBeyondMax = createBeyondMax,
        autoTriggerCreated = autoTriggerCreated,
    }
end

local CheckpointDup = buildCheckpointDuplicatorFeature()

-- ========================================
-- MEGA JUMP INSTA: colapsa CarSpawn + JumpCar + o checkpoint final (92,
-- o multiplicador x1000000) pro MESMO ponto, e desativa as CarResetZones
-- -- assim o carro nasce, já está "no" JumpCar e "no" checkpoint final,
-- tudo no mesmo lugar, sem percurso nenhum. 100% client-side: as parts
-- reais do jogo continuam nos lugares originais pro servidor e pros
-- outros jogadores, só a SUA cópia renderizada é que muda de posição
-- (mesma técnica do moveMiniGameButtonToEventShop, aplicada em 3 parts).
-- As CarResetZones não são destruídas de verdade -- só desligamos
-- Collide/Touch e escondemos (Transparency=1), assim dá pra desfazer
-- (Restaurar) sem precisar recarregar o script inteiro.
-- ========================================

local function buildMegaJumpInstaFeature()
    local enabled = false
    local saved = { carSpawn = nil, jumpCar = nil, checkpoint92 = nil, checkpoint92Size = nil, checkpoint92SquareDups = {}, landingZone3 = nil, resetZones = {}, jumpCarForceAttrs = {} }

    local function findCarResetZonesFolder()
        local direct = Workspace:FindFirstChild("CarResetZones", true)
        if direct then return direct end
        return nil
    end

    local function findCarSpawnPart()
        local direct = Workspace:FindFirstChild("CarSpawn", true)
        if direct and direct:IsA("BasePart") then return direct end
        return nil
    end

    local function findCheckpoint92()
        local folder = Workspace:FindFirstChild("Checkpoints", true)
        if not folder then return nil end

        -- Busca exata por nome "92" entre os filhos diretos primeiro
        -- (FindFirstChild pode devolver algo inesperado se houver mais de
        -- uma pasta "Checkpoints" no jogo -- por isso comparamos o nome
        -- manualmente em vez de confiar cegamente no primeiro achado).
        local child = nil
        for _, c in ipairs(folder:GetChildren()) do
            if c.Name == "92" then
                child = c
                break
            end
        end
        if not child then
            addLog("[MEGA-JUMP-INSTA] [!] Não achei um filho chamado '92' dentro de " .. folder:GetFullName())
            return nil
        end

        local part = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart", true)
        if part then
            addLog("[MEGA-JUMP-INSTA] [*] Checkpoint 92 encontrado: " .. part:GetFullName())
        end
        return part
    end

    local function findLandingZone3()
        local direct = Workspace:FindFirstChild("LandingZone3", true)
        if not direct then return nil end
        if direct:IsA("BasePart") then return direct end
        return direct:FindFirstChildWhichIsA("BasePart", true)
    end

    -- Offsets medidos direto no Studio (Properties de cada part, com o
    -- CarSpawn tomado como ponto de referência (0,0,0)):
    --   CarSpawn:     -0.108, 125.979, -1563.82
    --   JumpCar:      -0,     143.307, -1539.577  -> offset (0, +17.328, +24.243)
    --   Checkpoint 92: -0.021, 216,    -1538.844  -> offset (+0.087, +90.021, +24.976)
    -- Ou seja, o JumpCar NÃO fica no mesmo Y do CarSpawn (fica ~17 studs
    -- mais alto) e o Checkpoint 92 fica bem mais alto ainda (~90 studs),
    -- igual a rampa real do jogo -- por isso não dá pra colapsar os 3 no
    -- mesmo ponto exato, só alinhar em X/Z e respeitar essas diferenças
    -- de altura. Além de mover, também zeramos qualquer Attribute de
    -- força/impulso do JumpCar (nomes tipo Force/Power/Impulse/Speed),
    -- restaurando os valores originais no Restaurar.
    -- LandingZone3 (mais baixa, valor atualizado): -8.181, 133.341, -1398.538
    -- -> offset (-8.073, +7.362, +165.282)
    -- Checkpoint 92 (novo valor): -0.021, 216, -1541.379 -> offset (+0.087, +90.021, +22.441)
    local JUMP_CAR_OFFSET = Vector3.new(0.108, 17.328, 24.243)
    local CHECKPOINT92_OFFSET = Vector3.new(0.087, 90.021, 22.441)
    local LANDING_ZONE_OFFSET = Vector3.new(-8.073, 7.362, 165.282)
    local FORCE_ATTRIBUTE_KEYWORDS = { "force", "power", "impulse", "speed", "launch", "jump" }
    -- Checkpoint 92 é minúsculo perto do JumpCar/CarSpawn -- quando tudo
    -- colapsa pro mesmo ponto, o carro acaba pousando fora da área de
    -- toque dele e triggando os checkpoints 0/1 por engano (que são bem
    -- maiores). Aumentamos o Size dele (mantendo o centro) só enquanto
    -- ativo, pra garantir que a área cubra o ponto alvo.
    local CHECKPOINT_SIZE_MULTIPLIER = 6

    -- Além de aumentar o Size do Checkpoint 92 em si, criamos mais 3
    -- cópias dele ao redor -- mais acima, mais abaixo (só um pouco, pra
    -- não ficar longe demais do chão) e mais à frente -- formando um
    -- "quadrado" de áreas de toque em volta do ponto alvo. Cada cópia
    -- dispara o MESMO MiniParkourEvent("CheckpointTouched", 92) que o
    -- original, igual o CheckpointDup já faz com outros checkpoints.
    local CHECKPOINT_SQUARE_OFFSETS = {
        Vector3.new(0, 40, 0),   -- mais acima
        Vector3.new(0, -15, 0),  -- mais abaixo (não tão abaixo)
        Vector3.new(0, 0, 40),   -- mais à frente
    }

    local function wireCheckpoint92DupTouched(part)
        part.CanTouch = true
        part.CanCollide = false
        part.Touched:Connect(function(hit)
            if not hit then return end
            local isMine = false
            local character = LocalPlayer.Character
            if character and hit:IsDescendantOf(character) then
                isMine = true
            else
                local model = hit:FindFirstAncestorOfClass("Model")
                isMine = model ~= nil and model:GetAttribute("OwnerUserId") == LocalPlayer.UserId
            end
            if not isMine then return end
            if not miniParkourEventRemote then return end
            pcall(function() miniParkourEventRemote:FireServer("CheckpointTouched", 92) end)
            addLog("[MEGA-JUMP-INSTA] Checkpoint 92 (cópia do quadrado) disparado")
        end)
    end

    local function createCheckpoint92SquareDuplicates(checkpoint92)
        local dups = {}
        for _, offset in ipairs(CHECKPOINT_SQUARE_OFFSETS) do
            local clone = checkpoint92:Clone()
            clone.Name = "92_HubSquareDup"
            clone.CFrame = checkpoint92.CFrame + offset
            clone.Parent = checkpoint92.Parent
            wireCheckpoint92DupTouched(clone)
            table.insert(dups, clone)
        end
        return dups
    end

    local function removeCheckpoint92SquareDuplicates(dups)
        for _, part in ipairs(dups) do
            if part.Parent then part:Destroy() end
        end
    end

    local function zeroOutJumpCarForce(jumpCar)
        local savedAttrs = {}
        local ok, attrs = pcall(function() return jumpCar:GetAttributes() end)
        if ok and attrs then
            for name, value in pairs(attrs) do
                if typeof(value) == "number" then
                    local lowerName = name:lower()
                    for _, keyword in ipairs(FORCE_ATTRIBUTE_KEYWORDS) do
                        if lowerName:find(keyword, 1, true) then
                            savedAttrs[name] = value
                            pcall(function() jumpCar:SetAttribute(name, 0) end)
                            addLog("[MEGA-JUMP-INSTA] [*] Attribute '" .. name .. "' (" .. tostring(value) .. ") zerado no JumpCar")
                            break
                        end
                    end
                end
            end
        end
        return savedAttrs
    end

    local function restoreJumpCarForce(jumpCar, savedAttrs)
        if not jumpCar or not jumpCar.Parent then return end
        for name, value in pairs(savedAttrs) do
            pcall(function() jumpCar:SetAttribute(name, value) end)
        end
    end

    local function enable(x, y, z)
        if enabled then return end

        local carSpawn = findCarSpawnPart()
        local jumpCar = jumpCarPart or findJumpCarPart()
        local checkpoint92 = findCheckpoint92()
        local landingZone3 = findLandingZone3()

        if not carSpawn or not jumpCar or not checkpoint92 then
            addLog("[MEGA-JUMP-INSTA] [!] Não achei tudo (CarSpawn=" .. tostring(carSpawn ~= nil)
                .. ", JumpCar=" .. tostring(jumpCar ~= nil) .. ", Checkpoint 92=" .. tostring(checkpoint92 ~= nil) .. ")")
            return
        end

        saved.carSpawn = { part = carSpawn, cframe = carSpawn.CFrame }
        saved.jumpCar = { part = jumpCar, cframe = jumpCar.CFrame }
        saved.checkpoint92 = { part = checkpoint92, cframe = checkpoint92.CFrame }
        saved.checkpoint92Size = checkpoint92.Size
        saved.landingZone3 = landingZone3 and { part = landingZone3, cframe = landingZone3.CFrame } or nil

        local target = Vector3.new(x, y, z)
        local function moveKeepingRotation(part, position)
            local rotation = part.CFrame - part.CFrame.Position
            part.CFrame = CFrame.new(position) * rotation
        end
        moveKeepingRotation(carSpawn, target)
        moveKeepingRotation(jumpCar, target + JUMP_CAR_OFFSET)
        moveKeepingRotation(checkpoint92, target + CHECKPOINT92_OFFSET)
        checkpoint92.Size = saved.checkpoint92Size * CHECKPOINT_SIZE_MULTIPLIER
        addLog("[MEGA-JUMP-INSTA] [*] Checkpoint 92 aumentado de " .. tostring(saved.checkpoint92Size) .. " pra " .. tostring(checkpoint92.Size))
        saved.checkpoint92SquareDups = createCheckpoint92SquareDuplicates(checkpoint92)
        addLog("[MEGA-JUMP-INSTA] [*] " .. #saved.checkpoint92SquareDups .. " cópias do Checkpoint 92 criadas em quadrado (acima/abaixo/frente)")
        if landingZone3 then
            moveKeepingRotation(landingZone3, target + LANDING_ZONE_OFFSET)
        else
            addLog("[MEGA-JUMP-INSTA] [!] LandingZone3 não encontrada (seguindo sem mover)")
        end

        saved.jumpCarForceAttrs = zeroOutJumpCarForce(jumpCar)

        saved.resetZones = {}
        local resetFolder = findCarResetZonesFolder()
        if resetFolder then
            for _, part in ipairs(resetFolder:GetDescendants()) do
                if part:IsA("BasePart") then
                    saved.resetZones[part] = { canCollide = part.CanCollide, canTouch = part.CanTouch, transparency = part.Transparency }
                    part.CanCollide = false
                    part.CanTouch = false
                    part.Transparency = 1
                end
            end
        else
            addLog("[MEGA-JUMP-INSTA] [!] CarResetZones não encontrado (seguindo sem desativar)")
        end

        enabled = true
        addLog("[MEGA-JUMP-INSTA] [✓] Ativado -- CarSpawn/JumpCar/Checkpoint92 movidos pra (" .. x .. ", " .. y .. ", " .. z .. "), CarResetZones desativadas (só na sua tela)")
    end

    local function disable()
        if not enabled then return end

        if saved.carSpawn and saved.carSpawn.part.Parent then saved.carSpawn.part.CFrame = saved.carSpawn.cframe end
        if saved.jumpCar and saved.jumpCar.part.Parent then saved.jumpCar.part.CFrame = saved.jumpCar.cframe end
        if saved.checkpoint92 and saved.checkpoint92.part.Parent then
            saved.checkpoint92.part.CFrame = saved.checkpoint92.cframe
            if saved.checkpoint92Size then saved.checkpoint92.part.Size = saved.checkpoint92Size end
        end
        removeCheckpoint92SquareDuplicates(saved.checkpoint92SquareDups)
        saved.checkpoint92SquareDups = {}
        if saved.landingZone3 and saved.landingZone3.part.Parent then saved.landingZone3.part.CFrame = saved.landingZone3.cframe end

        if saved.jumpCar then
            restoreJumpCarForce(saved.jumpCar.part, saved.jumpCarForceAttrs)
        end
        saved.jumpCarForceAttrs = {}

        for part, state in pairs(saved.resetZones) do
            if part.Parent then
                part.CanCollide = state.canCollide
                part.CanTouch = state.canTouch
                part.Transparency = state.transparency
            end
        end
        saved.resetZones = {}

        enabled = false
        addLog("[MEGA-JUMP-INSTA] Restaurado -- posições e CarResetZones originais de volta")
    end

    return {
        enable = enable,
        disable = disable,
        isEnabled = function() return enabled end,
        getDefaultPosition = function()
            local carSpawn = findCarSpawnPart()
            if carSpawn then return carSpawn.Position end
            return Vector3.new(0, 0, 0)
        end,
    }
end

MegaJumpInsta = buildMegaJumpInstaFeature()

-- ========================================
-- REMOTE SPY: loga ao vivo TODO FireServer/InvokeServer que sai do client
-- (não só os que a gente mesmo dispara) via hookmetamethod no __namecall
-- do jogo -- é assim que dá pra ver o que o PRÓPRIO JOGO manda pro
-- servidor quando você vende, ganha, abre caixa etc., sem precisar ler o
-- script decompilado e adivinhar. Também loga todo OnClientEvent que
-- chega (servidor -> client) nos remotes existentes em ReplicatedStorage.
-- Precisa que o executor suporte hookmetamethod/getrawmetatable/
-- newcclosure -- se não suportar, avisa e só faz o lado de entrada
-- (OnClientEvent), que não depende de hook nenhum.
-- ========================================

local function buildRemoteSpyFeature()
    local MAX_ENTRIES = 200
    local entries = {}
    local enabled = false
    local originalNamecall = nil
    local refreshUI = nil
    local incomingConnections = {}

    local function serializeValue(v)
        local ty = typeof(v)
        if ty == "string" then
            return "\"" .. v .. "\""
        elseif ty == "Instance" then
            local ok, full = pcall(function() return v:GetFullName() end)
            return ok and full or ("<" .. v.ClassName .. ">")
        elseif ty == "table" then
            local ok, encoded = pcall(function() return HttpService:JSONEncode(v) end)
            return ok and encoded or "<table>"
        else
            return tostring(v)
        end
    end

    local function addEntry(direction, remoteName, method, args)
        local parts = {}
        for _, v in ipairs(args) do
            table.insert(parts, serializeValue(v))
        end
        local line = string.format("[%s] %s %s(%s)", direction, remoteName, method, table.concat(parts, ", "))

        table.insert(entries, line)
        if #entries > MAX_ENTRIES then
            table.remove(entries, 1)
        end

        print("[SPY] " .. line)
        if refreshUI then refreshUI() end
    end

    -- Só usa acesso a PROPRIEDADE (self.ClassName, self.Name, self.Parent)
    -- aqui dentro, nunca self:Metodo(...) -- qualquer chamada de método
    -- (mesmo IsA/GetFullName) passa de novo pelo __namecall que a gente
    -- acabou de hookear, e como esse hook roda pra TODA chamada de método
    -- do jogo inteiro (não só remotes), cada FireServer disparava 2-3
    -- passagens extras por ele mesmo -- multiplicado pela frequência de
    -- chamadas do jogo isso travava a tela bem na hora do reveal.
    local function getPathSafe(inst)
        local ok, result = pcall(function()
            local names = {}
            local cur = inst
            local hops = 0
            while cur and hops < 6 do
                table.insert(names, 1, cur.Name)
                cur = cur.Parent
                hops = hops + 1
            end
            return table.concat(names, ".")
        end)
        return ok and result or "?"
    end

    local function hookOutgoing()
        if typeof(hookmetamethod) ~= "function" or typeof(getrawmetatable) ~= "function" then
            return false
        end

        local ok = pcall(function()
            local gameMeta = getrawmetatable(game)
            local wasReadOnly = false
            pcall(function()
                if typeof(setreadonly) == "function" then
                    wasReadOnly = true
                    setreadonly(gameMeta, false)
                end
            end)

            originalNamecall = gameMeta.__namecall
            gameMeta.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod and getnamecallmethod() or ""
                if method == "FireServer" or method == "InvokeServer" then
                    local args = { ... }
                    pcall(function()
                        local className = self.ClassName
                        if className == "RemoteEvent" or className == "RemoteFunction" then
                            local path = getPathSafe(self)
                            task.spawn(function()
                                addEntry("OUT", path, method, args)
                            end)
                        end
                    end)
                end
                return originalNamecall(self, ...)
            end)

            if wasReadOnly and typeof(setreadonly) == "function" then
                setreadonly(gameMeta, true)
            end
        end)

        return ok
    end

    local function unhookOutgoing()
        if not originalNamecall then return end
        pcall(function()
            local gameMeta = getrawmetatable(game)
            local wasReadOnly = false
            pcall(function()
                if typeof(setreadonly) == "function" then
                    wasReadOnly = true
                    setreadonly(gameMeta, false)
                end
            end)
            gameMeta.__namecall = originalNamecall
            if wasReadOnly and typeof(setreadonly) == "function" then
                setreadonly(gameMeta, true)
            end
        end)
        originalNamecall = nil
    end

    local function hookIncomingFor(remote)
        if incomingConnections[remote] then return end
        if remote:IsA("RemoteEvent") then
            local path = getPathSafe(remote)
            incomingConnections[remote] = remote.OnClientEvent:Connect(function(...)
                addEntry("IN", path, "OnClientEvent", { ... })
            end)
        end
    end

    local function hookAllIncoming()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then hookIncomingFor(obj) end
        end
        incomingConnections["__descendantAdded"] = ReplicatedStorage.DescendantAdded:Connect(function(obj)
            if obj:IsA("RemoteEvent") then hookIncomingFor(obj) end
        end)
    end

    local function unhookAllIncoming()
        for _, conn in pairs(incomingConnections) do
            if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
        end
        incomingConnections = {}
    end

    local function enable()
        if enabled then return end
        local outgoingOk = hookOutgoing()
        hookAllIncoming()
        enabled = true
        addLog("[SPY] Ativado" .. (outgoingOk and "" or " (só entrada -- executor não suporta hookmetamethod pra ver saída)"))
        return outgoingOk
    end

    local function disable()
        if not enabled then return end
        unhookOutgoing()
        unhookAllIncoming()
        enabled = false
        addLog("[SPY] Desativado")
    end

    local function clear()
        entries = {}
        if refreshUI then refreshUI() end
    end

    local function getLogText()
        return table.concat(entries, "\n")
    end

    return {
        enable = enable,
        disable = disable,
        clear = clear,
        getLogText = getLogText,
        isEnabled = function() return enabled end,
        setRefreshCallback = function(fn) refreshUI = fn end,
    }
end

local RemoteSpy = buildRemoteSpyFeature()

-- ========================================
-- FUNCTION SPY: em vez de reimplementar a lógica do checkpoint por conta
-- própria (como fizemos no CheckpointDup, que não funcionou), isso aqui
-- captura a FUNÇÃO REAL que o próprio jogo conectou no Touched de um
-- checkpoint -- via getconnections(part.Touched), que devolve as
-- conexões existentes com a referência pra função real (.Function).
-- Assim dá pra chamar o EXATO mesmo código do jogo manualmente, com
-- qualquer part que a gente quiser passar como "hit", sem ter que
-- adivinhar a lógica interna dele. Precisa de getconnections com suporte
-- a .Function -- Wave e a maioria dos executores completos têm.
-- ========================================

local function buildFunctionSpyFeature()
    local capturedFn = nil
    local capturedFrom = nil
    local capturedKind = nil -- "touched" ou "remote" -- muda a assinatura de argumentos ao chamar

    -- Monta um relatório de texto com tudo que dá pra descobrir sobre a
    -- função capturada (via debug.getinfo -- source, linha, número de
    -- upvalues/params, se é vararg) e copia pro clipboard, igual o
    -- Remote Spy já faz com o log -- assim dá pra colar aqui na
    -- conversa sem precisar copiar do console manualmente.
    local function buildCaptureReport(checkpointName, fn)
        local lines = {
            "=== FUNCTION SPY: checkpoint '" .. tostring(checkpointName) .. "' ===",
        }

        local infoOk, info = pcall(debug.getinfo, fn)
        if infoOk and info then
            table.insert(lines, "source: " .. tostring(info.source))
            table.insert(lines, "short_src: " .. tostring(info.short_src))
            table.insert(lines, "linedefined: " .. tostring(info.linedefined))
            table.insert(lines, "currentline: " .. tostring(info.currentline))
            table.insert(lines, "what: " .. tostring(info.what))
            table.insert(lines, "nparams: " .. tostring(info.nparams))
            table.insert(lines, "is_vararg: " .. tostring(info.is_vararg))
        else
            table.insert(lines, "[!] debug.getinfo indisponível ou falhou")
        end

        if typeof(debug.getupvalues) == "function" then
            local upOk, ups = pcall(debug.getupvalues, fn)
            if upOk and ups then
                table.insert(lines, "upvalues (" .. #ups .. "):")
                for i, v in ipairs(ups) do
                    table.insert(lines, "  [" .. i .. "] " .. typeof(v) .. " = " .. tostring(v))
                end
            end
        end

        if typeof(decompile) == "function" then
            local decOk, source = pcall(decompile, fn)
            if decOk and source then
                table.insert(lines, "--- decompile ---")
                table.insert(lines, tostring(source))
            end
        end

        return table.concat(lines, "\n")
    end

    local function tryCaptureFromSignal(sourceName, signal, kind)
        local ok, conns = pcall(getconnections, signal)
        if not ok or not conns then return false end

        for _, conn in ipairs(conns) do
            local fn = conn.Function
            if fn then
                capturedFn = fn
                capturedFrom = sourceName
                capturedKind = kind

                local report = buildCaptureReport(sourceName, fn)
                print("[FN-SPY]\n" .. report)

                if typeof(setclipboard) == "function" then
                    local copied = pcall(setclipboard, report)
                    addLog(copied
                        and ("[FN-SPY] Função capturada de '" .. sourceName .. "' -- info copiada pro clipboard!")
                        or ("[FN-SPY] Função capturada, mas setclipboard falhou -- veja no console"))
                else
                    addLog("[FN-SPY] Função capturada de '" .. sourceName .. "' -- esse executor não suporta setclipboard, veja no console")
                end

                return true
            end
        end

        return false
    end

    -- O "Checkpoint UI: 48 x6000..." que aparece no console NÃO vem de
    -- um Touched físico -- é o próprio sistema de sorte da rampa, guiado
    -- 100% pelo remote CheckpointLuckUpdate (confirmado no Remote Spy:
    -- só aparecem entradas [IN] pra ele, nunca Touched). Por isso captura
    -- primeiro nos remotes que a gente sabe que disparam de verdade
    -- (igual o SimpleSpy faz -- getconnections funciona em OnClientEvent
    -- do mesmo jeito que em Touched), e só cai pro Touched dos
    -- checkpoints como último recurso, caso o jogo mude de novo.
    local function captureCheckpointTouched()
        if typeof(getconnections) ~= "function" then
            addLog("[FN-SPY] [!] getconnections não suportado nesse executor")
            return false
        end

        local remoteCandidates = { "CheckpointLuckUpdate", "JumpLuckStart", "JumpLuckEnd" }
        for _, name in ipairs(remoteCandidates) do
            local remote = findRemote(name)
            if remote then
                if tryCaptureFromSignal(name .. ".OnClientEvent", remote.OnClientEvent, "remote") then
                    return true
                end
            end
        end

        local folder = Workspace:FindFirstChild("Checkpoints", true)
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                local part = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    if tryCaptureFromSignal(child.Name .. ".Touched", part.Touched, "touched") then
                        return true
                    end
                end
            end
        end

        addLog("[FN-SPY] [!] Nenhuma conexão encontrada (nem nos remotes de sorte, nem nos checkpoints Touched)")
        return false
    end

    -- A função capturada de um REMOTE (OnClientEvent) recebe os MESMOS
    -- argumentos que o servidor mandou no evento -- pra CheckpointLuckUpdate
    -- isso é (isJackpot: boolean, luckValue: number, ...), NUNCA uma part
    -- de Touched. Passar o carro como argumento aqui é o que causava
    -- "invalid argument #2 to 'max' (number expected, got Instance)".
    -- Chamamos manualmente com um valor de sorte gigante só pra ver o que
    -- essa função faz com ele (ex: se só atualiza um LuckValue LOCAL/visual,
    -- ou se dispara algo mais) -- é 100% client-side, não manda nada pro
    -- servidor por conta própria (quem manda pro servidor é outro remote).
    local function callCapturedWithCar()
        if not capturedFn then
            addLog("[FN-SPY] [!] Capture a função primeiro")
            return
        end

        local ok, err
        if capturedKind == "remote" then
            -- Primeira tentativa (isJackpot=true, luckValue=numero) deu
            -- "argument #2 to 'max' (number expected, got boolean)" -- ou
            -- seja o 2º parâmetro TAMBÉM precisa ser número. O formato do
            -- print do próprio jogo ("Checkpoint UI: 48 x6000") sugere que
            -- a assinatura real é (index: number, luckValue: number).
            local testIndex, testValue = 1, 999999999
            ok, err = pcall(capturedFn, testIndex, testValue)
            addLog("[FN-SPY] Chamando função de remote com (index=" .. testIndex .. ", luckValue=" .. testValue .. ") -- teste 100% local, não afeta o servidor")
        else
            local car = findPlayerCarModel()
            local hitPart = car and (car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart", true))
            if not hitPart then
                addLog("[FN-SPY] [!] Carro não encontrado -- entre no carro primeiro")
                return
            end
            ok, err = pcall(capturedFn, hitPart)
        end

        local resultText = ok
            and ("=== FUNCTION SPY: chamada de '" .. tostring(capturedFrom) .. "' ===\nSucesso -- sem erro retornado.")
            or ("=== FUNCTION SPY: chamada de '" .. tostring(capturedFrom) .. "' ===\nErro: " .. tostring(err))

        print("[FN-SPY]\n" .. resultText)

        if typeof(setclipboard) == "function" then
            local copied = pcall(setclipboard, resultText)
            addLog((ok and "[FN-SPY] [✓] Função real chamada com sucesso" or "[FN-SPY] [!] Erro ao chamar a função real: " .. tostring(err))
                .. (copied and " -- resultado copiado pro clipboard!" or " -- setclipboard falhou, veja no console"))
        else
            addLog(ok and "[FN-SPY] [✓] Função real chamada com sucesso (executor sem setclipboard, veja no console)"
                or "[FN-SPY] [!] Erro ao chamar a função real: " .. tostring(err))
        end
    end

    return {
        capture = captureCheckpointTouched,
        callWithCar = callCapturedWithCar,
        hasCaptured = function() return capturedFn ~= nil end,
    }
end

local FunctionSpy = buildFunctionSpyFeature()

-- ========================================
-- PROPS LOCAIS: spawnar/clonar/grudar/segurar objetos onde você olha --
-- 100% client-side (LocalScript não tem canal de rede pra replicar
-- Instance criada por ele pra outros clients nem pro servidor), então só
-- APARECE NA SUA TELA. Bom pra brincar sozinho, gravar clipe, testar
-- cena -- não é visível pros outros jogadores.
-- ========================================

-- Tudo isso vai dentro de uma função própria só pra economizar registros
-- de variável local do chunk principal (mesmo motivo do setupMenu() lá
-- embaixo) -- só o necessário sai pra fora, dentro da tabela Props.
local function buildPropsFeature()
    local propsFolder = Instance.new("Folder")
    propsFolder.Name = "HubLocalProps"
    propsFolder.Parent = Workspace

    local config = { spawnDistance = 50, selected = nil, carrying = false, holdDistance = 8 }
    local statusLabel = nil
    local propHighlight = nil

    local function castLookRay(maxDistance, extraIgnore)
        local camera = Workspace.CurrentCamera
        local origin = camera.CFrame.Position
        local direction = camera.CFrame.LookVector * (maxDistance or 500)

        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local ignore = {}
        if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
        if extraIgnore then
            for _, obj in ipairs(extraIgnore) do table.insert(ignore, obj) end
        end
        params.FilterDescendantsInstances = ignore

        return Workspace:Raycast(origin, direction, params)
    end

    -- Flecha/mira fixa no centro da tela, pra saber exatamente o que vai
    -- ser clonado/grudado/movido antes de clicar -- também 100% local.
    local crosshairGui = Instance.new("ScreenGui")
    crosshairGui.Name = "HubCrosshair"
    crosshairGui.ResetOnSpawn = false
    crosshairGui.DisplayOrder = 998
    crosshairGui.IgnoreGuiInset = true
    crosshairGui.Parent = playerGui

    local crosshairLabel = Instance.new("TextLabel")
    crosshairLabel.Name = "Arrow"
    crosshairLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    crosshairLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    crosshairLabel.Size = UDim2.new(0, 24, 0, 24)
    crosshairLabel.BackgroundTransparency = 1
    crosshairLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
    crosshairLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    crosshairLabel.TextStrokeTransparency = 0
    crosshairLabel.TextScaled = true
    crosshairLabel.Font = Enum.Font.GothamBold
    crosshairLabel.Text = "▼"
    crosshairLabel.Parent = crosshairGui

    local function getSelectedPrimaryPart()
        local selected = config.selected
        if not selected or not selected.Parent then return nil end
        if selected:IsA("Model") then
            return selected.PrimaryPart or selected:FindFirstChildWhichIsA("BasePart", true)
        elseif selected:IsA("BasePart") then
            return selected
        end
        return nil
    end

    local function selectProp(instance)
        if propHighlight then
            propHighlight:Destroy()
            propHighlight = nil
        end
        config.selected = instance
        config.carrying = false

        if instance then
            local hl = Instance.new("Highlight")
            hl.Name = "HubPropHighlight"
            hl.FillColor = Color3.fromRGB(0, 200, 255)
            hl.FillTransparency = 0.6
            hl.OutlineColor = Color3.fromRGB(0, 200, 255)
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = instance
            propHighlight = hl

            if statusLabel then
                statusLabel.Text = t("label_selected") .. instance.Name
                statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
            end
        elseif statusLabel then
            statusLabel.Text = t("label_none_selected")
            statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end

    local function cloneLookedAt()
        local hit = castLookRay(config.spawnDistance, { propsFolder })
        if not hit or not hit.Instance then
            addLog("[PROPS] [!] Nada na mira pra clonar")
            return
        end

        local target = hit.Instance
        local model = target:FindFirstAncestorOfClass("Model")
        local sourceToClone = model or target

        local ok, clone = pcall(function() return sourceToClone:Clone() end)
        if not ok or not clone then
            addLog("[PROPS] [!] Não consegui clonar esse objeto")
            return
        end

        if clone:IsA("Model") then
            for _, d in ipairs(clone:GetDescendants()) do
                if d:IsA("BasePart") then d.Anchored = true d.CanCollide = false end
            end
            local primary = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
            if primary then
                clone:PivotTo(CFrame.new(hit.Position))
            end
            clone.Parent = propsFolder
            selectProp(primary or clone)
        elseif clone:IsA("BasePart") then
            clone.Anchored = true
            clone.CanCollide = false
            clone.Position = hit.Position
            clone.Parent = propsFolder
            selectProp(clone)
        else
            clone:Destroy()
            addLog("[PROPS] [!] Objeto não clonável (não é Part/Model)")
            return
        end

        addLog("[PROPS] Clonado: " .. target.Name)
    end

    local function attachSelectedToLookTarget()
        local primary = getSelectedPrimaryPart()
        if not primary then
            addLog("[PROPS] [!] Nenhum objeto selecionado")
            return
        end
        local hit = castLookRay(config.spawnDistance, { propsFolder })
        if not hit or not hit.Instance then
            addLog("[PROPS] [!] Nada na mira pra grudar")
            return
        end
        local targetPart = hit.Instance:IsA("BasePart") and hit.Instance or hit.Instance:FindFirstAncestorWhichIsA("BasePart")
        if not targetPart then
            addLog("[PROPS] [!] Não achei uma parte sólida na mira")
            return
        end

        local existing = primary:FindFirstChild("HubPropWeld")
        if existing then existing:Destroy() end

        primary.Position = hit.Position
        primary.Anchored = false

        local weld = Instance.new("WeldConstraint")
        weld.Name = "HubPropWeld"
        weld.Part0 = primary
        weld.Part1 = targetPart
        weld.Parent = primary

        addLog("[PROPS] Grudado em " .. targetPart.Name)
    end

    local function detachSelected()
        local primary = getSelectedPrimaryPart()
        if not primary then return end
        local existing = primary:FindFirstChild("HubPropWeld")
        if existing then existing:Destroy() end
        addLog("[PROPS] Solto")
    end

    local function toggleAnchorSelected()
        local primary = getSelectedPrimaryPart()
        if not primary then
            addLog("[PROPS] [!] Nenhum objeto selecionado")
            return
        end
        primary.Anchored = not primary.Anchored
        addLog("[PROPS] " .. (primary.Anchored and "Ancorado" or "Solto (física ligada)"))
    end

    local function scaleSelected(multiplier)
        local primary = getSelectedPrimaryPart()
        if not primary then
            addLog("[PROPS] [!] Nenhum objeto selecionado")
            return
        end
        primary.Size = primary.Size * multiplier
    end

    local function deleteSelected()
        local selected = config.selected
        if not selected then
            addLog("[PROPS] [!] Nenhum objeto selecionado")
            return
        end
        selectProp(nil)
        selected:Destroy()
        addLog("[PROPS] Deletado")
    end

    local function clearAllProps()
        selectProp(nil)
        propsFolder:ClearAllChildren()
        addLog("[PROPS] Tudo limpo")
    end

    local selectModeEnabled = false

    local function toggleSelectMode()
        selectModeEnabled = not selectModeEnabled
        addLog("[PROPS] Modo seleção " .. (selectModeEnabled and "ATIVADO (clique num objeto clonado)" or "DESATIVADO"))
        return selectModeEnabled
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if not selectModeEnabled then return end

        local hit = castLookRay(config.spawnDistance * 3)
        if hit and hit.Instance and hit.Instance:IsDescendantOf(propsFolder) then
            selectProp(hit.Instance)
        end
    end)

    local function toggleCarry()
        if not config.selected then
            addLog("[PROPS] [!] Nenhum objeto selecionado")
            return
        end
        config.carrying = not config.carrying
        addLog("[PROPS] Segurando: " .. tostring(config.carrying))
    end

    RunService.Heartbeat:Connect(function()
        if not config.carrying then return end
        local primary = getSelectedPrimaryPart()
        if not primary then
            config.carrying = false
            return
        end
        primary.Anchored = true
        local camera = Workspace.CurrentCamera
        local holdCFrame = camera.CFrame * CFrame.new(0, 0, -config.holdDistance)
        local selected = config.selected
        if selected:IsA("Model") then
            selected:PivotTo(holdCFrame)
        else
            primary.CFrame = holdCFrame
        end
    end)

    return {
        config = config,
        crosshairLabel = crosshairLabel,
        setStatusLabel = function(lbl) statusLabel = lbl end,
        clone = cloneLookedAt,
        attach = attachSelectedToLookTarget,
        detach = detachSelected,
        toggleAnchor = toggleAnchorSelected,
        scale = scaleSelected,
        delete = deleteSelected,
        clearAll = clearAllProps,
        toggleSelectMode = toggleSelectMode,
        toggleCarry = toggleCarry,
    }
end

local Props = buildPropsFeature()

-- ========================================
-- HORÁRIO (DIA/NOITE): Lighting.ClockTime replica DO SERVIDOR pro client
-- normalmente, mas o client pode sobrescrever localmente -- também só
-- aparece pra você. Se o jogo tiver um ciclo dia/noite rodando no
-- servidor, ele vai ficar tentando voltar o valor, então reaplicamos
-- sozinhos toda vez que ele mudar (enquanto ATIVADO).
-- ========================================

local timeOfDayConfig = { enabled = false, clockTime = 14 }

local function applyTimeOfDay()
    if not timeOfDayConfig.enabled then return end
    Lighting.ClockTime = timeOfDayConfig.clockTime
end

-- Antes isso escutava GetPropertyChangedSignal("ClockTime") e reescrevia
-- o valor de dentro do próprio handler -- se o jogo também tem um ciclo
-- dia/noite rodando no servidor, isso vira um vaivém (nosso handler
-- dispara o evento de novo, que dispara o handler de novo...) que o
-- Roblox corta sozinho com "Exponential deferred event growth detected".
-- Um polling simples no Heartbeat evita esse loop de evento-dentro-de-
-- evento por completo.
RunService.Heartbeat:Connect(function()
    if timeOfDayConfig.enabled and math.abs(Lighting.ClockTime - timeOfDayConfig.clockTime) > 0.05 then
        applyTimeOfDay()
    end
end)

-- ========================================
-- CLIMA: o jogo não tem sistema de clima nenhum (sem chuva/tempestade/
-- neblina/neve -- conferido, não existe nada assim no código), então
-- isso aqui é construído do zero, 100% local (só na sua tela, ninguém
-- mais vê) -- Atmosphere pra neblina/densidade, ParticleEmitter presa
-- numa part que segue a câmera pra chuva/neve/areia, e um flash de
-- PointLight + som pra trovão na tempestade.
-- ========================================

local function buildWeatherFeature()
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Parent = Lighting
    end
    local defaultAtmosphere = {
        Density = atmosphere.Density,
        Offset = atmosphere.Offset,
        Color = atmosphere.Color,
        Decay = atmosphere.Decay,
        Glare = atmosphere.Glare,
        Haze = atmosphere.Haze,
    }

    local followPart = Instance.new("Part")
    followPart.Name = "HubWeatherFollow"
    followPart.Anchored = true
    followPart.CanCollide = false
    followPart.CanTouch = false
    followPart.CanQuery = false
    followPart.Transparency = 1
    followPart.Size = Vector3.new(1, 1, 1)
    followPart.Parent = Workspace

    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "HubWeatherEmitter"
    emitter.Enabled = false
    emitter.Rate = 0
    emitter.Parent = followPart

    local followConn = RunService.RenderStepped:Connect(function()
        local camera = Workspace.CurrentCamera
        followPart.CFrame = camera.CFrame + camera.CFrame.LookVector * 40 + Vector3.new(0, 25, 0)
    end)

    local currentPreset = "clear"

    local function stopThunder()
        -- o loop de trovão checa `currentPreset == "storm"` a cada
        -- iteração e se auto-encerra quando o preset muda, então só
        -- precisamos garantir que currentPreset já não seja mais "storm"
        -- antes de chamar isso (feito em applyPreset logo no início).
    end

    local function flashThunder()
        local camera = Workspace.CurrentCamera
        local flash = Instance.new("ColorCorrectionEffect")
        flash.Name = "HubThunderFlash"
        flash.Brightness = 0.6
        flash.Parent = Lighting

        local sound = Instance.new("Sound")
        sound.SoundId = "rbxasset://sounds/impact_water.mp3"
        sound.Volume = 0.6
        sound.Parent = camera
        pcall(function() sound:Play() end)

        task.delay(0.15, function()
            if flash.Parent then flash:Destroy() end
        end)
        task.delay(3, function()
            if sound.Parent then sound:Destroy() end
        end)
    end

    local function configureEmitter(shape, color, size, speed, rate, lifetime, rotSpeed)
        emitter.Texture = shape
        emitter.Color = ColorSequence.new(color)
        emitter.Size = NumberSequence.new(size)
        emitter.Speed = NumberRange.new(speed[1], speed[2])
        emitter.Rate = rate
        emitter.Lifetime = NumberRange.new(lifetime[1], lifetime[2])
        emitter.RotSpeed = NumberRange.new(rotSpeed[1], rotSpeed[2])
        emitter.SpreadAngle = Vector2.new(60, 60)
        emitter.Enabled = true
    end

    local function applyPreset(name, statusLabel)
        currentPreset = name
        stopThunder()
        emitter.Enabled = false

        if name == "clear" then
            atmosphere.Density = defaultAtmosphere.Density
            atmosphere.Offset = defaultAtmosphere.Offset
            atmosphere.Color = defaultAtmosphere.Color
            atmosphere.Decay = defaultAtmosphere.Decay
            atmosphere.Glare = defaultAtmosphere.Glare
            atmosphere.Haze = defaultAtmosphere.Haze
        elseif name == "rain" then
            atmosphere.Density = 0.35
            atmosphere.Haze = 1.5
            atmosphere.Color = Color3.fromRGB(150, 160, 170)
            configureEmitter("rbxasset://textures/particle.dds", Color3.fromRGB(200, 210, 230), 1.2, { 60, 80 }, 300, { 0.6, 0.9 }, { 0, 0 })
        elseif name == "storm" then
            atmosphere.Density = 0.55
            atmosphere.Haze = 3
            atmosphere.Color = Color3.fromRGB(90, 95, 110)
            configureEmitter("rbxasset://textures/particle.dds", Color3.fromRGB(180, 190, 210), 1.6, { 90, 120 }, 600, { 0.4, 0.7 }, { 0, 0 })
            task.spawn(function()
                while currentPreset == "storm" do
                    task.wait(math.random(4, 10))
                    if currentPreset == "storm" then flashThunder() end
                end
            end)
        elseif name == "fog" then
            atmosphere.Density = 0.7
            atmosphere.Offset = 0.1
            atmosphere.Haze = 4
            atmosphere.Color = Color3.fromRGB(200, 200, 205)
        elseif name == "snow" then
            atmosphere.Density = 0.3
            atmosphere.Haze = 1
            atmosphere.Color = Color3.fromRGB(210, 220, 235)
            configureEmitter("rbxasset://textures/particle.dds", Color3.fromRGB(255, 255, 255), 2, { 8, 15 }, 150, { 3, 5 }, { -30, 30 })
        elseif name == "sandstorm" then
            atmosphere.Density = 0.6
            atmosphere.Haze = 3.5
            atmosphere.Color = Color3.fromRGB(190, 150, 90)
            configureEmitter("rbxasset://textures/particle.dds", Color3.fromRGB(200, 165, 100), 4, { 40, 70 }, 200, { 1, 2 }, { -10, 10 })
        end

        if statusLabel then
            statusLabel.Text = "Status: " .. name:upper()
        end
        addLog("[CLIMA] Aplicado: " .. name)
    end

    return {
        applyPreset = applyPreset,
    }
end

local Weather = buildWeatherFeature()

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

-- Reconstrói do zero (troca de idioma chama setupMenu() de novo) --
-- destrói a instância anterior antes de criar a nova.
local oldGui = playerGui:FindFirstChild("MegaRampHub")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MegaRampHub"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local TITLE_HEIGHT = 34
local SIDEBAR_WIDTH = 128

local frame = Instance.new("Frame")
frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
frame.BorderSizePixel = 0
frame.Position = lastFramePosition
frame.Draggable = true
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = screenGui

frame:GetPropertyChangedSignal("Position"):Connect(function()
    lastFramePosition = frame.Position
end)

local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(70, 120, 200)
outline.Thickness = 1
outline.Transparency = 0.3
outline.Parent = frame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, TITLE_HEIGHT)
titleBar.BackgroundColor3 = Color3.fromRGB(32, 34, 44)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(120, 190, 255)
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

local tabBar = Instance.new("ScrollingFrame")
tabBar.Size = UDim2.new(0, SIDEBAR_WIDTH, 1, 0)
tabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
tabBar.BorderSizePixel = 0
tabBar.ScrollBarThickness = 3
tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
tabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabBar.Parent = body

local tabBarLayout = Instance.new("UIListLayout")
tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabBarLayout.Padding = UDim.new(0, 2)
tabBarLayout.Parent = tabBar

local contentArea = Instance.new("Frame")
contentArea.Position = UDim2.new(0, SIDEBAR_WIDTH, 0, 0)
contentArea.Size = UDim2.new(1, -SIDEBAR_WIDTH, 1, 0)
contentArea.BackgroundTransparency = 1
contentArea.Parent = body

local TAB_DEFS = {
    { key = "ramp", labelKey = "tab_ramp" },
    { key = "games", labelKey = "tab_games" },
    { key = "cam", labelKey = "tab_cam" },
    { key = "car", labelKey = "tab_car" },
    { key = "props", labelKey = "tab_props" },
    { key = "esp", labelKey = "tab_esp" },
    { key = "anim", labelKey = "tab_anim" },
    { key = "webhook", labelKey = "tab_webhook" },
    { key = "players", labelKey = "tab_players" },
    { key = "slimes", labelKey = "tab_slimes" },
    { key = "spy", labelKey = "tab_spy" },
    { key = "settings", labelKey = "tab_settings" },
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
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
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
    lastSelectedTabKey = key
    for k, f in pairs(tabFrames) do
        f.Visible = (k == key)
    end
    for k, b in pairs(tabButtons) do
        local selected = (k == key)
        b.BackgroundColor3 = selected and Color3.fromRGB(40, 46, 60) or Color3.fromRGB(20, 20, 24)
        b.TextColor3 = selected and Color3.fromRGB(120, 190, 255) or Color3.fromRGB(190, 190, 190)
        local accent = b:FindFirstChild("Accent")
        if accent then accent.BackgroundTransparency = selected and 0 or 1 end
    end
end

for i, def in ipairs(TAB_DEFS) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(190, 190, 190)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = t(def.labelKey)
    btn.LayoutOrder = i
    btn.Parent = tabBar

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 14)
    padding.Parent = btn

    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    accent.BackgroundTransparency = 1
    accent.BorderSizePixel = 0
    accent.Parent = btn

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
    btn.Text = labelText
    btn.LayoutOrder = tabOrder(tab)
    btn.Parent = tab

    btn.MouseButton1Click:Connect(function()
        state.enabled = not state.enabled
        btn.BackgroundColor3 = state.enabled and Color3.fromRGB(0, 110, 60) or Color3.fromRGB(60, 60, 60)
    end)

    return state
end

-- --- ABA RAMP ---

local rampTab = tabFrames.ramp
addSectionLabel(rampTab, t("sec_ramp_cycle"), Color3.fromRGB(255, 140, 60))
local rampStartBtn, rampStopBtn = addTwoButtons(rampTab, t("start"), Color3.fromRGB(0, 150, 0), t("stop"), Color3.fromRGB(150, 0, 0))
local toggleAlertBtn = addButton(rampTab, t("btn_alert_rainbow"), Color3.fromRGB(150, 100, 0), 30)
local sellAllBtn = addButton(rampTab, t("btn_sell_all"), Color3.fromRGB(0, 150, 100), 34)

addSectionLabel(rampTab, t("lbl_checkpoint"), Color3.fromRGB(200, 200, 200))
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

rampStatusLabel = addFullLabel(rampTab, t("status_stopped"), Color3.fromRGB(100, 200, 100))
rampCountLabel = addFullLabel(rampTab, t("label_teleports_forced") .. "0", Color3.fromRGB(200, 200, 255))
rampCycleLabel = addFullLabel(rampTab, t("label_cycles_complete") .. "0", Color3.fromRGB(255, 200, 100))

local autoPauseToggleBtn = Instance.new("TextButton")
autoPauseToggleBtn.Size = UDim2.new(1, 0, 0, 26)
autoPauseToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 60)
autoPauseToggleBtn.TextColor3 = Color3.new(1, 1, 1)
autoPauseToggleBtn.TextSize = 11
autoPauseToggleBtn.Font = Enum.Font.GothamBold
autoPauseToggleBtn.Text = t("btn_auto_pause")
autoPauseToggleBtn.LayoutOrder = tabOrder(rampTab)
autoPauseToggleBtn.Parent = rampTab
autoPauseToggleBtn.MouseButton1Click:Connect(function()
    autoPauseConfig.enabled = not autoPauseConfig.enabled
    autoPauseToggleBtn.BackgroundColor3 = autoPauseConfig.enabled and Color3.fromRGB(0, 110, 60) or Color3.fromRGB(60, 60, 60)
end)

addInfoLabel(rampTab, "Ativa o evento mais caro, teleporta no JumpCar até acabar, vende tudo e repete sozinho até PARAR. Com a pausa automática LIGADA, os 3 loops (Ramp/Memória/Bata o Slime) pausam sozinhos se outro jogador entrar na sala e retomam quando ficar sozinho de novo. Desligada, eles ignoram outros jogadores e continuam rodando direto.")

rampStartBtn.MouseButton1Click:Connect(rampGuardedStart)
rampStopBtn.MouseButton1Click:Connect(rampGuardedStop)
toggleAlertBtn.MouseButton1Click:Connect(function()
    if alertKeywords[1] == "limitedrainbow" then
        alertKeywords = { "limited" }
        toggleAlertBtn.Text = t("btn_alert_all_limited")
    else
        alertKeywords = { "limitedrainbow" }
        toggleAlertBtn.Text = t("btn_alert_rainbow")
    end
end)
sellAllBtn.MouseButton1Click:Connect(function() autoSellAllSlimes() end)

addInfoLabel(rampTab, "O Mega Jump Insta (CarSpawn/JumpCar/Checkpoint92/LandingZone3 colapsados na posição do CarSpawn, com a FORÇA DO IMPULSO do JumpCar zerada e 3 cópias extras do Checkpoint92 em quadrado -- acima/abaixo/frente -- pra garantir o toque) agora liga e desliga JUNTO com esse ciclo: ativa sozinho ao clicar Iniciar e desativa sozinho ao Parar (ou quando pausa automaticamente por outro jogador entrar). 100% client-side -- só a SUA tela muda.")

-- --- ABA GAMES ---

local gamesTab = tabFrames.games
addSectionLabel(gamesTab, t("sec_memory"), Color3.fromRGB(0, 190, 100))
local memoryStartBtnUi, memoryStopBtnUi = addTwoButtons(gamesTab, t("play"), Color3.fromRGB(0, 150, 0), t("stop"), Color3.fromRGB(150, 0, 0))
memoryStatusLabel = addFullLabel(gamesTab, t("status_stopped"), Color3.fromRGB(100, 200, 100))
memoryCountLabel = addFullLabel(gamesTab, t("label_rounds") .. "0", Color3.fromRGB(200, 200, 255))

addDivider(gamesTab)

addSectionLabel(gamesTab, t("sec_hitslime"), Color3.fromRGB(0, 185, 235))
local secondsInput = addTextField(gamesTab, t("lbl_seconds_per_round"), hitSlimeConfig.secondsPerRound)
secondsInput.FocusLost:Connect(function()
    local val = tonumber(secondsInput.Text)
    if val and val >= 0 then
        hitSlimeConfig.secondsPerRound = val
    else
        secondsInput.Text = tostring(hitSlimeConfig.secondsPerRound)
    end
end)
local hitSlimeStartBtnUi, hitSlimeStopBtnUi = addTwoButtons(gamesTab, t("play"), Color3.fromRGB(0, 150, 0), t("stop"), Color3.fromRGB(150, 0, 0))
hitSlimeStatusLabel = addFullLabel(gamesTab, t("status_stopped"), Color3.fromRGB(100, 200, 100))
hitSlimeCountLabel = addFullLabel(gamesTab, t("label_rounds") .. "0", Color3.fromRGB(200, 200, 255))

addInfoLabel(gamesTab, "Memória joga de verdade. Bata o Slime é atalho por remote (~180s totais pra não cair no \"Too fast\"). Só existe UMA rodada ativa por vez no servidor. Os dois repetem sozinhos até PARAR e pausam se outro jogador entrar.")

memoryStartBtnUi.MouseButton1Click:Connect(memoryGuardedStart)
memoryStopBtnUi.MouseButton1Click:Connect(memoryGuardedStop)
hitSlimeStartBtnUi.MouseButton1Click:Connect(hitSlimeGuardedStart)
hitSlimeStopBtnUi.MouseButton1Click:Connect(hitSlimeGuardedStop)

-- --- ABA CAM ---

local camTab = tabFrames.cam
addSectionLabel(camTab, t("sec_freecam"), Color3.fromRGB(0, 150, 255))
local speedInput = addTextField(camTab, t("lbl_freecam_speed"), freecamConfig.baseSpeed)
speedInput.FocusLost:Connect(function()
    local val = tonumber(speedInput.Text)
    if val and val > 0 then
        freecamConfig.baseSpeed = val
    else
        speedInput.Text = tostring(freecamConfig.baseSpeed)
    end
end)
local camEnableBtn, camDisableBtn = addTwoButtons(camTab, t("enable"), Color3.fromRGB(0, 150, 0), t("disable"), Color3.fromRGB(150, 0, 0))
freecamStatusLabel = addFullLabel(camTab, t("status_inactive"), Color3.fromRGB(100, 200, 100))
addInfoLabel(camTab, "Botão direito + mover = olhar. WASD move, Space/Ctrl sobe e desce, Shift acelera. F5 liga/desliga a qualquer momento, em qualquer aba. Personagem fica ancorado (parado) enquanto ativo.")

camEnableBtn.MouseButton1Click:Connect(enableFreecam)
camDisableBtn.MouseButton1Click:Connect(disableFreecam)

-- --- ABA CARRO ---

local carTab = tabFrames.car
addSectionLabel(carTab, t("sec_car_boost"), Color3.fromRGB(0, 220, 220))

local carForceInput = addTextField(carTab, t("lbl_boost_force"), carBoostConfig.force)
carForceInput.FocusLost:Connect(function()
    local val = tonumber(carForceInput.Text)
    if val and val > 0 then
        carBoostConfig.force = val
    else
        carForceInput.Text = tostring(carBoostConfig.force)
    end
end)

local carToggleBtn = Instance.new("TextButton")
carToggleBtn.Size = UDim2.new(1, 0, 0, 30)
carToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
carToggleBtn.TextColor3 = Color3.new(1, 1, 1)
carToggleBtn.TextSize = 12
carToggleBtn.Font = Enum.Font.GothamBold
carToggleBtn.Text = t("btn_enable_boost")
carToggleBtn.LayoutOrder = tabOrder(carTab)
carToggleBtn.Parent = carTab
carToggleBtn.MouseButton1Click:Connect(function()
    carBoostConfig.enabled = not carBoostConfig.enabled
    carToggleBtn.BackgroundColor3 = carBoostConfig.enabled and Color3.fromRGB(0, 130, 60) or Color3.fromRGB(60, 60, 60)
end)

carStatusLabel = addFullLabel(carTab, t("status_off"), Color3.fromRGB(100, 200, 100))

addInfoLabel(carTab, "Com o impulso ATIVADO, segurar SHIFT empurra o carro pra frente com força extra a cada instante -- solta e para na hora, sem esperar desacelerar. Só funciona enquanto você está dentro do carro na pista. Ajuste a força se sentir fraco ou forte demais.")

addDivider(carTab)
addSectionLabel(carTab, t("sec_fly"), Color3.fromRGB(0, 220, 220))

local flyToggleBtn = Instance.new("TextButton")
flyToggleBtn.Size = UDim2.new(1, 0, 0, 30)
flyToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
flyToggleBtn.TextColor3 = Color3.new(1, 1, 1)
flyToggleBtn.TextSize = 12
flyToggleBtn.Font = Enum.Font.GothamBold
flyToggleBtn.Text = t("btn_fly_toggle")
flyToggleBtn.LayoutOrder = tabOrder(carTab)
flyToggleBtn.Parent = carTab
flyToggleBtn.MouseButton1Click:Connect(function()
    CarFly.toggle()
    flyToggleBtn.BackgroundColor3 = CarFly.config.active and Color3.fromRGB(0, 130, 60) or Color3.fromRGB(60, 60, 60)
end)

CarFly.setStatusLabel(addFullLabel(carTab, t("status_off"), Color3.fromRGB(100, 200, 100)))

addInfoLabel(carTab, "Desliga a colisão do carro inteiro e deixa você voar com ele (com você sentado dentro) usando WASD/Space/Ctrl relativo à câmera, igual o Free Cam -- Shift acelera. Precisa estar dentro do carro. Desativar devolve a colisão normal.")

addDivider(carTab)
addSectionLabel(carTab, t("sec_checkpoint_dup"), Color3.fromRGB(255, 140, 60))

local offsetZInput = addTextField(carTab, t("lbl_offset_z"), "10")
local dupCheckpointsBtn, clearDupCheckpointsBtn = addTwoButtons(carTab, t("btn_dup_checkpoints"), Color3.fromRGB(0, 150, 100), t("btn_clear_dup_checkpoints"), Color3.fromRGB(150, 0, 0))
dupCheckpointsBtn.MouseButton1Click:Connect(function()
    local offset = tonumber(offsetZInput.Text) or 10
    CheckpointDup.duplicateAll(offset)
end)
clearDupCheckpointsBtn.MouseButton1Click:Connect(function()
    CheckpointDup.clearAll()
end)

addInfoLabel(carTab, "Clona cada checkpoint da pasta Checkpoints com um deslocamento em Z e conecta um Touched próprio pra disparar o mesmo remote do jogo -- assim, passando pela pista duas vezes (original + cópia, com mais de 1s de intervalo) dispara o checkpoint de novo. Remover Duplicados apaga só as cópias criadas por aqui, sem mexer nos checkpoints originais do jogo.")

addDivider(carTab)
addSectionLabel(carTab, t("sec_checkpoint_extra"), Color3.fromRGB(255, 100, 220))

local extraCountInput = addTextField(carTab, t("lbl_extra_count"), "5")
local extraSpacingInput = addTextField(carTab, t("lbl_extra_spacing"), "15")
local createExtraBtn, autoTriggerExtraBtn = addTwoButtons(carTab, t("btn_create_extra"), Color3.fromRGB(150, 0, 150), t("btn_auto_trigger_extra"), Color3.fromRGB(0, 130, 150))

local lastCreatedCheckpoints = {}
createExtraBtn.MouseButton1Click:Connect(function()
    local count = math.clamp(tonumber(extraCountInput.Text) or 5, 1, 200)
    local spacing = tonumber(extraSpacingInput.Text) or 15
    lastCreatedCheckpoints = CheckpointDup.createBeyondMax(count, spacing)
end)
autoTriggerExtraBtn.MouseButton1Click:Connect(function()
    if #lastCreatedCheckpoints == 0 then
        addLog("[CHECKPOINT-DUP] [!] Crie os checkpoints extras antes de disparar")
        return
    end
    CheckpointDup.autoTriggerCreated(lastCreatedCheckpoints, 1.2)
end)

addInfoLabel(carTab, "Clona o checkpoint de maior número existente e cria N novos checkpoints em sequência (máximo+1, máximo+2, ...), já ligados no mesmo remote do jogo. Como o servidor só parece premiar quando o número sobe, isso testa se dá pra continuar ganhando além do checkpoint final da pista. Disparar Automaticamente teleporta seu personagem até cada um, esperando mais de 1s entre eles.")

-- --- ABA PROPS (LOCAL, SÓ PRA VOCÊ) ---

local propsTab = tabFrames.props
addSectionLabel(propsTab, t("sec_clone_map"), Color3.fromRGB(255, 180, 80))

local crosshairToggleBtn = Instance.new("TextButton")
crosshairToggleBtn.Size = UDim2.new(1, 0, 0, 26)
crosshairToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 60)
crosshairToggleBtn.TextColor3 = Color3.new(1, 1, 1)
crosshairToggleBtn.TextSize = 11
crosshairToggleBtn.Font = Enum.Font.GothamBold
crosshairToggleBtn.Text = t("btn_show_crosshair")
crosshairToggleBtn.LayoutOrder = tabOrder(propsTab)
crosshairToggleBtn.Parent = propsTab
crosshairToggleBtn.MouseButton1Click:Connect(function()
    Props.crosshairLabel.Visible = not Props.crosshairLabel.Visible
    crosshairToggleBtn.BackgroundColor3 = Props.crosshairLabel.Visible and Color3.fromRGB(0, 110, 60) or Color3.fromRGB(60, 60, 60)
end)

local cloneBtn = addButton(propsTab, t("btn_clone_looked"), Color3.fromRGB(150, 100, 0), 34)
cloneBtn.MouseButton1Click:Connect(function() Props.clone() end)

local propsDistanceInput = addTextField(propsTab, t("lbl_aim_distance"), Props.config.spawnDistance)
propsDistanceInput.FocusLost:Connect(function()
    local val = tonumber(propsDistanceInput.Text)
    if val and val > 0 then
        Props.config.spawnDistance = val
    else
        propsDistanceInput.Text = tostring(Props.config.spawnDistance)
    end
end)

addDivider(propsTab)
addSectionLabel(propsTab, t("sec_selected_object"), Color3.fromRGB(0, 200, 255))
Props.setStatusLabel(addFullLabel(propsTab, t("label_none_selected"), Color3.fromRGB(150, 150, 150)))

local selectModeBtn = addButton(propsTab, t("btn_select_mode"), Color3.fromRGB(60, 60, 60), 30)
selectModeBtn.MouseButton1Click:Connect(function()
    local enabled = Props.toggleSelectMode()
    selectModeBtn.BackgroundColor3 = enabled and Color3.fromRGB(0, 130, 60) or Color3.fromRGB(60, 60, 60)
end)

local carryBtn = addButton(propsTab, t("btn_carry"), Color3.fromRGB(90, 90, 200), 30)
carryBtn.MouseButton1Click:Connect(function() Props.toggleCarry() end)

local attachBtn = addButton(propsTab, t("btn_attach"), Color3.fromRGB(0, 150, 100), 30)
attachBtn.MouseButton1Click:Connect(function() Props.attach() end)

local detachBtn, anchorBtn = addTwoButtons(propsTab, t("btn_detach"), Color3.fromRGB(150, 100, 0), t("btn_toggle_anchor"), Color3.fromRGB(60, 60, 60))
detachBtn.MouseButton1Click:Connect(function() Props.detach() end)
anchorBtn.MouseButton1Click:Connect(function() Props.toggleAnchor() end)

local scaleDownBtn, scaleUpBtn = addTwoButtons(propsTab, t("btn_shrink"), Color3.fromRGB(60, 60, 60), t("btn_grow"), Color3.fromRGB(60, 60, 60))
scaleDownBtn.MouseButton1Click:Connect(function() Props.scale(0.8) end)
scaleUpBtn.MouseButton1Click:Connect(function() Props.scale(1.25) end)

local deleteBtn, clearAllBtn = addTwoButtons(propsTab, t("btn_delete"), Color3.fromRGB(150, 0, 0), t("btn_clear_all"), Color3.fromRGB(150, 0, 0))
deleteBtn.MouseButton1Click:Connect(function() Props.delete() end)
clearAllBtn.MouseButton1Click:Connect(function() Props.clearAll() end)

addInfoLabel(propsTab, "100% local -- SÓ VOCÊ VÊ as cópias, ninguém mais no servidor enxerga (LocalScript não tem canal de rede pra replicar isso). CLONAR duplica exatamente o objeto (ou o Model inteiro, se fizer parte de um) que estiver embaixo da flecha no centro da tela, dentro da distância configurada. MODO SELEÇÃO liga o clique-pra-selecionar num objeto já clonado; depois SEGURAR carrega ele na frente da câmera até clicar de novo pra soltar; GRUDAR cola ele fisicamente (WeldConstraint) no que estiver na mira -- útil pra grudar em algo que se move, tipo um carro.")

addDivider(propsTab)
addSectionLabel(propsTab, t("sec_time_of_day"), Color3.fromRGB(150, 170, 255))

local timeToggleBtn = Instance.new("TextButton")
timeToggleBtn.Size = UDim2.new(1, 0, 0, 28)
timeToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
timeToggleBtn.TextColor3 = Color3.new(1, 1, 1)
timeToggleBtn.TextSize = 11
timeToggleBtn.Font = Enum.Font.GothamBold
timeToggleBtn.Text = t("btn_keep_fixed")
timeToggleBtn.LayoutOrder = tabOrder(propsTab)
timeToggleBtn.Parent = propsTab
timeToggleBtn.MouseButton1Click:Connect(function()
    timeOfDayConfig.enabled = not timeOfDayConfig.enabled
    timeToggleBtn.BackgroundColor3 = timeOfDayConfig.enabled and Color3.fromRGB(0, 110, 60) or Color3.fromRGB(60, 60, 60)
    if timeOfDayConfig.enabled then applyTimeOfDay() end
end)

local dawnBtn, dayBtn = addTwoButtons(propsTab, t("btn_dawn"), Color3.fromRGB(255, 170, 100), t("btn_day"), Color3.fromRGB(255, 210, 80))
local duskBtn, nightBtn = addTwoButtons(propsTab, t("btn_dusk"), Color3.fromRGB(230, 120, 60), t("btn_night"), Color3.fromRGB(40, 50, 90))

local timeInput = addTextField(propsTab, t("lbl_exact_hour"), timeOfDayConfig.clockTime)
timeInput.FocusLost:Connect(function()
    local val = tonumber(timeInput.Text)
    if val and val >= 0 and val <= 24 then
        timeOfDayConfig.clockTime = val
        timeOfDayConfig.enabled = true
        timeToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 60)
        applyTimeOfDay()
    else
        timeInput.Text = tostring(timeOfDayConfig.clockTime)
    end
end)

local function setTimePreset(hour)
    timeOfDayConfig.clockTime = hour
    timeOfDayConfig.enabled = true
    timeToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 60)
    timeInput.Text = tostring(hour)
    applyTimeOfDay()
end

dawnBtn.MouseButton1Click:Connect(function() setTimePreset(6) end)
dayBtn.MouseButton1Click:Connect(function() setTimePreset(12) end)
duskBtn.MouseButton1Click:Connect(function() setTimePreset(18) end)
nightBtn.MouseButton1Click:Connect(function() setTimePreset(0) end)

addDivider(propsTab)
addSectionLabel(propsTab, t("sec_weather"), Color3.fromRGB(120, 200, 255))

local weatherStatusLabel = addFullLabel(propsTab, "Status: CLEAR", Color3.fromRGB(100, 200, 100))

local weatherClearBtn, weatherRainBtn = addTwoButtons(propsTab, t("btn_weather_clear"), Color3.fromRGB(60, 60, 60), t("btn_weather_rain"), Color3.fromRGB(0, 110, 180))
local weatherStormBtn, weatherFogBtn = addTwoButtons(propsTab, t("btn_weather_storm"), Color3.fromRGB(70, 70, 90), t("btn_weather_fog"), Color3.fromRGB(140, 140, 145))
local weatherSnowBtn, weatherSandBtn = addTwoButtons(propsTab, t("btn_weather_snow"), Color3.fromRGB(150, 180, 220), t("btn_weather_sandstorm"), Color3.fromRGB(180, 140, 80))

weatherClearBtn.MouseButton1Click:Connect(function() Weather.applyPreset("clear", weatherStatusLabel) end)
weatherRainBtn.MouseButton1Click:Connect(function() Weather.applyPreset("rain", weatherStatusLabel) end)
weatherStormBtn.MouseButton1Click:Connect(function() Weather.applyPreset("storm", weatherStatusLabel) end)
weatherFogBtn.MouseButton1Click:Connect(function() Weather.applyPreset("fog", weatherStatusLabel) end)
weatherSnowBtn.MouseButton1Click:Connect(function() Weather.applyPreset("snow", weatherStatusLabel) end)
weatherSandBtn.MouseButton1Click:Connect(function() Weather.applyPreset("sandstorm", weatherStatusLabel) end)

addInfoLabel(propsTab, "O jogo não tem clima nenhum de verdade (sem chuva/neve/neblina no código) -- isso aqui é construído do zero, 100% visual e só na SUA tela: Atmosphere pra névoa/densidade, partículas presas numa part que segue sua câmera pra chuva/neve/areia, e na Tempestade ainda entra um flash + som de trovão de vez em quando. Limpo volta tudo ao normal.")

-- --- ABA ESP ---

local espTab = tabFrames.esp
addSectionLabel(espTab, t("sec_esp"), Color3.fromRGB(255, 60, 60))
local espEnableBtn, espDisableBtn = addTwoButtons(espTab, t("enable"), Color3.fromRGB(0, 150, 0), t("disable"), Color3.fromRGB(150, 0, 0))
espStatusLabel = addFullLabel(espTab, t("status_inactive"), Color3.fromRGB(100, 200, 100))
local espDistanceInput = addTextField(espTab, t("lbl_esp_distance"), espConfig.maxDistance)
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
addSectionLabel(animTab, t("sec_anim_idle"), Color3.fromRGB(255, 200, 0))

local idleBox = addTextField(animTab, t("lbl_idle_id"), animConfig.idleId)
idleBox.FocusLost:Connect(function() animConfig.idleId = idleBox.Text end)

local captureBtn = addButton(animTab, t("btn_capture_anim"), Color3.fromRGB(90, 90, 200), 32)
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

local diagBtn = addButton(animTab, t("btn_diagnose"), Color3.fromRGB(150, 100, 0), 32)
diagBtn.MouseButton1Click:Connect(function() debugAnimateStructure() end)

local animToggleBtn = Instance.new("TextButton")
animToggleBtn.Size = UDim2.new(1, 0, 0, 30)
animToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
animToggleBtn.TextColor3 = Color3.new(1, 1, 1)
animToggleBtn.TextSize = 12
animToggleBtn.Font = Enum.Font.GothamBold
animToggleBtn.Text = t("btn_apply_idle")
animToggleBtn.LayoutOrder = tabOrder(animTab)
animToggleBtn.Parent = animTab
animToggleBtn.MouseButton1Click:Connect(function()
    animConfig.enabled = not animConfig.enabled
    animToggleBtn.BackgroundColor3 = animConfig.enabled and Color3.fromRGB(0, 130, 60) or Color3.fromRGB(60, 60, 60)
    if animConfig.enabled then applyForcedIdle() end
end)

local animReapplyBtn = addButton(animTab, t("btn_reapply"), Color3.fromRGB(90, 90, 200), 32)
animReapplyBtn.MouseButton1Click:Connect(function()
    animConfig.enabled = true
    animToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 60)
    applyForcedIdle()
end)

addInfoLabel(animTab, "IDLE toca separado (prioridade alta, sem reiniciar sozinho) e só fica ativo enquanto você tá parado -- solta na hora que anda/corre/pula, então não briga com o jogo. ANDAR/CORRER voltaram a ser 100% do jogo (sem forçação). Não precisa caçar o ID: toque o emote/animação que você já tem e clique CAPTURAR pra preencher o IDLE sozinho. Só funciona com animações que você tem direito de usar -- é permissão do próprio Roblox no ID. Reaplica sozinho se você morrer/respawnar.")

-- --- ABA WEBHOOK ---

local webhookTab = tabFrames.webhook
addSectionLabel(webhookTab, t("sec_discord_webhook"), Color3.fromRGB(114, 137, 218))
local webhookUrlBox = addTextField(webhookTab, t("lbl_webhook_url"), "")
webhookUrlBox.FocusLost:Connect(function()
    webhookConfig.url = webhookUrlBox.Text
end)
local webhookTestBtn = addButton(webhookTab, t("btn_test"), Color3.fromRGB(90, 90, 200), 32)
webhookTestBtn.MouseButton1Click:Connect(function()
    webhookConfig.url = webhookUrlBox.Text
    sendDiscordWebhook("✅ Teste", "Webhook configurado com sucesso no MEGA RAMP HUB!", Color3.fromRGB(0, 190, 100))
end)

addDivider(webhookTab)
addSectionLabel(webhookTab, t("sec_notify_when"), Color3.fromRGB(200, 200, 200))
webhookToggles.limited = addToggleRow(webhookTab, t("toggle_find_limited"), true)
webhookToggles.memory = addToggleRow(webhookTab, t("toggle_win_memory"), false)
webhookToggles.hitslime = addToggleRow(webhookTab, t("toggle_win_hitslime"), false)
webhookToggles.event = addToggleRow(webhookTab, t("toggle_activate_event"), false)

addInfoLabel(webhookTab, "Precisa que o executor suporte request/http_request/syn.request pra funcionar. Clique TESTAR pra confirmar que o link tá certo.")

-- --- ABA JOGADORES ---

local playersTab = tabFrames.players
addSectionLabel(playersTab, t("sec_players_in_match"), Color3.fromRGB(0, 150, 255))
playersStatusLabel = addFullLabel(playersTab, t("status_none_normal_cam"), Color3.fromRGB(100, 200, 100))
local stopSpectateBtnUi = addButton(playersTab, t("btn_stop_spectate"), Color3.fromRGB(150, 0, 0), 32)
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
            specBtn.Text = t("btn_spectate")
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
        emptyLbl.Text = t("lbl_no_other_players")
        emptyLbl.LayoutOrder = 1
        emptyLbl.Parent = rowsContainer
    end
end

Players.PlayerAdded:Connect(function() task.wait(0.1) rebuildPlayerRows() end)
Players.PlayerRemoving:Connect(function() task.wait(0.15) rebuildPlayerRows() end)

rebuildPlayerRows()

addDivider(playersTab)
addSectionLabel(playersTab, t("sec_top5"), Color3.fromRGB(255, 215, 0))
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
        emptyLbl.Text = t("lbl_waiting_server")
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

-- --- ABA SLIMES: equipar por índice + gift ---

local slimesTab = tabFrames.slimes
addSectionLabel(slimesTab, t("sec_equip_by_index"), Color3.fromRGB(0, 190, 100))
addInfoLabel(slimesTab, "Cada slime do inventário tem um índice (posição na lista que o jogo já manda pro client). Clicar EQUIPAR na lista abaixo dispara o MESMO remote que o botão do inventário do jogo dispara -- só que direto, sem precisar abrir a UI. Sobre prever o item da caixa (limited/rainbow etc): não dá -- o resultado é sorteado 100% no servidor e só chega pro client DEPOIS de decidido, sem nenhuma seed/prévia vazando antes. Isso aqui só funciona porque o jogo já deixa o client escolher livremente qual slime equipar/doar -- a raridade da caixa não passa por esse mesmo caminho.")

local slimesRowsContainer = Instance.new("Frame")
slimesRowsContainer.Size = UDim2.new(1, 0, 0, 0)
slimesRowsContainer.AutomaticSize = Enum.AutomaticSize.Y
slimesRowsContainer.BackgroundTransparency = 1
slimesRowsContainer.LayoutOrder = tabOrder(slimesTab)
slimesRowsContainer.Parent = slimesTab

local slimesRowsLayout = Instance.new("UIListLayout")
slimesRowsLayout.SortOrder = Enum.SortOrder.LayoutOrder
slimesRowsLayout.Padding = UDim.new(0, 3)
slimesRowsLayout.Parent = slimesRowsContainer

refreshInventoryUI = function()
    for _, child in ipairs(slimesRowsContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local list = latestInventoryList or {}
    if #list == 0 then
        local emptyLbl = Instance.new("TextLabel")
        emptyLbl.Size = UDim2.new(1, 0, 0, 20)
        emptyLbl.BackgroundTransparency = 1
        emptyLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
        emptyLbl.TextSize = 10
        emptyLbl.Font = Enum.Font.Gotham
        emptyLbl.Text = t("lbl_waiting_inventory")
        emptyLbl.LayoutOrder = 1
        emptyLbl.Parent = slimesRowsContainer
        return
    end

    for i, item in ipairs(list) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 26)
        row.BackgroundColor3 = (latestEquippedIndex == i) and Color3.fromRGB(0, 90, 50) or Color3.fromRGB(40, 40, 40)
        row.LayoutOrder = i
        row.Parent = slimesRowsContainer

        local itemName = tostring(item.Name or item.Rarity or "?")
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.75, -6, 1, 0)
        lbl.Position = UDim2.new(0, 6, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.TextSize = 10
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = "#" .. i .. " " .. itemName .. " (Lv" .. tostring(item.Level or 1) .. ", $" .. tostring(item.Income or 0) .. "/s)"
        lbl.Parent = row

        local eqBtn = Instance.new("TextButton")
        eqBtn.Size = UDim2.new(0.25, -6, 1, -4)
        eqBtn.Position = UDim2.new(0.75, 0, 0, 2)
        eqBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        eqBtn.TextColor3 = Color3.new(1, 1, 1)
        eqBtn.TextSize = 10
        eqBtn.Font = Enum.Font.GothamBold
        eqBtn.Text = (latestEquippedIndex == i) and t("lbl_equipped") or t("lbl_equip")
        eqBtn.Parent = row

        eqBtn.MouseButton1Click:Connect(function()
            equipSlimeByIndex(i)
        end)
    end
end

refreshInventoryUI()

addDivider(slimesTab)
addSectionLabel(slimesTab, t("sec_manual_equip"), Color3.fromRGB(200, 200, 200))
local manualIndexBox = addTextField(slimesTab, t("lbl_index_manual"), "0")
local manualEquipBtn = addButton(slimesTab, t("btn_equip_index"), Color3.fromRGB(0, 120, 200), 32)
manualEquipBtn.MouseButton1Click:Connect(function()
    local idx = tonumber(manualIndexBox.Text)
    if idx then
        equipSlimeByIndex(math.floor(idx))
    else
        addLog("[SLIMES] [!] Índice inválido")
    end
end)

addDivider(slimesTab)
addSectionLabel(slimesTab, t("sec_send_gift"), Color3.fromRGB(255, 140, 220))
local giftPlayerBox = addTextField(slimesTab, t("lbl_gift_target"), "")
local giftIndexBox = addTextField(slimesTab, t("lbl_gift_index"), "0")
local giftSendBtn = addButton(slimesTab, t("btn_send_gift"), Color3.fromRGB(200, 60, 160), 32)
giftSendBtn.MouseButton1Click:Connect(function()
    local target = findPlayerByNameFragment(giftPlayerBox.Text)
    local idx = tonumber(giftIndexBox.Text)
    if not target then
        addLog("[GIFT] [!] Jogador não encontrado: " .. tostring(giftPlayerBox.Text))
        return
    end
    if not idx then
        addLog("[GIFT] [!] Índice inválido")
        return
    end
    sendGiftByIndex(target, math.floor(idx))
end)
addInfoLabel(slimesTab, "GiftAction:FireServer(\"RequestGift\", jogador, índice) é o MESMO remote que o prompt \"Gift Slime\" dispara ao lado de outro jogador -- pode ser que o servidor exija estar fisicamente perto do prompt dele antes de aceitar; se não funcionar de longe, é o servidor validando distância (bom sinal de segurança).")

-- --- ABA REMOTE SPY ---

local spyTab = tabFrames.spy
addSectionLabel(spyTab, t("sec_remote_spy"), Color3.fromRGB(255, 90, 90))

local spyToggleBtn = Instance.new("TextButton")
spyToggleBtn.Size = UDim2.new(1, 0, 0, 30)
spyToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
spyToggleBtn.TextColor3 = Color3.new(1, 1, 1)
spyToggleBtn.TextSize = 12
spyToggleBtn.Font = Enum.Font.GothamBold
spyToggleBtn.Text = t("btn_spy_enable")
spyToggleBtn.LayoutOrder = tabOrder(spyTab)
spyToggleBtn.Parent = spyTab
spyToggleBtn.MouseButton1Click:Connect(function()
    if RemoteSpy.isEnabled() then
        RemoteSpy.disable()
        spyToggleBtn.Text = t("btn_spy_enable")
        spyToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    else
        local outgoingOk = RemoteSpy.enable()
        spyToggleBtn.Text = t("btn_spy_disable")
        spyToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 60)
        if not outgoingOk then
            addLog("[SPY] [!] hookmetamethod indisponível nesse executor -- só logs de entrada (OnClientEvent) vão aparecer")
        end
    end
end)

local spyCopyBtn, spyClearBtn = addTwoButtons(spyTab, t("btn_spy_copy"), Color3.fromRGB(90, 90, 200), t("btn_spy_clear"), Color3.fromRGB(150, 0, 0))
spyCopyBtn.MouseButton1Click:Connect(function()
    local text = RemoteSpy.getLogText()
    if typeof(setclipboard) == "function" then
        local ok = pcall(setclipboard, text)
        addLog(ok and "[SPY] Log copiado pro clipboard!" or "[SPY] [!] setclipboard falhou -- veja no console")
    else
        addLog("[SPY] [!] Esse executor não suporta setclipboard -- veja no console mesmo")
    end
end)
spyClearBtn.MouseButton1Click:Connect(function()
    RemoteSpy.clear()
end)

addInfoLabel(spyTab, "OUT = o que SAI do seu client pro servidor (FireServer/InvokeServer) -- inclui chamadas feitas pelo PRÓPRIO JOGO, não só as do hub. IN = o que o servidor manda de volta (OnClientEvent). Mostra as últimas 200 linhas; o log completo também vai pro console (F9). Precisa de hookmetamethod pra ver o OUT -- se o executor não suportar, só o IN aparece (ainda útil pra ver o formato dos dados que o jogo recebe).")

local spyLogLabel = Instance.new("TextLabel")
spyLogLabel.Size = UDim2.new(1, 0, 0, 0)
spyLogLabel.AutomaticSize = Enum.AutomaticSize.Y
spyLogLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
spyLogLabel.TextColor3 = Color3.fromRGB(0, 230, 120)
spyLogLabel.TextSize = 9
spyLogLabel.Font = Enum.Font.Code
spyLogLabel.TextWrapped = true
spyLogLabel.TextXAlignment = Enum.TextXAlignment.Left
spyLogLabel.TextYAlignment = Enum.TextYAlignment.Top
spyLogLabel.Text = ""
spyLogLabel.LayoutOrder = tabOrder(spyTab)
spyLogLabel.Parent = spyTab

local spyPadding = Instance.new("UIPadding")
spyPadding.PaddingLeft = UDim.new(0, 6)
spyPadding.PaddingRight = UDim.new(0, 6)
spyPadding.PaddingTop = UDim.new(0, 6)
spyPadding.PaddingBottom = UDim.new(0, 6)
spyPadding.Parent = spyLogLabel

RemoteSpy.setRefreshCallback(function()
    local text = RemoteSpy.getLogText()
    spyLogLabel.Text = (text ~= "" and text) or "(vazio -- ative o Spy e vá jogar normalmente pra ver as chamadas aparecerem aqui)"
end)
spyLogLabel.Text = "(vazio -- ative o Spy e vá jogar normalmente pra ver as chamadas aparecerem aqui)"

addDivider(spyTab)
addSectionLabel(spyTab, t("sec_function_spy"), Color3.fromRGB(255, 180, 60))

local captureFnBtn, callFnBtn = addTwoButtons(spyTab, t("btn_capture_fn"), Color3.fromRGB(150, 100, 0), t("btn_call_fn"), Color3.fromRGB(0, 130, 150))
captureFnBtn.MouseButton1Click:Connect(function()
    FunctionSpy.capture()
end)
callFnBtn.MouseButton1Click:Connect(function()
    FunctionSpy.callWithCar()
end)

addInfoLabel(spyTab, "O 'Checkpoint UI: 48 x6000...' que aparece no console não vem de um Touched físico -- é o sistema de sorte da rampa, guiado 100% pelo remote CheckpointLuckUpdate. Por isso Capturar tenta primeiro getconnections nesse remote (e em JumpLuckStart/JumpLuckEnd), igual o SimpleSpy faz, e só cai pro Touched dos checkpoints antigos como último recurso. Captura a função REAL do jogo (sem reimplementar nada) e copia um relatório completo pro clipboard. Se capturou de um remote, essa função recebe (isJackpot, luckValue) do SERVIDOR -- Chamar testa ela com um valor gigante só pra ver o que ela faz LOCALMENTE (não manda nada pro servidor por conta própria); se veio de um Touched, chama passando o carro. Resultado sempre vai pro clipboard.")

-- --- ABA CONFIGURACOES ---

local settingsTab = tabFrames.settings
addSectionLabel(settingsTab, t("settings_title"), Color3.fromRGB(120, 190, 255))

local langPtBtn = addButton(settingsTab, "Portugues", Color3.fromRGB(60, 60, 60), 32)
local langEnBtn = addButton(settingsTab, "English", Color3.fromRGB(60, 60, 60), 32)
local langEsBtn = addButton(settingsTab, "Espanol", Color3.fromRGB(60, 60, 60), 32)

local langButtons = { pt = langPtBtn, en = langEnBtn, es = langEsBtn }

local function refreshLangButtons()
    for lang, btn in pairs(langButtons) do
        btn.BackgroundColor3 = (Language.current == lang) and Color3.fromRGB(0, 110, 60) or Color3.fromRGB(60, 60, 60)
    end
end
refreshLangButtons()

local function setLanguage(lang)
    Language.current = lang
    addLog("[CONFIG] Idioma definido: " .. lang .. ", reconstruindo o menu...")
    lastSelectedTabKey = "settings"
    setupMenu()
end

langPtBtn.MouseButton1Click:Connect(function() setLanguage("pt") end)
langEnBtn.MouseButton1Click:Connect(function() setLanguage("en") end)
langEsBtn.MouseButton1Click:Connect(function() setLanguage("es") end)

addInfoLabel(settingsTab, t("settings_info"))

-- --- RESPONSIVO + MINIMIZAR ---

local MIN_W, MAX_W = 380, 480
local MIN_H, MAX_H = 340, 580

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

selectTab(lastSelectedTabKey)

addLog("Hub carregado. Use as abas pra navegar. F5 liga/desliga a Free Cam a qualquer momento.")
print("[+] MEGA RAMP HUB carregado!")

end

setupMenu()
