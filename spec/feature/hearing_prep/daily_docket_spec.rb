require "rails_helper"

RSpec.feature "Hearing prep" do
  context "Daily docket" do
    let!(:current_user) { User.authenticate!(roles: ["Hearing Prep"]) }

    let!(:vacols_staff) { create(:staff, user: current_user) }

    before do
      create(:case_hearing,
             board_member: vacols_staff.sattyid,
             hearing_type: HearingDay::REQUEST_TYPES[:central],
             hearing_date: Time.zone.today + 25.days,
             folder_nr: create(:case).bfkey)
      create(:hearing, hearing_day: create(:hearing_day, judge: current_user, scheduled_for: 1.year.from_now))
    end

    scenario "Legacy daily docket saves to the backend" do
      visit "/hearings/dockets/" + 25.days.from_now.to_date.to_s
      expect(page).to have_content("Daily Docket")
      fill_in "Notes", with: "This is a note about the hearing!"
      find(".checkbox-wrapper-1-prep").find(".cf-form-checkbox").click
      find(".dropdown-1-disposition").click
      find("#react-select-2--option-1").click
      find(".dropdown-1-aod").click
      find("#react-select-3--option-2").click
      find(".dropdown-1-hold_open").click
      find("#react-select-4--option-2").click
      find("label", text: "Transcript Requested").click

      visit "/hearings/dockets/" + 25.days.from_now.to_date.to_s
      expect(page).to have_content("This is a note about the hearing!")
      expect(page).to have_content("No Show")
      expect(page).to have_content("60 days")
      expect(page).to have_content("None")
      expect(find_field("Transcript Requested", visible: false)).to be_checked
      expect(find_field("1-prep", visible: false)).to be_checked
    end

    scenario "AMA daily docket saves to the backend" do
      visit "/hearings/dockets/" + Hearing.first.scheduled_for.to_date.to_s
      expect(page).to have_content("Daily Docket")
      fill_in "1.notes", with: "This is a note about the hearing!"
      find(".checkbox-wrapper-1-prep").find(".cf-form-checkbox").click
      find(".dropdown-1-disposition").click
      find("#react-select-2--option-1").click
      find("label", text: "Yes, Waive 90 Day Hold").click

      visit "/hearings/dockets/" + Hearing.first.scheduled_for.to_date.to_s
      expect(page).to have_content("This is a note about the hearing!")
      expect(page).to have_content("No Show")
      expect(find_field("1.evidence_window_waived", visible: false)).to be_checked
      expect(find_field("1-prep", visible: false)).to be_checked
    end
  end
end