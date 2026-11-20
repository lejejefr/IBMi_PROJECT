**free
ctl-opt nomain;

dcl-ds pieceInfo_t qualified template;
    trouve ind;
    idPartie int(10);
    x int(10);
    y int(10);
    couleur varchar(5);
    forme varchar(4);
end-ds pieceInfo_t;

//-----------------------------------------------------------
//      getPc permet de récupérer les infos d'une pièce
//      située sur une case spécifique du plateau.
//      pieceInfo_t.trouve si la case ciblée ne contient 
//      aucune pièce.
//-----------------------------------------------------------

dcl-proc getPc export;
    dcl-pi *n likeds(pieceInfo_t);
        idPartie_ int(10) const;
        x_ int(10) const;
        y_ int(10) const;
    end-pi;

    dcl-ds info likeds(pieceInfo_t);

    dcl-s couleur_ varchar(5);
    dcl-s forme_ varchar(4);

    clear info;

    exec sql 
            SELECT couleur, forme 
            INTO :couleur_, :forme_
            FROM LEBOULLIO1.Pieces
            WHERE idPartie = :idPartie_ AND x = :x_ AND y = :y_;
    
    if sqlcode = 0;
        info.trouve = *ON;
        info.idPartie = idPartie_;
        info.x = x_;
        info.y = y_;
        info.couleur = couleur_;
        info.forme = forme_;
    else;
        info.trouve = *OFF;
    endif;
    
    return info;
end-proc;
