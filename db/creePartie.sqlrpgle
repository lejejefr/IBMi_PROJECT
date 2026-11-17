**free
ctl-opt nomain;

dcl-proc addGame export;
    dcl-pi addGame int(10);
    end-pi;

    dcl-s maxId int(10) inz(0);
    dcl-s etatInit varchar(10) inz('blancJoue');

    exec sql SELECT COALESCE(MAX(id), 0) INTO :maxId
             FROM GBARDELA1.Parties;

    maxId += 1;

    exec sql INSERT INTO GBARDELA1.Parties (id, etat)
             VALUES (:maxId, :etatInit);

    return maxId;
end-proc;