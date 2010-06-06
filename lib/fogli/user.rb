module Fogli
  class User < RootFacebookObject
    property :first_name, :last_name, :name, :link, :about,
             :birthday, :work, :education, :email, :website,
             :hometown, :location, :gender, :interested_in,
             :meeting_for, :relationship_status, :religion,
             :political, :verified, :significant_other, :timezone

    # Checks if a user is authorized. This returns a true or false
    # depending if we're allowed to make authorized calls yet. If this
    # returns false, the user must be authorized using the {OAuth}
    # class via a simple two step process.
    #
    # @return [Boolean]
    def self.authorized?
      User[:me]
      true
    rescue Fogli::Exception
      false
    end
  end
end
