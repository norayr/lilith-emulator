MODULE LilithQuit;

IMPORT Out;

PROCEDURE Quit*(msg: ARRAY OF CHAR);
BEGIN
  Out.String(msg); Out.Ln;
  HALT(1)
END Quit;

END LilithQuit.

