# frozen_string_literal: true

# lib/tasks/rebuild_metrics.rake
namespace :getxo do
  desc "Ensures locales in organizations are in sync with Decidim configuration"
  task rebuild_locales: :environment do
    Decidim::Organization.all.each do |organization|
      organization.available_locales = Decidim.available_locales.filter do |lang|
        organization.available_locales.include?(lang.to_s)
      end
      organization.default_locale = organization.available_locales.first unless organization.available_locales.include? organization.default_locale
      organization.save!
    end
  end

  desc "Rebuild the search index"
  task rebuild_search: :environment do
    Decidim::SearchableResource.destroy_all
    Decidim::Searchable.searchable_resources.pluck(0).each do |resource|
      resource.constantize.all.each(&:try_update_index_for_search_resource)
    end
  end

  desc "Rebuild metrics"
  task rebuild_metrics: :environment do
    days = (Date.parse(2.years.ago.to_s)..Date.yesterday).uniq
    metrics = {
      "participants" => Decidim::Metrics::ParticipantsMetricManage,
      "followers" => Decidim::Metrics::FollowersMetricManage,
      "participatory_processes" => Decidim::ParticipatoryProcesses::Metrics::ParticipatoryProcessesMetricManage,
      "assemblies" => Decidim::Assemblies::Metrics::AssembliesMetricManage,
      "comments" => Decidim::Comments::Metrics::CommentsMetricManage,
      "meetings" => Decidim::Meetings::Metrics::MeetingsMetricManage,
      "proposals" => Decidim::Proposals::Metrics::ProposalsMetricManage,
      "accepted_proposals" => Decidim::Proposals::Metrics::AcceptedProposalsMetricManage,
      "votes" => Decidim::Proposals::Metrics::VotesMetricManage,
      "endorsements" => Decidim::Proposals::Metrics::EndorsementsMetricManage,
      "survey_answers" => Decidim::Surveys::Metrics::AnswersMetricManage,
      "results" => Decidim::Accountability::Metrics::ResultsMetricManage,
      "debates" => Decidim::Debates::Metrics::DebatesMetricManage
    }
    Decidim::Organization.find_each do |org|
      metrics.each do |key, klass|
        old_metrics = Decidim::Metric.where(organization: org).where(metric_type: key)
        days.each do |day|
          new_metrics = klass.new(day.to_s, org)
          ActiveRecord::Base.transaction do
            old_metrics.where(day: day).delete_all
            new_metrics.save
          end
        end
      end
    end
  end

  # rubocop:disable Lint/HandleExceptions
  desc "export to xliff"
  task xliff: :environment do
    I18n.backend.send(:init_translations)
    trans = I18n.backend.send(:translations)[:eu]
    s = Squasher.new
    s.squash trans, "en"
    xliff = Xliffle.new
    file = xliff.file("decidim.xliff", "en", "eu")

    s.results.each do |line|
      key = line[0].gsub(/^en\./, "")
      next unless line[1]

      begin
        file.string(key, I18n.t(key, locale: :en), line[1])
      rescue StandardError
      end
    end
    puts xliff.to_xliff
  end
  # rubocop:enable Lint/HandleExceptions

  desc "Test email server"
  task :mail_test, [:email] => :environment do |_task, args|
    raise ArgumentError if args.email.blank?

    puts "Sending a test email to #{args.email}"

    if ENV["SMTP_SETTINGS"].present?
      settings_string = ENV["SMTP_SETTINGS"].gsub(/(\w+)\s*:/, '"\1":').gsub("\\", "").gsub("'", "")
      settings = JSON.parse(settings_string).to_h
      ActionMailer::Base.smtp_settings = settings
      puts "Using custom settings!"
    end
    puts "Using configuration:"
    puts ActionMailer::Base.smtp_settings

    mail = ActionMailer::Base.mail(to: args.email,
                                   from: Decidim.mailer_sender,
                                   subject: "A test mail from #{Decidim.application_name}",
                                   body: "Sent by #{ENV["LOGNAME"]} in #{ENV["HOME"]} at #{Date.current}")
    mail.deliver_now
  rescue ArgumentError
    puts mail_usage
  end

  def mail_usage
    "Usage:
bin/rails 'getxo:mail_test[email@example.org]'

Override default configuration with the ENV var SMTP_SETTINGS:

export SMTP_SETTINGS='{address: \"stmp.example.org\", port: 25, enable_starttls_auto: true}'
"
  end
end

class Squasher
  attr_accessor :results

  def initialize
    @results = []
  end

  def squash(hash, previous_key = "")
    hash.each do |key, value|
      this_key = "#{previous_key}.#{key}"
      if value.is_a? Hash
        squash(value, this_key)
      elsif value.is_a? Array
        result = [this_key.to_s, value.inspect.to_s]
        # puts result
        @results << result
      else
        result = [this_key.to_s, value.to_s]
        # puts result
        @results << result
      end
    end
  end
end
