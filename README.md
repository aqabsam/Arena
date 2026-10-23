# Game Arena

Game Arena is an offline Flutter party game. It includes the existing Bid Challenge and eight local two-player mini-games. Everything runs on one device; Bid Challenge coins are virtual only.

## Run

```sh
flutter pub get
flutter run
```

To build the Android install package:

```sh
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`.

## Game rules

Mini Games includes Tic-Tac-Toe, Rock Paper Scissors, Connect Four, Dots and Boxes, Memory Match, Number Duel, Quick Tap, and Stick Takeaway. Player names are set on the Mini Games screen. RPS and Number Duel use a private handover before the other player acts.

Bid Challenge rules:

- Pick a category, then choose 3–7 players per team or a custom team size from 2–12.
- Every player starts a match with 100 virtual coins.
- Each round, all players submit a bid. The highest bidder receives the item and only that winning bid is deducted.
- Equal bids are resolved in player setup order. A zero bid can win if all bids are zero.
- Team score is remaining coins plus 10 points for each item owned by a team member. Equal final team scores go to Team A.
- Play Again creates new player balances and item ownership for a fresh match.

## Local category data and portraits

Category and item records live in `assets/data/categories.json`. Each item has a stable ID, display name, category ID, enabled flag, and an optional predefined HTTPS image URL. Individual character images are not included in Flutter's asset bundle. The repository validates unique IDs and category assignments.

Edit icons on Schoolmates, Classmates, Teachers, Friends, and Custom Category let players change those item names for the current session.

See [IMAGE_COVERAGE.md](assets/data/IMAGE_COVERAGE.md) for image URL coverage.

## Manage remote character images

Character photos are not required to play and the app has no user photo-import flow. Pokémon entries with verified Pokédex matches use predefined HTTPS image URLs; the other characters display a name fallback until a maintainer can verify an appropriate image URL. Images show a loading indicator and fall back to the character name if loading fails. Flutter reuses images in its in-memory image cache while the app is running; images that have not been cached require internet access, and persistent offline image storage is not provided.

Background music and touch sound effects are bundled for offline playback and can be controlled independently from Settings. Audio assets and provenance notes are in [assets/audio/README.md](assets/audio/README.md); the supplied theme's reuse rights should be confirmed before redistribution.
