**free
ctl-opt nomain;
// .../db/listMoves/listRafles.sqlrpgle

dcl-ds move qualified template;
    idPartie int(10);
    couleur  varchar(5);
    originX  int(10);
    originY  int(10);
    targetX  int(10);
    targetY  int(10);
end-ds;

dcl-ds moveList qualified template;
    count int(10);
    moves likeds(move) dim(48);
end-ds;

dcl-ds pieceInfo_t qualified template;
    trouve ind;
    idPartie int(10);
    x int(10);
    y int(10);
    couleur varchar(5);
    forme varchar(4);
end-ds;


dcl-ds equipe_t qualified template;
    nb int(10);
    pieces likeds(pieceInfo_t) dim(12);
end-ds;

dcl-ds partieInfo_t qualified template;
    trouve ind;
    id int(10);
	etat varchar(10);
    dernierX int(10);
    dernierY int(10);
end-ds;

dcl-pr getGame likeds(partieInfo_t) extproc('GETGAME');
    id int(10);
end-pr;

dcl-pr listPc likeds(equipe_t) extproc('LISTPC');
    idPartie_ int(10) const;
    couleur_ varchar(5) const;
end-pr;

dcl-pr getPc likeds(pieceInfo_t) extproc('GETPC');
    idPartie_ int(10);
    x_ int(10);
    y_ int(10);
end-pr;

dcl-proc listRafles export;
    dcl-pi *n likeds(moveList);
        idPartie int(10);
        couleur varchar(5);
    end-pi;
    dcl-ds pieces likeds(equipe_t);
    dcl-s i int(10);
    dcl-ds moves likeds(moveList);
    dcl-s targetX int(10);
    dcl-s targetY int(10);
    dcl-ds targetPiece likeds(pieceInfo_t);
    dcl-ds gameData likeds(partieInfo_t);
    dcl-ds pionRafle likeds(pieceInfo_t);

    pieces = listPc(idPartie : couleur);
    moves.count = 0;

    gameData = getGame(idPartie);

    if not gameData.trouve;
        return moves;
    endif;
    
    pionRafle = getPc(idPartie:gameData.dernierX:gameData.dernierY);
    
    if not pionRafle.trouve;
        return moves;
    endif;
    
    for-each j in %list(1:2:3:4);
        if j = 1;
            targetX = 1;
            targetY = 1;
        elseif j = 2;
            targetX = - 1;
            targetY = 1;
        elseif j = 3;
            targetX = - 1;
            targetY = - 1;
        elseif j = 4;
            targetX = 1;
            targetY = - 1;
        endif;
        //check bordure du plateau
        if pionRafle.x + targetX * 2 > 8 or pionRafle.x + targetX * 2 < 1
            iter;
        elseif pionRafle.y + targetY * 2 > 8 or pionRafle.y + targetY * 2 < 1;
            iter;
        endif;

        //check case disponible
        targetPiece = getPc(idPartie,pionRafle.x + targetX * 2, pionRafle.y + targetY * 2);
        if targetPiece.trouve;
            iter;
        endif;

        //check piece prenable
        targetPiece = getPc(idPartie,pionRafle.x + targetX, pionRafle.y + targetY);
        if not targetPiece.trouve;
            iter;
        endif;

        moves.count = moves.count + 1;
        moves.moves(moves.count).couleur = couleur;
        moves.moves(moves.count).idPartie = idPartie;
        moves.moves(moves.count).originX = pionRafle.x;
        moves.moves(moves.count).originY = pionRafle.y;
        moves.moves(moves.count).targetX = pionRafle.x + targetX * 2;
        moves.moves(moves.count).targetY = pionRafle.y + targetY * 2;
    endfor;

    return moves;
end-proc;
