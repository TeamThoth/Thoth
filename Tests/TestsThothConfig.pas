unit TestsThothConfig;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TThothConfigTest = class
  public
    [Setup]     procedure Setup;
    [TearDown]  procedure TearDown;

    [Test]      procedure TestInitIniConfig;
  end;

implementation

uses
  Thoth.Config;

type
  [ConfigName('ThConfig.ini')]
  TIniConfig = class(TThothConfig)
  private
    FInt: Integer;
  public
    [IntegerItem('TestKey', 10)]
    property Int: Integer read FInt write FInt;
  end;

procedure TThothConfigTest.Setup;
begin
end;

procedure TThothConfigTest.TearDown;
begin
end;

procedure TThothConfigTest.TestInitIniConfig;
var
  Conf: TIniConfig;
begin
  Conf := TIniConfig.Create;
  Conf.Free;
end;

initialization
  TDUnitX.RegisterTestFixture(TThothConfigTest);

end.
