require 'git-hook-update-notify-email/convertors/mail_html'
require 'git-hook-update-notify-email/lang/git-diff'


module GitHookUpdateNotifyEmail
  class GitRevision

    attr_reader :sha1, :author, :committer, :tagger, :log, :repo, :ref

    def initialize(sha1, ref, style=File.join(File.dirname(__FILE__), '..', '..', 'style/default.yaml'))
      @sha1 = sha1
      @ref = ref
      @style = YAML::load_file(style)
      git_cat_file
      get_repo
    end
    
    def self.get_all_revision(refname,old_sha1, new_sha1)
      all_revision = []
      a = `git-rev-list ^#{old_sha1} #{new_sha1}`
      a.split("\n").each do |sha1|
        all_revision << GitRevision.new(sha1, refname)
      end
      all_revision
    end

    def diff_stat
      `git-diff-tree --stat -M --no-commit-id #{@sha1}`
    end

    def diff_format_patch
      `git-diff-tree -p -M --no-commit-id #{@sha1}`
    end

    def diff_format_coloring
      diff = diff_format_patch
      convertor = Syntax::Convertors::MailHTML.for_syntax "git-diff"
      convertor.convert(diff, @style)
    end

    def get_repo
      repo = File.expand_path `git-rev-parse --git-dir`.chomp
      repo = repo[/(.*?)((\.git\/)?\.git)$/, 1]
      @repo = File.basename(repo)
    end

    def type
      @type ||= `git-cat-file -t #{@sha1}`.chomp
    end
    
    def git_cat_file
      @log = []
      a = `git-cat-file #{type} #{@sha1}`
      do_log = false
      a.split("\n").each do |line|
        (do_log = true; next) if line =~ /^$/
        if line =~ /^(author|committer|tagger) (.*)(<.*>) (\d+) ([+-]\d+)$/
          person = {}
          person[:name] = $2
          person[:email] = $3
          person[:date] = $4
          person[:tz] = $5
          case $1
          when 'author'
            @author = person
          when 'committer'
            @committer = person
          when 'tagger'
            @tagger = person
          else
          end
          next
        end

        if do_log
          break if line =~ /^-----BEGIN PGP SIGNATURE-----/
          @log << line
        end
      end
      @log = @log.join("\n")
    end

    def background_color
      @style[:background]
    end
  end
end
