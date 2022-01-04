unit Thoth.Bind.Bindings;

interface

uses
  Thoth.Classes,
  System.Rtti, System.TypInfo, System.Classes, System.SysUtils,
  System.Generics.Collections, System.Generics.Defaults;

type
  TUpdateControlEvent<T> = procedure(const ASource: TComponent; const Value: T) of object;

  TBindingsItem<T> = class(TNoRefCountObject, IObserver, IMultiCastObserver, IControlValueObserver)
  private
    FComponent: TComponent;
    FProperty: string;

    FCompPropTypeInfo: PTypeInfo;

    { IObserver }
    FOnToggle: TObserverToggleEvent;
    FOnControlValueChanged: TUpdateControlEvent<T>;
    function GetActive: Boolean;
    procedure SetActive(Value: Boolean);
    function GetOnObserverToggle: TObserverToggleEvent;
    procedure SetOnObserverToggle(AEvent: TObserverToggleEvent);
    procedure Removed;

    { IControlValueObserver }
    procedure ValueModified;  // KeyPress 시 발생
    procedure ValueUpdate;    // Exit 시 발생
    procedure NotifyControlValue(const Value: T);

    procedure SetControlValue(const Value: TValue);

    procedure DoControlValueChanged(const ASource: TComponent; const Value: T);
  public
    constructor Create(AComponent: TComponent; AProperty: string);
    destructor Destroy; override;

    property Component: TComponent read FComponent;
    property &Property: string read  FProperty;

    property OnControlValueChanged: TUpdateControlEvent<T> read FOnControlValueChanged write FOnControlValueChanged;
  end;

  TBindingList<T> = class(TNoRefCountObject)
  type
    TBindItemCompare = class(TComparer<TBindingsItem<T>>)
    public
      function Compare(const Left, Right: TBindingsItem<T>): Integer; override;
    end;
  private
    FList: TObjectList<TBindingsItem<T>>;
    FOnControlValueChanged: TUpdateControlEvent<T>;

    procedure DoControlValueChanged(const ASource: TComponent; const Value: T);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(AComponent: TComponent; AProperty: string);
    procedure Remove(AComponent: TComponent; AProperty: string);

    procedure NotifyAll(const ASource: TComponent; const Value: T);

    property OnControlValueChanged: TUpdateControlEvent<T> read FOnControlValueChanged write FOnControlValueChanged;
  end;


implementation

uses
  Thoth.Utils, Thoth.ResourceStrings;

{ TBindItem<T> }

constructor TBindingsItem<T>.Create(AComponent: TComponent; AProperty: string);
var
  LProp: TRttiProperty;
begin
  FComponent := AComponent;
  FProperty := AProperty;

  LProp := TRttiContext.Create.GetType(FComponent.ClassType).GetProperty(FProperty);
  if not Assigned(LProp) then
    raise Exception.CreateFmt(SNotFoundProperty, [ClassName, AComponent.Name, AProperty]);

  FCompPropTypeInfo := LProp.PropertyType.Handle;

  if not FComponent.Observers.CanObserve(TObserverMapping.ControlValueID) then
    Exit;
  FComponent.Observers.AddObserver(TObserverMapping.ControlValueID, Self);
end;

destructor TBindingsItem<T>.Destroy;
begin
  if not FComponent.Observers.CanObserve(TObserverMapping.ControlValueID) then
    Exit;
  FComponent.Observers.RemoveObserver(TObserverMapping.ControlValueID, Self);

  inherited;
end;

function TBindingsItem<T>.GetActive: Boolean;
begin
  Result := True;
end;

procedure TBindingsItem<T>.SetActive(Value: Boolean);
begin
  if Assigned(FOnToggle) then
    FOnToggle(Self, Value);
end;

function TBindingsItem<T>.GetOnObserverToggle: TObserverToggleEvent;
begin
  Result := FOnToggle;
end;

procedure TBindingsItem<T>.SetOnObserverToggle(AEvent: TObserverToggleEvent);
begin
  FOnToggle := AEvent;
end;

procedure TBindingsItem<T>.Removed;
begin
end;

procedure TBindingsItem<T>.SetControlValue(const Value: TValue);
var
  LProp: TRttiProperty;
  LConvertedValue: TValue;
begin
  if not Value.TryConvert(FCompPropTypeInfo, LConvertedValue) then
    Exit;

  LProp := TRttiContext.Create.GetType(FComponent.ClassType).GetProperty(FProperty);
  LProp.SetValue(FComponent, LConvertedValue);
end;

procedure TBindingsItem<T>.DoControlValueChanged(const ASource: TComponent;
  const Value: T);
begin
  if Assigned(FOnControlValueChanged) then
    FOnControlValueChanged(ASource, Value);
end;

procedure TBindingsItem<T>.NotifyControlValue(const Value: T);
var
  LValue: TValue;
begin
  LValue := TValue.From<T>(Value);

  SetControlValue(LValue);
end;

procedure TBindingsItem<T>.ValueUpdate;
var
  LProp: TRttiProperty;
  LValue, Converted: TValue;
begin
  LProp := TRttiContext.Create.GetType(FComponent.ClassType).GetProperty(FProperty);
  LValue := LProp.GetValue(FComponent);

  if not LValue.TryConvert(TypeInfo(T), Converted) then
    Exit;

  DoControlValueChanged(FComponent, Converted.AsType<T>);
end;

procedure TBindingsItem<T>.ValueModified;
var
  LValue, Converted: TValue;
  Value: T;
begin
//  LValue := FProperty.GetValue(FComponent);

end;

{ TBindList<T>.TBindListCompare }

function TBindingList<T>.TBindItemCompare.Compare(const Left, Right: TBindingsItem<T>): Integer;
begin
  Result := -1;
  if (Left.Component = Right.Component) and (Left.&Property = Right.&Property) then
    Result := 0
  else
  begin
    Result := CompareStr(Left.Component.Name, Right.Component.Name);
    if Result = 0 then
      Result := CompareStr(Left.&Property, Right.&Property);
  end;
end;

{ TBindList<T> }

constructor TBindingList<T>.Create;
begin
  FList := TObjectList<TBindingsItem<T>>.Create(TBindItemCompare.Create, True);
end;

destructor TBindingList<T>.Destroy;
begin
  FList.Free;

  inherited;
end;

procedure TBindingList<T>.Add(AComponent: TComponent; AProperty: string);
var
  Item: TBindingsItem<T>;
begin
  // Duplicate
  Item := TBindingsItem<T>.Create(AComponent, AProperty);
  Item.OnControlValueChanged := DoControlValueChanged;
  if FList.Contains(Item) then
  begin
    Item.Free;
    Exit;
  end;

  FList.Add(Item);
end;

procedure TBindingList<T>.Remove(AComponent: TComponent; AProperty: string);
var
  I: Integer;
  Item: TBindingsItem<T>;
begin
  for I := 0 to FList.Count - 1 do
  begin
    Item := FList[I];
    if (Item.Component = AComponent) and (Item.&Property = AProperty) then
    begin
      FList.Delete(I);
      Exit;
    end;
  end;
end;

procedure TBindingList<T>.DoControlValueChanged(const ASource: TComponent; const Value: T);
begin
  if Assigned(FOnControlValueChanged) then
    FOnControlValueChanged(ASource, Value);
end;

procedure TBindingList<T>.NotifyAll(const ASource: TComponent; const Value: T);
var
  Item: TBindingsItem<T>;
begin
  for Item in FList do
    if ASource = Item.Component then
      Continue
    else
      Item.NotifyControlValue(Value);
end;

end.
