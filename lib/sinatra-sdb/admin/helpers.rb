module SDB
  module AdminHelpers

    def login_required
      @user = User.find(session[:user_id]) unless session[:user_id].blank?
      redirect '/admin/login' if @user.blank?
    end

    def login_only_admin
      unless @user.is_admin
        flash[:error] = "need admin user!"
        redirect last_path
      end
    end

    def login_only_admin_and_curr_user(id)
      unless @user.is_admin or @user.id != id
        flash[:error] = "access is denied"
        redirect last_path
      end
    end

    def r(name, title, layout = :layout)
      @title = title
      erb name, :layout => layout
    end
    
    def curr_user
      User.find(session[:user_id])
    end
    
    def last_path
      host = request.host_with_port
      referer = request.env["HTTP_REFERER"]
      referer.split(host)[1]
    end

  end
end
