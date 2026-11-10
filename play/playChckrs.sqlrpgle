**free
ctl-opt main(playChckrs) dftactgrp(*no) actgrp(*new);

dcl-s etatPartie varchar(10);
dcl-s couleurPiece varchar(5);

dcl-proc playChckrs;
    dcl-pi *n varchar(40);
        idPartie int const;
        idParent int const;
        moveType varchar(6);
        couleur varchar(5);
        avantX int const;
        avantY int const;
        apresX int const;
        apresY int const;
    end-pi;

    exec sql set option commit = *none;
    
    //check à qui le tour
    exec sql SELECT etat INTO :etatPartie
             FROM LEBOULLIO1.Parties
             WHERE id = :idPartie;
    
    if sqlcode <> 0;
        return 'Partie non trouvée';
    elseif etat in %list('blancGagne' : 'noirGagne' : 'egalite');
        return 'Partie déjà terminée';
    elseif (etat = 'noirJoue' and couleur = 'blanc') or (etat = 'blancJoue' and couleur = 'noir');
        return 'Pas à vous de jouer';
    endif;

    //check case cible valide
    if apresX < 1 or apresX > 8 or apresY < 1 or apresY > 8 or %REM(apresX + apresY : 2) <> 0;
        return 'Destination invalide';
    endif;

    //check piece départ existe et au joueur
    exec sql SELECT couleur INTO :couleurPiece
             FROM LEBOULLIO1.Pieces
             WHERE x = :avantX AND y = :avantY AND idPartie = :idPartie;
    
    if sqlcode <> 0;
        return 'Aucune piece ici';
    elseif not couleurPiece = couleur;
        return 'Vous ne pouvez pas jouer cette piece';
    endif;

end-proc;

