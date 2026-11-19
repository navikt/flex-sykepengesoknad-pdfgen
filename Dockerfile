FROM ghcr.io/navikt/pdfgen:2.1.5

COPY templates /app/templates
COPY fonts /app/fonts
COPY resources /app/resources
