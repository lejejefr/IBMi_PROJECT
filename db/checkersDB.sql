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

CREATE OR REPLACE TABLE LEBOULLIO1.HstChckrs (
	id int not null,
	idParent int,
	idPartie int not null,

	dateCoup timestamp not null,
	typeCoup Varchar(6) not null,/*(dans "prends", "bouge")*/
	avantX int not null,
	avantY int not null,
	avantC Varchar(5) not null, /*(dans "blanc", "noir")*/
	avantF Varchar(4) not null, /*(dans "pion", "dame")*/
	
	apresX int,
	apresY int,
	apresC Varchar(5), /*(dans "blanc", "noir", NULL)*/
	apresF Varchar(4), /*(dans "pion", "dame")*/

	Primary Key (id),
	
	Constraint fk_partie2 Foreign Key (idPartie) References Parties(id)
);