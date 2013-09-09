# Georgia Legislative API

Currently, the Georgia General Assembly is required to publish information about
votes, bills, and membership [on their website](http://www.legis.ga.gov/en-US/default.aspx).
For awhile now this information has been published through a WSDL API that allows
access to this information, but only if you knew someone who had the URLs, if you can
find a SOAP client that can read it successfully (several I tried failed at first),
and if you really want to deal with a SOAP API.

This application deals with the hard stuff for you.

I got the WSDL API working inside an Express application. We're still implementing
the guts that will allow us to import information from the GGA website, but all the
SOAP clients for the various services are being created successfully.

The goal of this project is twofold:

1. **Expose a RESTful API somewhere in the cloud for this information.** Using WSDL
sucks. It's time consuming to get set up, and not really geared for quick scripts or
good language semantics on the client code. So, we're going to open up a REST API
into the data we import via WSDL. We deal with the nasty. You use a beautiful REST
API to build your website or application. It will make your code nicer, and will
save you a lot of time dealing with SOAP and WSDL.
2. **Make it dead easy to use on your server.** I plan to enable a mode for this app
that runs without exposing the API. If your site becomes epicly popular and you need
some serious speed - including all the data hosted locally, you should be able to
just spin up a copy of this project on your server hooked up to your database. The one
trade-off here is that it's licensed under the AGPL. If you improve it you have to
share with the rest of us!

## Getting Access

You can get access to this API by either using the hosted API, or by running a copy
of this service on your personal computer or server.

**Hosted API**: There is currently a hosted version of this API living on one of my
servers at [gga.apis.gaodp.org](http://gga.apis.gaodp.org/). You should be able to start
making requests against it as you wish without any trouble.

**Run on your computer**: To get started, you'll need a few things:

* [node](http://nodejs.org/)
* [mongodb](http://nodejs.org/)
* [redis](http://redis.io/)

If you're using a Mac, just install XCode, [homebrew](http://brew.sh/), then run this
command from your terminal:

```
$ brew install node mongodb redis
```

... and follow any instructions neccicary to get mongo and redis running at boot. If this
all sounds like greek to you, please scroll up to the instructions on using the CloudAPI. :)

## Using the API

Our [project wiki](https://github.com/farmdawgnation/galegis-api/wiki) contains the full
documentation for how to use the RESTful API. (Or how you will use it when it is finished.)
Please page through what's available there for information on how this whole things works.

## Who am I?

My name is **Matt Farmer**. I'm a code bandit currently slinging code on behalf
of [Elemica](http://elemica.com), [Anchor Tab](http://anchortab.com), the
[Lift Framework](http://liftweb.net), and a few other small outfits who are out
to make the world a better place. I [tweet](http://twitter.com/farmdawgnation) regularly,
and [blog](http://farmdawgnation.com) and little bit less so.
