unit Thoth.Bind.ObservableField;

interface

uses
  Thoth.Bind.Types, Thoth.Bind.Bindings, Thoth.Bind.Observes,
  System.Classes, System.SysUtils, System.Generics.Collections;

type
  TUpdateControlEvent<T> = procedure(const Value: T) of object;

  IObservableField<T> = interface
  ['{81695AA3-9A63-4CC2-A406-619AACD4368A}']
    procedure BindComponent(AComponent: TComponent; AProperty: string; ASupportBindEventTypes: TBindEventTypes);
    procedure RemoveBindComponent(AComponent: TComponent; AProperty: string = '');

    procedure Observe(AObject: TObject; ACallback: TProc<T>);
    procedure RemoveObserve(AObject: TObject);
  end;

  { TODO : 쓰래드에서 적용 가능하도록 처리 필요 }
  TObservableField<T> = class(TInterfacedObject, IObservableField<T>)
  private
    FBindings: TBindingList<T>;
    FObservings: TObservingList<T>;

    FValue: T;
    function GetValue: T;
    procedure SetValue(const Value: T);

    procedure ValueChanged(const ASource: TComponent; const Value: T);
    procedure ControlValueChanged(const ASource: TComponent; const Value: T);
  public
    constructor Create;
    destructor Destroy; override;

    property Value: T read GetValue write SetValue;

    procedure BindComponent(AComponent: TComponent; AProperty: string;
      ASupportBindEventTypes: TBindEventTypes = [betUpdate]);
    procedure RemoveBindComponent(AComponent: TComponent; AProperty: string = '');

    procedure Observe(AObject: TObject; ACallback: TProc<T>);
    procedure RemoveObserve(AObject: TObject);

    procedure Notify(ASource: TComponent = nil);
  end;

  { TODO : ObservableList }

implementation

uses
  Thoth.Utils, Thoth.ResourceStrings,
  System.Generics.Defaults,
  System.Rtti;

{ TObservableField<T> }

constructor TObservableField<T>.Create;
begin
  FBindings := TBindingList<T>.Create;
  FBindings.OnControlValueChanged := ControlValueChanged;

  FObservings := TObservingList<T>.Create;
end;

destructor TObservableField<T>.Destroy;
begin
  FBindings.Free;
  FObservings.Free;

  inherited;
end;

function TObservableField<T>.GetValue: T;
begin
  Result := FValue;
end;

procedure TObservableField<T>.Notify(ASource: TComponent);
begin
  ValueChanged(ASource, FValue);
end;

procedure TObservableField<T>.SetValue(const Value: T);
var
  Comparer: IEqualityComparer<T>;
begin
  Comparer := TEqualityComparer<T>.Default;
  if Comparer.Equals(FValue, Value) then
    Exit;

  FValue := Value;

  ValueChanged(nil, Value);
end;

procedure TObservableField<T>.ControlValueChanged(const ASource: TComponent; const Value: T);
var
  Comparer: IEqualityComparer<T>;
begin
  Comparer := TEqualityComparer<T>.Default;
  if Comparer.Equals(FValue, Value) then
    Exit;

  FValue := Value;

  ValueChanged(ASource, Value);
end;

procedure TObservableField<T>.ValueChanged(const ASource: TComponent; const Value: T);
begin
  FBindings.NotifyAll(ASource, Value);
  FObservings.NotifyAll(Value);
end;

procedure TObservableField<T>.BindComponent(AComponent: TComponent;
  AProperty: string; ASupportBindEventTypes: TBindEventTypes);
begin
  FBindings.Add(AComponent, AProperty, ASupportBindEventTypes);
end;

procedure TObservableField<T>.RemoveBindComponent(AComponent: TComponent;
  AProperty: string);
begin
  FBindings.Remove(AComponent, AProperty);
end;

procedure TObservableField<T>.Observe(AObject: TObject; ACallback: TProc<T>);
begin
  FObservings.Add(AObject, ACallback);
end;

procedure TObservableField<T>.RemoveObserve(AObject: TObject);
begin

end;

end.
