MODULE LilithLoad;

IMPORT LilithMemory, LilithTypes, Files, LilithQuit;

CONST
  EOFSY = 0;
  xBASE = 300H;
  xDATATEXT = 301H;
  xCODETEXT = 302H;
  xMODULE = 303H;

VAR R: Files.Rider;

PROCEDURE GetByte(VAR ch: CHAR): BOOLEAN;
BEGIN
  IF R.eof THEN RETURN FALSE END;
  Files.Read(R, ch);
  RETURN ~R.eof
END GetByte;

PROCEDURE GetWord(): LilithTypes.Word;
VAR ch1, ch2: CHAR;
BEGIN
  IF ~GetByte(ch1) OR ~GetByte(ch2) THEN
    LilithQuit.Quit("unexpected EOF reading word")
  END;
  RETURN ORD(ch1)*100H + ORD(ch2)
END GetWord;

PROCEDURE LoadFile*(name: ARRAY OF CHAR);
VAR
  f: Files.File;
  ch: CHAR;
  i, base, size, typ: INTEGER;
BEGIN
  f := Files.Old(name);
  IF f = NIL THEN
    LilithQuit.Quit("cannot open file")
  END;

  Files.Set(R, f, 0);

  LOOP
    IF ~GetByte(ch) THEN EXIT END;
    typ := ORD(ch);
    IF typ = EOFSY THEN EXIT END;

    size := GetWord();
    base := GetWord();

    CASE typ OF
      xBASE, xDATATEXT, xMODULE:
        FOR i := 0 TO size - 1 DO
          LilithMemory.stack[base + i] := GetWord()
        END
    | xCODETEXT:
        FOR i := 0 TO size - 1 DO
          IF ~GetByte(ch) THEN
            LilithQuit.Quit("EOF in code section")
          END;
          LilithMemory.code[base + i] := ch
        END
    ELSE
      LilithQuit.Quit("file corrupted")
    END
  END;

  Files.Register(f); (* optional cleanup *)
END LoadFile;

END LilithLoad.

