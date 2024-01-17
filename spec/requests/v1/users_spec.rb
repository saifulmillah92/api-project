# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users" do
  setup_users(["@nick", "@capt"])

  describe "Index" do
    before do
      alphabet = ("a".."z").to_a
      alphabet.each { |i| create_user("user+#{i}@yourdomain.co") }
      Permission.set!("modules.user_management", "true", @capt.role)
    end

    let(:params) { { sort_column: "id", sort_direction: "desc" } }

    it "returns ok" do
      get_json "/v1/users", {}, as_user(@nick)
      expect_response(:ok)
    end

    it "returns oke with filter" do
      get_json "/v1/users", { q: "capt" }, as_user(@nick)
      expect_response(:ok)
      expect(response_body[:data].size).to eq(1)
    end

    it "returns empty when searching user superadmin filter" do
      get_json "/v1/users", { q: "superadmin" }, as_user(@nick)
      expect_response(:ok)
      expect(response_body[:data].size).to eq(0)
    end

    it "returns 10 data as default limit" do
      get_json "/v1/users", {}, as_user(@nick)
      expect_response(:ok)
      expect(response_body[:data].size).to eq(10)
    end

    it "returns ok set limit to 5" do
      get_json "/v1/users", { limit: 5 }, as_user(@nick)
      expect_response(:ok)
      expect(response_body[:data].size).to eq(5)
    end

    context "when paginate using param offset" do
      it "returns valid next offset" do
        get_json "/v1/users", params, as_user(@nick)
        expect_response(:ok)
        expect(response_body[:current_offset]).to eq(0)
        expect(response_body[:next_offset]).to eq(10)
        data_ids = response_body[:data].pluck(:id)

        get_json "/v1/users",
                 { offset: response_body[:next_offset] },
                 as_user(@nick)

        expect(response_body[:current_offset]).to eq(10)
        expect(response_body[:next_offset]).to eq(20)

        expect(response_body[:data].pluck(:id)).not_to eq(data_ids)
      end

      it "returns valid data when modify sort column and direction" do
        params[:sort_direction] = "asc"
        params[:sort_column] = "email"
        get_json "/v1/users", params, as_user(@nick)
        expect_response(
          :ok,
          data: [
            { username: "capt@yourdomain.com" },
            { username: "user+a@yourdomain.co" },
          ],
        )

        get_json "/v1/users", params.merge(offset: 10), as_user(@nick)
        expect_response(
          :ok,
          data: [
            { username: "user+j@yourdomain.co" },
            { username: "user+k@yourdomain.co" },
          ],
        )

        get_json "/v1/users", params.merge(offset: 20), as_user(@nick)
        expect_response(
          :ok,
          data: [
            { username: "user+t@yourdomain.co" },
            { username: "user+u@yourdomain.co" },
          ],
        )

        params[:sort_direction] = "desc"
        get_json "/v1/users", params.merge(offset: 10), as_user(@nick)
        expect_response(
          :ok,
          data: [
            { username: "user+p@yourdomain.co" },
            { username: "user+o@yourdomain.co" },
          ],
        )

        get_json "/v1/users", params.merge(offset: 0), as_user(@nick)
        expect_response(
          :ok,
          data: [
            { username: "user+z@yourdomain.co" },
            { username: "user+y@yourdomain.co" },
          ],
        )
      end
    end

    context "when paginate using param page" do
      it "returns valid next pagination" do
        get_json "/v1/users", { page: 1 }, as_user(@nick)
        expect_response(:ok)
        pagination = response_body[:pagination]
        expect(pagination[:current_page]).to eq(1)
        expect(pagination[:next_page]).to eq(2)
        expect(pagination[:prev_page]).to be_nil

        data_ids = response_body[:data].pluck(:id)
        get_json "/v1/users", { page: pagination[:next_page] }, as_user(@nick)

        pagination2 = response_body[:pagination]
        expect(pagination2[:current_page]).to eq(2)
        expect(pagination2[:next_page]).to eq(3)
        expect(pagination2[:prev_page]).to eq(1)
        expect(response_body[:data].pluck(:id)).not_to eq(data_ids)
      end

      it "returns valid data when modify sort column and direction" do
        params[:sort_direction] = "asc"
        params[:sort_column] = "email"
        get_json "/v1/users", params.merge(page: 1), as_user(@nick)
        expect_response(
          :ok,
          data: [
            { username: "capt@yourdomain.com" },
            { username: "user+a@yourdomain.co" },
          ],
        )

        get_json "/v1/users", params.merge(page: 2), as_user(@nick)
        expect_response(
          :ok,
          data: [
            { username: "user+j@yourdomain.co" },
            { username: "user+k@yourdomain.co" },
          ],
        )

        get_json "/v1/users", params.merge(page: 3), as_user(@nick)
        expect_response(
          :ok,
          data: [
            { username: "user+t@yourdomain.co" },
            { username: "user+u@yourdomain.co" },
          ],
        )

        params[:sort_direction] = "desc"
        get_json "/v1/users", params.merge(page: 2), as_user(@nick)
        expect_response(
          :ok,
          data: [
            { username: "user+p@yourdomain.co" },
            { username: "user+o@yourdomain.co" },
          ],
        )

        get_json "/v1/users", params.merge(page: 1), as_user(@nick)
        expect_response(
          :ok,
          data: [
            { username: "user+z@yourdomain.co" },
            { username: "user+y@yourdomain.co" },
          ],
        )
      end
    end

    it "doesn't do N+1 query" do
      expect do
        get_json "/v1/users", {}, as_user(@nick)
      end.not_to exceed_query_limit(4)
    end

    context "with permissions" do
      it "returns ok when user has permission" do
        Permission.set!("users.index", "true", @capt.role)
        get_json "/v1/users", {}, as_user(@capt)
        expect_response(:ok)
      end

      it "returns forbidden when user has no permission" do
        Permission.set!("users.index", "false", @capt.role)
        get_json "/v1/users", {}, as_user(@capt)
        expect_response(:forbidden)
      end
    end
  end

  describe "Create" do
    let(:params) do
      {
        username: "user1",
        email: "user1@yourdomain.co",
        password: "password",
        state: "active",
        address: address,
      }
    end

    let(:address) do
      {
        street: "jl. kp baru tegal",
        city: "bogor",
        state: "west java",
        postal_code: 16_750,
        country: "indonesia",
        phone_number: "876546456454",
      }
    end

    before { Permission.set!("modules.user_management", "true", @capt.role) }

    it "returns ok" do
      post_json "/v1/users", params, as_user(@nick)
      expect_response(:created)
    end

    it "returns error when email is not given" do
      params[:email] = nil
      post_json "/v1/users", params, as_user(@nick)
      expect_error_response(422, "Email can't be blank")
    end

    it "returns error when username is not given" do
      params[:username] = nil
      post_json "/v1/users", params, as_user(@nick)
      expect_error_response(422, "Username can't be blank")
    end

    it "returns error when state is invalid" do
      params[:state] = "hfdfhd"
      post_json "/v1/users", params, as_user(@nick)
      expect_error_response(422, "State is not included in the list")
    end

    it "returns error when password is not given" do
      params[:password] = nil
      post_json "/v1/users", params, as_user(@nick)
      expect_error_response(422, "Password can't be blank")
    end

    context "with permissions" do
      it "returns ok when user has permission" do
        Permission.set!("users.create", "true", @capt.role)
        post_json "/v1/users", params, as_user(@capt)
        expect_response(:created)
      end

      it "returns forbidden when user has no permission" do
        Permission.set!("users.create", "false", @capt.role)
        post_json "/v1/users", params, as_user(@capt)
        expect_response(:forbidden)
      end
    end
  end

  describe "Show" do
    it "returns ok" do
      get_json "/v1/users/#{@nick.id}", {}, as_user(@nick)
      expect_response(:ok, data: { id: @nick.id })
    end

    it "returns error when user is not exist" do
      get_json "/v1/users/-999", {}, as_user(@nick)
      expect_error_response(404, "Couldn't find User with 'id'=-999")
    end

    context "with permissions" do
      it "returns ok when user sees owned things" do
        get_json "/v1/users/#{@capt.id}", {}, as_user(@capt)
        expect_response(:ok)
      end

      it "returns forbidden when user has no permission" do
        get_json "/v1/users/#{@nick.id}", {}, as_user(@capt)
        expect_response(:forbidden)
      end
    end
  end

  describe "Update" do
    it "returns ok" do
      params = { email: @nick.email, username: "hello2023" }
      put_json "/v1/users/#{@nick.id}", params, as_user(@nick)
      expect_response(:ok, data: { id: @nick.id, username: "hello2023" })
    end

    it "returns error when user is not exist" do
      params = { email: @nick.email, username: "hello2023" }
      put_json "/v1/users/-999", params, as_user(@nick)
      expect_error_response(404, "Couldn't find User with 'id'=-999")
    end

    context "with permissions" do
      it "returns ok when user has permission" do
        Permission.set!("users.update", "true", @capt.role)
        params = { email: @capt.email, username: "hello2023" }
        put_json "/v1/users/#{@capt.id}", params, as_user(@capt)
        expect_response(:ok)
      end

      it "returns forbidden when user has no permission" do
        Permission.set!("users.update", "false", @capt.role)
        params = { email: @capt.email, username: "hello2023" }
        put_json "/v1/users/#{@nick.id}", params, as_user(@capt)
        expect_response(:forbidden)
      end

      it "returns ok when user updates owned things" do
        Permission.set!("users.update", "false", @capt.role)
        params = { email: @capt.email, username: "hello2023" }
        put_json "/v1/users/#{@capt.id}", params, as_user(@capt)
        expect_response(:ok)
      end
    end
  end

  describe "Destroy" do
    before { Permission.set!("modules.user_management", "true", @capt.role) }

    it "returns ok" do
      user = create_user("hello@yourdomain.co")
      delete_json "/v1/users/#{user.id}", {}, as_user(@nick)
      expect_response(:ok)

      user = User.find_by(email: "hello@yourdomain.co")
      expect(user).not_to be_present
    end

    it "returns error when user is not exist" do
      delete_json "/v1/users/-999", {}, as_user(@nick)
      expect_error_response(404, "Couldn't find User with 'id'=-999")
    end

    context "with permissions" do
      it "returns ok when user has permission" do
        keys = ["users.show", "users.index", "users.destroy"]
        keys.each do |key|
          Permission.set!(key, "true", @capt.role)
        end

        user = create_user("hello@yourdomain.co")
        delete_json "/v1/users/#{user.id}", {}, as_user(@capt)
        expect_response(:ok)
      end

      it "returns forbidden when user has no permission" do
        Permission.set!("users.destroy", "false", @capt.role)
        user = create_user("hello@yourdomain.co")

        delete_json "/v1/users/#{user.id}", {}, as_user(@capt)
        expect_response(:forbidden)
      end
    end
  end
end
