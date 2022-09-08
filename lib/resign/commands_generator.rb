require 'rubygems'
require 'commander/import'

require 'colored2'
require 'version'
require_relative 'resign'

module Sigh
  class CommandsGenerator

  def self.start
    self.new.run
  end

  def run
    program :name, 'resignios'
    program :version, Resignios::VERSION
    program :description, 'ios resign tool.'

    command :ipa do |c|
      c.syntax = 'resignios ipa'
      c.description = 'Resigns an existing ipa file with the given provisioning profile'
      c.option '-i', '--signing_identity STRING', String, 'The signing identity to use. Must match the one defined in the provisioning profile.'
      c.option '-x', '--version_number STRING', String, 'Version number to force binary and all nested binaries to use. Changes both CFBundleShortVersionString and CFBundleIdentifier.'
      c.option '-p', '--provisioning_profile PATH', String, '(or BUNDLE_ID=PATH) The path to the provisioning profile which should be used. '\
                'Can be provided multiple times if the application contains nested applications and app extensions, which need their own provisioning profile. '\
                'The path may be prefixed with a identifier in order to determine which provisioning profile should be used on which app.',
                &multiple_values_option_proc(c, "provisioning_profile", &proc { |value| value.split('=', 2) })
      c.option '-d', '--display_name STRING', String, 'Display name to use'
      c.option '-e', '--entitlements PATH', String, 'The path to the entitlements file to use.'
      c.option '--short_version STRING', String, 'Short version string to force binary and all nested binaries to use (CFBundleShortVersionString).'
      c.option '--bundle_version STRING', String, 'Bundle version to force binary and all nested binaries to use (CFBundleVersion).'
      c.option '--use_app_entitlements', 'Extract app bundle codesigning entitlements and combine with entitlements from new provisionin profile.'
      c.option '-g', '--new_bundle_id STRING', String, 'New application bundle ID (CFBundleIdentifier)'
      c.option '--remove_plugins', 'Remove new Application plugins'
      c.option '--keychain_path STRING', String, 'Path to the keychain that /usr/bin/codesign should use'
      c.option '-o', '--output_path STRING', String, 'Output IPA Path.'
      c.action do |args, options|
        Sigh::Resign.new.run(options, args)
      end
    end
  
    default_command :ipa
  end

  def multiple_values_option_proc(command, name)
    proc do |value|
      value = yield(value) if block_given?
      option = command.proxy_options.find { |opt| opt[0] == name } || []
      values = option[1] || []
      values << value
  
      command.proxy_options.delete option
      command.proxy_options << [name, values]
    end
  end
end
end