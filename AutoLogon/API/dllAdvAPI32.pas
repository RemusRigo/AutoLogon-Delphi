//--------------------------------------------------------------------------------------------------
// AdvAPI32.dll - Advanced Windows API functions related to security and policy management.
//   © 2026 Remus Rigo
//      v1.0 2026-05-09
//--------------------------------------------------------------------------------------------------

unit dllAdvAPI32;

interface

uses
   Windows;

type
   NTSTATUS = LONG;

const
   STATUS_SUCCESS                 = NTSTATUS(0);
   STATUS_OBJECT_NAME_NOT_FOUND   = NTSTATUS($C0000034);
   POLICY_GET_PRIVATE_INFORMATION = $00000004;
   POLICY_ALL_ACCESS              = $00F01FFF;

type
   LSA_HANDLE  = THandle;
   PLSA_HANDLE = ^LSA_HANDLE;
   ACCESS_MASK = DWORD;

   LSA_UNICODE_STRING = record
      Length        : Word;
      MaximumLength : Word;
      Buffer        : PWideChar;
   end;
   PLSA_UNICODE_STRING = ^LSA_UNICODE_STRING;
   PPLSA_UNICODE_STRING = ^PLSA_UNICODE_STRING;

   LSA_OBJECT_ATTRIBUTES = record
      Length                   : Cardinal;
      RootDirectory            : THandle;
      ObjectName               : PLSA_UNICODE_STRING;
      Attributes               : Cardinal;
      SecurityDescriptor       : Pointer;
      SecurityQualityOfService : Pointer;
   end;
   PLSA_OBJECT_ATTRIBUTES = ^LSA_OBJECT_ATTRIBUTES;

//-------------------------------------------------------------------------------------------------
// Functions
function LsaOpenPolicy(
   SystemName: PLSA_UNICODE_STRING;
   ObjectAttributes: PLSA_OBJECT_ATTRIBUTES;
   DesiredAccess: Access_Mask;
   var PolicyHandle: THandle
   ): Cardinal; stdcall;

function LsaStorePrivateData(PolicyHandle: THandle; KeyName: PLSA_Unicode_String; PrivateData: PLSA_Unicode_String): Cardinal; stdcall;

function LsaRetrievePrivateData(PolicyHandle: THandle; KeyName: PLSA_Unicode_String; PrivateData: PLSA_Unicode_String): Cardinal; stdcall;

function LsaClose(ObjectHandle: THandle): Cardinal; stdcall;

function LsaFreeMemory(Buffer: Pointer): Cardinal; stdcall;

implementation

function LsaOpenPolicy;          external 'advapi32.dll' name 'LsaOpenPolicy';
function LsaStorePrivateData;    external 'advapi32.dll' name 'LsaStorePrivateData';
function LsaRetrievePrivateData; external 'advapi32.dll' name 'LsaRetrievePrivateData';
function LsaClose;               external 'advapi32.dll' name 'LsaClose';
function LsaFreeMemory;          external 'advapi32.dll' name 'LsaFreeMemory';

end.
