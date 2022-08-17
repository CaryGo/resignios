
module Resign
    class Command
        class Cert < Command
            self.summary = "iOS重签名证书"
            self.description = 'iOS重签名证书'
            self.command = "cert"
            self.abstract_command = false
            self.arguments = [
                # CLAide::Argument.new('CERT', false),
            ]
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
                puts "cert"
            end
        end
    end
end