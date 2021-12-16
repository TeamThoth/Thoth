unit Thoth.LiveData;

interface

type
  TLiveData<T> = record
  private
    FValue: T;
    function GetValue: T;
  public
    constructor Create(const Value: T); overload;

    property Value: T read GetValue;

    class operator Implicit(const AValue: T): TLiveData<T>;
    class operator Implicit(const AValue: TLiveData<T>): T;
    class operator Explicit(const AValue: T): TLiveData<T>;
    class operator Explicit(const AValue: TLiveData<T>): T;
  end;

implementation

{ TLiveData<T> }

constructor TLiveData<T>.Create(const Value: T);
begin
  FValue := Value;
end;

function TLiveData<T>.GetValue: T;
begin
  Result := FValue;
end;

class operator TLiveData<T>.Implicit(const AValue: T): TLiveData<T>;
begin
  Result.FValue := AValue;
end;

class operator TLiveData<T>.Implicit(const AValue: TLiveData<T>): T;
begin
  Result := AValue.Value;
end;

class operator TLiveData<T>.Explicit(const AValue: T): TLiveData<T>;
begin
  Result.FValue := AValue;
end;

class operator TLiveData<T>.Explicit(const AValue: TLiveData<T>): T;
begin
  Result := AValue.Value;
end;

end.
