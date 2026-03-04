"""API courses et auth."""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from .views import CourseViewSet, PartViewSet, BlockViewSet
from .auth_views import RegisterView, MeView

router = DefaultRouter()
router.register(r"courses", CourseViewSet, basename="course")
router.register(r"parts", PartViewSet, basename="part")
router.register(r"blocks", BlockViewSet, basename="block")

urlpatterns = [
    path("", include(router.urls)),
    path("auth/token/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("auth/token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("auth/register/", RegisterView.as_view(), name="register"),
    path("auth/me/", MeView.as_view(), name="me"),
]
