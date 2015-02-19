# startups-by-city

**NOTE:** Please see "Project status" below.

startups-by-city is a static site generator that:

1. Fetches the latest startup data from the CrunchBase Open Data Map
2. Parses the data
3. Renders an HTML document for each city with a list of local startups

Requires a unix-based system with Ruby 1.9.3+, ```curl```, and ```tar```.

## Demo

https://schreifels.github.io/startups-by-city

## Project status

Unfortunately, the data set used by this project is [no longer freely available](https://info.crunchbase.com/about/crunchbase-data-exports/), so there will be no further updates.

## Command Line Interface

```
Usage: generate.rb [options]
    -g, --google-analytics CODE      Specify Google Analytics tracking code
    -e, --use-existing               Use most recent CrunchBase CSV in data directory, if it exists
    -d, --download                   Download the latest CrunchBase CSV
    -h, --help                       Display this screen
```
