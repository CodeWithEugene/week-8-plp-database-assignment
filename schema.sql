-- Drop table if it exists (for easy recreation)
DROP TABLE IF EXISTS `tasks`;

-- Create the tasks table
CREATE TABLE `tasks` (
  `task_id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NULL,
  `status` ENUM('pending', 'in_progress', 'completed') NOT NULL DEFAULT 'pending',
  `due_date` DATE NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample data (optional)
INSERT INTO `tasks` (`title`, `description`, `status`, `due_date`) VALUES
('Buy Groceries', 'Milk, Bread, Eggs', 'pending', '2024-04-10'),
('Finish Project Report', 'Complete sections 4 and 5', 'in_progress', '2024-04-15'),
('Call Plumber', 'Fix leaky faucet in kitchen', 'completed', '2024-04-01');