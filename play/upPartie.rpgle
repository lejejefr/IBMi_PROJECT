**free
ctl-opt nomain;

dcl-ds partieInfo_t qualified template;
    trouve ind;
    id int(10);
	etat varchar(10);
end-ds partieInfo_t;

dcl-pr getGame likeds(partieInfo_t) extproc('LEBOULLIO1/GETGAME');
    id int(10) const;
end-pr;


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

dcl-pr getTeam likeds(equipe_t) extproc('LEBOULLIO1/LISTPC');
    idPartie_ int(10) const;
    couleur_ varchar(5) const;
end-pr;

dcl-pr getPc likeds(pieceInfo_t) extproc('LEBOULLIO1/GETPC');
  idPartie_ int(10) const;
  x_ int(10) const;
  y_ int(10) const;
end-pr;


dcl-pr updateLastMove ind extproc('LEBOULLIO1/UPDLASTMV');
    id int(10) const;
    dernierX int(10) const;
    dernierY int(10) const;
end-pr;


dcl-pr updateGame ind extpgm('LEBOULLIO1/UPDGAME');
    id int(10) const;
    etat varchar(10);
end-pr;



dcl-proc upGame export;
    dcl-pi *n ind;
        id int(10) const;
        dernierX int(10) const;
        dernierY int(10) const;
    end-pi;

    dcl-ds info likeds(partieInfo_t);
    info = getGame(id);

    dcl-ds piece likeds(pieceInfo_t);
    dcl-ds voisin1 likeds(pieceInfo_t);
    dcl-ds voisin2 likeds(pieceInfo_t);
    dcl-s directionX int(10);
    dcl-s directionY int(10);
    dcl-s i int(10);

    piece = getPc(id : dernierX : dernierY);
    
    if not piece.trouve;
        return *OFF;
    endif;

    //check gagne

    //check rafle
    for i = 1 to 4;
        select;
            when i = 1;
                directionX = 1;
                direction2 = 1;
            when i = 2;
                directionX = 1;
                direction2 = -1;
            when i = 3;
                directionX = -1;
                direction2 = -1;
            other;
                directionX = -1;
                direction2 = 1;
        endsl;

        if 2 * directionX + dernierX < 1 or 2 * directionY + dernierY < 1 or 2 * directionX + dernierX > 8 or 2 * directionY + dernierY > 8;
            iter;
        endif;
        
        voisin1 = getPc(id : directionX + dernierX : directionY + dernierY);
        voisin2 = getPc(id : 2 * directionX + dernierX : 2 * directionY + dernierY);
        if voisin1.trouve and not voisin2.trouve and voisin1.couleur <> piece.couleur;
            //set state
            return *ON;
        endif;

    endfor;

end-proc;
