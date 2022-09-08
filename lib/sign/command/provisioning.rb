module Sign
    class Command
        class Provisioning < Command
            self.summary = '展示和清除本机安装的描述文件'
            self.description = '展示和清除本机安装的描述文件'
            self.command = 'provisioning'
            self.arguments = [
                CLAide::Argument.new('Provisioning Profiles Path', false)
            ]
            def self.options
                [
                    ["--list", "列出本机安装的所有描述文件"],
                    ["--clean", "清除本机已安装的所有描述文件"]
                ]
            end

            def initialize(argv)
                @list = argv.flag?("list", true)
                @clean = argv.flag?("clean", false)

                @profile_path = argv.shift_argument || "~/Library/MobileDevice/Provisioning\ Profiles/"
                super
            end
  
            def validate!
              super
            end
  
            def run
                @profile_path = File.expand_path(@profile_path)
                if !File.exist?(@profile_path)
                    puts "没有找到`mobile provision`的安装路径, #{@profile_path}"
                    return
                end

                if @clean
                    clean_pp
                else
                    find_pp
                end
            end
            
            private
            def clean_pp
                FileUtils.chdir(@profile_path)

                Dir.glob("*.mobileprovision").each do |file|
                    FileUtils.rm_rf(file)
                end
                puts "mobileprovision files clean success"
            end

            def find_pp
                FileUtils.chdir(@profile_path)

                index = 0
                Dir.glob("*.mobileprovision").each do |file|
                    name = print_pp_info("Name", file)
                    identifier = print_pp_info("Entitlements:application-identifier", file)
                    uuid = print_pp_info("UUID", file) || ''
                    team_name = print_pp_info("TeamName", file) || ''
                    create_date = print_pp_info("CreationDate", file) || ''
                    expiration_date = print_pp_info("ExpirationDate", file) || ''

                    puts "#{index += 1})".red " #{name}".green
                    puts "   application-identifier: ".yellow "#{identifier}".green
                    puts "   UUID: ".yellow "#{uuid}".green
                    puts "   TeamName: ".yellow "#{team_name}".green
                    puts "   CreationDate: ".yellow "#{create_date}".green
                    puts "   ExpirationDate: ".yellow "#{expiration_date}".green
                end
            end
            
            def print_pp_info(name, file)
                command = "/usr/libexec/PlistBuddy -c 'Print :#{name}' /dev/stdin <<< $(security cms -D -u 11 -i #{file})"
                `#{command}`.lines.to_a.first.strip! || ''
            end
        end
    end
end