unit Thoth.Config.Attr;

interface

uses
  System.Rtti;

type
  ConfigNameAttribute = class(TCustomAttribute)
  private
    FConfigName: string;
  public
    constructor Create(const AConfigName: string);
    property ConfigName: string read FConfigName;
  end;

  TConfigItemAttribute<T> = class(TCustomAttribute)
  private
    FSection: string;
    FDefault: TValue;
  public
    property Section: string read FSection;
    property &Default: TValue read FDefault;

    constructor Create(const ASection: string; ADefault: T); overload;
    constructor Create(ASection: string); overload;
  end;

  IntegerItemAttribute = class(TConfigItemAttribute<Integer>)
  end;
  IntItemAttribute = IntegerItemAttribute;


implementation

{ ConfigNameAttribute }

constructor ConfigNameAttribute.Create(const AConfigName: string);
begin
  FConfigName := AConfigName;
end;

{ TConfigItemAttribute<T> }

constructor TConfigItemAttribute<T>.Create(ASection: string);
begin
  FSection := ASection;
  FDefault := TValue.From<T>(System.Default(T));
end;

constructor TConfigItemAttribute<T>.Create(const ASection: string; ADefault: T);
begin
  FSection := ASection;
  FDefault := TValue.From<T>(ADefault);
end;

end.
