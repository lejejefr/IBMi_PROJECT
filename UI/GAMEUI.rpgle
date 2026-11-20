**free
// ============================================================
// GAMEUI : interface 5250 du jeu de dames
// ============================================================
ctl-opt dftactgrp(*no) actgrp('GAMEUI_ACT') main(GameUIMain);

// ---------- Templates ----------
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

dcl-ds move_t qualified template;
    fromX int(10);
    fromY int(10);
    toX   int(10);
    toY   int(10);
    capX  int(10);
    capY  int(10);
end-ds;

dcl-ds moveList_t qualified template;
    count int(10) inz(0);
    moves likeds(move_t) dim(50);
end-ds;

// ---------- Fichier d'affichage ----------
// USROPN a été enlevé
dcl-f GAMEDSP workstn indds(fkey);

dcl-ds fkey qualified;
    exit    ind pos(3);
    refresh ind pos(5);
    newGame ind pos(6);
end-ds;

// ---------- Prototypes des procédures externes ----------
dcl-pr getGame likeds(partieInfo_t) extproc('GETPARTIE');
    id int(10) const;
end-pr;

dcl-pr getPc likeds(pieceInfo_t) extproc('GETPIECE');
    idPartie_ int(10) const;
    x_        int(10) const;
    y_        int(10) const;
end-pr;

dcl-pr creerPartie int(10) extproc('INITCHCKRS');
end-pr;

dcl-pr checkValidityMove ind extproc('CHECKVMOVE');
    id_partie int(10) const;
    fromX     int(10) const;
    fromY     int(10) const;
    toX       int(10) const;
    toY       int(10) const;
end-pr;

dcl-pr play ind extproc('JOUER');
    idPartie int(10) const;
    couleur  varchar(5) const;
    originX  int(10) const;
    originY  int(10) const;
    targetX  int(10) const;
    targetY  int(10) const;
end-pr;

dcl-pr upGame ind extproc('UPPARTIE');
    id      int(10) const;
    originX int(10) const;
    originY int(10) const;
    targetX int(10) const;
    targetY int(10) const;
end-pr;

// ---------- Prototypes des procédures internes ----------
dcl-pr drawBoard;
    p_idPartie int(10) const;
end-pr;

dcl-pr handleMove;
    p_idPartie int(10) const;
end-pr;

dcl-pr listPawnMove likeds(moveList_t) extproc('LISTPMOVE');
    id_partie int(10) const;
end-pr;

// Il est très salé Johan
// En vrai c'est le générateur de nombre aléatoire XD
dcl-pr CEERAN0 extproc('CEERAN0');
    seed     int(10);
    ran      float(8);
    feedback char(12) options(*omit);
end-pr;

dcl-pr playBlack;
    p_idPartie int(10) const;
end-pr;


// ============================================================
// PROGRAMME PRINCIPAL
// ============================================================
dcl-proc GameUIMain;
    dcl-ds gtmp likeds(partieInfo_t);
    dcl-s idPartie int(10);
    dcl-s trouvee  ind;
    dcl-s msgTxt varchar(100);

    SMSG = '';
    MSG  = '';

    // Écran 1 : choix de la partie (ou création avec F6)
    dou trouvee or fkey.exit;
        exfmt SELGAME;
        if fkey.exit;
            leave;
        endif;

        if fkey.newGame;
            idPartie = creerPartie(); 
            gtmp = getGame(idPartie);
            trouvee = gtmp.trouve;
            if trouvee;
                msgTxt = 'Partie ' + %char(idPartie) + ' creee : aux blancs de jouer';
                MSG = msgTxt;
            else;
                SMSG = 'Erreur a la creation de la partie';
            endif;
            iter;
        endif;

        idPartie = SID;
        gtmp = getGame(idPartie);
        trouvee = gtmp.trouve;
        if not trouvee;
            SMSG = 'Partie introuvable';
        endif;
    enddo;

    // Écran 2 : plateau
    if trouvee and not fkey.exit;
        clear ORGX;
        dow not fkey.exit;
            drawBoard(idPartie);
            exfmt BOARD;

            if fkey.exit;
                leave;
            endif;

            if fkey.refresh;
                MSG = '';
                iter;
            endif;

            handleMove(idPartie);
            playBlack(idPartie);

            
        enddo;
    endif;

    close GAMEDSP;
    return;
end-proc;

// ============================================================
// Remplit les 8 lignes du plateau
// ============================================================
dcl-proc drawBoard;
    dcl-pi *n;
        p_idPartie int(10) const;
    end-pi;

    dcl-s x int(10);
    dcl-s y int(10);
    dcl-s ligne char(20);
    dcl-s symb  char(1);
    dcl-ds p likeds(pieceInfo_t);
    dcl-ds g likeds(partieInfo_t);

    g = getGame(p_idPartie);
    WID   = p_idPartie;
    WETAT = g.etat;

    for y = 8 downto 1;
        ligne = %char(y) + ' ';
        for x = 1 to 8;
            p = getPc(p_idPartie : x : y);
            if not p.trouve;
                if %rem(x + y : 2) = 0;
                    symb = '.';
                else;
                    symb = ' ';
                endif;
            elseif p.couleur = 'blanc';
                if p.forme = 'dame';
                    symb = 'B';
                else;
                    symb = 'b';
                endif;
            else;
                if p.forme = 'dame';
                    symb = 'N';
                else;
                    symb = 'n';
                endif;
            endif;
            %subst(ligne : 2 * x + 1 : 1) = symb;
        endfor;

                select;
            when y = 8;
                ROW8 = ligne;
            when y = 7;
                ROW7 = ligne;
            when y = 6;
                ROW6 = ligne;
            when y = 5;
                ROW5 = ligne;
            when y = 4;
                ROW4 = ligne;
            when y = 3;
                ROW3 = ligne;
            when y = 2;
                ROW2 = ligne;
            when y = 1;
                ROW1 = ligne;
        endsl;
    endfor;
end-proc;

// ============================================================
// Lit la saisie, valide le coup, le joue, met à jour la partie
// ============================================================
dcl-proc handleMove;
    dcl-pi *n;
        p_idPartie int(10) const;
    end-pi;

    dcl-s oX int(10);
    dcl-s oY int(10);
    dcl-s tX int(10);
    dcl-s tY int(10);
    dcl-s couleur varchar(5);
    dcl-s msgTxt varchar(100);
    dcl-ds g likeds(partieInfo_t);

    monitor;
        oX = %int(ORGX);
        oY = %int(ORGY);
        tX = %int(TGTX);
        tY = %int(TGTY);
    on-error;
        MSG = 'Coordonnees invalides (chiffres de 1 a 8)';
        return;
    endmon;

    g = getGame(p_idPartie);
    if not g.trouve;
        MSG = 'Partie introuvable';
        return;
    endif;

    if g.etat = 'blancGagne' or g.etat = 'noirGagne';
        MSG = 'La partie est terminee';
        return;
    endif;

    if %subst(g.etat : 1 : 5) = 'blanc';
        couleur = 'blanc';
    else;
        couleur = 'noir';
    endif;

    if not checkValidityMove(p_idPartie : oX : oY : tX : tY);
        MSG = 'Coup invalide';
        return;
    endif;

    if not play(p_idPartie : couleur : oX : oY : tX : tY);
        MSG = 'Erreur lors du deplacement de la piece';
        return;
    endif;

    if not upGame(p_idPartie : oX : oY : tX : tY);
        MSG = 'Erreur lors de la mise a jour de la partie';
        return;
    endif;

    g = getGame(p_idPartie);
    select;
        when g.etat = 'blancGagne';
            MSG = 'Victoire des BLANCS !';
        when g.etat = 'noirGagne';
            MSG = 'Victoire des NOIRS !';
        when g.etat = 'blancRafle' or g.etat = 'noirRafle';
            MSG = 'Rafle : le meme joueur doit continuer a prendre';
        other;
            msgTxt = 'Coup joue. Etat : ' + g.etat;
            MSG = msgTxt;
    endsl;

    clear ORGX;
    clear ORGY;
    clear TGTX;
    clear TGTY;
end-proc;

dcl-proc playBlack;
    dcl-pi *n;
        p_idPartie int(10) const;
    end-pi;

    dcl-s  seed  int(10) static inz(0);   // 0 = initialisé par l'API
    dcl-s  rnd   float(8);
    dcl-ds g     likeds(partieInfo_t);
    dcl-ds list  likeds(moveList_t);
    dcl-ds mv    likeds(move_t);
    dcl-s  cand  int(10) dim(50);
    dcl-s  nbCand int(10);
    dcl-s  nbCap  int(10);
    dcl-s  i      int(10);
    dcl-s  pick   int(10);
    dcl-s  lastX  int(10) inz(0);
    dcl-s  lastY  int(10) inz(0);
    dcl-s joue ind;

    dou '0';
        g = getGame(p_idPartie);
        if not g.trouve or (g.etat <> 'noirJoue' and g.etat <> 'noirRafle');
            leave;
        endif;

        list = listPawnMove(p_idPartie);

        // Sélection des candidats
        nbCand = 0;
        for i = 1 to list.count;
            if g.etat = 'noirRafle';
                // on doit continuer avec la même pièce, en capturant
                if list.moves(i).fromX = lastX and list.moves(i).fromY = lastY
                   and list.moves(i).capX <> 0;
                    nbCand += 1;
                    cand(nbCand) = i;
                endif;
            else;
                nbCand += 1;
                cand(nbCand) = i;
            endif;
        endfor;

        // Prise obligatoire : si une capture existe, on ne garde qu'elles
        nbCap = 0;
        for i = 1 to nbCand;
            if list.moves(cand(i)).capX <> 0;
                nbCap += 1;
            endif;
        endfor;
        if nbCap > 0 and nbCap < nbCand;
            nbCap = 0;
            for i = 1 to nbCand;
                if list.moves(cand(i)).capX <> 0;
                    nbCap += 1;
                    cand(nbCap) = cand(i);
                endif;
            endfor;
            nbCand = nbCap;
        endif;

        if nbCand = 0;
            MSG = 'Les noirs ne peuvent plus jouer';
            leave;
        endif;




        joue = *off;
        dow nbCand > 0 and not joue;
            CEERAN0(seed : rnd : *omit);
            pick = %int(rnd * nbCand) + 1;
            if pick > nbCand;
                pick = nbCand;
            endif;
            mv = list.moves(cand(pick));

            joue = play(p_idPartie : 'noir' : mv.fromX : mv.fromY
                        : mv.toX : mv.toY);

            if not joue;
                // On retire ce candidat : on met le dernier à sa place
                cand(pick) = cand(nbCand);
                nbCand -= 1;
            endif;
        enddo;

        if not joue;
            MSG = 'Les noirs n''ont aucun coup valide';
            leave;      // sort du dou '0' externe
        endif;



        if not upGame(p_idPartie : mv.fromX : mv.fromY : mv.toX : mv.toY);
            MSG = 'Erreur mise a jour partie (noirs)';
            leave;
        endif;

        lastX = mv.toX;
        lastY = mv.toY;
    enddo;
end-proc;