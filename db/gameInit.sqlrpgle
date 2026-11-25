**free
ctl-opt nomain;

dcl-s maxId int(10) inz(0);
dcl-s etatInit varchar(10) inz('blancJoue');
dcl-s forme varchar(5) inz('pion');
dcl-s pionX int(10);
dcl-s pionY int(10);
dcl-s pionC varchar(5);
dcl-s x int(10);
dcl-s y int(10);

// procédure d'initialisation d'une partie de jeu de dames
dcl-proc initChckrs export;
    dcl-pi *n int(10);
    end-pi;

    // récupération de l'id maximum
    exec sql SELECT COALESCE(MAX(id), 0) INTO :maxId
             FROM Parties;

    maxId += 1;

    // initialisation de la partie
    exec sql INSERT INTO Parties (id, etat)
             VALUES (:maxId, :etatInit);

    // pions blancs : lignes 1 à 3
    for y = 1 to 3;
        for x = 1 to 8;
            if %rem(x + y : 2) = 0;
                pionX = x;
                pionY = y;
                pionC = 'blanc';
                exec sql INSERT INTO Pieces
                             (idPartie, x, y, couleur, forme)
                         VALUES (:maxId, :pionX, :pionY, :pionC, :forme);
            endif;
        endfor;
    endfor;

    // pions noirs : lignes 6 à 8
    for y = 6 to 8;
        for x = 1 to 8;
            if %rem(x + y : 2) = 0;
                pionX = x;
                pionY = y;
                pionC = 'noir';
                exec sql INSERT INTO Pieces
                             (idPartie, x, y, couleur, forme)
                         VALUES (:maxId, :pionX, :pionY, :pionC, :forme);
            endif;
        endfor;
    endfor;

    return maxId;

end-proc;