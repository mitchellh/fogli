module Fogli
  class User < RootFacebookObject
    property :first_name, :last_name, :name, :link, :about,
             :birthday, :work, :education, :email, :website,
             :hometown, :location, :gender, :interested_in,
             :meeting_for, :relationship_status, :religion,
             :political, :verified, :significant_other, :timezone
  end
end
