**free
ctl-opt nomain;

dcl-ds partieInfo_t qualified template;
    trouve ind;
    id int(10);
	etat varchar(10);
end-ds partieInfo_t;

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
            FROM GBARDELA1.Parties
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
