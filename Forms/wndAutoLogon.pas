//--------------------------------------------------------------------------------------------------
// AutoLogon
//    © 2026 Remus Rigo
//       v1.0 2026-05-09
// Main form
//--------------------------------------------------------------------------------------------------

unit wndAutoLogon;

interface

uses
   Winapi.Windows, Winapi.Messages,
   System.SysUtils, System.Variants, System.Classes,
   Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
   // API
   dllAdvAPI32, dllUser32,
   // lib
   libReg;

const
   myAppCaption = 'AutoLogon v1.0 [Remus Rigo]';
   myAppName = 'AutoLogon';
   myAppVer = 'v1.1 2026-05-12';
   myAppAuth = '© 2026 Remus Rigo';

   SYSMENU_ABOUT_ID = UINT(1000);   // must be between 1 and $F000

   REG_WINLOGON = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon';
   LSA_KEY      = 'DefaultPassword';

type
   TfrmAutoLogon = class(TForm)
      chkBoxAutoLogon : TCheckBox;
      grpBoxOptions   : TGroupBox;
      rGroupType      : TRadioGroup;
      lblUserName     : TLabel;
      edUserName      : TEdit;
      lblPassword     : TLabel;
      edPassword      : TEdit;
      lblDomain       : TLabel;
      edDomain        : TEdit;
      btnRead         : TButton;
      btnDelete       : TButton;
      btnSet          : TButton;
      procedure FormCreate(Sender: TObject);
      procedure chkBoxAutoLogonClick(Sender: TObject);
      procedure lblPasswordClick(Sender: TObject);
      procedure rGroupTypeClick(Sender: TObject);
      procedure btnReadClick(Sender: TObject);
      procedure btnDeleteClick(Sender: TObject);
      procedure btnSetClick(Sender: TObject);
   protected
      procedure CreateWnd; override;
      procedure WndProc(var Message: TMessage); override;
   private
      buttonsUp: Boolean;
      function InitLsaString(const S: string): LSA_UNICODE_STRING;
      function ReadPassword: string;
      procedure WritePassword(const Password: string);
   public
      appName    : String;
      appVer     : String;
      appAuth    : String;
end;

var
   frmAutoLogon: TfrmAutoLogon;

implementation

{$R *.dfm}

uses
   wndAbout;

//-------------------------------------------------------------------------------------------------
// CreateWnd
procedure TfrmAutoLogon.CreateWnd;
var
   hSysMenu: HMENU;
begin
   inherited;
   hSysMenu := GetSystemMenu(Handle, False);
   AppendMenu(hSysMenu, MF_SEPARATOR, 0, nil);
   AppendMenu(hSysMenu, MF_STRING,    SYSMENU_ABOUT_ID, 'About...');
end;

//-------------------------------------------------------------------------------------------------
// WndProc
procedure TfrmAutoLogon.WndProc(var Message: TMessage);
var
  frm: TfrmAbout;
begin
   inherited;
   if Message.Msg = WM_SYSCOMMAND then
      if UINT(Message.WParam) = SYSMENU_ABOUT_ID then
      begin
         frm:=TfrmAbout.Create(Self);
         try
            frm.ShowModal;
         finally
            frm.Free;
         end;
      end;
end;

function TfrmAutoLogon.InitLsaString(const S: string): LSA_UNICODE_STRING;
begin
  // Delphi's 'string' is already UTF-16 (Unicode)
  Result.Buffer := PWideChar(S);

  // Length is the number of BYTES used by the string (excluding null terminator)
  Result.Length := Length(S) * SizeOf(WideChar);

  // MaximumLength is the total size of the buffer in BYTES
  // We add SizeOf(WideChar) to account for the null terminator
  if S <> '' then
    Result.MaximumLength := Result.Length + SizeOf(WideChar)
  else
    Result.MaximumLength := 0;
end;

//-------------------------------------------------------------------------------------------------
function TfrmAutoLogon.ReadPassword: string;
var
  LsaHandle: THandle;
  ObjAttrs: LSA_OBJECT_ATTRIBUTES;
  KeyStr: LSA_UNICODE_STRING;
  DataPtr: PLSA_UNICODE_STRING;
  Status: Cardinal;
begin
  Result := '';

  // Initialize the Attributes (must set Length!)
  FillChar(ObjAttrs, SizeOf(ObjAttrs), 0);
  ObjAttrs.Length := SizeOf(ObjAttrs);

  // --- THIS IS THE INITIALIZATION STEP ---
  // We open the policy on the local machine (nil) with GET_PRIVATE_INFO rights
  Status := LsaOpenPolicy(nil, @ObjAttrs, $00000004, LsaHandle);

  if Status = 0 then
  begin
    try
      KeyStr := InitLsaString('DefaultPassword');
      DataPtr := nil;

      // Now 'LsaHandle' is initialized and valid
      Status := LsaRetrievePrivateData(LsaHandle, @KeyStr, @DataPtr);

      if (Status = 0) and (DataPtr <> nil) then
      begin
        try
          if DataPtr.Length > 0 then
            SetString(Result, DataPtr.Buffer, DataPtr.Length div SizeOf(WideChar));
        finally
          LsaFreeMemory(DataPtr);
        end;
      end;

    finally
      // Always close the handle when done
      LsaClose(LsaHandle);
    end;
  end;
end;

//-------------------------------------------------------------------------------------------------
procedure TfrmAutoLogon.WritePassword(const password: string);
var
  LSAPolicy : THandle;
  key, psw  : LSA_UNICODE_STRING;
  objAttrib : LSA_OBJECT_ATTRIBUTES;
  Status    : Cardinal;
begin
   FillChar(objAttrib, SizeOf(objAttrib), 0);
   objAttrib.Length := SizeOf(objAttrib);
   Status:=LsaOpenPolicy(nil, @objAttrib, $00000020, LSAPolicy);
   if status = 0 then
   begin
      try
         key:=InitLsaString('DefaultPassword');
         if password <> '' then
         begin
            psw:=InitLsaString(password);
            status:=LsaStorePrivateData(LSAPolicy, @key, @psw);
         end
         else
         begin
            // If password is empty, delete the secret
            status:=LsaStorePrivateData(LSAPolicy, @key, nil);
         end;
      finally
         LsaClose(LSAPolicy);
      end;
   end;
end;

//-------------------------------------------------------------------------------------------------
// FormCreate
procedure TfrmAutoLogon.FormCreate(Sender: TObject);
begin
   appName:=myAppName;
   appVer:=myAppVer;
   appAuth:=myAppAuth;
   frmAutoLogon.Caption:=myAppCaption;

   // AutoAdminLogon
   if RegValueExists(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'AutoAdminLogon') then
   begin
      if RegReadSZ(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'AutoAdminLogon') = '1' then
         chkBoxAutologon.Checked:=True
   end
   else
      chkBoxAutologon.Checked:=False;

   grpBoxOptions.Enabled:=chkBoxAutologon.Checked;

   // DefaultUserName
   if RegValueExists(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'DefaultUserName') then
      edUserName.Text:= RegReadSZ(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'DefaultUserName')
   else
      edUserName.Text:=GetEnvironmentVariable('USERNAME');

   // Password
   edPassword.Text:=ReadPassword;

   // Account type
   if RegValueExists(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'DefaultDomainName') then
   begin
      edDomain.Text:=RegReadSZ(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'DefaultDomainName');

      if edDomain.Text = '' then
         rGroupType.ItemIndex:=0
      else if edDomain.Text = 'MicrosoftAccount' then
         rGroupType.ItemIndex:=1
      else
         rGroupType.ItemIndex:=2;
   end;
end;

//-------------------------------------------------------------------------------------------------
procedure TfrmAutoLogon.lblPasswordClick(Sender: TObject);
begin
   if edPassword.PasswordChar = '*' then
    edPassword.PasswordChar := #0
  else
    edPassword.PasswordChar := '*';
end;

procedure TfrmAutoLogon.btnReadClick(Sender: TObject);
begin
   edUserName.Text:=RegReadSZ(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'DefaultUserName');
   edPassword.Text:=ReadPassword;
   edDomain.Text:=RegReadSZ(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'DefaultDomainName');
end;

procedure TfrmAutoLogon.btnDeleteClick(Sender: TObject);
begin
   RegDeleteValue(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'DefaultUserName');
   RegDeleteValue(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'DefaultPassword');
   RegDeleteValue(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'DefaultDomainName');
   WritePassword('');
   // Refresh UI
   btnReadClick(Sender);
end;

procedure TfrmAutoLogon.btnSetClick(Sender: TObject);
begin
   // User name
   RegWriteSZ(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'DefaultUserName', edUserName.Text);

   // Password (stored in LSA secret store, not plain registry)
   WritePassword(edPassword.Text);

   case rGroupType.ItemIndex of
      0: // Local account
         RegWriteSZ(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'DefaultDomainName', '');

      1: // Microsoft account
      begin
         RegWriteSZ(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'DefaultDomainName', 'MicrosoftAccount');

         // Ensure password sign-in is used instead of PIN / Windows Hello
         if RegValueExists(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\TestHooks', 'Passwordless') then
            RegWriteDWord(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\TestHooks', 'Passwordless', 0);

        if RegValueExists(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device', 'DevicePasswordLessBuildVersion') then
           RegWriteDWord(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device', 'DevicePasswordLessBuildVersion', 0);

         // Disable Windows Hello sign-in so autologon can take over
         RegWriteDWord(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\PolicyManager\default\Settings', 'AllowSignInOptions', 0);
      end;

      2: // Domain account
         RegWriteSZ(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'DefaultDomainName', edDomain.Text);
   end;
end;

procedure TfrmAutoLogon.chkBoxAutoLogonClick(Sender: TObject);
begin
   if chkBoxAutologon.Checked then
      RegWriteSZ(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'AutoAdminLogon', '1')
   else
      RegWriteSZ(HKEY_LOCAL_MACHINE, REG_WINLOGON, 'AutoAdminLogon', '0');

   grpBoxOptions.Enabled:=chkBoxAutologon.Checked;

   if chkBoxAutologon.Checked then
      grpBoxOptions.Visible:=True
   else
      grpBoxOptions.Visible:=False;

   frmAutoLogon.AutoSize:=True;
end;

procedure TfrmAutoLogon.rGroupTypeClick(Sender: TObject);
begin
   if rGroupType.ItemIndex=0 then
   begin
      lblDomain.Visible:=False;
      edDomain.Visible:=False;
      btnRead.Top:=btnRead.Top-23;
      btnDelete.Top:=btnDelete.Top-23;
      btnSet.Top:=btnSet.Top-23;
      grpBoxOptions.Height:=grpBoxOptions.Height-23;
      buttonsUp:=True;
   end
   else
   begin
      lblDomain.Visible:=True;
      edDomain.Visible:=True;
      if buttonsUp then
      begin
         btnRead.Top:=btnRead.Top+23;
         btnDelete.Top:=btnDelete.Top+23;
         btnSet.Top:=btnSet.Top+23;
         grpBoxOptions.Height:=grpBoxOptions.Height+23;
         buttonsUp:=False;
      end;
   end
end;

end.
