CREATE TABLE guitars (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  guitarist_id INTEGER,

  FOREIGN KEY(guitarist_id) REFERENCES guitarist(id)
);

CREATE TABLE guitarists (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  band_id INTEGER,

  FOREIGN KEY(band_id) REFERENCES guitarist(id)
);

CREATE TABLE bands (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  bands (id, name)
VALUES
  (1, "The Beatles"), (2, "Metallica");

INSERT INTO
  guitarists (id, fname, lname, band_id)
VALUES
  (1, "George", "Harrison", 1),
  (2, "John", "Lennon", 1),
  (3, "Kirk", "Hammett", 2),
  (4, "James", "Hetfield", 2),
  (5, "Lu", "Yang", NULL),
  (6, "Jimi", "Hendrix", NULL);

INSERT INTO
  guitars (id, name, guitarist_id)
VALUES
  (1, "Gretsch 62", 1),
  (2, "Rickenbacker 325", 2),
  (3, "ESP KH-602", 3),
  (4, "ESP LTD", 4),
  (5, "Epiphone Casino", 2),
  (6, "Fender Stratocaster", 6);
