unit ConfigForm;

interface

uses
  Thoth.Config, Thoth.Config.Types,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  [ConfigName('Env')]
  TEnv = class(TThothConfig)
  private
    FPort: Integer;
    FIpAddr: string;
  public
    [ConfigItem('Server', '192.168.0.1')]
    property IpAddr: string read FIpAddr write FIpAddr;
    [ConfigItem('Server', 8080)]
    property Port: Integer read FPort write FPort;
  end;

  TForm1 = class(TForm)
    btnSaveConfig: TButton;
    edtIpAddr: TEdit;
    edtPort: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnSaveConfigClick(Sender: TObject);
  private
    { Private declarations }
    FEnv: TEnv;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  Thoth.Config.Loader.IniFile;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  FEnv := TEnv.Create(TIniFileConfigLoader.Create as IConfigLoader);

  edtIpAddr.Text := FEnv.IpAddr;
  edtPort.Text := FEnv.Port.ToString;
end;

procedure TForm1.btnSaveConfigClick(Sender: TObject);
begin
  FEnv.IpAddr := edtIpAddr.Text;
  FEnv.Port := StrToIntDef(edtPort.Text, 8080);
  FEnv.Save;
end;

end.
