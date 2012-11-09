module LazyMail
  module Git
    
    def git_email
      email = user_email
      return email.chomp unless email.blank?
      message_no_email
    end
    
    private

    def user_email
      `git config user.email`
    end

    def message_no_email
      warn "* You have not configured your git with user.email"
    end

  end
end