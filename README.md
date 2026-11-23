# PREREQUIS
- Accès à un système IBM i (testé sur PUB400, V7R5M0)

- Un profil utilisateur avec les droits de création dans la bibliothèque GBARDELA1

- bash disponible (ou qsh/ssh sur IBM i)

- Les fichiers sources présents dans le répertoire IBMi_PROJECT

# LANCER LE JEU
- Dans un terminal, se placer dans le répertoire IBMi_PROJECT à l'aide de la commande `cd` (ex: `cd /home/user/IBMi_PROJECT`)
- Reformater si nécessaire le fichier build.sh à l'aide de la commande `tr -d '\r' < build.sh > build_tmp.sh && mv build_tmp.sh build.sh` 
- Créer les tables SQL et compiler les modules en RPG à l'aide de la commande `bash build.sh`
- Regrouper les modules dans un *SRVPGM en exportant les procédures avec `CRTSRVPGM SRVPGM(GBARDELA1/CHECKERS) MODULE(GBARDELA1/INITCHCKRS GBARDELA1/AJOUTPIECE GBARDELA1/BOUGEPIECE GBARDELA1/CREEPARTIE GBARDELA1/ENLEVPIECE GBARDELA1/GETPARTIE GBARDELA1/GETPIECE GBARDELA1/LISTEPIECE GBARDELA1/PROMOTION GBARDELA1/UPDERMOVE GBARDELA1/UPETATPART GBARDELA1/CHECKVMOVE GBARDELA1/JOUER GBARDELA1/UPPARTIE GBARDELA1/LISTPMOVE) EXPORT(*ALL) REPLACE(*YES)`

- Compiler le programme principal GAMEUI avec `CRTBNDRPG PGM(GBARDELA1/GAMEUI) SRCSTMF('/home/GBARDELA/builds/RPG_project/IBMi_PROJECT/UI/GAMEUI.rpgle') BNDDIR(GBARDELA1/CHECKERSBD) DFTACTGRP(*NO) DBGVIEW(*SOURCE) TGTCCSID(*JOB)`

- Appeler la procéduire GAMEUI avec la commande `CALL GBARDELA1/GAMEUI` pour lancer le jeu. Il est possible de reprendre une partie par son ID ou en créer une nouvelle en appuyant sur F6.

# TACHES A FAIRE / BRANCHES A METTRE EN PLACE

## MANIPULATION BDD
- ajouter une pièce X
- enlever une pièce X
- (bouger une pièce = enlever + ajouter) X
- changer la forme d'une pièce (pion --> dame) X
- vérifier si une pièce est sur une case X (récupérer data)
- lister pièces d'une équipe X
- créer une partie X
- récupérer une partie X 
- changer l'etat d'une partie X

## LISTER COUPS
- ~~lister coups 1 pion normal~~
- ~~lister coups 1 dame normal~~
- ~~lister coups 1 pion capture~~
- ~~lister coups 1 dame capture~~
- ~~lister captures possibles 1 equipe~~

## JOUER COUP
- ~~lister coups possible 1 joueur~~
- ~~checker si coup autorisé~~
- ~~jouer coup (si autorisé)~~
- ~~check état en fin de coup (toujours dans jouer coup)~~
- ~~string partie à print~~

## INTERFACE
- choisir une partie
- afficher une partie

