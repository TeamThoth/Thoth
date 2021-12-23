unit TestsThothConfig;

interface

uses
  DUnitX.TestFramework,
  TestsDatas,

  FireDAC.Comp.Client,
  FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite;

type
  [TestFixture]
  TThothConfigTest = class
  private
    FConnection: TFDConnection;
  public
    [SetupFixture]    procedure SetupFixture;
    [TearDownFixture] procedure TearDownFixture;

    [Setup]     procedure Setup;
    [TearDown]  procedure TearDown;

    [Test]
    procedure TestInitIniConfig;  // 초기 값 지정 확인

    [Test]
    procedure TestSaveIniConfig;  // 설정 값 저장 확인

    [Test]
    procedure TestLoadIniConfig;  // 설정 값 불러오기 확인
  end;

implementation

uses
  Thoth.Config.Types,
  Thoth.Config, Thoth.Config.Loader.IniFile,
  System.SysUtils, System.IniFiles,
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
    FIntDef: Integer;
    FStr: string;
    FDtm: TDatetime;
    FTestWS: TTestWS;
    FBool: Boolean;
    FWindowState: TWindowState;
    FDbl: Double;
    FWindowBounds: TRect;
    FDtmStr: TDatetime;
  public
    [ConfigItem('TestSect', 10)]
    property Int: Integer read FInt write FInt;

    [ConfigItem('TestSect')]
    property IntDef: Integer read FIntDef write FIntDef;

    [ConfigItem('TestSect', 'abcd')]
    property Str: string read FStr write FStr;

    [ConfigItem('TestSect', False)]
    property Bool: Boolean read FBool write FBool;

    [ConfigItem('TestSect', 'wsMaximized')]
    [ConfigKeyName('WS')]
    property WindowState: TWindowState read FWindowState write FWindowState;

    [ConfigItem('TestSect')]
    [ConfigTargetFields('WS, Int', 'wsMinimized, 20')]
    property TestWS: TTestWS read FTestWS write FTestWS;

    [ConfigItem('TestSect')]
    [ConfigTargetFields('Left, Top', '30,40')]
    property WindowBounds: TRect read FWindowBounds write FWindowBounds;

    [ConfigItem('TestSect')]
    property Dtm: TDatetime read FDtm write FDtm;

    [ConfigItem('TestSect', '2021-12-23')]
    [ConfigKeyName('DateTimeStr')]
    property DtmStr: TDatetime read FDtmStr write FDtmStr;

    [ConfigItem('TestSect', 10.23)]
    property Dbl: Double read FDbl write FDbl;
  end;


  [ConfigName('ThConfig')] // Database
  TSQLConfig = class(TThothConfig)
  private
    FInt: Integer;
    FStr: string;
    FTestWS: TTestWS;
  public
    [ConfigItem('TestSect', 10)] // TableName
    property Int: Integer read FInt write FInt;

    [ConfigItem('TestSect', 'abcd')]
    property Str: string read FStr write FStr;

    [ConfigItem('TestSect')]
    [ConfigKeyName('')]
    [ConfigTargetFields('WS, TestInt', 'wsMinimized, 20')]
    property TestWS: TTestWS read FTestWS write FTestWS;
  end;

procedure TThothConfigTest.Setup;
begin
end;

procedure TThothConfigTest.SetupFixture;
begin
  FormatSettings.DateSeparator := '-';
  FormatSettings.TimeSeparator := ':';

  FConnection := TFDConnection.Create(nil);
  FConnection.Params.DriverID := 'SQLite';
  FConnection.Params.Database := ExtractFilePath(Paramstr(0)) + 'Thoth.sqlite';
  FConnection.ExecSQL(CONFIG_CREATE_SQL);
end;

procedure TThothConfigTest.TearDown;
begin
end;

procedure TThothConfigTest.TearDownFixture;
begin
  FConnection.Free;
end;

procedure TThothConfigTest.TestInitIniConfig;
var
  Conf: TIniConfig;
begin
  Conf := TIniConfig.Create(TIniConfig.DefaultLoader);

  Conf.Clear;
  Conf.Load;

  Assert.AreEqual(Conf.Int, 10);
  Assert.AreEqual(Conf.Str, 'abcd');
  Assert.AreEqual(Conf.WindowState, wsMaximized);
  Assert.AreEqual(Conf.TestWS.Int, 20);
  Assert.AreEqual(Conf.WindowBounds.Left, 30);
  Assert.AreEqual(Conf.WindowBounds.Bottom, 0, '미지정 시 초기값 0?');

  Assert.AreEqual(FormatDateTime('YYYY-MM-DD', Conf.DtmStr), '2021-12-23');

  Assert.AreEqual(Conf.Dbl, Double(10.23));

  Conf.Free;
end;

procedure TThothConfigTest.TestSaveIniConfig;
var
  Conf: TIniConfig;
  IniFile: TIniFile;
begin
  Conf := TIniConfig.Create(TIniFileConfigLoader.Create as IConfigLoader);

  Conf.Load;

  Conf.Int := 100;
  Conf.Str := '가나다';
  Conf.WindowState := TWindowState.wsMinimized;
  var TestWS := Conf.TestWS;
  TestWS.Int := 999;
  Conf.TestWS := TestWS;

  Conf.Save;

  IniFile := TIniFile.Create(ExtractFilePath(Paramstr(0)) + 'ThConfig.ini');

  Assert.AreEqual(IniFile.ReadInteger('TestSect', 'Int', 0), 100);
  Assert.AreEqual(IniFile.ReadString('TestSect', 'Str', ''), '가나다');
  Assert.AreEqual(TWindowState(IniFile.ReadInteger('TestSect', 'WS', 0)), wsMinimized);
  Assert.AreEqual(IniFile.ReadInteger('TestSect', 'TestWS.Int', 0), 999);

  IniFile.Free;
  Conf.Free;
end;

procedure TThothConfigTest.TestLoadIniConfig;
var
  Conf: TIniConfig;
begin
  Conf := TIniConfig.Create(
    function: IConfigLoader
    begin
      Result := TIniFileConfigLoader.Create
    end
  );
  Conf.Clear;
  Conf.Load;

  Conf.Int := 256;
  Conf.Str := 'How are you?';
  Conf.WindowState := TWindowState.wsMaximized;
  var TestWS := Conf.TestWS;
  TestWS.Int := 987;
  Conf.TestWS := TestWS;
  var Rect: TRect := Conf.WindowBounds;
  Rect := TRect.Create(101, 202, 303, 404); // Target(Left, Top)
  Conf.WindowBounds := Rect;
  Conf.Save;
  Conf.Free;

  Conf := TIniConfig.Create(TIniConfig.DefaultLoader);
  Conf.Load;

  Assert.AreEqual(Conf.Int, 256);
  Assert.AreEqual(Conf.Str, 'How are you?');
  Assert.AreEqual(Conf.WindowState, wsMaximized);
  Assert.AreEqual(Conf.TestWS.Int, 987);
  Assert.AreEqual(Conf.WindowBounds, TRect.Create(101, 202, 0, 0));
  Conf.Free;
end;

initialization
  TDUnitX.RegisterTestFixture(TThothConfigTest);

end.
