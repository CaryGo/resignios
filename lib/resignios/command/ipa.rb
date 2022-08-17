module Resign
    class Command
        class IPA < Command
            self.summary = "ipa重签名"
            self.description = 'ipa包重签名'
            self.command = "ipa"
            self.abstract_command = false
            self.arguments = [
                CLAide::Argument.new('IPA PATH', false)
            ]
            def self.options
                [
                ]
            end
            def initialize(argv)
                @ipa_path = argv.shift_argument
                super
            end
            def validate!
                super
            end
            def run
                puts @ipa_path unless @ipa_path.nil?
            end
        end
    end    
end