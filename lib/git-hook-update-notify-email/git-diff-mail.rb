
module GitHookUpdateNotifyEmail
  class GitDiffMail < ActionMailer::Base

    def self.template_root
      File.join(File.dirname(__FILE__), 'view')
    end

    def git_diff_mail(git_rev, options)
      recipients options[:to]
      if options[:from_email].nil?
        from git_rev.author[:email]
      else
        from options[:from_email]
      end
      if options[:project]
        bracket = "[COMMIT-#{options[:project]}]"
      else
        bracket = "[COMMIT]"
      end
      subject "#{bracket} #{git_rev.author[:name]} : #{git_rev.log}"
      content_type    "multipart/alternative"

      part :content_type => "text/html",
        :body => render_message(File.join(File.dirname(__FILE__), 'view/diff-email.html.erb'), :git_rev => git_rev)
    end
  end
end
