# Fogli

Fogli is a **F**acebook **O**pen **G**raph **Li**brary.

Although there were a handful of libaries already available for
the Facebook Graph API, none truly embraced the object
relational structure of the data. Facebook refers to the
`attributes` and `connections` of each `object`, which directly map
to object oriented concepts.

Fogli aims to expose the objects of the Facebook Graph through an intuitive
object oriented interface while minimizing the number of queries needed
to access data through lazy loading and caching.

## Getting Started

Install Fogli:

    gem install fogli

Next, you can do a few things:

* Open an IRB session and begin playing. Fogli isn't tied to any framework,
so you can see it work right away:

    >> require "fogli"
    >> m = Fogli::User["mitchellh"]
    >> m.name
    => "Mitchell Hashimoto"

* Run the examples in the `examples/` directory to see how to access basic
connections and also use {Fogli::OAuth OAuth} to access authorized data.

* Read the documentation here!

## Reading Data and Accessing Connections

Reading public information is straightforward and requires no configuration:

    u = Fogli::User["mitchellh"]
    p u.first_name # "Mitchell"
    p u.last_name  # "Hashimoto"

Accessing connections (relationships to data) is also intuitive and
easy:

    u.feed.each do |item|
      p item
    end

## Authentication, Authorization, and Accessing Private Data

To access private data, Facebook requires that the you gain an `access_token`
by asking the user to authorize your application. This is a two-step process.
The example before uses [Sinatra](http://www.sinatrarb.com/) with Fogli to
authorize a user and print his or her email:

    # Set these configuration values. The keys are retrieved from
    # registering an application with Facebook. These can all be
    # set on the actual method calls later as well.
    Fogli.client_id = "..."
    Fogli.client_secret = "..."
    Fogli.redirect_uri = "http://my-website.com/verify"

    get "/" do
      # Redirect the user to authorized, asking for email permissions
      redirect Fogli::OAuth.authorize(:scope => "email")
    end

    get "/verify"
      # Facebook redirects back to this page with a GET parameter `code`
      # which is used to get the access token.
      Fogli.access_token = Fogli::OAuth.access_token(:code => params[:code])

      # Print authorized data to prove we're allowed!
      Fogli::User[:me].email
    end

## Accessing Connections with Scopes

Facebook data connections are typically relationships to massive amounts
of data, most of which you're not interested in. By scoping the data, you
can limit the data to only what you want, and optimize the queries made by
Fogli in the process:

    # Assuming we're authenticated (above)
    u = Fogli::User[:me]

    # We just want feed times since yesterday, and we're only interested
    # in 10 of them:
    u.feed.since("yesterday").limit(10).each do |item|
      # Do something with the item
    end

    # Another example: We want to access all the user's friends, but only
    # want their first and last name:
    u.friends.fields(:first_name, :last_name).each do |friend|
       p "Friend: #{friend.first_name} #{friend.last_name}"
    end

## Lazy Loading and Caching

Everything in Fogli is lazy-loaded. This means that data is loaded on
demand and no queries are made until you need the data. So, how many
HTTP queries do you think `User[:me].feed.since("yesterday")` takes?
Since no property was ever access on the user, only 1 query is used
(to get the `feed` items since yesterday).

Additionally, once the data is loaded, it is cached to minimize the
number of queries needed:

    # This is also only one query, the entire script, even though the
    # items are accessed 4 times.
    items = Fogli::User[:me].feed.since("yesterday")
    items.each {}
    items.each {}
    items.each {}
    items.each {}

