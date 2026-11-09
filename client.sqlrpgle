**free
ctl-opt main(main) dftactgrp(*no) actgrp(*new);

dcl-proc main;
    dcl-s clientId zoned(5) inz(1);
    dcl-s clientFirstname varchar(64);
    dcl-s clientLastname varchar(64);

    exec sql
        SELECT (firstname,lastname) INTO (:clientFirstname,:clientLastname)
        FROM LEBOULLIO1.Clients
        WHERE id = :clientId;
         
end-proc;
