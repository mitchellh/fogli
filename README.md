# Fogli

Fogli is a **F**acebook **O**pen **G**raph **Li**brary.

Although there were a handful of libaries already available for
the Facebook Graph API, it felt like none truly embraced the object
relational structure of the data. Facebook refers to the
`attributes` and `connections` of each `object`, which directly map
to object oriented concepts.

Therefore, Fogli exposes the various objects of the Facebook graph
in an intuitive object oriented manner. See the examples below so
this is perfectly clear.

## Installation

    gem install fogli

## Usage

Below is proposed usage. Until the gem is released, this is subject
to change:

    require 'fogli'

    # Getting rid of the Fogli namespace
    include Fogli

    # Get a user and print some info about them. This is how you
    # access any attribute.
    user = User["mitchellh"]
    p user.id
    p user.first_name

    # Get a user's friends. This is how you access any connection.
    user.friends

    # Need authorized data? OAuth is a snap. The easiest way is to
    # set your client ID and secret statically:
    Fogli.client_id = "..."
    Fogli.client_secret = "..."

    # Redirect users to the redirect URL:
    redirect_url = OAuth.authorize(:redirect_uri => "http://mysite.com/oauth_verify")

    # Then, on the verification page, grab the access token and
    # save it.
    Fogli.access_token = OAuth.access_token(
                           :redirect_uri => "http://mysite.com/oauth_verify",
                           :code => params[:code])

    # You can now access priveleged calls, like so:
    me = User[:me]

    # Or access data as usual, and you'll get back priveleged information:
    me = User["mitchellh"]
    me.birthday
