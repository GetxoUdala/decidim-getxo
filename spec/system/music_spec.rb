# frozen_string_literal: true

require "rails_helper"

describe "Visit a proposal", type: :system do
  let(:organization) { create(:organization) }
  let!(:process_old) { create(:participatory_process, :active, :promoted, organization: organization, created_at: "31.12.2022".to_date) }
  let!(:process_new) { create(:participatory_process, :active, :promoted, organization: organization, created_at: "01.01.2023".to_date) }
  let(:autoplay) { "true" }

  before do
    allow(ENV).to receive(:fetch).with("GETXO_AUTOPLAY").and_return(autoplay)
    switch_to_host(organization.host)
    visit decidim_participatory_processes.participatory_processes_path
  end

  describe "music player" do
    context "when process is old" do
      it "doesn't play music" do
        within first("#highlighted-processes") do
          find("h2.card__title", text: translated(process_old.title)).click
        end
        expect(page).to have_no_selector("audio")
      end
    end

    context "when process is new" do
      it "plays the music when the page is loaded" do
        within first("#highlighted-processes") do
          find("h2.card__title", text: translated(process_new.title)).click
        end

        audio_element = find("audio#audio")

        sleep 2
        expect(audio_element[:paused]).to eq("false")
        expect(audio_element[:loop]).to eq("true")
      end
    end

    context "when autoplay is disabled" do
      let(:autoplay) { "false" }

      it "doesn't play the music when the page is loaded" do
        within first("#highlighted-processes") do
          find("h2.card__title", text: translated(process_new.title)).click
        end
        expect(page).to have_no_selector("audio")
      end
    end
  end
end
