MODULE LilithTypes;

CONST
  TRUE* = 1;
  FALSE* = 0;

  EOFSY*     = 0;
  xBASE*     = 300H;
  xDATATEXT* = 301H;
  xCODETEXT* = 302H;
  xMODULE*   = 303H;

  DFT* = 40;
  TLC* = 16;

TYPE
  Word* = INTEGER;  (* 16-bit unsigned *)
  Short* = SHORTINT;
  Address* = INTEGER;

PROCEDURE IsVisible*(ch: CHAR): BOOLEAN;
BEGIN
  RETURN (ch >= ' ') & (ch <= '~')
END IsVisible;

END LilithTypes.

