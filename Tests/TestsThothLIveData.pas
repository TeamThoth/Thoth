unit TestsThothLIveData;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TThothLiveDataTest = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
  end;

implementation

procedure TThothLiveDataTest.Setup;
begin
end;

procedure TThothLiveDataTest.TearDown;
begin
end;

initialization
  TDUnitX.RegisterTestFixture(TThothLiveDataTest);

end.
