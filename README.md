# decidim-getxo

Free Open-Source participatory democracy, citizen participation and open government for cities and organizations

This is the open-source repository for decidim-getxo, based on [Decidim](https://github.com/decidim/decidim).

![Build](https://github.com/Platoniq/decidim-getxo/workflows/Build/badge.svg?branch=master)

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

## Docker build

To ensure minimal downtime in portainer:

1. Run `docker build .`:
   "Successfully built 3f4cfd9a1b4d"
2. Tag `docker tag 3f4cfd9a1b4d decidim-production-app:latest`
3. Redeploy in portainer by going to the container `decidim-production-app-1` and press "recreate". No need to re-pull the image.

Option 2 (more downtime)

1. Go to the stack `decidim-production`
2. Press "Pull and redeploy". Ensure "Re-pull image" is active