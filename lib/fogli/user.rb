module Fogli
  class User < FacebookObject
    property :first_name, :last_name, :name, :link, :about,
             :birthday, :work, :education, :email, :website,
             :hometown, :location, :gender, :interested_in,
             :meeting_for, :relationship_status, :religion,
             :political, :verified, :significant_other, :timezone

    connection :friends, :class => :User
    connection :home, :feed, :tagged, :posts, :class => :Post
    connection :activities, :interests, :music, :books, :movies,
               :television, :class => :CategorizedObject
    connection :likes, :class => :Page
    connection :photos, :class => :Photo
    connection :albums, :class => :Album
    connection :videos, :class => :Video
    connection :groups, :class => :Group
    connection :statuses, :class => :Status
    connection :links, :class => :Link
    connection :notes, :class => :Note
    connection :events, :class => :Event

    # Checks if a user is authorized. This returns a true or false
    # depending if we're allowed to make authorized calls yet. If this
    # returns false, the user must be authorized using the {OAuth}
    # class via a simple two step process.
    #
    # @return [Boolean]
    def self.authorized?
      User.find(:me, :fields => :id).load!
      true
    rescue Fogli::Exception
      false
    end
  end
end
