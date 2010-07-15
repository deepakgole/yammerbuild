require "rubygems"
require 'sqlite3'
require 'activerecord'
require 'action_mailer'
require 'smtp-tls'
require 'integrity'

module YammerBuild

 class Notifier < ActionMailer::Base

  def self.send_email()
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "/var/www/apps/integrity/integrity.db")
    build_yml = YAML.load_file("/var/www/apps/yammerbuild/lib/last_build.yml")
    p build_yml
    last_build_id = build_yml["last_build_id"]
    p last_build_id
    number_of_builds_to_yammer = ActiveRecord::Base.connection.execute("SELECT * FROM 'integrity_builds' where id>#{last_build_id} and completed_at is not NULL")
    number_of_builds_to_yammer.each do |build|
#     if build["successful"] != 't'
      project_name, success, commit = pull_last_commit_data_from_integrity(build["id"])
      YammerBuild::Notifier.deliver_email(project_name, success, commit)
#     end
    end
    p number_of_builds_to_yammer.last["id"]
    dump_hash = {"last_build_id"=>number_of_builds_to_yammer.last["id"]}
    File.open("/var/www/apps/yammerbuild/lib/last_build.yml", 'w') { |f| YAML.dump(dump_hash, f) }

  end

  def self.pull_last_commit_data_from_integrity(build_id)
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "/var/www/apps/integrity/integrity.db")
#   build =  ActiveRecord::Base.connection.execute("SELECT MAX ( id ) build_max_id FROM 'integrity_builds'")

    build = ActiveRecord::Base.connection.execute("SELECT * FROM 'integrity_builds' where id='#{build_id}'")
    p "=================Build Id=#{build[0]['id']}========"
    commit = ActiveRecord::Base.connection.execute("SELECT * from 'integrity_commits' where id='#{build[0]["commit_id"]}' ")
   p "=================Commit Id=#{commit[0]['id']}========"
    project = ActiveRecord::Base.connection.execute("SELECT * from 'integrity_projects' where id='#{commit[0]["project_id"]}' ")
    p "=================Project Id=#{project[0]['id']}========"
    success = build[0]["successful"] == 'f' ? "fail" : "pass"
    p build[0]["successful"]
    p success
    email_setup(project[0]["name"], success, commit[0]["author"] )
    return project[0]["name"], success, commit[0]
  end


  def self.email_setup(project_name, success, who_committed)
   YammerBuild::Notifier.template_root = File.dirname(__FILE__)
   YammerBuild::Notifier.delivery_method = :smtp
   if success == "pass"
     YammerBuild::Notifier.smtp_settings = {:enable_starttls_auto => true, :address => "smtp.gmail.com",:port => 587,:domain =>  "sapnasolutions.com",
                             :user_name =>"qa@sapnasolutions.com",:password => "deepak",:authentication => :plain}
   else
     YammerBuild::Notifier.smtp_settings = {:enable_starttls_auto => true, :address => "smtp.gmail.com",:port => 587,:domain =>  "sapnasolutions.com",
                             :user_name =>"contact@sapnasolutions.com",:password => "xVU8QkcFpdM1",:authentication => :plain}
   end
   YammerBuild::Notifier.perform_deliveries = true
   YammerBuild::Notifier.raise_delivery_errors = false
   YammerBuild::Notifier.default_charset = "utf-8"
   YammerBuild::Notifier.default_content_type = "text/html"
  end


  def email(project_name, success, commit)
    yammer_groups_yml = YAML.load_file("/var/www/apps/yammerbuild/lib/yammer_groups.yml")
    yammer_names_yml = YAML.load_file("/var/www/apps/yammerbuild/lib/yammer_names.yml")
    p "=============groups name=#{yammer_groups_yml[project_name]}========="
    p commit["author"]
    p "=============author name=#{yammer_names_yml[commit["author"].split(" <").first]}========="
    @subject = "#{project_name} build #{success}"
    @recipients = ["#{yammer_groups_yml[project_name]}", "deepak@sapnasolutions.com"]
#    @recipients = ["deepak@sapnasolutions.com"]
    @body["project_name"] = project_name
    @body["who_committed"] = yammer_names_yml[commit["author"].split(" <").first]
    @body["message"] = commit["message"]
    @body["committed_at"] = commit["committed_at"]
  end

 end


end

