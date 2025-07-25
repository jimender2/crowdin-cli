; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Crowdin"
#define MyAppVersion "4.9.0"
#define MyAppPublisher "OU Crowdin"
#define MyAppURL "https://crowdin.github.io/crowdin-cli"
#define MyAppExeName "crowdin-cli.jar"

[Registry]
Root: HKCU; Subkey: "Environment"; ValueType:string; ValueName:"PATH"; ValueData:"{olddata};{app}"; Flags: preservestringtype
Root: HKCU; Subkey: "Environment"; ValueType:string; ValueName:"CROWDIN_HOME"; ValueData:"{app}"; Flags: preservestringtype

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{52B80417-16B8-4EFE-B118-6FA64B25CC0F}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={commonpf}\CrowdinCLI
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\..\
OutputBaseFilename=crowdin
Compression=lzma
SolidCompression=yes
ChangesEnvironment=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\..\dist\crowdin-cli.jar"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\zip\crowdin.bat"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"

[Code]
function CutJavaVersionPart(var V: string): Integer;
var
  S: string;
  P: Integer;
begin
  if Length(V) = 0 then
  begin
    Result := 0;
  end
    else
  begin
    P := Pos('.', V);
    if P = 0 then P := Pos('_', V);

    if P > 0 then
    begin
      S := Copy(V, 1, P - 1);
      Delete(V, 1, P);
    end
      else
    begin
      S := V;
      V := '';
    end;
    Result := StrToIntDef(S, 0);
  end;
end;

function MaxJavaVersion(V1, V2: string): string;
var
  Part1, Part2: Integer;
  Buf1, Buf2: string;
begin
  Buf1 := V1;
  Buf2 := V2;
  Result := '';
  while (Result = '') and
        ((Buf1 <> '') or (Buf2 <> '')) do
  begin
    Part1 := CutJavaVersionPart(Buf1);
    Part2 := CutJavaVersionPart(Buf2);
    if Part1 > Part2 then Result := V1
      else
    if Part2 > Part1 then Result := V2;
  end;
end;

function GetJavaVersion(): string;
var
  TempFile: string;
  ResultCode: Integer;
  S: AnsiString;
  P: Integer;
begin
  TempFile := ExpandConstant('{tmp}\javaversion.txt');
  if (not ExecAsOriginalUser(
            ExpandConstant('{cmd}'), '/c java -version 2> "' + TempFile + '"', '',
            SW_HIDE, ewWaitUntilTerminated, ResultCode)) or
     (ResultCode <> 0) then
  begin
    Log('Failed to execute java -version');
  end
    else
  if not LoadStringFromFile(TempFile, S) then
  begin
    Log(Format('Error reading file %s', [TempFile]));
  end
    else
  if Copy(S, 1, 14) <> 'java version "' then
  begin
    Log('Output of the java -version not as expected');
  end
    else
  begin
    Delete(S, 1, 14);
    P := Pos('"', S);
    if P = 0 then
    begin
      Log('Output of the java -version not as expected');
    end
      else
    begin
      SetLength(S, P - 1);
      Result := S;
    end;
  end;

  DeleteFile(TempFile);
end;

function HasJava1Dot7OrNewer: Boolean;
begin
  Result := (MaxJavaVersion('1.6.9', GetJavaVersion) <> '1.6.9');
end;

function InitializeSetup(): Boolean;
var
  ErrorCode: Integer;
begin
  Result := HasJava1Dot7OrNewer;
  if not Result then
  begin
    Result := MsgBox(ExpandConstant('Your Java version needs to be updated. Download it from https://www.java.com?'), mbConfirmation, MB_YESNO) = idYes;
    if Result then
    begin
      ShellExec(
        'open', 'https://www.java.com/getjava/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    end;
  end;
end;
