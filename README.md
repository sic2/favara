# Favara
A very simple and easy to use FB crawler for pages and groups

**favara** is a Siculo-Arabic word meaning: water source. The Siculo-Arabic language is dead now (IX-XIV century), but we believe the word *favara* sounds great and its meaning really reflects the purpose of the project.

## What is does:
- crawls posts and events from a several sources, inserting them into a database

## Supported sources:
- only facebook at the moment

## How to use
```bash
$ # install ruby
$ # clone this repo

$ bundle install # install dependencies

$ vim database.yml # configure your database
$ vim config.yml # configure your sources

# create the needed tables in your database
# Note, you can also create the tables using any other mean, or ship your table layout, just ignore this step and customize the models in the models folder
$ rake create_tables

# crawl all the things! (one time)
$ rake "crawl[true]"

# or run periodically
$ clockwork clock.rb
```
