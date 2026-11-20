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
