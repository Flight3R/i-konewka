# i-konewka

![plot](./images/logo.png)

Innowacyjna konewka do nawadniania roślin, wyposażona w rozpoznawanie gatunku kwiatów poprzez kamerę, to nasz projekt. Dzięki zaawansowanej technologii IoT i rozpoznawania wizyjnego, ma on za zadanie zrewolucjonizować pielęgnację roślin, poprawiając ich zdrowie i wzrost w każdym gospodarstwie domowym. Zaoszczędź czas i stwórz optymalne warunki dla roślin, niezależnie od poziomu doświadczenia – dla ogrodników profesjonalistów i początkujących miłośników zieleni. Podstawowe funkcje obejmują: planowanie podlewania, rozpoznawanie gatunku kwiatów oraz dedykowaną aplikację mobilną.

Cały system składa się z aplikacji mobilnej, którą użytkownik instaluje na swoim smartfonie, urządzenia IoT zawierającego mikroprocesor oraz pompy umożliwiającej podawanie wody roślinom.

## Schemat projektu

![plot](./images/scheme.png)

## Dokumentacja

### Aplikacja mobilna

Aplikacja Flutter zaprojektowana w celu wsparcia urządzenia do podlewania poprzez dodanie kontroli i logiki. Użytkownik może utworzyć konto, w którym może przechowywać informacje o swoich roślinach, z różnymi atrybutami. Kamera zainstalowana w smartfonie może być używana do identyfikacji kwiatów użytkownika. Dzięki silnikowi identyfikacji roślin i oceny zdrowia dostarczanemu przez API PlantId.

### Połaczenie bluetooth

### API i-konewka

Część "backend" projektu i-konewka została wykonana z użyciem frameworka [Flask](https://flask.palletsprojects.com/). Został on wybrany ze względu na niewielki narzut oraz prostotę, która została postawiona postawiona ponad skomplikowanie innych rozwiązań wykorzystywanych w tej dziedzinie. Łatwa do użycia składnia Flaska pozoliła nam w stosunkowo krótkim czasie wytworzyć w pełni fnkcjonalną oraz poprawną w kontekście rozwoju aplikację. Wszystkie założone w projekcie funkcjonalności zostały zaimplementowane.

Lista endpoit'ów:

* ``/auth/register`` - rejestracja użytkowmika
* ``/auth/login`` - logowanie użytkownika
* ``/api/user_information`` - pobranie informacji o użytkowniku
* ``/api/add_flower`` - dodanie kwiatka do bazy danych
* ``/api/add_flower_photo`` - dodanie zdjęcia kwiatka
* ``/api/user_flowers`` -  pobranie informacji o kwiatach uzytkownika
* ``/api/flower_details`` - pobranie wszystkich informacji o kwiatku
* ``/api/add_watering`` - dodanie podlewania do bazy danych
* ``/api/get_last_waterings`` - pobranie ostatnich podlewań
* ``/api/delete_flower`` - usunięcie kwiatka z bazy danych
* ``/api/update_flower`` - zmiana informacji o kwiatku

### Uwierzytelnianie

Odpowiedzialne za uwierzytelnianie użytkownika endpointy `/auth/register` oraz `/auth/login` odpowiednio dodają oraz wyszukują użytkownika o podanych parametrach w celu umożliwienia mu korzystania z funkcjonalności aplikacji.

Po przesłaniu przez formularz logowania informacji, które znajdują dopasowanie w bazie danych, odsyłany jest token (JWT), który aplikacja mobilna zachowuje w celu dalszego korzystania z endpointów.

### Obsługa roślin

W zbiorze endpointów części backend zdefiniowano zakres tych odpowiedzialnych za operacje na roślinach użytkownika. Każda z nich zapewnia unikalną funkcjonalność, co daje przejżysty i łatwy w utrzymaniu kod.

Wszystkie niżej opisane pocedury wymagają zalogowanego użytkownika, który jest rozróżniany za pośrednictwem przesyłanego w nagłówku zapytania tokenu.

#### Wyświetlanie

W celach prezentacji danych w aplikacji zostały przygotowane endpointy `/api/user_information`, `/api/user_flowers`, `/api/flower_details` oraz `/api/get_last_waterings`. Zwracają one podstawowe informacje o użytkowniku, zapisanych przez niego roślinach, o ilości tych roślin, ich parametrach oraz wykonanych podlewaniach dowolnego z posiadanych kwiatów.

#### Dodawanie

Endpointy `/api/add_flower` oraz `/api/add_flower_photo`. Ich zadaniem jest zapewnienie możliwości dodawania roślin do bazy danych. W czasie pierwszego dodania rośliny następuje jej identyfikacja za pomocą usługi PlantId co zostało szerzej opisane w rozdziale [API PlantId](#api-plantid). Kolejno ustalane są szczegóły planu podlewania z wykorzystaniem ChatGPT (rozdział [API openAI](#api-openai)).

Po dodaniu kolejnego zdjęcia do już istniejącego kwiatka następuje jedynie identyfikacja jego zdrowia, którego nowa wartość wpisywana jest do bazy danych.

#### Podlewanie

Każdorazowe podlanie kwiatka musi być poprzedzone odnotowaniem tego w bazie danych poprzez wykonanie zapytania na endpoint `/api/add_flower_photo`. Rejestrowane są: identyfikator rośliny, moment podlania oraz ilość dozowanej wody.

#### Modyfikacja

Prezentowane rozwiązanie umożliwia, za pośrednictwem endpointu `/api/update_flower`, bardziej zaawansowanemu użytkownikowi modyfikację automatycznie proponowanych parametrów. Możliwa jest zmiana nazwy, harmonogramu podlewania czy ilości podawanej wody.

#### Usuwanie

Przygotowany endpoint `/api/delete_flower` pozwala na usunięcie niechcianej rośliny z bazy danych aplikacji. Usunięcie powoduje aktualizację pozostałych tabel w bazie danych, aby jej spójność nie została utracona (rozdział [Baza danych](#baza-danych)).

### API PlantId

Plant.id to zaawansowane narzędzie identyfikacji roślin, oferujące precyzyjne rozpoznawanie ponad 33 000 taksonów, obejmując rośliny doniczkowe, ogrodowe, drzewa, chwasty, grzyby i porosty z całego świata. Baza danych zawiera bogate informacje, obejmujące nazwę zwyczajową, krótki opis, klasyfikację oraz naukową (łacińską) nazwę dla każdej zidentyfikowanej rośliny.

Dodatkowo, Plant.id oferuje funkcję Oceny Zdrowia, która umożliwia użytkownikom rozpoznanie potencjalnych chorób roślin. Model wykrywa aż 90 różnych schorzeń, obejmujących szkodniki, choroby grzybowe i problemy związane z nadmiernym podlewaniem. Po zidentyfikowaniu rośliny, wystarczy kliknąć na ikonę choroby, aby uzyskać informacje na temat jej stanu zdrowia.

Potęga w dziedzinie uczenia maszynowego opiera się na najnowocześniejszych metodach, w tym niestandardowych głębokich sieciach neuronowych konwolucyjnych. Dzięki temu osiągamy doskonałe wyniki, szacując, że nazwę rośliny uda się poprawnie ustalić w 90% przypadków.

### API openAI

OpenAI API to interfejs programistyczny (API) udostępniany przez firmę OpenAI, umożliwiający deweloperom integrację zaawansowanych modeli językowych w swoich aplikacjach i usługach. Kluczowym elementem API jest użycie modelu GPT (Generative Pre-trained Transformer) do generowania tekstów na podstawie dostarczonych wejść.

W projekcie zostało wykorzystane do dopasowania ilości potrzebnej do podlania kwiatka oraz liczbie dni podlewań w tygodniu. Informacje ustalono na podstawie gatunku kwiatka.

Kod z implementacją znajduje się w pliku [chatgpt.py](./backend/src/chatgpt.py)

### Baza danych

![plot](./images/db_scheme.png)

W bazie danych znajduje się kilka kluczowych tabel. Pierwsza z nich to **USERS**, która przechowuje informacje o użytkownikach. Każdy użytkownik ma unikalny identyfikator (uid), nick, liczbę posiadanych kwiatów (nof_flowers), adres email, hasło, godzinę podlewania (watering_hour), oraz datę rozpoczęcia korzystania z systemu (start).

Drugą istotną tabelą jest **FLOWER_TYPES**, która definiuje różne typy kwiatów. Każdy typ ma swój unikalny identyfikator (ftid), nazwę, dodatkowe notatki (note), liczbę dni między podlewaniem (nof_watering_days), oraz ilość mililitrów wody potrzebną do podlania (ml_per_watering).

Kolejna tabela, **FLOWERS**, zawiera informacje o konkretnych kwiatach. Każdy kwiat ma swój unikalny identyfikator (fid), przypisanego użytkownika (uid), typ kwiatu (ftid), nazwę, stan zdrowia (health), datę dodania do systemu (start), ilość mililitrów wody na podlewanie (ml_per_watering), oraz informacje o dniach tygodnia, w których należy podlewać (monday, tuesday, ..., sunday).

Historia podlewania kwiatów przechowywana jest w tabeli **HISTORY**. Każde podlewanie ma swój unikalny identyfikator (hid), identyfikator kwiatu (fid), identyfikator użytkownika (uid), oraz datę i godzinę podlewania (watering).

Ostatnia tabela, **IMAGES**, zawiera informacje o obrazach przypisanych do konkretnych kwiatów. Każdy obraz ma swój unikalny identyfikator (iid), identyfikator kwiatu (fid), sam obraz w formie długiego tekstu (image), oraz datę i godzinę dodania obrazu (image_timestamp).

Wszystkie te tabele są ze sobą powiązane za pomocą kluczy obcych (foreign keys), co umożliwia skonstruowanie spójnej bazy danych, gdzie informacje o użytkownikach, typach kwiatów, konkretnych kwiatach, historii podlewania i obrazach są ze sobą powiązane.

Plik ze wstępną konfiguracją bazy danych: [init_schema.sql](./database/init_schema.sql)

### Docker

Po wytworzeniu oprogramowania dla aplikacji i-konewka koniecznym stało się udostępnienie jej dla klientów indywidualnych, którzy, za pośrednictwem aplikacji mobilnej, będą korzystac z funkcjonalności dla nich przygotowanych.

Do tego celu wybrana została pratforma [Docker](https://www.docker.com/). W ramach konfiguracji serwera aplikacji *i-konewka* przygotowany został plik komend generujący obrazy przeznaczone do działania w środowisku produkcyjnym. Instancje części backendowej zostały uruchomione z wykorzystaniem frameworka [Gunicorn](https://gunicorn.org/), oferującego w pełni funkcjonalny serwer produkcyjny; dopasowany pod wzdlęgami zarówno wydajności, jak i bezpieczeństwa, do potrzeb wprowadzanej na rynek aplikacji.

W podobny sposób przygotowano kontener obsługujący serwer bazodanowy, w oparciu o plik konfiguracyjny opisany w rozdziale [Baza Danych](#baza-danych). Z uwagi na skomplikowanie, wydajność, jak i bezpieczeństwo danych, zdecydowano się na utworzenie osobnej instancji bazy danych w środowisku *Docker.*

Na potrzeby komunikacji sieciowej *baza danych - backend*, z wykorzystaniem platformy *Docker,* została utworzona wirtualna sieć *ikonewa_network*. W tej sieci uruchomione zostały: kontener *backend*, kontener *mysql*.

W celu ekspozycji aplikacji na ruch użytkowników udostępnione zostało dodane przekierowanie portów umożliwiające połączenie tunelu cloudflare oraz kontenera z portem 60001.

### Cloudflare

Część backend aplikacji *i-konewka* otrzymała osobisty identyfikator w sieci internet za pośrednictwem wykupionej do tego celu domeny [ikonewka.panyre.pl](ikonewka.panyre.pl). Na potrzeby udostępnienia pracującej w środowisku *Docker* aplikacji został utworzony tunel z wykorzystaniem usugi [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/), wykorzystujący technikę przekierowania portów TCP na usługę docelową pracującą na porcie 60001. Dzięki tunelowaniu ruchu https, możliwe stało się upublicznienie API aplikacji *i-konewka* w sieci Internet pod podanym wyżej adresem, z użyciem bezpiecznej dla użytkownika końcowego, w pełni szyfrowanej komunikacji TLS.

### Fizyczne urządzenie

### Lista potrzebnego sprzętu

### Program zarządzający hardware

## Wykorzystane narzędzia

* [openAI](https://platform.openai.com/docs/introduction)
* [PlantId](https://plant.id/)
* [Flutter](https://flutter.dev/)
* [Flask](https://flask.palletsprojects.com/)

## Możliwy rozwój

Istnieje możliwość rozwoju innowacyjnej konewki do nawadniania roślin, poprzez wprowadzenie zaawansowanych funkcji. W planach jest integracja czujników wilgotności i nasłonecznienia, co otworzy drzwi do automatycznego dostosowywania planu podlewania do aktualnych warunków atmosferycznych. Aplikacja mobilna, będąca sercem systemu, umożliwi użytkownikom korzystanie z tej potężnej funkcji, monitorując poziom wilgotności gleby i intensywność nasłonecznienia. Choć to dopiero wizja, możliwość wprowadzenia tej funkcjonalności jest kamieniem milowym do uzyskania bardziej zaawansowanego i inteligentnego systemu podlewania, oferującego optymalną pielęgnację roślin, dostosowaną do ich unikalnych potrzeb i otoczenia.

## Podziękowania

Chcielibyśmy podziękować firmie [kindwise](https://www.kindwise.com/) za udostępnienie nam ich fantastycznego narzędzia [PlantId](https://plant.id/), które znakomicie wzbogaciło nasz projekt. Ich maszynowe rozpoznawanie kwiatów na podstawie obrazów pozwoliło nam poszerzyć zakres zastosowania naszej aplikacji.
