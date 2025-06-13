MODULE LilithExec;

IMPORT LilithMemory, LilithTypes, LilithMnemonic, LilithStorage, LilithStack, LilithEnd, LilithQuit, Out, SYSTEM;

CONST
  MaxExprStack = 16;

  (* Opcodes *)
  LI0 = 0; LI1 = 1; LI2 = 2; LI3 = 3;
  LI4 = 4; LI5 = 5; LI6 = 6; LI7 = 7;
  LI8 = 8; LI9 = 9; LI10 = 10; LI11 = 11;
  LI12 = 12; LI13 = 13; LI14 = 14; LI15 = 15;
  LIB = 16;
  ANDJP = 17;

  SWAP = 182;
  ROT = 183;
  DUP = 184;
  DROP = 185;
  OVER = 186;
  ADD = 187;
  SUB = 188;
  MUL = 189;
  DIV0 = 190;
  MOD0 = 191;
  NEG = 192;
  EQ = 193;
  NE = 194;
  LT = 195;
  LE = 196;
  GT = 197;
  GE = 198;
  MARK = 199;
  JMP = 200;
  JMPF = 201;
  JMPB = 202;
  JMPZ = 203;
  JMPNZ = 204;
  LDL = 205;
  STL = 206;
  LDA = 207;
  LDC = 208;
  LDV = 209;
  STV = 210;
  LDPI = 211;
  STPI = 212;
  LFR = 213;
  SFR = 214;
  XCH = 215;
  CSP = 216;

VAR
  a: ARRAY MaxExprStack OF LilithTypes.Word;
  sp: INTEGER;
  PC: INTEGER;

PROCEDURE Push(w: LilithTypes.Word);
BEGIN
  LilithMemory.stack^[LilithMemory.S] := w;
  INC(LilithMemory.S);
END Push;

PROCEDURE Pop(): LilithTypes.Word;
BEGIN
  DEC(LilithMemory.S);
  RETURN LilithMemory.stack^[LilithMemory.S];
END Pop;

PROCEDURE Top(): LilithTypes.Word;
BEGIN
  RETURN LilithMemory.stack^[LilithMemory.S - 1];
END Top;

PROCEDURE SetTop(w: LilithTypes.Word);
BEGIN
  LilithMemory.stack^[LilithMemory.S - 1] := w;
END SetTop;

PROCEDURE Empty(): BOOLEAN;
BEGIN
  RETURN sp = 0
END Empty;

PROCEDURE Next(): LilithTypes.Word;
BEGIN
  INC(LilithMemory.PC);
  RETURN ORD(LilithMemory.code^[4 * LilithMemory.F + LilithMemory.PC - 1])
END Next;

PROCEDURE SNext(): INTEGER;
VAR val: INTEGER; b: INTEGER;
BEGIN
  INC(LilithMemory.PC);
  b := ORD(LilithMemory.code^[4 * LilithMemory.F + LilithMemory.PC - 1]);
  val := b MOD 80H;
  IF b >= 80H THEN val := val - 80H END;
  RETURN val
END SNext;

PROCEDURE Next2(): LilithTypes.Word;
VAR hi, lo: INTEGER;
BEGIN
  hi := ORD(LilithMemory.code^[4 * LilithMemory.F + LilithMemory.PC]);
  INC(LilithMemory.PC);
  lo := ORD(LilithMemory.code^[4 * LilithMemory.F + LilithMemory.PC]);
  INC(LilithMemory.PC);
  RETURN SYSTEM.VAL(LilithTypes.Word, hi * 100H + lo)
END Next2;

PROCEDURE Mark(x: LilithTypes.Word; external: BOOLEAN);
VAR i: INTEGER;
BEGIN
  i := LilithMemory.S;
  LilithMemory.stack^[LilithMemory.S] := x; INC(LilithMemory.S);
  LilithMemory.stack^[LilithMemory.S] := LilithMemory.L; INC(LilithMemory.S);
  IF external THEN
    LilithMemory.stack^[LilithMemory.S] := SYSTEM.VAL(LilithTypes.Word, SYSTEM.VAL(INTEGER, LilithMemory.PC) + 8000H);
  ELSE
    LilithMemory.stack^[LilithMemory.S] := LilithMemory.PC;
  END;
  INC(LilithMemory.S);
  INC(LilithMemory.S);
  LilithMemory.L := i
END Mark;

PROCEDURE SaveExpStack;
VAR c: INTEGER;
BEGIN
  c := 0;
  WHILE ~Empty() DO
    LilithMemory.stack^[LilithMemory.S] := Pop(); INC(LilithMemory.S);
    INC(c)
  END;
  LilithMemory.stack^[LilithMemory.S] := SYSTEM.VAL(LilithTypes.Word, c); INC(LilithMemory.S)
END SaveExpStack;

PROCEDURE RestoreExpStack;
VAR c: INTEGER;
BEGIN
  DEC(LilithMemory.S);
  c := SYSTEM.VAL(INTEGER, LilithMemory.stack^[LilithMemory.S]);
  WHILE c > 0 DO
    DEC(c);
    DEC(LilithMemory.S);
    Push(LilithMemory.stack^[LilithMemory.S])
  END
END RestoreExpStack;

PROCEDURE SaveRegs;
BEGIN
  SaveExpStack;
  LilithMemory.stack^[LilithMemory.P] := LilithMemory.G;
  LilithMemory.stack^[LilithMemory.P+1] := LilithMemory.L;
  LilithMemory.stack^[LilithMemory.P+2] := LilithMemory.PC;
  LilithMemory.stack^[LilithMemory.P+3] := LilithMemory.M;
  LilithMemory.stack^[LilithMemory.P+4] := LilithMemory.S;
  LilithMemory.stack^[LilithMemory.P+5] := SYSTEM.VAL(LilithTypes.Word, SYSTEM.VAL(INTEGER, LilithMemory.H) + 24)
END SaveRegs;

PROCEDURE RestoreRegs(changemask: INTEGER);
BEGIN
  LilithMemory.G := LilithMemory.stack^[LilithMemory.P];
  LilithMemory.F := LilithMemory.stack^[LilithMemory.G];
  LilithMemory.L := LilithMemory.stack^[LilithMemory.P+1];
  IF ~LilithMemory.bootflag THEN
    LilithMemory.PC := LilithMemory.stack^[LilithMemory.P+2];
  ELSE
    LilithMemory.PC := 0;
    LilithMemory.PC := Next2();
    LilithMemory.stack^[LilithMemory.P+2] := LilithMemory.PC
  END
END RestoreRegs;

PROCEDURE Execute*;
VAR
  opcode: INTEGER;
  w, w1, w2: LilithTypes.Word;
BEGIN
  PC := 0;
  LOOP
    opcode := ORD(LilithMemory.code^[PC]); INC(PC);
    CASE opcode OF
      (* previous opcodes... *)
      | LDPI:
        w := SYSTEM.VAL(LilithTypes.Word, LilithMemory.G + SNext()); Push(LilithMemory.stack^[SYSTEM.VAL(INTEGER, w)]);
      | STPI:
        w1 := Pop(); w := SYSTEM.VAL(LilithTypes.Word, LilithMemory.G + SNext()); LilithMemory.stack^[SYSTEM.VAL(INTEGER, w)] := w1;
      | LFR:
        w := SYSTEM.VAL(LilithTypes.Word, LilithMemory.F + SNext()); Push(LilithMemory.stack^[SYSTEM.VAL(INTEGER, w)]);
      | SFR:
        w1 := Pop(); w := SYSTEM.VAL(LilithTypes.Word, LilithMemory.F + SNext()); LilithMemory.stack^[SYSTEM.VAL(INTEGER, w)] := w1;
      | XCH:
        w1 := Pop(); w2 := Pop(); Push(w1); Push(w2);
      | CSP:
        (* Placeholder for system call handling *)
        w := Next(); Out.String("CSP not yet implemented, opcode param: "); Out.Int(SYSTEM.VAL(INTEGER, w), 5); Out.Ln;
      ELSE
        Out.String("Unknown opcode: "); Out.Int(opcode, 5); Out.Ln;
        LilithQuit.Quit("Unknown opcode")
    END
  END
END Execute;

END LilithExec.
