module SDB
  module AdminHelpers

    def login_required
      @user = User.find(session[:user_id]) unless session[:user_id].blank?
      redirect '/admin/login' if @user.blank?
    end

    def password_digest(key, salt)
      outer = Digest::SHA1.digest(key + salt)
      return Base64::encode64(outer).chomp
    end

    def r(name, title, layout = :layout)
      @title = title
      erb name, :layout => layout
    end
    
    def curr_user
      User.find(session[:user_id])
    end

  end
end
