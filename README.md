# MultiTypeChatApp

MultiTypeChatApp, farklı türde sohbet mesajlarını tek bir zaman çizelgesinde göstermeyi amaçlayan küçük bir SwiftUI örnek uygulamasıdır. Projenin temel hedefi, **opaque type** kullanımı (`some View`) ve heterojen koleksiyonlarda **type erasure** ile tip güvenliğinin nasıl korunacağını göstermek; aynı zamanda farklı veri modellerini tek bir protokol üzerinden yönetebilmenin pratik yollarını sunmaktır.

## Güncel özellikler
- Metin, görsel, alıntı, sistem bildirimi ve etkileşimli widget mesajlarını aynı listede toplar.
- `ChatMessageDisplayable` protokolü her mesajın kendi SwiftUI görünümünü üretmesini sağlar, dış katman yalnızca ortak metadata'yı bilir.
- `MessageEnvelope` JSON içindeki `type` alanını okuyarak doğru modele yönlendirir, yeni tip eklemek için tek bir enum güncellemesi yeterlidir.
- Akış hissi için mesajlar `Task` içinde sırayla yüklenir, küçük gecikmeler ve animasyonlar eklenir.
- Görseller `AsyncImage` ile uzaktan yüklenir; hata ve yüklenme durumları kullanıcıya yansıtılır.

## Adım adım akış (ne yapıyor, neden yapıyor?)
1. **Giriş ve iskelet** – `MultiTypeChatAppApp` uygulamayı açar ve `MessageListView` ile bir gezinti yığını başlatır. Amaç: örneği minimum kabukla ayağa kaldırmak.
2. **Durum hazırlığı** – `MessageListView` `@State` ile mesaj listesini ve yükleme durumunu tutar. Amaç: SwiftUI'da basit state yönetimi ve animasyon tetikleyebilmek.
3. **Veri yükleme** – `onAppear` içinde `loadMessages()` çağrılır; her mesaj için `Task.sleep` kullanarak araya kısa gecikmeler eklenir. Amaç: gerçek zamanlı akış hissi ve animasyonlu ekleme örneği.
4. **JSON ayrıştırma** – `MockDataLoader.decodeMessages` örnek JSON'u `MessageEnvelope` aracılığıyla çözer, `MessageType` ayrıştırıcıyı kullanır. Amaç: tür ayrıştırma (discriminated union) mantığını göstermek.
5. **Görselleştirme** – Her öğe `MessageBubble` içinde avatar, kullanıcı adı ve saatle birlikte kendi `toView()` çıktısını üretir. Amaç: opaque view ile içerik detayını saklayıp ortak kabuğu paylaşmak.
6. **Etkileşim** – `WidgetMessageView` seçim yapılan butonları işler, seçilen metni anlık gösterir. Amaç: chat içindeki mini eylem bileşenlerini tanıtmak.

## Öne çıkan tipler ve dosyalar
- **`ContentView.swift`**: `MessageListView` ile zaman çizelgesini kurar, sıralı yüklemeyi ve başlıkları yönetir.
- **`ChatMessages.swift`**: `ChatMessageDisplayable`, `MessageEnvelope`, mesaj modelleri ve `MockDataLoader` burada yer alır.
- **`WidgetMessageView`**: Çoktan seçmeli butonlarla etkileşimli içerik örneği sunar.

## Öğrenme ve inceleme roadmap'i
- **Başlangıç: Protokoller ve opaque view'lar** – `ChatMessageDisplayable` ve `toView()` imzasını inceleyin; SwiftUI `some View` ve `AnyView` farkını hatırlayın.
- **Devam: Tür ayrıştırma** – `MessageEnvelope` ve `MessageType` enum'una bakarak JSON'dan modele akışı takip edin; yeni tip eklemek için gerekli dokunuşları not alın.
- **Görsel katman: Liste ve kabuk** – `MessageListView` ve `MessageBubble` içinde avatar/başlık render'ına bakın; animasyon ve `Task.sleep` kullanımıyla stream etkisini inceleyin.
- **Etkileşim: Widget mesajı** – `WidgetMessageView` içinde state yönetimini ve buton stillerini gözden geçirin; seçeneklerin boş geldiği senaryoda varsayılan seçeneğin nasıl üretildiğini görün.
- **Deney: Kendi tipinizi ekleyin** – Yeni bir mesaj modeli tanımlayıp `MessageType` ve `MessageEnvelope`'a ekleyin, `MockDataLoader.liveJSON` içinde örnek veriyle test edin.

## Çalıştırma
- Xcode 15+ ile projeyi açın (`MultiTypeChatApp.xcodeproj`).
- Hedef olarak **MultiTypeChatApp**'i seçip iOS simülatörde `Run` edin.
- SwiftUI Önizlemeleri için `ContentView.swift` içindeki `#Preview` bloğunu kullanarak yükleme simülasyonunu beklemeden hızlıca göz atın.

## Dosya yapısı (özet)
- `MultiTypeChatAppApp.swift`: Uygulama giriş noktası.
- `ContentView.swift`: Mesaj listesi ve yükleme akışı.
- `ChatMessages.swift`: Mesaj modelleri, protokol, JSON ayrıştırma ve örnek veri.
- `Assets.xcassets`: Uygulama ikonları ve renk varlıkları.

## İleri okuma
- [Swift Language Guide – Protocols](https://docs.swift.org/swift-book/LanguageGuide/Protocols.html)
- [SwiftUI – Type Erasure with AnyView](https://developer.apple.com/documentation/swiftui/anyview)
- [Opaque Types in Swift](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/opaque-types/)

Bu doküman, demo uygulamanın son halini ve öğrenme odaklı akışını hızlıca kavramak isteyenler için rehber niteliğindedir.
