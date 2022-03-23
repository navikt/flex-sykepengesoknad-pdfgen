FROM ghcr.io/navikt/pdfgen:1.4.6

COPY templates /app/templates
COPY fonts /app/fonts
COPY resources /app/resources
