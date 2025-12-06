# MultiTypeChatApp

MultiTypeChatApp, farklı türde sohbet mesajlarını aynı zaman çizelgesinde göstermek için hazırlanmış küçük bir SwiftUI örnek projesidir. Amaç; **opaque type** (`some View`) ve heterojen koleksiyonlarda **type erasure** (ör. `AnyView`) gerektirmeden tip güvenliğini korumayı ve farklı veri modellerini tek protokol üzerinden yönetmeyi göstermektir.

## Neler içeriyor?
- **Mesaj tipleri:** Metin, görsel, alıntı, sistem bildirimi ve etkileşimli widget mesajlarını tek listede toplar.
- **Opaque görünüm üretimi:** `ChatMessageDisplayable` protokolü her mesajın kendi SwiftUI görünümünü `some View` ile döndürmesini zorunlu kılar; çağıran katman sadece ortak metadata'yı bilir.
- **Tür ayrıştırma (discriminated union):** `MessageEnvelope` JSON içindeki `type` alanını okuyup doğru modele yönlendirir; yeni tip eklemek yalnızca `MessageType` enum’una dokunmayı gerektirir.
- **Akış hissi:** `MessageListView` mesajları `Task` içinde sırayla ekler, kısa gecikmeler ve animasyonlarla canlı bir timeline sunar.
- **Uzaktan içerik:** Görseller `AsyncImage` ile yüklenir; yüklenme ve hata durumları kullanıcıya gösterilir.
- **Önizleme kolaylığı:** `MockDataLoader.loadPreviewMessages()` SwiftUI Preview’da hızlıca çalışır, gerçek yükleme akışını beklemeden tasarım görmenizi sağlar.

## Mimarinin hızlı turu
1. **Giriş noktası:** `MultiTypeChatAppApp` uygulamayı açar ve `MessageListView` ile gezinme yığını (navigation stack) başlatır.
2. **Durum (state) yönetimi:** `MessageListView` mesajları ve yükleme durumunu `@State` ile tutar; akış animasyonlarını tetikler.
3. **Veri yükleme:** `MockDataLoader.loadMessages()` statik JSON’u çözer, `MessageEnvelope` üzerinden doğru modele çevirir.
4. **Görselleştirme:** Her `ChatMessage` öğesi `MessageBubble` içinde avatar, ad ve saatle gösterilir; içerik view’i `message.toView()` ile opaque şekilde üretilir.
5. **Etkileşim:** `WidgetMessageView` seçenekli butonları işler ve seçimi anında balon içinde gösterir; boş gelen seçenekler için güvenli varsayılan üretir.

## Öne çıkan dosyalar
- `MultiTypeChatAppApp.swift`: SwiftUI uygulama girişi.
- `ContentView.swift`: Basit kabuk; doğrudan `MessageListView`’i barındırır.
- `Models/ChatMessageDisplayable.swift`: Opaque görünüm üreten protokol, `MessageType` enum’u ve `ChatMessage` wrapper’ı.
- `Models/*.swift`: Metin, görsel, alıntı, sistem ve widget mesaj modelleri.
- `Views/MessageListView.swift`: Zaman çizelgesini ve yükleme akışını yönetir.
- `Views/MessageBubble.swift`: Ortak kabuk (avatar, başlık, zaman) ve içerik kapsayıcısı.
- `Views/WidgetMessageView.swift`: Etkileşimli widget mesajını render eder.
- `Data/MockDataLoader.swift`: Canlı ve önizleme için statik JSON kaynakları ve ayrıştırma yardımcıları.

## Çalıştırma
1. Xcode 15+ ile `MultiTypeChatApp.xcodeproj` dosyasını açın.
2. Hedef olarak **MultiTypeChatApp**’i seçip iOS simülatörde **Run** edin.
3. SwiftUI Önizlemeleri için `ContentView.swift` içindeki `#Preview` bloğunu seçin; `MockDataLoader.loadPreviewMessages()` hızlıca örnek veri sağlar.

## Neyi incelemeli?
- **Opaque type kullanımı:** `ChatMessageDisplayable.toView()` imzası ve her modelin `some View` döndürmesi, `AnyView` olmadan tür güvenliğini nasıl koruduğunu gösterir.
- **Yeni tip ekleme:** `MessageType` enum’una yeni değer ekleyip ilgili model dosyasını yazmanız ve `MessageEnvelope` içinde case eklemeniz yeterlidir.
- **Akış animasyonu:** `MessageListView.loadMessages()` içindeki ardışık ekleme ve `withAnimation` kullanımı zaman çizelgesinin hissini belirler.

Bu doküman, projenin güncel halini özetler ve özellikle opaque SwiftUI görünümleriyle çoklu mesaj tiplerini yönetmek isteyen geliştiriciler için hızlı rehber sağlar.
