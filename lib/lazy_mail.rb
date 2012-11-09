require 'lazy_mail/git'

module LazyMail

  class << self
    class_attribute :mailer_templates_path, :default_no_reply, :user_model,
                    :email_field, :development_mail, :i18n_scope
    
    self.mailer_templates_path = 'notifications'
    self.default_no_reply = 'no-reply@set-the-no-reply.com'
    self.user_model = nil
    self.email_field = :email
    self.development_mail = :git
    self.i18n_scope = [:mailer, :class_name, :action_name]
  end

  def self.included(base)
    base.class_eval do
      include LazyMail::Git
      include LazyMail::InstanceMethods
    end
  end

  module InstanceMethods

    def lazy_mail(*args)
      setup_mail(args)
      mail headers_for
    end

    private

    def setup_mail(args)
      @options = args.extract_options!
      set_resources(args)
      @class_name = self.class.name.underscore
      @action_name = self.action_name
    end
    
    def set_resources(args)
      if LazyMail.user_model.nil?
        raise ArgumentError, 'lazy_mail: you need to define a user_model or use option :to'
      end
      args.each do |arg|
        variable_name = arg.class.name.underscore
        variable_name = set_valid_name("#{variable_name}", 2) if instance_variable_defined?("@#{variable_name}")
        instance_variable_set("@#{variable_name}", arg)
      end
      if !instance_variable_defined?("@#{user_model.to_s.downcase}") and !@options.has_key?(:to)
        raise ArgumentError, "lazy_mail should have an instance of #{user_model.to_s} or an option :to"
      end
    end
    
    def set_valid_name(variable_name, count)
      return set_valid_name("#{variable_name}", count + 1) if instance_variable_defined?("@#{variable_name}_#{count}")
      return "#{variable_name}_#{count}"
    end
    
    def headers_for
      headers = {
        :subject       => @options.has_key?(:subject) ? @options[:subject] : translate_subject,
        :from          => @options.has_key?(:from) ? @options[:from] : LazyMail.default_no_reply,
        :to            => @options.has_key?(:to) ? @options[:to] : get_email,
        :template_path => @options.has_key?(:template_path) ? @options[:template_path] : template_path
      }
      headers
    end

    def template_path
      unless LazyMail.mailer_templates_path.nil?
        File.join(LazyMail.mailer_templates_path, @class_name, I18n.locale.to_s)
      end
    end

    def translate_subject
      return nil if LazyMail.i18n_scope.nil?
      i18n_scope = LazyMail.i18n_scope.map { |key| instance_variable_defined?("@#{key}") ? instance_variable_get("@#{key}") : key }
      I18n.t(:subject, :scope => i18n_scope)
    end
    
    def user_model
      LazyMail.user_model
    end
    
    def get_email
      if Rails.env == 'development'
        return development_mail if development_mail.is_a?(String)
        return send("#{development_mail}_email") if development_mail.is_a?(Symbol)
        raise ArgumentError, 'option development_mail should be a String or a Symbol'
      else
        instance_variable_get("@#{user_model.to_s.downcase}").send(LazyMail.email_field)
      end
    end
    
    def development_mail
      LazyMail.development_mail
    end
    
  end
end

ActionMailer::Base.send :include, LazyMail