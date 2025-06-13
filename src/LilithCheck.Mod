MODULE LilithCheck;

IMPORT LilithMemory, LilithFS, Out;

PROCEDURE Check*;
BEGIN
  IF LilithMemory.PC = 3651H THEN
    Out.String("NextCh : ch = '");
    Out.Char(CHR(LilithMemory.stack[LilithMemory.G + 7]));
    Out.String("' , (");
    Out.Int(LilithMemory.stack[LilithMemory.G + 7], 4); Out.String(")\n");
    LilithFS.Show(LilithMemory.stack^, 41764H)
  END
END Check;

END LilithCheck.
