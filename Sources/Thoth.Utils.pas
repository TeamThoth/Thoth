unit Thoth.Utils;

interface

uses
  System.Rtti, System.TypInfo,
  System.SysUtils,
  System.Generics.Defaults;

type
  TAttributeUtil = class
    class function FindAttribute<T: TCustomAttribute>(const Attrs: TArray<TCustomAttribute>): T; overload;
    class function FindAttribute<T: TCustomAttribute>(const AObject: TObject): T; overload;
    class function GetAttributeCount<T: TCustomAttribute>(const AType: TRttiType): Integer;
  end;

  TGenericsUtil = class
    class function AsString(const Value): string;
    class function AsInteger(const Value): Integer;
  end;

  TArrayUtil = class
    class function IndexOf<T>(const Items: TArray<T>; Value:T): Integer;
    class function Contains<T>(const Items: TArray<T>; Value: T): Boolean;

    class function Add<T>(var Items: TArray<T>; Value: T): Integer;

    class procedure Trim(var Items: TArray<string>);

    class function Concat<T>(const values: array of TArray<T>): TArray<T>; static;
  end;

  TRttiUtil = class
    class function TryStrToValue(ATypeInfo: PTypeInfo; AStr: string; var Value: TValue): Boolean;
    class function HasProperty(AInstance: TObject; AProperty: string): Boolean;
    class function TryGetPropertyType(AInstance: TObject; AProperty: string; var ATypeInfo: PTypeInfo): Boolean;
  end;

  TValueHelper = record helper for TValue
    function TryConvert(ATypeInfo: PTypeInfo; out AOut: TValue): Boolean;
  end;

implementation

{ TAttributeUtil }

class function TAttributeUtil.FindAttribute<T>(
  const Attrs: TArray<TCustomAttribute>): T;
var
  Attr: TCustomAttribute;
begin
  Result := nil;
  for Attr in Attrs do
  begin
    if Attr is T then
      Exit(Attr as T);
  end;
end;

class function TAttributeUtil.FindAttribute<T>(const AObject: TObject): T;
var
  LCtx: TRttiContext;
begin
  LCtx := TRttiContext.Create;
  Result := FindAttribute<T>(
    LCtx
      .GetType(AObject.ClassType)
      .GetAttributes
  ) as T;
end;

class function TAttributeUtil.GetAttributeCount<T>(const AType: TRttiType): Integer;
var
  LField: TRttiField;
  LMethod: TRttiMethod;
  LAttr: TCustomAttribute;
  LFieldType: TRttiType;
begin
  Result := 0;

  for LField in AType.GetFields do
  begin
    if LField.FieldType.IsRecord then
    begin
      LFieldType := LField.FieldType;
      Result := Result + GetAttributeCount<T>(LFieldType);
      Continue;
    end;

    if LField.FieldType.TypeKind = tkDynArray then
    begin
      LFieldType := (LField.FieldType as TRttiDynamicArrayType).ElementType;
      Result := Result + GetAttributeCount<T>(LFieldType);
      Continue;
    end;

    for LAttr in LField.GetAttributes do
      if LAttr is T then
        Inc(Result);
  end;

  for LMethod in AType.GetMethods do
    for LAttr in LMethod.GetAttributes do
      if LAttr is T then
        Inc(Result);
end;

{ TGenericsUtil }

class function TGenericsUtil.AsInteger(const Value): Integer;
begin
  Result := Integer(Value);
end;

class function TGenericsUtil.AsString(const Value): string;
begin
  Result := string(Value);
end;

{ TArrayUtil }

class function TArrayUtil.IndexOf<T>(const Items: TArray<T>; Value: T): Integer;
var
  I: Integer;
begin

  Result := -1;
  for I := 0 to Length(Items) - 1 do
    if TComparer<T>.Default.Compare(Items[I], Value) = 0 then
      Exit(I);
end;

//class function TArrayUtil.Trim(const Items: TArray<string>): TArray<string>;
class procedure TArrayUtil.Trim(var Items: TArray<string>);
begin
  for var I: Integer := 0 to Length(Items) - 1 do
    Items[I] := System.SysUtils.Trim(Items[I]);
end;

class function TArrayUtil.Add<T>(var Items: TArray<T>; Value: T): Integer;
begin
  Result := Length(Items);
  SetLength(Items, Result + 1);
  Items[Result] := Value;
end;

class function TArrayUtil.Concat<T>(
  const values: array of TArray<T>): TArray<T>;
var
  i, k, n: Integer;
begin
  n := 0;
  for i := Low(values) to High(values) do
    Inc(n, Length(values[i]));
  SetLength(Result, n);
  n := 0;
  for i := Low(values) to High(values) do
    for k := Low(values[i]) to High(values[i]) do
    begin
      Result[n] := values[i, k];
      Inc(n);
    end;
end;

class function TArrayUtil.Contains<T>(const Items: TArray<T>; Value: T): Boolean;
begin
  Result := IndexOf<T>(Items, Value) <> -1;
end;

{ TRttiUtil }

class function TRttiUtil.TryStrToValue(ATypeInfo: PTypeInfo; AStr: string;
  var Value: TValue): Boolean;
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
//      tkUnknown: ;
//      tkSet: ;
//      tkClass: ;
//      tkMethod: ;
//      tkVariant: ;
//      tkArray: ;
//      tkRecord: ;
//      tkInterface: ;
//      tkDynArray: ;
//      tkClassRef: ;
//      tkPointer: ;
//      tkProcedure: ;
//      tkMRecord: ;
//    else
//      raise Exception.Create('Not support type: ' + ATypeInfo.Name);
    end;
  except
    Value := TValue.Empty;
  end;

  Result := not Value.IsEmpty;
end;

class function TRttiUtil.HasProperty(AInstance: TObject;
  AProperty: string): Boolean;
var
  LCtx: TRttiContext;
  LType: TRttiType;
  LProp: TRttiProperty;
begin
  LCtx := TRttiContext.Create;
  LType := LCtx.GetType(AInstance.ClassType);
  LProp := LType.GetProperty(AProperty);
  Result := Assigned(LProp);
  LCtx.Free;
end;

class function TRttiUtil.TryGetPropertyType(AInstance: TObject;
  AProperty: string; var ATypeInfo: PTypeInfo): Boolean;
var
  LCtx: TRttiContext;
  LType: TRttiType;
  LProp: TRttiProperty;
begin
  Result := True;
  LCtx := TRttiContext.Create;
  LType := LCtx.GetType(AInstance.ClassType);
  LProp := LType.GetProperty(AProperty);
  if not Assigned(LProp) then
    Exit(False);

  ATypeInfo := LProp.PropertyType.Handle;
  LCtx.Free;
end;

{ TValueHelper }

function TValueHelper.TryConvert(ATypeInfo: PTypeInfo; out AOut: TValue): Boolean;
begin
  AOut := TValue.Empty;
  case TypeInfo.Kind of
  // Integer > string
  tkInteger, tkInt64, tkEnumeration:
    case ATypeInfo.Kind of
    tkString, tkLString, tkWString, tkUString:
      AOut := TValue.From<string>(IntToStr(AsInteger));
    end;
  tkString, tkLString, tkWString, tkUString:
    case ATypeInfo.Kind of
    tkInteger, tkInt64, tkEnumeration:
      begin
        AOut := TValue.FromOrdinal(ATypeInfo, StrToIntDef(AsString, 0));
      end;
    tkFloat:
      AOut := TVAlue.From<Extended>(StrToFloatDef(AsString, 0));
    end;

  tkFloat:
    case ATypeInfo.Kind of
    tkString, tkLString, tkWString, tkUString:
      AOut := TValue.From<string>(FloatToStr(AsExtended));
    end;
  end;

  if AOut.IsEmpty and TryCast(ATypeInfo, AOut) then
    Exit(True);

  Result := not AOut.IsEmpty;
end;

end.
