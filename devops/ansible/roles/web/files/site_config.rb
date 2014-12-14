# site_config.rb should contain configuration options for the whole local installation of CruiseControl.rb.
# It should be located at DATA_ROOT/site_config.rb, ie, ~/.cruise/site_config.rb

# YOU MUST RESTART YOUR CRUISE CONTROL SERVER FOR ANY CHANGES MADE HERE TO TAKE EFFECT!

# Repository and project specific configuration is defined at various cruise_config.rb

# EMAIL NOTIFICATION
# ------------------

# CruiseControl.rb can notify you about build status via email. It uses ActionMailer component of Ruby on Rails 
# framework. Obviously, ActionMailer needs to know how to send out email messages. 
# If you have an SMTP server on your network, and it needs no authentication, write this in your site_config.rb:
# 
ActionMailer::Base.smtp_settings = {
  :address =>        "localhost",
  :domain =>         "webdb01-ci.learningtapestry.com",
}
#
# If you have no SMTP server at hand, you can configure email notification to use GMail SMTP server, as follows
# (of course, you'll need to create a GMail account):
#
# ActionMailer::Base.smtp_settings = {
#   :address =>        "smtp.gmail.com",
#   :port =>           587,
#   :domain =>         "yourdomain.com",
#   :authentication => :plain,
#   :user_name =>      "yourgmailaccount",
#   :password =>       "yourgmailpassword"
# }
# 
# The same approach works for other SMTP servers thet require authentication. Note that GMail's SMTP server runs on a 
# non-standard port 587 (standard port for SMTP is 25).
#
# For further details about configuration of outgoing email, see Ruby On Rails documentation for ActionMailer::Base.

# Other site-wide options are available through CruiseControl::Configuration class:

# Change how often CC.rb pings Subversion for new requests. Default is 10.seconds, which should be OK for a local
# SVN repository, but probably isn't very polite for a public repository, such as RubyForge. This can also be set for
# each project individually, through project.scheduler.polling_interval option:
CruiseControl::Configuration.default_polling_interval = 15.minutes

# How often the dashboard page refreshes itself. If you have more than 10-20 dashboards open,
# it is advisable to set it to something higher than the default 5 seconds:
# CruiseControl::Configuration.dashboard_refresh_interval = 20.seconds

# Site-wide setting for the email "from" field. This can also be set on per-project basis,
# through project.email.notifier.from attribute
CruiseControl::Configuration.email_from = 'jasonhoekstra@gmail.com'

# Root URL of the dashboard application. Setting this attribute allows various notifiers to include a link to the
# build page in the notification message.
# CruiseControl::Configuration.dashboard_url = 'http://my.cruisecontrolrb.host/'

# Disallow triggering, killing, and creating builds through the dashboard. Useful when you host CC.rb as a
# public web site (such as http://cruisecontrolrb.thoughtworks.com/projects):
# CruiseControl::Configuration.disable_admin_ui = true

# If you want to only allow one project to build at a time, uncomment this line
# by default, cruise allows multiple projects to build at a time
# CruiseControl::Configuration.serialize_builds = true

# Amount of time a project will wait to build before failing when build serialization is on
CruiseControl::Configuration.serialized_build_timeout = 10.minutes

# Amount of time a project will wait for git to load new changesets before failing
# CruiseControl::Configuration.git_load_new_changesets_timeout = 5.minutes

# Disable URLs like /projects/code/[project name]/* - used for browsing source code
# CruiseControl::Configuration.disable_code_browsing = true

# To delete build when there are more than a certain number present, uncomment this line - it will make the dashboard 
# perform better
BuildReaper.number_of_builds_to_keep = 20

# any files that you'd like to override in cruise, keep in ~/.cruise, and copy over when this file is loaded like this
site_css = CruiseControl::Configuration.data_root.join('site.css')
FileUtils.cp site_css, Rails.root.join('public', 'stylesheets', 'site.css') if site_css.exist?

