**free
ctl-opt nomain;

dcl-proc addPc export;
    dcl-pi *n ind;
        idPartie int(10) const;
        x int(10) const;
        y int(10) const;
        couleur varchar(5) const;
        forme varchar(4) const;
    end-pi;

    dcl-s rowsInserted int(10);

    exec sql INSERT INTO GBARDELA1.Pieces
                (idPartie, x, y, couleur, forme)
             VALUES (:idPartie, :x, :y, :couleur, :forme);

    exec sql GET DIAGNOSTICS :rowsInserted = ROW_COUNT;

    return (SQLCODE = 0 and rowsInserted = 1);
end-proc;