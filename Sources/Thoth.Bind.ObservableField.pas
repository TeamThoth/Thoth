unit Thoth.Bind.ObservableField;

interface

uses
  Thoth.Bind.Bindings, Thoth.Bind.Observes,
  System.Classes, System.SysUtils, System.Generics.Collections;

type
  TUpdateControlEvent<T> = procedure(const Value: T) of object;

  IObservableField = interface
  ['{81695AA3-9A63-4CC2-A406-619AACD4368A}']
    procedure BindComponent(AComponent: TComponent; AProperty: string);
    procedure RemoveBindComponent(AComponent: TComponent; AProperty: string = '');

    procedure Observe(AObject: TObject; ACallback: TProc);
    procedure RemoveObserve(AObject: TObject);
  end;

  { TODO : 쓰래드에서 적용 가능하도록 처리 필요 }
  TObservableField<T> = class(TInterfacedObject, IObservableField)
  private
    FBindList: TBindList<T>;
    FObserveList: TObserveList<T>;

    FValue: T;
    function GetValue: T;
    procedure SetValue(const Value: T);

    procedure ValueChanged(const ASource: TComponent; const Value: T);
    procedure ControlValueChanged(const ASource: TComponent; const Value: T);
  public
    constructor Create;
    destructor Destroy; override;

    property Value: T read GetValue write SetValue;

    procedure BindComponent(AComponent: TComponent; AProperty: string);
    procedure RemoveBindComponent(AComponent: TComponent; AProperty: string = '');

    procedure Observe(AObject: TObject; ACallback: TProc);
    procedure RemoveObserve(AObject: TObject);

    procedure Notify;
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
  FBindList := TBindList<T>.Create;
  FBindList.OnControlValueChanged := ControlValueChanged;

  FObserveList := TObserveList<T>.Create;
end;

destructor TObservableField<T>.Destroy;
begin
  FBindList.Free;
  FObserveList.Free;

  inherited;
end;

function TObservableField<T>.GetValue: T;
begin
  Result := FValue;
end;

procedure TObservableField<T>.Notify;
begin
  ValueChanged(nil, FValue);
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
begin
  FValue := Value;
  ValueChanged(ASource, Value);
end;

procedure TObservableField<T>.ValueChanged(const ASource: TComponent; const Value: T);
begin
  FBindList.NotifyControls(ASource, Value);
  FObserveList.Notify(Value);
end;

procedure TObservableField<T>.BindComponent(AComponent: TComponent;
  AProperty: string);
begin
  FBindList.Add(AComponent, AProperty);
end;

procedure TObservableField<T>.RemoveBindComponent(AComponent: TComponent;
  AProperty: string);
begin
  FBindList.Remove(AComponent, AProperty);
end;

procedure TObservableField<T>.Observe(AObject: TObject; ACallback: TProc);
begin
  FObserveList.Add(AObject, ACallback);
end;

procedure TObservableField<T>.RemoveObserve(AObject: TObject);
begin

end;

end.
