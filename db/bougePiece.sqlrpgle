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

    dcl-s rowsUpdated int(10);

    exec sql UPDATE GBARDELA1.Pieces
                SET x = :targetX, y = :targetY
              WHERE idPartie = :idPartie
                AND x = :origineX
                AND y = :origineY;

    exec sql GET DIAGNOSTICS :rowsUpdated = ROW_COUNT;

    return (SQLCODE = 0 and rowsUpdated = 1);
end-proc;