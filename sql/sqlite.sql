CREATE TABLE IF NOT EXISTS sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT
);

DROP TABLE IF EXISTS images;

CREATE TABLE images (
    filename VARCHAR(255)
    ,width INTEGER
    ,height INTEGER
    ,content BLOB
    ,timestamp INTEGER
    ,PRIMARY KEY (filename, width, height)
);
