MODULE LilithMain;
IMPORT LilithMemory, LilithLoad, LilithExec, LilithQuit, Args, SYSTEM;
CONST
  K = 256;
VAR
  name: ARRAY 64 OF CHAR;
  InitDatasize: LONGINT;
  InitCodesize: LONGINT;

BEGIN
  InitDatasize := SYSTEM.VAL(LONGINT, K*K);
  InitCodesize := SYSTEM.VAL(LONGINT, 65536);

  LilithMemory.datasize := InitDatasize;
  LilithMemory.codesize := InitCodesize;

  LilithMemory.stacksize := 4096;

  NEW(LilithMemory.stack, LilithMemory.datasize + LilithMemory.stacksize);
  NEW(LilithMemory.code, LilithMemory.codesize);

  IF Args.argc < 2 THEN
    LilithQuit.Quit("Missing filename")
  END;

  Args.Get(1, name);  (* argv[1] *)
  LilithLoad.LoadFile(name);
  LilithExec.Execute;
END LilithMain.

