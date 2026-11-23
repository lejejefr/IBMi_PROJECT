**free
ctl-opt nomain;

dcl-ds partieInfo_t qualified template;
    trouve ind;
    id int(10);
	etat varchar(10);
    dernierX int(10);
    dernierY int(10);
end-ds partieInfo_t;

//-----------------------------------------------------------
//      getGame renvoie les informations d'une partie à
//      partir de son id. partieInfo_t.trouve = *OFF dans
//      le cas où la partie n'a pas été trouvée.
//-----------------------------------------------------------

dcl-proc getGame export;
    dcl-pi *n likeds(partieInfo_t);
        id int(10) const;
    end-pi;

    dcl-ds info likeds(partieInfo_t);

    dcl-s etat_ varchar(10);

    clear info;

    exec sql 
            SELECT etat
            INTO :etat_
            FROM Parties
            WHERE id = :id;
    
    if sqlcode = 0;
        info.trouve = *ON;
        info.id = id;
        info.etat = etat_;
    else;
        info.trouve = *OFF;
    endif;
    
    return info;
end-proc;
