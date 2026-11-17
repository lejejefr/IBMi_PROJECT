**free
ctl-opt nomain;

dcl-proc promote export;
    dcl-pi promote ind;
        idPartie int(10) const;
        x int(10) const;
        y int(10) const;
    end-pi;

    dcl-s rowsUpdated int(10);

    exec sql UPDATE GBARDELA1.Pieces
             SET forme = 'dame'
             WHERE idPartie = :idPartie AND x = :x AND y = :y AND forme = 'pion';

    exec sql GET DIAGNOSTICS :rowsUpdated = ROW_COUNT;

    return (SQLCODE = 0 and rowsUpdated = 1);
end-proc;