**free
ctl-opt nomain;
// .../play/upPartie.rpgle
dcl-ds partieInfo_t qualified template;
    trouve ind;
    id int(10);
	etat varchar(10);
end-ds partieInfo_t;


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


dcl-pr getGame likeds(partieInfo_t) extproc('GETGAME');
    id int(10) const;
end-pr;


dcl-pr listPc likeds(equipe_t) extproc('LISTPC');
  idPartie_ int(10) const;
  couleur_ varchar(5) const;
end-pr;


dcl-pr getPc likeds(pieceInfo_t) extproc('GETPC');
  idPartie_ int(10) const;
  x_ int(10) const;
  y_ int(10) const;
end-pr;


dcl-pr updateLastMove ind extproc('UPDLASTMV');
    id int(10) const;
    dernierX int(10) const;
    dernierY int(10) const;
end-pr;


dcl-pr updateGame ind extproc('UPDGAME');
    id int(10) const;
    etat varchar(10);
end-pr;

dcl-ds info likeds(partieInfo_t);
dcl-ds piece likeds(pieceInfo_t);
dcl-ds voisin1 likeds(pieceInfo_t);
dcl-ds voisin2 likeds(pieceInfo_t);
dcl-s directionX int(10);
dcl-s directionY int(10);
dcl-s i int(10);
dcl-ds equipeAdv likeds(equipe_t);

dcl-s blancGagne varchar(10) inz('blancGagne');
dcl-s noirGagne varchar(10) inz('noirGagne');
dcl-s blancRafle varchar(10) inz('blancRafle');
dcl-s noirRafle varchar(10) inz('noirRafle');
dcl-s blancJoue varchar(10) inz('blancJoue');
dcl-s noirJoue varchar(10) inz('noirJoue');
dcl-s blanc varchar(5) inz('blanc');
dcl-s noir varchar(5) inz('noir');

dcl-proc upGame export;
    dcl-pi *n ind;
        id int(10) const;
        originX int(10) const;
        originY int(10) const;
        targetX int(10) const;
        targetY int(10) const;
    end-pi;
    info = getGame(id);

    piece = getPc(id : targetX : targetY);
    

    if not piece.trouve;
        return *OFF;
    endif;

    //check gagne
    if info.etat in %list(blancGagne : noirGagne);
        return *OFF;
    endif;

    if info.etat in %list(blancJoue : blancRafle);
        equipeAdv = listPc(id : noir);
        if equipeAdv.nb = 0;
            updateGame(id : blancGagne);
            updateLastMove(id : targetX : targetY);
            return *ON;
        endif;
    endif;

    if info.etat in %list(noirJoue : noirRafle);
        equipeAdv = listPc(id : blanc);
        if equipeAdv.nb = 0;
            updateGame(id : noirGagne);
            updateLastMove(id : targetX : targetY);
            return *ON;
        endif;
    endif;

    //check rafle
    if %abs(targetX - originX) = 2 and %abs(targetY - originY) = 2;

        for i = 1 to 4;
            select;
                when i = 1;
                    directionX = 1;
                    directionY = 1;
                when i = 2;
                    directionX = 1;
                    directionY = -1;
                when i = 3;
                    directionX = -1;
                    directionY = -1;
                other;
                    directionX = -1;
                    directionY = 1;
            endsl;

            if 2 * directionX + targetX < 1 or 2 * directionY + targetY < 1 or 2 * directionX + targetX > 8 or 2 * directionY + targetY > 8;
                iter;
            endif;
            
            voisin1 = getPc(id : directionX + targetX : directionY + targetY);
            voisin2 = getPc(id : 2 * directionX + targetX : 2 * directionY + targetY);

            if voisin1.trouve and not voisin2.trouve and voisin1.couleur <> piece.couleur;
                
                if info.etat in %list(blancJoue : blancRafle);
                    updateGame(id : blancRafle);
                endif;

                if info.etat in %list(noirJoue : noirRafle);
                    updateGame(id : noirRafle);
                endif;
                updateLastMove(id : targetX : targetY);
                return *ON;
            endif;

        endfor;
        
    endif;

    //check passe la main
    if info.etat in %list(blancJoue : blancRafle);
        updateGame(id : noirJoue);
    endif;

    if info.etat in %list(noirJoue : noirRafle);
        updateGame(id : blancJoue);
    endif;
    updateLastMove(id : targetX : targetY);
    return *ON;
    
end-proc;
