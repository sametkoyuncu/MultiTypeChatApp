# MultiTypeChatApp

MultiTypeChatApp, farklı türde sohbet mesajlarını tek bir zaman çizelgesinde göstermeyi amaçlayan küçük bir SwiftUI örnek uygulamasıdır. Projenin temel hedefi, **opaque type** (SwiftUI `some View` kullanımı) ve **associated type** benzeri esnekliğin nasıl sağlanabileceğini göstermek; aynı zamanda farklı veri modellerini tek bir protokolden geçirerek tip güvenliğini korumaktır.

## Amaç ve kapsam
- Metin, görsel, alıntı, sistem bildirimi ve etkileşimli widget gibi birden çok mesaj tipini tek bir listede göstermek.
- `ChatMessageDisplayable` protokolü üzerinden her mesajın kendi görünümünü üretmesini sağlayarak çağıran tarafın ayrıntıları bilmesine gerek bırakmamak.
- `MessageEnvelope` ile JSON içeriğindeki `type` alanını okuyup ilgili modele yönlendiren basit bir ayrıştırma örneği sunmak.
- SwiftUI `View` türlerini `AnyView` ile gizleyerek **opaque** yaklaşımı güçlendirmek ve heterojen koleksiyonlar içinde çalışabilmek.

## Öne çıkan tipler
- **`ChatMessageDisplayable`**: Her mesajın `toView()` ile kendi SwiftUI görünümünü döndürdüğü protokol. Heterojen dizilerde kullanılmak üzere `Identifiable` uyumu da içerir.
- **`MessageEnvelope`**: JSON içindeki `type` ayırt edicisini okuyarak ilgili modele çeviren sarmalayıcı. Yeni mesaj tipleri eklenirken bu enum’a yeni bir durum eklemek yeterlidir.
- **Mesaj modelleri**: `TextMessage`, `ImageMessage`, `WidgetMessage`, `SystemMessage`, `QuoteMessage` yapıları, hem `Decodable` hem `ChatMessageDisplayable` uyumludur ve kendi görünümlerini üretirler.
- **`WidgetMessageView`**: Buton tabanlı etkileşim sağlayan küçük bir bileşen; SwiftUI içinde state yönetimini gösterir.

## Uygulama akışı
1. **Giriş noktası**: `MultiTypeChatAppApp` içinde `MessageListView` açılır.
2. **Mesaj yükleme**: `MessageListView` `onAppear` ile `loadMessages()` çağırır, yapay gecikme ekleyerek gerçek zamanlı akış hissi verir.
3. **JSON ayrıştırma**: `MockDataLoader` örnek JSON’u `MessageEnvelope` üzerinden çözüp `[any ChatMessageDisplayable]` dizisine dönüştürür.
4. **Görüntüleme**: `ForEach` içinde her mesaj `toView()` çağrısıyla kendi SwiftUI bileşenine dönüşür; liste içinde hangi tür olduğu bilinmez.

## Ne zaman kullanılır?
- Heterojen veri modellerini tek bir liste veya koleksiyonda göstermek istediğinizde.
- Arayüzü belirli alt türlere göre ayrı ayrı şekillendirmeniz gerektiğinde, ancak çağıran katmanın bu ayrıntıları bilmesini istemediğinizde.
- SwiftUI ile **opaque type** ve **type erasure** (ör. `AnyView`) konularını deneyerek öğrenmek istediğinizde.

## Yeni mesaj tipleri ekleme
1. `ChatMessageDisplayable` ve `Decodable` protokollerine uyan yeni bir struct yazın.
2. `MessageType` enum’una yeni bir durum ekleyin.
3. `MessageEnvelope.init(from:)` içindeki `switch` ifadesine yeni durum için ayrıştırma ekleyin.
4. `MockDataLoader.liveJSON` içine örnek bir kayıt ekleyerek hızlıca test edebilirsiniz.

## Çalıştırma
- Xcode 15+ ile projeyi açın (`MultiTypeChatApp.xcodeproj`).
- Hedef olarak **MultiTypeChatApp** seçin ve `Run` ile iOS simülatörde başlatın.
- SwiftUI Önizlemeleri için `ContentView.swift` içindeki `#Preview` bloğu kullanılabilir.

## Dosya yapısı
- `MultiTypeChatAppApp.swift`: Uygulama giriş noktası.
- `ContentView.swift`: Ana görünüm ve mesaj yükleme akışı.
- `ChatMessages.swift`: Mesaj modelleri, protokol, JSON ayrıştırma ve örnek veri.
- `Assets.xcassets`: Uygulama ikonları ve renk varlıkları.

## İleri okuma
- [Swift Language Guide – Protocols](https://docs.swift.org/swift-book/LanguageGuide/Protocols.html)
- [SwiftUI – Type Erasure with AnyView](https://developer.apple.com/documentation/swiftui/anyview)
- [Opaque Types in Swift](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/opaque-types/)

Bu doküman, projenin amacını ve yaklaşımını hızlıca kavramak isteyenler için kısa bir referans niteliğindedir.
