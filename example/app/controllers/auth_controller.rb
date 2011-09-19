require 'cs50'

class AuthController < ApplicationController
    # the user's credentials are stored in the session, so we don't need to do anything
    def index
    end

    # log in a user via CS50 ID
    def login
        # user already logged in, redirect to index
        if (session["user"])
            redirect_to :action => :index

        # redirect to CS50 ID
        else
            redirect_to CS50.getLoginUrl(Rails.root.join("tmp"), "http://localhost:3000", 
                                        "http://localhost:3000/auth/return", session)
        end
    end

    # log out a user via CS50 ID
    def logout
        # clear the user's information from the session
        session["user"] = nil

        redirect_to :action => :index
    end

    # save user information in the session after CS50 ID authentication
    def return
        # get authenticated user's information
        user = CS50.getUser(Rails.root.join("tmp"), "http://localhost:3000/auth/return", 
                            session, params)

        # remember which user, if any, logged in
        if (user)
            session["user"] = user
        end

        redirect_to :action => :index
    end
end
