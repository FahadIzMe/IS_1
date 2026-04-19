"""
URL configuration for ids_api
"""
from django.urls import path
from . import views

urlpatterns = [
    path('health/', views.health_check, name='health_check'),
    path('statistics/', views.get_statistics, name='statistics'),
    path('predict/', views.predict, name='predict'),
    path('fetch-and-classify/', views.fetch_and_classify, name='fetch_and_classify'),
    path('attack-classes/', views.get_attack_classes, name='attack_classes'),
    path('recent-threats/', views.get_recent_threats, name='recent_threats'),
    path('reset-statistics/', views.reset_statistics, name='reset_statistics'),
    path('feature-names/', views.get_feature_names, name='feature_names'),
]
