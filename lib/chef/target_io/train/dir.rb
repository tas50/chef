require_relative "file"
require_relative "fileutils"

module TargetIO
  module TrainCompat
    class Dir
      class << self
        # TODO: chdir, mktmpdir, pwd, home (Used in Resources)

        def [](*patterns, base: ".", sort: true)
          Dir.glob(patterns, 0, base, sort)
        end

        def delete(dir_name)
          ::TargetIO::FileUtils.rm_rf(dir_name)
        end

        def directory?(dir_name)
          ::TargetIO::File.directory? dir_name
        end

        def entries(dirname)
          cmd = "ls -1a #{dirname}"
          output = __run_command(cmd).stdout
          output.split("\n")
        end

        def glob(pattern, flags = 0, base: ".", sort: true)
          raise "Dir.glob flags not supported except FNM_DOTMATCH" unless [0, ::File::FNM_DOTMATCH].include? flags

          pattern  = Array(pattern)
          matchdot = flags || ::File::FNM_DOTMATCH ? "dotglob" : ""

          # TODO: Check for bash remotely
          cmd += <<-BASH4
            shopt -s globstar #{matchdot}
            cd #{base}
            for f in #{pattern.join(" ")}; do
              printf '%s\n' "$f";
            done
          BASH4

          output = __run_command(cmd).stdout
          files  = output.split("\n")
          files.sort! if sort

          files
        end

        def mkdir(dir_name, mode = nil)
          ::TargetIO::FileUtils.mkdir(dir_name)
          ::TargetIO::FileUtils.chmod(dir_name, mode) if mode
        end

        # Borrowed and adapted from Ruby's Dir::tmpdir and Dir::mktmpdir
        def mktmpdir(prefix_suffix = nil, *rest, **options)
          prefix, suffix = ::File.basename(prefix_suffix || "d")
          random = (::Random.urandom(4).unpack1("L") % 36**6).to_s(36)

          tmpdir = ::Dir.tmpdir
          t = Time.now.strftime("%Y%m%d%s")
          path = "#{prefix}#{t}-#{$$}-#{random}" "#{suffix || ""}"
          path = ::File.join(tmpdir, path)

          ::TargetIO::FileUtils.mkdir(path)
          ::TargetIO::FileUtils.chmod(0700, path)

          at_exit do
            ::TargetIO::FileUtils.rm_rf(path)
          end

          path
        end

        def unlink(dir_name)
          ::TargetIO::FileUtils.rmdir(dir_name)
        end

        def __run_command(cmd)
          __transport_connection.run_command(cmd)
        end

        def __transport_connection
          Chef.run_context&.transport_connection
        end
      end
    end
  end
end
