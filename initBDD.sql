CREATE OR REPLACE TABLE GBARDELA1.Clients(
    id INTEGER NOT NULL,
    firstname VARCHAR(64) NOT NULL,
    lastname VARCHAR(64) NOT NULL,

    CONSTRAINT CLIENT_PK PRIMARY KEY (id)
);

INSERT INTO GBARDELA1.Clients (id,firstname,lastname)
VALUES 
('1','Leo','Ag***u'),
('2','Gurvan','Ba******n');

SELECT * FROM GBARDELA1.Clients;