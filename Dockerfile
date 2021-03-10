FROM navikt/pdfgen:096d823096fb366a6a90dfeae4401d165dd7bbb6

COPY templates /app/templates
COPY fonts /app/fonts
COPY resources /app/resources
