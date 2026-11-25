**free
ctl-opt nomain;

exec sql set option commit = *none;

// procédure mise à jour de l'état d'une partie dans la table Parties
dcl-proc upEtatPart export;
    dcl-pi upEtatPart ind;
        id int(10) const;
        etat varchar(10) const;
    end-pi;

    dcl-s rowsUpdated int(10);

    exec sql UPDATE Parties
             SET etat = :etat
             WHERE id = :id;

    exec sql GET DIAGNOSTICS :rowsUpdated = ROW_COUNT;

    return (SQLCODE = 0 and rowsUpdated = 1);
end-proc;