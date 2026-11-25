**free
ctl-opt nomain;

// procédure mise à jour des coordonnées du dernier mouvement dans la table Parties
dcl-proc updermove export;
    dcl-pi updermove ind;
        id int(10) const;
        dernierX int(10) const;
        dernierY int(10) const;
    end-pi;

    dcl-s rowsUpdated int(10);

    exec sql UPDATE Parties
             SET dernierX = :dernierX,
                 dernierY = :dernierY
             WHERE id = :id;

    exec sql GET DIAGNOSTICS :rowsUpdated = ROW_COUNT;

    return (SQLCODE = 0 and rowsUpdated = 1);
end-proc;