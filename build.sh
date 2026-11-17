#!/QOpenSys/pkgs/bin/bash

P="/home/GBARDELA/builds/RPG_project/IBMi_PROJECT"
L=GBARDELA1

# 0) Création du fichier source QDDSSRC (si erreur, on ignore)
system "CRTSRCPF FILE($L/QDDSSRC) RCDLEN(112)" 2>/dev/null || true

# 1) Création des tables + procédure SQL
# (On le fait AVANT les modules car les modules ont besoin des tables)
system "RUNSQLSTM SRCSTMF('$P/db/checkersDB.sql') COMMIT(*NONE)"

# 2) Fonction générique pour compiler les modules SQLRPGLE
m() {
    system "CRTSQLRPGI OBJ($L/$1) SRCSTMF('$P/$2') COMMIT(*NONE) CVTCCSID(*JOB) OBJTYPE(*MODULE) REPLACE(*YES) DBGVIEW(*SOURCE)"
}

# 3) Compilation des modules SQLRPGLE
m INITCHCKRS db/gameInit.sqlrpgle
m AJOUTPIECE  db/ajoutPiece.sqlrpgle
m BOUGEPIECE  db/bougePiece.sqlrpgle
m CREEPARTIE  db/creePartie.sqlrpgle
m ENLEVPIECE  db/enlevPiece.sqlrpgle
m GETPARTIE   db/getPartie.sqlrpgle
m GETPIECE    db/getPiece.sqlrpgle
m LISTEPIECE  db/listePiece.sqlrpgle
m PROMOTION   db/promotion.sqlrpgle
m UPDERMOVE   db/upDerMove.sqlrpgle
m UPETATPART  db/upEtatPart.sqlrpgle
m CHECKVMOVE  play/checkVMove.sqlrpgle

# 4) Modules RPGLE sans SQL
system "CRTRPGMOD MODULE($L/JOUER) SRCSTMF('$P/play/jouer.rpgle') DBGVIEW(*SOURCE)"
system "CRTRPGMOD MODULE($L/UPPARTIE) SRCSTMF('$P/play/upPartie.rpgle') DBGVIEW(*SOURCE)"

# 5) Programme de service
# (On a bien ajouté $L/INITCHCKRS dans la liste des modules)
system "CRTSRVPGM SRVPGM($L/CHECKERS) MODULE($L/INITCHCKRS $L/AJOUTPIECE $L/BOUGEPIECE $L/CREEPARTIE $L/ENLEVPIECE $L/GETPARTIE $L/GETPIECE $L/LISTEPIECE $L/PROMOTION $L/UPDERMOVE $L/UPETATPART $L/CHECKVMOVE $L/JOUER $L/UPPARTIE) EXPORT(*ALL) REPLACE(*YES)"

# 6) Écran DDS
system "CPYFRMSTMF FROMSTMF('$P/UI/GAMEDSP.dspf') TOMBR('/QSYS.LIB/$L.LIB/QDDSSRC.FILE/GAMEDSP.MBR') MBROPT(*REPLACE)"
system "CRTDSPF FILE($L/GAMEDSP) SRCFILE($L/QDDSSRC) SRCMBR(GAMEDSP) REPLACE(*YES)"

# 7) Programme principal
system "CRTBNDRPG PGM($L/GAMEUI) SRCSTMF('$P/UI/GAMEUI.rpgle') BNDDIR($L/CHECKERSBD) DFTACTGRP(*NO) DBGVIEW(*SOURCE)"

echo "Compilation terminée."