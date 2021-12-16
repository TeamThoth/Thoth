unit Thoth.Config.Loader;

interface

uses
  System.Rtti,
  System.SysUtils,
  Thoth.Config.Types;

type
  TCustomConfigLoader = class(TInterfacedObject, IConfigLoader)
  private
    procedure SetConfig(const Value: IConfig);
  protected
    FConfig: IConfig;

    function ReadValue(const ASection, AIdent: string; ADefault: TValue): TValue; virtual; abstract;
    procedure WriteValue(const ASection, AIdent: string; AValue: TValue); virtual; abstract;
  public
    procedure LoadConfig; virtual; abstract;
    procedure SaveConfig; virtual; abstract;

    property Config: IConfig read FConfig write SetConfig;
  end;

  TConfigLoaderClass = class of TCustomConfigLoader;
  TConfigLoaderCreateFunc = TFunc<IConfigLoader>;

implementation

{ TCustomConfigLoader }

procedure TCustomConfigLoader.SetConfig(const Value: IConfig);
begin
  FConfig := Value;
end;

end.
