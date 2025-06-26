from django.shortcuts import render

# Create your views here.
from rest_framework import generics
from .models import ClothingItem, Schedule, RecommendationLog
from .serializers import ClothingItemSerializer, ScheduleSerializer, RecommendationLogSerializer

# CRUD API 뷰를 위한 클래스 기반 뷰

# 의류 등록 및 목록 조회
class ClothingItemListCreateView(generics.ListCreateAPIView):
    queryset = ClothingItem.objects.all()
    serializer_class = ClothingItemSerializer

# 일정 등록 및 목록 조회
class ScheduleListCreateView(generics.ListCreateAPIView):
    queryset = Schedule.objects.all()
    serializer_class = ScheduleSerializer

# 추천 기록 조회 (읽기 전용)
class RecommendationLogListView(generics.ListAPIView):
    queryset = RecommendationLog.objects.all()
    serializer_class = RecommendationLogSerializer
