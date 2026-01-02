# 실시간 검사 시스템 사용 가이드

## 개요

이 시스템은 YOLO와 DINOv2 모델을 사용하여 실시간으로 프론트도어와 볼트의 양불량을 검사하는 시스템입니다.

## 설치 및 요구사항

### 시스템 요구사항

- Python 3.8 이상
- CUDA (GPU 사용 시, 선택사항)

### 패키지 설치

#### 가상환경 사용

**자동 설정 스크립트 사용 (권장):**

스크립트를 실행하면 가상환경 생성부터 패키지 설치까지 자동으로 진행됩니다.

```bash
# macOS/Linux:
./setup.sh

# Windows:
setup.bat
```

**스크립트가 자동으로 수행하는 작업:**
1. 가상환경 생성 (`venv` 폴더)
2. 가상환경 활성화
3. pip 업그레이드
4. `requirements.txt`의 모든 패키지 설치

스크립트 실행 후 가상환경이 활성화된 상태로 유지되므로, 바로 프로그램을 실행할 수 있습니다.

<!-- **수동 설정:**

```bash
# 가상환경 생성
python -m venv venv

# 가상환경 활성화
# macOS/Linux:
source venv/bin/activate
# Windows:
venv\Scripts\activate
# 또는 Windows PowerShell:
# venv\Scripts\Activate.ps1

# 패키지 설치
pip install -r requirements.txt

``` -->


## 기본 사용법

```bash
python live.py --config <설정파일.yaml> --source <카메라소스>
```

## 명령줄 인자 (Arguments)

### 필수 인자

- `--config`: 설정 YAML 파일 경로 (필수)
  - 예: `BoltLive.yaml`, `DoorLive.yaml`

### 선택 인자

- `--source`: 카메라 소스 (기본값: `0`)
  - `0`: 컴퓨터에 연결된 기본 웹캠
  - `1`, `2`, ...: 외부 USB로 연결된 카메라
  - `"rtsp://..."`: RTSP 네트워크 카메라 URL
  - `"http://..."`: HTTP IP 카메라 URL
  - `"비디오파일.mp4"`: 비디오 파일 경로

- `--device`: 디바이스 선택 (기본값: `cuda`)
  - `cuda`: GPU 사용 (CUDA 사용 가능 시)
  - `cpu`: CPU 사용

- `--obb`: OBB(Oriented Bounding Box) 모드 활성화
  - 회전된 객체를 정확하게 검출하고 처리

- `--debug`: 디버그 모드 활성화
  - 크롭된 이미지를 `debug_crops/` 폴더에 저장
  - 디버깅 및 검증용

- `--detect-only`: 검출 전용 모드 활성화
  - YOLO 검출만 수행하고 DINOv2 검사는 수행하지 않음
  - 검출 결과만 화면에 표시
  - 검사 조건 확인 및 타이머 없이 실시간 검출만 확인 가능
  - YOLO 모델 테스트 및 검출 성능 확인용

## 사용 예시

### 프론트도어 검사

```bash
# 기본 웹캠 사용
python live.py --config DoorLive.yaml --source 0

# 외부 USB 카메라 사용
python live.py --config DoorLive.yaml --source 1

# OBB 모드 활성화
python live.py --config DoorLive.yaml --source 0 --obb

# CPU 사용
python live.py --config DoorLive.yaml --source 0 --device cpu

# 디버그 모드 (크롭 이미지 저장)
python live.py --config DoorLive.yaml --source 0 --debug

# 검출 전용 모드 (검사 없이 YOLO 검출만)
python live.py --config DoorLive.yaml --source 0 --detect-only

# 모든 옵션 조합
python live.py --config DoorLive.yaml --source 0 --obb --debug --device cpu
```

### 볼트 검사

```bash
# 기본 웹캠 사용
python live.py --config BoltLive.yaml --source 0

# 외부 USB 카메라 사용
python live.py --config BoltLive.yaml --source 1

# OBB 모드 활성화
python live.py --config BoltLive.yaml --source 0 --obb

# 디버그 모드
python live.py --config BoltLive.yaml --source 0 --debug

# 검출 전용 모드 (검사 없이 YOLO 검출만)
python live.py --config BoltLive.yaml --source 0 --detect-only

# 네트워크 카메라 사용 (RTSP)
python live.py --config BoltLive.yaml --source "rtsp://192.168.1.100:554/stream"

# IP 웹캠 사용 (HTTP)
python live.py --config BoltLive.yaml --source "http://192.168.1.100:8080/video"
```

## 카메라 소스 옵션 상세

### 로컬 카메라

- **기본 웹캠**: `--source 0`
  - 컴퓨터에 내장된 기본 카메라

- **USB 카메라**: `--source 1`, `--source 2`, ...
  - USB로 연결된 외부 카메라
  - 여러 개 연결 시 인덱스로 구분

### 네트워크 카메라

**사용 권장사항:**
- 먼저 `/video`를 시도 (대부분의 IP 웹캠에서 기본 엔드포인트)
- 작동하지 않으면 `/video.mjpg`를 시도
- 카메라/앱마다 지원하는 엔드포인트가 다를 수 있으므로 제조사 문서 확인

- **HTTP/IP 웹캠**: `--source "http://192.168.1.100:8080/video"`
  - HTTP 프로토콜을 사용하는 IP 카메라
  - IP 웹캠 앱 (예: Android IP Webcam)에서 일반적으로 사용
  - 대부분의 경우 `/video` 엔드포인트가 MJPEG 스트림을 제공함
  
- **MJPEG 스트림 (명시적)**: `"http://192.168.1.100:8080/video.mjpg"`
  - Motion JPEG 형식의 비디오 스트림을 명시적으로 요청
  - `/video`가 작동하지 않을 때 시도
  - 연속된 JPEG 이미지를 빠르게 전송하여 비디오처럼 보이게 함
  - 실시간 스트리밍에 적합하며 지연이 적음



### 비디오 파일

- **비디오 파일**: `--source "test_video.mp4"`
  - 로컬 비디오 파일로 테스트
  - 예: `--source "/path/to/video.avi"`

## 동작 흐름

### 프론트도어 모드

1. **대기 단계**
   - 카메라에서 `high`, `mid`, `low` 세 부위가 각각 1개씩 감지될 때까지 대기
   - 또는 `high`와 `low` 각 1개씩 감지될 때까지 대기 (mid 없이도 가능)

2. **타이머 시작**
   - 조건이 만족되면 3초 타이머 시작
   - 화면에 타이머 표시

3. **조건 유지 확인**
   - 3초 동안 조건이 유지되어야 함
   - 조건이 해제되면 타이머 리셋

4. **검사 수행**
   - 조건이 3초 이상 유지되면 마지막 프레임을 캡처
   - 각 부위(high/mid/low 또는 high/low)를 crop하여 DINOv2로 분류

5. **최종 판정**
   - Hard/Soft Voting 방식으로 최종 판정
   - 결과를 터미널에 출력

### 볼트 모드

1. **대기 단계**
   - 카메라에서 프레임 객체(클래스 2~7번)가 정확히 1개 감지될 때까지 대기
   - 프레임 타입: sedan, suv, hood, frontfender 등

2. **타이머 시작**
   - 조건이 만족되면 5초 타이머 시작
   - 화면에 타이머 표시

3. **조건 유지 확인**
   - 5초 동안 조건이 유지되어야 함
   - 조건이 해제되면 타이머 리셋

4. **검사 수행**
   - 조건이 5초 이상 유지되면 마지막 프레임을 캡처
   - 프레임 내 볼트들을 찾아 개수 체크
     - sedan, suv, hood 프레임(클래스 2~4번): 볼트 2개 필요
     - frontfender 프레임(클래스 5~7번): 볼트 개수 제한 없음
   - 각 볼트를 DINOv2로 분류

5. **최종 판정**
   - Hard/Soft Voting 방식으로 최종 판정
   - 하나라도 불량이면 전체 불량으로 판정
   - 결과를 터미널에 출력

### 검출 전용 모드 (`--detect-only`)

검출 전용 모드에서는 검사 과정 없이 YOLO 검출만 수행합니다.

1. **실시간 검출**
   - 조건 확인 없이 계속 YOLO 검출 수행
   - 검출된 객체를 실시간으로 화면에 표시
   - 검출된 객체 개수가 화면 상단에 표시됨 (예: "Detections: 3")

2. **종료**
   - 'q' 키를 누르면 프로그램 종료
   - 검사는 수행되지 않음

**참고**: 검출 전용 모드는 프론트도어와 볼트 모드 모두에서 동일하게 동작합니다.

## 설정 파일 (YAML)

### 프론트도어 설정 예시 (DoorLive.yaml)

```yaml
mode: frontdoor

# YOLO 모델 경로
yolo_model: ./산학결과/[Final]Door_20251201_201740_tune/iter/weights/best.pt

# DINOv2 모델 경로 (각 부위별)
dino_high: ./산학결과/[Final]DoorDINO_high_2class_20251202_120038/weights/best.pt
dino_mid: ./산학결과/[Final]DoorDINO_mid_2class_20251202_204517/weights/best.pt
dino_low: ./산학결과/[Final]DoorDINO_low_2class_20251202_115110/weights/best.pt

# Voting 방법 (hard 또는 soft)
voting_method: soft

# YOLO 신뢰도 임계값
conf_threshold: 0.25
```

### 볼트 설정 예시 (BoltLive.yaml)

```yaml
mode: bolt

# YOLO 모델 경로
yolo_model: ./산학결과/[Final]Bolt_20251201_111615_tune/iter/weights/best.pt

# DINOv2 모델 경로
dino_bolt: ./산학결과/[Final]BoltDINO_4class_20251202_123616/weights/best.pt

# Voting 방법 (hard 또는 soft)
voting_method: soft

# YOLO 신뢰도 임계값
conf_threshold: 0.25
```

## Voting 방법

### Hard Voting
- 하나라도 불량이면 전체 불량으로 판정
- 엄격한 검사 기준

### Soft Voting
- 각 부위/볼트의 불량 confidence를 평균내어 판정
- 평균 confidence가 0.5 이상이면 불량
- 더 유연한 검사 기준

## OBB 모드

OBB(Oriented Bounding Box) 모드는 회전된 객체를 정확하게 검출하고 처리합니다.

### 특징
- 회전된 객체도 정확하게 검출
- 회전된 객체를 올바른 방향으로 crop하여 분류 정확도 향상
- 기울어진 볼트나 프레임도 정확하게 처리

### 사용법
```bash
python live.py --config BoltLive.yaml --source 0 --obb
```

## 디버그 모드

디버그 모드는 크롭된 이미지를 저장하여 검사 과정을 확인할 수 있습니다.

### 특징
- 크롭된 이미지를 `debug_crops/` 폴더에 저장
- 파일명에 타임스탬프와 부위/볼트 정보 포함
- 크롭 크기 정보 출력

### 저장되는 파일 예시
- 프론트도어: `debug_crops/frontdoor_high_20251223_143045_123.jpg`
- 볼트: `debug_crops/bolt_1_sedan (trunklid)_20251223_143045.jpg`

### 사용법
```bash
python live.py --config BoltLive.yaml --source 0 --debug
```

## 검출 전용 모드

검출 전용 모드는 YOLO 검출만 수행하고 DINOv2 검사는 수행하지 않는 모드입니다.

### 특징
- YOLO 모델의 검출 성능만 확인 가능
- 검사 조건 확인 및 타이머 없이 실시간 검출 결과만 표시
- 검출된 객체 개수가 화면에 표시됨
- DINOv2 모델을 로드하지 않아 시작 속도가 빠름
- YOLO 모델 테스트 및 검출 성능 확인용으로 유용

### 동작 방식
- 일반 모드와 달리 조건 만족 확인 없이 계속 검출만 수행
- 화면에 검출된 객체 개수 표시 (예: "Detections: 3")
- 검출 결과는 실시간으로 화면에 표시됨
- 'q' 키로 종료 가능

### 사용법
```bash
# 프론트도어 검출 전용 모드
python live.py --config DoorLive.yaml --source 0 --detect-only

# 볼트 검출 전용 모드
python live.py --config BoltLive.yaml --source 0 --detect-only

# OBB 모드와 함께 사용
python live.py --config BoltLive.yaml --source 0 --detect-only --obb
```

## 화면 조작

- **'q' 키**: 프로그램 종료
- 실시간 검출 결과가 화면에 표시됨
- 조건 만족 시 타이머가 화면에 표시됨

## 문제 해결

### 카메라를 열 수 없는 경우
- 다른 프로그램에서 카메라를 사용 중인지 확인
- 카메라 권한 확인 (macOS: 시스템 설정 > 보안 및 개인 정보 보호 > 카메라)
- 카메라 인덱스 확인 (0: 내장, 1: USB 카메라 1, 2: USB 카메라 2)

### 프레임을 읽을 수 없는 경우
- 카메라가 실제로 작동하는지 확인
- 카메라 드라이버 문제 확인
- 네트워크 카메라의 경우 연결 상태 확인

### 모델 로드 실패
- 모델 파일 경로 확인
- 모델 파일이 손상되지 않았는지 확인
- 파일 크기 정보를 확인하여 파일이 완전한지 확인

## 출력 정보

실행 시 다음 정보가 출력됩니다:

- 모델 로드 상태
  - YOLO 모델 파일 경로 및 크기
  - DINOv2 모델 파일 경로 및 크기
  - 클래스 수 및 목록

- 시스템 초기화 정보
  - 모드 (frontdoor/bolt)
  - 디바이스 (cuda/cpu)
  - YOLO 신뢰도 임계값
  - 조건 유지 시간
  - Voting 방법
  - OBB 모드 활성화 여부

- 검사 결과
  - 각 부위/볼트별 검사 결과
  - 최종 판정 (양품/불량)
  - 신뢰도 정보

