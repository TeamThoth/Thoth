unit TestsThothConfig;

interface

uses
  DUnitX.TestFramework,
  TestsDatas,
  Thoth.Config.Types,
  Thoth.Config.Loader.SQL,

  FireDAC.Comp.Client,
  FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite;

type
  [TestFixture]
  TThothConfigTest = class
  private
    FConnection: TFDConnection;

    function DefaultSQLConfigLoader: TSQLConfigLoader;
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

    [Test]
    procedure TestInitSQLConfig;

    [Test]
    procedure TestSaveSQLConfig;

    [Test]
    procedure TestLoadSQLConfig;
  end;

implementation

uses
  Thoth.Config,
  Thoth.Config.Loader.IniFile,
  Thoth.Config.SQLExecutor,

  System.SysUtils, System.IniFiles,
  Vcl.Forms, System.Types;

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
  FConnection.Open;

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

  Assert.AreEqual(Conf.Int, 10);
  Assert.AreEqual(Conf.Str, 'abcd');
  Assert.AreEqual(Conf.WindowState, wsMaximized);
  Assert.AreEqual(Conf.Rec1.Int, 20);
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

  Conf.Int := 100;
  Conf.Str := '가나다';
  Conf.WindowState := TWindowState.wsMinimized;
  var Rec1 := Conf.Rec1;
  Rec1.Int := 999;
  Conf.Rec1 := Rec1;

  Conf.Save;

  IniFile := TIniFile.Create(ExtractFilePath(Paramstr(0)) + 'ThConfig.ini');

  Assert.AreEqual(IniFile.ReadInteger('TestSect', 'Int', 0), 100);
  Assert.AreEqual(IniFile.ReadString('TestSect', 'Str', ''), '가나다');
  Assert.AreEqual(TWindowState(IniFile.ReadInteger('TestSect', 'WS', 0)), wsMinimized);
  Assert.AreEqual(IniFile.ReadInteger('TestSect', 'Rec1.Int', 0), 999);

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

  Conf.Int := 256;
  Conf.Str := 'How are you?';
  Conf.WindowState := TWindowState.wsMaximized;

  var Rec1 := Conf.Rec1;
  Rec1.Int := 987;
  Conf.Rec1 := Rec1;

  var Rect: TRect := Conf.WindowBounds;
  Rect := TRect.Create(101, 202, 303, 404); // Target(Left, Top)
  Conf.WindowBounds := Rect;

  Conf.Save;
  Conf.Free;

  Conf := TIniConfig.Create(TIniConfig.DefaultLoader);

  Assert.AreEqual(Conf.Int, 256);
  Assert.AreEqual(Conf.Str, 'How are you?');
  Assert.AreEqual(Conf.WindowState, wsMaximized);
  Assert.AreEqual(Conf.Rec1.Int, 987);
  Assert.AreEqual(Conf.WindowBounds, TRect.Create(101, 202, 0, 0));
  Conf.Free;
end;

function TThothConfigTest.DefaultSQLConfigLoader: TSQLConfigLoader;
var
  Loader: TSQLConfigLoader;
  SQLExecutor: TSQLConfigFireDACExecutor;
begin
  SQLExecutor := TSQLConfigFireDACExecutor.Create(FConnection);
  Loader := TSQLConfigLoader.Create(SQLExecutor);

  Result := Loader;
end;

procedure TThothConfigTest.TestInitSQLConfig;
var
  Conf: TSQLConfig;
begin
  Conf := TSQLConfig.Create(DefaultSQLConfigLoader);
  Conf.Clear;

  Assert.AreEqual(Conf.Int, 10);
  Assert.AreEqual(Conf.Str, 'abcd');
  Assert.AreEqual(Conf.TestWS.WS, wsMinimized);
  Assert.AreEqual(Conf.TestWS.Int, 20);
  Assert.AreEqual(FormatDateTime('YYYY-MM-DD', Conf.DtmStr), '2021-12-23');

  Conf.Free;
end;

procedure TThothConfigTest.TestSaveSQLConfig;
var
  Conf: TSQLConfig;
begin
  Conf := TSQLConfig.Create(DefaultSQLConfigLoader);

  Conf.Int := 30;
  Conf.Str := 'test';
  var Rec := Conf.TestWS;
  Rec.WS := wsMaximized;
  Rec.Int := 200;
  Conf.TestWS := Rec;

  Conf.Save;

  Conf.Free;
end;

procedure TThothConfigTest.TestLoadSQLConfig;
var
  Conf: TSQLConfig;
  Int: Integer;
begin
  Conf := TSQLConfig.Create(DefaultSQLConfigLoader);
  Conf.Int := 90;
  Conf.Str := 'saved';
  Conf.DtmStr := EncodeDate(2021, 12, 30);
  var Rec := Conf.TestWS;
  Rec.WS := wsMaximized;
  Rec.Int := 200;
  Conf.TestWS := Rec;
  Conf.Save;
  Conf.Free;

  Conf := TSQLConfig.Create(DefaultSQLConfigLoader);
  Assert.AreEqual(Conf.Int, 90);
  Assert.AreEqual(Conf.Str, 'saved');
  Assert.AreEqual(Conf.DtmStr, EncodeDate(2021, 12, 30));
  Assert.AreEqual(Conf.TestWS.WS, wsMaximized);
  Conf.Free;
end;

initialization
  TDUnitX.RegisterTestFixture(TThothConfigTest);

end.
