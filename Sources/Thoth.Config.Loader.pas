unit Thoth.Config.Loader;

interface

uses
  System.Rtti,
  Thoth.Classes,
  Thoth.Config.Types;

type
  TCustomConfigLoader = class(TNoRefCountObject, IConfigLoader)
  protected
    FConfig: IConfig;

    procedure CheckConfig;

    procedure SetConfig(const Value: IConfig); virtual;

    function DoReadValue(const ASection, AKey: string; ADefault: TValue): TValue; virtual; abstract;
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

    destructor Destroy; override;
  end;

implementation

uses
  System.TypInfo,
  System.SysUtils,

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

procedure TCustomConfigLoader.ClearData;
begin
  DoClearData;
end;

destructor TCustomConfigLoader.Destroy;
begin

  inherited;
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

  LAttr: TConfigItemAttribute;
  LRecAttr: RecItemAttribute;
  LValue: TValue;
  LKeyName: string;
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

      LAttr := TAttributeUtil.FindAttribute<TConfigItemAttribute>(LProp.GetAttributes);
      if not Assigned(LAttr) then
        Continue;

      var KeyAttr := TAttributeUtil.FindAttribute<KeyNameAttribute>(LProp.GetAttributes);
      if Assigned(KeyAttr) then
        LKeyName := KeyAttr.Name
      else
        LKeyName := LProp.Name;

      LValue := TValue.Empty;

      if LAttr is EnumItemAttribute{default = string} then
      // [열거형] 기본값 = 문자열
        // 문자열기본값을 열거형타입으로 변환 후 읽기
      begin
        var DefaultValue: TValue;
        if ConvertStrToValue(LProp.PropertyType.Handle, LAttr.Default.AsString, DefaultValue) then
          LValue := DoReadValue(LAttr.Section, LKeyName, DefaultValue);
      end
      else if LAttr is RecItemAttribute{default = 'string,string,..'} then
      // [구조체] 기본값 = 문자열(쉼표로 복수 지정)
        // 구조체 필드에 설정값 로드
      begin
        LValue := LProp.GetValue(FConfig);
        LRecAttr := LAttr as RecItemAttribute;

        for LField in LProp.PropertyType.GetFields do
        begin
          { TODO : 구조체 불러오는 부분 다시 검토해 볼것 }
          var Idx := TArrayUtil.IndexOf<string>(LRecAttr.Fields, LField.Name);
//          if Idx = -1 then
//            Continue;

          var DefStrVal: string := '';
          if (Idx > -1) and (Length(LRecAttr.Defaults) > Idx) then
            DefStrVal := LRecAttr.Defaults[Idx];

          var DefaultValue: TValue;
          if ConvertStrToValue(LField.FieldType.Handle, DefStrVal, DefaultValue) then
          begin
            var FieldValue: TValue := DoReadValue(LAttr.Section, LKeyName + '.' + LField.Name, DefaultValue);
            LField.SetValue(LValue.GetReferenceToRawData, FieldValue);
          end;
        end;
      end
      else
        LValue := DoReadValue(LAttr.Section, LKeyName, LAttr.Default);

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

  LAttr: TConfigItemAttribute;
  LRecAttr: RecItemAttribute;
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

      LAttr := TAttributeUtil.FindAttribute<TConfigItemAttribute>(LProp.GetAttributes);
      if not Assigned(LAttr) then
        Continue;

      var KeyAttr := TAttributeUtil.FindAttribute<KeyNameAttribute>(LProp.GetAttributes);
      if Assigned(KeyAttr) then
        LKeyName := KeyAttr.Name
      else
        LKeyName := LProp.Name;

      if LAttr is RecItemAttribute{default = 'string,string,..'} then
      begin
        LValue := LProp.GetValue(TObject(FConfig));
        LRecAttr := LAttr as RecItemAttribute;
        for LField in LProp.PropertyType.GetFields do
        begin
          // [구조체] 지정한 필드만 저장
          var Idx := TArrayUtil.IndexOf<string>(LRecAttr.Fields, LField.Name);
          if Idx = -1 then
            Continue;

          DoWriteValue(
            LAttr.Section,
            LKeyName + '.' + LField.Name,
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
end;

end.
