**free
ctl-opt nomain;
// .../db/creePartie.sqlrpgle
dcl-proc addGame export;
    dcl-pi *n int(10);
    end-pi;
    
    dcl-s maxId int(10) inz(0);
    dcl-s etatInit varchar(10) inz('blancJoue');

    exec sql set option commit = *none;

    exec sql SELECT COALESCE(MAX(id), 0) INTO :maxId
             FROM LEBOULLIO1.Parties;

    maxId += 1;

    exec sql INSERT INTO LEBOULLIO1.Parties (id, etat)
             VALUES (:maxId, :etatInit);
    
    return maxId;
end-proc;
