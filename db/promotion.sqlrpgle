**free
ctl-opt nomain;

exec sql set option commit = *none;

//-----------------------------------------------------------
//      promote permet de promouvoir une pièce à une
//      position donnée.
//-----------------------------------------------------------

dcl-proc promote export;
    dcl-pi *n;
        idPartie int(10) const;
        x int(10) const;
        y int(10) const;
    end-pi;
    
    exec sql UPDATE Pieces
             SET forme = 'dame'
             WHERE idPartie = :idPartie AND x = :x AND y = :y AND forme = 'pion';
end-proc;