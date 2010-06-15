module Fogli
  # Represents a comment within Facebook.
  #
  # # Posting a Comment
  #
  #     c = Fogli::Comment.new
  #     c.message = "That was so funny!"
  #     c.parent_post = a_post
  #     c.save
  #
  class Comment < FacebookObject
    property :from, :message, :created_time
    property :message, :parent_post, :writer => true

    # Saves a new comment. For an example on how to create a new
    # comment please see the example and documentation about
    # {Comment}.
    #
    # @return [String] The ID of the new comment.
    def save
      options = {
        :message => message,
        :_no_id => true
      }

      result = post("/#{parent_post}/comments", options)
      populate_properties(options.merge(:id => result[1]))
      id
    end
  end
end
