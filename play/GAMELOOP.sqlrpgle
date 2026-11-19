**free
ctl-opt main(jouer);
// .../play/GAMELOOP.sqlrpgle
// Si vos procédures sont dans un binding directory, ajoutez-le :
// ctl-opt dftactgrp(*no) actgrp(*new) main(jouer) bnddir('MONBNDDIR');

// ------------------------------------------------------------
// Prototypes
// ------------------------------------------------------------
dcl-ds partieInfo_t qualified template;
    trouve ind;
    id int(10);
    etat varchar(10);
    dernierX int(10);
    dernierY int(10);
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

dcl-ds tentative_coup qualified template;
    fromX int(10);
    fromY int(10);
    toX int(10);
    toY int(10);
    quit ind;
    pass ind;
end-ds;

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

dcl-pr initChckrs int(10) extproc('INITCHCKRS');
end-pr;

dcl-pr getGame likeds(partieInfo_t) extproc('GETGAME');
    id int(10) const;
end-pr;

dcl-pr checkValidityMove ind extproc('CHECKVALIDITYMOVE');
    idPartie int(10) const;
    fromX    int(10) const;
    fromY    int(10) const;
    toX      int(10) const;
    toY      int(10) const;
end-pr;

dcl-pr play ind extproc('PLAY');
    idPartie int(10) const;
    couleur  varchar(5) const;
    originX  int(10) const;
    originY  int(10) const;
    targetX  int(10) const;
    targetY  int(10) const;
end-pr;

dcl-pr upGame ind extproc('UPGAME');
    id      int(10) const;
    originX int(10) const;
    originY int(10) const;
    targetX int(10) const;
    targetY int(10) const;
end-pr;

dcl-pr listPc likeds(equipe_t) extproc('LISTPC');
    idPartie_ int(10) const;
    couleur_ varchar(5) const;
end-pr;

dcl-pr coupJoueur likeds(tentative_coup) extproc('COUPJOUEUR');
    info likeds(partieInfo_t) const;
    couleur varchar(5) const;
end-pr;

dcl-pr coupBot likeds(tentative_coup) extproc('COUPBOT');
    info likeds(partieInfo_t) const;
    couleur varchar(5) const;
end-pr;

dcl-pr listMoves likeds(moveList) extproc('LISTMOVES');
    idPartie int(10);
    couleur varchar(5);
end-pr;

dcl-pr listRafles likeds(moveList) extproc('LISTRAFLES');
    idPartie int(10);
    couleur varchar(5);
end-pr;

dcl-pr listTakes likeds(moveList) extproc('LISTTAKES');
    idPartie int(10);
    couleur varchar(5);
end-pr;
// ------------------------------------------------------------
// Affichage du damier
// . case inaccessible   + case libre accessible
// n/N pion/dame noir    b/B pion/dame blanc
// ------------------------------------------------------------
dcl-proc afficherDamier;
    dcl-pi *n;
        idPartie int(10) const;
    end-pi;

    dcl-s grille char(8) dim(8);
    dcl-s x int(10);
    dcl-s y int(10);
    dcl-s i int(10);
    dcl-s ligne varchar(20);
    dcl-ds blancs likeds(equipe_t);
    dcl-ds noirs  likeds(equipe_t);

    // fond du damier : cases foncées = x + y pair (comme dans initChckrs)
    for y = 1 to 8;
        for x = 1 to 8;
            if %rem(x + y : 2) = 0;
                %subst(grille(y) : x : 1) = '+';
            else;
                %subst(grille(y) : x : 1) = '.';
            endif;
        endfor;
    endfor;

    // pièces blanches
    blancs = listPc(idPartie : 'blanc');
    for i = 1 to blancs.nb;
        if blancs.pieces(i).forme = 'dame';
            %subst(grille(blancs.pieces(i).y) : blancs.pieces(i).x : 1) = 'B';
        else;
            %subst(grille(blancs.pieces(i).y) : blancs.pieces(i).x : 1) = 'b';
        endif;
    endfor;

    // pièces noires
    noirs = listPc(idPartie : 'noir');
    for i = 1 to noirs.nb;
        if noirs.pieces(i).forme = 'dame';
            %subst(grille(noirs.pieces(i).y) : noirs.pieces(i).x : 1) = 'N';
        else;
            %subst(grille(noirs.pieces(i).y) : noirs.pieces(i).x : 1) = 'n';
        endif;
    endfor;

    // affichage : y = 8 en haut, y = 1 en bas (les blancs en bas)
    ligne = '  12345678';
    dsply ligne;
    for y = 8 downto 1;
        ligne = %char(y) + ' ' + grille(y);
        dsply ligne;
    endfor;
end-proc;

// ------------------------------------------------------------
// Boucle de jeu
// Saisie d'un coup : 4 chiffres "xyXY" (ex : 2334 = de (2,3) vers (3,4))
//                    q pour quitter
// ------------------------------------------------------------
dcl-proc jouer;

    dcl-s idPartie int(10);
    dcl-ds info likeds(partieInfo_t);
    dcl-s couleur varchar(5);
    dcl-s msg     varchar(40);
    dcl-s fromX int(10);
    dcl-s fromY int(10);
    dcl-s toX   int(10);
    dcl-s toY   int(10);
    dcl-ds coup likeds(tentative_coup);
    // init game
    idPartie = initChckrs();

    exec sql SELECT MAX(id) INTO :idPartie FROM LEBOULLIO1.Parties;

    msg = 'Partie creee. Coup: xyXY (ex 2334), q=quitter';
    dsply msg;

    dow *on;

        // état de la partie
        info = getGame(idPartie);
        afficherDamier(idPartie);
        
        if info.etat = 'blancGagne' or info.etat = 'noirGagne';
            msg = 'Partie terminee : ' + info.etat;
            dsply msg;
            leave;
        endif;

        if %scan('blanc' : info.etat) = 1;
            couleur = 'blanc';
        else;
            couleur = 'noir';
        endif;

        ////
        if couleur = 'blanc';
            coup = coupJoueur(info : couleur);
        else;
            coup = coupBot(info : couleur);
        endif;

        if coup.quit;
            leave;
        elseif coup.pass;
            iter;
        endif;

        fromX = coup.fromX;
        fromY = coup.fromY;
        toX   = coup.toX;
        toY   = coup.toY;

        // check move input
        if not checkValidityMove(idPartie : fromX : fromY : toX : toY);
            msg = 'Coup invalide';
            dsply msg;
            iter;
        endif;

        // play move
        if not play(idPartie : couleur : fromX : fromY : toX : toY);
            msg = 'Erreur pendant le deplacement';
            dsply msg;
            iter;
        endif;

        // update game state (victoire / rafle / changement de joueur)
        if not upGame(idPartie : fromX : fromY : toX : toY);
            msg = 'Erreur mise a jour partie';
            dsply msg;
        endif;
    enddo;

end-proc;

dcl-proc coupJoueur;
    dcl-pi *n likeds(tentative_coup);
        info likeds(partieInfo_t) const;
        couleur varchar(5) const;
    end-pi;

    dcl-ds tentative likeds(tentative_coup);
    dcl-s valide ind;
    dcl-s reponse char(10);
    dcl-s saisie  varchar(52);
    dcl-s msg     varchar(40);

  // wait input
    msg = 'Tour des ' + couleur + ' (' + info.etat + ')';
    dsply msg '' reponse;
    saisie = %trim(reponse);

    if saisie = 'q' or saisie = 'Q';
        tentative.quit  = *ON;
        tentative.pass  = *OFF;

        return tentative;
    endif;

    // vérification du format de la saisie
    valide = *off;
    if %len(saisie) = 4;
        if %check('12345678' : saisie) = 0;
            valide = *on;
        endif;
    endif;

    if not valide;
        msg = 'Saisie invalide (ex : 2334)';
        dsply msg;
        tentative.quit  = *OFF;
        tentative.pass  = *ON;

        return tentative;
    endif;

    tentative.fromX = %int(%subst(saisie : 1 : 1));
    tentative.fromY = %int(%subst(saisie : 2 : 1));
    tentative.toX   = %int(%subst(saisie : 3 : 1));
    tentative.toY   = %int(%subst(saisie : 4 : 1));
    tentative.quit  = *OFF;
    tentative.pass  = *OFF;

    return tentative;

end-proc;


dcl-proc coupBot;
    dcl-pi *n likeds(tentative_coup);
        info likeds(partieInfo_t) const;
        couleur varchar(5) const;
    end-pi;

    dcl-ds tentative likeds(tentative_coup);
    dcl-s valide ind;
    dcl-s reponse char(10);
    dcl-s saisie  varchar(52);
    dcl-s msg     varchar(40);

  // wait input
    msg = 'Tour des ' + couleur + ' (' + info.etat + ')';
    dsply msg '' reponse;
    saisie = %trim(reponse);

    if saisie = 'q' or saisie = 'Q';
        tentative.quit  = *ON;
        tentative.pass  = *OFF;

        return tentative;
    endif;

    // vérification du format de la saisie
    valide = *off;
    if %len(saisie) = 4;
        if %check('12345678' : saisie) = 0;
            valide = *on;
        endif;
    endif;

    if not valide;
        msg = 'Saisie invalide (ex : 2334)';
        dsply msg;
        tentative.quit  = *OFF;
        tentative.pass  = *ON;

        return tentative;
    endif;

    tentative.fromX = %int(%subst(saisie : 1 : 1));
    tentative.fromY = %int(%subst(saisie : 2 : 1));
    tentative.toX   = %int(%subst(saisie : 3 : 1));
    tentative.toY   = %int(%subst(saisie : 4 : 1));
    tentative.quit  = *OFF;
    tentative.pass  = *OFF;

    return tentative;

end-proc;
