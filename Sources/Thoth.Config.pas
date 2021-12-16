unit Thoth.Config;

interface

uses
  Thoth.Config.Types,
  Thoth.Config.Loader;

type
  TThothConfig = class(TInterfacedObject, IConfig)
  private
    FConfigName: string;
    FLoader: IConfigLoader;
    function GetConfigName: string;
    procedure SetConfigName(const Value: string);
  public
    constructor Create(AConfigName: string = ''); overload;

    constructor Create(ALoader: IConfigLoader); overload;
    constructor Create(AConfigName: string; ALoader: IConfigLoader); overload;

    constructor Create(ALoaderClass: TConfigLoaderClass); overload;
    constructor Create(AConfigName: string; ALoaderClass: TConfigLoaderClass); overload;

    constructor Create(ACreateFunc: TConfigLoaderCreateFunc); overload;
    constructor Create(AConfigName: string; ACreateFunc: TConfigLoaderCreateFunc); overload;

    property ConfigName: string read GetConfigName write SetConfigName;
  end;

implementation

uses
  Thoth.Utils,
  Thoth.Config.Attr;

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

constructor TThothConfig.Create(AConfigName: string;
  ACreateFunc: TConfigLoaderCreateFunc);
begin
  Create(AConfigName, ACreateFunc());
end;

constructor TThothConfig.Create(AConfigName: string; ALoader: IConfigLoader);
begin
  FConfigName := AConfigName;
  FLoader := ALoader;
end;

constructor TThothConfig.Create(AConfigName: string;
  ALoaderClass: TConfigLoaderClass);
begin
  Create(AConfigName, ALoaderClass.Create  as IConfigLoader);
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

end.
