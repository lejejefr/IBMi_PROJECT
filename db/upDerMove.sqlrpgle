**free
ctl-opt nomain;

dcl-s msg varchar(52);

//-----------------------------------------------------------
//      updLastMv permet de modifier la dernière position
//      jouée dans la partie en base de données. Nécessaire
//      pour déterminer les coups disponibles lors d'une rafle.
//-----------------------------------------------------------

dcl-proc updLastMv export;
    dcl-pi *n ind;
        id int(10) const;
        dernierX int(10) const;
        dernierY int(10) const;
    end-pi;
    
    exec sql UPDATE LEBOULLIO1.Parties
            SET 
                dernierX = :dernierX,
                dernierY = :dernierY
            WHERE id = :id
            WITH NC;
    if sqlcode <> 0;
        msg = 'updGame: SQL ' + %char(sqlcode) + ' ' + sqlstate;
        dsply msg;
    endif;
    return sqlcode = 0 and sqlerrd(3) = 1;
end-proc;
