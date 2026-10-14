# AutoLogon: User's Guide



## Downloads & Runtimes

Download the latest release from the [Releases page](https://github.com/RemusRigo/AutoLogon-Delphi/releases).

|Folder|Architecture|Required Runtime|
|-|-|-|
|`Win32`|32-bit|none (native Windows app)|
|`Win64`|64-bit|none (native Windows app)|

> On 64-bit Windows, use **Win64**.



## Install

AutoLogon is portable: there is no installer.

1. Copy `AutoLogon.exe` to a folder, for example `D:\My Apps\AutoLogon\`.
2. Double-click `AutoLogon.exe` and accept the administrator prompt (AutoLogon writes to `HKEY_LOCAL_MACHINE`).

> If Windows blocks the file ("Windows protected your PC"), right-click `AutoLogon.exe` →
> **Properties** → check **Unblock** → **OK**, then try again.



## Usage

1. Check **Enable AutoLogon**. The **Options** are shown.
2. Choose the **Account Type**:

   |Account Type|User Name|Domain|
   |-|-|-|
   |**Local**|your Windows user name|(hidden)|
   |**Microsoft Account**|your Microsoft account e-mail|`MicrosoftAccount`|
   |**Domain**|your domain user name|your domain name|

3. Enter the **Password**. Click the **Password** label to show/hide it.
4. Click **Set**, then restart Windows: it signs in automatically.

|Button|Description|
|-|-|
|**Set**|Save the user name, password and domain|
|**Read**|Reload the saved settings|
|**Delete**|Remove the saved user name, password and domain|

To turn AutoLogon off, uncheck **Enable AutoLogon**.
Right-click the title bar → **About...** for version information.

> **Microsoft Account:** **Set** also turns off the Windows Hello / passwordless sign-in options, so
> Windows can sign in with the password. **Delete** and unchecking **Enable AutoLogon** don't turn them back on.

> **Security:** anyone who turns on the PC is signed in to your account, and an administrator on this PC
> can read the saved password. Use AutoLogon only on a PC that is physically secure.



## Where are the settings stored?

|Setting|Location|
|-|-|
|AutoLogon on/off, user name, domain|`HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon` (`AutoAdminLogon`, `DefaultUserName`, `DefaultDomainName`)|
|Password|LSA secret `DefaultPassword`|



## Uninstall

1. Click **Delete**, then uncheck **Enable AutoLogon**.
2. Delete `AutoLogon.exe`.
