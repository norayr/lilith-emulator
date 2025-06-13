MODULE LilithEnd;

IMPORT LilithMemory, Out, In;

VAR
  line: ARRAY 16 OF CHAR;

PROCEDURE OctalToInt(line: ARRAY OF CHAR): INTEGER;
VAR i, val: INTEGER;
BEGIN
  val := 0; i := 0;
  WHILE (line[i] >= '0') & (line[i] <= '7') DO
    val := val * 8 + ORD(line[i]) - ORD('0');
    INC(i)
  END;
  RETURN val
END OctalToInt;

PROCEDURE EOX*;
VAR
  i, index, cmd, val: INTEGER;
  ch: CHAR;
BEGIN
  Out.String("\n\nEnd of execution....\n");

  In.Open;

  LOOP
    In.Line(line);
    index := OctalToInt(line);
    cmd := ORD('o');  (* default *)

    (* skip spaces, read command char *)
    ch := line[0];
    i := 0;
    WHILE (line[i] = ' ') DO INC(i) END;
    IF (line[i] # 0X) & (line[i] # 0AX) THEN
      cmd := ORD(line[i])
    END;

    IF (index < 0) OR (index >= LilithMemory.stacksize + LilithMemory.datasize + LilithMemory.heapsize) THEN
      index := 0
    END;

    CASE CHR(cmd) OF
      'o':
        Out.Int(index, 5); Out.Char(' ');
        Out.Int(LilithMemory.stack[index], 5); Out.Ln;
        INC(index)
    | 's':
        Out.Int(index, 5); Out.Char(' ');
        WHILE (LilithMemory.stack[index] # 0)
            & (index < LilithMemory.stacksize + LilithMemory.datasize + LilithMemory.heapsize) DO
          Out.Char(CHR(LilithMemory.stack[index]));
          INC(index)
        END;
        INC(index); Out.Ln
    | 'c':
        val := LilithMemory.stack[index];
        Out.Int(index, 5); Out.String(" '");
        Out.Char(CHR(val DIV 256)); Out.String("' '");
        Out.Char(CHR(val MOD 256)); Out.String("' ");
        Out.Int(val DIV 256, 3); Out.Char(' ');
        Out.Int(val MOD 256, 3); Out.Ln;
        INC(index)
    | 'x':
        HALT(0)
    ELSE
        Out.String("??? "); cmd := ORD('o')
    END
  END
END EOX;

END LilithEnd.

