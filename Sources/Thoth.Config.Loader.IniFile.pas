unit Thoth.Config.Loader.IniFile;

interface

uses
  Thoth.Config.Loader,
  System.SysUtils,
  System.IniFiles,
  System.Rtti;

type
  TIniFileConfigLoader = class(TCustomConfigLoader)
  private
    FIniFile: TIniFile;
    FFilename: string;

    procedure CreateIniFile;
  protected
    function ReadValue(const ASection, AIdent: string; ADefault: TValue): TValue; override;
    procedure WriteValue(const ASection, AIdent: string; AValue: TValue); override;
  public
    procedure LoadConfig; override;
    procedure SaveConfig; override;
  end;

implementation

{ TIniFileConfigLoader }

procedure TIniFileConfigLoader.CreateIniFile;
var
  LName: string;
//  LAttr: IniFilenameAttribute;
begin
//  LAttr := TAttributeUtil.FindAttribute<IniFilenameAttribute>(FConfig);
//  if Assigned(LAttr) then
//    LName := LAttr.Filename;
  LName := FConfig.ConfigName;

  if LName = '' then
    FFilename := ChangeFileExt(ParamStr(0), '.ini')
  else
    FFilename := ExtractFilePath(Paramstr(0)) + LName;
  FIniFile := TIniFile.Create(FFilename);
end;

procedure TIniFileConfigLoader.LoadConfig;
begin
  inherited;

end;

function TIniFileConfigLoader.ReadValue(const ASection, AIdent: string;
  ADefault: TValue): TValue;
begin

end;

procedure TIniFileConfigLoader.SaveConfig;
begin
  inherited;

end;

procedure TIniFileConfigLoader.WriteValue(const ASection, AIdent: string;
  AValue: TValue);
begin
  inherited;

end;

end.
