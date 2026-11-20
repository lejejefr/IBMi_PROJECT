**free
ctl-opt nomain;

dcl-s maxId int(10) inz(0);
dcl-s etatInit varchar(10) inz('blancJoue');
dcl-s forme varchar(4) inz('pion');

dcl-s pionX int(10);
dcl-s pionY int(10);
dcl-s pionC varchar(5);

//-----------------------------------------------------------
//      initChckrs crée une nouvelle partie et 
//      initialise le plateau. 
//
//      Le plateau fait 8x8 cases, avec 12 pièces par 
//      équipe.      
//-----------------------------------------------------------

dcl-proc initChckrs export;

    dcl-pi *n int(10);
    end-pi;

    dcl-s msg varchar(52);
    dcl-s x int(10);
    dcl-s y int(10);
    exec sql set option commit = *none;

    // récupération de l'id maximum
    exec sql SELECT COALESCE(MAX(id), 0) INTO :maxId
             FROM LEBOULLIO1.Parties;

    maxId += 1;

    // initialisation de la partie
    exec sql INSERT INTO LEBOULLIO1.Parties (id, etat, dernierX, dernierY)
             VALUES (:maxId, :etatInit, 1, 1);
    if sqlcode <> 0;
        msg = 'Parties: SQL ' + %char(sqlcode) + ' ' + sqlstate;
        dsply msg;
        return -1;
    endif;
    
    for y = 1 to 3;
        for x = 1 to 8;
            if %rem(x + y : 2) = 0;
                pionX = x;
                pionY = y;
                pionC = 'blanc';
                exec sql INSERT INTO LEBOULLIO1.Pieces
                             (idPartie, x, y, couleur, forme)
                         VALUES (:maxId, :pionX, :pionY, :pionC, :forme);
                if sqlcode <> 0;
                    msg = 'Pieces: SQL ' + %char(sqlcode) + ' ' + sqlstate;
                    dsply msg;
                    return -1;
                endif;
            endif;
        endfor;
    endfor;
    
    for y = 6 to 8;
        for x = 1 to 8;
            if %rem(x + y : 2) = 0;
                pionX = x;
                pionY = y;
                pionC = 'noir';
                exec sql INSERT INTO LEBOULLIO1.Pieces
                             (idPartie, x, y, couleur, forme)
                         VALUES (:maxId, :pionX, :pionY, :pionC, :forme);
            endif;
        endfor;
    endfor;

    return maxId;
end-proc;