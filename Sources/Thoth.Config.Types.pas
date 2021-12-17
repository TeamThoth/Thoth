unit Thoth.Config.Types;

interface

uses
  System.Rtti;

type
  IConfig = interface
    function GetConfigName: string;
    procedure SetConfigName(const Value: string);

    property ConfigName: string read GetConfigName write SetConfigName;
  end;

  IConfigLoader = interface
  ['{F8551D93-54E6-4534-A13C-2F6E2941AFD8}']
    procedure LoadConfig;
    procedure SaveConfig;

    procedure SetConfig(const Value: IConfig);
//    property Config: IConfig write SetConfig;
  end;

  {$REGION 'Attribute'}
  ConfigNameAttribute = class(TCustomAttribute)
  private
    FConfigName: string;
  public
    constructor Create(const AConfigName: string);
    property ConfigName: string read FConfigName;
  end;

  TConfigItemAttribute = class(TCustomAttribute)
  private
    FSection: string;
    FDefault: TValue;
  public
    property Section: string read FSection;
    property &Default: TValue read FDefault;
  end;

  TCustomItemAttribute<T> = class(TConfigItemAttribute)
  public
    constructor Create(const ASection: string; ADefault: T); overload;
    constructor Create(ASection: string); overload;
  end;

  /// <summary>Integer 항목 지정</summary>
  IntegerItemAttribute = class(TCustomItemAttribute<Integer>)
  end;
  IntItemAttribute = IntegerItemAttribute;

  /// <summary>String 항목 지정</summary>
  StringItemAttribute = class(TCustomItemAttribute<String>)
  end;
  StrItemAttribute = StringItemAttribute;


  Int64ItemAttribute = class(TCustomItemAttribute<Int64>)
  end;

  FloatItemAttribute = class(TCustomItemAttribute<Double>)
  end;
  DblItemAttribute = FloatItemAttribute;

  DateTimeItemAttribute = class(TCustomItemAttribute<TDateTime>)
  end;
  DtmItemAttibute = DateTimeItemAttribute;

  BooleanItemAttribute = class(TCustomItemAttribute<Boolean>)
  end;
  BoolItemAttribute = BooleanItemAttribute;

  /// <summary>열거형(Enumeration) 항목 지정</summary>
  /// <code>
  ///    [EnumProp('Test', 'wsMaximized')]
  ///    property WindowState: TWindowState read FWindowState write FWindowState;
  /// </code>
  EnumerationItemAttribute = class(TCustomItemAttribute<string>)
  end;
  EnumItemAttribute = EnumerationItemAttribute;


  RecordItemAttribute = class(TCustomItemAttribute<string>)
  private
    FField: string;
    FFields: TArray<string>;
    FDefaults: TArray<string>;
  public
    constructor Create(ASection: string; AFields: string; ADefaults: string = ''); overload;

    property Field: string read FField;
    property Fields: TArray<string> read FFields;
    property Defaults: TArray<string> read FDefaults;
  end;
  RecItemAttribute = RecordItemAttribute;

  {$ENDREGION 'Attribute'}

implementation

uses
  Thoth.Utils,
  System.SysUtils;


{ ConfigNameAttribute }

constructor ConfigNameAttribute.Create(const AConfigName: string);
begin
  FConfigName := AConfigName;
end;

{ TConfigItemAttribute<T> }

constructor TCustomItemAttribute<T>.Create(ASection: string);
begin
  FSection := ASection;
  FDefault := TValue.From<T>(System.Default(T));
end;

constructor TCustomItemAttribute<T>.Create(const ASection: string; ADefault: T);
begin
  FSection := ASection;
  FDefault := TValue.From<T>(ADefault);
end;

{ RecordItemAttribute }

constructor RecordItemAttribute.Create(ASection, AFields, ADefaults: string);
begin
  FSection := ASection;
  FDefault := ADefaults;
  FField := AFields;

  FFields := FField.Split([',']);
  if not FDefault.IsEmpty then
    FDefaults := FDefault.AsString.Split([',']);

  TArrayUtil.Trim(FFields);
  TArrayUtil.Trim(FDefaults);
end;

end.
