from django.urls import path
from . import views
app_name = 'data_server'
urlpatterns = [
    path('data/', views.get_random_samples, name='get_random_samples'),
    path('health/', views.health_check, name='health_check'),
]
