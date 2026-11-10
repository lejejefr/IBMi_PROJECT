CREATE OR REPLACE TABLE LEBOULLIO1.Parties (
	id int not null,
	etat Varchar(10) not null, /*dans "blancJoue", "noirJoue", "blancGagne", "noirGagne")*/

	Primary Key (id)
);

CREATE OR REPLACE TABLE LEBOULLIO1.Pieces (
	idPartie int not null,
	x int not null,
	y int not null,
	couleur Varchar(5) not null, /*(dans "blanc", "noir")*/
	forme Varchar(4) not null, /*(dans "pion", "dame")*/

	Primary Key (idPartie, x, y),
	Constraint fk_partie Foreign Key (idPartie) References Parties(id)
);