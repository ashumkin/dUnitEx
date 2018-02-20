unit TestSetupEx;

interface

uses
  TestFramework, TestExtensions;

type
  TTestSetupEx = class(TTestSetup, ITestSuite)
  protected
    function CountTestsInterfaces: Integer;
    function CountEnabledTestInterfaces: Integer;

    procedure AddTests(ATests: array of ITest); overload;
    procedure AddTest(ATest: ITest);
    procedure AddSuite(ASuite: ITestSuite);

    procedure RunTest(ATestResult: TTestResult); override;
  public
    function CountTestCases: Integer; override;
    function CountEnabledTestCases: Integer; override;

    function GetName: string; override;

    constructor Create(ATest: ITest; AName: string = ''); reintroduce; overload;
    constructor Create(const AName: string; ATests: array of ITest); overload;
  end;

implementation

{ TTestSetupEx }

procedure TTestSetupEx.AddSuite(ASuite: ITestSuite);
begin
  AddTest(ASuite);
end;

procedure TTestSetupEx.AddTest(ATest: ITest);
begin
  if FTest = nil then
    FTest := ATest;
  FTests.Add(ATest);
end;

procedure TTestSetupEx.AddTests(ATests: array of ITest);
var
  i: Integer;
begin
  for i := Low(ATests) to High(ATests) do
    AddTest(ATests[i]);
end;

function TTestSetupEx.CountEnabledTestCases: Integer;
begin
  Result := 0;
  if Assigned(FTest) then
    Result := inherited CountEnabledTestCases;
  if Enabled then
    Inc(Result, CountEnabledTestInterfaces);
end;

function TTestSetupEx.CountEnabledTestInterfaces: Integer;
var
  i: Integer;
begin
  Result := 0;
  // skip FIRST test case (it is FTest)
  for i := 1 to FTests.Count - 1 do
    if (FTests[i] as ITest).Enabled then
      Inc(Result, (FTests[i] as ITest).CountEnabledTestCases);
end;

function TTestSetupEx.CountTestCases: Integer;
begin
  Result := 0;
  if Assigned(FTest) then
    Result := inherited CountTestCases;
  if Enabled then
    Inc(Result, CountTestsInterfaces);
end;

function TTestSetupEx.CountTestsInterfaces: Integer;
var
  i: Integer;
begin
  Result := 0;
  // skip FIRST test case (it is FTest)
  for i := 1 to FTests.Count - 1 do
    Inc(Result, (FTests[i] as ITest).CountTestCases);
end;

constructor TTestSetupEx.Create(const AName: string; ATests: array of ITest);
begin
  Create(nil, AName);
  AddTests(ATests);
end;

function TTestSetupEx.GetName: string;
begin
  Result := FTestName;
end;

procedure TTestSetupEx.RunTest(ATestResult: TTestResult);
var
  i: Integer;
begin
  inherited;
  // skip FIRST test case (it is FTest)
  for i := 1 to FTests.Count - 1 do
    (FTests[i] as ITest).RunWithFixture(ATestResult);
end;

constructor TTestSetupEx.Create(ATest: ITest; AName: string);
begin
  if Assigned(ATest) then
    AName := ATest.Name;
  inherited Create(ATest, AName);
  FTests.Remove(nil);
end;

end.
