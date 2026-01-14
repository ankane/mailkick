require "rails/generators"
require "rails/generators/active_record"

module Mailkick
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration
      source_root File.join(__dir__, "templates")

      def copy_migration
        migration_template "install.rb", "db/migrate/create_mailkick_opt_outs.rb", migration_version: migration_version
      end

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end

      def primary_key_type
        ", id: :#{key_type}" if key_type
      end

      def foreign_key_type
        ", type: :#{key_type}" if key_type
      end

      def key_type
        Rails.configuration.generators.options.dig(:active_record, :primary_key_type)
      end
    end
  end
end
