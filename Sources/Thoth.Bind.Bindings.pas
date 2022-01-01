unit Thoth.Bind.Bindings;

interface

uses
  Thoth.Classes,
  System.Rtti, System.TypInfo, System.Classes, System.SysUtils, System.Generics.Collections;

type
  TUpdateControlEvent<T> = procedure(const Value: T) of object;

  IBindList<T> = interface
  ['{1AFDEF31-D3AB-4432-962B-F6E757D75CFF}']
    procedure NotifyControls(const Value: T);
    procedure ControlValueChanged(const Value: T);
  end;

  TBindItem<T> = class(TNoRefCountObject, IObserver, IMultiCastObserver, IControlValueObserver)
  private
    FParent: IBindList<T>;
    FComponent: TComponent;
    FPropName: string;

    FProperty: TRttiProperty;
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
    property PropName: string read  FPropName;
  end;

  TBindList<T> = class(TNoRefCountObject, IBindList<T>)
  private
    FList: TObjectList<TBindItem<T>>;
    FOnControlValueChanged: TUpdateControlEvent<T>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(AComponent: TComponent; AProperty: string);
    procedure Remove(AComponent: TComponent; AProperty: string);

    property OnControlValueChanged: TUpdateControlEvent<T> read FOnControlValueChanged write FOnControlValueChanged;

    procedure NotifyControls(const Value: T);
    procedure ControlValueChanged(const Value: T);
  end;


implementation

uses
  Thoth.Utils, Thoth.ResourceStrings;

{ TBindItem<T> }

constructor TBindItem<T>.Create(AParent: IBindList<T>; AComponent: TComponent; AProperty: string);
var
  Ctx: TRttiContext;
begin
  FParent := AParent;
  FComponent := AComponent;
  FPropName := AProperty;

  FProperty := Ctx.GetType(FComponent.ClassType).GetProperty(FPropName);
  if not Assigned(FProperty) then
    raise Exception.CreateFmt(SNotFoundProperty, [ClassName, AComponent.Name, AProperty]);

  FTypeInfo := FProperty.PropertyType.Handle;

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
  LValue, Converted: TValue;
begin
  LValue := TValue.From<T>(Value);

  if not LValue.TryConvert(FTypeInfo, Converted) then
    Exit;

  FProperty.SetValue(FComponent, Converted);
end;

procedure TBindItem<T>.ValueModified;
begin

end;

procedure TBindItem<T>.ValueUpdate;
var
  LValue, Converted: TValue;
  Value: T;
begin
  LValue := FProperty.GetValue(FComponent);

  if not LValue.TryConvert(TypeInfo(T), Converted) then
    Exit;
  FParent.ControlValueChanged(Converted.AsType<T>);
end;

{ TBindList<T> }

constructor TBindList<T>.Create;
begin
  FList := TObjectList<TBindItem<T>>.Create(False);
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
  Item := TBindItem<T>.Create(Self, AComponent, AProperty);
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
    if (Item.Component = AComponent) and (Item.PropName = AProperty) then
    begin
      FList.Delete(I);
      Exit;
    end;
  end;
end;

procedure TBindList<T>.ControlValueChanged(const Value: T);
begin
  if Assigned(FOnControlValueChanged) then
    FOnControlValueChanged(Value);
end;

procedure TBindList<T>.NotifyControls(const Value: T);
var
  Item: TBindItem<T>;
begin
  for Item in FList do
    Item.NotifyControlValue(Value);
end;

end.
