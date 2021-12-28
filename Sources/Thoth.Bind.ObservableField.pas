unit Thoth.Bind.ObservableField;

interface

uses
  System.Classes, System.Generics.Collections;

type
  TUpdateControlEvent<T> = procedure(const Value: T) of object;

  TBindComponent<T> = class(TInterfacedObject, IObserver, IMultiCastObserver, IControlValueObserver)
  private
    FComponent: TComponent;
    FProperty: string;

    FOnToggle: TObserverToggleEvent;
    FOnUpdateControl: TUpdateControlEvent<T>;

    { IObserver }
    procedure Removed;
    function GetActive: Boolean;
    procedure SetActive(Value: Boolean);
    function GetOnObserverToggle: TObserverToggleEvent;
    procedure SetOnObserverToggle(AEvent: TObserverToggleEvent);

    { IControlValueObserver }
    procedure ValueModified;
    procedure ValueUpdate;
  protected
    procedure DoUpdateControl(const Value: T);
  public
    constructor Create(AComponent: TComponent; AProperty: string);
    destructor Destroy; override;

    procedure UpdateControlValue(const Value: T);

    property OnUpdateControl: TUpdateControlEvent<T> read FOnUpdateControl write FOnUpdateControl;
  end;

  TObservableField<T> = class
  private
    FBindingList: TList<TBindComponent<T>>;

    FValue: T;
    function GetValue: T;
    procedure SetValue(const Value: T);

    procedure UpdateValue(const Value: T);
    procedure ControlValueChanged(const Value: T);
  public
    constructor Create;
    destructor Destroy; override;

    property Value: T read GetValue write SetValue;

    procedure BindComponent(AComponent: TComponent; AProperty: string);
    procedure RemoveBindComponent(AComponent: TComponent; AProperty: string = '');
  end;

implementation

uses
  System.SysUtils,
  System.Generics.Defaults,
  System.Rtti;

{ TBindComponent }

constructor TBindComponent<T>.Create(AComponent: TComponent;
  AProperty: string);
begin
  FComponent := AComponent;
  FProperty := AProperty;

  FComponent.Observers.AddObserver(TObserverMapping.ControlValueID, Self);
end;

destructor TBindComponent<T>.Destroy;
begin
  FComponent.Observers.RemoveObserver(TObserverMapping.ControlValueID, Self);

  inherited;
end;

procedure TBindComponent<T>.DoUpdateControl(const Value: T);
begin
  if Assigned(FOnUpdateControl) then
    FOnUpdateControl(Value);
end;

function TBindComponent<T>.GetActive: Boolean;
begin
  Result := True;
end;

function TBindComponent<T>.GetOnObserverToggle: TObserverToggleEvent;
begin
  Result := FOnToggle;
end;

procedure TBindComponent<T>.UpdateControlValue(const Value: T);
var
  LCtx: TRttiContext;
  LValue: TValue;
begin
  LValue := TValue.From<T>(Value);

  { TODO : Casting 贸府 鞘夸 }
  LValue := TValue.From<string>(LValue.ToString);

  LCtx
    .GetType(FComponent.ClassType)
    .GetProperty(FProperty)
    .SetValue(FComponent, LValue);
end;

procedure TBindComponent<T>.Removed;
begin
  WriteLn('Removed');
end;

procedure TBindComponent<T>.SetActive(Value: Boolean);
begin
  if Assigned(FOnToggle) then
    FOnToggle(Self, Value);
end;

procedure TBindComponent<T>.SetOnObserverToggle(AEvent: TObserverToggleEvent);
begin
  FOnToggle := AEvent;
end;

procedure TBindComponent<T>.ValueModified;
begin

end;

procedure TBindComponent<T>.ValueUpdate;
var
  LCtx: TRttiContext;
  LValue: TValue;
begin
  LValue := LCtx.GetType(FComponent.ClassType)
                .GetProperty(FProperty)
                .GetValue(FComponent);

  { TODO : Casting 贸府 鞘夸 }
  LValue := TValue.From<Integer>(StrToInt(LValue.AsString));

  DoUpdateControl(LValue.AsType<T>);
end;

{ TObservableField<T> }

constructor TObservableField<T>.Create;
begin
  FBindingList := TList<TBindComponent<T>>.Create;
end;

destructor TObservableField<T>.Destroy;
begin
  FBindingList.Free;

  inherited;
end;

function TObservableField<T>.GetValue: T;
begin
  Result := FValue;
end;

procedure TObservableField<T>.SetValue(const Value: T);
var
  Comparer: IEqualityComparer<T>;
begin
  Comparer := TEqualityComparer<T>.Default;
  if Comparer.Equals(FValue, Value) then
    Exit;

  FValue := Value;

  UpdateValue(Value);
end;

procedure TObservableField<T>.ControlValueChanged(const Value: T);
begin
  FValue := Value;
end;

procedure TObservableField<T>.UpdateValue(const Value: T);
var
  I: Integer;
begin
  for I := 0 to FBindingList.Count - 1 do
  begin
    FBindingList[I].UpdateControlValue(Value);
  end;
end;

procedure TObservableField<T>.BindComponent(AComponent: TComponent;
  AProperty: string);
var
  BindComp: TBindComponent<T>;
begin
  // Check property

  // Add to binds
  BindComp := TBindComponent<T>.Create(AComponent, AProperty);
  BindComp.OnUpdateControl := ControlValueChanged;
  FBindingList.Add(BindComp);

//  AComponent.Observers.AddObserver()
end;

procedure TObservableField<T>.RemoveBindComponent(AComponent: TComponent;
  AProperty: string);
begin

end;

end.
