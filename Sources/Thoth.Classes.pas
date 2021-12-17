unit Thoth.Classes;

{$I Thoth.inc}

interface

type
{$IFDEF DELPHIX_ALEXANDRIA_UP}
  TNoRefCountObject = System.TNoRefCountObject;
{$ELSE}
  TNoRefCountObject = class(TObject, IInterface)
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
  end;
{$ENDIF}

implementation

{$IFNDEF DELPHIX_ALEXANDRIA_UP}
{ TNoRefCountObject }

function TNoRefCountObject.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TNoRefCountObject._AddRef: Integer;
begin
  Result := -1;
end;

function TNoRefCountObject._Release: Integer;
begin
  Result := -1;
end;
{$ENDIF}

end.
