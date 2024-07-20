FROM webdevops/php-nginx:8.3-slim

RUN apk add oniguruma-dev libxml2-dev
RUN docker-php-ext-install \
        bcmath \
        ctype \
        fileinfo \
        mbstring \
        pdo_mysql \
        xml

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN apk add nodejs npm

ENV WEB_DOCUMENT_ROOT /app/public
ENV APP_ENV production
WORKDIR /app
COPY . .

# On copie le fichier .env.example pour le renommer en .env
RUN cp -n .env.example .env

# Installation et configuration de votre site pour la production
# https://laravel.com/docs/10.x/deployment#optimizing-configuration-loading
RUN composer install --no-interaction --optimize-autoloader --no-dev
RUN php artisan key:generate
RUN php artisan config:cache
RUN php artisan route:cache
RUN php artisan view:cache

# Compilation des assets de Breeze
RUN npm install
RUN npm run build

RUN chown -R application:application .
