unit Thoth.Config.Loader;

interface

uses
  System.Rtti,
  System.SysUtils,
  Thoth.Classes,
  Thoth.Config.Types;

type
  TCustomConfigLoader = class(TNoRefCountObject, IConfigLoader)
  private
    procedure SetConfig(const Value: IConfig);
  protected
    FConfig: IConfig;

    procedure CheckConfig;

    function ReadValue(const ASection, AIdent: string; ADefault: TValue): TValue; virtual; abstract;
    procedure WriteValue(const ASection, AIdent: string; AValue: TValue); virtual; abstract;

    procedure DoLoadConfigBefore; virtual;
    procedure DoSaveConfigAfter; virtual;
  public
    procedure LoadConfig;
    procedure SaveConfig;

    property Config: IConfig read FConfig write SetConfig;

    destructor Destroy; override;
  end;

  TConfigLoaderClass = class of TCustomConfigLoader;
  TConfigLoaderCreateFunc = TFunc<IConfigLoader>;

implementation

uses
  System.TypInfo,

  Thoth.ResourceStrings,
  Thoth.Config,
  Thoth.Utils;

function ConvertStrToValue(ATypeInfo: PTypeInfo; AStr: string; var Value: TValue): Boolean;
begin
  Value := TValue.Empty;
  try
    case ATypeInfo.Kind of
      tkInteger:
        Value := TValue.From<Integer>(StrToIntDef(AStr, 0));
      tkInt64:
        Value := TValue.From<Int64>(StrToInt64Def(AStr, 0));

      tkFloat:
        Value := TValue.From<Double>(StrToFloatDef(AStr, 0));

      tkString, tkLString, tkWString, tkUString:
        Value := TValue.From<string>(AStr);

      tkEnumeration:
        begin
          var EnumValue: Integer;
          if AStr = '' then
            EnumValue := GetTypeData(ATypeInfo)^.MinValue
          else
            EnumValue := GetEnumValue(ATypeInfo, AStr);
          Value := TValue.FromOrdinal(ATypeInfo, EnumValue);
        end;

      // not support
      tkUnknown: ;
      tkSet: ;
      tkClass: ;
      tkMethod: ;
      tkVariant: ;
      tkArray: ;
      tkRecord: ;
      tkInterface: ;
      tkDynArray: ;
      tkClassRef: ;
      tkPointer: ;
      tkProcedure: ;
      tkMRecord: ;
    end;
  except
    Value := TValue.Empty;
  end;

  Result := not Value.IsEmpty;
end;

{ TCustomConfigLoader }

procedure TCustomConfigLoader.CheckConfig;
begin
  if not Assigned(FConfig) then
    raise Exception.CreateFmt(SNotAssigned, ['config object']);
end;

destructor TCustomConfigLoader.Destroy;
begin

  inherited;
end;

procedure TCustomConfigLoader.DoLoadConfigBefore;
begin
end;

procedure TCustomConfigLoader.DoSaveConfigAfter;
begin
end;

procedure TCustomConfigLoader.LoadConfig;
var
  LConfig: TThothConfig;

  LCtx: TRttiContext;
  LType: TRttiType;
  LProp: TRttiProperty;
  LField: TRttiField;

  LAttr: TConfigItemAttribute;
  LRecAttr: RecItemAttribute;
  LValue: TValue;
begin
  CheckConfig;

  DoLoadConfigBefore;

  LConfig := TThothConfig(FConfig);

  LCtx := TRttiContext.Create;
  try
    LType := LCtx.GetType(LConfig.ClassType);
    for LProp in LType.GetProperties do
    begin
      if not LProp.IsReadable then
        Continue;

      LAttr := TAttributeUtil.FindAttribute<TConfigItemAttribute>(LProp.GetAttributes);
      if not Assigned(LAttr) then
        Continue;

      LValue := TValue.Empty;

      if LAttr is EnumItemAttribute{default = string} then
      // [열거형] 기본값 = 문자열
        // 문자열기본값을 열거형타입으로 변환 후 읽기
      begin
        var DefaultValue: TValue;
        if ConvertStrToValue(LProp.PropertyType.Handle, LAttr.Default.AsString, DefaultValue) then
          LValue := ReadValue(LAttr.Section, LProp.Name, DefaultValue);
      end
      else if LAttr is RecItemAttribute{default = 'string,string,..'} then
      // [구조체] 기본값 = 문자열(쉼표로 복수 지정)
        // 구조체 필드에 설정값 로드
      begin
        LValue := LProp.GetValue(FConfig);
        LRecAttr := LAttr as RecItemAttribute;

        for LField in LProp.PropertyType.GetFields do
        begin
          var Idx := TArrayUtil.IndexOf<string>(LRecAttr.Fields, LField.Name);
          if Idx = -1 then
            Continue;

          var DefStrVal: string := '';
          if Length(LRecAttr.Defaults) > Idx then
            DefStrVal := LRecAttr.Defaults[Idx];

          var DefaultValue: TValue;
          if ConvertStrToValue(LField.FieldType.Handle, DefStrVal, DefaultValue) then
          begin
            var FieldValue: TValue := ReadValue(LAttr.Section, LProp.Name + '.' + LField.Name, DefaultValue);
            LField.SetValue(LValue.GetReferenceToRawData, FieldValue);
          end;
        end;
      end
      else
        LValue := ReadValue(LAttr.Section, LProp.Name, LAttr.Default);

      if LValue.IsEmpty then
        raise Exception.CreateFmt(STypeNotSupported, [LProp.PropertyType.Name]);

      LProp.SetValue(LConfig, LValue);
    end;
  finally
    LCtx.Free;
  end;
end;

procedure TCustomConfigLoader.SaveConfig;
begin
  CheckConfig;

end;

procedure TCustomConfigLoader.SetConfig(const Value: IConfig);
begin
  FConfig := Value;
end;

end.
