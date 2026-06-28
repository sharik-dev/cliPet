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
    let sectionSkins: String
    let buttonOpenEditor: String
    let sectionCoats: String
    let sectionCustomColors: String
    let sectionSize: String
    let colorFur: String
    let colorBelly: String
    let colorStripes: String
    let colorEyes: String
    let colorNose: String
    let colorOutline: String
    let labelSize: String
    let sectionMovement: String
    let labelSpeed: String
    let sectionBehavior: String
    let toggleMischief: String
    let toggleChaseCursor: String
    let toggleToy: String
    let sectionClipboard: String
    let keepItemsFmt: String   // printf format, %d = count
    let buttonReset: String
    let sectionLanguage: String
    let sectionStartup: String
    let toggleLaunchAtLogin: String
    let toggleAutoUpdate: String
    let launchPromptTitle: String
    let launchPromptBody: String
    let launchEnable: String
    let launchLater: String
    let launchOpenSettings: String

    // Clipboard panel + folders
    let clipTitle: String
    let clipSearchPlaceholder: String
    let clipClearHelp: String
    let clipEmpty: String
    let clipNoResults: String
    let historyTab: String
    let foldersTitle: String
    let newFolderPlaceholder: String
    let folderEmpty: String
    let saveToFolder: String
    let noFoldersYet: String
    let skinActive: String
    let clearHistory: String
    let clearHistoryTitle: String
    let clearHistoryMessage: String
    let clearConfirm: String
    let cancel: String
    let sectionNamedColors: String
    let colorNamePlaceholder: String
    let addFolder: String
    let saveVariant: String
    let deleteVariant: String
    let variantNamePlaceholder: String

    // Sprite editor
    let editorSectionFrame: String
    let editorPreviewIdle: String
    let editorPreviewWalk: String
    let editorPreviewSit: String
    let editorSectionColors: String
    let editorAddColor: String
    let editorSectionImport: String
    let editorImportImage: String
    let editorBgToleranceFmt: String   // %d = value
    let editorBgToleranceHelp: String
    let editorSectionActions: String
    let editorUndo: String
    let editorRedo: String
    let editorAssociate: String
    let editorClearFrame: String
    let editorResetAll: String
    let editorAutoSave: String
    let editorEraser: String
    let editorCopyToFmt: String        // %@ = frame name
    let editorSelectAll: String
    let editorSelectNone: String
    let editorApplyFmt: String         // %d = count

    // Skin manager
    let skinManagerTitle: String
    let skinRescan: String
    let skinBuiltin: String
    let skinCustom: String
    let skinOpenFolder: String
    let skinDropHint: String
    let skinRename: String

    // App menu
    let menuClipboard: String
    let menuHidePet: String
    let menuShowPet: String
    let menuSettings: String
    let menuClearHistory: String
    let menuSkinManager: String
    let menuEditor: String
    let menuCheckUpdates: String
    let menuQuit: String
    let menuLicense: String

    // Licence / paywall
    let licenseTitle: String
    let licenseTrialFmt: String      // %d = jours restants
    let licenseTrialEnded: String
    let licenseEnterKey: String
    let licenseKeyPlaceholder: String
    let licenseActivate: String
    let licenseChecking: String
    let licenseBuy: String
    let licenseActive: String
    let licenseInvalid: String
    let licenseContinueTrial: String
    let licenseQuit: String

    func keepItems(_ n: Int) -> String { String(format: keepItemsFmt, n) }
    func licenseTrial(_ n: Int) -> String { String(format: licenseTrialFmt, n) }
    func editorBgTolerance(_ n: Int) -> String { String(format: editorBgToleranceFmt, n) }
    func editorCopyTo(_ name: String) -> String { String(format: editorCopyToFmt, name) }
    func editorApply(_ n: Int) -> String { String(format: editorApplyFmt, n) }

    /// Nom par défaut (localisé) d'une couleur de base du chat par défaut.
    func defaultColorName(for ch: Character) -> String? {
        switch ch {
        case "g": return colorFur
        case "w": return colorBelly
        case "d": return colorStripes
        case "o": return colorEyes
        case "p": return colorNose
        default:  return nil
        }
    }

    // MARK: - Factory

    static func for_(_ lang: Language) -> L10n {
        switch lang {
        case .en:
            return L10n(
                tabMyCat: "MY PET", tabSettings: "SETTINGS",
                sectionSkins: "Skin", buttonOpenEditor: "🎨 OPEN PET EDITOR",
                sectionCoats: "Coats", sectionCustomColors: "Custom Colors",
                sectionSize: "Size",
                colorFur: "Fur", colorBelly: "Belly / paws",
                colorStripes: "Stripes / outline", colorEyes: "Eyes", colorNose: "Nose / ears",
                colorOutline: "Outline",
                labelSize: "Size",
                sectionMovement: "Movement", labelSpeed: "Speed",
                sectionBehavior: "Behavior",
                toggleMischief: "Do mischief", toggleChaseCursor: "Chase cursor",
                toggleToy: "Play with toy",
                sectionClipboard: "Clipboard", keepItemsFmt: "Keep %d items",
                buttonReset: "RESET", sectionLanguage: "Language",
                sectionStartup: "Startup",
                toggleLaunchAtLogin: "Launch at login",
                toggleAutoUpdate: "Check for updates automatically",
                launchPromptTitle: "Launch cliPet at startup?",
                launchPromptBody: "Add cliPet to your login items so your pet is always there when you start your Mac. You can change this anytime in Settings.",
                launchEnable: "Add to startup",
                launchLater: "Not now",
                launchOpenSettings: "Open Login Items settings",
                clipTitle: "CLIPBOARD", clipSearchPlaceholder: "search…",
                clipClearHelp: "Clear", clipEmpty: "nothing copied yet",
                clipNoResults: "no results", historyTab: "History",
                foldersTitle: "Folders", newFolderPlaceholder: "folder name",
                folderEmpty: "nothing saved here yet", saveToFolder: "Save to folder",
                noFoldersYet: "Create a folder first",
                skinActive: "● ACTIVE",
                clearHistory: "CLEAR HISTORY",
                clearHistoryTitle: "Clear clipboard history?",
                clearHistoryMessage: "This permanently deletes all copied items except saved favorites. This cannot be undone.",
                clearConfirm: "Clear", cancel: "Cancel",
                sectionNamedColors: "Named colors", colorNamePlaceholder: "name…",
                addFolder: "Add folder",
                saveVariant: "💾 SAVE VARIANT", deleteVariant: "Delete variant",
                variantNamePlaceholder: "variant name",
                editorSectionFrame: "Frame", editorPreviewIdle: "idle",
                editorPreviewWalk: "walk", editorPreviewSit: "sit",
                editorSectionColors: "Colors", editorAddColor: "+ ADD COLOR",
                editorSectionImport: "Image → sprite", editorImportImage: "🖼 IMPORT IMAGE",
                editorBgToleranceFmt: "BG tolerance: %d",
                editorBgToleranceHelp: "Detects the background (near-uniform zones connected to edges) and makes it transparent. ↑ tolerance = more background removed.",
                editorSectionActions: "Actions",
                editorUndo: "↶ UNDO", editorRedo: "↷ REDO",
                editorAssociate: "🔗 APPLY TO…",
                editorClearFrame: "CLEAR FRAME", editorResetAll: "RESET ALL",
                editorAutoSave: "💾 Auto-saved",
                editorEraser: "eraser",
                editorCopyToFmt: "Copy \"%@\" to:", editorSelectAll: "All",
                editorSelectNone: "None", editorApplyFmt: "APPLY (%d)",
                skinManagerTitle: "🎨 SKINS", skinRescan: "Rescan",
                skinBuiltin: "built-in", skinCustom: "custom",
                skinOpenFolder: "📁 OPEN SKINS FOLDER",
                skinDropHint: "Drop a .json here then « Rescan » to add a skin.",
                skinRename: "Rename…",
                menuClipboard: "Clipboard history", menuHidePet: "Hide pet",
                menuShowPet: "Show pet", menuSettings: "Settings…",
                menuClearHistory: "Clear history", menuSkinManager: "Skin manager…",
                menuEditor: "Sprite editor…", menuCheckUpdates: "Check for Updates…", menuQuit: "Quit cliPet",
                menuLicense: "Licence…",
                licenseTitle: "cliPet Pro",
                licenseTrialFmt: "%d days left in your free trial",
                licenseTrialEnded: "Your free trial has ended",
                licenseEnterKey: "Enter your licence key",
                licenseKeyPlaceholder: "XXXX-XXXX-XXXX-XXXX",
                licenseActivate: "Activate",
                licenseChecking: "Checking…",
                licenseBuy: "Buy a licence",
                licenseActive: "Licence active — thank you!",
                licenseInvalid: "Invalid licence key. Please check and try again.",
                licenseContinueTrial: "Continue trial",
                licenseQuit: "Quit cliPet"
            )
        case .zh:
            return L10n(
                tabMyCat: "我的宠物", tabSettings: "设置",
                sectionSkins: "皮肤", buttonOpenEditor: "🎨 打开宠物编辑器",
                sectionCoats: "外观", sectionCustomColors: "自定义颜色",
                sectionSize: "大小",
                colorFur: "毛色", colorBelly: "肚子 / 爪子",
                colorStripes: "条纹 / 轮廓", colorEyes: "眼睛", colorNose: "鼻子 / 耳朵",
                colorOutline: "轮廓",
                labelSize: "大小",
                sectionMovement: "移动", labelSpeed: "速度",
                sectionBehavior: "行为",
                toggleMischief: "调皮捣蛋", toggleChaseCursor: "追逐光标",
                toggleToy: "玩玩具",
                sectionClipboard: "剪贴板", keepItemsFmt: "保留 %d 条记录",
                buttonReset: "重置", sectionLanguage: "语言",
                sectionStartup: "开机启动",
                toggleLaunchAtLogin: "登录时启动",
                toggleAutoUpdate: "自动检查更新",
                launchPromptTitle: "开机时启动 cliPet？",
                launchPromptBody: "将 cliPet 添加到登录项，开机时宠物就会一直陪着你。可随时在设置中更改。",
                launchEnable: "添加到启动项",
                launchLater: "暂不",
                launchOpenSettings: "打开登录项设置",
                clipTitle: "剪贴板", clipSearchPlaceholder: "搜索…",
                clipClearHelp: "清空", clipEmpty: "还没有复制任何内容",
                clipNoResults: "无结果", historyTab: "历史",
                foldersTitle: "文件夹", newFolderPlaceholder: "文件夹名称",
                folderEmpty: "这里还没有保存内容", saveToFolder: "保存到文件夹",
                noFoldersYet: "请先创建一个文件夹",
                skinActive: "● 使用中",
                clearHistory: "清空历史",
                clearHistoryTitle: "清空剪贴板历史？",
                clearHistoryMessage: "这将永久删除所有已复制的内容（已保存的收藏除外），且无法撤销。",
                clearConfirm: "清空", cancel: "取消",
                sectionNamedColors: "命名颜色", colorNamePlaceholder: "名称…",
                addFolder: "添加文件夹",
                saveVariant: "💾 保存变体", deleteVariant: "删除变体",
                variantNamePlaceholder: "变体名称",
                editorSectionFrame: "帧", editorPreviewIdle: "静止",
                editorPreviewWalk: "行走", editorPreviewSit: "坐下",
                editorSectionColors: "颜色", editorAddColor: "+ 添加颜色",
                editorSectionImport: "图像 → 精灵", editorImportImage: "🖼 导入图像",
                editorBgToleranceFmt: "背景容差：%d",
                editorBgToleranceHelp: "检测背景（连接到边缘的近似均匀区域）并将其变为透明。↑ 容差 = 去除更多背景。",
                editorSectionActions: "操作",
                editorUndo: "↶ 撤销", editorRedo: "↷ 重做",
                editorAssociate: "🔗 应用到…",
                editorClearFrame: "清除帧", editorResetAll: "全部重置",
                editorAutoSave: "💾 自动保存",
                editorEraser: "橡皮",
                editorCopyToFmt: "将「%@」复制到：", editorSelectAll: "全选",
                editorSelectNone: "取消全选", editorApplyFmt: "应用（%d）",
                skinManagerTitle: "🎨 皮肤", skinRescan: "重新扫描",
                skinBuiltin: "内置", skinCustom: "自定义",
                skinOpenFolder: "📁 打开皮肤文件夹",
                skinDropHint: "将 .json 文件拖放到此处，然后点击「重新扫描」添加皮肤。",
                skinRename: "重命名…",
                menuClipboard: "剪贴板历史", menuHidePet: "隐藏宠物",
                menuShowPet: "显示宠物", menuSettings: "设置…",
                menuClearHistory: "清空历史", menuSkinManager: "皮肤管理器…",
                menuEditor: "精灵编辑器…", menuCheckUpdates: "检查更新…", menuQuit: "退出 cliPet",
                menuLicense: "许可证…",
                licenseTitle: "cliPet Pro",
                licenseTrialFmt: "免费试用还剩 %d 天",
                licenseTrialEnded: "免费试用已结束",
                licenseEnterKey: "输入您的许可证密钥",
                licenseKeyPlaceholder: "XXXX-XXXX-XXXX-XXXX",
                licenseActivate: "激活",
                licenseChecking: "正在检查…",
                licenseBuy: "购买许可证",
                licenseActive: "许可证已激活 — 谢谢！",
                licenseInvalid: "许可证密钥无效，请检查后重试。",
                licenseContinueTrial: "继续试用",
                licenseQuit: "退出 cliPet"
            )
        case .hi:
            return L10n(
                tabMyCat: "मेरा पेट", tabSettings: "सेटिंग्स",
                sectionSkins: "स्किन", buttonOpenEditor: "🎨 पेट एडिटर खोलें",
                sectionCoats: "रंग-रूप", sectionCustomColors: "कस्टम रंग",
                sectionSize: "आकार",
                colorFur: "फर", colorBelly: "पेट / पंजे",
                colorStripes: "धारियाँ / आउटलाइन", colorEyes: "आँखें", colorNose: "नाक / कान",
                colorOutline: "आउटलाइन",
                labelSize: "आकार",
                sectionMovement: "गति", labelSpeed: "रफ्तार",
                sectionBehavior: "व्यवहार",
                toggleMischief: "शरारत करना", toggleChaseCursor: "कर्सर का पीछा",
                toggleToy: "खिलौने से खेलना",
                sectionClipboard: "क्लिपबोर्ड", keepItemsFmt: "%d आइटम रखें",
                buttonReset: "रीसेट", sectionLanguage: "भाषा",
                sectionStartup: "स्टार्टअप",
                toggleLaunchAtLogin: "लॉगिन पर शुरू करें",
                toggleAutoUpdate: "स्वतः अपडेट जाँचें",
                launchPromptTitle: "स्टार्टअप पर cliPet शुरू करें?",
                launchPromptBody: "cliPet को अपने लॉगिन आइटम्स में जोड़ें ताकि Mac शुरू होते ही आपका पेट मौजूद रहे। इसे सेटिंग्स में कभी भी बदला जा सकता है।",
                launchEnable: "स्टार्टअप में जोड़ें",
                launchLater: "अभी नहीं",
                launchOpenSettings: "लॉगिन आइटम्स सेटिंग्स खोलें",
                clipTitle: "क्लिपबोर्ड", clipSearchPlaceholder: "खोजें…",
                clipClearHelp: "साफ़ करें", clipEmpty: "अभी तक कुछ कॉपी नहीं हुआ",
                clipNoResults: "कोई परिणाम नहीं", historyTab: "इतिहास",
                foldersTitle: "फ़ोल्डर", newFolderPlaceholder: "फ़ोल्डर का नाम",
                folderEmpty: "यहाँ अभी तक कुछ सहेजा नहीं गया", saveToFolder: "फ़ोल्डर में सहेजें",
                noFoldersYet: "पहले एक फ़ोल्डर बनाएँ",
                skinActive: "● सक्रिय",
                clearHistory: "इतिहास साफ़ करें",
                clearHistoryTitle: "क्लिपबोर्ड इतिहास साफ़ करें?",
                clearHistoryMessage: "यह सभी कॉपी किए गए आइटम (सहेजे गए पसंदीदा छोड़कर) को स्थायी रूप से हटा देगा। इसे पूर्ववत नहीं किया जा सकता।",
                clearConfirm: "साफ़ करें", cancel: "रद्द करें",
                sectionNamedColors: "नामित रंग", colorNamePlaceholder: "नाम…",
                addFolder: "फ़ोल्डर जोड़ें",
                saveVariant: "💾 वैरिएंट सहेजें", deleteVariant: "वैरिएंट हटाएँ",
                variantNamePlaceholder: "वैरिएंट का नाम",
                editorSectionFrame: "फ्रेम", editorPreviewIdle: "विश्राम",
                editorPreviewWalk: "चलना", editorPreviewSit: "बैठना",
                editorSectionColors: "रंग", editorAddColor: "+ रंग जोड़ें",
                editorSectionImport: "छवि → स्प्राइट", editorImportImage: "🖼 छवि आयात करें",
                editorBgToleranceFmt: "पृष्ठभूमि सहनशीलता: %d",
                editorBgToleranceHelp: "पृष्ठभूमि (किनारों से जुड़े लगभग एकसमान क्षेत्र) का पता लगाता है और उसे पारदर्शी बनाता है। ↑ सहनशीलता = अधिक पृष्ठभूमि हटाई जाती है।",
                editorSectionActions: "क्रियाएँ",
                editorUndo: "↶ पूर्ववत", editorRedo: "↷ फिर करें",
                editorAssociate: "🔗 लागू करें…",
                editorClearFrame: "फ्रेम साफ़ करें", editorResetAll: "सब रीसेट करें",
                editorAutoSave: "💾 स्वतः-सहेजा",
                editorEraser: "रबड़",
                editorCopyToFmt: "« %@ » को कॉपी करें:", editorSelectAll: "सभी",
                editorSelectNone: "कोई नहीं", editorApplyFmt: "लागू करें (%d)",
                skinManagerTitle: "🎨 स्किन", skinRescan: "पुनः स्कैन",
                skinBuiltin: "बिल्ट-इन", skinCustom: "कस्टम",
                skinOpenFolder: "📁 स्किन फ़ोल्डर खोलें",
                skinDropHint: "स्किन जोड़ने के लिए यहाँ .json फ़ाइल डालें और « पुनः स्कैन » करें।",
                skinRename: "नाम बदलें…",
                menuClipboard: "क्लिपबोर्ड इतिहास", menuHidePet: "पेट छुपाएँ",
                menuShowPet: "पेट दिखाएँ", menuSettings: "सेटिंग्स…",
                menuClearHistory: "इतिहास साफ़ करें", menuSkinManager: "स्किन मैनेजर…",
                menuEditor: "स्प्राइट एडिटर…", menuCheckUpdates: "अपडेट जाँचें…", menuQuit: "cliPet बंद करें",
                menuLicense: "लाइसेंस…",
                licenseTitle: "cliPet Pro",
                licenseTrialFmt: "आपके मुफ़्त ट्रायल में %d दिन शेष",
                licenseTrialEnded: "आपका मुफ़्त ट्रायल समाप्त हो गया",
                licenseEnterKey: "अपनी लाइसेंस कुंजी दर्ज करें",
                licenseKeyPlaceholder: "XXXX-XXXX-XXXX-XXXX",
                licenseActivate: "सक्रिय करें",
                licenseChecking: "जाँच हो रही है…",
                licenseBuy: "लाइसेंस खरीदें",
                licenseActive: "लाइसेंस सक्रिय — धन्यवाद!",
                licenseInvalid: "अमान्य लाइसेंस कुंजी। कृपया जाँचें और पुनः प्रयास करें।",
                licenseContinueTrial: "ट्रायल जारी रखें",
                licenseQuit: "cliPet बंद करें"
            )
        case .es:
            return L10n(
                tabMyCat: "MI MASCOTA", tabSettings: "AJUSTES",
                sectionSkins: "Skin", buttonOpenEditor: "🎨 ABRIR EDITOR DE MASCOTA",
                sectionCoats: "Pelajes", sectionCustomColors: "Colores personalizados",
                sectionSize: "Tamaño",
                colorFur: "Pelaje", colorBelly: "Vientre / patas",
                colorStripes: "Rayas / contorno", colorEyes: "Ojos", colorNose: "Nariz / orejas",
                colorOutline: "Contorno",
                labelSize: "Tamaño",
                sectionMovement: "Movimiento", labelSpeed: "Velocidad",
                sectionBehavior: "Comportamiento",
                toggleMischief: "Hacer travesuras", toggleChaseCursor: "Perseguir cursor",
                toggleToy: "Jugar con el juguete",
                sectionClipboard: "Portapapeles", keepItemsFmt: "Guardar %d elementos",
                buttonReset: "RESTABLECER", sectionLanguage: "Idioma",
                sectionStartup: "Inicio",
                toggleLaunchAtLogin: "Abrir al iniciar sesión",
                toggleAutoUpdate: "Buscar actualizaciones automáticamente",
                launchPromptTitle: "¿Abrir cliPet al inicio?",
                launchPromptBody: "Añade cliPet a tus elementos de inicio para tener a tu mascota siempre al arrancar el Mac. Puedes cambiarlo cuando quieras en Ajustes.",
                launchEnable: "Añadir al inicio",
                launchLater: "Ahora no",
                launchOpenSettings: "Abrir Elementos de inicio",
                clipTitle: "PORTAPAPELES", clipSearchPlaceholder: "buscar…",
                clipClearHelp: "Vaciar", clipEmpty: "nada copiado todavía",
                clipNoResults: "sin resultados", historyTab: "Historial",
                foldersTitle: "Carpetas", newFolderPlaceholder: "nombre de carpeta",
                folderEmpty: "nada guardado aquí todavía", saveToFolder: "Guardar en carpeta",
                noFoldersYet: "Crea una carpeta primero",
                skinActive: "● ACTIVO",
                clearHistory: "BORRAR HISTORIAL",
                clearHistoryTitle: "¿Borrar el historial del portapapeles?",
                clearHistoryMessage: "Esto elimina permanentemente todos los elementos copiados excepto los favoritos guardados. No se puede deshacer.",
                clearConfirm: "Borrar", cancel: "Cancelar",
                sectionNamedColors: "Colores con nombre", colorNamePlaceholder: "nombre…",
                addFolder: "Añadir carpeta",
                saveVariant: "💾 GUARDAR VARIANTE", deleteVariant: "Eliminar variante",
                variantNamePlaceholder: "nombre de variante",
                editorSectionFrame: "Frame", editorPreviewIdle: "quieto",
                editorPreviewWalk: "caminar", editorPreviewSit: "sentado",
                editorSectionColors: "Colores", editorAddColor: "+ AÑADIR COLOR",
                editorSectionImport: "Imagen → sprite", editorImportImage: "🖼 IMPORTAR IMAGEN",
                editorBgToleranceFmt: "Tolerancia fondo: %d",
                editorBgToleranceHelp: "Detecta el fondo (zonas casi uniformes conectadas a los bordes) y lo hace transparente. ↑ tolerancia = más fondo eliminado.",
                editorSectionActions: "Acciones",
                editorUndo: "↶ DESHACER", editorRedo: "↷ REHACER",
                editorAssociate: "🔗 APLICAR A…",
                editorClearFrame: "LIMPIAR FRAME", editorResetAll: "RESTABLECER TODO",
                editorAutoSave: "💾 Guardado automático",
                editorEraser: "goma",
                editorCopyToFmt: "Copiar «%@» a:", editorSelectAll: "Todo",
                editorSelectNone: "Ninguno", editorApplyFmt: "APLICAR (%d)",
                skinManagerTitle: "🎨 SKINS", skinRescan: "Volver a escanear",
                skinBuiltin: "integrado", skinCustom: "personalizado",
                skinOpenFolder: "📁 ABRIR CARPETA DE SKINS",
                skinDropHint: "Suelta un .json aquí y pulsa « Volver a escanear » para añadir un skin.",
                skinRename: "Renombrar…",
                menuClipboard: "Historial del portapapeles", menuHidePet: "Ocultar mascota",
                menuShowPet: "Mostrar mascota", menuSettings: "Ajustes…",
                menuClearHistory: "Borrar historial", menuSkinManager: "Gestor de skins…",
                menuEditor: "Editor de sprite…", menuCheckUpdates: "Buscar actualizaciones…", menuQuit: "Salir de cliPet",
                menuLicense: "Licencia…",
                licenseTitle: "cliPet Pro",
                licenseTrialFmt: "Te quedan %d días de prueba gratuita",
                licenseTrialEnded: "Tu prueba gratuita ha terminado",
                licenseEnterKey: "Introduce tu clave de licencia",
                licenseKeyPlaceholder: "XXXX-XXXX-XXXX-XXXX",
                licenseActivate: "Activar",
                licenseChecking: "Comprobando…",
                licenseBuy: "Comprar una licencia",
                licenseActive: "Licencia activa — ¡gracias!",
                licenseInvalid: "Clave de licencia no válida. Compruébala e inténtalo de nuevo.",
                licenseContinueTrial: "Continuar prueba",
                licenseQuit: "Salir de cliPet"
            )
        case .fr:
            return L10n(
                tabMyCat: "MON PET", tabSettings: "RÉGLAGES",
                sectionSkins: "Skin", buttonOpenEditor: "🎨 OUVRIR L'ÉDITEUR DE PET",
                sectionCoats: "Robes", sectionCustomColors: "Couleurs perso",
                sectionSize: "Taille",
                colorFur: "Pelage", colorBelly: "Ventre / pattes",
                colorStripes: "Rayures / contour", colorEyes: "Yeux", colorNose: "Nez / oreilles",
                colorOutline: "Contour",
                labelSize: "Taille",
                sectionMovement: "Mouvement", labelSpeed: "Vitesse",
                sectionBehavior: "Comportement",
                toggleMischief: "Faire des bêtises", toggleChaseCursor: "Poursuivre le curseur",
                toggleToy: "Jouer avec le jouet",
                sectionClipboard: "Presse-papiers", keepItemsFmt: "Garder %d éléments",
                buttonReset: "RÉINITIALISER", sectionLanguage: "Langue",
                sectionStartup: "Démarrage",
                toggleLaunchAtLogin: "Lancer au démarrage",
                toggleAutoUpdate: "Rechercher les mises à jour automatiquement",
                launchPromptTitle: "Lancer cliPet au démarrage ?",
                launchPromptBody: "Ajoutez cliPet à vos éléments d'ouverture pour retrouver votre compagnon dès le démarrage du Mac. Modifiable à tout moment dans les Réglages.",
                launchEnable: "Ajouter au démarrage",
                launchLater: "Plus tard",
                launchOpenSettings: "Ouvrir les Éléments d'ouverture",
                clipTitle: "PRESSE-PAPIERS", clipSearchPlaceholder: "rechercher…",
                clipClearHelp: "Vider", clipEmpty: "rien copié pour l'instant",
                clipNoResults: "aucun résultat", historyTab: "Historique",
                foldersTitle: "Dossiers", newFolderPlaceholder: "nom du dossier",
                folderEmpty: "rien de sauvegardé ici", saveToFolder: "Sauvegarder dans",
                noFoldersYet: "Créez d'abord un dossier",
                skinActive: "● ACTIF",
                clearHistory: "VIDER L'HISTORIQUE",
                clearHistoryTitle: "Vider l'historique du presse-papiers ?",
                clearHistoryMessage: "Cette action supprime définitivement tous les éléments copiés, sauf les favoris sauvegardés. Elle est irréversible.",
                clearConfirm: "Vider", cancel: "Annuler",
                sectionNamedColors: "Couleurs nommées", colorNamePlaceholder: "nom…",
                addFolder: "Ajouter le dossier",
                saveVariant: "💾 SAUVEGARDER LA VARIANTE", deleteVariant: "Supprimer la variante",
                variantNamePlaceholder: "nom de la variante",
                editorSectionFrame: "Frame", editorPreviewIdle: "inactif",
                editorPreviewWalk: "marche", editorPreviewSit: "assis",
                editorSectionColors: "Couleurs", editorAddColor: "+ AJOUTER UNE COULEUR",
                editorSectionImport: "Image → sprite", editorImportImage: "🖼 IMPORTER UNE IMAGE",
                editorBgToleranceFmt: "Tolérance fond : %d",
                editorBgToleranceHelp: "Détecte le fond (zones quasi-uniformes connectées aux bords) et le rend vide. ↑ tolérance = plus de fond effacé.",
                editorSectionActions: "Actions",
                editorUndo: "↶ ANNULER", editorRedo: "↷ RÉTABLIR",
                editorAssociate: "🔗 ASSOCIER…",
                editorClearFrame: "EFFACER LA FRAME", editorResetAll: "RÉINITIALISER TOUT",
                editorAutoSave: "💾 Sauvegarde automatique",
                editorEraser: "gomme",
                editorCopyToFmt: "Copier « %@ » vers :", editorSelectAll: "Tout",
                editorSelectNone: "Aucun", editorApplyFmt: "ASSOCIER (%d)",
                skinManagerTitle: "🎨 SKINS", skinRescan: "Rescanner",
                skinBuiltin: "intégré", skinCustom: "perso",
                skinOpenFolder: "📁 OUVRIR LE DOSSIER DES SKINS",
                skinDropHint: "Dépose un .json ici puis « Rescanner » pour ajouter un skin.",
                skinRename: "Renommer…",
                menuClipboard: "Historique du presse-papiers", menuHidePet: "Masquer le pet",
                menuShowPet: "Afficher le pet", menuSettings: "Réglages…",
                menuClearHistory: "Vider l'historique", menuSkinManager: "Gestionnaire de skins…",
                menuEditor: "Éditeur de sprite…", menuCheckUpdates: "Rechercher des mises à jour…", menuQuit: "Quitter cliPet",
                menuLicense: "Licence…",
                licenseTitle: "cliPet Pro",
                licenseTrialFmt: "Il vous reste %d jours d'essai gratuit",
                licenseTrialEnded: "Votre essai gratuit est terminé",
                licenseEnterKey: "Entrez votre clé de licence",
                licenseKeyPlaceholder: "XXXX-XXXX-XXXX-XXXX",
                licenseActivate: "Activer",
                licenseChecking: "Vérification…",
                licenseBuy: "Acheter une licence",
                licenseActive: "Licence active — merci !",
                licenseInvalid: "Clé de licence invalide. Vérifiez et réessayez.",
                licenseContinueTrial: "Continuer l'essai",
                licenseQuit: "Quitter cliPet"
            )
        case .ar:
            return L10n(
                tabMyCat: "حيواني", tabSettings: "الإعدادات",
                sectionSkins: "المظهر العام", buttonOpenEditor: "🎨 فتح محرر الحيوان",
                sectionCoats: "المظهر", sectionCustomColors: "ألوان مخصصة",
                sectionSize: "الحجم",
                colorFur: "الفراء", colorBelly: "البطن / المخالب",
                colorStripes: "الخطوط / المحيط", colorEyes: "العيون", colorNose: "الأنف / الأذنان",
                colorOutline: "المحيط",
                labelSize: "الحجم",
                sectionMovement: "الحركة", labelSpeed: "السرعة",
                sectionBehavior: "السلوك",
                toggleMischief: "المشاغبة", toggleChaseCursor: "ملاحقة المؤشر",
                toggleToy: "اللعب باللعبة",
                sectionClipboard: "الحافظة", keepItemsFmt: "احتفظ بـ %d عناصر",
                buttonReset: "إعادة ضبط", sectionLanguage: "اللغة",
                sectionStartup: "بدء التشغيل",
                toggleLaunchAtLogin: "التشغيل عند تسجيل الدخول",
                toggleAutoUpdate: "التحقق من التحديثات تلقائيًا",
                launchPromptTitle: "تشغيل cliPet عند بدء التشغيل؟",
                launchPromptBody: "أضف cliPet إلى عناصر تسجيل الدخول ليكون رفيقك حاضرًا دائمًا عند تشغيل الـ Mac. يمكنك تغيير ذلك في أي وقت من الإعدادات.",
                launchEnable: "إضافة إلى بدء التشغيل",
                launchLater: "ليس الآن",
                launchOpenSettings: "فتح إعدادات عناصر تسجيل الدخول",
                clipTitle: "الحافظة", clipSearchPlaceholder: "بحث…",
                clipClearHelp: "مسح", clipEmpty: "لم يتم نسخ أي شيء بعد",
                clipNoResults: "لا نتائج", historyTab: "السجل",
                foldersTitle: "المجلدات", newFolderPlaceholder: "اسم المجلد",
                folderEmpty: "لا شيء محفوظ هنا بعد", saveToFolder: "حفظ في مجلد",
                noFoldersYet: "أنشئ مجلدًا أولًا",
                skinActive: "● نشط",
                clearHistory: "مسح السجل",
                clearHistoryTitle: "مسح سجل الحافظة؟",
                clearHistoryMessage: "سيؤدي ذلك إلى حذف جميع العناصر المنسوخة نهائيًا، باستثناء المفضلات المحفوظة. لا يمكن التراجع عن هذا.",
                clearConfirm: "مسح", cancel: "إلغاء",
                sectionNamedColors: "ألوان مُسمّاة", colorNamePlaceholder: "الاسم…",
                addFolder: "إضافة مجلد",
                saveVariant: "💾 حفظ المتغيّر", deleteVariant: "حذف المتغيّر",
                variantNamePlaceholder: "اسم المتغيّر",
                editorSectionFrame: "إطار", editorPreviewIdle: "ساكن",
                editorPreviewWalk: "يمشي", editorPreviewSit: "جالس",
                editorSectionColors: "الألوان", editorAddColor: "+ إضافة لون",
                editorSectionImport: "صورة ← سبرايت", editorImportImage: "🖼 استيراد صورة",
                editorBgToleranceFmt: "تحمّل الخلفية: %d",
                editorBgToleranceHelp: "يكتشف الخلفية (مناطق شبه موحدة متصلة بالحواف) ويجعلها شفافة. ↑ التحمّل = إزالة المزيد من الخلفية.",
                editorSectionActions: "الإجراءات",
                editorUndo: "↶ تراجع", editorRedo: "↷ إعادة",
                editorAssociate: "🔗 تطبيق على…",
                editorClearFrame: "مسح الإطار", editorResetAll: "إعادة ضبط الكل",
                editorAutoSave: "💾 حفظ تلقائي",
                editorEraser: "ممحاة",
                editorCopyToFmt: "نسخ \"%@\" إلى:", editorSelectAll: "الكل",
                editorSelectNone: "لا شيء", editorApplyFmt: "تطبيق (%d)",
                skinManagerTitle: "🎨 السمات", skinRescan: "إعادة الفحص",
                skinBuiltin: "مدمج", skinCustom: "مخصص",
                skinOpenFolder: "📁 فتح مجلد السمات",
                skinDropHint: "أفلت ملف .json هنا ثم اضغط « إعادة الفحص » لإضافة سمة.",
                skinRename: "إعادة التسمية…",
                menuClipboard: "سجل الحافظة", menuHidePet: "إخفاء الحيوان",
                menuShowPet: "إظهار الحيوان", menuSettings: "الإعدادات…",
                menuClearHistory: "مسح السجل", menuSkinManager: "مدير السمات…",
                menuEditor: "محرر السبرايت…", menuCheckUpdates: "التحقق من التحديثات…", menuQuit: "إنهاء cliPet",
                menuLicense: "الترخيص…",
                licenseTitle: "cliPet Pro",
                licenseTrialFmt: "تبقى %d يومًا من الفترة التجريبية المجانية",
                licenseTrialEnded: "انتهت فترتك التجريبية المجانية",
                licenseEnterKey: "أدخل مفتاح الترخيص",
                licenseKeyPlaceholder: "XXXX-XXXX-XXXX-XXXX",
                licenseActivate: "تفعيل",
                licenseChecking: "جارٍ التحقق…",
                licenseBuy: "شراء ترخيص",
                licenseActive: "الترخيص مُفعَّل — شكرًا لك!",
                licenseInvalid: "مفتاح ترخيص غير صالح. يرجى التحقق والمحاولة مرة أخرى.",
                licenseContinueTrial: "متابعة التجربة",
                licenseQuit: "إنهاء cliPet"
            )
        }
    }
}
