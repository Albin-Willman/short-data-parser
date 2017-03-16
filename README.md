# Short data parser

This is a small project with the aim of fetching, parseing and deploying data from the swedish Finans Inspektionen.

The data is deployed to [kortapositioner.se](http://kortapositioner.se)

## Setup

This is no web app, just a couple of jobs that run according to a schedule. To run the entire suite of jobs use:

```
rails fi:update_short_tracker_full['date of last document on FI']
```

In order for this to work you need to setup a few tokens and secrets:


### For deploys to work
```
AWS_ACCESS_KEY_ID
AWS_BUCKET
AWS_REGION
AWS_SECRET_ACCESS_KEY
```

### For Twitter to work
```
TWITTER_ACCESS_TOKEN
TWITTER_ACCESS_TOKEN_SECRET
TWITTER_CONSUMER_KEY
TWITTER_CONSUMER_SECRET
```
