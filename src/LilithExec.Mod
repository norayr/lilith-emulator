MODULE LilithExec;

IMPORT LilithMemory, LilithTypes, LilithMnemonic, LilithStorage, LilithStack, LilithEnd, LilithQuit, Out, SYSTEM;

CONST
  MaxExprStack = 16;
  MASK15 = 7FFFH;  (* Mask for 15 bits *)

  (* M-code opcodes (decimal values) *)
  LI0 = 0;   LI1 = 1;   LI2 = 2;   LI3 = 3;
  LI4 = 4;   LI5 = 5;   LI6 = 6;   LI7 = 7;
  LI8 = 8;   LI9 = 9;   LI10 = 10; LI11 = 11;
  LI12 = 12; LI13 = 13; LI14 = 14; LI15 = 15;
  LIB = 16;  (* 020: Load Immediate Byte *)
  LIW = 18;  (* 022: Load Immediate Word *)
  LID = 19;  (* 023: Load Immediate Double *)
  LLA = 20;  (* 024: Load Local Address *)
  LGA = 21;  (* 025: Load Global Address *)
  LSA = 22;  (* 026: Load Stack Address *)
  LEA = 23;  (* 027: Load External Address *)
  JPC = 24;  (* 030: Jump Conditional *)
  JP = 25;   (* 031: Jump *)
  JPFC = 26; (* 032: Jump Forward Conditional *)
  JPF = 27;  (* 033: Jump Forward *)
  JPBC = 28; (* 034: Jump Backward Conditional *)
  JPB = 29;  (* 035: Jump Backward *)
  ORJP = 30; (* 036: OR Jump *)
  ANDJP = 31;(* 037: AND Jump *)
  LLW = 32;  (* 040: Load Local Word *)
  LLD = 33;  (* 041: Load Local Double *)
  LEW = 34;  (* 042: Load External Word *)
  LED = 35;  (* 043: Load External Double *)
  SLW = 48;  (* 060: Store Local Word *)
  SLD = 49;  (* 061: Store Local Double *)
  SEW = 50;  (* 062: Store External Word *)
  SED = 51;  (* 063: Store External Double *)
  LGW = 64;  (* 100: Load Global Word *)
  LGD = 65;  (* 101: Load Global Double *)
  SGW = 80;  (* 120: Store Global Word *)
  SGD = 81;  (* 121: Store Global Double *)
  LSW = 128; (* 200: Load Stack Word *)
  LSD = 129; (* 201: Load Stack Double *)
  LSDO = 130;(* 202: Load Stack Double Offset *)
  LXFW = 131;(* 203: Load Indexed Full Word *)
  LSTA = 132;(* 204: Load Static Address *)
  LXB = 133; (* 205: Load Indexed Byte *)
  LXW = 134; (* 206: Load Indexed Word *)
  LXD = 135; (* 207: Load Indexed Double *)
  DADD = 136;(* 210: Double Add *)
  DSUB = 137;(* 211: Double Subtract *)
  DMUL = 138;(* 212: Double Multiply *)
  DDIV = 139;(* 213: Double Divide *)
  DSHL = 142;(* 216: Double Shift Left *)
  DSHR = 143;(* 217: Double Shift Right *)
  SSW = 144; (* 220: Store Stack Word *)
  SSD = 145; (* 221: Store Stack Double *)
  SSD0 = 146;(* 222: Store Stack Double Offset *)
  SXFW = 147;(* 223: Store Indexed Full Word *)
  TS = 148;  (* 224: Test and Set *)
  SXB = 149; (* 225: Store Indexed Byte *)
  SXW = 150; (* 226: Store Indexed Word *)
  SXD = 151; (* 227: Store Indexed Double *)
  FADD = 152;(* 230: Float Add *)
  FSUB = 153;(* 231: Float Subtract *)
  FMUL = 154;(* 232: Float Multiply *)
  FDIV = 155;(* 233: Float Divide *)
  FCMP = 156;(* 234: Float Compare *)
  FABS = 157;(* 235: Float Absolute *)
  FNEG = 158;(* 236: Float Negate *)
  FFCT = 159;(* 237: Float Function *)
  READ = 164;(* 244: Read *)
  WRITE = 165;(* 245: Write *)
  DSKR = 166;(* 246: Disk Read *)
  DSKW = 167;(* 247: Disk Write *)
  SETRK = 168;(* 250: Set Record Key *)
  UCHK = 169;(* 251: Unsigned Check *)
  SVC = 170; (* 252: Supervisor Call *)
  SYS = 171; (* 253: System Call *)
  ENTP = 172;(* 254: Enter Process *)
  EXP = 173; (* 255: Exit Process *)
  ULSS = 174;(* 256: Unsigned Less *)
  ULEQ = 175;(* 257: Unsigned Less or Equal *)
  UGTR = 176;(* 260: Unsigned Greater *)
  UGEQ = 177;(* 261: Unsigned Greater or Equal *)
  TRA = 178; (* 262: Transfer *)
  RDS = 179; (* 263: Read String *)
  LODFW = 180;(* 264: Load Frame Word *)
  LODFD = 181;(* 265: Load Frame Double *)
  STORE = 182;(* 266: Store Expression Stack *)
  STOFV = 183;(* 267: Store Frame Variable *)
  STOT = 184; (* 270: Store Top *)
  COPT = 185; (* 271: Copy Top *)
  DECS = 186; (* 272: Decrement Stack *)
  PCOP = 187; (* 273: Parameter Copy *)
  UADD = 188; (* 274: Unsigned Add *)
  USUB = 189; (* 275: Unsigned Subtract *)
  UMUL = 190; (* 276: Unsigned Multiply *)
  UDIV = 191; (* 277: Unsigned Divide *)
  UMOD = 192; (* 300: Unsigned Modulo *)
  ROR = 193;  (* 301: Rotate Right *)
  SHL = 194;  (* 302: Shift Left *)
  SHR = 195;  (* 303: Shift Right *)
  FOR1 = 196; (* 304: For Loop Init *)
  FOR2 = 197; (* 305: For Loop Step *)
  ENTC = 198; (* 306: Enter Case *)
  EXC = 199;  (* 307: Exception *)
  TRAP = 200; (* 310: Trap *)
  CHK = 201;  (* 311: Check *)
  CHKZ = 202; (* 312: Check Zero *)
  CHKS = 203; (* 313: Check Sign *)
  EQL = 204;  (* 314: Equal *)
  NEQ = 205;  (* 315: Not Equal *)
  LSS = 206;  (* 316: Less *)
  LEQ = 207;  (* 317: Less or Equal *)
  GTR = 208;  (* 320: Greater *)
  GEQ = 209;  (* 321: Greater or Equal *)
  AbsOp = 210;(* 322: Absolute *)
  NegOp = 211;(* 323: Negate *)
  OrOp = 212; (* 324: Bitwise OR *)
  XorOp = 213;(* 325: Bitwise XOR *)
  AndOp = 214;(* 326: Bitwise AND *)
  COM = 215;  (* 327: Complement *)
  InOp = 216; (* 330: Bit Test *)
  LIN = 217;  (* 331: Load Immediate -1 *)
  MSK = 218;  (* 332: Mask *)
  NotOp = 219;(* 333: Logical NOT *)
  AddOp = 220;(* 334: Add *)
  SubOp = 221;(* 335: Subtract *)
  MulOp = 222;(* 336: Multiply *)
  DivOp = 223;(* 337: Divide *)
  ModOp = 224;(* 340: Modulo *)
  BIT = 225;  (* 341: Bit Set *)
  NOP = 226;  (* 342: No Operation *)
  MOVF = 227; (* 343: Move Float *)
  MOV = 228;  (* 344: Move Block *)
  CMP = 229;  (* 345: Compare Block *)
  DDT = 230;  (* 346: Debugging Tool *)
  REPL = 231; (* 347: Replace *)
  BBLT = 232; (* 350: Block Bit Transfer *)
  DCH = 233;  (* 351: Double Check *)
  UNPK = 234; (* 352: Unpack *)
  PACK = 235; (* 353: Pack *)
  GB = 236;   (* 354: Global Base *)
  GB1 = 237;  (* 355: Global Base 1 *)
  ALLOC = 238;(* 356: Allocate *)
  ENTR = 239; (* 357: Enter *)
  RTN = 240;  (* 360: Return *)
  CX = 241;   (* 361: Call External *)
  CI = 242;   (* 362: Call Internal *)
  CF = 243;   (* 363: Call Formal *)
  CL = 244;   (* 364: Call Local *)
  CL1 = 245;  (* 365: Call Local 1 *)
  CL2 = 246;  (* 366: Call Local 2 *)
  CL3 = 247;  (* 367: Call Local 3 *)
  CL4 = 248;  (* 370: Call Local 4 *)
  CL5 = 249;  (* 371: Call Local 5 *)
  CL6 = 250;  (* 372: Call Local 6 *)
  CL7 = 251;  (* 373: Call Local 7 *)
  CL8 = 252;  (* 374: Call Local 8 *)
  CL9 = 253;  (* 375: Call Local 9 *)
  CL10 = 254; (* 376: Call Local 10 *)
  CL11 = 255; (* 377: Call Local 11 *)

VAR
  a: ARRAY MaxExprStack OF LilithTypes.Word;
  sp: INTEGER;

PROCEDURE BitwiseAnd(a, b: LilithTypes.Word): LilithTypes.Word;
VAR
  longA, longB: LONGINT;
  setA, setB, resultSet: SET;
BEGIN
  longA := LONG(a);
  longB := LONG(b);
  setA := SYSTEM.VAL(SET, longA);
  setB := SYSTEM.VAL(SET, longB);
  resultSet := setA * setB;
  RETURN SYSTEM.VAL(LilithTypes.Word, SYSTEM.VAL(LONGINT, resultSet) MOD 10000H);
END BitwiseAnd;

PROCEDURE BitwiseOr(a: LilithTypes.Word; b: LONGINT): LilithTypes.Word;
VAR
  longA: LONGINT;
  setA, setB, resultSet: SET;
BEGIN
  longA := LONG(a);
  setA := SYSTEM.VAL(SET, longA);
  setB := SYSTEM.VAL(SET, b);
  resultSet := setA + setB;
  RETURN SYSTEM.VAL(LilithTypes.Word, SYSTEM.VAL(LONGINT, resultSet) MOD 10000H);
END BitwiseOr;

PROCEDURE BitwiseXor(a, b: LilithTypes.Word): LilithTypes.Word;
VAR
  longA, longB: LONGINT;
  setA, setB, resultSet: SET;
BEGIN
  longA := LONG(a);
  longB := LONG(b);
  setA := SYSTEM.VAL(SET, longA);
  setB := SYSTEM.VAL(SET, longB);
  resultSet := setA / setB;
  RETURN SYSTEM.VAL(LilithTypes.Word, SYSTEM.VAL(LONGINT, resultSet) MOD 10000H);
END BitwiseXor;

PROCEDURE ClearHighBit(w: LilithTypes.Word): LilithTypes.Word;
VAR
  setW, maskSet: SET;
BEGIN
  setW := SYSTEM.VAL(SET, LONG(w));
  maskSet := SYSTEM.VAL(SET, 7FFFH);  (* 0111 1111 1111 1111 *)
  RETURN SYSTEM.VAL(LilithTypes.Word, SYSTEM.VAL(LONGINT, setW * maskSet) MOD 10000H);
END ClearHighBit;

PROCEDURE Push(w: LilithTypes.Word);
BEGIN
  IF sp < MaxExprStack THEN
    a[sp] := w;
    INC(sp)
  ELSE
    LilithQuit.Quit("Expression Stack Overflow")
  END
END Push;

PROCEDURE Pop(): LilithTypes.Word;
BEGIN
  IF sp > 0 THEN
    DEC(sp);
    RETURN a[sp]
  ELSE
    LilithQuit.Quit("Expression Stack Underflow");
    RETURN 0
  END
END Pop;

PROCEDURE Next(): LilithTypes.Word;
BEGIN
  INC(LilithMemory.PC);
  RETURN ORD(LilithMemory.code[4 * LilithMemory.F + LilithMemory.PC - 1])
END Next;

PROCEDURE SNext(): INTEGER;
VAR b: INTEGER;
BEGIN
  INC(LilithMemory.PC);
  b := ORD(LilithMemory.code[4 * LilithMemory.F + LilithMemory.PC - 1]);
  IF b >= 80H THEN
    RETURN b - 100H  (* Sign extend for negative values *)
  ELSE
    RETURN b
  END
END SNext;

PROCEDURE Next2(): LilithTypes.Word;
VAR hi, lo: INTEGER;
BEGIN
  hi := ORD(LilithMemory.code[4 * LilithMemory.F + LilithMemory.PC]);
  INC(LilithMemory.PC);
  lo := ORD(LilithMemory.code[4 * LilithMemory.F + LilithMemory.PC]);
  INC(LilithMemory.PC);
  RETURN SYSTEM.VAL(LilithTypes.Word, hi * 100H + lo)
END Next2;
(*
PROCEDURE Next2Signed(): INTEGER;
VAR w: LilithTypes.Word;
BEGIN
  w := Next2();
  IF w >= 8000H THEN
    (*RETURN SYSTEM.VAL(INTEGER, w) - 10000H*)  (* Sign extend for negative values *)
    RETURN SYSTEM.VAL(INTEGER, w) - 65536
  ELSE
    RETURN w
  END
END Next2Signed;
*)

PROCEDURE Next2Signed(): INTEGER;
VAR w: LilithTypes.Word;
l: LONGINT;
BEGIN
  w := Next2();
  IF w >= 8000H THEN
    (* Sign extend by converting to LONGINT first *)
    l := LONG(w);
    l := l - 65536;
    RETURN SHORT(w);
  ELSE
    RETURN w
  END
END Next2Signed;

(*
PROCEDURE Mark(x: LilithTypes.Word; external: BOOLEAN);
VAR i: INTEGER;
BEGIN
  i := LilithMemory.S;
  LilithMemory.stack[LilithMemory.S] := x; INC(LilithMemory.S);
  LilithMemory.stack[LilithMemory.S] := LilithMemory.L; INC(LilithMemory.S);
  IF external THEN
    LilithMemory.stack[LilithMemory.S] := LilithMemory.PC + 8000H;
  ELSE
    LilithMemory.stack[LilithMemory.S] := LilithMemory.PC;
  END;
  INC(LilithMemory.S);
  INC(LilithMemory.S);
  LilithMemory.L := i
END Mark;
*)

PROCEDURE Mark(x: LilithTypes.Word; external: BOOLEAN);
VAR
  i: INTEGER;
  pcValue: LilithTypes.Word;
BEGIN
  i := LilithMemory.S;
  LilithMemory.stack[LilithMemory.S] := x; INC(LilithMemory.S);
  LilithMemory.stack[LilithMemory.S] := LilithMemory.L; INC(LilithMemory.S);

  IF external THEN
    pcValue := LilithMemory.PC;
    LilithMemory.stack[LilithMemory.S] := BitwiseOr(pcValue, 8000H);
  ELSE
    LilithMemory.stack[LilithMemory.S] := LilithMemory.PC;
  END;

  INC(LilithMemory.S);
  INC(LilithMemory.S);
  LilithMemory.L := i
END Mark;

PROCEDURE SaveExpStack;
VAR c: INTEGER;
BEGIN
  c := 0;
  WHILE sp # 0 DO
    LilithMemory.stack[LilithMemory.S] := Pop();
    INC(LilithMemory.S);
    INC(c)
  END;
  LilithMemory.stack[LilithMemory.S] := SYSTEM.VAL(LilithTypes.Word, c);
  INC(LilithMemory.S)
END SaveExpStack;

PROCEDURE RestoreExpStack;
VAR c: INTEGER;
BEGIN
  DEC(LilithMemory.S);
  c := SYSTEM.VAL(INTEGER, LilithMemory.stack[LilithMemory.S]);
  WHILE c > 0 DO
    DEC(c);
    DEC(LilithMemory.S);
    Push(LilithMemory.stack[LilithMemory.S])
  END
END RestoreExpStack;

PROCEDURE SaveRegs;
BEGIN
  SaveExpStack;
  LilithMemory.stack[LilithMemory.P] := LilithMemory.G;
  LilithMemory.stack[LilithMemory.P+1] := LilithMemory.L;
  LilithMemory.stack[LilithMemory.P+2] := LilithMemory.PC;
  LilithMemory.stack[LilithMemory.P+3] := LilithMemory.M;
  LilithMemory.stack[LilithMemory.P+4] := LilithMemory.S;
  LilithMemory.stack[LilithMemory.P+5] := SYSTEM.VAL(LilithTypes.Word, SYSTEM.VAL(INTEGER, LilithMemory.H) + 24)
END SaveRegs;

PROCEDURE RestoreRegs(changemask: INTEGER);
BEGIN
  LilithMemory.G := LilithMemory.stack[LilithMemory.P];
  LilithMemory.F := LilithMemory.stack[LilithMemory.G];
  LilithMemory.L := LilithMemory.stack[LilithMemory.P+1];
  IF ~LilithMemory.bootflag THEN
    LilithMemory.PC := LilithMemory.stack[LilithMemory.P+2];
  ELSE
    LilithMemory.PC := 0;
    LilithMemory.PC := Next2();
    LilithMemory.stack[LilithMemory.P+2] := LilithMemory.PC
  END
END RestoreRegs;

PROCEDURE Execute*;
VAR
  opcode: INTEGER;
  w, w1, w2: LilithTypes.Word;
  i, j, k, offset: INTEGER;
  si, sj, sk: INTEGER;
BEGIN
  LilithMemory.PC := 0;
  LOOP
    opcode := ORD(LilithMemory.code[4 * LilithMemory.F + LilithMemory.PC]);
    INC(LilithMemory.PC);

    CASE opcode OF
      (* LI0 to LI15 *)
      0..15: Push(opcode)

    | LIB: Push(Next())
    | LIW: Push(Next2())
    | LID:
        w1 := Next2();
        w2 := Next2();
        Push(w1);
        Push(w2)

    | LLA: Push(LilithMemory.L + SNext())
    | LGA: Push(LilithMemory.G + SNext())
    | LSA: Push(Pop() + SNext())
    | LEA:
        i := Next();
        j := Next();
        Push(LilithMemory.stack[LilithTypes.DFT + i] + j)

    | JPC:
        IF Pop() = 0 THEN
          offset := Next2Signed();
          LilithMemory.PC := LilithMemory.PC + offset - 2
        ELSE
          LilithMemory.PC := LilithMemory.PC + 2
        END

    | JP:
        offset := Next2Signed();
        LilithMemory.PC := LilithMemory.PC + offset - 2

    | JPFC:
        IF Pop() = 0 THEN
          offset := SNext();
          LilithMemory.PC := LilithMemory.PC + offset - 1
        ELSE
          LilithMemory.PC := LilithMemory.PC + 1
        END

    | JPF:
        offset := SNext();
        LilithMemory.PC := LilithMemory.PC + offset - 1

    | JPBC:
        IF Pop() = 0 THEN
          offset := SNext();
          LilithMemory.PC := LilithMemory.PC - offset - 1
        ELSE
          LilithMemory.PC := LilithMemory.PC + 1
        END

    | JPB:
        offset := SNext();
        LilithMemory.PC := LilithMemory.PC - offset - 1

    | ORJP:
        IF Pop() # 0 THEN
          Push(1);
          offset := SNext();
          LilithMemory.PC := LilithMemory.PC + offset - 1
        ELSE
          LilithMemory.PC := LilithMemory.PC + 1
        END

    | ANDJP:
        IF Pop() = 0 THEN
          Push(0);
          offset := SNext();
          LilithMemory.PC := LilithMemory.PC + offset - 1
        ELSE
          LilithMemory.PC := LilithMemory.PC + 1
        END

    | LLW:
        i := LilithMemory.L + SNext();
        Push(LilithMemory.stack[i])

    | LLD:
        i := LilithMemory.L + SNext();
        Push(LilithMemory.stack[i]);
        Push(LilithMemory.stack[i+1])

    | LEW:
        i := Next();
        j := Next();
        Push(LilithMemory.stack[LilithMemory.stack[LilithTypes.DFT + i] + j])

    | LED:
        i := Next();
        j := Next();
        k := LilithMemory.stack[LilithTypes.DFT + i] + j;
        Push(LilithMemory.stack[k]);
        Push(LilithMemory.stack[k+1])

    (* LLW4 to LLW15 *)
    | 36..47: Push(LilithMemory.stack[LilithMemory.L + (opcode MOD 16)])

    | SLW:
        i := LilithMemory.L + SNext();
        LilithMemory.stack[i] := Pop()

    | SLD:
        i := LilithMemory.L + SNext();
        LilithMemory.stack[i+1] := Pop();
        LilithMemory.stack[i] := Pop()

    | SEW:
        i := Next();
        j := Next();
        LilithMemory.stack[LilithMemory.stack[LilithTypes.DFT + i] + j] := Pop()

    | SED:
        i := Next();
        j := Next();
        k := LilithMemory.stack[LilithTypes.DFT + i] + j;
        LilithMemory.stack[k+1] := Pop();
        LilithMemory.stack[k] := Pop()

    (* SLW4 to SLW15 *)
    | 52..63: LilithMemory.stack[LilithMemory.L + (opcode MOD 16)] := Pop()

    | LGW:
        i := LilithMemory.G + Next();
        Push(LilithMemory.stack[i])

    | LGD:
        i := LilithMemory.G + Next();
        Push(LilithMemory.stack[i]);
        Push(LilithMemory.stack[i+1])

    (* LGW2 to LGW15 *)
    | 66..79: Push(LilithMemory.stack[LilithMemory.G + (opcode MOD 16)])

    | SGW:
        i := LilithMemory.G + Next();
        LilithMemory.stack[i] := Pop()

    | SGD:
        i := LilithMemory.G + Next();
        LilithMemory.stack[i+1] := Pop();
        LilithMemory.stack[i] := Pop()

    (* SGW2 to SGW15 *)
    | 82..95: LilithMemory.stack[LilithMemory.G + (opcode MOD 16)] := Pop()

    | RTN:
        LilithMemory.S := LilithMemory.L;
        LilithMemory.L := LilithMemory.stack[LilithMemory.S+1];
        w := LilithMemory.stack[LilithMemory.S+2];
        IF (w >= 8000H) THEN
            LilithMemory.G := LilithMemory.stack[LilithMemory.S];
            LilithMemory.F := LilithMemory.stack[LilithMemory.G];
            LilithMemory.PC := ClearHighBit(w);  (* Clear high bit *)
        ELSE
            LilithMemory.PC := w
        END;
        IF LilithMemory.PC = 0 THEN
            LilithEnd.EOX
        END
    | CX: (* 241 - Call External *)
        j := Next();
        i := Next();
        Mark(LilithMemory.G, TRUE);
        LilithMemory.G := LilithMemory.stack[LilithTypes.DFT + j];
        LilithMemory.F := LilithMemory.stack[LilithMemory.G];
        LilithMemory.PC := 2 * i;
        LilithMemory.PC := SYSTEM.VAL(INTEGER, Next2())

    | CI:  (* 242 - Call Internal *)
        i := Next();
        Mark(Pop(), FALSE);
        LilithMemory.PC := 2 * i;
        LilithMemory.PC := SYSTEM.VAL(INTEGER, Next2())

    | CF:    (* 243 - Call Formal *)
        i := Pop();
        Mark(LilithMemory.G, TRUE);
        j := i DIV 100H;
        LilithMemory.G := LilithMemory.stack[LilithTypes.DFT + j];
        LilithMemory.F := LilithMemory.stack[LilithMemory.G];
        LilithMemory.PC := 2 * (i MOD 100H);
        LilithMemory.PC := SYSTEM.VAL(INTEGER, Next2())

    | CL:  (* 244 - Call Local *)
        i := Next();
        Mark(LilithMemory.L, FALSE);
        LilithMemory.PC := 2 * i;
        LilithMemory.PC := SYSTEM.VAL(INTEGER, Next2())

    (* CL1 to CL15 *)
    | 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255:
        Mark(LilithMemory.L, FALSE);
        LilithMemory.PC := 2 * (opcode MOD 16);
        LilithMemory.PC := SYSTEM.VAL(INTEGER, Next2())
    | CHK:
        w := Pop();
        IF (w < 8000H) OR (w > 7FFFH) THEN  (* Check 16-bit signed range *)
            Out.String("CHKI failed: "); Out.Int(SYSTEM.VAL(INTEGER, w), 1); Out.Ln;
            LilithQuit.Quit("CHKI: Integer overflow")
        END;
        Push(w)

    | CHKS:
        w := Pop();
        IF (w < 0) OR (w > 255) THEN
            Out.String("CHKS failed: "); Out.Int(SYSTEM.VAL(INTEGER, w), 1); Out.Ln;
            LilithQuit.Quit("CHKS: Set index out of bounds")
        END;
        Push(w)

    | NotOp:  (* Logical NOT *)
        w := Pop();
        IF w = 0 THEN Push(1) ELSE Push(0) END

    | AndOp:  (* Bitwise AND *)
        w2 := Pop();
        w1 := Pop();
        Push(BitwiseAnd(w1, w2))

    | OrOp:   (* Bitwise OR *)
        w2 := Pop();
        w1 := Pop();
        Push(BitwiseOr(w1, w2))

    | XorOp:  (* Bitwise XOR *)
        w2 := Pop();
        w1 := Pop();
        Push(BitwiseXor(w1, w2))

    | SHL:    (* Shift Left *)
        w2 := Pop() MOD 16;
        w1 := Pop();
        Push(SYSTEM.VAL(LilithTypes.Word, ASH(SYSTEM.VAL(INTEGER, w1), w2)))

    | SHR:    (* Shift Right *)
        w2 := Pop() MOD 16;
        w1 := Pop();
        Push(SYSTEM.VAL(LilithTypes.Word, ASH(SYSTEM.VAL(INTEGER, w1), -w2)))
    ELSE
        Out.String("Unknown opcode: "); Out.Int(opcode, 5); Out.Ln;
        LilithQuit.Quit("Unknown opcode")
    END
  END
END Execute;

END LilithExec.
