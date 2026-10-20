@echo off
echo ========================================================
echo   MENJALANKAN MICROSERVICE MACHINE LEARNING MAGANGIN
echo ========================================================
echo   Algoritma:
echo   1. Linear Regression     (Prediksi Uang Saku)
echo   2. Logistic Regression   (Prediksi Kelolosan Seleksi)
echo   3. Naive Bayes           (Klasifikasi Karir & Sentimen)
echo   4. Support Vector Machine (Matchmaking Kandidat)
echo ========================================================
echo.

python ml_backend/run_server.py
pause
