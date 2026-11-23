**free
ctl-opt nomain;
dcl-s msg varchar(52);

//-----------------------------------------------------------
//      updGame permet de mettre à jour l'état d'un partie
//      en base de données. 
//-----------------------------------------------------------

dcl-proc updGame export;
    dcl-pi *n ind;
        id int(10) const;
	    etat varchar(10);
    end-pi;
    
    exec sql UPDATE Parties
            SET etat = :etat
            WHERE id = :id
            WITH NC;
    if sqlcode <> 0;
        msg = 'updGame: SQL ' + %char(sqlcode) + ' ' + sqlstate;
        dsply msg;
    endif;
    return sqlcode = 0 and sqlerrd(3) = 1;
end-proc;