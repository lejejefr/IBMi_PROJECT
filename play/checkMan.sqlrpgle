**free
ctl-opt nomain;

dcl-ds prise qualified;
    depuisX  packed(10:0);
    depuisY  packed(10:0);
    versX    packed(10:0);
    versY    packed(10:0);
    cibleX   packed(10:0);
    cibleY   packed(10:0);
end-ds;

dcl-s prises prise dim(4);
dcl-s nbPrises packed(10:0);

dcl-proc listerPrisesPion export;
    dcl-pi *n;
        idPartie_ packed(10:0) const;
        couleur_  varchar(5)   const;
        pionX_    packed(10:0) const;
        pionY_    packed(10:0) const;
    end-pi;

    dcl-s advCouleur varchar(5);
    dcl-s dirX       packed(10:0);
    dcl-s dirY       packed(10:0);
    dcl-s cibleX     packed(10:0);
    dcl-s cibleY     packed(10:0);
    dcl-s arrX       packed(10:0);
    dcl-s arrY       packed(10:0);
    dcl-s couleurAdv varchar(5);
    dcl-s nbOccupee  packed(10:0);
    dcl-s i          packed(10:0);

    if couleur_ = 'blanc';
        advCouleur = 'noir';
    else;
        advCouleur = 'blanc';
    endif;

    nbPrises = 0;
    clear prises;

    dcl-c DIRS  dim(4) const('1:1' : '1:-1' : '-1:-1' : '-1:1');

    for i = 1 to 4;
        select i;
            when i = 1; dirX =  1; dirY =  1;
            when i = 2; dirX =  1; dirY = -1;
            when i = 3; dirX = -1; dirY = -1;
            when i = 4; dirX = -1; dirY =  1;
        endsl;

        cibleX = pionX_ + dirX;
        cibleY = pionY_ + dirY;
        arrX   = pionX_ + dirX * 2;
        arrY   = pionY_ + dirY * 2;

        if arrX < 1 or arrX > 8 or arrY < 1 or arrY > 8;
            iter;
        endif;
        if %rem(arrX + arrY : 2) <> 0;
            iter;
        endif;

        couleurAdv = '';
        exec sql SELECT couleur INTO :couleurAdv
                 FROM LEBOULLIO1.Pieces
                 WHERE idPartie = :idPartie_
                   AND x = :cibleX
                   AND y = :cibleY;

        if sqlcode <> 0;
            iter;
        endif;
        if couleurAdv <> advCouleur;
            iter;
        endif;

        nbOccupee = 0;
        exec sql SELECT COUNT(*) INTO :nbOccupee
                 FROM LEBOULLIO1.Pieces
                 WHERE idPartie = :idPartie_
                   AND x = :arrX
                   AND y = :arrY;

        if nbOccupee > 0;
            iter;
        endif;

        nbPrises += 1;
        prises(nbPrises).depuisX = pionX_;
        prises(nbPrises).depuisY = pionY_;
        prises(nbPrises).versX   = arrX;
        prises(nbPrises).versY   = arrY;
        prises(nbPrises).cibleX  = cibleX;
        prises(nbPrises).cibleY  = cibleY;
    endfor;
end-proc;