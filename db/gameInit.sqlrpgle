**free
ctl-opt main(initChckrs) dftactgrp(*no) actgrp(*new);

dcl-proc initChckrs;

    //récupération de l'id maximum
    dcl-s maxId int(4) inz(0);

    exec sql SELECT Max(id) INTO maxId FROM IBMi_PROJECT.Parties;

    //initialisation des infos générales de la partie
    maxId += 1;
    dcl-c etatInit 'blancJoue';

    exec sql 
        INSERT INTO IBMi_PROJECT.Parties (id, etat)
        VALUES (:maxId, :etatInit);
    
  
end-proc;
