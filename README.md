# 📔 Mobidic (모바일 영어 단어장 서비스)
> **사용자 맞춤형 단어 학습 및 딥러닝 기반 발음 체크 기능을 제공**

기존 단어장 서비스의 불편함을 개선하고자 설계되었으며, 네이티브 안드로이드에서 플러터 크로스 플랫폼으로의 전환, 그리고 백엔드 최적화를 거치며 3차에 걸쳐 완성도를 높인 프로젝트입니다.

---

## 🛠 Tech Stack
- **Backend:** Java 21, [Spring Boot](https://github.com/kthowns/mobidic-be) 3.4.3, Spring Data JPA, Spring Security, QueryDSL
- **Frontend:** [Flutter](https://github.com/kthowns/mobidic-fe) (Cross-Platform), [Android](https://github.com/kthowns/custom-voca) (Native Legacy)
- **Database & Cache:** MySQL, Redis
- **Model Serving:** Python (Flask, Gunicorn), Whisper STT
- **Library & Tools:** Jasypt, JJWT, Docker, Git

---

## 🌿 Project Evolution (개발 과정)

### **Phase 1: Foundation (2024.04 - 2024.07)**
- Android Native (MVVM) 앱 및 기초 백엔드 API 구축
- JUnit 기반 테스트 코드 작성 및 초기 데이터 모델링

### **Phase 2: Expansion (2025.03 - 2025.06)**
- Flutter 기반 크로스 플랫폼 전환 (iOS/Android 대응)
- Whisper STT 모델 기반 영어 발음 체크 기능 구현 및 Flask 서버 연동

### **Phase 3: Optimization & Modernization (2026.02)**
- Flutter 아키텍처 개편 (Riverpod, GoRouter 도입)
- 백엔드 리팩토링 및 쿼리 성능 개선, 프리셋 구현
- QueryDSL 도입을 통한 조회 최적화 및 소셜 인증(Kakao OAuth2) 구현

---

## 🚀 Key Implementation & Problem Solving

### 1. 성능 최적화: 쿼리 2N+1 문제 해결
- **문제 상황:** 
    - 사용자 최초 가입 시 Preset 단어장 복사 및 학습 통계 연산 과정에서 데이터 양($N$)에 비례하여 쿼리가 $2N+1$번 발생하는 성능 저하 확인
- **해결 방안:**
    - **QueryDSL & DTO Projection:** 복잡한 통계 연산 쿼리를 단일 쿼리로 최적화하여 연산 효율 극대화
    - **Hibernate Batch Size:** 엔티티 간 단방향 매핑 구조를 유지하면서, Preset 복사 시 발생하는 연관 엔티티 조회를 **Batch Size 설정**을 통해 1번의 쿼리로 단축
- **결과:** 불필요한 네트워크 오버헤드를 제거하여 데이터 로딩 및 처리 속도 대폭 개선

### 2. 퀴즈 시스템 설계: 어뷰징 방지 및 기밀성 보장
- **문제 상황:** 통계에 반영되는 퀴즈 점수에 대한 어뷰징을 방지하고, 퀴즈 생성-채점 로직 간의 결합도를 낮춰야 함
- **해결 방안:**
    - **Token 기반 채점:** Jasypt 라이브러리를 통해 `UserId + WordId`가 포함된 Hash 값을 생성하여 **Redis**에 토큰과 정답만 저장
    - **결합도 분리:** 클라이언트 응답에는 정답을 제외한 토큰과 문제 정보만 포함하여 채점 로직과의 기밀성 유지
    - **Simple Factory Method 패턴:** OX 퀴즈, 빈칸 채우기 등 다양한 퀴즈 형태에 유연하게 대응할 수 있도록 설계
- **결과:** 퀴즈 데이터의 보안성을 강화하고 새로운 퀴즈 유형 추가 시 기존 코드 수정 최소화
<img width="600" height="300" alt="image" src="https://github.com/user-attachments/assets/2de8d660-80da-45cb-8027-8f82c8dd41a2" />

### 3. Whisper STT 기반 발음 체크 시스템
- **구현 로직:** 사용자 음성 데이터를 Flask 서버로 전송 ➡️ Whisper 모델(`base.en`)로 텍스트 변환 ➡️ **Damerau-Levenshtein Distance** 알고리즘으로 유사도 비교 및 점수 산출
- **최적화:** 
    - 수동 테스트를 통해 리소스 대비 성능이 가장 적합한 모델 버전 결정
    - Gunicorn 기반의 Flask 서버 구성을 통해 모델 서빙 리소스 사용 최적화
