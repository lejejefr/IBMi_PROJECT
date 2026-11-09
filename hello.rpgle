**free
ctl-opt main(hello) dftactgrp(*no) actgrp(*new);

dcl-proc hello;
    snd-msg 'Hello world';
end-proc;
