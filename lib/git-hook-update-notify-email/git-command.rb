module GitHookUpdateNotifyEmail
  class GitRevision

    attr_reader :sha1, :author, :committer, :tagger, :log

    def initialize(sha1)
      @sha1 = sha1
      git_cat_file
    end
    
    def self.get_all_revision(old_sha1, new_sha1)
      all_revision = []
      a = `git-rev-list ^#{old_sha1} #{new_sha1}`
      a.split('\n').each do |sha1|
        all_revision << GitRevision.new(sha1.chomp)
      end
      all_revision
    end

    def get_diff_stat
      `git-diff-tree --stat -M --no-commit-id #{@sha1}`
    end

    def get_diff_format_patch
      `git-diff-tree -p -M --no-commit-id #{@sha1}`
    end

    def type
      @type ||= `git-cat-file -t #{@sha1}`.chomp
    end
    
    def git_cat_file
      p type
      p @sha1
      @log = []
      a = `git-cat-file #{type} #{@sha1}`
      do_log = false
      a.split("\n").each do |line|
        p line
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
          @log << line
        end
      end

      p @log
      @log = @log.join("\n")
    end
  end
end
