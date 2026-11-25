**free
ctl-opt nomain;

exec sql set option commit = *none;

dcl-c MAX_MOVES 50;

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
    moves likeds(move_t) dim(MAX_MOVES);
end-ds;

// Procédure permettant de vérifier si une pièce ennemie est présente à une position donnée
dcl-proc isEnemyAt;
    dcl-pi *n ind;
        pIdPartie int(10) const;
        px        int(10) const;
        py        int(10) const;
        pCouleur  char(5) const;
    end-pi;

    dcl-s nb int(10);

    if px < 1 or px > 8 or py < 1 or py > 8;
        return *off;
    endif;

    exec sql
        SELECT COUNT(*) INTO :nb
        FROM Pieces
        WHERE idPartie = :pIdPartie
          AND x = :px
          AND y = :py
          AND couleur <> :pCouleur;

    return (nb > 0);
end-proc;

dcl-proc isEmptyAt;
    dcl-pi *n ind;
        pIdPartie int(10) const;
        px        int(10) const;
        py        int(10) const;
    end-pi;

    dcl-s nb int(10);

    if px < 1 or px > 8 or py < 1 or py > 8;
        return *off;
    endif;

    exec sql
        SELECT COUNT(*) INTO :nb
        FROM Pieces
        WHERE idPartie = :pIdPartie
          AND x = :px
          AND y = :py;

    return (nb = 0);
end-proc;

dcl-proc addMove;
    dcl-pi *n;
        list  likeds(moveList_t);
        fromX int(10) const;
        fromY int(10) const;
        toX   int(10) const;
        toY   int(10) const;
        capX  int(10) const;
        capY  int(10) const;
    end-pi;

    if list.count >= MAX_MOVES;
        return;
    endif;

    list.count += 1;
    list.moves(list.count).fromX = fromX;
    list.moves(list.count).fromY = fromY;
    list.moves(list.count).toX   = toX;
    list.moves(list.count).toY   = toY;
    list.moves(list.count).capX  = capX;
    list.moves(list.count).capY  = capY;
end-proc;

// Procédure exportée
dcl-proc ListPTakes export;
    dcl-pi *n likeds(moveList_t);
        id_partie int(10) const;
    end-pi;

    dcl-ds result likeds(moveList_t) inz;

    dcl-s etat    char(10);
    dcl-s couleur char(5);
    dcl-s x       int(10);
    dcl-s y       int(10);
    dcl-s forme   varchar(4);
    dcl-s dir     int(10);
    dcl-s dx      int(10);
    dcl-s fin     ind;

    exec sql SELECT etat INTO :etat
             FROM Parties WHERE id = :id_partie;

    select;
        when etat = 'blancJoue' or etat = 'blancRafle';
            couleur = 'blanc';
            dir = 1;
        when etat = 'noirJoue' or etat = 'noirRafle';
            couleur = 'noir';
            dir = -1;
        other;
            return result;          // état inconnu : liste vide
    endsl;

    exec sql DECLARE c CURSOR FOR
        SELECT x, y, forme FROM Pieces
        WHERE idPartie = :id_partie AND couleur = :couleur;

    exec sql open c;

    dou fin;
        exec sql fetch next from c into :x, :y, :forme;
        fin = (sqlcode <> 0);

        if not fin;
            for dx = -1 to 1 by 2;
                // Vérifier les captures possibles
                if isEnemyAt(id_partie : x + dx : y + dir : couleur) and isEmptyAt(id_partie : x + 2*dx : y + 2*dir) and x + 2 * dx > 0 and x + 2 * dx < 9 and y + 2 * dir > 0 and y + 2 * dir < 9;
                    // Ajouter le mouvement de prise vers (x + 2*dx, y + 2*dir) à la liste
                    addMove(result : x : y : x + 2*dx : y + 2*dir
                                   : x + dx : y + dir);
                endif;
                if isEnemyAt(id_partie : x + dx : y - dir : couleur) and isEmptyAt(id_partie : x + 2*dx : y - 2*dir) and x + 2 * dx > 0 and x + 2 * dx < 9 and y - 2 * dir > 0 and y - 2 * dir < 9;
                        // Ajouter le mouvement vers (x + dx, y - dir) à la liste
                        addMove(result : x : y : x + 2*dx : y - 2*dir
                                   : x + dx : y - dir);
                endif;
                
                // Mouvements simples (sans capture)
                // Avant : pions et dames
                if isEmptyAt(id_partie : x + dx : y + dir)
                and x + dx > 0 and x + dx < 9
                and y + dir > 0 and y + dir < 9;
                    addMove(result : x : y : x + dx : y + dir : 0 : 0);
                endif;

                // Arrière : dames uniquement
                if forme = 'dame'
                and isEmptyAt(id_partie : x + dx : y - dir)
                and x + dx > 0 and x + dx < 9
                and y - dir > 0 and y - dir < 9;
                    addMove(result : x : y : x + dx : y - dir : 0 : 0);
                endif;
            endfor;

        endif;




    enddo;

    exec sql close c;

    return result;
end-proc;