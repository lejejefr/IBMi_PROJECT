**free
ctl-opt main(checkMove1) dftactgrp(*no) actgrp(*new);

dcl-s etatPartie varchar(10);
dcl-s couleurPiece varchar(5);
dcl-s formePiece varchar(4);

dcl-proc checkMove1;
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
    exec sql SELECT couleur, forme INTO :couleurPiece, :formePiece
             FROM LEBOULLIO1.Pieces
             WHERE x = :avantX AND y = :avantY AND idPartie = :idPartie;
    
    if sqlcode <> 0;
        return 'Aucune piece ici';
    elseif not couleurPiece = couleur;
        return 'Vous ne pouvez pas jouer cette piece';
    endif;

    //check case arrivee vide
    exec sql SELECT * FROM LEBOULLIO1.Pieces WHERE x = :apresX AND y = :apresY AND idPartie = :idPartie;
    
    if sqlcode = 0;
        return 'Case cible déjà occupée';
    endif;

    //check piece et cible alignées
    if (apresX - avantX) <> (apresY - avantY) and (apresX - avantX) <> (avantY - apresY);
        return 'La cible et la pièce ne sont pas alignées'
    endif;

    return 'ok';
end-proc;

