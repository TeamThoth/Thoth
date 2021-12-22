unit Thoth.Config.Types;

interface

uses
  System.SysUtils,
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
    procedure ClearData;

    procedure SetConfig(const Value: IConfig);
//    property Config: IConfig write SetConfig;
  end;

  TConfigLoaderCreateFunc = TFunc<IConfigLoader>;

  {$REGION 'Attribute'}
  ConfigNameAttribute = class(TCustomAttribute)
  private
    FConfigName: string;
  public
    constructor Create(const AConfigName: string);
    property ConfigName: string read FConfigName;
  end;

  KeyNameAttribute = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(const AName: string);
    property Name: string read FName;
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

  IntegerItemAttribute = class(TCustomItemAttribute<Integer>)
  end;
  IntItemAttribute = IntegerItemAttribute;

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

  /// <summary>열거형(Enumeration) 항목 지정
  ///  [EnumItem('Test', 'wsMaximized')]
  /// </summary>
  EnumerationItemAttribute = class(TCustomItemAttribute<string>)
  end;
  /// <summary>열거형(Enumeration) 항목 지정</summary>
  EnumItemAttribute = EnumerationItemAttribute;


  /// <summary>구조체 항목 지정
  ///   [RecItem('section', 'Field1,Field2', 'Val1, Val2')]
  /// </summary>
  RecordItemAttribute = class(TCustomItemAttribute<string>)
  private
    FFields: TArray<string>;
    FDefaults: TArray<string>;
  public
    /// <param name="ASection">Section of config data</param>
    /// <param name="ATargetFields">Storage target field of the record.(Separated by commas.)</param>
    /// <param name="ADefaults">Default value of the record.(Separated by commas.)</param>
    constructor Create(ASection: string; ATargetFields: string; ADefaults: string = ''); overload;

    property Fields: TArray<string> read FFields;
    property Defaults: TArray<string> read FDefaults;
  end;
  /// <summary>구조체 항목 지정</summary>
  RecItemAttribute = RecordItemAttribute;

  {$ENDREGION 'Attribute'}

implementation

uses
  Thoth.Utils;


{ ConfigNameAttribute }

constructor ConfigNameAttribute.Create(const AConfigName: string);
begin
  FConfigName := AConfigName;
end;

{ KeyNameAttribute }

constructor KeyNameAttribute.Create(const AName: string);
begin
  FName := AName;
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

constructor RecordItemAttribute.Create(ASection, ATargetFields, ADefaults: string);
begin
  FSection := ASection;
  FDefault := ADefaults;

  FFields := ATargetFields.Split([',']);
  if not FDefault.IsEmpty then
    FDefaults := FDefault.AsString.Split([',']);

  TArrayUtil.Trim(FFields);
  TArrayUtil.Trim(FDefaults);
end;

end.
