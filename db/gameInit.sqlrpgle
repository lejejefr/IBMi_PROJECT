**free
ctl-opt main(initChckrs) dftactgrp(*no) actgrp(*new);

dcl-proc initChckrs;

    //récupération de l'id maximum
    dcl-s maxId int(4) inz(0);

    exec sql SELECT Max(id) INTO :maxId FROM IBMi_PROJECT.Parties;

    //initialisation des infos générales de la partie
    maxId += 1;
    dcl-c etatInit 'blancJoue';

    exec sql 
        INSERT INTO IBMi_PROJECT.Parties (id, etat)
        VALUES (:maxId, :etatInit);
    
    //initialisation de la position des pions
    dcl-ds pions qualified dim(24);
      x int(4);
      y int(4);
      couleur varchar(5);
    end-ds;
    
    dcl-s forme varchar(4) inz('pion');
    dcl-s count int(4) inz(0);

        //initialisation des pions blancs
    for-each i in %list(1:3:5:7);
        count += 1;
        pions(count).x = i;
        pions(count).y = 1;
        pions(count).couleur = "blanc";
    endfor;

    for-each i in %list(2:4:6:8);
        count += 1;
        pions(count).x = i;
        pions(count).y = 2;
        pions(count).couleur = "blanc";
    endfor;

    for-each i in %list(1:3:5:7);
        count += 1;
        pions(count).x = i;
        pions(count).y = 3;
        pions(count).couleur = "blanc";
    endfor;

        //initialisation des pions noirs
    for-each i in %list(2:4:6:8);
        count += 1;
        pions(count).x = i;
        pions(count).y = 6;
        pions(count).couleur = "noir";
    endfor;

    for-each i in %list(1:3:5:7);
        count += 1;
        pions(count).x = i;
        pions(count).y = 7;
        pions(count).couleur = "noir";
    endfor;

    for-each i in %list(2:4:6:8);
        count += 1;
        pions(count).x = i;
        pions(count).y = 8;
        pions(count).couleur = "noir";
    endfor;
    
    for-each pion in pions;
        exec sql INSERT INTO IBMi_PROJECT.Pieces (idPartie, x, y, couleur, forme)
            VALUES (:maxId,:pion.x,:pion.y,:pion.couleur,:forme);
    endfor;
  
end-proc;
