unit Thoth.Config;

interface

uses
  Thoth.Classes,
  Thoth.Config.Types,
  Thoth.Config.Loader;

type
  TThothConfig = class(TNoRefCountObject, IConfig)
  private
    FConfigName: string;
    FLoader: IConfigLoader;
    function GetConfigName: string;
    procedure SetConfigName(const Value: string);
  protected
    procedure CheckLoader;
  public
    constructor Create(AConfigName: string = ''); overload;

    constructor Create(ALoader: IConfigLoader); overload;
    constructor Create(AConfigName: string; ALoader: IConfigLoader); overload;

    constructor Create(ALoaderClass: TConfigLoaderClass); overload;
    constructor Create(AConfigName: string; ALoaderClass: TConfigLoaderClass); overload;

    constructor Create(ACreateFunc: TConfigLoaderCreateFunc); overload;
    constructor Create(AConfigName: string; ACreateFunc: TConfigLoaderCreateFunc); overload;

    procedure Load;
    procedure Save;

    property ConfigName: string read GetConfigName write SetConfigName;

    destructor Destroy; override;
    class function DefaultLoader: IConfigLoader;
  end;

implementation

uses
  System.SysUtils,
  Thoth.ResourceStrings,
  Thoth.Utils,
  Thoth.Config.Loader.IniFile // Default loader
;

{ TCustomConfig }

constructor TThothConfig.Create(AConfigName: string);
begin
  FConfigName := AConfigName;
end;

constructor TThothConfig.Create(ALoaderClass: TConfigLoaderClass);
begin
  Create('', ALoaderClass);
end;

constructor TThothConfig.Create(ACreateFunc: TConfigLoaderCreateFunc);
begin
  Create('', ACreateFunc);
end;

constructor TThothConfig.Create(ALoader: IConfigLoader);
begin
  Create('', ALoader);
end;

procedure TThothConfig.CheckLoader;
begin
  if not Assigned(FLoader) then
    raise Exception.CreateFmt(SNotAssigned, ['loader']);
end;

constructor TThothConfig.Create(AConfigName: string;
  ACreateFunc: TConfigLoaderCreateFunc);
begin
  Create(AConfigName, ACreateFunc());
end;

constructor TThothConfig.Create(AConfigName: string; ALoader: IConfigLoader);
begin
  FConfigName := AConfigName;
  FLoader := ALoader;
  if Assigned(FLoader) then
    FLoader.SetConfig(Self);
end;

constructor TThothConfig.Create(AConfigName: string;
  ALoaderClass: TConfigLoaderClass);
begin
  Create(AConfigName, ALoaderClass.Create  as IConfigLoader);
end;

procedure TThothConfig.Load;
begin
  CheckLoader;

  FLoader.LoadConfig;
end;

procedure TThothConfig.Save;
begin
  CheckLoader;

  FLoader.SaveConfig;
end;

function TThothConfig.GetConfigName: string;
var
  LAttr: ConfigNameAttribute;
begin
  if FConfigName = '' then
  begin
    LAttr := TAttributeUtil.FindAttribute<ConfigNameAttribute>(Self);
    if Assigned(LAttr) then
      FConfigName := LAttr.ConfigName;
  end;

  Result := FConfigName;
end;

procedure TThothConfig.SetConfigName(const Value: string);
begin
  FConfigName := Value;
end;

class function TThothConfig.DefaultLoader: IConfigLoader;
begin
  Result := TIniFileConfigLoader.Create;
end;

destructor TThothConfig.Destroy;
begin
  if Assigned(FLoader) then
    FreeAndNil(TObject(FLoader));

  inherited;
end;

end.
