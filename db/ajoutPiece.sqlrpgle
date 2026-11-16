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
    
    exec sql set option commit = *none;
    
    exec sql INSERT INTO GBARDELA1.Pieces
            (idPartie, x, y, couleur, forme)
            VALUES (:idPartie, :x, :y, :couleur, :forme);

    return sqlcode = 0 and sqlerrd(3) = 1;
end-proc;