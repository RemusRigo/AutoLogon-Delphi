//--------------------------------------------------------------------------------------------------
// user32.dll - Functions for managing windows, handling input, and other
//              core user interface tasks.
//
//   © 2026 Remus Rigo
//      v1.0 2026-05-09
//--------------------------------------------------------------------------------------------------

unit dllUser32;

interface

uses
   Windows;

const
  //------------------------------------------------------------------------------------------------
  // Window Styles

   WS_BORDER       = $00800000;        // The window has a thin-line border
   WS_CAPTION      = $00C00000;        // The window has a title bar (includes WS_BORDER)
   WS_CHILD        = $40000000;        // The window is a child window. Cannot be used with WS_POPUP
   WS_CHILDWINDOW  = WS_CHILD;         // Alias for WS_CHILD
   WS_CLIPCHILDREN = $02000000;        // Excludes child windows from clipping regions
   WS_CLIPSIBLINGS = $04000000;        // Clips sibling windows during drawing operations
   WS_DISABLED     = $08000000;        // Disables the window
   WS_DLGFRAME     = $00400000;        // The window has a dialog-style frame
   WS_GROUP        = $00020000;        // The window is the first control in a group
   WS_HSCROLL      = $00100000;        // The window has a horizontal scroll bar
   WS_ICONIC       = $20000000;        // The window is initially minimized
   WS_MAXIMIZE     = $01000000;        // The window is initially maximized
   WS_MAXIMIZEBOX  = $00010000;        // The window has a maximize button
   WS_MINIMIZE     = $20000000;        // The window is initially minimized
   WS_MINIMIZEBOX  = $00020000;        // The window has a minimize button
   WS_OVERLAPPED   = $00000000;        // A standard overlapped window (default)
   WS_POPUP        = DWORD($80000000); // The window is a pop-up window. Cannot be used with WS_CHILD
   WS_SIZEBOX      = $00040000;        // The window has a sizing border
   WS_SYSMENU      = $00080000;        // The window has a system menu
   WS_TABSTOP      = $00010000;        // The control can receive keyboard focus via TAB
   WS_THICKFRAME   = WS_SIZEBOX;       // Alias for WS_SIZEBOX
   WS_TILED        = WS_OVERLAPPED;    // Alias for WS_OVERLAPPED
   WS_VISIBLE      = $10000000;        // The window is initially visible
   WS_VSCROLL      = $00200000;        // The window has a vertical scroll bar

  //------------------------------------------------------------------------------------------------
  // Extended Window Styles

  WS_EX_ACCEPTFILES         = $00000010;         // The window accepts drag-drop files
  WS_EX_APPWINDOW           = $00040000;         // Forces a top-level window onto the taskbar when the window is visible
  WS_EX_CLIENTEDGE          = $00000200;         // The window has a border with a sunken edge
  WS_EX_COMPOSITED          = $02000000;         // Paints all descendants in bottom-to-top painting order using double-buffering
  WS_EX_CONTEXTHELP         = $00000400;         // The title bar includes a question mark. Cannot be used with maximize/minimize buttons
  WS_EX_CONTROLPARENT       = $00010000;         // The window itself contains child windows that should take part in dialog navigation
  WS_EX_DLGMODALFRAME       = $00000001;         // The window has a double border
  WS_EX_LAYERED             = $00080000;         // The window is a layered window. Required for transparency/alpha effects
  WS_EX_LAYOUTRTL           = $00400000;         // If the shell language is Hebrew/Arabic, the horizontal origin is on the right edge
  WS_EX_LEFT                = $00000000;         // The window has generic left-aligned properties. This is the default
  WS_EX_LEFTSCROLLBAR       = $00004000;         // The vertical scroll bar is to the left of the client area (RTL languages)
  WS_EX_LTRREADING          = $00000000;         // The window text is displayed using left-to-right reading-order properties
  WS_EX_MDICHILD            = $00000040;         // The window is a MDI child window
  WS_EX_NOACTIVATE          = $08000000;         // A top-level window that does not become the foreground window when clicked
  WS_EX_NOINHERITLAYOUT     = $00100000;         // The window does not pass its window layout to its child windows
  WS_EX_NOPARENTNOTIFY      = $00000004;         // The child window does not send the WM_PARENTNOTIFY message to its parent
  WS_EX_NOREDIRECTIONBITMAP = $00200000;         // The window does not render to a redirection surface. Use for Acrylic/Composition
  WS_EX_RIGHT               = $00001000;         // The window has generic "right-aligned" properties (RTL languages)
  WS_EX_RIGHTSCROLLBAR      = $00000000;         // The vertical scroll bar is to the right of the client area. This is the default
  WS_EX_RTLREADING          = $00002000;         // The window text is displayed using right-to-left reading-order properties
  WS_EX_STATICEDGE          = $00020000;         // The window has a 3D border style for items that do not accept user input
  WS_EX_TOOLWINDOW          = $00000080;         // The window is intended to be used as a floating toolbar (no taskbar icon)
  WS_EX_TOPMOST             = $00000008;         // The window should be placed above all non-topmost windows
  WS_EX_TRANSPARENT         = $00000020;         // The window should not be painted until siblings beneath it are painted
  WS_EX_WINDOWEDGE          = $0000003C;         // The window has a border with a raised edge
     // as per source; SDK standard is $00000100

  // Combined styles
  WS_EX_OVERLAPPEDWINDOW = WS_EX_WINDOWEDGE or WS_EX_CLIENTEDGE;
  WS_EX_PALETTEWINDOW    = WS_EX_WINDOWEDGE or WS_EX_TOOLWINDOW or WS_EX_TOPMOST;

  //------------------------------------------------------------------------------------------------
  // Window Message Constants

  WM_SYSCOMMAND = $0112;

  //------------------------------------------------------------------------------------------------
  // Menu Flags — MF_STRING and MF_SEPARATOR are also in the Windows unit

  MF_STRING_U    = UINT($00000000);
  MF_SEPARATOR_U = UINT($00000800);

  //------------------------------------------------------------------------------------------------
  // SetWindowPos Flags

  SWP_NOSIZE     = UINT($0001);
  SWP_NOMOVE     = UINT($0002);
  SWP_NOACTIVATE = UINT($0010);
  SWP_SHOWWINDOW = UINT($0040);

  HWND_BOTTOM_VAL = HWND(1);

type
  TEnumWindowsProc = function(hWnd: HWND; lParam: LPARAM): BOOL; stdcall;

  TAccentPolicy = packed record
    AccentState   : Integer;
    AccentFlags   : Integer;
    GradientColor : Integer;
    AnimationId   : Integer;
  end;

  TBlendFunction = packed record
    BlendOp             : Byte;
    BlendFlags          : Byte;
    SourceConstantAlpha : Byte;
    AlphaFormat         : Byte;
  end;
  PBlendFunction = ^TBlendFunction;

  TGDI_POINT = packed record
    X : Integer;
    Y : Integer;
  end;
  PGDI_POINT = ^TGDI_POINT;

  TGDI_SIZE = packed record
    Width  : Integer;
    Height : Integer;
  end;
  PGDI_SIZE = ^TGDI_SIZE;

  TWindowCompositionAttributeData = packed record
    Attribute  : Integer;
    Data       : Pointer;
    SizeOfData : Integer;
  end;

// declared in Windows.pas:
// AppendMenu
// EnumWindows
// FindWindow
// FindWindowEx
// GetDC
// GetSystemMenu,
// GetWindowRect
// ReleaseDC
// SendMessage
// SetLayeredWindowAttributes
// SetParent
// SetWindowLong
// SetWindowPos
// UpdateLayeredWindow

function SetWindowCompositionAttribute(hWnd: HWND; var pAttrData: TWindowCompositionAttributeData): Integer; stdcall;

implementation

function SetWindowCompositionAttribute; external 'user32.dll' name 'SetWindowCompositionAttribute';

end.
