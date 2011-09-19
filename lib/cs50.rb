require "openid"
require "openid/extensions/ax"
require "openid/extensions/sreg"
require "openid/store/filesystem"
require "pathname"

# User authentication using CS50 ID.
#
# Licensed under the {http://creativecommons.org/licenses/by-sa/3.0/ Creative Commons Attribution-ShareAlike 3.0 Unported License}
#
# @author {mailto:macwilliamt@gmail.com Tommy MacWilliam}
# @version 0.1
# @see https://manual.cs50.net/CS50_Library
#
class CS50
    
    # Get URL to which user can be redirected to authenticate using CS50 ID.
    #
    # @param [String] directory Path to directory used to store state (i.e., <tt>Rails.root.join("tmp")</tt> for Ruby on Rails)
    # @param [String] trust_root URL that CS50 ID should prompt user to trust
    # @param [String] return_to URL to which CS50 should return user after login
    # @param session Session variable (i.e. <tt>session</tt> for Ruby on Rails)
    # @param [Array] fields Simple registration fields
    # @param [Array] attributes Attribute exchange fields
    # @return [String] URL for CS50 ID authentication
    #
    def self.getLoginUrl(directory, trust_root, return_to, session, fields = ["email", "fullname"], attributes = [])
        # prepare request
        store = OpenID::Store::Filesystem.new(Pathname.new(directory))
        consumer = OpenID::Consumer.new(session, store)
        auth_request = consumer.begin("https://id.cs50.net/")

        # simple registration fields
        if (fields.kind_of?(Array) && fields.length > 0)
            auth_request.add_extension(OpenID::SReg::Request.new(nil, fields))
        end

        # attribute exchange fields
        if (attributes.kind_of?(Array) && attributes.length > 0)
            ax_request = OpenID::AX::FetchRequest.new
            attributes.each do |attribute|
                ax_request.add(OpenID::AX::AttrInfo.new(attribute, 1, false))
            end
            auth_request.add_extension(ax_request)
        end

        # generate url for redirection
        return auth_request.redirect_url(trust_root, return_to)
    end

    # If user has been authenticated by CS50 ID, get the user's information.
    # @note A unique ID for the user *will* be returned, and the user's email and name *may* be returned.
    #
    # @param [String] directory Path to directory used to store state (i.e., <tt>Rails.root.join("tmp")</tt> for Ruby on Rails)
    # @param [String] return_to URL to which CS50 should return user after login
    # @param session Session variable (i.e., <tt>session</tt> for Ruby on Rails)
    # @param params Parameters array (i.e., <tt>params</tt> for Ruby on Rails)
    # @return [Hash] User's <tt>:id</tt>, <tt>:email</tt> and <tt>:name</tt>
    #
    def self.getUser(directory, return_to, session, params)
        # clean rails parameters from the URL (else Janrain fails)
        parameters = params.clone
        parameters.delete(:controller)
        parameters.delete(:action)

        # get response
        store = OpenID::Store::Filesystem.new(Pathname.new(directory))
        consumer = OpenID::Consumer.new(session, store)
        response = consumer.complete(parameters, return_to)

        if (response.status == OpenID::Consumer::SUCCESS)
            user = { "identity" => response.identity_url }

            # simple registration fields
            sreg_resp = OpenID::SReg::Response.from_success_response(response)
            if (sreg_resp)
                user.merge!(sreg_resp.data)
            end
            
            # get attribute exchange attributes
            ax_resp = OpenID::AX::FetchResponse.from_success_response(response)
            if (ax_resp)
                user.merge!(ax_resp.data)
            end

            return user
            
        # response failure
        else
            return false
        end
    end
end
