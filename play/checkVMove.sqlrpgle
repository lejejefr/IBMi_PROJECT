**free
ctl-opt nomain;

dcl-ds partieInfo_t qualified template;
    trouve ind;
    id int(10);
    etat varchar(10);
    dernierX int(10);
    dernierY int(10);
end-ds;

dcl-ds move qualified template;
    idPartie int(10);
    couleur varchar(5);
    originX int(10);
    originY int(10);
    targetX int(10);
    targetY int(10);
end-ds;

dcl-ds moveList qualified template;
    count int(10);
    moves likeds(move) dim(48);
end-ds;

dcl-pr getGame likeds(partieInfo_t) extproc('GETGAME');
    id int(10) const;
end-pr;

dcl-pr listMoves likeds(moveList) extproc('LISTMOVES');
    idPartie int(10) const;
    couleur varchar(5) const;
end-pr;

dcl-pr listRafles likeds(moveList) extproc('LISTRAFLES');
    idPartie int(10) const;
    couleur varchar(5) const;
end-pr;

dcl-pr listTakes likeds(moveList) extproc('LISTTAKES');
    idPartie int(10) const;
    couleur varchar(5) const;
end-pr;

// ------------------------------------------------------------
//      listValidMoves permet de lister les coups autorisés.
//      La prise et la rafle sont obligatoires.
// ------------------------------------------------------------

dcl-proc listValidMoves export;
    dcl-pi *n likeds(moveList);
        info likeds(partieInfo_t) const;
        couleur varchar(5) const;
    end-pi;
  dcl-ds moves likeds(moveList);

    moves = listRafles(info.id:couleur);

    if moves.count = 0;
        moves = listTakes(info.id:couleur);
        if moves.count = 0;
            moves = listMoves(info.id:couleur);
        endif;
    endif;

    return moves;
end-proc;

// ------------------------------------------------------------
//      checkMove permet de vérifier si un coup appartient 
//      à la liste des coups autorisés.
// ------------------------------------------------------------

dcl-proc checkMove export;
    dcl-pi *n ind;
        id_partie int(10) const;
        fromX int(10) const;
        fromY int(10) const;
        toX int(10) const;
        toY int(10) const;
        couleur varchar(5) const;
    end-pi;
    dcl-ds info likeds(partieInfo_t);
    dcl-ds moves likeds(moveList);
    dcl-s i int(10);
    info = getGame(id_partie);
    moves = listValidMoves(info:couleur);
    for i = 1 to moves.count;
        if fromX <> moves.moves(i).originX;
            iter;
        elseif fromY <> moves.moves(i).originY;
            iter;
        elseif toX <> moves.moves(i).targetX;
            iter;
        elseif toY <> moves.moves(i).targetY;
            iter;
        elseif toY <> moves.moves(i).targetY;
            iter;
        elseif couleur <> moves.moves(i).couleur;
            iter;
        endif; 
        return *ON;
    endfor;
    return *OFF;
end-proc;