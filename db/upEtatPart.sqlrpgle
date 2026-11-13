**free
ctl-opt nomain;

dcl-proc updGame export;
    dcl-pi *n ind;
        id int(10) const;
	    etat varchar(10);
    end-pi;
    
    exec sql set option commit = *none;
    
    exec sql UPDATE LEBOULLIO1.Parties
            SET etat = :etat
            WHERE id = :id;

    return sqlcode = 0 and sqlerrd(3) = 1;
end-proc;