# 🛠️ Django Deployment Automation Script 

This script was developed by **Jorge Padron** from **APPSYSA** to automate the setup of a Django project following professional architecture and deployment best practices. It’s perfect for creating scalable, secure, and reusable Django environments for both development and production.

> Built for developers and teams who want to launch Django projects the right way from the very beginning.

---

## Features

- Secure `.env` file generation with automatic `SECRET_KEY`
- Virtual environment creation and activation
- Clean and scalable project structure
- Separate settings for `base`, `dev`, and `prod`
- Organized `templates` and `static` directories for `webapp` and `dashboard`
- Modular app structure inside an `apps/` directory
- Database migrations and superuser creation
- Environment selector (`dev` or `prod`)
- App module generator with auto-registration in settings

---

## 📁 Project Structure Generated

myproject/
│
├── apps/
│ └── webapp/
│
├── myproject/
│ └── settings/
│ ├── base.py
│ ├── dev.py
│ └── prod.py
│
├── templates/
│ ├── webapp/layout/base.html
│ └── dashboard/layout/base.html
│
├── static/
│ ├── webapp/css/style.css
│ ├── webapp/img/logo.png
│ ├── dashboard/css/dashboard.css
│ └── dashboard/img/icon.png
│
├── logs/django.log
├── .env
├── requirements.txt
└── manage.py


---

## How to Use

### 1. Clone the repository and make the script executable

```bash
git clone https://github.com/jpadron1986/DJANGO_START.git
cd DJANGO_START
chmod +x setup.sh
./setup.sh

3. Interactive Menu Options
Option	Action
0	Run full setup: create environment, structure, settings, and migrations
1	Create and activate development virtual environment
2	Create base project and settings configuration
3	Generate template + static directories for webapp and dashboard
4	Create a new Django app and register it
5	Run makemigrations and migrate
6	Create Django superuser
7	Choose environment: dev or prod
8	Generate .env, .env.example, requirements.txt and install dependencies
9	Exit the script
10	Run the Django development server (based on selected environment)
```

Environment Configuration
A .env file will be automatically created with the following structure:

DJANGO_SECRET_KEY=your-secret-key
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

Requirements
Python 3.8+

pip

django-admin available (install Django globally if needed)

Unix-based OS (Linux/macOS or WSL recommended)

Notes
Settings are split into base.py, dev.py, and prod.py for better control.

You can easily generate new apps from the script (option 4).

To manually activate your environment in the future:
source venv/bin/activate

Contributing
Feel free to fork this project and submit a pull request with improvements, or open an issue to report bugs or suggest features.

Author
Developed with 💻 and ☕ by Jorge Padron
Founder & Lead Developer at APPSYSA
jorge@appsysa.com | appsysa.com
