CREATE OR REPLACE TABLE Parties (
	id int not null,
	etat Varchar(40) not null, /*dans "blanc_joue", "noir_joue", "blanc_gagne", "noir_gagne")*/

	Primary Key (id)
);

CREATE OR REPLACE TABLE Pieces (
	idPartie int not null,
	x int not null,
	y int not null,
	couleur Varchar(40) not null, /*(dans "blanc", "noir")*/
	force Varchar(40) not null, /*(dans "pion", "dame")*/

	Primary Key (x, y),
	Constraint fk_partie Foreign Key (idPartie) References Parties(id)
);