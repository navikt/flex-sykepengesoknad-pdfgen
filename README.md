# flex-sykepengesoknad-pdfgen

`flex-sykepengesoknad-pdfgen` er en applikasjon som genererer PDF-filer av utfylte søknader.
Disse PDF-filene blir brukt i Gosys og Altinn, og i all hovedsak er det kun
[`sykepengesoknad-arkivering-oppgave`](https://github.com/navikt/sykepengesoknad-arkivering-oppgave) og [`sykepengesoknad-altinn`](https://github.com/navikt/sykepengesoknad-altinn) som snakker med denne applikasjonen fra vår side.
Teknisk sett, gitt et ordentlig JSON-objekt kan hvem som helst generere en PDF.
De eksponterte endepunktene er ikke begrenset til `sykepengesoknad-arkivering-oppgave` og `sykepengesoknad-altinn`.


## Overordnet bilde av applikasjonen

Applikasjonen støtter kun `POST`-kall til spesifikke endepunkter. For bruk i teamet er dette endepunktet
`/api/v1/genpdf/syfosoknader/<soknadstype>`. Applikasjonen leter da etter `soknadstype.hbs` inne i
`templates/syfosoknader/`. Dette er en [Handlebars](https://handlebarsjs.com/)-malfil som brukes til å generere HTML
som deretter brukes for å generere en PDF. For effektiv bruk av applikasjonen må `POST`-kallet ha en JSON-payload
som har feltene som brukes i malen.

Ved lokal utvikling kan hjelpeskriptet `run_development.sh` kjøres. Det er forutsatt at maskinen du kjører det på
har Docker installert. I en typisk utviklingssituasjon vil man endre på malfiler i `templates` og mockdata i `data`,
effekten av endringer der kan ses ved å gjøre et GET-kall til URL-en som man i produksjon vil gjøre `POST`-kall til.

Når man har kjørt `run_development.sh` kan man for eksempel gå til
[http://localhost:8080/api/v1/genpdf/syfosoknader/arbeidstakere](http://localhost:8080/api/v1/genpdf/syfosoknader/arbeidstakere) for å se hva kombinasjonen av
`templates/syfosoknader/arbeidstakere.hbs` og `data/syfosoknader/arbeidstakere.json` resulterer i. Man trenger ikke å
restarte `run_development.sh` når man har gjort endringer, en enkel refresh av siden vil vise resultatet av endringene.


## Utvikling av maler

Det man burde være oppmerksom på ved utvikling av maler er at det fins en grunnmal
(`templates/syfosoknader/partials/base.hbs`) som er felles for alle søknadene. Det oppfordres til at endringer som
gjøres blir gjort generelt i grunnmalen.

I grunnmalen refereres det også til

* `templates/syfosoknader/partials/style.hbs`
    * Dette er en `<style>`-blokk med CSS som puttes inn i grunnmalen.
* `templates/syfosoknader/partials/spmpartial.hbs`
    * Dette er en såkalt [partial](https://handlebarsjs.com/partials.html), som håndterer spørsmål basert på
      spørsmålstype.

Generelt sett anbefales det å lese [Handlebars-dokumentasjonen](https://handlebars-draft.knappi.org/guide/),
med forbehold om at vi kanskje ikke kjører aller siste versjon.

## Referanse

I tillegg til Handlebars, har applikasjonen også flere hjelpefunksjoner som kan brukes i malene.

### iso_to_nor_date

Konverterer en datostring med tid til `DD.MM.YYYY`.

| Eksempel | JSON-data | Resultat |
| -------------- | --------- | -------- |
| `#!jinja {{ iso_to_nor_date min_datostring }}` |`#!json {"min_datostring": "2018-10-14T14:52:35"}` | 14.10.2018 |

### iso_to_date

Konverterer en datostring på ISO-format til `DD.MM.YYYY`.

| Eksempel | JSON-data | Resultat |
| -------------- | --------- | -------- |
| `#!jinja {{ iso_to_date min_datostring }}` |`#!json {"min_datostring": "2019-09-01"}` | 01.09.2019 |

### duration

Regner ut distansen (i dager) mellom to datoer. Den tidligste datoen må stå først for å få positivt resultat.

| Eksempel | JSON-data | Resultat |
| -------------- | --------- | -------- |
| `#!jinja {{ duration fom tom }} dager` |`#!json {"fom": "2018-10-10", "tom": "2018-10-12"}` | 2 dager |

### json_to_period

| Eksempel | JSON-data | Resultat |
| -------------- | --------- | -------- |
| `#!jinja {{ json_to_period verdi }}` |`#!json {"verdi": "{\"fom\":\"2019-09-05\",\"tom\":\"2019-09-06\"}"}` | 05.09.2019 - 06.09.2019 |

### insert_at

Setter inn et mellomrom i string ved indeks (0-indeksert).

| Eksempel | JSON-data | Resultat |
| -------------- | --------- | -------- |
| `#!jinja {{ insert_at fnr 6 }}` |`#!json {"fnr": "12345678901"}` | 123456 78901 |

### eq

Sjekker om en ting er lik en annen.

!!! warning "Vær oppmerksom"
Denne er ment å bruke som [block helper](https://handlebars-draft.knappi.org/guide/#block-helpers). Det vil si at
alt som er innenfor start- og slutt-tag blir vist dersom tilstanden i start-taggen blir evaluert som `#!js true`.

| Eksempel | JSON-data | Resultat |
| -------------- | --------- | -------- |
| `#!jinja {#eq status "VIS"}yes{/eq}` |`#!json {"status": "VIS"}` | yes |
| `#!jinja {#eq status "VIS"}yes{/eq}` |`#!json {"status": "IKKE VIS"}` |  |
| `#!jinja {#eq status "VIS"}yes{/eq}` |`#!json {"status": "noe helt annet"}` |  |

### not_eq

Sjekker om en ting ikke er lik en annen.

!!! warning "Vær oppmerksom"
Denne er ment å bruke som [block helper](https://handlebars-draft.knappi.org/guide/#block-helpers). Det vil si at
alt som er innenfor start- og slutt-tag blir vist dersom tilstanden i start-taggen blir evaluert som `#!js true`.

| Eksempel | JSON-data | Resultat |
| -------------- | --------- | -------- |
| `#!jinja {#not_eq status "VIS"}yes{/eq}` |`#!json {"status": "VIS"}` |  |
| `#!jinja {#not_eq status "VIS"}yes{/eq}` |`#!json {"status": "IKKE VIS"}` | yes |
| `#!jinja {#not_eq status "VIS"}yes{/eq}` |`#!json {"status": "noe helt annet"}` | yes |

### image

Setter inn et bilde fra `resources`-mappen.

!!! tip "Tips"
Det anbefales å legge en klasse på img-taggen som setter størrelsen på bildet ved rendering.

| Eksempel | JSON-data | Resultat |
| -------------- | --------- | -------- |
| `#!jinja <img src="{{ image "Checkboks.png" }}" />` | | ![Checkboks.png](/img/Checkboks.png) |

### resource

Setter inn en ressurs som UTF-8-kodet string fra `resources`-mappen. For eksempel kan dette brukes for å
inkludere en SVG-fil.

!!! tip "Tips"
Det anbefales å legge en klasse på svg-taggen som setter størrelsen på SVG-bildet ved rendering.

| Eksempel | JSON-data | Resultat |
| -------------- | --------- | -------- |
| `#!jinja <svg>{{ resource "checkbox.svg" }}</svg>` | | ![checkbox.svg](/img/checkbox.svg) |

### capitalize

Konverterer string til små bokstaver med stor Forbokstav.

| Eksempel | JSON-data | Resultat |
| -------------- | --------- | -------- |
| `#!jinja {{ capitalize min_string }}` |`#!json {"min_string": "HALLO"}` | Hallo |
| `#!jinja {{ capitalize min_string }}` |`#!json {"min_string": "hallo"}` | Hallo |
| `#!jinja {{ capitalize min_string }}` |`#!json {"min_string": "hallo"}` | Hallo |

### inc

Inkrementerer et tall med én.

| Eksempel | JSON-data | Resultat |
| -------------- | --------- | -------- |
| `#!jinja {{ inc mitt_tall }}` |`#!json {"mitt_tall": 1}` | 2 |

### formatComma

Bytter ut alle `.`-tegn i et tall til `,`.

| Eksempel | JSON-data | Resultat |
| -------------- | --------- | -------- |
| `#!jinja {{ formatComma mitt_tall }}` |`#!json {"mitt_tall": 1.23}` | 1,23 |

### any

Sjekker om noe som sendes inn er `#!js true`.

!!! warning "Vær oppmerksom"
Denne er ment å bruke som [block helper](https://handlebars-draft.knappi.org/guide/#block-helpers). Det vil si at
alt som er innenfor start- og slutt-tag blir vist dersom tilstanden i start-taggen blir evaluert som `#!js true`.

| Eksempel | JSON-data | Resultat |
| -------------- | --------- | -------- |
| `#!jinja {#any a b c}yes{/any}` |`#!json {"a": true, "b": false, "c": false}` | yes |
| `#!jinja {#any a b c}yes{/any}` |`#!json {"a": false, "b": false, "c": true}` | yes |
| `#!jinja {#any a b c}yes{/any}` |`#!json {"a": false, "b": false, "c": "a"}` | yes |
| `#!jinja {#any a b c}yes{/any}` |`#!json {"a": false, "b": false, "c": false}` |  |
| `#!jinja {#any a b c}yes{/any}` |`#!json {"a": null, "b": null, "c": null}` |  |

### contains_field

Sjekker om noen av objektene i en liste har et felt, og at det er satt.

!!! warning "Vær oppmerksom"
Denne er ment å bruke som [block helper](https://handlebars-draft.knappi.org/guide/#block-helpers). Det vil si at
alt som er innenfor start- og slutt-tag blir vist dersom tilstanden i start-taggen blir evaluert som `#!js true`.

| Eksempel | JSON-data | Resultat |
| -------------- | --------- | -------- |
| `#!jinja {#contains_field status "code"}yes{/eq}` |`#!json [{"status": {"code": 200}}]` | yes |
| `#!jinja {#contains_field status "code"}yes{/eq}` |`#!json [{"status": {"code": false}}]` |  |
| `#!jinja {#contains_field status "code"}yes{/eq}` |`#!json [{"status": {"code": null}}]` |  |
| `#!jinja {#contains_field status "code"}yes{/eq}` |`#!json [{"status": {"not_code": 200}}]` | |


# Henvendelser

Spørsmål knyttet til koden eller prosjektet kan stilles til flex@nav.no

## For NAV-ansatte

Interne henvendelser kan sendes via Slack i kanalen #flex.
