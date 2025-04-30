# Sistema de Loteria - Halion City

## Visão Geral
Sistema de loteria automatizado integrado ao servidor FiveM GTARP Halion City. O sistema permite sorteios diários, controle administrativo e integração com a economia do servidor.

## Estrutura do Banco de Dados

### Tabela: vrp_lottery_tickets
Armazena os bilhetes comprados pelos jogadores.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INT(11) | Identificador único do bilhete (AUTO_INCREMENT) |
| user_id | INT(11) | ID do jogador que comprou o bilhete (FK para vrp_users) |
| token | VARCHAR(4) | Token único de 4 caracteres alfanuméricos |
| cycle_id | INT(11) | ID do ciclo em que o bilhete foi comprado |
| purchase_date | DATETIME | Data e hora da compra do bilhete |

### Tabela: vrp_lottery_cycles
Controla os ciclos de venda e sorteio da loteria.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INT(11) | Identificador único do ciclo (AUTO_INCREMENT) |
| start_date | DATETIME | Data de início do ciclo |
| end_date | DATETIME | Data de término do ciclo |
| draw_date | DATETIME | Data do sorteio (pode ser NULL) |
| winner_id | INT(11) | ID do jogador ganhador (FK para vrp_users) |
| total_amount | INT(11) | Valor total arrecadado no ciclo |
| prize_amount | INT(11) | Valor do prêmio do ciclo |
| status | ENUM | Status do ciclo: 'open', 'closed', 'drawn' |

### Tabela: vrp_lottery_draws
Registra os resultados dos sorteios realizados.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INT(11) | Identificador único do sorteio (AUTO_INCREMENT) |
| draw_date | DATETIME | Data e hora do sorteio |
| ticket_id | INT(11) | ID do bilhete premiado (FK para vrp_lottery_tickets) |
| cycle_id | INT(11) | ID do ciclo (FK para vrp_lottery_cycles) |
| winner_id | INT(11) | ID do jogador ganhador (FK para vrp_users) |
| prize_amount | INT(11) | Valor do prêmio distribuído |

### Tabela: vrp_lottery_backup
Armazena backup dos sorteios antigos.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INT(11) | Identificador único do backup (AUTO_INCREMENT) |
| draw_date | DATETIME | Data e hora do sorteio original |
| ticket_id | INT(11) | ID do bilhete premiado |
| cycle_id | INT(11) | ID do ciclo |
| winner_id | INT(11) | ID do jogador ganhador |
| prize_amount | INT(11) | Valor do prêmio distribuído |
| backup_date | DATETIME | Data e hora do backup |

## Relacionamentos

- `vrp_lottery_tickets.user_id` → `vrp_users.id`
- `vrp_lottery_tickets.cycle_id` → `vrp_lottery_cycles.id`
- `vrp_lottery_cycles.winner_id` → `vrp_users.id`
- `vrp_lottery_draws.ticket_id` → `vrp_lottery_tickets.id`
- `vrp_lottery_draws.cycle_id` → `vrp_lottery_cycles.id`
- `vrp_lottery_draws.winner_id` → `vrp_users.id`

## Funcionamento do Sistema

1. **Ciclos de Venda**:
   - Cada ciclo tem um período definido de venda (24 horas)
   - Os jogadores podem comprar bilhetes durante o ciclo
   - Cada bilhete recebe um token único de 4 caracteres
   - Valor do bilhete: R$1.000
   - Verificação de saldo antes da compra

2. **Sorteio**:
   - Realizado automaticamente às 12:00
   - O ganhador é selecionado aleatoriamente entre os bilhetes válidos
   - Distribuição do prêmio:
     - 10% para o ganhador
     - 90% para a prefeitura
   - Backup automático dos dados

3. **Integração Econômica**:
   - Os valores são integrados com o sistema de economia do servidor
   - O prêmio é depositado automaticamente na conta do ganhador
   - Transações são registradas no sistema de banco
   - Suporte para jogadores online e offline

## Segurança e Validações

1. **Integridade dos Dados**:
   - Transações para operações críticas
   - Rollback automático em caso de erro
   - Validação de usuário antes da compra
   - Verificação de saldo do jogador
   - Tokens únicos garantem que não haja duplicação de bilhetes

2. **Controle de Ciclos**:
   - Verificação de ciclo aberto
   - Prevenção de múltiplos ciclos simultâneos
   - Status do ciclo controla o fluxo de compras e sorteios
   - Registro completo de todas as transações

3. **Backup e Histórico**:
   - Backup automático de sorteios antigos
   - Retenção de 30 dias de histórico
   - Tabela separada para backup
   - Rastreamento completo de todas as operações

## Integração com Discord

O sistema pode ser integrado com Discord para:
- Anúncio de ciclos abertos
- Notificação de ganhadores
- Transparência nos sorteios
- Estatísticas e rankings
- Formatação personalizada com embeds

## Manutenção

Para manter o sistema funcionando corretamente:
1. Verificar regularmente a integridade dos dados
2. Monitorar o desempenho das queries
3. Verificar status das transações
4. Monitorar o processo de backup
5. Atualizar os índices conforme necessário
6. Verificar logs de erros
7. Manter o webhook do Discord atualizado