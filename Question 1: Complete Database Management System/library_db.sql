-- Library Management System Database Schema
-- Author: [Your Name/AI Assistant]
-- Date: [Current Date]

-- -----------------------------------------------------
-- Drop existing tables if they exist (optional, for easy re-running)
-- Drop in reverse order of creation due to dependencies
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Loans`;
DROP TABLE IF EXISTS `BookAuthors`;
DROP TABLE IF EXISTS `Books`;
DROP TABLE IF EXISTS `Authors`;
DROP TABLE IF EXISTS `Publishers`;
DROP TABLE IF EXISTS `Genres`;
DROP TABLE IF EXISTS `Members`;

-- -----------------------------------------------------
-- Table `Genres`
-- Stores different book genres.
-- -----------------------------------------------------
CREATE TABLE `Genres` (
  `genre_id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL UNIQUE COMMENT 'Genre name, e.g., Fiction, Science, History',
  `description` TEXT NULL COMMENT 'Optional description of the genre'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores book genres';

-- -----------------------------------------------------
-- Table `Publishers`
-- Stores information about book publishers.
-- -----------------------------------------------------
CREATE TABLE `Publishers` (
  `publisher_id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL UNIQUE COMMENT 'Publisher name',
  `address` VARCHAR(255) NULL COMMENT 'Publisher physical address',
  `website` VARCHAR(255) NULL COMMENT 'Publisher website URL'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores publisher information';

-- -----------------------------------------------------
-- Table `Authors`
-- Stores information about book authors.
-- -----------------------------------------------------
CREATE TABLE `Authors` (
  `author_id` INT AUTO_INCREMENT PRIMARY KEY,
  `first_name` VARCHAR(100) NOT NULL,
  `last_name` VARCHAR(100) NOT NULL,
  `birth_date` DATE NULL COMMENT 'Author date of birth',
   CONSTRAINT `uq_author_name` UNIQUE (`first_name`, `last_name`) -- Prevent duplicate author names
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores author details';

-- -----------------------------------------------------
-- Table `Books`
-- Stores information about individual books in the library.
-- -----------------------------------------------------
CREATE TABLE `Books` (
  `book_id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL COMMENT 'Book title',
  `isbn` VARCHAR(20) NOT NULL UNIQUE COMMENT 'International Standard Book Number',
  `publication_year` YEAR NULL COMMENT 'Year the book was published',
  `publisher_id` INT NULL COMMENT 'Foreign key referencing the publisher',
  `genre_id` INT NULL COMMENT 'Foreign key referencing the genre',
  `total_copies` INT NOT NULL DEFAULT 1 COMMENT 'Total number of copies available',
  `available_copies` INT NOT NULL DEFAULT 1 COMMENT 'Number of copies currently available for loan',

  CONSTRAINT `fk_book_publisher`
    FOREIGN KEY (`publisher_id`)
    REFERENCES `Publishers` (`publisher_id`)
    ON DELETE SET NULL -- If publisher is deleted, keep the book but set publisher to NULL
    ON UPDATE CASCADE, -- If publisher ID changes, update it here

  CONSTRAINT `fk_book_genre`
    FOREIGN KEY (`genre_id`)
    REFERENCES `Genres` (`genre_id`)
    ON DELETE SET NULL -- If genre is deleted, keep the book but set genre to NULL
    ON UPDATE CASCADE, -- If genre ID changes, update it here

   CHECK (`available_copies` <= `total_copies` AND `available_copies` >= 0) -- Ensure available copies is logical
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores book details';

-- -----------------------------------------------------
-- Table `BookAuthors` (Junction Table for M-M relationship)
-- Links Books and Authors (a book can have multiple authors, an author can write multiple books).
-- -----------------------------------------------------
CREATE TABLE `BookAuthors` (
  `book_id` INT NOT NULL,
  `author_id` INT NOT NULL,
  PRIMARY KEY (`book_id`, `author_id`), -- Composite primary key

  CONSTRAINT `fk_bookauthors_book`
    FOREIGN KEY (`book_id`)
    REFERENCES `Books` (`book_id`)
    ON DELETE CASCADE -- If a book is deleted, remove its author associations
    ON UPDATE CASCADE,

  CONSTRAINT `fk_bookauthors_author`
    FOREIGN KEY (`author_id`)
    REFERENCES `Authors` (`author_id`)
    ON DELETE CASCADE -- If an author is deleted, remove their book associations
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Junction table for Books and Authors (M-M)';


-- -----------------------------------------------------
-- Table `Members`
-- Stores information about library members/borrowers.
-- -----------------------------------------------------
CREATE TABLE `Members` (
  `member_id` INT AUTO_INCREMENT PRIMARY KEY,
  `first_name` VARCHAR(100) NOT NULL,
  `last_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(255) NOT NULL UNIQUE COMMENT 'Member email address, used for notifications',
  `phone_number` VARCHAR(20) NULL,
  `address` VARCHAR(255) NULL,
  `join_date` DATE NOT NULL DEFAULT (CURDATE()) COMMENT 'Date the member joined the library',
  `membership_expiry_date` DATE NULL COMMENT 'Optional membership expiry'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores library member information';


-- -----------------------------------------------------
-- Table `Loans`
-- Tracks books borrowed by members.
-- -----------------------------------------------------
CREATE TABLE `Loans` (
  `loan_id` INT AUTO_INCREMENT PRIMARY KEY,
  `book_id` INT NOT NULL COMMENT 'Foreign key referencing the borrowed book',
  `member_id` INT NOT NULL COMMENT 'Foreign key referencing the borrowing member',
  `loan_date` DATE NOT NULL DEFAULT (CURDATE()) COMMENT 'Date the book was borrowed',
  `due_date` DATE NOT NULL COMMENT 'Date the book is due back',
  `return_date` DATE NULL COMMENT 'Actual date the book was returned (NULL if not returned yet)',
  `fine_amount` DECIMAL(5, 2) DEFAULT 0.00 COMMENT 'Fine incurred for late return',

  CONSTRAINT `fk_loan_book`
    FOREIGN KEY (`book_id`)
    REFERENCES `Books` (`book_id`)
    ON DELETE RESTRICT -- Prevent deleting a book if it's currently on loan
    ON UPDATE CASCADE,

  CONSTRAINT `fk_loan_member`
    FOREIGN KEY (`member_id`)
    REFERENCES `Members` (`member_id`)
    ON DELETE RESTRICT -- Prevent deleting a member if they have active loans
    ON UPDATE CASCADE,

  CHECK (`return_date` IS NULL OR `return_date` >= `loan_date`) -- Return date must be after or same as loan date
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tracks book loans to members';


-- -----------------------------------------------------
-- Sample Data Insertion
-- -----------------------------------------------------

-- Insert Genres
INSERT INTO `Genres` (`name`, `description`) VALUES
('Science Fiction', 'Fiction based on imagined future scientific or technological advances.'),
('Fantasy', 'Fiction featuring magic and supernatural elements.'),
('Mystery', 'Fiction involving a puzzling crime or situation.'),
('History', 'Non-fiction accounts of past events.'),
('Programming', 'Technical books about software development.');

-- Insert Publishers
INSERT INTO `Publishers` (`name`, `address`, `website`) VALUES
('Penguin Random House', '1745 Broadway, New York, NY 10019', 'https://global.penguinrandomhouse.com/'),
('O Reilly Media', '1005 Gravenstein Highway North, Sebastopol, CA 95472', 'https://www.oreilly.com/'),
('Tor Books', '120 Broadway, New York, NY 10271', 'https://www.tor.com/'),
('Vintage Books', 'Part of Penguin Random House', 'https://knopfdoubleday.com/imprint/vintage/');


-- Insert Authors
INSERT INTO `Authors` (`first_name`, `last_name`, `birth_date`) VALUES
('George', 'Orwell', '1903-06-25'),
('J.R.R.', 'Tolkien', '1892-01-03'),
('Agatha', 'Christie', '1890-09-15'),
('Isaac', 'Asimov', '1920-01-02'),
('David', 'Flanagan', NULL),
('Brandon', 'Sanderson', '1975-12-19');


-- Insert Books
INSERT INTO `Books` (`title`, `isbn`, `publication_year`, `publisher_id`, `genre_id`, `total_copies`, `available_copies`) VALUES
('Nineteen Eighty-Four', '978-0451524935', 1949, 1, 1, 5, 4),
('The Hobbit', '978-0547928227', 1937, 4, 2, 7, 7),
('Murder on the Orient Express', '978-0062693662', 1934, 1, 3, 4, 3),
('Foundation', '978-0553293357', 1951, 4, 1, 3, 3),
('JavaScript: The Definitive Guide', '978-1491952023', 2020, 2, 5, 2, 1),
('The Way of Kings', '978-0765326355', 2010, 3, 2, 6, 6);

-- Insert BookAuthors (Link books to authors)
-- Note: IDs correspond to the order of inserts above (e.g., Orwell is 1, Tolkien is 2, Christie is 3, Asimov is 4, Flanagan is 5, Sanderson is 6)
-- Book IDs: Nineteen Eighty-Four(1), Hobbit(2), Murder on Orient Express(3), Foundation(4), JavaScript Guide(5), Way of Kings(6)
INSERT INTO `BookAuthors` (`book_id`, `author_id`) VALUES
(1, 1), -- Nineteen Eighty-Four by George Orwell
(2, 2), -- The Hobbit by J.R.R. Tolkien
(3, 3), -- Murder on the Orient Express by Agatha Christie
(4, 4), -- Foundation by Isaac Asimov
(5, 5), -- JavaScript Guide by David Flanagan
(6, 6); -- The Way of Kings by Brandon Sanderson

-- Insert Members
INSERT INTO `Members` (`first_name`, `last_name`, `email`, `phone_number`, `address`, `join_date`) VALUES
('Alice', 'Smith', 'alice.smith@email.com', '555-1234', '123 Main St', '2023-01-15'),
('Bob', 'Johnson', 'bob.j@email.com', '555-5678', '456 Oak Ave', '2023-03-22'),
('Charlie', 'Brown', 'charlie.b@email.com', '555-9900', '789 Pine Ln', CURDATE());


-- Insert Loans
-- Assume Alice borrowed Nineteen Eighty-Four and returned it
INSERT INTO `Loans` (`book_id`, `member_id`, `loan_date`, `due_date`, `return_date`) VALUES
(1, 1, '2024-02-01', '2024-02-15', '2024-02-14');
-- Update available copies for book 1 (no trigger in this basic setup, do manually)
-- UPDATE Books SET available_copies = available_copies + 1 WHERE book_id = 1; -- This should ideally be handled by application logic or triggers

-- Assume Bob borrowed Murder on the Orient Express and it's still out
INSERT INTO `Loans` (`book_id`, `member_id`, `loan_date`, `due_date`) VALUES
(3, 2, '2024-03-10', '2024-03-24');
-- Update available copies for book 3
UPDATE Books SET available_copies = available_copies - 1 WHERE book_id = 3;

-- Assume Alice borrowed the JavaScript guide
INSERT INTO `Loans` (`book_id`, `member_id`, `loan_date`, `due_date`) VALUES
(5, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY));
-- Update available copies for book 5
UPDATE Books SET available_copies = available_copies - 1 WHERE book_id = 5;

-- Show final available copies count (for verification)
-- SELECT book_id, title, total_copies, available_copies FROM Books;

-- -----------------------------------------------------
-- End of Script
-- -----------------------------------------------------
