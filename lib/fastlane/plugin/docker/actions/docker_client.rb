module Fastlane
  module Actions
    class DockerClient
      def build(repository, path, dockerfile, argMap, tag: "latest")
        build_args = []
        argMap.each do |key,value|
          build_args << "--build-arg #{key.shellescape}=#{value.shellescape}"
        end

        build_args_str = build_args.join(" ")
        result = Actions.sh "docker build #{build_args_str} -f #{dockerfile.shellescape} --pull -t #{repository.shellescape}:#{tag.shellescape} #{path.shellescape}"

        # Image ID is the last word of the last line
        return result.lines.last.split(" ").last
      end

      def login(username, password, email: nil)
        require 'open3'
        require 'shellwords'

        cmd = %W[docker login --username #{username} --password-stdin]
        cmd << "--email=\"#{email}\"" unless email.nil?

        Open3.capture2("cat - | " + cmd.shelljoin, stdin_data: password)
      end

      def push(repository, tag: nil)
        cmd = "docker push #{repository}"
        cmd << ":#{tag}" unless tag.nil?

        Actions.sh cmd
      end
    end
  end
end
