SET SCHEMA LEBOULLIO1;

DROP TABLE IF EXISTS HstChckrs;
DROP TABLE IF EXISTS Pieces;
DROP TABLE IF EXISTS Parties;

CREATE TABLE Parties (
    id INT NOT NULL,
    etat VARCHAR(10) NOT NULL
        CHECK (etat IN ('blancJoue', 'noirJoue', 'blancGagne', 'noirGagne', 'blancRafle', 'noirRafle')),
    dernierX INT NOT NULL,
    dernierY INT NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE Pieces (
    idPartie INT NOT NULL,
    x INT NOT NULL,
    y INT NOT NULL,
    couleur VARCHAR(5) NOT NULL
        CHECK (couleur IN ('blanc', 'noir')),
    forme VARCHAR(5) NOT NULL
        CHECK (forme IN ('pion', 'dame')),
    PRIMARY KEY (idPartie, x, y),
    CONSTRAINT fk_partie
        FOREIGN KEY (idPartie) REFERENCES Parties(id)
);

CREATE TABLE HstChckrs (
    id INT NOT NULL,
    idParent INT,
    idPartie INT NOT NULL,
    dateCoup TIMESTAMP NOT NULL,
    typeCoup VARCHAR(6) NOT NULL
        CHECK (typeCoup IN ('prends', 'bouge')),
    avantX INT NOT NULL,
    avantY INT NOT NULL,
    avantC VARCHAR(5) NOT NULL
        CHECK (avantC IN ('blanc', 'noir')),
    avantF VARCHAR(5) NOT NULL
        CHECK (avantF IN ('pion', 'dame')),
    apresX INT,
    apresY INT,
    apresC VARCHAR(5)
        CHECK (apresC IN ('blanc', 'noir')),
    apresF VARCHAR(5)
        CHECK (apresF IN ('pion', 'dame')),
    PRIMARY KEY (id),
    CONSTRAINT fk_partie2
        FOREIGN KEY (idPartie) REFERENCES Parties(id)
);