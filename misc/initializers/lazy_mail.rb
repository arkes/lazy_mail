# You have to set the default :from
#
LazyMail.default_no_reply = 'no-reply@set-the-no-reply.com'

# To set the option :to by default
# Put the name of a model
#
LazyMail.user_model = User

# By default it will call the method email of your model
#
# LazyMail.email_field = :email

# I18n subject is a scope: [:mailer, :mailer_name, :action_name]
# If you want the rails default set it to nil
# key works: :mailer_name, :action_name
#
# LazyMail.i18n_scope = [:mailer, :class_name, :action_name]


# By default the mail view are in: 'app/views/notifications/mailer_name/current_locale/'
# If you prefer the rails default set it to nil
# default: 'notifications'
#
# LazyMail.mailer_templates_path = 'notifications'

# For the development phase you can set a default :to
# String: If you want the same email
# :git : If want to use 'git config user.email'
# default: :git
#
# LazyMail.development_mail = :git