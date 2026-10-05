# Room (base interne de WorkManager) crée la classe générée par réflexion :
# garder son constructeur sans argument, retiré sinon par R8 en mode strict.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
