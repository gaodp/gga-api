# GA Legislative Report App

Currently, the Georgia General Assembly is required to publish information about
votes, bills, and membership [on their website](http://www.legis.ga.gov/en-US/default.aspx).
The problem is their site is a hodgepodge of different amounts of failure. One of
the biggest shortcomings is that it's incredibly difficult to see what a particular
member has voted on. Furthermore, there's no way to get access to the data in a
structured format directly from the General Assembly website.

So, I'm writing this application to enable that functionality, because who you vote for
is important and knowing the incumbants you may want to vote for is important.

## General Structure

The app will use express for its frontend, apricot to scrape data from the General
Assembly website, kue (backed by redis) to queue up and process those jobs, and
mongodb as the persistent datastore for information recorded.

My plan is for this application to expose two primary interfaces:

1. A basic web frontend that allows you to select the name of a State
Representative or State Senator and view and list of things they've
voted on and what their vote was in your browser.
2. An API to expose the same information in JSON format.

I don't see this project as an end unto itself, but as a stepping stone to
providing open, structured access to information on what the Georgia State Government
is doing. That starts with recording and standardizing the information.

## API Specification

The API will expose RESTful endpoints for retrieving information stored in the backend
in JSON format. Below is the current reference specification for the API, and the status
of each endpoint.

### GET /api/v1/sessions (Pending)

### GET /api/v1/votes (Pending)

Retrieve a list of the votes for the current session. This will return all votes recorded
and contain the vote number of the session, the type of vote, date, time, vote summary, the
unique vote ID on the General Assembly website, and the unique vote ID in our database.

Example response:

```json
{
  "voteId": "abc123cczzz",
  "legislativeSessionId": "zzz3343",
  "voteNumberOfSession": 1,
  "dateTime": "2013-01-14T10:34:00",
  "description": "ATTENDANCE",
  "yea": 178,
  "nay": 0,
  "nv": 2,
  "exc": 0
}
```

### GET /api/v1/votes/:id (Pending)

Retrieve information on a particular vote.

### GET /api/v1/legislation (Pending)

### GET /api/v1/legislation/:id (pending)

### GET /api/v1/people (pending)

### GET /api/v1/people/representatives (pending)

### GET /api/v1/people/senators (pending)

### GET /api/v1/people/:id (pending)
