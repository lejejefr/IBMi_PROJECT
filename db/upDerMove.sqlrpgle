**free
ctl-opt nomain;

dcl-proc updLastMv export;
    dcl-pi *n ind;
        id int(10) const;
        dernierX int(10) const;
        dernierY int(10) const;
    end-pi;
    
    exec sql set option commit = *none;
    
    exec sql UPDATE GBARDELA1.Parties
            SET 
                dernierX = :dernierX,
                dernierY = :dernierY
            WHERE id = :id;

    return sqlcode = 0 and sqlerrd(3) = 1;
end-proc;
