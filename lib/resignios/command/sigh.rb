module Resign
    class Command
        class Sigh < Command
            self.summary = 'iOS重签名描述文件'
            self.description = 'iOS重签名描述文件'
            self.command = "sign"
            self.abstract_command = false
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
                puts "sigh"
            end
        end
    end
end