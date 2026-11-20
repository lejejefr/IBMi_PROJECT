# Jeu de dames pour IBM i (PUB400)

Jeu de dames en RPGLE/SQL : le joueur joue les blancs, l'ordinateur joue les noirs (coups aléatoires parmi les coups valides, prise obligatoire).

## Prérequis

- Un compte PUB400 (ou tout IBM i en V7R3 ou plus) avec une bibliothèque personnelle
- Les sources copiées dans l'IFS, dans `/home/<VOTRE_PROFIL>/builds/IBMi_PROJECT` :

```
IBMi_PROJECT/
├── BUILDDAMES.clle
├── db/      (checkersDB.sql, *.sqlrpgle, listMoves/)
└── play/    (GAMELOOP.sqlrpgle, jouer.rpgle, ...)
```

## Installation

Dans un terminal 5250 (ou SSH/QSH, avec `system "..."`) :

1. Définir la bibliothèque d'installation (la vôtre, sur PUB400 la création de bibliothèque est interdite) :

```
CHGCURLIB MABIB
```

2. Compiler le script de build :

```
CRTBNDCL PGM(MABIB/BUILDDAMES) +
         SRCSTMF('/home/<VOTRE_PROFIL>/builds/IBMi_PROJECT/BUILDDAMES.clle')
```

3. Lancer le build :

```
CALL BUILDDAMES
```

Le build :
- crée les tables `PARTIES` et `PIECES` (⚠️ elles sont supprimées et recréées à chaque build, donc les parties sont réinitialisées),
- active la journalisation,
- compile tous les modules et crée le programme `GAMELOOP`,
- lance le jeu à la fin.

Pour installer dans une autre bibliothèque que la bibliothèque courante :

```
CALL BUILDDAMES PARM('AUTREBIB')
```

## Rejouer

```
ADDLIBLE MABIB
CALL MABIB/GAMELOOP
```

## Jouer

- Un coup se saisit avec 4 chiffres `xyXY` : colonne et ligne de départ, puis colonne et ligne d'arrivée. Exemple : `2334` déplace la pièce de (2,3) vers (3,4).
- `q` pour quitter.
- Légende du damier :

| Symbole | Signification |
|---|---|
| `.` | case inaccessible |
| `+` | case libre |
| `b` / `B` | pion / dame blanc(he) |
| `n` / `N` | pion / dame noir(e) |

- Les blancs sont en bas (ligne 1), les noirs en haut (ligne 8).
- La prise (et la rafle) est obligatoire : un coup qui ne respecte pas cette règle est refusé.

## Dépannage

| Message | Cause probable |
|---|---|
| `Echec a l etape : ...` | voir `DSPJOBLOG` pour le détail de l'étape indiquée |
| `SQL0204 Parties not found` | la bibliothèque n'est pas dans la liste : `ADDLIBLE MABIB` |
| `CPF9801` sur la bibliothèque | le nom passé en paramètre n'existe pas |