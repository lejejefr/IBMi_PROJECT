**free
ctl-opt nomain;

dcl-ds pieceInfo_t qualified template;
    trouve ind;
    idPartie int(10);
    x int(10);
    y int(10);
    couleur varchar(5);
    forme varchar(5);
end-ds;

dcl-ds equipe_t qualified template;
    nb int(10);
    pieces likeds(pieceInfo_t) dim(12);
end-ds;

dcl-proc listPiece export;
    dcl-pi listPiece likeds(equipe_t);
        idPartie_ int(10) const;
        couleur_ varchar(5) const;
    end-pi;

    dcl-ds result likeds(equipe_t) inz;
    dcl-s currentX like(pieceInfo_t.x);
    dcl-s currentY like(pieceInfo_t.y);
    dcl-s currentF like(pieceInfo_t.forme);

    exec sql
        DECLARE c CURSOR FOR
        SELECT x, y, forme FROM GBARDELA1.Pieces
        WHERE idPartie = :idPartie_ AND couleur = :couleur_;

    exec sql open c;
    if sqlcode < 0;
        return result;
    endif;

    exec sql fetch next from c into :currentX, :currentY, :currentF;
    dow sqlcode = 0 and result.nb < %elem(result.pieces);
        result.nb += 1;
        result.pieces(result.nb).trouve = *on;
        result.pieces(result.nb).idPartie = idPartie_;
        result.pieces(result.nb).x = currentX;
        result.pieces(result.nb).y = currentY;
        result.pieces(result.nb).couleur = couleur_;
        result.pieces(result.nb).forme = currentF;

        exec sql fetch next from c into :currentX, :currentY, :currentF;
    enddo;

    exec sql close c;
    return result;
end-proc;