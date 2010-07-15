require "rubygems"
require 'sqlite3'
require 'activerecord'
require 'action_mailer'
require 'smtp-tls'
require 'integrity'

module YammerBuild

 class Notifier < ActionMailer::Base

  def self.send_email()
    project_name, success, commit = pull_last_commit_data_from_integrity
    YammerBuild::Notifier.deliver_email(project_name, success, commit)
  end

  def self.pull_last_commit_data_from_integrity
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "/var/www/apps/integrity/integrity.db")
    build =  ActiveRecord::Base.connection.execute("SELECT MAX ( id ) build_max_id FROM 'integrity_builds'")
    build = ActiveRecord::Base.connection.execute("SELECT * FROM 'integrity_builds' where id='#{build[0]["build_max_id"]}'")
    p "=================Build Id=#{build[0]['id']}========"
    commit = ActiveRecord::Base.connection.execute("SELECT * from 'integrity_commits' where id='#{build[0]["commit_id"]}' ")
    p "=================Commit Id=#{commit[0]['id']}========"
    project = ActiveRecord::Base.connection.execute("SELECT * from 'integrity_projects' where id='#{commit[0]["project_id"]}' ")
    p "=================Prprooject Id=#{project[0]['id']}========"
    success = build[0]["successful"] == 'f' ? "fail" : "pass"
    email_setup(project[0]["name"], success, commit[0]["author"] )
    return project[0]["name"], success, commit[0]
  end


  def self.email_setup(project_name, success, who_committed)
   YammerBuild::Notifier.template_root = File.dirname(__FILE__)
   YammerBuild::Notifier.delivery_method = :smtp
   if success == "pass"
     YammerBuild::Notifier.smtp_settings = {:address => "smtp.gmail.com",:port => 587,:domain =>  "sapnasolutions.com",
                             :user_name =>"qa@sapnasolutions.com",:password => "deepak",:authentication => :plain}
   else
     YammerBuild::Notifier.smtp_settings = {:address => "smtp.gmail.com",:port => 587,:domain =>  "sapnasolutions.com",
                             :user_name =>"contact@sapnasolutions.com",:password => "xVU8QkcFpdM1",:authentication => :plain}
   end
  end


  def email(project_name, success, commit)
    recipients "deepak+sapnasolutions.com@yammer.com"
    # from "sender@anotherdomain.com"
    subject "#{project_name} build #{success}"
    content_type "multipart/alternative"
    body = { :project_name => project_name, :commit_message => commit["message"], :who_committed => commit["author"]}
    @project = project_name
    @message = commit["message"]
    p "=====================#{@project} #{success}======="
    @who_committed = commit["author"]
    @committed_at = commit["committed_at"]
    part :content_type => "text/plain", :body => render_message('email', body)
  end

 end


end
