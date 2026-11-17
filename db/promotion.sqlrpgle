**free
ctl-opt nomain;
// .../db/promotion.sqlrpgle
exec sql set option commit = *none;

dcl-proc promote export;
    dcl-pi *n;
        idPartie int(10) const;
        x int(10) const;
        y int(10) const;
    end-pi;

    // transformation du pion en dame
    exec sql UPDATE LEBOULLIO1.Pieces
             SET forme = 'dame'
             WHERE idPartie = :idPartie AND x = :x AND y = :y AND forme = 'pion';
end-proc;