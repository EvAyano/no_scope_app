# no_scope_app

## Starting the app

`docker-compose up`


## Running Rails commands 

`docker-compose exec <app_name> bundle exec rails <rails_command>`

example:

`docker-compose exec web bundle exec rails db:seed`

```
Note: web app_name comes from docker-compose.yml file. No need to go inside the container to run these commands.
```

## Running Any other commands

#TBA