# Thoth libarary for Delphi

토트(Thoth) 라이브러리의 목표는 
0. 반복되는 코드(Boilerplate code) 작성을 줄이고, 
1. 새로운 개발 패러다임 구현시 필요 기능을 제공하고, 
2. 테스트가 용이한 개발 방식을 지원하는 것이다.

## 주요 기능(Main features)
* **Thoth.Config** - 환경변수 읽기/쓰기 자동화 객체(Attribute 이용), Thoth.Config.Loader 클래스를 상속해 원하는 자료로 저장(현재 IniFile, SQL Loader 지원)
* **Thoth.Bind.ObservableField** - 관찰가능한 데이터 객체(Observable data object) 제공, 컴포넌트 바인딩(BindComponent) 및 Observe 함수 등록 가능, MVVM 구현 시 ViewModel의 데이터로 활용 가능

## 설치(Installation)
1. 이 저장소 클론(Clone this repository)
```
git clone https://github.com/TeamThoth/Thoth.git
```
2. IDE에서 라이브러리 패스에 Thoth/Sources 등록(Add the source Thoth/Sources to the IDE's library path)

# 샘플(Samples)
## Thoth.Config
### 환경변수 클래스 정의(Attribute 이용)
```pascal
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
```
### 환경변수 객체 사용
```pascal
  // read(using TIniFileConfigLoader)
  FEnv := TEnv.Create(TIniFileConfigLoader.Create as IConfigLoader);
  edtIpAddr.Text := FEnv.IpAddr;
  edtPort.Text := FEnv.Port.ToString;
  // write
  FEnv.IpAddr := edtIpAddr.Text;
  FEnv.Port := StrToIntDef(edtPort.Text, 8080);
  FEnv.Save;
```

## TObservableField<T>
### 옵저버블 변수 정의(Observable variable define)
```pascal
  private
    FLimit: TObservableField<Integer>;
  public
    property Limit: TObservableField<Integer> read FLimit write FLimit;
```
### 옵저버블 변수 활용
```pascal
  // Binding data and component
  dmViewModel.Limit.BindComponent(TrackBar1, 'Position'); // readonly(control <- data)
  dmViewModel.Limit.BindComponent(Edit1, 'Text'); // read-write(control <-> data)
  // Manually update value
  dmViewModel.Limit.Value := 30;
  // Register observe proc
  dmViewModel.Limit.Observe(Self, procedure
    begin
      Memo1.Lines.Add(dmViewModel.Limit.Value.ToString);
    end);
```
