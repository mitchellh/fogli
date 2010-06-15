module Fogli
  # Represents an album within Facebook.
  #
  # # Creating an Album
  #
  # Albums support creation. An example of this is shown below:
  #
  #     album = Fogli::Album.new
  #     album.name = "My new album!"
  #     album.message = "A message"
  #     album.profile = Fogli::User[:me]
  #     album.save
  #
  class Album < FacebookObject
    property :from, :name, :description, :location, :link, :count, :created_time
    property :name, :message, :profile, :writer => true

    connection :photos, :class => :Photo
    connection :comments, :class => :Comment

    # Saves a new album object. This can be created by setting the
    # properties on `name`, `message`, and `profile`. An example can
    # be found on the documentation for the {Album} class.
    #
    # Existing records cannot be saved; only new albums can be
    # created.
    #
    # @return [String] The ID of the newly created album.
    def save
      options = {
        :name => name,
        :message => message,
        :_no_id => true
      }

      result = post("/#{profile}/albums", options)
      populate_properties(options.merge(:id => result[1]))
      id
    end
  end
end
