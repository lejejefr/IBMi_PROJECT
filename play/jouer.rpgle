**free
ctl-opt nomain;

dcl-pr move ind extproc('MOVEPIECE');
    idPartie int(10) const;
    origineX int(10) const;
    origineY int(10) const;
    targetX int(10) const;
    targetY int(10) const;
end-pr;

dcl-pr promote ind extproc('PROMOTE');
    idPartie int(10) const;
    x int(10) const;
    y int(10) const;
end-pr;

dcl-pr take ind extproc('REMOVEPC');
    idPartie int(10) const;
    x int(10) const;
    y int(10) const;
end-pr;

dcl-s moveX int(10);
dcl-s moveY int(10);
dcl-s takeX int(10);
dcl-s takeY int(10);

// ------------------------------------------------------------
//      play permet d'exécuter un coup. Modifie la base de
//      données en conséquence avec les procédures dédiées
//      et renvoie un indicateur sur la réussite de l'opération
// ------------------------------------------------------------

dcl-proc play export;
    dcl-pi *n ind;
        idPartie int(10) const;
        couleur varchar(5) const;
        originX int(10) const;
        originY int(10) const;
        targetX int(10) const;
        targetY int(10) const;
    end-pi;
    
    dcl-s i int(10);

    for i = 1 to 8;

        moveX = originX;
        moveY = originY;

        takeX = originX;
        takeY = originY;

        select;
            when i = 1;
                moveX += 1;
                moveY += 1;
            when i = 2;
                moveX += 1;
                moveY += -1;
            when i = 3;
                moveX += -1;
                moveY += -1;
            when i = 4;
                moveX += -1;
                moveY += 1;
            when i = 5;
                moveX += 2;
                moveY += 2;
                takeX += 1;
                takeY += 1;
            when i = 6;
                moveX += 2;
                moveY += -2;
                takeX += 1;
                takeY += -1;
            when i = 7;
                moveX += -2;
                moveY += -2;
                takeX += -1;
                takeY += -1;
            when i = 8;
                moveX += -2;
                moveY += 2;
                takeX += -1;
                takeY += 1;
            other;

        endsl;
        
        if targetX = moveX and targetY = moveY;
            if not move(idPartie : originX : originY : moveX : moveY);
                return *OFF;
            endif;
            if (couleur = 'blanc' and moveY = 8) or (couleur = 'noir' and moveY = 1);
                promote(idPartie : moveX : moveY);
            endif;
            if takeX <> originX or takeY <> originY;
                take(idPartie : takeX : takeY);
            endif;

            return *ON;
        endif;
    endfor;
    return *OFF;
end-proc;