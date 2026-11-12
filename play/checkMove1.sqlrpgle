**free
ctl-opt nomain;

dcl-s etatPartie varchar(10);
dcl-s couleurPiece varchar(5);
dcl-s formePiece varchar(4);
dcl-s nbOccupes packed(10:0);

dcl-proc baseCheck export;
    dcl-pi *n varchar(40);
        idPartie_ int(10) const;
        moveType_ varchar(6) const;
        couleur_ varchar(5) const;
        avantX_ int(10) const;
        avantY_ int(10) const;
        apresX_ int(10) const;
        apresY_ int(10) const;
    end-pi;

    dcl-s idPartie packed(10:0);
    dcl-s moveType varchar(6);
    dcl-s couleur varchar(5);
    dcl-s avantX packed(10:0);
    dcl-s avantY packed(10:0);
    dcl-s apresX packed(10:0);
    dcl-s apresY packed(10:0);

    idPartie = idPartie_;
    moveType = moveType_;
    couleur = couleur_;
    avantX = avantX_;
    avantY = avantY_;
    apresX = apresX_;
    apresY = apresY_;
    
    //check à qui le tour
    exec sql SELECT etat INTO :etatPartie
             FROM LEBOULLIO1.Parties
             WHERE id = :idPartie;
    
    if sqlcode <> 0;
        return 'Partie non trouvée';
    elseif etatPartie in %list('blancGagne' : 'noirGagne' : 'egalite');
        return 'Partie déjà terminée';
    elseif (etatPartie = 'noirJoue' and couleur = 'blanc') or (etatPartie = 'blancJoue' and couleur = 'noir');
        return 'Pas à vous de jouer';
    endif;

    //check case cible valide
    if apresX < 1 or apresX > 8 or apresY < 1 or apresY > 8 or %REM(apresX + apresY : 2) <> 0;
        return 'Destination invalide';
    endif;

    //check piece départ existe et au joueur
    exec sql SELECT couleur, forme INTO :couleurPiece, :formePiece
             FROM LEBOULLIO1.Pieces
             WHERE x = :avantX AND y = :avantY AND idPartie = :idPartie;
    
    if sqlcode <> 0;
        return 'Aucune piece ici';
    elseif couleurPiece <> couleur;
        return 'Vous ne pouvez pas jouer cette piece';
    endif;

    //check case arrivee vide
    exec sql SELECT COUNT(*) INTO :nbOccupes
         FROM LEBOULLIO1.Pieces
         WHERE x = :apresX AND y = :apresY AND idPartie = :idPartie;

    if nbOccupes > 0;
        return 'Case cible déjà occupée';
    endif;

    //check piece et cible alignées
    if %abs(apresX - avantX) <> %abs(apresY - avantY);
        return 'La cible et la pièce ne sont pas alignées';
    endif;

    return formePiece;
end-proc;

