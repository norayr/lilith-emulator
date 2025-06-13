MODULE LilithStack;

IMPORT LilithTypes;

CONST
  MaxStack = 16;

VAR
  sp: INTEGER;
  a: ARRAY MaxStack OF LilithTypes.Word;

PROCEDURE Empty*(): BOOLEAN;
BEGIN
  RETURN sp = 0
END Empty;

PROCEDURE Push*(x: LilithTypes.Word);
BEGIN
  IF sp >= MaxStack THEN
    HALT(99)  (* Or raise an error *)
  END;
  a[sp] := x;
  INC(sp)
END Push;

PROCEDURE Pop*(): LilithTypes.Word;
BEGIN
  IF sp = 0 THEN HALT(98) END;
  DEC(sp);
  RETURN a[sp]
END Pop;

END LilithStack.

