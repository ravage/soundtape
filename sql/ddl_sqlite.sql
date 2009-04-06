CREATE TABLE agendas (
	id 			INT UNSIGNED AUTO_INCREMENT,
	description	varchar(255) NOT NULL,
	
	PRIMARY KEY	(id)
);

CREATE TABLE blocks (
	id			INT UNSIGNED AUTO_INCREMENT,
	title		VARCHAR(80) NOT NULL,
	content		LONGTEXT DEFAULT NULL,
	parent		INT UNSIGNED NOT NULL,
	
	PRIMARY KEY	(id),
	INDEX		(parent),
	FOREIGN KEY (parent) REFERENCES blocks(id)
);

CREATE TABLE categories (
	id			INT UNSIGNED AUTO_INCREMENT,
	description	VARCHAR(20) NOT NULL,
	
	PRIMARY KEY (id)
);

CREATE TABLE mailing_lists (
	id			INT UNSIGNED AUTO_INCREMENT,
	state		BOOLEAN DEFAULT FALSE,
	
	PRIMARY KEY	(id)
);

CREATE TABLE map_marquers (
	id			INT UNSIGNED AUTO_INCREMENT,
	latitude	FLOAT NOT NULL,
	longitude	FLOAT NOT NULL,
	name		VARCHAR(80) NOT NULL,
	description	LONGTEXT,
	
	PRIMARY KEY (id)
);

CREATE TABLE countries (
	id			INT UNSIGNED	AUTO_INCREMENT,
	abbr		VARCHAR(3) NOT NULL,
	country		VARCHAR(30) NOT NULL,
	
	PRIMARY KEY	(id)
);

CREATE TABLE profiles (
	id				INT UNSIGNED AUTO_INCREMENT,
	address			VARCHAR(255) DEFAULT NULL,
	province		VARCHAR(20) DEFAULT NULL,
	zip_code		VARCHAR(10) DEFAULT NULL,
	city			VARCHAR(30) DEFAULT NULL,
	real_name		VARCHAR(100) NOT NULL,
	photo_path		VARCHAR(60) DEFAULT NULL,
	preferences		TEXT DEFAULT NULL,
	country_id		INT UNSIGNED NOT NULL,
	map_point_id	INT UNSIGNED NULL,
	
	PRIMARY KEY		(id),
	INDEX			(country_id),
	INDEX			(map_point_id),
	FOREIGN KEY		(country_id) REFERENCES countries(id),
	FOREIGN KEY		(map_point_id) REFERENCES map_marquers(id)
);

CREATE TABLE users (
	id				INT UNSIGNED AUTO_INCREMENT,
	email			VARCHAR(100) UNIQUE NOT NULL,
	password		VARCHAR(512) NOT NULL,
	agenda_id		INT UNSIGNED NOT NULL,
	mailing_list_id	INT UNSIGNED NOT NULL,
	profile_id		INT UNSIGNED NOT NULL,
	
	PRIMARY KEY		(id),
	INDEX			(agenda_id),
	INDEX			(mailing_list_id),
	INDEX			(profile_id),
	FOREIGN KEY		(agenda_id) REFERENCES agendas(id),
	FOREIGN KEY		(mailing_list_id) REFERENCES mailing_lists(id),
	FOREIGN	KEY		(profile_id) REFERENCES	profiles(id)
);

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
	FOREIGN KEY	(parent) REFERENCES comments(id),
	FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE albums (
	id			INT UNSIGNED AUTO_INCREMENT,
	title		VARCHAR(255) NOT NULL,
	user_id		INT UNSIGNED NOT NULL,
	category_id	INT UNSIGNED NOT NULL,
	
	PRIMARY KEY	(id),
	INDEX		(user_id),
	INDEX		(category_id),
	FOREIGN KEY	(user_id) REFERENCES users(id),
	FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE band_elements (
	user_id		INT UNSIGNED NOT NULL,
	element_id	INT UNSIGNED NOT NULL,
	
	PRIMARY KEY	(user_id, element_id),
	FOREIGN	KEY	(user_id) REFERENCES users(id),
	FOREIGN KEY (element_id) REFERENCES users(id)
);

CREATE TABLE events (
	id				INT UNSIGNED AUTO_INCREMENT,
	name			VARCHAR(100) NOT NULL,
	description		LONGTEXT NOT NULL,
	map_point_id	INT UNSIGNED NOT NULL,
	agenda_id		INT UNSIGNED NOT NULL,
	
	PRIMARY KEY		(id),
	INDEX			(map_point_id),
	INDEX			(agenda_id),
	FOREIGN KEY		(map_point_id) REFERENCES map_marquers(id),
	FOREIGN KEY		(agenda_id)	REFERENCES agendas(id)
);

CREATE TABLE mailing_list_messages (
	id				INT UNSIGNED AUTO_INCREMENT,
	created_at		TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	content			LONGTEXT NOT NULL,
	mailing_list_id	INT UNSIGNED NOT NULL,
	
	PRIMARY KEY		(id),
	INDEX			(mailing_list_id),
	FOREIGN KEY		(mailing_list_id) REFERENCES mailing_lists(id)
);

CREATE TABLE tracks (
	id			INT UNSIGNED AUTO_INCREMENT,
	title		VARCHAR(60) NOT NULL,
	lyrics		TEXT DEFAULT NULL,
	track_path	VARCHAR(100) NOT NULL,
	album_id	INT UNSIGNED NOT NULL,
	
	PRIMARY KEY	(id),
	INDEX		(album_id),
	FOREIGN KEY	(album_id) REFERENCES albums(id)
);

CREATE TABLE user_favs (
	user_id		INT UNSIGNED NOT NULL,
	band_id		INT UNSIGNED NOT NULL,
	
	PRIMARY KEY	(user_id, band_id),
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (band_id) REFERENCES users(id)
);

CREATE TABLE users_mailing_lists (
	user_id			INT UNSIGNED NOT NULL,
	mailing_list_id	INT UNSIGNED NOT NULL,
	
	PRIMARY KEY	(user_id, mailing_list_id),
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (mailing_list_id) REFERENCES mailing_lists(id)
);