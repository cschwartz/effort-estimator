require 'rails_helper'

RSpec.describe "SessionParticipants", type: :request do
  include Warden::Test::Helpers

  let(:turbo_stream_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }
  let(:turbo_stream_content_type) { "text/vnd.turbo-stream.html" }

  let(:user) { User.create!(email: "user@example.com", password: "password123", password_confirmation: "password123") }
  let(:facilitator) { User.create!(email: "facilitator@example.com", password: "password123", password_confirmation: "password123") }
  let(:project) { Project.create!(title: "Test Project") }
  let(:estimation_option) { EstimationOption.create!(title: "Fibonacci") }
  let(:estimation_session) do
    EstimationSession.create!(
      project: project,
      estimation_option: estimation_option,
      facilitator: facilitator,
      status: :active
    )
  end

  before do
    # Add facilitator as participant
    estimation_session.session_participants.create!(
      user: facilitator,
      joined_at: Time.current,
      status: :active
    )
    login_as user, scope: :user
  end

  after do
    Warden.test_reset!
  end

  describe "POST /projects/:project_id/estimation_session/participants" do
    context "when estimation session exists" do
      it "creates a new session participant" do
        expect {
          post project_estimation_session_session_participants_path(project)
        }.to change(SessionParticipant, :count).by(1)
      end

      it "adds current user as participant" do
        post project_estimation_session_session_participants_path(project)
        participant = SessionParticipant.last
        expect(participant.user).to eq(user)
        expect(participant.estimation_session).to eq(estimation_session)
        expect(participant.status).to eq("active")
      end

      it "redirects to estimation session page" do
        post project_estimation_session_session_participants_path(project)
        expect(response).to redirect_to(project_estimation_session_path(project))
      end

      it "sets success notice" do
        post project_estimation_session_session_participants_path(project)
        expect(flash[:notice]).to eq("Joined estimation session.")
      end

      it "does not create duplicate participant" do
        estimation_session.session_participants.create!(
          user: user,
          joined_at: Time.current,
          status: :active
        )

        expect {
          post project_estimation_session_session_participants_path(project)
        }.not_to change(SessionParticipant, :count)
      end
    end

    context "when estimation session does not exist" do
      before do
        estimation_session.update!(status: :completed)
      end

      it "does not create a session participant" do
        expect {
          post project_estimation_session_session_participants_path(project)
        }.not_to change(SessionParticipant, :count)
      end

      it "redirects to project page" do
        post project_estimation_session_session_participants_path(project)
        expect(response).to redirect_to(project_path(project))
      end

      it "sets error alert" do
        post project_estimation_session_session_participants_path(project)
        expect(flash[:alert]).to eq("No active estimation session")
      end
    end
  end

  describe "DELETE /projects/:project_id/estimation_session/participants/:id" do
    let!(:participant) do
      estimation_session.session_participants.create!(
        user: user,
        joined_at: Time.current,
        status: :active
      )
    end

    context "when user is a participant" do
      it "updates participant status to left" do
        delete project_estimation_session_session_participant_path(project, participant)
        expect(participant.reload.status).to eq("left")
      end

      it "does not destroy the participant record" do
        expect {
          delete project_estimation_session_session_participant_path(project, participant)
        }.not_to change(SessionParticipant, :count)
      end

      it "redirects to project page" do
        delete project_estimation_session_session_participant_path(project, participant)
        expect(response).to redirect_to(project_path(project))
      end

      it "sets success notice" do
        delete project_estimation_session_session_participant_path(project, participant)
        expect(flash[:notice]).to eq("You have left the estimation session.")
      end
    end

    context "when user is facilitator" do
      before do
        login_as facilitator, scope: :user
      end

      let(:facilitator_participant) do
        estimation_session.session_participants.find_by(user: facilitator)
      end

      it "allows facilitator to leave" do
        delete project_estimation_session_session_participant_path(project, facilitator_participant)
        expect(facilitator_participant.reload.status).to eq("left")
      end

      it "does not destroy the participant record" do
        expect {
          delete project_estimation_session_session_participant_path(project, facilitator_participant)
        }.not_to change(SessionParticipant, :count)
      end

      it "redirects to project page" do
        delete project_estimation_session_session_participant_path(project, facilitator_participant)
        expect(response).to redirect_to(project_path(project))
      end
    end

    context "when user is not a participant" do
      let(:other_user) { User.create!(email: "other@example.com", password: "password123", password_confirmation: "password123") }

      before do
        login_as other_user, scope: :user
      end

      it "does not update any participant" do
        original_status = participant.status
        delete project_estimation_session_session_participant_path(project, participant)
        expect(participant.reload.status).to eq(original_status)
      end

      it "redirects to estimation session page" do
        delete project_estimation_session_session_participant_path(project, participant)
        expect(response).to redirect_to(project_estimation_session_path(project))
      end

      it "sets error alert" do
        delete project_estimation_session_session_participant_path(project, participant)
        expect(flash[:alert]).to eq("You can only leave your own session.")
      end
    end

    context "when estimation session does not exist" do
      before do
        estimation_session.update!(status: :completed)
      end

      it "does not update the participant" do
        original_status = participant.status
        delete project_estimation_session_session_participant_path(project, participant)
        expect(participant.reload.status).to eq(original_status)
      end

      it "redirects to project page" do
        delete project_estimation_session_session_participant_path(project, participant)
        expect(response).to redirect_to(project_path(project))
      end

      it "sets error alert" do
        delete project_estimation_session_session_participant_path(project, participant)
        expect(flash[:alert]).to eq("No active estimation session")
      end
    end
  end
end
