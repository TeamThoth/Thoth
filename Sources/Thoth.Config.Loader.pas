unit Thoth.Config.Loader;

interface

uses
  System.Rtti,
  Thoth.Classes,
  Thoth.Config.Types;

type
  TCustomConfigLoader = class(TNoRefCountObject, IConfigLoader)
  private
    procedure SetConfig(const Value: IConfig);

    procedure CheckConfig;
  protected
    FConfig: IConfig;

    /// <summary>초기화(Config 객체 설정 됨)</summary>
    procedure DoInitialize; virtual;

    /// <summary>설정값 읽어 Config 객체에 값할당(없으면 ADefault)</summary>
    function DoReadValue(const ASection, AKey: string; ADefault: TValue): TValue; virtual; abstract;
    /// <summary>Config 객체의 값을 설정값에 쓰기</summary>
    procedure DoWriteValue(const ASection, AKey: string; AValue: TValue); virtual; abstract;

    procedure DoBeforeLoadConfig; virtual;
    procedure DoAfterLoadConfig; virtual;
    procedure DoBeforeSaveConfig; virtual;
    procedure DoAfterSaveConfig; virtual;

    procedure DoClearData; virtual;
  public
    procedure LoadConfig;
    procedure SaveConfig;

    procedure ClearData;

    property Config: IConfig read FConfig write SetConfig;
  end;

implementation

uses
  System.TypInfo,
  System.SysUtils,
  System.StrUtils,

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
        if ATypeInfo = TypeInfo(TDateTime) then
          Value := TValue.From<TDateTime>(StrToDateTimeDef(AStr, 0))
        else
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

procedure TCustomConfigLoader.ClearData;
begin
  DoClearData;
end;

procedure TCustomConfigLoader.DoInitialize;
begin
end;

procedure TCustomConfigLoader.DoBeforeLoadConfig;
begin
end;

procedure TCustomConfigLoader.DoAfterLoadConfig;
begin
end;

procedure TCustomConfigLoader.DoBeforeSaveConfig;
begin
end;

procedure TCustomConfigLoader.DoAfterSaveConfig;
begin
end;

procedure TCustomConfigLoader.DoClearData;
begin
end;

procedure TCustomConfigLoader.LoadConfig;
var
  LCtx: TRttiContext;
  LType: TRttiType;
  LProp: TRttiProperty;
  LField: TRttiField;

  LAttr: ConfigItemAttribute;
  LKeyName: string;
  LValue: TValue;
  LDefaultValue: TValue;
  LTargetAttr: ConfigTargetFieldsAttribute;
begin
  CheckConfig;

  DoBeforeLoadConfig;
  LCtx := TRttiContext.Create;
  try
    LType := LCtx.GetType(TObject(FConfig).ClassType);
    for LProp in LType.GetProperties do
    begin
      if not LProp.IsReadable then
        Continue;

      LAttr := TAttributeUtil.FindAttribute<ConfigItemAttribute>(LProp.GetAttributes);
      if not Assigned(LAttr) then
        Continue;

      var KeyAttr := TAttributeUtil.FindAttribute<ConfigKeyNameAttribute>(LProp.GetAttributes);
      if Assigned(KeyAttr) then
        LKeyName := KeyAttr.Name
      else
        LKeyName := LProp.Name;

      LValue := TValue.Empty;

      // [열거형] 기본 값이 문자열로 지정 됨, 타입 변환 후 값 읽을 것
      if (LProp.PropertyType.Handle.Kind = tkEnumeration) and (LProp.PropertyType.Handle <> TypeInfo(Boolean)) then
      begin
        if ConvertStrToValue(LProp.PropertyType.Handle, LAttr.Default.AsString, LDefaultValue) then
          LValue := DoReadValue(LAttr.Section, LKeyName, LDefaultValue);
      end
      // [구조체] 대상필드 및 기본 값을 쉼표구분으로 지정 됨(ConfigTargetFieldsAttribute)
      else if LProp.PropertyType.Handle.Kind = tkRecord then
      begin
        LValue := LProp.GetValue(FConfig);
        LTargetAttr := TAttributeUtil.FindAttribute<ConfigTargetFieldsAttribute>(LProp.GetAttributes);
        if not Assigned(LTargetAttr) then
          Continue;

        for LField in LProp.PropertyType.GetFields do
        begin
          var Idx := TArrayUtil.IndexOf<string>(LTargetAttr.Fields, LField.Name);

          var DefStrVal: string := '';
          if (Idx > -1) and (Length(LTargetAttr.Defaults) > Idx) then
            DefStrVal := LTargetAttr.Defaults[Idx];

          var KeyFieldName: string := IfThen(LKeyName.IsEmpty, '', LKeyName + '.') + LField.Name;
          if ConvertStrToValue(LField.FieldType.Handle, DefStrVal, LDefaultValue) then
          begin
            var FieldValue: TValue := DoReadValue(LAttr.Section, KeyFieldName~, LDefaultValue);
            LField.SetValue(LValue.GetReferenceToRawData, FieldValue);
          end;
        end;
      end
      else
      begin
        LDefaultValue := LAttr.Default;
        if LDefaultValue.IsEmpty then
          TValue.Make(nil, LProp.PropertyType.Handle, LDefaultValue);

        // 특성의 기본 값이 문자열로 지정 시 DefaultValue 타입 변경
        if (LDefaultValue.TypeInfo <> LProp.PropertyType.Handle) and (LDefaultValue.TypeInfo = TypeInfo(string)) then
          ConvertStrToValue(LProp.PropertyType.Handle, LDefaultValue.AsString, LDefaultValue);

        LValue := DoReadValue(LAttr.Section, LKeyName, LDefaultValue);
      end;

      if LValue.IsEmpty then
        raise Exception.CreateFmt(STypeNotSupported, [LProp.PropertyType.Name]);

      LProp.SetValue(TObject(FConfig), LValue);
    end;
  finally
    LCtx.Free;

    DoAfterLoadConfig;
  end;
end;

procedure TCustomConfigLoader.SaveConfig;
var
  LCtx: TRttiContext;
  LType: TRttiType;
  LProp: TRttiProperty;
  LField: TRttiField;

  LAttr: ConfigItemAttribute;
  LTargetAttr: ConfigTargetFieldsAttribute;
  LValue: TValue;
  LKeyName: string;
begin
  CheckConfig;

  DoBeforeSaveConfig;
  LCtx := TRttiContext.Create;
  try
    LType := LCtx.GetType(TObject(FConfig).ClassType);
    for LProp in LType.GetProperties do
    begin
      if not LProp.IsReadable then
        Continue;

      LAttr := TAttributeUtil.FindAttribute<ConfigItemAttribute>(LProp.GetAttributes);
      if not Assigned(LAttr) then
        Continue;

      var KeyAttr := TAttributeUtil.FindAttribute<ConfigKeyNameAttribute>(LProp.GetAttributes);
      if Assigned(KeyAttr) then
        LKeyName := KeyAttr.Name
      else
        LKeyName := LProp.Name;

      if LProp.PropertyType.Handle.Kind = tkRecord then
      begin
        LValue := LProp.GetValue(TObject(FConfig));
        LTargetAttr := TAttributeUtil.FindAttribute<ConfigTargetFieldsAttribute>(LProp.GetAttributes);
        if not Assigned(LTargetAttr) then // 타겟필드 지정하지 않으면 저장하지 않음
          Continue;
        for LField in LProp.PropertyType.GetFields do
        begin
          // 지정한 필드만 저장
          var Idx := TArrayUtil.IndexOf<string>(LTargetAttr.Fields, LField.Name);
          if Idx = -1 then
            Continue;

          var KeyFieldName: string := IfThen(LKeyName.IsEmpty, '', LKeyName + '.') + LField.Name;

          DoWriteValue(
            LAttr.Section,
            KeyFieldName,
            LField.GetValue(LValue.GetReferenceToRawData)
          );
        end;
      end
      else
        DoWriteValue(LAttr.Section, LKeyName, LProp.GetValue(TObject(FConfig)));
    end;
  finally
    LCtx.Free;

    DoAfterSaveConfig;
  end;
end;

procedure TCustomConfigLoader.SetConfig(const Value: IConfig);
begin
  FConfig := Value;

  DoInitialize;
end;

end.
