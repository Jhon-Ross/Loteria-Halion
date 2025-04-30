-- Estrutura da tabela vrp_lottery_tickets
CREATE TABLE IF NOT EXISTS `vrp_lottery_tickets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` varchar(4) NOT NULL,
  `cycle_id` int(11) NOT NULL,
  `purchase_date` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `user_id` (`user_id`),
  KEY `cycle_id` (`cycle_id`),
  KEY `idx_tickets_user_cycle` (`user_id`, `cycle_id`),
  KEY `idx_tickets_token` (`token`),
  CONSTRAINT `fk_lottery_tickets_users` FOREIGN KEY (`user_id`) REFERENCES `vrp_users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_lottery_tickets_cycles` FOREIGN KEY (`cycle_id`) REFERENCES `vrp_lottery_cycles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Estrutura da tabela vrp_lottery_cycles
CREATE TABLE IF NOT EXISTS `vrp_lottery_cycles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `draw_date` datetime DEFAULT NULL,
  `winner_id` int(11) DEFAULT NULL,
  `total_amount` int(11) NOT NULL DEFAULT 0,
  `prize_amount` int(11) NOT NULL DEFAULT 0,
  `status` enum('open','closed','drawn') NOT NULL DEFAULT 'open',
  PRIMARY KEY (`id`),
  KEY `winner_id` (`winner_id`),
  KEY `idx_cycles_status` (`status`),
  KEY `idx_cycles_dates` (`start_date`, `end_date`),
  CONSTRAINT `fk_lottery_cycles_users` FOREIGN KEY (`winner_id`) REFERENCES `vrp_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Estrutura da tabela vrp_lottery_draws
CREATE TABLE IF NOT EXISTS `vrp_lottery_draws` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `draw_date` datetime NOT NULL DEFAULT current_timestamp(),
  `ticket_id` int(11) NOT NULL,
  `cycle_id` int(11) NOT NULL,
  `winner_id` int(11) NOT NULL,
  `prize_amount` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ticket_id` (`ticket_id`),
  KEY `cycle_id` (`cycle_id`),
  KEY `winner_id` (`winner_id`),
  KEY `idx_draws_cycle` (`cycle_id`),
  KEY `idx_draws_winner` (`winner_id`),
  CONSTRAINT `fk_lottery_draws_tickets` FOREIGN KEY (`ticket_id`) REFERENCES `vrp_lottery_tickets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_lottery_draws_cycles` FOREIGN KEY (`cycle_id`) REFERENCES `vrp_lottery_cycles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_lottery_draws_users` FOREIGN KEY (`winner_id`) REFERENCES `vrp_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Estrutura da tabela vrp_lottery_backup
CREATE TABLE IF NOT EXISTS `vrp_lottery_backup` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `draw_date` datetime NOT NULL,
  `ticket_id` int(11) NOT NULL,
  `cycle_id` int(11) NOT NULL,
  `winner_id` int(11) NOT NULL,
  `prize_amount` int(11) NOT NULL,
  `backup_date` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `draw_date` (`draw_date`),
  KEY `cycle_id` (`cycle_id`),
  KEY `winner_id` (`winner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Trigger para backup automático
DELIMITER //
CREATE TRIGGER after_draw_insert
AFTER INSERT ON vrp_lottery_draws
FOR EACH ROW
BEGIN
    IF Config.Backup.Ativo THEN
        INSERT INTO vrp_lottery_backup
        SELECT *, NOW() FROM vrp_lottery_draws
        WHERE id = NEW.id;
    END IF;
END //
DELIMITER ;