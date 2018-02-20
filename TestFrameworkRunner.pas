unit TestFrameworkRunner;

interface

function RunRegisteredTestsGUIOrConsole(IsConsole: Boolean): Integer;

implementation

uses
  SysUtils,
  {$IFDEF FPC}
  TestFrameworkProxyIfaces,
  {$ENDIF FPC}
  TestFramework, TextTestRunner, GUITestRunner;

function RunRegisteredTestsGUIOrConsole(IsConsole: Boolean): Integer;
var
  LTestResult: {$IFDEF FPC}ITestResult{$ELSE}TTestResult{$ENDIF};
begin
  Result := S_OK;
  if IsConsole then
  begin
    LTestResult := TextTestRunner.RunRegisteredTests;
    try
      // set bits:
      //   0 - there were errors
      //   1 - there were failures
      Result := Ord(LTestResult.ErrorCount > 0) shl 1
        or Ord(LTestResult.FailureCount > 0);
    finally
      {$IFDEF FPC}
      LTestResult := nil;
      {$ELSE FPC}
      FreeAndNil(LTestResult);
      {$ENDIF FPC}
    end;
  end
  else
    GUITestRunner.RunRegisteredTests;
end;

end.
