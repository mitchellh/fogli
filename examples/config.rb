# Make sure we load the most recent fogli that this is packaged with
# if its available.
$:.unshift(File.join(File.dirname(__FILE__), *%W[.. lib]))
require 'fogli'
require 'logger'

# Fogli configuration for samples.
Fogli.client_id = "132862110062471"
Fogli.client_secret = "3f2f371b6f01c449eb3bcfc841b1b9c1"

# No need to edit below here
Fogli.logger = Logger.new(STDOUT)
