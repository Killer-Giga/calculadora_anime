# Mantener clases de Flutter para evitar que sean eliminadas u ofuscadas
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Mantener la MainActivity (ajusta el paquete si tu actividad principal está en otro paquete)
-keep class com.DDDevelopment.calculadora_mona_china.MainActivity { *; }

# Mantener las clases usadas por reflexión o anotaciones (ejemplo genérico)
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Evitar warnings sobre Kotlin y librerías comunes
-dontwarn kotlin.**
-dontwarn kotlinx.**
-dontwarn androidx.**

# Si usas librerías que usan serialización por reflexión, mantén estas reglas también:
# -keepclassmembers class * {
#     @com.google.gson.annotations.SerializedName <fields>;
# }

