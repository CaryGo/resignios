require 'claide'
require 'colored2'
require 'version'

module ResignTool
    class Command < CLAide::Command
        self.summary = "iOS重签名"
        self.description = 'ipa包重签名信息查看，证书、描述文件等'
        self.command = "resigntool"
        self.abstract_command = true
        def self.options
            [
                ["--version", "Show sign tool version"]
            ]
        end
        def initialize(argv)
            @version = argv.flag?("version", false)
            super
        end
        def validate!
            if @version
                puts "#{Resignios::VERSION}"
                return
            end
            super
        end
        def run
        end
    end
end

require_relative 'command/cert'
require_relative 'command/provisioning'
require_relative 'command/entitlements'