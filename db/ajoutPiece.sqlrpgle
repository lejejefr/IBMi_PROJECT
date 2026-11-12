**free
ctl-opt nomain;

dcl-proc addPc;
    dcl-pi *n ind;
        idPartie_ int(10) const;
        x_ int(10) const;
        y_ int(10) const;
        couleur_ varchar(5) const;
        forme_ varchar(4) const;
    end-pi;
    
    dcl-s idPartie int(10);
    dcl-s x int(10);
    dcl-s y int(10);
    dcl-s couleur varchar(5);
    dcl-s forme varchar(4);

    exec sql INSERT INTO LEBOULLIO1.Pieces
            (idPartie, x, y, couleur, forme)
            VALUES (:idPartie, :x, :y, :couleur, :forme);

    return sqlcode = 0 and sqlerrd(3) = 1;
end-proc;