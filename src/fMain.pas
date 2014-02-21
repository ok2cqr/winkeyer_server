unit fMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls, Menus, ActnList, lNetComponents, lNet, uCWKeying,
  inifiles;

const
  AllowedChars     = ['A'..'Z', 'a'..'z', '0'..'9', '/', ',', '.', '?', '!', ' ',
    ':', '|', '-', '=', '+', '@', '#', '*', '%', '_', '(', ')', '$'];


type

  { TfrmMain }

  TfrmMain = class(TForm)
    acClose: TAction;
    acPreferences: TAction;
    ActionList1: TActionList;
    btnServer: TButton;
    btnOpenKeyer: TButton;
    edtSpeed: TEdit;
    edtDev: TEdit;
    edtPort: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lblCWInfo: TLabel;
    lblInfo: TLabel;
    m:   TMemo;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    StatusBar1: TStatusBar;
    procedure acCloseExecute(Sender: TObject);
    procedure btnServerClick(Sender: TObject);
    procedure btnOpenKeyerClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    Running: boolean;
    CW:      TCWKeying;
    CWActive: boolean;
    UDP: TLUDPComponent;

    procedure OnEr(const msg: string; aSocket: TLSocket); // OnError callback
    procedure OnRe(aSocket: TLSocket); // OnReceive callback

    function MyTrim(s: string): string;
  public
    { public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{ TfrmMain }

function TfrmMain.MyTrim(s: string): string;
var
  i: integer;
begin
  s      := Trim(s);
  Result := '';
  for i := 1 to Length(s) do
  begin
    if (s[i] in AllowedChars) then
      Result := Result + s[i]
  end
end;

procedure TfrmMain.OnEr(const msg: string; aSocket: TLSocket);
begin
  Writeln(msg);
  m.Lines.Add(msg)
end;

procedure TfrmMain.OnRe(aSocket: TLSocket);
var
  s,x: string;
  i : Integer;
  t : String;
begin
  if aSocket.GetMessage(s) > 0 then
  begin
    if s[1] = chr(27) then
    begin
      case s[2] of
        '2' : begin
                x := s[3]+s[4];
                if not TryStrToInt(x,i) then
                  i := 30;
                m.Lines.Add('Setting speed to '+IntToStr(i)+' WPM');
                CW.SetSpeed(i);
              end;
        '4' : begin
                CW.StopSending;
                m.Lines.Add('Sending stopped')
              end
      end;
      exit
    end;
    t := '';
    for i:= 1 to Length(s) do
    begin
      if s[i] in AllowedChars then
      begin
        t := t + s[i];
        CW.SendText(s[i])
      end
      else
        break
    end;
    if t <> ' ' then
      m.Lines.Add('Sending ...'+t)
  end
end;


procedure TfrmMain.FormCreate(Sender: TObject);
begin
  UDP := TLUDPComponent.Create(nil);
  UDP.OnError := @OnEr;     // assign callbacks
  UDP.OnReceive := @OnRe;
  UDP.Timeout := 100; // responsive enough, but won't hog CPU
  Running := False;
  CWActive := False;
  CW := TCWKeying.Create;
  CW.KeyType := ktWinKeyer;
  CW.DebugMode := True
end;

procedure TfrmMain.FormShow(Sender: TObject);
var
  ini : TIniFile;
begin
  ini := TIniFile.Create(GetAppConfigFile(False));
  try
    width         := ini.ReadInteger('Main','width',width);
    height        := ini.ReadInteger('Main','height',height);
    top           := ini.ReadInteger('Main','top',10);
    left          := ini.ReadInteger('Main','left',10);
    edtSpeed.Text := ini.ReadString('Main','speed','32');
    edtPort.text  := ini.ReadString('Main','port','6789');
    edtDev.Text   := ini.ReadString('Main','device','/dev/ttyUSB0')
  finally
    ini.Free
  end
end;

procedure TfrmMain.btnServerClick(Sender: TObject);
begin
  if not Running then
  begin
    udp.Listen(StrToInt(edtPort.Text));
    btnServer.Caption := 'Quit';
    lblInfo.Caption := 'Server is running';
    Running := True
  end
  else
  begin
    udp.Disconnect;
    Close;
    btnServer.Caption := 'Start server';
    lblInfo.Caption   := 'Server is NOT running'
  end
end;

procedure TfrmMain.acCloseExecute(Sender: TObject);
begin
  Close
end;

procedure TfrmMain.btnOpenKeyerClick(Sender: TObject);
begin
  if not CWActive then
  begin
    CW.Device := edtDev.Text;
    CW.Port   := edtDev.Text;
    CW.Open;
    if CW.Active then
    begin
      CW.SetSpeed(StrToInt(edtSpeed.Text));
      CWActive := True;
      btnOpenKeyer.Caption := 'Close keyer';
      lblCWInfo.Caption    := 'Keyer is online';
      if CW.Firmware <> '' then
      begin
        m.Lines.Add('Keyer is online');
        m.Lines.Add('Firmware version: '+CW.Firmware)
      end
    end
    else begin
      lblCWInfo.Caption := 'Keyer is NOT online';
      m.Lines.Add('Keyer is NOT online');
      m.Lines.Add('Error: ('+IntToStr(CW.LastErrNr)+') '+CW.LastErrSt)
    end
  end
  else begin
    CW.Close;
    CWActive := False;
    btnOpenKeyer.Caption := 'Open keyer';
    lblCWInfo.Caption := 'Keyer is offline';
    m.Lines.Add('Keyer is offline')
  end
end;

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  ini : TIniFile;
begin
  ini := TIniFile.Create(GetAppConfigFile(False));
  try
    ini.WriteInteger('Main','width',width);
    ini.WriteInteger('Main','height',height);
    ini.WriteInteger('Main','top',top);
    ini.WriteInteger('Main','left',left);
    ini.WriteString('Main','speed',edtSpeed.text);
    ini.WriteString('Main','port',edtPort.text);
    ini.WriteString('Main','device',edtDev.Text)
  finally
    ini.Free
  end
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CW.Close;
  FreeAndNil(CW);
  FreeAndNil(UDP)
end;

initialization
  {$I fMain.lrs}

end.

