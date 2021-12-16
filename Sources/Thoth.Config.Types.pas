unit Thoth.Config.Types;

interface

type
  IConfig = interface
    function GetConfigName: string;
    procedure SetConfigName(const Value: string);
    property ConfigName: string read GetConfigName write SetConfigName;
  end;

  IConfigLoader = interface
  ['{F8551D93-54E6-4534-A13C-2F6E2941AFD8}']
    procedure LoadConfig;
    procedure SaveConfig;
  end;

implementation

end.
