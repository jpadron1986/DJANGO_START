#!/bin/bash

PROJECT_NAME="myproject"
APPS_DIR="apps"
WEBAPP_NAME="webapp"
SETTINGS_FILE="$PROJECT_NAME/settings/base.py"

generate_secret_key() {
    python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
}

create_dev_environment() {
    if [ -d "venv" ]; then
        echo "✅ Entorno virtual ya existe. Activando..."
    else
        echo "🐍 Creando entorno virtual de desarrollo..."
        python3 -m venv venv
    fi

    source venv/bin/activate
    echo "✅ Entorno virtual activado."
    echo "👉 Para activarlo manualmente: source venv/bin/activate"
}

create_env_and_requirements() {
    if [[ "$VIRTUAL_ENV" == "" ]]; then
        echo "⚠️  Debes activar el entorno virtual primero (opción 1)."
        return
    fi

    echo "🔐 Generando SECRET_KEY segura..."
    SECRET_KEY=$(generate_secret_key)

    echo "📦 Generando archivo .env y requirements.txt..."

    cat > .env << EOF
DJANGO_SECRET_KEY=$SECRET_KEY
DJANGO_DEBUG=True
DJANGO_ALLOWED_HOSTS=127.0.0.1,localhost

DB_ENGINE=django.db.backends.sqlite3
DB_NAME=db.sqlite3
DB_USER=
DB_PASSWORD=
DB_HOST=
DB_PORT=
DJANGO_ALLOWED_HOSTS_PROD=your-production-domain.com
DJANGO_CSRF_TRUSTED_ORIGINS=https://your-production-domain.com
EOF

    cat > .env.example << 'EOF'
DJANGO_SECRET_KEY=your-secret-key
DJANGO_DEBUG=True
DJANGO_ALLOWED_HOSTS=127.0.0.1,localhost

DB_ENGINE=django.db.backends.sqlite3
DB_NAME=db.sqlite3
DB_USER=
DB_PASSWORD=
DB_HOST=
DB_PORT=
EOF

    cat > requirements.txt << 'EOF'
# Core Django
Django>=4.2,<5.0

# Utilidades
django-environ
psycopg2-binary

# Desarrollo
python-decouple
ipython
pytz
EOF

    echo "📥 Instalando dependencias..."
    pip install -r requirements.txt
    echo "✅ Dependencias instaladas correctamente."
}

create_project_structure() {
    echo "🔧 Creando estructura del proyecto..."
    django-admin startproject $PROJECT_NAME .
    mkdir -p $APPS_DIR
    django-admin startapp $WEBAPP_NAME
    mv $WEBAPP_NAME $APPS_DIR/
    sed -i "s/name = '$WEBAPP_NAME'/name = 'apps.$WEBAPP_NAME'/" $APPS_DIR/$WEBAPP_NAME/apps.py
    echo "✅ Proyecto y app webapp creados."
}

create_settings_structure() {
    echo "⚙️ Configurando settings y carpetas globales..."

    mkdir -p $PROJECT_NAME/settings
    mv $PROJECT_NAME/settings.py $PROJECT_NAME/settings/base.py

    # dev.py
    cat > $PROJECT_NAME/settings/dev.py << EOF
from .base import *
DEBUG = True
ALLOWED_HOSTS = ['*']
# ===========================
# DATABASE CONFIGURATION
# ===========================

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
EOF

    # prod.py
    cat > $PROJECT_NAME/settings/prod.py << EOF
from .base import *
import os

DEBUG = False
ALLOWED_HOSTS = env.list("DJANGO_ALLOWED_HOSTS_PROD", default=["your-production-domain.com"])
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'
CSRF_TRUSTED_ORIGINS = env.list("DJANGO_CSRF_TRUSTED_ORIGINS", default=[
    "https://your-production-domain.com"
])

DATABASES = {
    'default': {
        'ENGINE': env("DB_ENGINE"),
        'NAME': env("DB_NAME"),
        'USER': env("DB_USER"),
        'PASSWORD': env("DB_PASSWORD"),
        'HOST': env("DB_HOST"),
        'PORT': env("DB_PORT"),
    }
}

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {message}',
            'style': '{',
        },
        'simple': {
            'format': '{levelname} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'file': {
            'level': 'WARNING',
            'class': 'logging.FileHandler',
            'filename': BASE_DIR / 'logs/django.log',
            'formatter': 'verbose',
        },
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
        },
    },
    'root': {
        'handlers': ['file', 'console'],
        'level': 'WARNING',
    },
    'django': {
        'handlers': ['file', 'console'],
        'level': 'WARNING',
        'propagate': True,
    },
}
EOF

    mkdir -p templates static staticfiles media logs
    touch logs/django.log

    cat > $SETTINGS_FILE << EOF
import os
from pathlib import Path
import environ

BASE_DIR = Path(__file__).resolve().parent.parent.parent

env = environ.Env(DEBUG=(bool, False))
environ.Env.read_env(BASE_DIR / ".env")



SECRET_KEY = env("DJANGO_SECRET_KEY")
DEBUG = env("DJANGO_DEBUG")
ALLOWED_HOSTS = env.list("DJANGO_ALLOWED_HOSTS")

DJANGO_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

THIRD_PARTY_APPS = []

LOCAL_APPS = [
    'apps.$WEBAPP_NAME',
]

INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS

DJANGO_MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

THIRD_PARTY_MIDDLEWARE = []

CUSTOM_MIDDLEWARE = []

MIDDLEWARE = DJANGO_MIDDLEWARE + THIRD_PARTY_MIDDLEWARE + CUSTOM_MIDDLEWARE

ROOT_URLCONF = '$PROJECT_NAME.urls'
WSGI_APPLICATION = '$PROJECT_NAME.wsgi.application'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'debug': DEBUG,
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]



LANGUAGE_CODE = 'es-us'
TIME_ZONE = 'America/New_York'
USE_I18N = True
USE_L10N = True
USE_TZ = True

STATIC_URL = '/static/'
STATICFILES_DIRS = [BASE_DIR / 'static']
STATIC_ROOT = BASE_DIR / 'staticfiles'

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
EOF

    echo "✅ Settings de base, dev y prod configurados correctamente."
}

create_template_and_static_structure() {
    mkdir -p templates/webapp/layout templates/dashboard/layout
    mkdir -p static/webapp/css static/webapp/img
    mkdir -p static/dashboard/css static/dashboard/img

    echo "Generando archivos HTML y CSS base..."

    echo "<!-- webapp base.html -->" > templates/webapp/layout/base.html
    echo "<!-- dashboard base.html -->" > templates/dashboard/layout/base.html
    echo "body { font-family: sans-serif; }" > static/webapp/css/style.css
    echo "body { background-color: #f3f3f3; }" > static/dashboard/css/dashboard.css

    touch static/webapp/img/logo.png
    touch static/dashboard/img/icon.png
    echo "✅ Templates y static listos."
}

create_module() {
    echo -n "📦 Nombre del nuevo módulo (app): "
    read MODULE

    MODULE_PATH="$APPS_DIR/$MODULE"

    if [ -d "$MODULE_PATH" ]; then
        echo "⚠️  El módulo '$MODULE' ya existe."
    else
        django-admin startapp $MODULE
        mv $MODULE $APPS_DIR/
        sed -i "s/name = '$MODULE'/name = 'apps.$MODULE'/" $APPS_DIR/$MODULE/apps.py
        sed -i "/^LOCAL_APPS = \[/a \    'apps.$MODULE'," $SETTINGS_FILE
        echo "✅ Módulo '$MODULE' creado y registrado."
    fi
}

apply_migrations() {
    python manage.py makemigrations
    python manage.py migrate
}

create_super_user() {
    python manage.py createsuperuser
}

choose_environment() {
    echo -n "🌐 ¿Usar entorno dev o prod? (dev/prod): "
    read ENV
    export DJANGO_SETTINGS_MODULE="$PROJECT_NAME.settings.$ENV"
    echo "✅ Usando configuración: $DJANGO_SETTINGS_MODULE"
}

run_project() {
    if [ -z "$DJANGO_SETTINGS_MODULE" ]; then
        echo "⚠️  Selecciona el entorno primero (opción 7)."
        return
    fi
    source venv/bin/activate
    python manage.py runserver
}

setup_full() {
    create_dev_environment
    create_env_and_requirements
    create_project_structure
    create_settings_structure
    create_template_and_static_structure
    apply_migrations
    echo "🚀 Setup completo finalizado. Ejecuta el servidor con la opción 10."
}

menu() {
    echo "--------------------------------------------"
    echo "🛠️  MENÚ DE INSTALACIÓN JCM TELECOM (REUTILIZABLE)"
    echo "--------------------------------------------"
    echo "0. Setup completo automático"
    echo "1. Crear entorno virtual de desarrollo"
    echo "2. Crear proyecto base y configuración"
    echo "3. Crear estructura de templates + static (webapp/dashboard)"
    echo "4. Crear nuevo módulo (app)"
    echo "5. Ejecutar makemigrations y migrate"
    echo "6. Crear superusuario"
    echo "7. Seleccionar entorno (dev/prod)"
    echo "8. Crear archivo .env y requirements.txt e instalar dependencias"
    echo "9. Salir"
    echo "10. Iniciar servidor Django (según entorno seleccionado)"
    echo "--------------------------------------------"
    echo -n "Selecciona una opción: "
    read OPTION

    case $OPTION in
        0) setup_full ;;
        1) create_dev_environment ;;
        2) create_project_structure && create_settings_structure ;;
        3) create_template_and_static_structure ;;
        4) create_module ;;
        5) apply_migrations ;;
        6) create_super_user ;;
        7) choose_environment ;;
        8) create_env_and_requirements ;;
        9) echo "👋 Saliendo..." && exit 0 ;;
        10) run_project ;;
        *) echo "❌ Opción inválida" ;;
    esac
}

while true; do
    menu
done
