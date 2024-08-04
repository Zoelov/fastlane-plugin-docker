module Fastlane
  module Actions
    class DockerClient
      def build(repository, path, dockerfile, changelog, tag: "latest")
        result = Actions.sh "docker build --build-arg changelog=#{changelog.shellescape} -f #{dockerfile.shellescape} --pull -t #{repository.shellescape}:#{tag.shellescape} #{path.shellescape}"

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
