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
end-ds;

dcl-pr initChckrs extproc('INITCHCKRS');
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
    dcl-s reponse char(10);
    dcl-s saisie  varchar(52);
    dcl-s fromX int(10);
    dcl-s fromY int(10);
    dcl-s toX   int(10);
    dcl-s toY   int(10);
    dcl-s valide ind;

    // init game
    initChckrs();

    exec sql SELECT MAX(id) INTO :idPartie FROM LEBOULLIO1.Parties;

    msg = 'Partie creee. Coup: xyXY (ex 2334), q=quitter';
    dsply msg;

    dow *on;

        // état de la partie
        info = getGame(idPartie);

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

        // wait input
        msg = 'Tour des ' + couleur + ' (' + info.etat + ')';
        dsply msg '' reponse;
        saisie = %trim(reponse);

        if saisie = 'q' or saisie = 'Q';
            leave;
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
            iter;
        endif;

        fromX = %int(%subst(saisie : 1 : 1));
        fromY = %int(%subst(saisie : 2 : 1));
        toX   = %int(%subst(saisie : 3 : 1));
        toY   = %int(%subst(saisie : 4 : 1));

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