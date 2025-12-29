@echo off
REM 가상환경 설정 스크립트 (Windows)

echo 🔧 실시간 검사 시스템 환경 설정 시작...

REM 가상환경 생성
echo 📦 가상환경 생성 중...
python -m venv venv

REM 가상환경 활성화
echo ✅ 가상환경 활성화 중...
call venv\Scripts\activate.bat

REM pip 업그레이드
echo ⬆️  pip 업그레이드 중...
python -m pip install --upgrade pip

REM 패키지 설치
echo 📥 필수 패키지 설치 중...
pip install -r requirements.txt

echo.
echo ✅ 환경 설정 완료!
echo.
echo 가상환경을 활성화하려면 다음 명령을 실행하세요:
echo   venv\Scripts\activate
echo.
echo 가상환경을 비활성화하려면:
echo   deactivate

pause

