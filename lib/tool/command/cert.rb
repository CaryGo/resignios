
module ResignTool
    class Command
        class Cert < Command
            self.summary = "列出本机安装的所有证书信息"
            self.description = '列出本机安装的所有证书信息'
            self.command = "cert"
            self.abstract_command = false
            self.arguments = [
            ]
            def self.options
                [
                    ["--valid", "输出有效证书"],
                    ["--codesigning", "只输出用于iOS签名的证书信息"]
                ]
            end
            def initialize(argv)
                @valid = argv.flag?("valid", true)
                @codesigning = argv.flag?("codesigning", false)
                super
            end
            def validate!
                super
            end
            def run
                command = 'security find-identity' << (@valid ? ' -v' : '') << (@codesigning ? ' -p codesigning' : '')
                exec "#{command}"
            end
        end
    end
end