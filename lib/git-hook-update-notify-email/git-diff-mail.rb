
module GitHookUpdateNotifyEmail
  class GitDiffMail < ActionMailer::Base

    require 'redcloth' # needed for textilize in the view

    def self.view_paths
      ActionView::Base.process_view_paths File.join(File.dirname(__FILE__), 'view')
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

      part(:content_type => "text/html",
           # leading '/' short-circuits the classic Rails template tree layout
           :body => render_message('/diff-email',
                                   :git_rev => git_rev))
    end
  end
end
