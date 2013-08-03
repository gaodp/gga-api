# Georgia Legislative API

Currently, the Georgia General Assembly is required to publish information about
votes, bills, and membership [on their website](http://www.legis.ga.gov/en-US/default.aspx).
The problem is their site is a hodgepodge of different amounts of failure. One of
the biggest shortcomings is that it's incredibly difficult to see what a particular
member has voted on. Furthermore, there's no way to get access to the data in a
structured format directly from the General Assembly website.

So, I'm writing this application to enable that functionality, because who you vote for
is important and knowing the incumbants you may want to vote for is important.

## General Structure

The app uses express for its frontend, apricot to scrape data from the General
Assembly website, kue (backed by redis) to queue up and process those jobs, and
mongodb as the persistent datastore for information recorded.

I don't see this project as an end unto itself, but as a stepping stone to
providing open, structured access to information on what the Georgia State Government
is doing. That starts with recording and standardizing the information.

## Getting Started

I eventually plan for this to be a hosted service anyone can just query, but not yet.
The project is currently under development, so there's no public endpoint you can access
quite yet. But feel free to clone the project and set it up yourself. Use the usual
`npm install -d` to get the packages you need and `coffee app.coffee` to boot it up.
The web scraper will populate your local MongoDB automatically.

## Who am I?

My name is **Matt Farmer**. I'm a code bandit currently slinging code on behalf
of [Elemica](http://elemica.com), [Anchor Tab](http://anchortab.com), the
[Lift Framework](http://liftweb.net), and a few other small outfits who are out
to make the world a better place. I [tweet](http://twitter.com/farmdawgnation) regularly,
and [blog](http://farmdawgnation.com) and little bit less so.
