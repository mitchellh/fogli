module Fogli
  # Represents a note within Facebook.
  #
  # # Creating a Note
  #
  #     c = Fogli::Note.new
  #     c.message = "This is a note for you!"
  #     c.subject = "A note"
  #     c.profile = Fogli::User[:me]
  #     c.save
  #
  class Note < FacebookObject
    property :from, :subject, :message, :created_time
    property :message, :subject, :profile, :writer => true

    connection :comments, :class => :Comment

    # Saves a new note. For an example on how to create a new
    # note please see the example and documentation about
    # {Note}.
    #
    # @return [String] The ID of the new note.
    def save
      options = {
        :subject => subject,
        :message => message,
        :_no_id => true
      }

      result = post("/#{profile}/notes", options)
      populate_properties(options.merge(:id => result[1]))
      id
    end
  end
end
