# frozen_string_literal: true

require "rails_helper"

describe "Visit a proposal", type: :system do
  let(:organization) { create(:organization) }
  let!(:process) do
    create(:participatory_process, :active, :promoted, organization: organization)
  end

  before do
    switch_to_host(organization.host)
    visit decidim_participatory_processes.participatory_processes_path
  end

  describe "music player" do
    it "plays the music when the page is loaded" do
      within first(".card__content") do
        find("h2.card__title").click
      end

      audio_element = find("audio#audio")

      sleep 2
      expect(audio_element[:paused]).to eq("false")
      expect(audio_element[:loop]).to eq("true")
    end
  end
end
