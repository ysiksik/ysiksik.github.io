---
layout: post
bigtitle: '쿠폰 서비스'
subtitle: 쿠폰 발급 서비스 구성
date: '2023-04-23 00:00:00 +0900'
categories:
- coupon-service
comments: true
---

# 쿠폰 발급 서비스 구성

# 쿠폰 발급 서비스 구성
* toc
{:toc}

## 개요
+ 휴대폰 소액 결제 마케팅 및 쿠폰 서비스 

## 서비스 구성
+ ![img_1.png](../../../assets/img/coupon-service/configureCouponIssuanceService_1.png)

## 쿠폰 발급/사용 프로세스 
+ 고객 프로모션 쿠폰 발급 프로세스 (타겟팅)
  + ![img_2.png](../../../assets/img/coupon-service/configureCouponIssuanceService_2.png)
+ 고객 프로모션 쿠폰 발급 프로세스 (MPAY 쿠폰 신규 발급)
  + ![img_3.png](../../../assets/img/coupon-service/configureCouponIssuanceService_3.png)
+ 고객 프로모션 쿠폰 사용 프로세스
  + ![img_4.png](../../../assets/img/coupon-service/configureCouponIssuanceService_4.png)

## 광고 문자 전송 프로세스
+ 고객 결제 후 광고 문자 전송(CP 광고 문자 전송) 프로세스
  + ![img_5.png](../../../assets/img/coupon-service/configureCouponIssuanceService_5.png)
+ 멀티 벌크 광고 문자 전송(CP 광고 문자 전송) 프로세스
  + ![img_6.png](../../../assets/img/coupon-service/configureCouponIssuanceService_6.png)
+ CTN 광고 문자 전송 프로세스
  + ![img_7.png](../../../assets/img/coupon-service/configureCouponIssuanceService_7.png)

## 휴대폰 소액 결제 요청 처리 SEQUENCE DIAGRAM
+ ![img_8.png](../../../assets/img/coupon-service/configureCouponIssuanceService_8.png)

## 휴대폰 소액 결제 취소 요청 처리 SEQUENCE DIAGRAM
+ ![img_9.png](../../../assets/img/coupon-service/configureCouponIssuanceService_9.png)
