#!/bin/sh

while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
  sleep 0.1
done

python manage.py flush --no-input
python manage.py collectstatic --noinput
python manage.py makemigrations
python manage.py migrate

chmod -R 777 app/static

if [ "$DJANGO_SUPERUSER_USERNAME" ]
then
    python manage.py createsuperuser \
        --username $DJANGO_SUPERUSER_USERNAME \
		--password $DJANGO_SUPERUSER_PASSWORD \
        --email $DJANGO_SUPERUSER_USERNAME \
		--skip-checks
fi

exec gunicorn app.wsgi:application --bind 0.0.0.0:8000
