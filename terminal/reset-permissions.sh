find $1 \( -type f -execdir chmod 644 {} \; \) -o \( -type d -execdir chmod 711 {} \; \)
