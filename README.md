  1. Ціль проєкту
“Ціль проєкту — реалізувати просту гру з фізикою, яка демонструє роботу з SpriteKit,
інтеграцію зі SwiftUI та застосування архітектурних підходів у iOS-розробці.”
	2.	🕹️ Ігровий процес
	•	Стріляй у кулі, щоб заробляти бали.
	•	Великі кулі розділяються на менші при влучанні.
	•	Збирай якомога більше очок, щоб побити свій рекорд.
	•	Всі рекорди зберігаються в таблиці High Scores.
	3.	📊 Особливості
	•	Реалізація фізики та колізій через SKPhysicsBody + bit masks.
	•	Звукові ефекти та музика (керуються у Settings).
	•	Збереження рекордів у UserDefaults.
	•	Адаптивний інтерфейс (працює на iPhone SE → iPhone Pro Max).
	•	Мінімум iOS 16.0, сумісність до iOS 26.0.
	4.	🛠️ Технології
	•	Swift 5.9
	•	SwiftUI
	•	SpriteKit
	•	AVFoundation
	•	UserDefaults

TestGame/
 ├── Managers/
 │   └── AudioManager.swift    // керування музикою та SFX
 ├── Resources/
 │   └── Sounds/               // аудіо-файли
 │   └── Assets/               // зображення, іконки
 |   └── gameTestLogo          // іконка аплікації 
 ├── Scenes/
 │   └── GameScene.swift       // основна сцена SpriteKit з фізикою та bit masks
 ├── Views/
 │   ├── MainMenuView.swift    // головне меню
 │   ├── ScoreRecordsView.swift// таблиця рекордів
 |   ├── GameContainerView     // обгортка для GameScene у SwiftUI
 │   └── SettingsView.swift    // налаштування (музика, звуки)
 └── TestGameApp.swift         // точка входу в застосунок

 ## 📸 Screenshots

### iPhone 17 Pro Max (iOS 26)
<img src="https://github.com/user-attachments/assets/a1ebafab-84ae-4a81-999c-d7f1131b05e1" alt="Main Menu" width="300"/>
<img src="https://github.com/user-attachments/assets/b36fdc38-6790-4f04-9364-93611894f79d" alt="Gameplay" width="300"/>
<img src="https://github.com/user-attachments/assets/d8159594-77ee-443d-a87b-3de3d837be37" alt="Game Over" width="300"/>

---

### iPhone SE (iOS 16.0)
<img src="https://github.com/user-attachments/assets/28c60c41-002a-47ff-870c-69ae508de16f" alt="Main Menu SE" width="220"/>
<img src="https://github.com/user-attachments/assets/112bc13e-0a6d-4cdc-9456-d333986185d6" alt="Gameplay SE" width="220"/>
<img src="https://github.com/user-attachments/assets/191b0c2c-32ef-4e94-8479-88cdb63b01ec" alt="Game Over SE" width="220"/>

