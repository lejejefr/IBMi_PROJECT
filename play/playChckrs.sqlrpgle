**free
ctl-opt main(playChckrs) dftactgrp(*no) actgrp(*new);

dcl-proc playChckrs;
    dcl-pi *n ;
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
    
    
end-proc;

