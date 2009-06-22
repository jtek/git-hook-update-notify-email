require 'git-hook-update-notify-email/lang/git-diff'
require 'coderay'


module GitHookUpdateNotifyEmail
  class GitRevision

    attr_reader :sha1, :author, :committer, :tagger, :log, :module_name, :ref

    def initialize(sha1, ref, style)
      if style.nil?
        @style = YAML::load_file(File.join(File.dirname(__FILE__), '..', '..', 'style/default.yaml'))
      else
        @style = YAML::load_file(style)
      end
      @sha1 = sha1
      @ref = ref
      git_cat_file
      get_module_name
    end
    
    def self.get_all_revision(refname,old_sha1, new_sha1, style)
      all_revision = []
      a = `git rev-list ^#{old_sha1} #{new_sha1}`
      a.split("\n").each do |sha1|
        all_revision << GitRevision.new(sha1, refname, style)
      end
      all_revision.reverse
    end

    def diff_stat
      `git diff-tree --stat -M --no-commit-id #{@sha1}`
    end

    def diff_format_patch
      `git diff-tree -p -M --no-commit-id #{@sha1}`
    end

    def diff_format_coloring
      diff = diff_format_patch
      CodeRay.scan(diff, :git_diff).git(:style => :git_hook, :css => :style, :wrap => :div, :style_conf => @style)
    end

    def get_module_name
      repo_dir_spec = "git rev-parse --git-dir"
      repo = File.expand_path `#{repo_dir_spec}`.chomp
      case repo
      when '.git', '.'
      	@module_name = File.basename(Dir.pwd)
      when /(.*?)((\.git\/)?\.git)$/
        @module_name = $1
      else
        @module_name = "FIXME: git-hook-update doesn't know how to handle '#{repo}' result for '#{repo_dir_spec}"
      end
    end

    def type
      @type ||= `git cat-file -t #{@sha1}`.chomp
    end
    
    def git_cat_file
      @log = []
      a = `git cat-file #{type} #{@sha1}`
      do_log = false
      a.split("\n").each do |line|
        (do_log = true; next) if line =~ /^$/
        if line =~ /^(author|committer|tagger) (.*)<(.*)> (\d+) ([+-]\d+)$/
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
      @style['background']
    end
  end
end
