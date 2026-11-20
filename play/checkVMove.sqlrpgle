**free
ctl-opt nomain;

dcl-c BLANC 'blanc';
dcl-c NOIR  'noir';

// procédure pour voir si la pièce existe
dcl-proc pieceExists;
    dcl-pi *n ind;
        pIdPartie int(10) const;
        pX        int(10) const;
        pY        int(10) const;
        pCouleur  char(5) const;
    end-pi;

    dcl-s nb int(10);

    if pX < 1 or pX > 8 or pY < 1 or pY > 8;
        return *off;
    endif;

    exec sql
        SELECT COUNT(*) INTO :nb
        FROM GBARDELA1.Pieces
        WHERE idPartie = :pIdPartie
          AND x = :pX
          AND y = :pY
          AND couleur = :pCouleur;

    return (nb > 0);
end-proc;


// Procédure pour vérifier si une case ne continent pas de pièce.
dcl-proc caseLibre;
    dcl-pi *n ind;
        pIdPartie int(10) const;
        pX        int(10) const;
        pY        int(10) const;
    end-pi;

    dcl-s nb int(10);

    if pX < 1 or pX > 8 or pY < 1 or pY > 8;
        return *off;
    endif;

    exec sql
        SELECT COUNT(*) INTO :nb
        FROM GBARDELA1.Pieces
        WHERE idPartie = :pIdPartie
          AND x = :pX
          AND y = :pY;

    return (nb = 0);
end-proc;

// Forme de la pièce ('pion' / 'dame') à une case
dcl-proc getForme;
    dcl-pi *n char(5);
        pIdPartie int(10) const;
        pX        int(10) const;
        pY        int(10) const;
    end-pi;

    dcl-s laForme char(5) inz('');

    exec sql
        SELECT forme INTO :laForme
        FROM GBARDELA1.Pieces
        WHERE idPartie = :pIdPartie
          AND x = :pX
          AND y = :pY;

    return laForme;
end-proc;

// Procédure pour vérifier si une pièce peut capturer une autre pièce à partir d'une position donnée
dcl-proc canCaptureFrom;
    dcl-pi *n ind;
        pIdPartie int(10) const;
        pX        int(10) const;
        pY        int(10) const;
        pCouleur  char(5) const;
    end-pi;

    dcl-s autre char(5);
    dcl-s dx int(10);
    dcl-s dy int(10);
    dcl-s mx int(10);
    dcl-s my int(10);
    dcl-s ax int(10);
    dcl-s ay int(10);

    if pCouleur = BLANC;
        autre = NOIR;
    else;
        autre = BLANC;
    endif;

    for dx = -1 to 1 by 2;
        for dy = -1 to 1 by 2;
            mx = pX + dx;
            my = pY + dy;
            ax = pX + 2 * dx;
            ay = pY + 2 * dy;
            if ax >= 1 and ax <= 8 and ay >= 1 and ay <= 8;
                if pieceExists(pIdPartie: mx: my: autre)
                   and caseLibre(pIdPartie: ax: ay);
                    return *on;
                endif;
            endif;
        endfor;
    endfor;

    return *off;
end-proc;

// procédure pour voir si le joueur peut capturer une pièce ennemie
dcl-proc playerCanCapture;
    dcl-pi *n ind;
        pIdPartie int(10) const;
        pCouleur  char(5) const;
    end-pi;

    dcl-s px    int(10);
    dcl-s py    int(10);
    dcl-s trouve ind inz(*off);

    exec sql
        DECLARE cPieces CURSOR FOR
        SELECT x, y
        FROM GBARDELA1.Pieces
        WHERE idPartie = :pIdPartie
          AND couleur = :pCouleur;

    exec sql OPEN cPieces;

    dow not trouve;
        exec sql FETCH cPieces INTO :px, :py;
        if sqlcode <> 0;
            leave;
        endif;
        trouve = canCaptureFrom(pIdPartie: px: py: pCouleur);
    enddo;

    exec sql CLOSE cPieces;

    return trouve;
end-proc;

// Procédure exportée pour vérifier si un déplacement est valide
dcl-proc checkVMove export;
    dcl-pi checkVMove ind;
        id_partie int(10) const;
        fromX     int(10) const;
        fromY     int(10) const;
        toX       int(10) const;
        toY       int(10) const;
    end-pi;

    dcl-s etat    char(10);
    dcl-s couleur char(5);
    dcl-s autre   char(5);
    dcl-s forme   char(5);
    dcl-s sens    int(10);
    dcl-s absX    int(10);
    dcl-s absY    int(10);
    dcl-s enRafle ind;

    // État de la partie
    exec sql SELECT etat INTO :etat
             FROM GBARDELA1.Parties WHERE id = :id_partie;
    if sqlcode <> 0;
        return *off;
    endif;

    select;
        when etat = 'blancJoue' or etat = 'blancRafle';
            couleur = BLANC;
            autre   = NOIR;
            sens    = 1;
        when etat = 'noirJoue' or etat = 'noirRafle';
            couleur = NOIR;
            autre   = BLANC;
            sens    = -1;
        other;
            return *off;
    endsl;

    enRafle = (etat = 'blancRafle' or etat = 'noirRafle');

    // Case d'arrivée dans le plateau
    if toX < 1 or toX > 8 or toY < 1 or toY > 8;
        return *off;
    endif;

    // La pièce existe et appartient au joueur dont c'est le tour
    if not pieceExists(id_partie: fromX: fromY: couleur);
        return *off;
    endif;

    // La case d'arrivée doit être libre
    if not caseLibre(id_partie: toX: toY);
        return *off;
    endif;

    // Déplacement en diagonale uniquement, distance 1 ou 2
    absX = %abs(toX - fromX);
    absY = %abs(toY - fromY);
    if absX <> absY or absX = 0 or absX > 2;
        return *off;
    endif;

    // Distance 2 : prise (une pièce adverse au milieu)
    if absX = 2;
        if not pieceExists(id_partie: (fromX + toX) / 2:
                                      (fromY + toY) / 2: autre);
            return *off;
        endif;
        // Vérifie que la case intermédiaire est bien dans le plateau
        if (fromX + toX) / 2 < 1 or (fromX + toX) / 2 > 8
           or (fromY + toY) / 2 < 1 or (fromY + toY) / 2 > 8;
            return *off;
        endif;
        return *on;
    endif;

    // Distance 1 : déplacement simple
    if enRafle;
        return *off;
    endif;

    // Un pion ne recule pas (la dame, si)
    forme = getForme(id_partie: fromX: fromY);
    if forme <> 'dame' and (toY - fromY) <> sens;
        return *off;
    endif;

    // Prise obligatoire : pas de déplacement simple si une prise existe
    if playerCanCapture(id_partie: couleur);
        return *off;
    endif;

    return *on;
end-proc;