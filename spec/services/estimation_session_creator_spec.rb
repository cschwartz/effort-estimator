require "rails_helper"

RSpec.describe EstimationSessionCreator do
  describe ".call" do
    let(:project) { create(:project) }
    let(:facilitator) { create(:user) }
    let(:estimation_option) { create(:estimation_option) }

    context "with valid inputs" do
      let!(:category1) { create(:category, project: project, category_type: :scaled) }
      let!(:category2) { create(:category, project: project, category_type: :absolute) }
      let!(:parameter) { create(:parameter, project: project) }
      let!(:root_effort) { create(:effort, project: project, parent: nil) }
      let!(:leaf_effort) { create(:effort, project: project, parent: root_effort) }

      it "returns success: true" do
        result = described_class.call(
          project: project,
          facilitator: facilitator,
          estimation_option: estimation_option
        )

        expect(result.success).to be true
      end

      it "creates an estimation session" do
        expect {
          described_class.call(
            project: project,
            facilitator: facilitator,
            estimation_option: estimation_option
          )
        }.to change(EstimationSession, :count).by(1)
      end

      it "sets the session attributes correctly" do
        result = described_class.call(
          project: project,
          facilitator: facilitator,
          estimation_option: estimation_option
        )

        session = result.session
        expect(session.project).to eq(project)
        expect(session.facilitator).to eq(facilitator)
        expect(session.estimation_option).to eq(estimation_option)
        expect(session.status).to eq("active")
      end

      it "sets the current_effort to the first leaf" do
        result = described_class.call(
          project: project,
          facilitator: facilitator,
          estimation_option: estimation_option
        )

        expect(result.session.current_effort).to eq(leaf_effort)
      end

      it "creates a facilitator participant" do
        result = described_class.call(
          project: project,
          facilitator: facilitator,
          estimation_option: estimation_option
        )

        participant = result.session.session_participants.first
        expect(participant.user).to eq(facilitator)
        expect(participant.status).to eq("active")
        expect(participant.joined_at).to be_present
      end

      it "creates effort estimates for all categories and leaf efforts" do
        result = described_class.call(
          project: project,
          facilitator: facilitator,
          estimation_option: estimation_option
        )

        expect(result.session.effort_estimates.count).to eq(2) # 2 categories * 1 leaf
        expect(result.session.effort_estimates.pluck(:category_id)).to match_array([ category1.id, category2.id ])
        expect(result.session.effort_estimates.pluck(:effort_id).uniq).to eq([ leaf_effort.id ])
      end

      it "activates the first category" do
        result = described_class.call(
          project: project,
          facilitator: facilitator,
          estimation_option: estimation_option
        )

        first_estimate = result.session.effort_estimates.order(:category_id).first
        expect(first_estimate.status).not_to eq("pending")
      end

      it "sets parameter_selection status for scaled categories" do
        result = described_class.call(
          project: project,
          facilitator: facilitator,
          estimation_option: estimation_option
        )

        scaled_estimate = result.session.effort_estimates.find_by(category: category1)
        expect(scaled_estimate.status).to eq("parameter_selection")
      end

      it "sets voting status for absolute categories when they are first" do
        # Create a new project with only absolute category to test this scenario
        new_project = create(:project)
        category_absolute_first = create(:category, project: new_project, category_type: :absolute)
        leaf = create(:effort, project: new_project, parent: nil)

        result = described_class.call(
          project: new_project,
          facilitator: facilitator,
          estimation_option: estimation_option
        )

        absolute_estimate = result.session.effort_estimates.find_by(category: category_absolute_first)
        expect(absolute_estimate.status).to eq("voting")
      end

      context "with multiple leaf efforts" do
        let!(:leaf_effort2) { create(:effort, project: project, parent: root_effort) }

        it "creates estimates for all leaves" do
          result = described_class.call(
            project: project,
            facilitator: facilitator,
            estimation_option: estimation_option
          )

          expect(result.session.effort_estimates.count).to eq(4) # 2 categories * 2 leaves
        end

        it "sets all estimates except first to pending" do
          result = described_class.call(
            project: project,
            facilitator: facilitator,
            estimation_option: estimation_option
          )

          pending_estimates = result.session.effort_estimates.where(status: :pending)
          expect(pending_estimates.count).to eq(3) # All except first category of first leaf
        end
      end

      context "with nested effort structure" do
        # Create a fresh project for this test to avoid conflicts with existing leaf_effort
        let(:nested_project) { create(:project) }
        let!(:nested_category) { create(:category, project: nested_project) }
        let!(:parent) { create(:effort, project: nested_project, parent: nil) }
        let!(:child) { create(:effort, project: nested_project, parent: parent) }
        let!(:grandchild) { create(:effort, project: nested_project, parent: child) }

        it "finds leaf efforts in DFS order" do
          result = described_class.call(
            project: nested_project,
            facilitator: facilitator,
            estimation_option: estimation_option
          )

          # First leaf in DFS order should be the current effort
          expect(result.session.current_effort).to eq(grandchild)
        end
      end
    end

    context "with invalid inputs" do
      context "when project has no efforts at all" do
        let!(:category) { create(:category, project: project) }

        it "returns success: false" do
          result = described_class.call(
            project: project,
            facilitator: facilitator,
            estimation_option: estimation_option
          )

          expect(result.success).to be false
        end

        it "includes an error message" do
          result = described_class.call(
            project: project,
            facilitator: facilitator,
            estimation_option: estimation_option
          )

          expect(result.errors).to include("Project must have at least one leaf effort to estimate")
        end

        it "does not create a session participant" do
          expect {
            described_class.call(
              project: project,
              facilitator: facilitator,
              estimation_option: estimation_option
            )
          }.not_to change(SessionParticipant, :count)
        end

        it "rolls back the session creation" do
          result = described_class.call(
            project: project,
            facilitator: facilitator,
            estimation_option: estimation_option
          )

          expect(EstimationSession.count).to eq(0)
        end
      end

      context "when session validation fails" do
        it "returns success: false" do
          # Create invalid scenario by passing nil facilitator
          result = described_class.call(
            project: project,
            facilitator: nil,
            estimation_option: estimation_option
          )

          expect(result.success).to be false
        end

        it "includes validation errors" do
          result = described_class.call(
            project: project,
            facilitator: nil,
            estimation_option: estimation_option
          )

          expect(result.errors).to be_present
          expect(result.errors.first).to include("Facilitator")
        end
      end
    end

    context "transaction rollback" do
      let!(:category) { create(:category, project: project) }
      let!(:leaf_effort) { create(:effort, project: project, parent: nil) }

      it "rolls back all changes on error" do
        # Stub to force an error during participant creation
        allow_any_instance_of(SessionParticipant).to receive(:save).and_return(false)
        allow_any_instance_of(SessionParticipant).to receive(:errors).and_return(
          double(full_messages: [ "Forced error" ])
        )

        expect {
          described_class.call(
            project: project,
            facilitator: facilitator,
            estimation_option: estimation_option
          )
        }.not_to change(EstimationSession, :count)

        expect(EffortEstimate.count).to eq(0)
      end
    end
  end
end
