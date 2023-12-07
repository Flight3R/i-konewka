CREATE DATABASE IF NOT EXISTS ikonewka;

USE ikonewka;

CREATE TABLE USERS (
  uid INTEGER AUTO_INCREMENT PRIMARY KEY,
  nick TEXT NOT NULL,
  nof_flowers INTEGER DEFAULT 0,
  email TEXT NOT NULL,
  password TEXT NOT NULL,
  watering_hour INTEGER NOT NULL,
  start TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE FLOWER_TYPES (
  ftid INTEGER AUTO_INCREMENT PRIMARY KEY,
  name TEXT NOT NULL,
  note TEXT,
  nof_watering_days INTEGER NOT NULL,
  ml_per_watering INTEGER NOT NULL
);

CREATE TABLE FLOWERS (
  fid INTEGER AUTO_INCREMENT PRIMARY KEY,
  uid INTEGER NOT NULL,
  ftid INTEGER NOT NULL,
  name TEXT NOT NULL,
  health TEXT NOT NULL,
  start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ml_per_watering INTEGER NOT NULL,
  monday INTEGER DEFAULT '0',
  tuesday INTEGER DEFAULT '0',
  wednesday INTEGER DEFAULT '0',
  thursday INTEGER DEFAULT '0',
  friday INTEGER DEFAULT '0',
  saturday INTEGER DEFAULT '0',
  sunday INTEGER DEFAULT '0',
  CONSTRAINT ftid_FLOWER_TYPES
    FOREIGN KEY (ftid) REFERENCES FLOWER_TYPES(ftid),
  CONSTRAINT uid_USERS_2
    FOREIGN KEY (uid) REFERENCES USERS(uid)
);

CREATE TABLE HISTORY (
  hid INTEGER AUTO_INCREMENT PRIMARY KEY,
  fid INTEGER NOT NULL,
  uid INTEGER NOT NULL,
  watering TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fid_FLOWERS
    FOREIGN KEY (fid) REFERENCES FLOWERS(fid),
  CONSTRAINT uid_USERS
    FOREIGN KEY (uid) REFERENCES USERS(uid)
);

CREATE TABLE IMAGES (
  iid INTEGER AUTO_INCREMENT PRIMARY KEY,
  fid INTEGER NOT NULL,
  image LONGTEXT NOT NULL,
  image_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fid_FLOWERS_2
    FOREIGN KEY (fid) REFERENCES FLOWERS(fid)
);

INSERT INTO USERS (nick, email, password, watering_hour) VALUES
("Foczka", "foczka@gamil.com", "1234", 8),
("Zyrafka", "zyrafka@gamil.com", "1234", 13);

INSERT into FLOWER_TYPES (name, note, nof_watering_days, ml_per_watering) VALUES
("Roza", "ladna", 2, 100),
("Paprotka", "fajna", 1, 200),
("Kaktus", "ostry", 3, 300),
("Storczyk", "mamy to lubia", 2, 150);

INSERT INTO FLOWERS (uid, ftid, name, health, ml_per_watering) VALUES
(1, 1, "rozyczka", "GOOD", 100),
(1, 2, "paprotka kuchania", "BAD", 200),
(2, 2, "paprotka sypialnia", "GOOD", 300),
(1, 3, "kaktus", "BAD", 400),
(2, 4, "storczyczek", "GOOD", 500);

INSERT INTO HISTORY (fid, uid) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 1),
(5, 2);

UPDATE USERS
SET nof_flowers = (
    SELECT COUNT(*) FROM FLOWERS WHERE uid = USERS.uid
);

CREATE USER serviceaccount IDENTIFIED BY 'cZtx7b$xwkSL';

GRANT ALL PRIVILEGES ON ikonewka.* TO serviceaccount;
