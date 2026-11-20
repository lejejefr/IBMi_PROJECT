**free
ctl-opt nomain;

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
    idPartie_ int(10) const;
    x_ int(10) const;
    y_ int(10) const;
end-pr;

//-----------------------------------------------------------
//      listMoves permet de lister les prises
//      possibles en l'absence de rafle.
//-----------------------------------------------------------

dcl-proc listTakes export;
    dcl-pi *n likeds(moveList);
        idPartie int(10) const;
        couleur varchar(5) const;
    end-pi;
    dcl-ds pieces likeds(equipe_t);
    dcl-s i int(10);
    dcl-s j int(10);
    dcl-ds moves likeds(moveList);
    dcl-s targetX int(10);
    dcl-s targetY int(10);
    dcl-ds targetPiece likeds(pieceInfo_t);

    pieces = listPc(idPartie : couleur);
    moves.count = 0;

    for i = 1 to pieces.nb;
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
            if pieces.pieces(i).x + targetX * 2 > 8 or pieces.pieces(i).x + targetX * 2 < 1;
                iter;
            elseif pieces.pieces(i).y + targetY * 2 > 8 or pieces.pieces(i).y + targetY * 2 < 1;
                iter;
            endif;

            //check case disponible
            targetPiece = getPc(idPartie : pieces.pieces(i).x + targetX * 2 : pieces.pieces(i).y + targetY * 2);
            if targetPiece.trouve;
                iter;
            endif;

            //check piece prenable
            targetPiece = getPc(idPartie : pieces.pieces(i).x + targetX : pieces.pieces(i).y + targetY);
            if not targetPiece.trouve or targetPiece.couleur = pieces.pieces(i).couleur;
                iter;
            endif;

            moves.count = moves.count + 1;
            moves.moves(moves.count).couleur = couleur;
            moves.moves(moves.count).idPartie = idPartie;
            moves.moves(moves.count).originX = pieces.pieces(i).x;
            moves.moves(moves.count).originY = pieces.pieces(i).y;
            moves.moves(moves.count).targetX = pieces.pieces(i).x + targetX * 2;
            moves.moves(moves.count).targetY = pieces.pieces(i).y + targetY * 2;
        endfor;
    endfor;

    return moves;
end-proc;
