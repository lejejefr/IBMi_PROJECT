**free
// ============================================================
// GAMEUI : interface 5250 du jeu de dames
// Enchaîne : checkValidityMove -> play -> upGame
// ============================================================
ctl-opt dftactgrp(*no) actgrp(*new);

dcl-f GAMEDSP workstn indds(fkey);

dcl-ds fkey qualified;
    exit    ind pos(3);
    refresh ind pos(5);
    newGame ind pos(6);
end-ds;

// ---------- Templates (identiques à ceux de UPGAME) ----------
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
    forme    varchar(4);
end-ds;

// ---------- Prototypes ----------
dcl-pr getGame likeds(partieInfo_t) extproc('GETGAME');
    id int(10) const;
end-pr;

dcl-pr getPc likeds(pieceInfo_t) extproc('GETPC');
    idPartie_ int(10) const;
    x_        int(10) const;
    y_        int(10) const;
end-pr;

// Programme INITCHCKRS : crée une partie et renvoie son id
dcl-pr creerPartie extpgm('INITCHCKRS');
    idCree int(10);
end-pr;

// Module CHECKMOVE
dcl-pr checkValidityMove ind extproc('CHECKVALIDITYMOVE');
    id_partie int(10) const;
    fromX     int(10) const;
    fromY     int(10) const;
    toX       int(10) const;
    toY       int(10) const;
end-pr;

// Module PLAY
dcl-pr play ind extproc('PLAY');
    idPartie int(10) const;
    couleur  varchar(5) const;
    originX  int(10) const;
    originY  int(10) const;
    targetX  int(10) const;
    targetY  int(10) const;
end-pr;

// Module UPGAME
dcl-pr upGame ind extproc('UPGAME');
    id      int(10) const;
    originX int(10) const;
    originY int(10) const;
    targetX int(10) const;
    targetY int(10) const;
end-pr;

// ---------- Programme principal ----------
dcl-s idPartie int(10);
dcl-s trouvee  ind;

SMSG = '';
MSG  = '';

// Écran 1 : choix de la partie (ou création avec F6)
dou trouvee or fkey.exit;
    exfmt SELGAME;
    if fkey.exit;
        leave;
    endif;

    if fkey.newGame;
        creerPartie(idPartie);
        trouvee = getGame(idPartie).trouve;
        if trouvee;
            MSG = 'Partie ' + %char(idPartie) + ' creee : aux blancs de jouer';
        else;
            SMSG = 'Erreur a la creation de la partie';
        endif;
        iter;
    endif;

    idPartie = SID;
    trouvee  = getGame(idPartie).trouve;
    if not trouvee;
        SMSG = 'Partie introuvable';
    endif;
enddo;

// Écran 2 : plateau
if trouvee and not fkey.exit;
    clear ORGX;
    dow not fkey.exit;
        drawBoard();
        exfmt BOARD;

        if fkey.exit;
            leave;
        endif;

        if fkey.refresh;
            MSG = '';
            iter;
        endif;

        handleMove();
    enddo;
endif;

*inlr = *on;
return;

// ============================================================
// Remplit les 8 lignes du plateau (Y=8 en haut, Y=1 en bas)
// ============================================================
dcl-proc drawBoard;
    dcl-s x int(10);
    dcl-s y int(10);
    dcl-s ligne char(20);
    dcl-s symb  char(1);
    dcl-ds p likeds(pieceInfo_t);
    dcl-ds g likeds(partieInfo_t);

    g = getGame(idPartie);
    WID   = idPartie;
    WETAT = g.etat;

    for y = 8 downto 1;
        ligne = %char(y) + ' ';
        for x = 1 to 8;
            p = getPc(idPartie : x : y);
            if not p.trouve;
                // cases foncées = (x + y) pair, comme dans INITCHCKRS
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
            when y = 8; ROW8 = ligne;
            when y = 7; ROW7 = ligne;
            when y = 6; ROW6 = ligne;
            when y = 5; ROW5 = ligne;
            when y = 4; ROW4 = ligne;
            when y = 3; ROW3 = ligne;
            when y = 2; ROW2 = ligne;
            when y = 1; ROW1 = ligne;
        endsl;
    endfor;
end-proc;

// ============================================================
// Lit la saisie, valide le coup, le joue, met à jour la partie
// ============================================================
dcl-proc handleMove;
    dcl-s oX int(10);
    dcl-s oY int(10);
    dcl-s tX int(10);
    dcl-s tY int(10);
    dcl-s couleur varchar(5);
    dcl-ds g likeds(partieInfo_t);

    // 1) Saisie numérique
    monitor;
        oX = %int(ORGX);
        oY = %int(ORGY);
        tX = %int(TGTX);
        tY = %int(TGTY);
    on-error;
        MSG = 'Coordonnees invalides (chiffres de 1 a 8)';
        return;
    endmon;

    // 2) État de la partie
    g = getGame(idPartie);
    if not g.trouve;
        MSG = 'Partie introuvable';
        return;
    endif;

    if g.etat = 'blancGagne' or g.etat = 'noirGagne';
        MSG = 'La partie est terminee';
        return;
    endif;

    if %scan('blanc' : g.etat) = 1;
        couleur = 'blanc';
    else;
        couleur = 'noir';
    endif;

    // 3) Validation des règles
    if not checkValidityMove(idPartie : oX : oY : tX : tY);
        MSG = 'Coup invalide';
        return;
    endif;

    // 4) Exécution : déplacement + prise + promotion
    if not play(idPartie : couleur : oX : oY : tX : tY);
        MSG = 'Erreur lors du deplacement de la piece';
        return;
    endif;

    // 5) Rafle / changement de joueur / victoire
    if not upGame(idPartie : oX : oY : tX : tY);
        MSG = 'Erreur lors de la mise a jour de la partie';
        return;
    endif;

    // 6) Message selon le nouvel état
    g = getGame(idPartie);
    select;
        when g.etat = 'blancGagne';
            MSG = 'Victoire des BLANCS !';
        when g.etat = 'noirGagne';
            MSG = 'Victoire des NOIRS !';
        when g.etat = 'blancRafle' or g.etat = 'noirRafle';
            MSG = 'Rafle : le meme joueur doit continuer a prendre';
        other;
            MSG = 'Coup joue. Etat : ' + g.etat;
    endsl;

    clear ORGX;
    clear ORGY;
    clear TGTX;
    clear TGTY;
end-proc;
