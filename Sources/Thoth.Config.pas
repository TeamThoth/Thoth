unit Thoth.Config;

interface

uses
  Thoth.Classes,
  Thoth.Config.Types;

type
  TThothConfig = class abstract(TNoRefCountObject, IConfig)
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

    constructor Create(ACreateFunc: TConfigLoaderCreateFunc); overload;
    constructor Create(AConfigName: string; ACreateFunc: TConfigLoaderCreateFunc); overload;
    destructor Destroy; override;

    procedure Load;
    procedure Save;

    procedure Reset;

    property ConfigName: string read GetConfigName write SetConfigName;
  end;

implementation

uses
  System.SysUtils,
  Thoth.ResourceStrings,
  Thoth.Utils
;

{ TCustomConfig }

constructor TThothConfig.Create(AConfigName: string);
begin
  FConfigName := AConfigName;
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

  CheckLoader;
  FLoader.SetConfig(Self);
  FLoader.LoadConfig;
end;

procedure TThothConfig.CheckLoader;
begin
  if not Assigned(FLoader) then
    raise Exception.CreateFmt(SNotAssigned, [ClassName, 'loader']);
end;

procedure TThothConfig.Reset;
begin
  CheckLoader;

  FLoader.ResetConfig;
  FLoader.LoadConfig;
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

destructor TThothConfig.Destroy;
begin

  inherited;
end;

end.
