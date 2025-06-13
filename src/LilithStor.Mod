MODULE LilithStor;

IMPORT LilithTypes, LilithStorage;

PROCEDURE LoadW*(addr: INTEGER): LilithTypes.Word;
BEGIN
  RETURN LilithStorage.stack[addr]
END LoadW;

PROCEDURE StoreW*(addr, val: INTEGER);
BEGIN
  LilithStorage.stack[addr] := val
END StoreW;

END LilithStor.

