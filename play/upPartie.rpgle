**free
ctl-opt nomain;

dcl-ds partieInfo_t qualified template;
    trouve ind;
    id     int(10);
    etat   varchar(10);
end-ds;

dcl-ds pieceInfo_t qualified template;
    trouve   ind;
    idPartie int(10);
    x        int(10);
    y        int(10);
    couleur  varchar(5);
    forme    varchar(5);
end-ds;

dcl-ds equipe_t qualified template;
    nb     int(10);
    pieces likeds(pieceInfo_t) dim(12);
end-ds;

// ------------------------------------------------------------
// Prototypes externes
// ------------------------------------------------------------
dcl-pr getGame likeds(partieInfo_t) extproc('GETPARTIE');
    id int(10) const;
end-pr;

dcl-pr listPc likeds(equipe_t) extproc('LISTPIECE');
    idPartie_ int(10) const;
    couleur_  varchar(5) const;
end-pr;

dcl-pr getPc likeds(pieceInfo_t) extproc('GETPIECE');
    idPartie_ int(10) const;
    x_        int(10) const;
    y_        int(10) const;
end-pr;

dcl-pr updateLastMove ind extproc('UPDERMOVE');
    id      int(10) const;
    dernierX int(10) const;
    dernierY int(10) const;
end-pr;

dcl-pr updateGame ind extproc('UPETATPART');
    id   int(10) const;
    etat varchar(10) const;
end-pr;

// ------------------------------------------------------------
// Procédure exportée
// ------------------------------------------------------------
dcl-proc upPartie export;
    dcl-pi upPartie ind;
        id      int(10) const;
        originX int(10) const;
        originY int(10) const;
        targetX int(10) const;
        targetY int(10) const;
    end-pi;

    dcl-ds info      likeds(partieInfo_t);
    dcl-ds piece     likeds(pieceInfo_t);
    dcl-ds voisin1   likeds(pieceInfo_t);
    dcl-ds voisin2   likeds(pieceInfo_t);
    dcl-ds equipeAdv likeds(equipe_t);
    dcl-s directionX int(10);
    dcl-s directionY int(10);
    dcl-s i          int(10);
    dcl-s rafle      ind;

    // 1) Charger la partie
    info = getGame(id);
    if not info.trouve;
        return *off;
    endif;

    // 2) La pièce cible doit exister (elle vient d'être déplacée)
    piece = getPc(id : targetX : targetY);
    if not piece.trouve;
        dsply 'STOP step 2: piece non trouvee';
        return *off;
    endif;

    // 3) Partie déjà terminée ?
    if info.etat in %list('blancGagne' : 'noirGagne');
        dsply 'Noir gagne, ou blanc gagne';
        return *off;
    endif;

    // 4) Vérifier si l'adversaire n'a plus de pièces -> victoire
    if info.etat in %list('blancJoue' : 'blancRafle');
        equipeAdv = listPc(id : 'noir');
        if equipeAdv.nb = 0;
            updateGame(id : 'blancGagne');
            updateLastMove(id : targetX : targetY);
            return *on;
        endif;
    endif;

    if info.etat in %list('noirJoue' : 'noirRafle');
        equipeAdv = listPc(id : 'blanc');
        if equipeAdv.nb = 0;
            updateGame(id : 'noirGagne');
            updateLastMove(id : targetX : targetY);
            return *on;
        endif;
    endif;

    // 5) Détection d'une rafle : le coup était une prise (distance 2)
    rafle = *off;
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

            // Les 2 cases voisines doivent être dans le plateau
            if targetX + 2 * directionX < 1 or targetX + 2 * directionX > 8
               or targetY + 2 * directionY < 1 or targetY + 2 * directionY > 8;
                iter;
            endif;

            voisin1 = getPc(id : targetX + directionX : targetY + directionY);
            voisin2 = getPc(id : targetX + 2 * directionX : targetY + 2 * directionY);

            // Une pièce adverse devant, et la case derrière est libre
            if voisin1.trouve
               and not voisin2.trouve
               and voisin1.couleur <> piece.couleur;
                rafle = *on;
                leave;
            endif;
        endfor;

        if rafle;
            if info.etat in %list('blancJoue' : 'blancRafle');
                updateGame(id : 'blancRafle');
            else;
                updateGame(id : 'noirRafle');
            endif;
            updateLastMove(id : targetX : targetY);
            return *on;
        endif;
    endif;

    // 6) Pas de rafle -> on passe la main
    if info.etat in %list('blancJoue' : 'blancRafle');
        updateGame(id : 'noirJoue');
    else;
        updateGame(id : 'blancJoue');
    endif;

    updateLastMove(id : targetX : targetY);
    return *on;
end-proc;