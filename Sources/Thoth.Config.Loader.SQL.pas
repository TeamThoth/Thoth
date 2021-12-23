unit Thoth.Config.Loader.SQL;

interface

uses
  Thoth.Config.Types,
  Thoth.Config.Loader,
  // FireDAC
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  System.Rtti;

type
  TSQLConfigLoader = class(TCustomConfigLoader)
  private
    FConnection: TFDConnection;
    FQuery: TFDQuery;

    FTableName: string;

  protected
    procedure DoInitialize;

    function DoReadValue(const ASection, AKey: string; ADefault: TValue): TValue; override;
    procedure DoWriteValue(const ASection, AKey: string; AValue: TValue); override;

    procedure DoBeforeLoadConfig; override;
    procedure DoAfterLoadConfig; override;
    procedure DoBeforeSaveConfig; override;
    procedure DoAfterSaveConfig; override;

    procedure DoClearData; override;
  end;

implementation

{ TSQLConfigLoader }

procedure TSQLConfigLoader.DoInitialize;
begin

end;

procedure TSQLConfigLoader.DoAfterLoadConfig;
begin
  inherited;

end;

procedure TSQLConfigLoader.DoAfterSaveConfig;
begin
  inherited;

end;

procedure TSQLConfigLoader.DoBeforeLoadConfig;
begin
  inherited;

end;

procedure TSQLConfigLoader.DoBeforeSaveConfig;
begin
  inherited;

end;

procedure TSQLConfigLoader.DoClearData;
begin
  inherited;

end;

function TSQLConfigLoader.DoReadValue(const ASection, AKey: string;
  ADefault: TValue): TValue;
begin

end;

procedure TSQLConfigLoader.DoWriteValue(const ASection, AKey: string;
  AValue: TValue);
begin
  inherited;

end;

end.
