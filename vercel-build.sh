#!/bin/bash

# 1. Flutter SDK 클론
git clone https://github.com/flutter/flutter.git -b stable

# 2. 패스 설정
export PATH="$PATH:`pwd`/flutter/bin"

# 3. 플러터 진단 및 빌드
flutter doctor
flutter build web --release