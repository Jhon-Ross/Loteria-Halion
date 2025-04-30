Config = {}

-- Configurações de Valores Monetários
Config.ValorBilhete = 1000
Config.PercentualGanhador = 0.10 -- 10%
Config.PercentualPrefeitura = 0.90 -- 90%

-- Configurações de Tempo
Config.DuracaoCiclo = 24 -- horas
Config.HorarioSorteio = 12 -- 12:00
Config.IntervaloVerificacao = 3000 -- 50 minutos em segundos (50 * 60 = 3000)

-- Configurações de Integração
Config.WebhookDiscord = "https://discord.com/api/webhooks/1367114695638646884/iIQ4U-2OVRsrXodXyv8w3c09md5NIBAvToyuEM2GOCowEAusbZvrh2Pp3lF4TqvxGVRG"
Config.PermissaoAdmin = "admin.permissao"

-- Configurações de Interface
--[[
Config.Textos = {
    Titulo = "Loteria Halion City",
    SubTitulo = "Compre seu bilhete e boa sorte!",
    BotaoComprar = "Comprar Bilhete",
    BotaoFechar = "Fechar",
    MensagemSucesso = "Bilhete comprado com sucesso!",
    MensagemErro = "Erro ao comprar bilhete.",
    SemSaldo = "Saldo insuficiente.",
    LimiteAtingido = "Limite de bilhetes atingido."
}
]]

-- Configurações de NPC
Config.NPC = {
    Posicao = {
        x = -1079.31,
        y = -244.39,
        z = 37.77,
        h = 201.04
    },
    Modelo = {
        hash = GetHashKey('a_f_y_business_04'),
        nome = "a_f_y_business_04"
    },
    Blip = {
        id = 304,
        cor = 1,
        escala = 0.7,
        nome = "Loteria"
    }
}

-- Configurações de Segurança
Config.Validacoes = {
    SaldoMinimo = Config.ValorBilhete,
    IntervaloTransacoes = 1000, -- ms
    MaxTentativasToken = 10
}

-- Configurações de Backup
Config.Backup = {
    Ativo = true,
    Intervalo = 24, -- horas
    Retencao = 30 -- dias
}

-- Configurações de Notificações
Config.Notificacoes = {
    Sucesso = {
        Tipo = "success",
        Tempo = 5000
    },
    Erro = {
        Tipo = "error",
        Tempo = 5000
    },
    Negado = {
        Tipo = "negado",
        Tempo = 5000
    },
    Info = {
        Tipo = "info",
        Tempo = 3000
    }
}