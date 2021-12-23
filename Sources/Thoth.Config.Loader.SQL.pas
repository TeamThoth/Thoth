unit Thoth.Config.Loader.SQL;

interface

uses
  Thoth.Config.Types,
  Thoth.Config.Loader,
  System.Rtti;

type
  TSQLConfigLoader = class(TCustomConfigLoader)
  private
//    FConnection: TFDConnection;

    FTableName: string;

  protected
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
