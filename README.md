# PREREQUIS
- Accès à un système IBM i (testé sur PUB400, V7R5M0)
- Un profil utilisateur avec les droits de création dans la bibliothèque GBARDELA1
- Les fichiers sources présents dans le répertoire IBMi_PROJECT (IFS)

# LANCER LE JEU

## 0. Journaliser les objets de la bibliothèque (remplacer MALIB)

CRTJRNRCV JRNRCV(MALIB/JRNRCV0001)

CRTJRN JRN(MALIB/MONJRN) JRNRCV(MALIB/JRNRCV0001) MNGRCV(*SYSTEM) DLTRCV(*YES)

STRJRNPF FILE(MALIB/*ALL) JRN(MALIB/MONJRN) IMAGES(*BOTH) OMTJRNE(*OPNCLO)

## 1. dans BUILDCHCK.clle, modifier la ligne 3 pour indiquer votre bibliothèque à la place de MALIB


## 2. Une seule fois : créer le répertoire de liaison (remplacer MALIB)
En 5250 :
`CRTBNDDIR BNDDIR(MALIB/CHECKERSBD)`
`ADDBNDDIRE BNDDIR(MALIB/CHECKERSBD) OBJ((MALIB/CHECKERS *SRVPGM))`

## 3. Compiler le script de build (remplacer MALIB et VOTRE/CHEMIN)
En 5250 :
`CRTBNDCL PGM(MALIB/BUILDCHCK) SRCSTMF('VOTRE/CHEMIN/RPG_project/IBMi_PROJECT/BUILDCHCK.clle')`

## 4. Construire le projet
`CALL PGM(MALIB/BUILDCHCK)`

Ce programme crée les tables SQL, compile les modules, crée le *SRVPGM CHECKERS,
l'écran GAMEDSP et le programme GAMEUI.

## 5. Jouer
`CALL MALIB/GAMEUI`

Reprendre une partie par son ID, ou en créer une nouvelle avec F6.

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

