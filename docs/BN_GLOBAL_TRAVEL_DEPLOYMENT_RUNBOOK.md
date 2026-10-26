# 🛠️🚀 BN-GLOBAL-TRAVEL-DEPLOYMENT-RUNBOOK
## 상용 운영 인프라 배포 및 장애 복구 운영 가이드북
**Project ID:** `BN-GLOBAL-TRAVEL-APP-002`  
**Client:** Booking Network Co., Ltd.  
**Version:** v1.0.0 (Production Edition)  
**Status:** **ACTIVE & OPERATIONAL**

---

## 1. 운영 인프라 아키텍처 개요

본 서비스는 엔터프라이즈 환경에서 무중단으로 동작하도록 고성능 Go 백엔드 API와 글로벌 엣지 역방향 프록시(Cloudflare Edge)가 계층형으로 구성되어 있습니다.

```mermaid
graph LR
    Client["User Device<br>(PC / Mac / Android / iPhone)"] -->|HTTPS (Port 443)<br>TLS 1.3 / QUIC| CF["Cloudflare Edge Global CDN<br>(TLS Termination & HSTS)"]
    CF -->|Secure Quick Tunnel| LocalDaemon["Cloudflare Tunnel Daemon<br>(cloudflared.exe)"]
    LocalDaemon -->|HTTP / Localhost:8080| GoServer["Go 1.27 High-Performance Server<br>(server.exe)"]
    GoServer --> Web["Flutter Web SPA (/web/)"]
    GoServer --> API["REST API Gateway (/api/v1/)"]
    GoServer --> APK["Android APK Storage (/download/android)"]
```

---

## 2. 서비스 기동 및 정지 절차 (Operational Commands)

### 2.1 백엔드 API 서버 기동
```powershell
# 1. 작업 디렉토리 이동
Set-Location "c:\Users\dnjst\Desktop\project\all-on-one_travel_app"

# 2. 백엔드 바이너리 백그라운드 기동 (포트 8080)
Start-Process -FilePath "backend\bin\server.exe" -ArgumentList "-port 8080" -WindowStyle Hidden
```

### 2.2 공용 HTTPS 터널 기동 (Cloudflare Tunnel)
```powershell
# 공식 설치된 cloudflared 데몬 기동
Start-Process -FilePath "C:\Program Files (x86)\cloudflared\cloudflared.exe" `
  -ArgumentList "tunnel --url http://localhost:8080" -WindowStyle Hidden
```

### 2.3 서비스 종료 (Graceful Shutdown)
```powershell
# 실행 중인 서버 및 터널 프로세스 안전 종료
Get-Process -Name server, cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force
```

---

## 3. 헬스체크 및 실시간 모니터링 가이드

### 3.1 서비스 상태 확인 (Liveness / Readiness)
```powershell
# 로컬 헬스체크
curl.exe -s http://localhost:8080/api/v1/health

# 공용 HTTPS 헬스체크
curl.exe -s https://determines-ing-tvs-allowance.trycloudflare.com/api/v1/health
```
정상 응답: `{"cities":18,"service":"Global Travel Essential API","status":"healthy","version":"1.0.0"}`

### 3.2 Cloudflare 터널 메트릭 확인
- 메트릭 로컬 엔드포인트: `http://127.0.0.1:20241/metrics`
- 전송량, 연결된 QUIC 스트림 수, 지연시간 실시간 제공

---

## 4. 장애 복구 및 롤백 절차 (Disaster Recovery)

### 4.1 포트 충돌 또는 프로세스 이상 시
1. 포트 8080을 점유 중인 프로세스 조회:
   ```powershell
   Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | Select-Object OwningProcess
   ```
2. 해당 PID 종료 후 `backend/bin/server.exe` 재실행.

### 4.2 웹 애플리케이션 캐시 갱신 (PWA Cache Clear)
- 사용자 브라우저에서 `Ctrl + Shift + R` (강력 새로고침)을 수행하거나, `release/web/version.json`의 빌드 번호가 변경되면 Service Worker가 자동으로 신규 에셋을 내려받도록 캐시 무효화 헤더(`Cache-Control: no-cache, no-store, must-revalidate`)가 기적용되어 있습니다.

### 4.3 이전 버전 롤백 (Rollback)
Git 태그 또는 커밋 해시를 기반으로 즉시 이전 상태로 복구:
```powershell
git checkout <PREVIOUS_COMMIT_SHA>
Set-Location backend; go build -o bin/server.exe cmd/server/main.go
```

---

## 5. 모바일 앱 배포 절차 (Mobile Release Runbook)

### 5.1 Android 실기기 직접 배포 (APK Sideload)
1. 다운로드 URL: `https://determines-ing-tvs-allowance.trycloudflare.com/download/android`
2. 또는 웹 브라우저 다운로드 센터: `https://determines-ing-tvs-allowance.trycloudflare.com/download`
3. 기기에서 APK 파일 실행 후 설치 허용.

### 5.2 Google Play Store 콘솔 등록 (AAB)
1. 아티팩트 위치: `release/apk/app-release.aab` (49.1 MB)
2. Google Play Console에 로그인 후 [프로덕션] ➔ [새 버전 출시] ➔ `app-release.aab` 업로드.

### 5.3 iPhone Safari 홈 화면 추가 (Web PWA)
1. iPhone Safari에서 `https://determines-ing-tvs-allowance.trycloudflare.com/web/` 접속.
2. [공유] ➔ [홈 화면에 추가] 선택.

