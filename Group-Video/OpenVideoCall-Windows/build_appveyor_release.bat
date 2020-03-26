@echo off

title qmake and nmake build prompt
set SDKVersion=%~1
set SDKFolderVersion=%~2
set Machine=%~3

curl -fsSL -o AgoraSDK.zip https://download.agora.io/sdk/release/Agora_Native_SDK_for_Windows(%Machine%)_v%SDKFolderVersion%_FULL.zip
if exist AgoraSDK.zip (
  7z x AgoraSDK.zip -oAgoraSDK
) else (
  echo "download sdk failed"
		echo "https://download.agora.io/sdk/release/Agora_Native_SDK_for_Windows(%Machine%)_v%SDKFolderVersion%_FULL.zip"
	 exit
)

if not exist sdk (mkdir sdk)
xcopy /S /I AgoraSDK\Agora_Native_SDK_for_Windows_v%SDKVersion%_FULL\sdk sdk /y

if exist AgoraSDK (rmdir /S /Q AgoraSDK)

del AgoraSDK.zip

if %Machine% == x86 (
  set QTDIR=C:\Qt\5.13.2\msvc2017
) else (
  set QTDIR=C:\Qt\5.13.2\msvc2017_64
)

set VCINSTALLDIR=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build

call "%VCINSTALLDIR%\vcvarsall.bat" %Machine%
%QTDIR%\bin\qmake.exe OpenVideoCall.pro "CONFIG+=release" "CONFIG+=qml_release"
nmake

if not exist release (
  echo "no release"
  exit
)

cd release
del *.h
del *.cpp
del *.obj
%QTDIR%\bin\windeployqt OpenVideoCall.exe
cd ..

set PackageDIR=OpenVideoCall_Win_v%SDKVersion%
if not exist %PackageDIR% (
	 mkdir %PackageDIR%
)
cd %PackageDIR%
mkdir %Machine%
xcopy /S /I ..\Release\*.* %Machine% /y
cd ..

7z a -tzip -r OpenVideoCall_Win_v%SDKVersion%(%Machine%).zip release
