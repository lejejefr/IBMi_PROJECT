**free
ctl-opt nomain;

//-----------------------------------------------------------
//      removePc permet de supprimer une pièce du plateau. 
//      Renvoie un idicateur montrant si l'opération s'est
//      bien déroulée.
//-----------------------------------------------------------

dcl-proc removePc export;
    dcl-pi *n ind;
        idPartie int(10) const;
        x int(10) const;
        y int(10) const;
    end-pi;
    
    exec sql set option commit = *none;
    
    exec sql DELETE FROM LEBOULLIO1.Pieces
            WHERE x = :x AND y = :y AND idPartie = :idPartie;

    return sqlcode = 0;
end-proc;