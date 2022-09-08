require 'shellwords'

module Sigh
    class Resign
        def run(options, args)
            # get the command line inputs and parse those into the vars we need...
            ipa, signing_identity, provisioning_profiles, entitlements, version, display_name, short_version, bundle_version, new_bundle_id, use_app_entitlements, remove_plugins, keychain_path, output_path = get_inputs(options, args)
            # ... then invoke our programmatic interface with these vars
            unless resign(ipa, signing_identity, provisioning_profiles, entitlements, version, display_name, short_version, bundle_version, new_bundle_id, use_app_entitlements, remove_plugins, keychain_path, output_path)
                puts "Failed to re-sign .ipa".red
            end
        end

        def find_resign_path
            File.expand_path('../../assets/resign.sh', __FILE__)
        end

        def resign(ipa, signing_identity, provisioning_profiles, entitlements, version, display_name, short_version, bundle_version, new_bundle_id, use_app_entitlements, remove_plugins, keychain_path, output_path)
            resign_path = find_resign_path
            signing_identity = find_signing_identity(signing_identity)
      
            unless provisioning_profiles.kind_of?(Enumerable)
              provisioning_profiles = [provisioning_profiles]
            end
      
            # validate that we have valid values for all these params, we don't need to check signing_identity because `find_signing_identity` will only ever return a valid value
            validate_params(resign_path, ipa, provisioning_profiles)
            entitlements = "-e #{entitlements.shellescape}" if entitlements
      
            provisioning_options = create_provisioning_options(provisioning_profiles)
            version = "-n #{version}" if version
            display_name = "-d #{display_name.shellescape}" if display_name
            short_version = "--short-version #{short_version}" if short_version
            bundle_version = "--bundle-version #{bundle_version}" if bundle_version
            verbose = "-v" if $verbose
            bundle_id = "-b '#{new_bundle_id}'" if new_bundle_id
            use_app_entitlements_flag = "--use-app-entitlements" if use_app_entitlements
            remove_plugins_flag = "--remove-plugins" if remove_plugins
            specific_keychain = "--keychain-path #{keychain_path.shellescape}" if keychain_path
      
            command = [
              resign_path.shellescape,
              ipa.shellescape,
              signing_identity.shellescape,
              provisioning_options, # we are aleady shellescaping this above, when we create the provisioning_options from the provisioning_profiles
              entitlements,
              version,
              display_name,
              short_version,
              bundle_version,
              use_app_entitlements_flag,
              remove_plugins_flag,
              verbose,
              bundle_id,
              output_path || ipa.shellescape,
              specific_keychain
            ].join(' ')
      
            puts command.magenta
            puts `#{command}`
      
            if $?.to_i == 0
              puts "Successfully signed #{ipa}!"
              true
            else
              puts "Something went wrong while code signing #{ipa}".red
              false
            end
        end

        def find_signing_identity(signing_identity)
            until (signing_identity = sha1_for_signing_identity(signing_identity))
              puts "Couldn't find signing identity '#{signing_identity}'.".red
              signing_identity = ask_for_signing_identity
            end
      
            signing_identity
        end

        def sha1_for_signing_identity(signing_identity)
            identities = installed_identities
            return signing_identity if identities.keys.include?(signing_identity)
            identities.key(signing_identity)
        end

        def create_provisioning_options(provisioning_profiles)
            # provisioning_profiles is passed either a hash (to be able to resign extensions/nested apps):
            # (in that case the underlying resign.sh expects values given as "-p at.fastlane=/folder/mobile.mobileprovision -p at.fastlane.today=/folder/mobile.mobileprovision")
            #   {
            #     "at.fastlane" => "/folder/mobile.mobileprovision",
            #     "at.fastlane.today" => "/folder/mobile.mobileprovision"
            #   }
            # or an array
            # (resign.sh also takes "-p /folder/mobile.mobileprovision" as a param)
            #   [
            #        "/folder/mobile.mobileprovision"
            #   ]
            provisioning_profiles.map do |app_id, app_id_prov|
              if app_id_prov
                app_id_prov = File.expand_path(app_id_prov)
              else
                app_id = File.expand_path(app_id)
              end
              "-p #{[app_id, app_id_prov].compact.map(&:shellescape).join('=')}"
            end.join(' ')
        end

        def validate_params(resign_path, ipa, provisioning_profiles)
            validate_resign_path(resign_path)
            validate_ipa_file(ipa)
            provisioning_profiles.each { |fst, snd| validate_provisioning_file(snd || fst) }
        end

        def validate_resign_path(resign_path)
            puts 'Could not find resign.sh file. Please try re-installing the gem'.red unless File.exist?(resign_path)
        end
    
        def validate_ipa_file(ipa)
            puts "ipa file could not be found or is not an ipa file (#{ipa})".red unless File.exist?(ipa) && ipa.end_with?('.ipa')
        end
    
        def validate_provisioning_file(provisioning_profile)
            unless File.exist?(provisioning_profile) && provisioning_profile.end_with?('.mobileprovision')
                puts "Provisioning profile file could not be found or is not a .mobileprovision file (#{provisioning_profile})".red
            end
        end

        def get_inputs(options, args)
            ipa = args.first || self.input('Path to ipa file: ')
            signing_identity = options.signing_identity || ask_for_signing_identity
            provisioning_profiles = options.provisioning_profile || self.input('Path to provisioning file: ')
            entitlements = options.entitlements || nil
            version = options.version_number || nil
            display_name = options.display_name || nil
            short_version = options.short_version || nil
            bundle_version = options.bundle_version || nil
            new_bundle_id = options.new_bundle_id || nil
            use_app_entitlements = options.use_app_entitlements || nil
            remove_plugins = options.remove_plugins || (options.provisioning_profile.nil? ? true : false)
            keychain_path = options.keychain_path || nil
            output_path = options.output_path || ask_for_output_ipa_path
            
            if options.provisioning_name
              puts "The provisioning_name (-n) option is not applicable to resign. You should use provisioning_profile (-p) instead".yellow
            end
      
            return ipa, signing_identity, provisioning_profiles, entitlements, version, display_name, short_version, bundle_version, new_bundle_id, use_app_entitlements, remove_plugins, keychain_path, output_path
        end

        def ask_for_signing_identity
            descriptions = []
            installed_identities.group_by { |sha1, name| name }.each do |name, identities|
              descriptions << name
              # Show SHA-1 for homonymous identities
              descriptions += identities.map do |sha1, _|
                "\t#{sha1}"
              end
            end
            puts "Available identities: \n\t#{descriptions.join("\n\t")}\n"
            self.input('Signing Identity: ')
        end

        # Hash of available signing identities
        def installed_identities
            available = `security find-identity -v -p codesigning`
            ids = {}
            available.split("\n").each do |current|
                begin
                    sha1 = current.match(/[a-zA-Z0-9]{40}/).to_s
                    name = current.match(/.*\"(.*)\"/)[1]
                    ids[sha1] = name
                rescue
                    nil
                end # the last line does not match
            end
    
            ids
        end

        def ask_for_output_ipa_path
            output_path = self.input('Output path to ipa file: ')
            unless output_path.end_with?('.ipa')
                puts "Output path to ipa file error.".yellow
                return nil
            end
            output_path
        end

        def input(message)
            print "#{message}".red
            STDIN.gets.chomp.strip
        end
    end
end