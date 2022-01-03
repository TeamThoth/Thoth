unit Thoth.Bind.Bindings;

interface

uses
  Thoth.Classes,
  System.Rtti, System.TypInfo, System.Classes, System.SysUtils,
  System.Generics.Collections, System.Generics.Defaults;

type
  TUpdateControlEvent<T> = procedure(const ASource: TComponent; const Value: T) of object;

  IBindList<T> = interface
  ['{1AFDEF31-D3AB-4432-962B-F6E757D75CFF}']
    procedure NotifyControls(const ASource: TComponent; const Value: T);
    procedure ControlValueChanged(const ASource: TComponent; const Value: T);
  end;

  TBindItem<T> = class(TNoRefCountObject, IObserver, IMultiCastObserver, IControlValueObserver)
  private
    FParent: IBindList<T>;
    FComponent: TComponent;
    FProperty: string;

    FTypeInfo: PTypeInfo;

    { IObserver }
    FOnToggle: TObserverToggleEvent;
    function GetActive: Boolean;
    procedure SetActive(Value: Boolean);
    function GetOnObserverToggle: TObserverToggleEvent;
    procedure SetOnObserverToggle(AEvent: TObserverToggleEvent);
    procedure Removed;

    { IControlValueObserver }
    procedure ValueModified;  // KeyPress 시 발생
    procedure ValueUpdate;
    procedure NotifyControlValue(const Value: T);    // Exit(LostFocus) 시 발생
  public
    constructor Create(AParent: IBindList<T>; AComponent: TComponent; AProperty: string);
    destructor Destroy; override;

    property Component: TComponent read FComponent;
    property &Property: string read  FProperty;
  end;

  TBindList<T> = class(TNoRefCountObject, IBindList<T>)
  type
    TBindItemCompare = class(TComparer<TBindItem<T>>)
    public
      function Compare(const Left, Right: TBindItem<T>): Integer; override;
    end;
  private
    FList: TObjectList<TBindItem<T>>;
    FOnControlValueChanged: TUpdateControlEvent<T>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(AComponent: TComponent; AProperty: string);
    procedure Remove(AComponent: TComponent; AProperty: string);

    property OnControlValueChanged: TUpdateControlEvent<T> read FOnControlValueChanged write FOnControlValueChanged;

    procedure NotifyControls(const ASource: TComponent; const Value: T);
    procedure ControlValueChanged(const ASource: TComponent; const Value: T);
  end;


implementation

uses
  Thoth.Utils, Thoth.ResourceStrings;

{ TBindItem<T> }

constructor TBindItem<T>.Create(AParent: IBindList<T>; AComponent: TComponent; AProperty: string);
var
  LProp: TRttiProperty;
begin
  FParent := AParent;
  FComponent := AComponent;
  FProperty := AProperty;

  LProp := TRttiContext.Create.GetType(FComponent.ClassType).GetProperty(FProperty);
//  FProperty := Ctx.GetType(FComponent.ClassType).GetProperty(FPropName);
  if not Assigned(LProp) then
    raise Exception.CreateFmt(SNotFoundProperty, [ClassName, AComponent.Name, AProperty]);

  FTypeInfo := LProp.PropertyType.Handle;

  if not FComponent.Observers.CanObserve(TObserverMapping.ControlValueID) then
    Exit;
  FComponent.Observers.AddObserver(TObserverMapping.ControlValueID, Self);
end;

destructor TBindItem<T>.Destroy;
begin
  if not FComponent.Observers.CanObserve(TObserverMapping.ControlValueID) then
    Exit;
  FComponent.Observers.RemoveObserver(TObserverMapping.ControlValueID, Self);

  inherited;
end;

function TBindItem<T>.GetActive: Boolean;
begin
  Result := True;
end;

procedure TBindItem<T>.SetActive(Value: Boolean);
begin
  if Assigned(FOnToggle) then
    FOnToggle(Self, Value);
end;

function TBindItem<T>.GetOnObserverToggle: TObserverToggleEvent;
begin
  Result := FOnToggle;
end;

procedure TBindItem<T>.SetOnObserverToggle(AEvent: TObserverToggleEvent);
begin
  FOnToggle := AEvent;
end;

procedure TBindItem<T>.Removed;
begin
end;

procedure TBindItem<T>.NotifyControlValue(const Value: T);
var
  LProp: TRttiProperty;
  LValue, Converted: TValue;
begin
  LValue := TValue.From<T>(Value);

  if not LValue.TryConvert(FTypeInfo, Converted) then
    Exit;

  LProp := TRttiContext.Create.GetType(FComponent.ClassType).GetProperty(FProperty);
  LProp.SetValue(FComponent, Converted);
end;

procedure TBindItem<T>.ValueModified;
var
  LValue, Converted: TValue;
  Value: T;
begin
//  LValue := FProperty.GetValue(FComponent);

end;

procedure TBindItem<T>.ValueUpdate;
var
  LProp: TRttiProperty;
  LValue, Converted: TValue;
  Value: T;
begin
  LProp := TRttiContext.Create.GetType(FComponent.ClassType).GetProperty(FProperty);
  LValue := LProp.GetValue(FComponent);

  if not LValue.TryConvert(TypeInfo(T), Converted) then
    Exit;
  FParent.ControlValueChanged(FComponent, Converted.AsType<T>);
end;

{ TBindList<T>.TBindListCompare }

function TBindList<T>.TBindItemCompare.Compare(const Left, Right: TBindItem<T>): Integer;
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

constructor TBindList<T>.Create;
begin
  FList := TObjectList<TBindItem<T>>.Create(TBindItemCompare.Create, True);
end;

destructor TBindList<T>.Destroy;
begin
  FList.Free;

  inherited;
end;

procedure TBindList<T>.Add(AComponent: TComponent; AProperty: string);
var
  Item: TBindItem<T>;
begin
  // Duplicate
  Item := TBindItem<T>.Create(Self, AComponent, AProperty);
  if FList.Contains(Item) then
  begin
    Item.Free;
    Exit;
  end;

  FList.Add(Item);
end;

procedure TBindList<T>.Remove(AComponent: TComponent; AProperty: string);
var
  I: Integer;
  Item: TBindItem<T>;
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

procedure TBindList<T>.ControlValueChanged(const ASource: TComponent; const Value: T);
begin
  if Assigned(FOnControlValueChanged) then
    FOnControlValueChanged(ASource, Value);
end;

procedure TBindList<T>.NotifyControls(const ASource: TComponent; const Value: T);
var
  Item: TBindItem<T>;
begin
  for Item in FList do
    if (ASource = nil) or (ASource <> Item.Component) then
      Item.NotifyControlValue(Value);
end;

end.
