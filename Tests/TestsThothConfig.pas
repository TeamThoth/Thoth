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
  Thoth.Config.Types,
  Thoth.Config, Thoth.Config.Loader.IniFile,
  Vcl.Forms, System.Types;

type
  TTestWS = record
    WS: TWindowState;
    Int: Integer;
  end;

  [ConfigName('ThConfig.ini')]
  TIniConfig = class(TThothConfig)
  private
    FInt: Integer;
    FStr: string;
    FDtm: TDatetime;
    FTestWS: TTestWS;
    FBool: Boolean;
    FWindowState: TWindowState;
    FDbl: Double;
    FWindowBounds: TRect;
  public
    [IntItem('TestSect', 10)]
    property Int: Integer read FInt write FInt;

    [StrItem('TestSect', 'abcd')]
    property Str: string read FStr write FStr;

    [BoolItem('TestSect', True)]
    property Bool: Boolean read FBool write FBool;

    [EnumItem('TestSect', 'wsMaximized')]
    property WindowState: TWindowState read FWindowState write FWindowState;

    [RecItem('TestSect', 'WS, Int', 'wsMinimized, 20')]
    property TestWS: TTestWS read FTestWS write FTestWS;

    [RecItem('TestSect', 'Left, Top', '30,40')]
    property WindowBounds: TRect read FWindowBounds write FWindowBounds;

    [DateTimeItem('TestSect')]
    property Dtm: TDatetime read FDtm write FDtm;

    [DblItem('TestSect', 10.23)]
    property Dbl: Double read FDbl write FDbl;
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
  Conf := TIniConfig.Create(TIniConfig.DefaultLoader);

  Conf.Load;

  Assert.AreEqual(Conf.Int, 10);
  Assert.AreEqual(Conf.Str, 'abcd');
  Assert.AreEqual(Conf.TestWS.Int, 20);
  Assert.AreEqual(Conf.WindowBounds.Left, 30);

  Conf.Free;
end;

initialization
  TDUnitX.RegisterTestFixture(TThothConfigTest);

end.
