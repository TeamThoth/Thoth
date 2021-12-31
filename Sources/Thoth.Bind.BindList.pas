unit Thoth.Bind.BindList;

interface

uses
  Thoth.Classes,
  System.Classes, System.SysUtils, System.Generics.Collections;

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
    FProperty: string;

    FOnToggle: TObserverToggleEvent;

    { IObserver }
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
  Thoth.Utils,
  System.Rtti;

{ TBindItem<T> }

constructor TBindItem<T>.Create(AParent: IBindList<T>; AComponent: TComponent; AProperty: string);
begin
  FParent := AParent;
  FComponent := AComponent;
  FProperty := AProperty;

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

function TBindItem<T>.GetOnObserverToggle: TObserverToggleEvent;
begin
  Result := FOnToggle;
end;

procedure TBindItem<T>.Removed;
begin

end;

procedure TBindItem<T>.SetActive(Value: Boolean);
begin
  if Assigned(FOnToggle) then
    FOnToggle(Self, Value);
end;

procedure TBindItem<T>.SetOnObserverToggle(AEvent: TObserverToggleEvent);
begin
  FOnToggle := AEvent;
end;

procedure TBindItem<T>.NotifyControlValue(const Value: T);
var
  LCtx: TRttiContext;
  LValue: TValue;
begin
  LValue := TValue.From<T>(Value);

  { TODO : Dynamic Casting 처리 필요. 데이터의 타입을 속성 타입으로 치환 }
  LValue := TValue.From<string>(LValue.ToString);

  LCtx
    .GetType(FComponent.ClassType)
    .GetProperty(FProperty)
    .SetValue(FComponent, LValue);
end;

procedure TBindItem<T>.ValueModified;
begin

end;

procedure TBindItem<T>.ValueUpdate;
var
  LCtx: TRttiContext;
  LValue, Converted: TValue;
  Value: T;
begin
  LValue := LCtx.GetType(FComponent.ClassType)
                .GetProperty(FProperty)
                .GetValue(FComponent);

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
var
  Item: TBindItem<T>;
begin
//  Item := FList.Items[0];
//
//  FList.Items[0].Free;
//  FList.Clear;
  FList.Free;

  inherited;
end;

procedure TBindList<T>.Add(AComponent: TComponent; AProperty: string);
var
  Item: TBindItem<T>;
begin
  // 변환 가능한지 확인(예> string > Integer, Enum > Integer)

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
    if (Item.Component = AComponent) and (Item.&Property = AProperty) then
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
