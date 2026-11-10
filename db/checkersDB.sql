CREATE OR REPLACE TABLE IBMi_PROJECT.Parties (
	id int not null,
	etat Varchar(10) not null, /*dans "blancJoue", "noirJoue", "blancGagne", "noirGagne")*/

	Primary Key (id)
);

CREATE OR REPLACE TABLE IBMi_PROJECT.Pieces (
	idPartie int not null,
	x int not null,
	y int not null,
	couleur Varchar(5) not null, /*(dans "blanc", "noir")*/
	force Varchar(4) not null, /*(dans "pion", "dame")*/

	Primary Key (x, y),
	Constraint fk_partie Foreign Key (idPartie) References Parties(id)
);