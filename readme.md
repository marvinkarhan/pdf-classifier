# CPD Document Classifier

Dieses Projekt ist Teil des CPD-Kurses an der Hochschule Mannheim, in dessen Rahmen wir eine Flutter-Anwendung entwickelt haben.

Die Anwendung ermöglicht es den Nutzern, PDF-Dateien hochzuladen und Kategorien zu erstellen. Die Dateien werden mit Hilfe von OpenAI-Embeddings in die Kategorien eingeordnet. Darüber hinaus bietet die Anwendung eine Suchleiste, um alle Dateien zu durchsuchen, die eine Liste von Dokumenten zusammen mit ihren Genauigkeitsprozenten zurückgibt. Die unterstützten Plattformen für diese Anwendung sind Android und Windows.

Das Backend dieser Anwendung dient zum Speichern von Dateien und Kategorien in einer Vektordatenbank namens Weaviate, sodass Sie die Anwendung auf verschiedenen Geräten zur Verwaltung aller Dateien nutzen können. Die Vektordatenbank zusammen mit dem Python (Flask) Backend wird auf AWS bereitgestellt.

## Team
- Maximilian Broszio
- Marvin Karhan

## Erste Schritte

Um die Anwendung zu starten, führen Sie die folgenden Befehle in Ihrer Konsole aus:

```bash
cd app
flutter pub get
flutter run --release
```

## Tests durchführen

Um die Tests für die Flutter-Anwendung auszuführen, verwenden Sie die folgenden Befehle:

```bash
cd app
flutter test
```

## Entwicklung

Für die Einrichtung der Entwicklungsumgebung wird ein Docker Compose-Setup bereitgestellt, das das Python (Flask) Backend und die Weaviate-Datenbank enthält. Führen Sie die folgenden Befehle aus:

```bash
docker compose up -d
cd app
flutter pub get
flutter run --dart-define=env="dev"
```

## Zukunftsausblick

Für zukünftige Updates könnten einige potenzielle Funktionen hinzugefügt werden, wie die Hinzufügung von Optical Character Recognition (OCR), das Bilder in Text umwandeln kann. Diese Funktion könnte möglicherweise mit der Objekterkennung kombiniert werden, um eine detailliertere Beschreibung des Bildes zu erhalten. Der erzeugte Text kann verwendet werden, um ein Embedding zu generieren und in der Datenbank gespeichert werden. Dies würde die Verwendung von Bildern/Kamera zur Speicherung verschiedener Arten von Dateien ermöglichen.