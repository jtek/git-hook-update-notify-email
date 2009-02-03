
module GitHookUpdateNotifyEmail
  class GitDiffMail < ActionMailer::Base

    def self.template_root
      File.join(File.dirname(__FILE__), 'view')
    end

    def git_diff_mail(git_rev, to, from_email)
      recipients to
      if from_email.nil?
        from git_rev.author[:email]
      else
        from from_email
      end
      subject "[GIT-COMMIT] #{git_rev.author[:name]} : #{git_rev.log}"
      content_type    "multipart/alternative"

      part :content_type => "text/html",
        :body => render_message(File.join(File.dirname(__FILE__), 'view/diff-email.html.erb'), :git_rev => git_rev)
    end
  end
end
