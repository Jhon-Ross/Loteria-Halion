local webhook_loteria = "SUA_WEBHOOK_AQUI"
local valorBilhete = 1000
local percentualGanhador = 0.10
local percentualPrefeitura = 0.90

-- Gera token aleatório de 4 caracteres
function gerarToken()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local token = ""
    for i = 1, 4 do
        token = token .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return token
end

-- Criação automática do novo ciclo
function iniciarNovoCiclo()
    -- Verifica se já existe ciclo aberto
    local cicloAberto = exports.ghmattimysql:executeSync("SELECT id FROM vrp_lottery_cycles WHERE status = 'open'", {})
    if #cicloAberto > 0 then return end

    -- Inicia transação
    exports.ghmattimysql:execute("START TRANSACTION")
    
    local success, error = pcall(function()
        exports.ghmattimysql:execute("INSERT INTO vrp_lottery_cycles (start_date, end_date, draw_date, status, total_amount, prize_amount) VALUES (NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), NULL, 'open', 0, 0)", {})
    end)

    if success then
        exports.ghmattimysql:execute("COMMIT")
    else
        exports.ghmattimysql:execute("ROLLBACK")
        print("Erro ao iniciar novo ciclo:", error)
    end
end

-- Encerra o ciclo atual e realiza o sorteio
function sortearBilhete()
    -- Inicia transação
    exports.ghmattimysql:execute("START TRANSACTION")

    local success, error = pcall(function()
        local cicloAtual = exports.ghmattimysql:executeSync("SELECT * FROM vrp_lottery_cycles WHERE status = 'open' LIMIT 1", {})
        if #cicloAtual == 0 then return end

        local ciclo = cicloAtual[1]
        local bilhetes = exports.ghmattimysql:executeSync("SELECT * FROM vrp_lottery_tickets WHERE cycle_id = @cycle_id", {
            ['@cycle_id'] = ciclo.id
        })

        if #bilhetes == 0 then
            exports.ghmattimysql:execute("UPDATE vrp_lottery_cycles SET status = 'closed', draw_date = NOW() WHERE id = @id", {
                ['@id'] = ciclo.id
            })
            iniciarNovoCiclo()
            return
        end

        local vencedor = bilhetes[math.random(#bilhetes)]
        local totalArrecadado = #bilhetes * valorBilhete
        local premio = math.floor(totalArrecadado * percentualGanhador)
        local restante = totalArrecadado - premio

        if premio <= 0 then
            error("Valor do prêmio inválido")
        end

        -- Atualiza ciclo e registra sorteio
        exports.ghmattimysql:execute("UPDATE vrp_lottery_cycles SET status = 'drawn', draw_date = NOW(), winner_id = @winner_id, total_amount = @total, prize_amount = @premio WHERE id = @id", {
            ['@winner_id'] = vencedor.user_id,
            ['@total'] = totalArrecadado,
            ['@premio'] = premio,
            ['@id'] = ciclo.id
        })

        exports.ghmattimysql:execute("INSERT INTO vrp_lottery_draws (draw_date, ticket_id, cycle_id, winner_id, prize_amount) VALUES (NOW(), @ticket_id, @cycle_id, @winner_id, @prize_amount)", {
            ['@ticket_id'] = vencedor.id,
            ['@cycle_id'] = ciclo.id,
            ['@winner_id'] = vencedor.user_id,
            ['@prize_amount'] = premio
        })

        -- Deposita o prêmio para o ganhador
        local srcWinner = vRP.getUserSource(vencedor.user_id)
        if srcWinner then
            vRP.giveBankMoney(srcWinner, premio)
        else
            vRP.setBankMoney(vencedor.user_id, vRP.getBankMoney(vencedor.user_id) + premio)
        end

        -- Deposita para o prefeito (ID 1)
        local srcPrefeito = vRP.getUserSource(1)
        if srcPrefeito then
            vRP.giveBankMoney(srcPrefeito, restante)
        else
            vRP.setBankMoney(1, vRP.getBankMoney(1) + restante)
        end

        -- Webhook Discord
        local nome = GetPlayerName(srcWinner or 0) or "Offline"
        PerformHttpRequest(webhook_loteria, function() end, "POST", json.encode({
            username = "Loteria Halion",
            embeds = { {
                title = "🎉 Sorteio da Loteria Finalizado!",
                description = "**Vencedor:** " .. nome ..
                            "\n**ID:** " .. vencedor.user_id ..
                            "\n**Token:** " .. vencedor.token ..
                            "\n**Prêmio:** R$" .. premio ..
                            "\n**Total Arrecadado:** R$" .. totalArrecadado ..
                            "\n**Prefeitura recebeu:** R$" .. restante,
                color = 65280,
                footer = { text = "Halion City - Loteria" },
                timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
            }}
        }), { ["Content-Type"] = "application/json" })

        -- Limpa bilhetes do ciclo atual
        exports.ghmattimysql:execute("DELETE FROM vrp_lottery_tickets WHERE cycle_id = @cycle_id", {
            ['@cycle_id'] = ciclo.id
        })

        -- Faz backup dos dados do sorteio
        exports.ghmattimysql:execute("INSERT INTO vrp_lottery_backup SELECT * FROM vrp_lottery_draws WHERE draw_date < DATE_SUB(NOW(), INTERVAL 30 DAY)")

        iniciarNovoCiclo()
    end)

    if success then
        exports.ghmattimysql:execute("COMMIT")
    else
        exports.ghmattimysql:execute("ROLLBACK")
        print("Erro no sorteio:", error)
    end
end

-- Compra de bilhete
RegisterNetEvent("halion_loteria:comprarBilhete")
AddEventHandler("halion_loteria:comprarBilhete", function()
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end

    -- Verifica se o usuário existe
    local userExists = exports.ghmattimysql:executeSync("SELECT id FROM vrp_users WHERE id = @user_id", {
        ["@user_id"] = user_id
    })
    if #userExists == 0 then
        TriggerClientEvent("Notify", source, "negado", "Usuário não encontrado.")
        return
    end

    -- Verifica saldo do jogador
    local bankMoney = vRP.getBankMoney(user_id)
    if bankMoney < valorBilhete then
        TriggerClientEvent("Notify", source, "negado", "Saldo insuficiente.")
        return
    end

    local ciclo = exports.ghmattimysql:executeSync("SELECT id FROM vrp_lottery_cycles WHERE status = 'open' LIMIT 1", {})
    if #ciclo == 0 then
        TriggerClientEvent("Notify", source, "negado", "Nenhum ciclo ativo no momento.")
        return
    end

    -- Inicia transação
    exports.ghmattimysql:execute("START TRANSACTION")

    local success, error = pcall(function()
        -- Gera token único
        local token
        repeat
            token = gerarToken()
            local tokenExistente = exports.ghmattimysql:executeSync("SELECT id FROM vrp_lottery_tickets WHERE token = @token", {
                ["@token"] = token
            })
        until #tokenExistente == 0

        -- Insere bilhete
        exports.ghmattimysql:execute("INSERT INTO vrp_lottery_tickets (user_id, token, cycle_id, purchase_date) VALUES (@user_id, @token, @cycle_id, NOW())", {
            ["@user_id"] = user_id,
            ["@token"] = token,
            ["@cycle_id"] = ciclo[1].id
        })

        -- Debita valor do jogador
        vRP.tryBankPayment(user_id, valorBilhete)
    end)

    if success then
        exports.ghmattimysql:execute("COMMIT")
        TriggerClientEvent("Notify", source, "sucesso", "Bilhete comprado! Token: " .. token)
    else
        exports.ghmattimysql:execute("ROLLBACK")
        TriggerClientEvent("Notify", source, "negado", "Erro ao comprar bilhete.")
        print("Erro na compra do bilhete:", error)
    end
end)

-- Agendamento automático
Citizen.CreateThread(function()
    while true do
        local hora = os.date("%H:%M")
        if hora == "12:00" then
            sortearBilhete()
        end
        Wait(60000) -- checa a cada minuto
    end
end)
