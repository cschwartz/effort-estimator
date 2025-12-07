require 'rails_helper'

RSpec.describe "EstimationSessions", type: :request do
  include Warden::Test::Helpers

  let(:user) { create(:user) }
  let(:facilitator) { create(:user) }
  let(:turbo_stream_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }
  let(:turbo_stream_content_type) { "text/vnd.turbo-stream.html" }
  let(:project) { create(:project) }
  let(:estimation_option) { create(:estimation_option) }
  let(:effort) { create(:effort, project: project) }
  let(:category) { create(:category, project: project, category_type: :scaled) }
  let(:parameter) { create(:parameter, project: project) }

  before do
    login_as user, scope: :user
  end

  after do
    Warden.test_reset!
  end

  describe "POST /projects/:project_id/estimation_session/select_parameter" do
    let(:estimation_session) do
      create(:estimation_session,
        project: project,
        facilitator: facilitator,
        estimation_option: estimation_option,
        current_effort: effort)
    end

    let(:effort_estimate) do
      create(:effort_estimate, :parameter_selection,
        estimation_session: estimation_session,
        effort: effort,
        category: category)
    end

    before do
      effort_estimate # ensure estimate exists
    end

    context "when user is the facilitator" do
      before do
        login_as facilitator, scope: :user
      end

      context "with valid parameter" do
        it "selects the parameter and transitions to voting state" do
          post select_parameter_project_estimation_session_path(project),
               params: { parameter_id: parameter.id }

          effort_estimate.reload
          expect(effort_estimate.parameter).to eq(parameter)
          expect(effort_estimate.status).to eq("voting")
        end

        it "redirects to the estimation session" do
          post select_parameter_project_estimation_session_path(project),
               params: { parameter_id: parameter.id }

          expect(response).to redirect_to(project_estimation_session_path(project))
        end

        it "sets a success notice" do
          post select_parameter_project_estimation_session_path(project),
               params: { parameter_id: parameter.id }

          expect(flash[:notice]).to eq("Parameter selected successfully.")
        end

        context "with turbo_stream format" do
          it "responds with turbo_stream" do
            post select_parameter_project_estimation_session_path(project),
                 params: { parameter_id: parameter.id },
                 headers: turbo_stream_headers

            expect(response.media_type).to eq(turbo_stream_content_type)
            expect(response).to have_http_status(:ok)
          end

          it "sets flash.now notice" do
            post select_parameter_project_estimation_session_path(project),
                 params: { parameter_id: parameter.id },
                 headers: turbo_stream_headers

            expect(flash.now[:notice]).to eq("Parameter selected successfully.")
          end
        end
      end

      context "with parameter from different project" do
        let(:other_project) { create(:project) }
        let(:other_parameter) { create(:parameter, project: other_project) }

        it "returns not found response" do
          post select_parameter_project_estimation_session_path(project),
               params: { parameter_id: other_parameter.id }

          expect(response).to have_http_status(:not_found)
        end
      end

      context "when estimate is not in parameter_selection state" do
        let(:effort_estimate) do
          create(:effort_estimate, :voting,
            estimation_session: estimation_session,
            effort: effort,
            category: category,
            parameter: parameter)
        end

        it "does not update the parameter" do
          original_parameter = effort_estimate.parameter

          post select_parameter_project_estimation_session_path(project),
               params: { parameter_id: create(:parameter, project: project).id }

          effort_estimate.reload
          expect(effort_estimate.parameter).to eq(original_parameter)
        end

        it "redirects with error message" do
          post select_parameter_project_estimation_session_path(project),
               params: { parameter_id: create(:parameter, project: project).id }

          expect(response).to redirect_to(project_estimation_session_path(project))
          expect(flash[:alert]).to include("Can only select parameter during parameter_selection state")
        end
      end
    end

    context "when user is not the facilitator" do
      before do
        login_as user, scope: :user
      end

      it "redirects with authorization error" do
        post select_parameter_project_estimation_session_path(project),
             params: { parameter_id: parameter.id }

        expect(response).to redirect_to(project_estimation_session_path(project))
        expect(flash[:alert]).to eq("Only the facilitator can perform this action.")
      end

      it "does not update the estimate" do
        post select_parameter_project_estimation_session_path(project),
             params: { parameter_id: parameter.id }

        effort_estimate.reload
        expect(effort_estimate.parameter).to be_nil
        expect(effort_estimate.status).to eq("parameter_selection")
      end
    end

    context "when no active estimate exists" do
      before do
        login_as facilitator, scope: :user
        effort_estimate.update!(status: :finalized, parameter: parameter, estimation_option_value: create(:estimation_option_value, estimation_option: estimation_option))
      end

      it "redirects with error message" do
        post select_parameter_project_estimation_session_path(project),
             params: { parameter_id: parameter.id }

        expect(response).to redirect_to(project_estimation_session_path(project))
        expect(flash[:alert]).to eq("No active estimate found.")
      end
    end
  end
end
