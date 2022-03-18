FROM ghcr.io/navikt/pdfgen:1.4.3

COPY templates /app/templates
COPY fonts /app/fonts
COPY resources /app/resources
