MODULE LilithMemory;

IMPORT LilithTypes;

VAR
  stack*: POINTER TO ARRAY OF LilithTypes.Word;
  code*: POINTER TO ARRAY OF CHAR;

  heapsize*, datasize*, stacksize*, codesize*: LONGINT;

  PC*, IR*: LilithTypes.Word;
  F*, G*, H*, L*, S*, P*, M*, ReqNo*: LilithTypes.Word;
  REQ*: BOOLEAN;
  bootflag*: BOOLEAN;

BEGIN
  bootflag := TRUE
END LilithMemory.

