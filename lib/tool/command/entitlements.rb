
module ResignTool
    class Command
        class Entitlements < Command
            self.summary = "生成用于重签名的plist文件entitlements.plist"
            self.description = '生成用于重签名的plist文件entitlements.plist'
            self.command = "entitlements"
            self.abstract_command = false
            self.arguments = [
                CLAide::Argument.new('Provisioning Profiles Path', true)
            ]
            def self.options
                []
            end
            def initialize(argv)
                @profile_path = argv.shift_argument
                super
            end
            def validate!
                super
                help! "必须输入描述文件路径！" unless @profile_path
                
                @profile_path = File.expand_path(@profile_path)
                help! "传入的描述文件不存在！" unless File.exist?(@profile_path)
            end
            def run
                command = "/usr/libexec/PlistBuddy -x -c \"print :Entitlements \" /dev/stdin <<< $(security cms -D -i #{@profile_path}) > entitlements.plist"
                `#{command}`

                # 签名命令
                # /usr/bin/codesign --continue -fs $EXPANDED_CODE_SIGN_IDENTITY "framework/dylib/CydiaSubstrate"
                # /usr/bin/codesign --continue -fs $EXPANDED_CODE_SIGN_IDENTITY --entitlements "entitlements.plist" "app/extension"
            end
        end
    end
end