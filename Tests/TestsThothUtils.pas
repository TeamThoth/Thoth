unit TestsThothUtils;

interface

uses
  Thoth.Config, Thoth.Config.Types,
  DUnitX.TestFramework;

type
  [TestFixture]
  TThothUtilsTest = class
  public
    [Test]
    procedure TestAttrFindAttribute;

    [Test]
    procedure TestAttrFindAttributeInThothConfig;
  end;

  [ConfigName('Env')]
  TEnv = class(TThothConfig)
  private
    FPort: Integer;
    FIpAddr: string;
  public
    [ConfigItem('Server', '192.168.0.1')]
    property IpAddr: string read FIpAddr write FIpAddr;
    [ConfigItem('Server', 8080)]
    property Port: Integer read FPort write FPort;
  end;

implementation

uses
  Thoth.Utils,
  Thoth.Config.Loader.IniFile;

{ TThothUtilsTest }

procedure TThothUtilsTest.TestAttrFindAttribute;
var
  Env: TEnv;
  LAttr: ConfigNameAttribute;
begin
  Env := TEnv.Create(TIniFileConfigLoader.Create as IConfigLoader);

  LAttr := TAttributeUtil.FindAttribute<ConfigNameAttribute>(Env);

  Assert.AreEqual(LAttr.ConfigName, 'Env');

  Env.Free;
end;

procedure TThothUtilsTest.TestAttrFindAttributeInThothConfig;
var
  Env: TEnv;
  LAttr: ConfigNameAttribute;
begin
  Env := TEnv.Create(TIniFileConfigLoader.Create as IConfigLoader);

  Assert.AreEqual(Env.ConfigName, 'Env');

  Env.Free;
end;

initialization
  TDUnitX.RegisterTestFixture(TThothUtilsTest);

end.
