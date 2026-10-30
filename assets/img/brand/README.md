# SIKSIK 브랜드 이미지

내장 image_gen 도구로 제작했습니다. PNG는 생성 원본이며, 사이트에서는 동일한 이미지의 WebP 인코딩을 사용합니다. 로고는 투명 배경을 유지합니다.

- 로고: `siksik-logo.webp` (원본 `siksik-logo.png`)
- 사이드바 배경: `siksik-sidebar.webp` (원본 `siksik-sidebar.png`)
- 색상: 잉크 네이비 `#0b1726`, 차분한 틸 `#70b8ad`, 아이보리 `#f5f1e8`
- 문구: **기록하고, 연결하고, 개선합니다.**

## 사이트 아이콘

`siksik-logo.png`의 투명 여백을 정리한 뒤 같은 디자인으로 크기별 아이콘을 만들었습니다. iOS 홈 화면과 Windows 타일은 네이비 배경으로 처리했습니다.

- 탭 아이콘: `/assets/icons/favicon.ico` (16·32·48·64·256px), PNG (16·32·96px)
- iOS 홈 화면: `/assets/icons/apple-icon-180x180.png` 및 기존 크기별 아이콘
- Android 홈 화면: `/assets/icons/android-icon-192x192.png`, `/assets/icons/android-icon-512x512.png`
- Windows 타일: `/assets/icons/ms-icon-*.png`, `/assets/icons/browserconfig.xml`
- 앱 이름·아이콘 연결: `_includes/head/app-manifest.json` → `/assets/site.webmanifest`, `/assets/icons/manifest.json`
- 링크의 `v=siksik-v1`은 기존 아이콘 캐시 갱신용입니다.

## 제작 프롬프트

### 로고 · logo-brand

Create a finished square logo for a Korean backend developer's personal blog. A geometric S monogram made of two interlocking angular bands in muted teal, above the exact word SIKSIK in bold, spaced geometric sans-serif capitals. Use all six letters exactly: S I K S I K. Warm ivory lettering on a deep ink navy rounded-square tile. Crisp, flat, vector-like artwork, generous margins, readable at 120 pixels. The background outside the tile must be truly transparent. No extra words, slogans, perspective, mockup, or watermark.

### 사이드바 배경 · stylized-concept

Create a finished wide 1536 by 1024 editorial 3D illustration for a backend developer's blog sidebar. Deep ink navy #0b1726 atmosphere, matte architectural planes and translucent stacked data blocks concentrated in the lower right, connected by very subtle muted teal #70b8ad paths with small warm ivory highlights. The upper half and central 60 percent should be quiet dark negative space so white navigation text stays readable, including in a narrow sidebar crop. Restrained, precise, calm and professional. No city, server room, neon, people, letters, or watermark.
