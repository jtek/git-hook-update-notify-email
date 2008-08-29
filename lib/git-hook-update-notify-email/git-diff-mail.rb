require 'actionmailer'

module GitHookUpdateNotifyEmail
  class GitDiffMail < ActionMailer::Base


    def git_diff_mail(git_rev)
      p git_rev
      email_builder = ActionView::Base.new
      recipients 'cyril.mougel@jtek.fr'
      from 'cyril.mougel@jtek.fr'
      subject "[GIT-COMMIT] #{git_rev.author[:name]} : #{git_rev.log}"
      part "text/html" do |a|
        a.body = email_builder.render(
          :inline => File.read(File.join(File.dirname(__FILE__), '/view/diff-email.html.erb')),
          :locals => {:git_rev => git_rev}
        )
      end
    end
  end
end
