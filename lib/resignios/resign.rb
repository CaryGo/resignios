require 'claide'
require 'colored2'

module Resign
    class Command < CLAide::Command
        self.summary = "iOS重签名"
        self.description = 'ipa包重签名'
        self.command = "resign"
        self.abstract_command = true
        def self.options
            [
            ]
        end
        def initialize(argv)
            super
        end
        def validate!
            super
        end
        def run
        end
    end
end

require_relative 'command/ipa'
require_relative 'command/cert'
require_relative 'command/provisioning'