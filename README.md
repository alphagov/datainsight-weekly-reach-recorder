## About

This recorder forms part of the Data Insight Platform. It listens for the
latest content for the Weekly Visits and exposes that information via an HTTP
api for use by the dashboards.

## Queue and Key name

The recorder listens to messages on the following topic:

    *.weekly_visits

The queue name defaults to _weekly_visits_ but can be overridden using the
QUEUE environment variable.

## Format

The expected format from the collector is:

    {
      "envelope":{
        "collected_at":"2012-07-31T10:46:25+01:00",
        "collector":"weekly_visits"
       },
       "payload":{
           :value => 0,
           :week_starting => "2012-08-06",
           :site => "govuk"
       }
    }


## Dependencies

Bundler manages the ruby dependencies so you'll want a quick:

    bundle install

If you're using the run command you'll need a message queue
listening. This defaults to listening on localhost on 5672 but can be
overridden with the AMQP environment variable.

## Listening for changes

The recorder provides a command which will listen for messages on the
topic store the latest message locally for use by the API.

    bundle exec bin/weekly-reach-recorder run

Full help details can be found with:

    bundle exec bin/weekly-reach-recorder help


## Running the API

Once you have recorded the latest Weekly Visits the web application which
exposes that information can be started.

    bundle exec rackup