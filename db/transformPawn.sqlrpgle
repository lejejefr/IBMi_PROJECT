**free
ctl-opt nomain;

exec sql set option commit = *none;

dcl-proc transformPawn export;
    dcl-pi *n;
        x int(10) const;
        y int(10) const;
    end-pi;

    // transformation du pion en dame
    exec sql UPDATE GBARDELA1.Pieces
             SET forme = 'dame'
             WHERE x = :x AND y = :y AND forme = 'pion';
end-proc;