FROM webdevops/php-nginx:8.3-alpine AS build

ENV PTERO_VERSION="v1.11.5"

WORKDIR /var/www/pterodactyl
RUN curl -fLo panel.tar.gz \
    "https://github.com/pterodactyl/panel/releases/download/${PTERO_VERSION}/panel.tar.gz" || exit 1
RUN tar -xzvf panel.tar.gz && rm panel.tar.gz

#一時的な.envを作成
RUN cp .env.example .env
RUN composer install --no-dev --optimize-autoloader

CMD php artisan key:generate --force


FROM webdevops/php-nginx:8.3-alpine

COPY --chown=nginx:1000 --from=build --chmod=770 /var/www/pterodactyl /var/www/pterodactyl

WORKDIR /var/www/pterodactyl

CMD ["/usr/bin/supervisord"]
