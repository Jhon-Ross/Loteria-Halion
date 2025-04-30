# Backend da Loteria - Halion City

## Visão Geral
Sistema de loteria automatizado para servidor FiveM GTARP. O backend gerencia ciclos de sorteio, compra de bilhetes, sorteios e distribuição de prêmios.

## Configuração Inicial

```lua
local webhook_loteria = "SUA_WEBHOOK_AQUI"
local valorBilhete = 1000
local percentualGanhador = 0.10
local percentualPrefeitura = 0.90
```

## Estrutura do Código

### Funções Principais

1. **gerarToken()**
   - Gera token único de 4 caracteres alfanuméricos
   - Usa caracteres de A-Z e 0-9
   - Implementa validação de unicidade
   - Loop de tentativas até encontrar token válido

2. **iniciarNovoCiclo()**
   - Cria novo ciclo de loteria
   - Duração: 24 horas
   - Inicializa valores monetários em 0
   - Verifica existência de ciclo aberto
   - Usa transações para garantir integridade

3. **sortearBilhete()**
   - Realiza o sorteio do ciclo atual
   - Calcula prêmios (10% para ganhador, 90% para prefeitura)
   - Registra resultado no banco de dados
   - Notifica via Discord
   - Inicia novo ciclo
   - Implementa backup automático
   - Usa transações para segurança

4. **Evento: halion_loteria:comprarBilhete**
   - Gerencia compra de bilhetes
   - Valida token único
   - Verifica saldo do jogador
   - Valida existência do usuário
   - Registra compra no banco
   - Usa transações para segurança

## Agendamento

- Verificação automática a cada minuto
- Sorteio diário às 12:00
- Backup automático de dados antigos
- Retenção de 30 dias de histórico

## Integrações

1. **Banco de Dados**
   - Usa ghmattimysql
   - Tabelas: vrp_lottery_tickets, vrp_lottery_cycles, vrp_lottery_draws
   - Backup automático para vrp_lottery_backup
   - Transações para operações críticas
   - Rollback automático em caso de erro

2. **Sistema de Economia**
   - Integra com vRP
   - Deposita prêmios via vRP.giveBankMoney
   - Suporta jogadores online e offline
   - Verifica saldo antes da compra
   - Debita valor automaticamente

3. **Discord**
   - Webhook para notificações
   - Informa vencedor, prêmio e valores arrecadados
   - Formatação personalizada com embeds
   - Notificação de erros críticos

## Valores e Cálculos

- Valor do bilhete: R$1.000
- Distribuição:
  - 10% para o ganhador
  - 90% para a prefeitura
- Cálculo automático baseado em número de bilhetes
- Validação de valores monetários

## Segurança

1. **Validação de Tokens**
   - Geração única
   - Verificação de duplicidade
   - Loop de tentativas até encontrar token válido

2. **Controle de Ciclos**
   - Verificação de ciclo aberto
   - Prevenção de múltiplos ciclos simultâneos
   - Limpeza automática de bilhetes antigos
   - Transações para garantir integridade

3. **Backup de Dados**
   - Backup automático de sorteios antigos
   - Retenção de 30 dias de histórico
   - Tabela separada para backup
   - Rastreamento de data do backup

## Dependências

- vRP Framework
- ghmattimysql
- Discord Webhook

## Manutenção

1. **Verificações Diárias**
   - Status do ciclo atual
   - Funcionamento do webhook
   - Backup dos dados
   - Logs de erros
   - Status das transações

2. **Limpeza de Dados**
   - Bilhetes são excluídos após sorteio
   - Backup automático de sorteios antigos
   - Histórico mantido por 30 dias
   - Monitoramento de espaço em disco

## Troubleshooting

1. **Ciclo não inicia**
   - Verificar se há ciclo aberto
   - Checar conexão com banco de dados
   - Validar permissões do usuário
   - Verificar logs de erro
   - Checar status da transação

2. **Erro na compra de bilhete**
   - Verificar saldo do jogador
   - Validar token único
   - Checar status do ciclo
   - Verificar logs de erro
   - Checar status da transação

3. **Problemas no sorteio**
   - Verificar quantidade de bilhetes
   - Validar conexão com banco
   - Checar webhook do Discord
   - Verificar logs de erro
   - Checar status da transação

4. **Erros de Backup**
   - Verificar espaço em disco
   - Checar permissões do banco
   - Validar data do último backup
   - Verificar logs de erro 