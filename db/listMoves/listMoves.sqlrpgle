**free
ctl-opt nomain;
// .../db/listMoves/listMoves.sqlrpgle

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

dcl-pr listPc likeds(equipe_t) extproc('LISTPC');
    idPartie_ int(10) const;
    couleur_ varchar(5) const;
end-pr;

dcl-pr getPc likeds(pieceInfo_t) extproc('GETPC');
    idPartie_ int(10);
    x_ int(10);
    y_ int(10);
end-pr;

dcl-proc listMoves export;
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

    pieces = listPc(idPartie : couleur);
    moves.count = 0;

    for i = 1 to pieces.nb;
        for-each j in %list(1:2:3:4);
            if j = 1;
                targetX = pieces.pieces(i).x + 1;
                targetY = pieces.pieces(i).y + 1;
            elseif j = 2;
                targetX = pieces.pieces(i).x - 1;
                targetY = pieces.pieces(i).y + 1;
            elseif j = 3;
                targetX = pieces.pieces(i).x - 1;
                targetY = pieces.pieces(i).y - 1;
            elseif j = 4;
                targetX = pieces.pieces(i).x + 1;
                targetY = pieces.pieces(i).y - 1;
            endif;
            //check bordure du plateau
            if targetX > 8 or targetX < 1 or targetY > 8 or targetY < 1;
                iter;
            endif;

            //check pions avancent
            if (targetY < pieces.pieces(i).y and pieces.pieces(i).forme = 'pion' and pieces.pieces(i).couleur = 'blanc');
                iter;
            elseif (targetY > pieces.pieces(i).y and pieces.pieces(i).forme = 'pion' and pieces.pieces(i).couleur = 'noir');
                iter;
            endif;

            //check case disponible
            targetPiece = getPc(idPartie,targetX, targetY);
            if targetPiece.trouve;
                iter;
            endif;

            moves.count = moves.count + 1;
            moves.moves(moves.count).couleur = couleur;
            moves.moves(moves.count).idPartie = idPartie;
            moves.moves(moves.count).originX = pieces.pieces(i).x;
            moves.moves(moves.count).originY = pieces.pieces(i).y;
            moves.moves(moves.count).targetX = targetX;
            moves.moves(moves.count).targetY = targetY;
        endfor;
    endfor;

    return moves;
end-proc;
