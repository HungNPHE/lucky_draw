# Kiến Trúc Dự Án – Lì Xì May Mắn

Ứng dụng Flutter theo chủ đề Tết Nguyên Đán, gồm 4 tính năng: Vòng Quay, Lì Xì Gacha, Đua Thú, Pháo Hoa.

---

## Cấu Trúc Thư Mục

```
lib/
├── main.dart
├── core/
│   ├── constants/app_colors.dart
│   ├── theme/tet_theme.dart
│   └── utils/random_utils.dart
├── shared/
│   └── widgets/rule_dialog.dart
└── features/
    ├── lucky_draw/
    │   ├── data/
    │   │   ├── models/lucky_result.dart
    │   │   ├── repositories/lucky_draw_repository_impl.dart
    │   │   └── services/lucky_draw_service.dart
    │   ├── domain/
    │   │   └── lucky_draw_repository.dart        # Abstract interface
    │   └── presentation/
    │       ├── viewmodels/lucky_draw_viewmodel.dart
    │       ├── pages/lucky_draw_page.dart
    │       └── widgets/
    │           ├── lucky_wheel.dart
    │           ├── history_list.dart
    │           ├── named_value_input.dart
    │           ├── range_input_field.dart
    │           └── tag_input_field.dart
    ├── gacha/
    │   ├── data/
    │   │   ├── models/gacha_result.dart
    │   │   └── services/gacha_service.dart
    │   └── presentation/
    │       ├── pages/gacha_page.dart
    │       └── widgets/
    │           ├── gacha_envelope.dart
    │           ├── gacha_result_display.dart
    │           └── gacha_wheel.dart
    ├── animal_racing/
    │   ├── data/
    │   │   └── models/racer.dart
    │   └── presentation/
    │       ├── viewmodels/animal_racing_viewmodel.dart
    │       ├── pages/animal_racing_page.dart
    │       └── widgets/
    │           ├── animal_racer.dart
    │           ├── countdown_overlay.dart
    │           ├── racing_result.dart
    │           ├── racing_setup.dart
    │           ├── racing_track.dart
    │           └── trait_indicator.dart
    └── firework/
        ├── data/
        │   ├── models/firework_result.dart
        │   └── services/firework_service.dart
        └── presentation/
            ├── viewmodels/firework_viewmodel.dart
            ├── pages/firework_page.dart
            └── widgets/firework_launcher.dart
```

---

## Kiến Trúc

**Pattern**: Feature-first MVVM với Provider + ChangeNotifier

**Nguyên tắc**:
- Mỗi feature tự chứa đầy đủ `data/`, `domain/`, `presentation/`
- `core/` chứa những gì dùng chung toàn app (theme, utils)
- `shared/widgets/` chứa widget dùng chung giữa nhiều feature
- Cross-feature dependency đi qua import tường minh (không qua barrel files)

**State management**:
- `LuckyDrawViewModel`: Global provider (dùng chung cho cả `LuckyDrawPage` và `GachaPage`)
- `AnimalRacingViewModel`: Local `ChangeNotifierProvider` trong `AnimalRacingPage`
- `FireworkViewModel`: Local `ChangeNotifierProvider` trong `FireworkPage`

---

## Luồng Dữ Liệu

```
User Action
    ↓
ViewModel (ChangeNotifier)
    ↓
Service (business logic)
    ↓
Model (data object)
    ↓ (optional)
Repository (in-memory)
    ↓ notifyListeners()
View → Widget (animation + paint)
```
