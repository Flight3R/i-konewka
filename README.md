# i-konewka

![plot](./images/logo.png)

Innowacyjna konewka do nawadniania roślin, wyposażona w rozpoznawanie gatunku kwiatów poprzez kamerę, to nasz projekt. Dzięki zaawansowanej technologii IoT i rozpoznawania wizyjnego, ma on za zadanie zrewolucjonizować pielęgnację roślin, poprawiając ich zdrowie i wzrost w każdym gospodarstwie domowym. Zaoszczędź czas i stwórz optymalne warunki dla roślin, niezależnie od poziomu doświadczenia – dla ogrodników profesjonalistów i początkujących miłośników zieleni. Podstawowe funkcje obejmują: planowanie podlewania, rozpoznawanie gatunku kwiatów oraz dedykowaną aplikację mobilną.

Cały system składa się z aplikacji mobilnej, którą użytkownik instaluje na swoim smartfonie, urządzenia IoT zawierającego mikroprocesor oraz pompy umożliwiającej podawanie wody roślinom.

## Schemat projektu

![plot](./images/scheme.png)

## Dokumentacja

### Aplikacja mobilna

Aplikacja Flutter zaprojektowana w celu wsparcia urządzenia do podlewania poprzez dodanie kontroli i logiki. Użytkownik może utworzyć konto, w którym może przechowywać informacje o swoich roślinach, z różnymi atrybutami. Kamera zainstalowana w smartfonie może być używana do identyfikacji kwiatów użytkownika. Dzięki silnikowi identyfikacji roślin i oceny zdrowia dostarczanemu przez API PlantId.

### Arduino

Używamy płytki Arduino ESP32 oraz biblioteki BluetoothSerial do połączeń Bluetooth. Pompa jest podłączona do Arduino na pinie 2.

#### Połączenie Bluetooth
Każde polecenie zawiera **head** i **value**. Żadne z nich nie powinno przekraczać długości 100 znaków. Są one odbierane jako zwykły tekst i oddzielone spacją. Istnieją dwie komendy, które można wykonać:
- connect - nie ma wartości i zwraca tekst "ok". Służy do upewnienia się, że jesteś podłączony do dobrego urządzenia.
- water - zawiera wartość całkowitą jako liczbę mililitrów, które zostaną przepompowane. Nie zwraca żadnej wartości 

#### Kod
Kod Arduino jest podzielony na trzy kluczowe segmenty: 
- setup - część kodu, która działa raz, po uruchomieniu Arduino. W naszym kodzie definiujemy pin pompy jako wyjście cyfrowe i otwieramy szeregowy Bluetooth.
- loop - ta część kodu działa w pętli po konfiguracji. W każdej iteracji sprawdzamy dostępność szeregowego Bluetooth i odbieramy polecenia. Główną częścią kodu jest nawadnianie, wywoływane poleceniem "water". Jego parametrem jest liczba mililitrów, przeliczana na liczbę milisekund pracy pompy przez stałą PUMP_CAPACITY = 0,0015 [ml/msec]. Wykonywanie nawadniania nie jest blokowane. Oznacza to, że gdy nawadnianie jest włączone, Arduino nie czeka na zakończenie nawadniania i może wykonywać inne czynności. Mierzy czas w każdej iteracji i odejmuje go od całkowitego czasu, przez jaki pompa powinna być włączona. Gdy czas ten dojdzie do zera, nawadnianie zostanie zatrzymane.

#### Klasa Command
Ta klasa służy do interpretowania poleceń wejściowych. Posiada kilka publicznych metod:
- read - odczytuje dane z portu szeregowego i dzieli je na dwie tablice znaków: nagłówek i wartość (każda o maksymalnej długości 100 znaków).
- is - pobiera tablicę znaków jako dane wejściowe i sprawdza, czy nagłówek jest równy tablicy wejściowej
- isVal - pobiera tablicę znaków jako dane wejściowe i sprawdza, czy wartość jest równa tablicy wejściowej
- valToInt - próbuje przekonwertować wartość z tablicy znaków na liczbę całkowitą 



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


### Kubernetes

Drugą możliwością uruchomienia aplikacji zostało wystawienie *deployment* za pośrednictwem [Kubernetes](https://kubernetes.io/). Do tego celu dopasowany został kod aplikacji: dane wrażliwe przeniesione zostały do elementu *secret* definiowanego poprzez plik `ikonewka_secrets.yaml`:
```
apiVersion: v1
kind: Secret
metadata:
    name: ikonewka-secret
type: Opaque
data:
    JWT_KEY: <key_in_base64>
    OPENAI_API_KEY: <key_in_base64>
    PLANTID_API_KEY: <key_in_base64>
    MYSQL_HOST: <host_in_base64>
    MYSQL_DATABASE: <database_in_base64>
    MYSQL_USER: <user_in_base64>
    MYSQL_PASSWORD: <password_in_base64>
```
Dodatkowo, zarówno dla części *backend* oraz *database* utworzono pliki .yaml definiujące potrzebne komponenty w *Kubernetes*.
Aby zrealizować wdrożenie wystarczy uruchomić w każdym z komponentów plik `Makefile` korzystając z polecenia `make prod`.

Po zbudowaniu, otagowaniu oraz wypchnięciu obrazu do repozytorium można uruchomić procesy w *Kubernetes*:

```
kubectl apply -f ikonewka_secrets.yaml
```

* backend
    ```
    kubectl apply -f ikonewka_backend_persistentvolume.yaml
    kubectl apply -f ikonewka_backend_persistentvolumeclaim.yaml
    kubectl apply -f ikonewka_backend_deployment.yaml
    ```

* database
    ```
    kubectl apply -f ikonewka_mysql_persistentvolume.yaml
    kubectl apply -f ikonewka_mysql_persistentvolumeclaim.yaml
    kubectl apply -f ikonewka_mysql_service.yaml
    kubectl apply -f ikonewka_mysql_deployment.yaml
    ```

### Cloudflare

Część backend aplikacji *i-konewka* otrzymała osobisty identyfikator w sieci internet za pośrednictwem wykupionej do tego celu domeny [ikonewka.panyre.pl](ikonewka.panyre.pl). Na potrzeby udostępnienia pracującej w środowisku *Docker* aplikacji został utworzony tunel z wykorzystaniem usugi [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/), wykorzystujący technikę przekierowania portów TCP na usługę docelową pracującą na porcie 60001. Dzięki tunelowaniu ruchu https, możliwe stało się upublicznienie API aplikacji *i-konewka* w sieci Internet pod podanym wyżej adresem, z użyciem bezpiecznej dla użytkownika końcowego, w pełni szyfrowanej komunikacji TLS.

### Fizyczne urządzenie

Budowa urządzenia zoptymalizowana została w celu możliwości szybkiego i taniego wydruku w technologii druku 3D. Model został podzielony na kilka mniejszych elementów dla uniknięcia przymusu druku supportów(materiału wsparciowego). Montaż jest prosty do wykonania przy pomocy kleju cyjanoakrylowego(tzw. kropelka/superglue). Konewka składa się z dwóch głównych części, górnej i dolnej, przymocowanej do siebie magnesami neodymowymi w celu łatwego demontażu akumulatora.
![plot](./images/print_simulation.png)
Model drukuje się przez niecałe 4 godziny, natomiast koszt filamentu to około 5zł. Do tego kosztu dodać należy wartość 4 magnesów neodymowych tj. około 2zł.

### Lista potrzebnego sprzętu

Do wykonania wykorzystane zostały następujące elementy elektroniczne:

1) ESP32-DEV
2) Moduł przekaźnika sterowany sygnałem 5V
3) Przetwornica STEP-UP 12V
4) Przetwornica STEP-DOWN 5V
5) Pompa perystaltyczna 12V
6) Akumulator Li-Pol 2S1P 7.4V

### Program zarządzający hardware

## Rozeznanie rynku

Podczas prac nad aplikacją zdecydowaliśmy się przeprowadzić pełną analizę rynku, która pozwoliła nam scharakteryzować potencjalnych klientów (persony) aplikacji oraz opinie ekspertów od opieki nad roślinami.
Zaczynając od początku zostały stworzone trzy różne persony, które mają różne wymagania oraz oczekiwania względem aplikacji.

![image](https://github.com/Flight3R/i-konewka/assets/56027574/13f91b5c-1287-4538-b70a-070a21f33ae2)
![image](https://github.com/Flight3R/i-konewka/assets/56027574/2b116a71-929b-442a-883c-241590a45e7c)
![image](https://github.com/Flight3R/i-konewka/assets/56027574/158f3d11-7ccd-4366-ac6f-55d7930a44ca)

Podczas pracy nad aplikacją staraliśmy się odpowiadać na żądania oraz obawy potencjalnych użytkowników względem aplikacji, aby byli skorzy ją wykorzystać do codziennego użycia. To doskonale pokazuje, że nasz projekt jest zdecydowanie skierowany na użytkownika końcowegom co jest niezwykle istotne w tworzeniu aplikacji mobilnych, które mają być łatwe oraz przyjemne w obsłudze.

Poniżej przedstawiamy parę kluczowych wniosków, które zostały wyciągnięte po szczegółowej ankiecie przeprowadzonej w trzech kwiaciarniach:

1) Kluczowa jest monitorowanie oraz analiza stanu rośliny, aby wykryć wszelkie nieprawidłowości już na samym początku problemów.
2) Niezwykle istotny jest fakt, że korzystanie z I-konewki pozwoliłoby zaoszczędzić czas, pieniądze oraz zmniejszyć stres zarówno u profesjonalistów jak i wśród domowych amatorów roślin.
3) W 99% przypadków problemem rośliny jest jej nieprawidłowa pielęgnacja czy podlewanie, a korzystanie z automatycznej i inteligentnej konewki pozwoliłoby zredukować liczbę takich przypadków przynajmniej kilkukrotnie.
4) Rozpoznawanie kwiatów pozwoliłoby natychmiastowo dowiedzieć się prawdziwej nazwy rośliny oraz jej wymagań, co umożliwiłoby szybszą reakcję na problemy niż powolne przeszukiwanie Internetu.

Przeprowadzono również ankietę Google, która została udostepniona na Facebooku i w kręgach znajomych, rodziny.

Prawie wszyscy ankietowani posiadają kwiaty w swoich domach, a co ciekawe, prawie 70% z nich uważa,
że ich wiedza na ten temat jest niewystarczająca. Najbardziej interesujące są odpowiedzi na pytania
takie jak "Jak dobrym opiekunem kwiatów jesteś?", gdzie ponad połowa ankietowanych udzieliła
odpowiedzi na poziomie 1 lub 2 na 5, oraz "Jaki jest stan Twojej wiedzy o kwiatach?", na które 41.2%
osób zaznaczyło 1/5. Tylko połowa odpowiedzi wskazywała na to, że kupujący szukają dodatkowych
informacji po zakupie, a co więcej, najczęściej robią to w internecie. Interesujące jest to, że 32.7%
ankietowanych na pytanie "Jak często podlewasz kwiaty?" odpowiedziało: "Kiedy mi się przypomni."
Ponad połowa odpowiedzi pokazuje, że sytuacje, w których potrzebna jest opieka nad kwiatami, wciąż
się zdarzają.

## Wykorzystane narzędzia

* [openAI](https://platform.openai.com/docs/introduction)
* [PlantId](https://plant.id/)
* [Flutter](https://flutter.dev/)
* [Flask](https://flask.palletsprojects.com/)

## Możliwy rozwój

Istnieje możliwość rozwoju innowacyjnej konewki do nawadniania roślin, poprzez wprowadzenie zaawansowanych funkcji. W planach jest integracja czujników wilgotności i nasłonecznienia, co otworzy drzwi do automatycznego dostosowywania planu podlewania do aktualnych warunków atmosferycznych. Aplikacja mobilna, będąca sercem systemu, umożliwi użytkownikom korzystanie z tej potężnej funkcji, monitorując poziom wilgotności gleby i intensywność nasłonecznienia. Choć to dopiero wizja, możliwość wprowadzenia tej funkcjonalności jest kamieniem milowym do uzyskania bardziej zaawansowanego i inteligentnego systemu podlewania, oferującego optymalną pielęgnację roślin, dostosowaną do ich unikalnych potrzeb i otoczenia.

## Podziękowania

Chcielibyśmy podziękować firmie [kindwise](https://www.kindwise.com/) za udostępnienie nam ich fantastycznego narzędzia [PlantId](https://plant.id/), które znakomicie wzbogaciło nasz projekt. Ich maszynowe rozpoznawanie kwiatów na podstawie obrazów pozwoliło nam poszerzyć zakres zastosowania naszej aplikacji.
