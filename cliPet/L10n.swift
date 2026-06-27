import Foundation

struct L10n {

    // MARK: - Supported languages

    enum Language: String, CaseIterable, Identifiable {
        case en, zh, hi, es, fr, ar
        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .en: return "English"
            case .zh: return "中文"
            case .hi: return "हिन्दी"
            case .es: return "Español"
            case .fr: return "Français"
            case .ar: return "العربية"
            }
        }

        var flag: String {
            switch self {
            case .en: return "🇺🇸"
            case .zh: return "🇨🇳"
            case .hi: return "🇮🇳"
            case .es: return "🇪🇸"
            case .fr: return "🇫🇷"
            case .ar: return "🇸🇦"
            }
        }
    }

    // MARK: - Strings

    let tabMyCat: String
    let tabSettings: String
    let sectionCoats: String
    let sectionCustomColors: String
    let sectionSize: String
    let colorFur: String
    let colorBelly: String
    let colorStripes: String
    let colorEyes: String
    let colorNose: String
    let labelSize: String
    let sectionMovement: String
    let labelSpeed: String
    let sectionBehavior: String
    let toggleMischief: String
    let toggleChaseCursor: String
    let sectionClipboard: String
    let keepItemsFmt: String   // printf format, %d = count
    let buttonReset: String
    let sectionLanguage: String
    let sectionStartup: String
    let toggleLaunchAtLogin: String
    let launchPromptTitle: String
    let launchPromptBody: String
    let launchEnable: String
    let launchLater: String
    let launchOpenSettings: String

    func keepItems(_ n: Int) -> String { String(format: keepItemsFmt, n) }

    // MARK: - Factory

    static func for_(_ lang: Language) -> L10n {
        switch lang {
        case .en:
            return L10n(
                tabMyCat: "MY CAT", tabSettings: "SETTINGS",
                sectionCoats: "Coats", sectionCustomColors: "Custom Colors",
                sectionSize: "Size",
                colorFur: "Fur", colorBelly: "Belly / paws",
                colorStripes: "Stripes / outline", colorEyes: "Eyes", colorNose: "Nose / ears",
                labelSize: "Size",
                sectionMovement: "Movement", labelSpeed: "Speed",
                sectionBehavior: "Behavior",
                toggleMischief: "Do mischief", toggleChaseCursor: "Chase cursor",
                sectionClipboard: "Clipboard", keepItemsFmt: "Keep %d items",
                buttonReset: "RESET", sectionLanguage: "Language",
                sectionStartup: "Startup",
                toggleLaunchAtLogin: "Launch at login",
                launchPromptTitle: "Launch cliPet at startup?",
                launchPromptBody: "Add cliPet to your login items so your pet is always there when you start your Mac. You can change this anytime in Settings.",
                launchEnable: "Add to startup",
                launchLater: "Not now",
                launchOpenSettings: "Open Login Items settings"
            )
        case .zh:
            return L10n(
                tabMyCat: "我的猫", tabSettings: "设置",
                sectionCoats: "外观", sectionCustomColors: "自定义颜色",
                sectionSize: "大小",
                colorFur: "毛色", colorBelly: "肚子 / 爪子",
                colorStripes: "条纹 / 轮廓", colorEyes: "眼睛", colorNose: "鼻子 / 耳朵",
                labelSize: "大小",
                sectionMovement: "移动", labelSpeed: "速度",
                sectionBehavior: "行为",
                toggleMischief: "调皮捣蛋", toggleChaseCursor: "追逐光标",
                sectionClipboard: "剪贴板", keepItemsFmt: "保留 %d 条记录",
                buttonReset: "重置", sectionLanguage: "语言",
                sectionStartup: "开机启动",
                toggleLaunchAtLogin: "登录时启动",
                launchPromptTitle: "开机时启动 cliPet？",
                launchPromptBody: "将 cliPet 添加到登录项，开机时宠物就会一直陪着你。可随时在设置中更改。",
                launchEnable: "添加到启动项",
                launchLater: "暂不",
                launchOpenSettings: "打开登录项设置"
            )
        case .hi:
            return L10n(
                tabMyCat: "मेरी बिल्ली", tabSettings: "सेटिंग्स",
                sectionCoats: "रंग-रूप", sectionCustomColors: "कस्टम रंग",
                sectionSize: "आकार",
                colorFur: "फर", colorBelly: "पेट / पंजे",
                colorStripes: "धारियाँ / आउटलाइन", colorEyes: "आँखें", colorNose: "नाक / कान",
                labelSize: "आकार",
                sectionMovement: "गति", labelSpeed: "रफ्तार",
                sectionBehavior: "व्यवहार",
                toggleMischief: "शरारत करना", toggleChaseCursor: "कर्सर का पीछा",
                sectionClipboard: "क्लिपबोर्ड", keepItemsFmt: "%d आइटम रखें",
                buttonReset: "रीसेट", sectionLanguage: "भाषा",
                sectionStartup: "स्टार्टअप",
                toggleLaunchAtLogin: "लॉगिन पर शुरू करें",
                launchPromptTitle: "स्टार्टअप पर cliPet शुरू करें?",
                launchPromptBody: "cliPet को अपने लॉगिन आइटम्स में जोड़ें ताकि Mac शुरू होते ही आपका पेट मौजूद रहे। इसे सेटिंग्स में कभी भी बदला जा सकता है।",
                launchEnable: "स्टार्टअप में जोड़ें",
                launchLater: "अभी नहीं",
                launchOpenSettings: "लॉगिन आइटम्स सेटिंग्स खोलें"
            )
        case .es:
            return L10n(
                tabMyCat: "MI GATO", tabSettings: "AJUSTES",
                sectionCoats: "Pelajes", sectionCustomColors: "Colores personalizados",
                sectionSize: "Tamaño",
                colorFur: "Pelaje", colorBelly: "Vientre / patas",
                colorStripes: "Rayas / contorno", colorEyes: "Ojos", colorNose: "Nariz / orejas",
                labelSize: "Tamaño",
                sectionMovement: "Movimiento", labelSpeed: "Velocidad",
                sectionBehavior: "Comportamiento",
                toggleMischief: "Hacer travesuras", toggleChaseCursor: "Perseguir cursor",
                sectionClipboard: "Portapapeles", keepItemsFmt: "Guardar %d elementos",
                buttonReset: "RESTABLECER", sectionLanguage: "Idioma",
                sectionStartup: "Inicio",
                toggleLaunchAtLogin: "Abrir al iniciar sesión",
                launchPromptTitle: "¿Abrir cliPet al inicio?",
                launchPromptBody: "Añade cliPet a tus elementos de inicio para tener a tu mascota siempre al arrancar el Mac. Puedes cambiarlo cuando quieras en Ajustes.",
                launchEnable: "Añadir al inicio",
                launchLater: "Ahora no",
                launchOpenSettings: "Abrir Elementos de inicio"
            )
        case .fr:
            return L10n(
                tabMyCat: "MON CHAT", tabSettings: "RÉGLAGES",
                sectionCoats: "Robes", sectionCustomColors: "Couleurs perso",
                sectionSize: "Taille",
                colorFur: "Pelage", colorBelly: "Ventre / pattes",
                colorStripes: "Rayures / contour", colorEyes: "Yeux", colorNose: "Nez / oreilles",
                labelSize: "Taille",
                sectionMovement: "Mouvement", labelSpeed: "Vitesse",
                sectionBehavior: "Comportement",
                toggleMischief: "Faire des bêtises", toggleChaseCursor: "Poursuivre le curseur",
                sectionClipboard: "Presse-papiers", keepItemsFmt: "Garder %d éléments",
                buttonReset: "RÉINITIALISER", sectionLanguage: "Langue",
                sectionStartup: "Démarrage",
                toggleLaunchAtLogin: "Lancer au démarrage",
                launchPromptTitle: "Lancer cliPet au démarrage ?",
                launchPromptBody: "Ajoutez cliPet à vos éléments d'ouverture pour retrouver votre compagnon dès le démarrage du Mac. Modifiable à tout moment dans les Réglages.",
                launchEnable: "Ajouter au démarrage",
                launchLater: "Plus tard",
                launchOpenSettings: "Ouvrir les Éléments d'ouverture"
            )
        case .ar:
            return L10n(
                tabMyCat: "قطتي", tabSettings: "الإعدادات",
                sectionCoats: "المظهر", sectionCustomColors: "ألوان مخصصة",
                sectionSize: "الحجم",
                colorFur: "الفراء", colorBelly: "البطن / المخالب",
                colorStripes: "الخطوط / المحيط", colorEyes: "العيون", colorNose: "الأنف / الأذنان",
                labelSize: "الحجم",
                sectionMovement: "الحركة", labelSpeed: "السرعة",
                sectionBehavior: "السلوك",
                toggleMischief: "المشاغبة", toggleChaseCursor: "ملاحقة المؤشر",
                sectionClipboard: "الحافظة", keepItemsFmt: "احتفظ بـ %d عناصر",
                buttonReset: "إعادة ضبط", sectionLanguage: "اللغة",
                sectionStartup: "بدء التشغيل",
                toggleLaunchAtLogin: "التشغيل عند تسجيل الدخول",
                launchPromptTitle: "تشغيل cliPet عند بدء التشغيل؟",
                launchPromptBody: "أضف cliPet إلى عناصر تسجيل الدخول ليكون رفيقك حاضرًا دائمًا عند تشغيل الـ Mac. يمكنك تغيير ذلك في أي وقت من الإعدادات.",
                launchEnable: "إضافة إلى بدء التشغيل",
                launchLater: "ليس الآن",
                launchOpenSettings: "فتح إعدادات عناصر تسجيل الدخول"
            )
        }
    }
}
