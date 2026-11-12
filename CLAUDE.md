# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Yumly is an offline French recipe app in Flutter (iOS/Android): no backend, no account. The catalog and photos ship with the build; favorites, the shopping list and checked items live in `shared_preferences`. The UI, code comments, docs and test names are in French; commit messages are in English (`feat: …`).

`README.md` holds the full setup, architecture rationale and known limitations. `docs/FORMAT_RECETTES.md` is the authoritative recipe JSON spec (fields, units, product categories, `ingredientId` conventions). Product spec: `assets/INITIAL_SPEC.md`.

## Commands

```bash
flutter pub get
flutter run                                   # default device
dart format .
flutter analyze                               # strict-casts, strict-raw-types, see analysis_options.yaml
flutter test                                  # unit + widget + test/integration (no device)
flutter test test/unit/catalog_parser_test.dart            # single file
flutter test test/widget/catalog_screen_test.dart --name "tri"   # single test by name
flutter test integration_test                 # same journey on a real device/emulator
flutter build apk --release
python3 tool/screenshots.py               # README screenshots from a plugged-in Android phone (see README)
```

## Architecture

- `lib/app/`: `router.dart` uses go_router `StatefulShellRoute` (4 tabs, each with its own stack; the recipe detail opens inside the current tab). Also holds the theme and `app_info.dart`, whose version string must stay in sync with `pubspec.yaml`.
- `lib/features/<feature>/{data,domain,presentation}`: `recipes`, `favorites`, `shopping_list`, `settings`. State is Riverpod 3 providers (`*_controller.dart`). Filtering, sorting, aggregation and formatting are pure functions in `domain/` and `core/formatting/`, tested without widgets.
- Catalog pipeline: `assets/data/recipes.json` → `recipe_catalog_loader.dart` → `catalog_parser.dart`. The parser validates against controlled values (`domain/controlled_values.dart`, `domain/unit.dart`) and returns the catalog plus warnings. A missing image becomes a placeholder and is logged as `[Yumly] Catalogue : …`.
- Shopping list: stores only `recipeId` + servings. Ingredients are recomputed from the catalog by `ingredient_aggregator.dart`, which merges by `ingredientId` and unit dimension, so the same ingredient in different dimensions (piece vs g) stays on separate lines. Checked items are keyed `ingredientId|dimension`; orphaned keys are pruned.
- Persistence (`core/storage/local_storage.dart`): each state is a separate versioned JSON envelope. Corrupt or unknown-version data resets only that state.
- Origin flags: `domain/origin_flags.dart` maps normalized origin adjectives to ISO country codes. A new `origin` value in the catalog needs an entry there, or it shows no flag.

## Adding or editing recipes

- Reuse existing `ingredientId`s, and keep `name` and `category` identical for a given `ingredientId` across recipes: the parser warns on mismatches, and `catalog_parser_test` requires zero warnings.
- Ids are `<slug>-<NNN>` with the next sequential number. New recipes use `"status": "a_tester"`, which puts them in the home page's « À tester » section. `"a_revoir"` marks a tested recipe the owner wasn't convinced by: it is left out of the home carousels.
- Photos go in `assets/recipes/<N>-<slug>.jpg`, where `N` is the recipe id number without leading zeros and `slug` the id without its number (`lasagnes-bolognaise-001` → `1-lasagnes-bolognaise.jpg`). They are JPEG, roughly 16:10, and referenced by `imageAsset`. No pubspec change is needed.
- The recipe count is hard-coded in tests. When adding or removing recipes, update `hasLength(N)` in `test/unit/catalog_parser_test.dart` and the « N recettes » / « Voir N recettes » strings in `test/widget/catalog_screen_test.dart`.
- `TODO_RECIPES.md` is the backlog of recipes to add. Remove an entry once it is added and update the section count.
- If a recipe needed a decision or leaves a doubt, add a line to `TODO_REVIEW.md` (see below).
- For HelloFresh sources, convert box containers ("1 paquet", "½ sachet"), house spice blends and labels with the equivalences in `docs/CONVERSIONS_HELLOFRESH.md`. Update that file with every HelloFresh recipe added or edited: add each new equivalence, add the recipe to the rows it reuses, and list under « À harmoniser » any conversion that contradicts an existing one.

## `TODO_REVIEW.md`

This is the list of decisions waiting for the owner's review. Data-entry choices are written down there instead of being made silently in the catalog.

- **Fonctionnalités**: app limitations found while entering recipes, such as the missing `servingsUnit`, units that don't merge in the shopping list, or rest/marinade time counted in the total duration.
- **Recettes**: one line per recipe that has something to review, in the form `- **Titre** — …`. A recipe with nothing to review gets no line. Lines are grouped by course in the same order as the app (Petit-déjeuner, Entrées / apéritif, Plats, Accompagnements, Desserts); a course with no lines has no heading. The legend:
  - **A**: a decision made during data entry, to be confirmed. Examples: converting "pots" to grams, substituting an ingredient, choosing the number of servings.
  - **?**: an ambiguity to settle. Examples: an unknown quantity, a missing source, a brand name, an ingredient whose units don't merge.
- When adding or editing a recipe that needs review, add or update its line. When the owner settles a point, apply it in `recipes.json` and remove it from the line. Once a recipe has no points left, remove its line.

## Tests

- `test/helpers/test_app.dart` builds the app with provider overrides. The clock is fixed to 2026-10-10, which matters for « De saison » assertions.
- `test/helpers/demo_catalog.dart` provides an 8-recipe demo catalog used only by tests. The shipped catalog is the personal one.
- `integration_test/journey.dart` is shared by `test/integration/journey_test.dart` (headless) and `integration_test/app_test.dart` (device).
