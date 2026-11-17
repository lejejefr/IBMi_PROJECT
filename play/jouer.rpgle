**free
ctl-opt nomain;

// ------------------------------------------------------------
// Prototypes externes (procédures SQLRPGLE)
// ------------------------------------------------------------
dcl-pr checkValidityMove ind extproc('CHECKVMOVE');
    idPartie int(10) const;
    fromX    int(10) const;
    fromY    int(10) const;
    toX      int(10) const;
    toY      int(10) const;
end-pr;

dcl-pr move ind extproc('MOVEPIECE');
    idPartie int(10) const;
    origineX int(10) const;
    origineY int(10) const;
    targetX  int(10) const;
    targetY  int(10) const;
end-pr;

dcl-pr promote ind extproc('PROMOTE');
    idPartie int(10) const;
    x        int(10) const;
    y        int(10) const;
end-pr;

dcl-pr take ind extproc('REMOVEPC');
    idPartie int(10) const;
    x        int(10) const;
    y        int(10) const;
end-pr;

// ------------------------------------------------------------
// Procédure principale
// ------------------------------------------------------------
dcl-proc jouer export;
    dcl-pi jouer ind;
        idPartie int(10) const;
        couleur  varchar(5) const;
        originX  int(10) const;
        originY  int(10) const;
        targetX  int(10) const;
        targetY  int(10) const;
    end-pi;

    dcl-s dx       int(10);
    dcl-s dy       int(10);
    dcl-s absX     int(10);
    dcl-s absY     int(10);
    dcl-s capX     int(10);
    dcl-s capY     int(10);
    dcl-s capture  ind;
    dcl-s promoteR ind;

    // 1) Vérifier la validité du coup
    if not checkValidityMove(idPartie : originX : originY : targetX : targetY);
        return *off;
    endif;

    dx = targetX - originX;
    dy = targetY - originY;
    absX = %abs(dx);
    absY = %abs(dy);
    capture = (absX = 2 and absY = 2);

    // 2) Déplacer la pièce
    if not move(idPartie : originX : originY : targetX : targetY);
        return *off;
    endif;

    // 3) Supprimer la pièce capturée si prise
    if capture;
        capX = originX + (dx / 2);
        capY = originY + (dy / 2);
        if not take(idPartie : capX : capY);
            return *off;
        endif;
    endif;

    // 4) Promotion si un pion atteint la dernière rangée
    if (couleur = 'blanc' and targetY = 8)
       or (couleur = 'noir'  and targetY = 1);
        promoteR = promote(idPartie : targetX : targetY);
        // promotion facultative : on ne bloque pas si le UPDATE échoue
    endif;

    return *on;
end-proc;