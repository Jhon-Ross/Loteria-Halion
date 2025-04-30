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

## Relacionamentos

- `vrp_lottery_tickets.user_id` → `vrp_users.id`
- `vrp_lottery_cycles.winner_id` → `vrp_users.id`
- `vrp_lottery_draws.ticket_id` → `vrp_lottery_tickets.id`
- `vrp_lottery_draws.cycle_id` → `vrp_lottery_cycles.id`
- `vrp_lottery_draws.winner_id` → `vrp_users.id`

## Funcionamento do Sistema

1. **Ciclos de Venda**:
   - Cada ciclo tem um período definido de venda
   - Os jogadores podem comprar bilhetes durante o ciclo
   - Cada bilhete recebe um token único de 4 caracteres

2. **Sorteio**:
   - Ao final do ciclo, o sistema realiza o sorteio
   - O ganhador é selecionado aleatoriamente entre os bilhetes válidos
   - O prêmio é calculado com base no valor arrecadado

3. **Integração Econômica**:
   - Os valores são integrados com o sistema de economia do servidor
   - O prêmio é depositado automaticamente na conta do ganhador
   - Transações são registradas no sistema de banco

## Segurança e Validações

- Tokens únicos garantem que não haja duplicação de bilhetes
- Chaves estrangeiras mantêm a integridade dos dados
- Status do ciclo controla o fluxo de compras e sorteios
- Registro completo de todas as transações

## Integração com Discord

O sistema pode ser integrado com Discord para:
- Anúncio de ciclos abertos
- Notificação de ganhadores
- Transparência nos sorteios
- Estatísticas e rankings

## Manutenção

Para manter o sistema funcionando corretamente:
1. Verificar regularmente a integridade dos dados
2. Monitorar o desempenho das queries
3. Fazer backup regular do banco de dados
4. Atualizar os índices conforme necessário