MODULE LilithStorage;

IMPORT SYSTEM, LilithTypes;

VAR
  stack*: POINTER TO ARRAY OF LilithTypes.Word;
  stacksize*: INTEGER;

PROCEDURE AllocateStack*(size: INTEGER);
BEGIN
  NEW(stack, size);
  stacksize := size
END AllocateStack;

END LilithStorage.
