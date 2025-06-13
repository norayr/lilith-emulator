MODULE LilithFS;

IMPORT Out, LilithTypes;

PROCEDURE Show*(VAR start: ARRAY OF LilithTypes.Word; offset: LONGINT);
VAR i: LONGINT; ch: CHAR;
BEGIN
  i := offset;
  WHILE start[i] # 0 DO
    ch := CHR(start[i]);
    IF LilithTypes.IsVisible(ch) THEN
      Out.Char(ch)
    ELSE
      Out.Char('.')
    END;
    INC(i)
  END;
  Out.Ln
END Show;

END LilithFS.
