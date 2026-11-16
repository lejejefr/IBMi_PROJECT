**free
ctl-opt nomain;

dcl-proc movePiece export;
    dcl-pi *n ind;
        idPartie int(10) const;
        origineX int(10) const;
        origineY int(10) const;
        targetX int(10) const;
        targetY int(10) const;
    end-pi;
    
    exec sql set option commit = *none;
    
    exec sql UPDATE GBARDELA1.Pieces
            SET 
                x = :targetX, y = :targetY
            WHERE 
                idPartie = :idPartie AND 
                x = :origineX AND 
                y = :origineY;

    return sqlcode = 0 and sqlerrd(3) = 1;
end-proc;