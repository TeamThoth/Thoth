unit Thoth.Config.Loader;

interface

uses
  System.Rtti,
  System.SysUtils,
  Thoth.Classes,
  Thoth.Config.Types;

type
  TExtractConfigAttributeProc = TProc<string, string, TValue>;

  TCustomConfigLoader = class abstract(TInterfacedObject, IConfigLoader)
  private
    procedure SetConfig(const Value: IConfig);

    procedure CheckConfig;
  protected
    FConfig: IConfig;

    /// <summary>�ʱ�ȭ(Config ��ü ���� ��)</summary>
    procedure DoInitialize; virtual;

    /// <summary>������ �о� Config ��ü�� ���Ҵ�(������ ADefault)</summary>
    function DoReadValue(const ASection, AKey: string; ADefault: TValue): TValue; virtual; abstract;
    /// <summary>Config ��ü�� ���� �������� ����</summary>
    procedure DoWriteValue(const ASection, AKey: string; AValue: TValue); virtual; abstract;

    procedure DoBeforeLoadConfig; virtual;
    procedure DoAfterLoadConfig; virtual;
    procedure DoBeforeSaveConfig; virtual;
    procedure DoAfterSaveConfig; virtual;

    procedure DoResetConfig; virtual;

    /// <summary>Config ��ü�� Config Ư�� ���� �� ACallback���� ����</summary>
    ///  <param name="ACallback">TProc<SectionName, KeyName></param>
    procedure ExtractConfigAttribute(ACallback: TExtractConfigAttributeProc);
  public
    procedure LoadConfig;
    procedure SaveConfig;

    procedure ResetConfig;

    property Config: IConfig read FConfig write SetConfig;
  end;

implementation

uses
  System.TypInfo,
  System.StrUtils,

  Thoth.ResourceStrings,
  Thoth.Config,
  Thoth.Utils;

{ TCustomConfigLoader }

procedure TCustomConfigLoader.CheckConfig;
begin
  if not Assigned(FConfig) then
    raise Exception.CreateFmt(SNotAssigned, [ClassName, 'config object']);
end;

procedure TCustomConfigLoader.SetConfig(const Value: IConfig);
begin
  FConfig := Value;

  DoInitialize;
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

procedure TCustomConfigLoader.DoResetConfig;
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

      // [������] �⺻ ���� ���ڿ��� ���� ��, Ÿ�� ��ȯ �� �� ���� ��
      if (LProp.PropertyType.Handle.Kind = tkEnumeration) and (LProp.PropertyType.Handle <> TypeInfo(Boolean)) then
      begin
        var EnumTypeInfo: PTypeInfo := LProp.PropertyType.Handle;
        if TRttiUtil.TryStrToValue(EnumTypeInfo, LAttr.Default.AsString, LDefaultValue) then
          LValue := DoReadValue(LAttr.Section, LKeyName, LDefaultValue);
      end
      // [����ü] ����ʵ� �� �⺻ ���� ��ǥ�������� ���� ��(ConfigTargetFieldsAttribute)
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
          var FieldName: string := LField.Name;
          if (Idx > -1) and (Length(LTargetAttr.Defaults) > Idx) then
            DefStrVal := LTargetAttr.Defaults[Idx];
          if (Idx > -1) and (Length(LTargetAttr.KeyNames) > Idx) then
            FieldName := LTargetAttr.KeyNames[Idx];

          var KeyFieldName: string := IfThen(LKeyName.IsEmpty, '', LKeyName + '.') + FieldName;
          if TRttiUtil.TryStrToValue(LField.FieldType.Handle, DefStrVal, LDefaultValue) then
          begin
            var FieldValue: TValue := DoReadValue(LAttr.Section, KeyFieldName, LDefaultValue);
            LField.SetValue(LValue.GetReferenceToRawData, FieldValue);
          end;
        end;
      end
      else
      begin
        LDefaultValue := LAttr.Default;
        if LDefaultValue.IsEmpty then
          TValue.Make(nil, LProp.PropertyType.Handle, LDefaultValue);

        // Ư���� �⺻ ���� ���ڿ��� ���� �� DefaultValue Ÿ�� ����
        if (LDefaultValue.TypeInfo <> LProp.PropertyType.Handle) and (LDefaultValue.TypeInfo = TypeInfo(string)) then
          TRttiUtil.TryStrToValue(LProp.PropertyType.Handle, LDefaultValue.AsString, LDefaultValue);

        LValue := DoReadValue(LAttr.Section, LKeyName, LDefaultValue);
      end;

      if LValue.IsEmpty then
        raise Exception.CreateFmt(STypeNotSupported, [ClassName, LProp.PropertyType.Name]);

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
        if not Assigned(LTargetAttr) then // Ÿ���ʵ� �������� ������ �������� ����
          Continue;
        for LField in LProp.PropertyType.GetFields do
        begin
          // ������ �ʵ常 ����
          var Idx := TArrayUtil.IndexOf<string>(LTargetAttr.Fields, LField.Name);
          if Idx = -1 then
            Continue;

          var FieldName: string := LField.Name;
          if (Idx > -1) and (Length(LTargetAttr.KeyNames) > Idx) then
            FieldName := LTargetAttr.KeyNames[Idx];

          var FieldKeyName: string := IfThen(LKeyName.IsEmpty, '', LKeyName + '.') + FieldName;

          DoWriteValue(
            LAttr.Section,
            FieldKeyName,
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

procedure TCustomConfigLoader.ExtractConfigAttribute(
  ACallback: TExtractConfigAttributeProc);
var
  LCtx: TRttiContext;
  LType: TRttiType;
  LProp: TRttiProperty;
  LField: TRttiField;

  LAttr: ConfigItemAttribute;
  LDefaultValue: TValue;
  LTargetAttr: ConfigTargetFieldsAttribute;
  LValue: TValue;
  LKeyName: string;
begin
  CheckConfig;

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

      // [������] �⺻ ���� ���ڿ��� ���� ��, Ÿ�� ��ȯ �� �� ���� ��
      if (LProp.PropertyType.Handle.Kind = tkEnumeration) and (LProp.PropertyType.Handle <> TypeInfo(Boolean)) then
      begin
        var EnumTypeInfo: PTypeInfo := LProp.PropertyType.Handle;
        if TRttiUtil.TryStrToValue(EnumTypeInfo, LAttr.Default.AsString, LDefaultValue) then
          LValue := DoReadValue(LAttr.Section, LKeyName, LDefaultValue);
      end
      // [����ü] ����ʵ� �� �⺻ ���� ��ǥ�������� ���� ��(ConfigTargetFieldsAttribute)
      else if LProp.PropertyType.Handle.Kind = tkRecord then
      begin
        LValue := LProp.GetValue(FConfig);
        LTargetAttr := TAttributeUtil.FindAttribute<ConfigTargetFieldsAttribute>(LProp.GetAttributes);
        if not Assigned(LTargetAttr) then
          Continue;

        for LField in LProp.PropertyType.GetFields do
        begin
          var Idx := TArrayUtil.IndexOf<string>(LTargetAttr.Fields, LField.Name);
          if Idx = -1 then
            Continue;

          var DefStrVal: string := '';
          var FieldName: string := LField.Name;
          if Length(LTargetAttr.Defaults) > Idx then
            DefStrVal := LTargetAttr.Defaults[Idx];
          if Length(LTargetAttr.KeyNames) > Idx then
            FieldName := LTargetAttr.KeyNames[Idx];

          var FieldKeyName: string := IfThen(LKeyName.IsEmpty, '', LKeyName + '.') + FieldName;
          if TRttiUtil.TryStrToValue(LField.FieldType.Handle, DefStrVal, LDefaultValue) then
            ACallback(LAttr.Section, FieldKeyName, LDefaultValue);
        end;

        Continue
      end
      else
      begin
        LDefaultValue := LAttr.Default;
        if LDefaultValue.IsEmpty then
          TValue.Make(nil, LProp.PropertyType.Handle, LDefaultValue);

        // Ư���� �⺻ ���� ���ڿ��� ���� �� DefaultValue Ÿ�� ����
        if (LDefaultValue.TypeInfo <> LProp.PropertyType.Handle) and (LDefaultValue.TypeInfo = TypeInfo(string)) then
          TRttiUtil.TryStrToValue(LProp.PropertyType.Handle, LDefaultValue.AsString, LDefaultValue);
      end;

      ACallback(LAttr.Section, LKeyName, LDefaultValue);
    end;
  finally
    LCtx.Free;
  end;
end;

procedure TCustomConfigLoader.ResetConfig;
begin
  DoResetConfig;
end;

end.
