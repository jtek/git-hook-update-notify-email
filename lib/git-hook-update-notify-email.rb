$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'git-hook-update-notify-email/version'
require 'git-hook-update-notify-email/git-command'
require 'git-hook-update-notify-email/git-diff-mail'

module GitHookUpdateNotifyEmail
  
end
