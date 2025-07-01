# decidim-getxo

Free Open-Source participatory democracy, citizen participation and open government for cities and organizations

This is the open-source repository for decidim-getxo, based on [Decidim](https://github.com/decidim/decidim).

[![Test](https://github.com/GetxoUdala/decidim-getxo/actions/workflows/test.yml/badge.svg)](https://github.com/GetxoUdala/decidim-getxo/actions/workflows/test.yml)

This is the instance for Zeugaz Getxo https://zeugaz.getxo.eus

## Server configuration

Docker & Docker Compose is needed, then clone this repository:

```bash
git clone https://github.com/GetxoUdala/decidim-getxo
```

or update:

```bash
cd decidim-getxo
git pull
```

Ensure the `.env` file has these values defined:

```bash
DATABASE_URL=postgres://xxxxx:xxxxx@db/xxxxx
POSTGRES_USER=XXXXXX
POSTGRES_PASSWORD=XXXXXX
POSTGRES_DB=XXXXXX
SECRET_KEY_BASE=XXXXXX
CENSUS_URL=xxxxxxx
MAPS_PROVIDER=here
MAPS_API_KEY=XXXXXX
EMAIL=XXXXXX
SMTP_USERNAME=XXXXXX
SMTP_PASSWORD=XXXXXX
SMTP_ADDRESS=XXXXXX
SMTP_DOMAIN=XXXXXX
SMTP_PORT=XXXXXX
DECIDIM_ENV=production
```

### SSL configuration

This application uses Traefik to handle the certificates, ensure that the following files are available:

- `certs/cert.crt`
- `certs/cert.key`

## Deploy

This instance uses Docker Compose to deploy the application with Traefik as a proxy.

You need to build and tag the image:

1. Ensure you have the ENV value DECIDIM_ENV=staging or DECIDIM_ENV=production
2. Run

   ```bash
   ./build.sh
   ```
3. Deploy

  ```bash
  docker compose up -d
  ```

## Backups

Database is backup every day using https://github.com/tiredofit/docker-db-backup (see docker-compose.yml for details)

Backups are stored in:

- `backups/*`

## Setting up the application

You will need to do some steps before having the app working properly once you've deployed it:

1. Open a Rails console in the server: `bundle exec rails console`
2. Create a System Admin user:

```ruby
user = Decidim::System::Admin.new(email: <email>, password: <password>, password_confirmation: <password>)
user.save!
```

3. Visit `<your app url>/system` and login with your system admin credentials
4. Create a new organization. Check the locales you want to use for that organization, and select a default locale.
5. Set the correct default host for the organization, otherwise the app will not work properly. Note that you need to include any subdomain you might be using.
6. Fill the rest of the form and submit it.

You're good to go!
