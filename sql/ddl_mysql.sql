CREATE TABLE users (
	id				INT UNSIGNED AUTO_INCREMENT,
	email			VARCHAR(100) UNIQUE NOT NULL,
	password		VARCHAR(128) NOT NULL,
	active			BOOLEAN	DEFAULT FALSE,
	created_at		TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	activation_key	VARCHAR(64) NOT NULL,
	
	PRIMARY KEY		(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE agendas (
	id 			INT UNSIGNED AUTO_INCREMENT,
	user_id		INT UNSIGNED UNIQUE NOT NULL,
	description	varchar(255) NULL,
	
	PRIMARY KEY	(id),
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE blocks (
	id			INT UNSIGNED AUTO_INCREMENT,
	title		VARCHAR(80) NOT NULL,
	content		LONGTEXT NULL,
	parent		INT UNSIGNED NOT NULL,
	
	PRIMARY KEY	(id),
	INDEX		(parent),
	FOREIGN KEY (parent) REFERENCES blocks(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE categories (
	id			INT UNSIGNED AUTO_INCREMENT,
	description	VARCHAR(20) NOT NULL,
	
	PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mailing_lists (
	id			INT UNSIGNED AUTO_INCREMENT,
	user_id		INT UNSIGNED UNIQUE NOT NULL,
	state		BOOLEAN DEFAULT FALSE,
	
	PRIMARY KEY	(id),
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE map_marquers (
	id			INT UNSIGNED AUTO_INCREMENT,
	latitude	FLOAT NOT NULL,
	longitude	FLOAT NOT NULL,
	name		VARCHAR(80) NOT NULL,
	description	LONGTEXT,
	
	PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE countries (
	id			INT UNSIGNED	AUTO_INCREMENT,
	abbr		VARCHAR(3) NOT NULL,
	country		VARCHAR(30) NOT NULL,
	
	PRIMARY KEY	(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE profiles (
	id				INT UNSIGNED AUTO_INCREMENT,
	address			VARCHAR(255) NULL,
	province		VARCHAR(20) NULL,
	zip_code		VARCHAR(10) NULL,
	city			VARCHAR(30) NULL,
	real_name		VARCHAR(100) NOT NULL,
	photo_path		VARCHAR(60) NULL,
	preferences		TEXT NULL,
	country_id		INT UNSIGNED NULL,
	map_point_id	INT UNSIGNED NULL,
	user_id			INT	UNSIGNED UNIQUE NOT NULL,
	bio				TEXT NULL,
	
	PRIMARY KEY		(id),
	INDEX			(country_id),
	INDEX			(map_point_id),
	FOREIGN KEY		(country_id) REFERENCES countries(id) ON DELETE CASCADE,
	FOREIGN KEY		(map_point_id) REFERENCES map_marquers(id) ON DELETE CASCADE,
	FOREIGN KEY 	(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE comments (
	id			INT UNSIGNED AUTO_INCREMENT,
	content		LONGTEXT NOT NULL,
	created_at	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	update_at	DATETIME NULL,
	parent		INT UNSIGNED NOT NULL,
	user_id		INT UNSIGNED NOT NULL,
	
	PRIMARY KEY	(id),
	INDEX		(parent),
	INDEX		(user_id),
	FOREIGN KEY	(parent) REFERENCES comments(id) ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE albums (
	id			INT UNSIGNED AUTO_INCREMENT,
	title		VARCHAR(255) NOT NULL,
	user_id		INT UNSIGNED NOT NULL,
	category_id	INT UNSIGNED NOT NULL,
	
	PRIMARY KEY	(id),
	INDEX		(user_id),
	INDEX		(category_id),
	FOREIGN KEY	(user_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE band_elements (
	user_id		INT UNSIGNED NOT NULL,
	element_id	INT UNSIGNED NOT NULL,
	
	PRIMARY KEY	(user_id, element_id),
	FOREIGN	KEY	(user_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (element_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE events (
	id				INT UNSIGNED AUTO_INCREMENT,
	name			VARCHAR(100) NOT NULL,
	description		LONGTEXT NOT NULL,
	map_point_id	INT UNSIGNED NOT NULL,
	agenda_id		INT UNSIGNED NOT NULL,
	
	PRIMARY KEY		(id),
	INDEX			(map_point_id),
	INDEX			(agenda_id),
	FOREIGN KEY		(map_point_id) REFERENCES map_marquers(id) ON DELETE CASCADE,
	FOREIGN KEY		(agenda_id)	REFERENCES agendas(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE mailing_list_messages (
	id				INT UNSIGNED AUTO_INCREMENT,
	created_at		TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	content			LONGTEXT NOT NULL,
	mailing_list_id	INT UNSIGNED NOT NULL,
	
	PRIMARY KEY		(id),
	INDEX			(mailing_list_id),
	FOREIGN KEY		(mailing_list_id) REFERENCES mailing_lists(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE tracks (
	id			INT UNSIGNED AUTO_INCREMENT,
	title		VARCHAR(60) NOT NULL,
	lyrics		TEXT NULL,
	track_path	VARCHAR(100) NOT NULL,
	album_id	INT UNSIGNED NOT NULL,
	
	PRIMARY KEY	(id),
	INDEX		(album_id),
	FOREIGN KEY	(album_id) REFERENCES albums(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE user_favs (
	user_id		INT UNSIGNED NOT NULL,
	band_id		INT UNSIGNED NOT NULL,
	
	PRIMARY KEY	(user_id, band_id),
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (band_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE users_mailing_lists (
	user_id			INT UNSIGNED NOT NULL,
	mailing_list_id	INT UNSIGNED NOT NULL,
	
	PRIMARY KEY	(user_id, mailing_list_id),
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (mailing_list_id) REFERENCES mailing_lists(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DELIMITER $$
DROP TRIGGER IF EXISTS user_tables $$
CREATE TRIGGER user_tables AFTER INSERT ON users
	FOR EACH ROW BEGIN
		DECLARE lastid INT;
		SET lastid = LAST_INSERT_ID();
		INSERT INTO agendas(user_id) VALUES(lastid);
		INSERT INTO mailing_lists(user_id, state) VALUES(lastid, FALSE);
		INSERT INTO profiles(user_id, email) VALUES(lastid, NEW.email);
	END;