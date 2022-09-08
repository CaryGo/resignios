module Sigh
    class Resign
        def run(options, args)
            # get the command line inputs and parse those into the vars we need...
            ipa, signing_identity, provisioning_profiles, entitlements, version, display_name, short_version, bundle_version, new_bundle_id, use_app_entitlements, keychain_path = get_inputs(options, args)
            # ... then invoke our programmatic interface with these vars
            unless resign(ipa, signing_identity, provisioning_profiles, entitlements, version, display_name, short_version, bundle_version, new_bundle_id, use_app_entitlements, keychain_path)
              UI.user_error!("Failed to re-sign .ipa")
            end
        end

        def get_inputs(options, args)
            ipa = args.first || find_ipa || UI.input('Path to ipa file: ')
            signing_identity = options.signing_identity || ask_for_signing_identity
            provisioning_profiles = options.provisioning_profile || find_provisioning_profile || UI.input('Path to provisioning file: ')
            entitlements = options.entitlements || nil
            version = options.version_number || nil
            display_name = options.display_name || nil
            short_version = options.short_version || nil
            bundle_version = options.bundle_version || nil
            new_bundle_id = options.new_bundle_id || nil
            use_app_entitlements = options.use_app_entitlements || nil
            keychain_path = options.keychain_path || nil
      
            if options.provisioning_name
              UI.important "The provisioning_name (-n) option is not applicable to resign. You should use provisioning_profile (-p) instead"
            end
      
            return ipa, signing_identity, provisioning_profiles, entitlements, version, display_name, short_version, bundle_version, new_bundle_id, use_app_entitlements, keychain_path
        end
    end
end