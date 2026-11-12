CREATE OR REPLACE TABLE LEBOULLIO1.Parties (
	id int not null,
	etat ENUM('blancJoue', 'noirJoue', 'blancGagne', 'noirGagne') not null,

	Primary Key (id)
);

CREATE OR REPLACE TABLE LEBOULLIO1.Pieces (
	idPartie int not null,
	x int not null,
	y int not null,
	couleur ENUM('blanc', 'noir') not null,
	forme ENUM('pion', 'dame') not null,

	Primary Key (idPartie, x, y),
	Constraint fk_partie Foreign Key (idPartie) References Parties(id)
);

CREATE OR REPLACE TABLE LEBOULLIO1.HstChckrs (
	id int not null,
	idParent int,
	idPartie int not null,

	dateCoup timestamp not null,
	typeCoup ENUM('prends', 'bouge') not null,
	avantX int not null,
	avantY int not null,
	avantC ENUM('blanc', 'noir') not null,
	avantF ENUM('pion', 'dame') not null,
	
	apresX int,
	apresY int,
	apresC ENUM('blanc', 'noir'),
	apresF ENUM('pion', 'dame'),

	Primary Key (id),
	
	Constraint fk_partie2 Foreign Key (idPartie) References Parties(id)
);