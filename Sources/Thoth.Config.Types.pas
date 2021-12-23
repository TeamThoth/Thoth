unit Thoth.Config.Types;

interface

uses
  System.SysUtils,
  System.Rtti;

type
  IConfig = interface
  ['{931DD9FB-8260-40B3-8A60-B13886E54CD0}']
    function GetConfigName: string;
    procedure SetConfigName(const Value: string);

    property ConfigName: string read GetConfigName write SetConfigName;
  end;

  IConfigLoader = interface
  ['{F8551D93-54E6-4534-A13C-2F6E2941AFD8}']
    procedure LoadConfig;
    procedure SaveConfig;
    procedure ClearData;

    procedure SetConfig(const Value: IConfig);
//    property Config: IConfig write SetConfig;
  end;

  TConfigLoaderCreateFunc = TFunc<IConfigLoader>;

{$REGION 'Attribute'}
  /// <summary>���� �̸� ����(Ȱ��: ini ���ϸ�, DB���̺�� ��)</summary>
  ConfigNameAttribute = class(TCustomAttribute)
  private
    FConfigName: string;
  public
    constructor Create(const AConfigName: string);
    property ConfigName: string read FConfigName;
  end;

  /// <summary>Ű �̸� ����(�⺻: property �̸�) </summary>
  ConfigKeyNameAttribute = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(const AName: string);
    property Name: string read FName;
  end;

  /// <summary>���� �׸� ����(Params: ī�װ�, �⺻��='')</summary>
  ConfigItemAttribute = class(TCustomAttribute)
  private
    FSection: string;
    FDefault: TValue;
  public
    property Section: string read FSection;
    property &Default: TValue read FDefault;

    constructor Create(ASection: string); overload;
    constructor Create(ASection: string; ADefault: string); overload;
    constructor Create(ASection: string; ADefault: Integer); overload;
    constructor Create(ASection: string; ADefault: Boolean); overload;
    constructor Create(ASection: string; ADefault: Double); overload;
  end;

  /// <summary>����ü �׸� ����(Params: 'Field1,Field2', 'Val1, Val2')</summary>
  ConfigTargetFieldsAttribute = class(TCustomAttribute)
  private
    FDefault: string;
    FFields: TArray<string>;
    FDefaults: TArray<string>;
  public
    /// <param name="ATargetFields">Storage target field of the record.(Separated by commas.)</param>
    /// <param name="ADefaults">Default value of the record.(Separated by commas.)</param>
    constructor Create(ATargetFields: string; ADefaults: string = ''); overload;

    property Fields: TArray<string> read FFields;
    property Defaults: TArray<string> read FDefaults;
  end;
{$ENDREGION 'Attribute'}

implementation

uses
  Thoth.Utils;


{ ConfigNameAttribute }

constructor ConfigNameAttribute.Create(const AConfigName: string);
begin
  FConfigName := AConfigName;
end;

{ ConfigKeyNameAttribute }

constructor ConfigKeyNameAttribute.Create(const AName: string);
begin
  FName := AName;
end;

{ ConfigItemAttribute }

constructor ConfigItemAttribute.Create(ASection: string);
begin
  FSection := ASection;
end;

constructor ConfigItemAttribute.Create(ASection: string; ADefault: string);
begin
  FSection := ASection;
  FDefault := TValue.From<string>(ADefault);
end;

constructor ConfigItemAttribute.Create(ASection: string; ADefault: Integer);
begin
  FSection := ASection;
  FDefault := TValue.From<Integer>(ADefault);
end;

constructor ConfigItemAttribute.Create(ASection: string; ADefault: Boolean);
begin
  FSection := ASection;
  FDefault := TValue.From<Boolean>(ADefault);
end;

constructor ConfigItemAttribute.Create(ASection: string; ADefault: Double);
begin
  FSection := ASection;
  FDefault := TValue.From<Double>(ADefault);
end;

{ ConfigTargetFieldsAttribute }

constructor ConfigTargetFieldsAttribute.Create(ATargetFields, ADefaults: string);
begin
//  FSection := ASection;
  FDefault := ADefaults;

  FFields := ATargetFields.Split([',']);
  if not FDefault.IsEmpty then
    FDefaults := FDefault.Split([',']);

  TArrayUtil.Trim(FFields);
  TArrayUtil.Trim(FDefaults);
end;

end.
