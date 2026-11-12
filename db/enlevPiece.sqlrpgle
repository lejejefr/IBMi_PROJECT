**free
ctl-opt nomain;

dcl-proc removePc;
    dcl-pi *n ind;
        idPartie int(10) const;
        x int(10) const;
        y int(10) const;
    end-pi;
    
    exec sql DELETE FROM LEBOULLIO1.Pieces
            WHERE x = :x AND y = :y AND idPartie = :idPartie;

    return sqlcode = 0;
end-proc;