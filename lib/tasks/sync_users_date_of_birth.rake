# frozen_string_literal: true

namespace :getxo do
  desc "Sync users extended_data['date_of_birth'] from authorization metadata['date_of_birth']"
  task sync_users_date_of_birth: :environment do
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV.fetch("DRY_RUN", "true"))
    authorization_name = ENV["AUTHORIZATION_NAME"].presence
    organization_id = ENV["ORGANIZATION_ID"].presence

    puts "Starting date_of_birth sync (dry_run=#{dry_run})"
    puts "Filtering by authorization name: #{authorization_name}" if authorization_name
    puts "Filtering by organization: #{organization_id}" if organization_id

    scope = Decidim::Authorization.where.not(granted_at: nil)
    scope = scope.where(name: authorization_name) if authorization_name
    scope = scope.joins(:user).where(Decidim::User.table_name => { decidim_organization_id: organization_id }) if organization_id

    latest_dobs_by_user_id = {}
    scanned_authorizations = 0
    invalid_dobs = 0

    scope.find_each do |authorization|
      scanned_authorizations += 1
      raw_dob = authorization.metadata&.[]("date_of_birth") || authorization.metadata&.[](:date_of_birth)
      next if raw_dob.blank?

      date_of_birth = parse_iso_date(raw_dob)
      unless date_of_birth
        invalid_dobs += 1
        next
      end

      current_value = latest_dobs_by_user_id[authorization.decidim_user_id]
      should_replace = current_value.nil? || authorization.granted_at > current_value[:granted_at]

      if should_replace
        latest_dobs_by_user_id[authorization.decidim_user_id] = {
          date_of_birth: date_of_birth.strftime("%Y-%m-%d"),
          granted_at: authorization.granted_at,
          authorization_id: authorization.id
        }
      end
    end

    puts "Scanned authorizations: #{scanned_authorizations}"
    puts "Users with candidate date_of_birth: #{latest_dobs_by_user_id.size}"
    puts "Authorizations with invalid date_of_birth metadata: #{invalid_dobs}"

    updated_users = 0
    unchanged_users = 0
    users_found = 0

    Decidim::User.where(id: latest_dobs_by_user_id.keys).find_each do |user|
      users_found += 1
      candidate = latest_dobs_by_user_id[user.id]
      target_date_of_birth = candidate[:date_of_birth]

      extended_data = (user.extended_data || {}).deep_dup
      current_date_of_birth = extended_data["date_of_birth"]

      if current_date_of_birth == target_date_of_birth
        unchanged_users += 1
        next
      end

      extended_data["date_of_birth"] = target_date_of_birth

      if dry_run
        puts "[DRY_RUN] user_id=#{user.id} #{current_date_of_birth.inspect} -> #{target_date_of_birth.inspect} (authorization_id=#{candidate[:authorization_id]})"
      else
        user.update!(extended_data:)
      end

      updated_users += 1
    end

    missing_users = latest_dobs_by_user_id.size - users_found

    puts "Users updated#{dry_run ? " (simulated)" : ""}: #{updated_users}"
    puts "Users unchanged: #{unchanged_users}"
    puts "Users missing from DB: #{missing_users}"
    puts "Done"
  end

  def parse_iso_date(raw_value)
    Date.iso8601(raw_value.to_s)
  rescue ArgumentError
    nil
  end
end
