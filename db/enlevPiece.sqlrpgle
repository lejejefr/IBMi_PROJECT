**free
ctl-opt nomain;
// Procédure suppression d'une pièce dans la table Pieces
dcl-proc removePc export;
    dcl-pi removePc ind;
        idPartie int(10) const;
        x int(10) const;
        y int(10) const;
    end-pi;

    dcl-s rowsDeleted int(10);

    exec sql DELETE FROM Pieces
             WHERE x = :x AND y = :y AND idPartie = :idPartie;

    exec sql GET DIAGNOSTICS :rowsDeleted = ROW_COUNT;

    return (SQLCODE = 0 and rowsDeleted = 1);
end-proc;