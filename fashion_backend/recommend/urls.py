from django.urls import path
from .views import ClothingItemListCreateView, ScheduleListCreateView, RecommendationLogListView

urlpatterns = [
    path('clothes/', ClothingItemListCreateView.as_view(), name='clothes'),
    path('schedule/', ScheduleListCreateView.as_view(), name='schedule'),
    path('recommend-log/', RecommendationLogListView.as_view(), name='recommend_log'),
]
