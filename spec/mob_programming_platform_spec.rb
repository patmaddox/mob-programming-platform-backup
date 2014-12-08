require 'mob_programming_platform'

describe "Mob Programming Platform (MPP)" do
  let(:mpp) { MobProgrammingPlatform.new }

  it "a prospective mobster (PM) lists available sessions" do
    expect(mpp.available_sessions).to be_empty
  end

  describe "a prospective mobster (PM) creates a new session" do
    it "MPP adds a new named session to the available sessions list" do
      mpp.create_session "my new session"

      expect(mpp.available_sessions.size).to eq(1)
      expect(mpp.available_sessions).to include("my new session")
    end

    it "MPP reports success" do
      response = mpp.create_session "successful new session"

      expect(response).to eq(true)
    end

    context "PM does not provide a session name" do
      it "MPP indicates that the PM must provide a session name" do
        expect { mpp.create_session nil }.
          to raise_error(/You must provide a session name/)
      end

      it "MPP does not create a new session" do
        mpp.create_session nil rescue nil

        expect(mpp.available_sessions).to be_empty
      end
    end

    context "PM provides the name of an existing session" do
      it "MPP indicates that the PM must provide a different name" do
        mpp.create_session "my session name"

        expect { mpp.create_session "my session name" }.
          to raise_error(/You must provide a different session name/)
      end

      it "MPP does not create a new session" do
        first_session_name = "my session name"

        mpp.create_session first_session_name
        mpp.create_session "my session name" rescue nil

        expect(mpp.available_sessions.size).to eq(1)
        expect(mpp.available_sessions.first.object_id).
          to eq(first_session_name.object_id)
      end
    end
  end

  describe "a Prospective Mobster (PM) joins a session" do
    it "MPP adds PM to the list of active mobsters" do
      mpp.create_session "session name"

      mpp.join_session "session name", "PM name"

      expect(mpp.active_mobsters("session name")).to include("PM name")
    end

    it "MPP reports success" do
      mpp.create_session "session name"

      expect(mpp.join_session("session name", "PM name")).to eq(true)
    end

    context "PM does not provide the name of a session to join" do
      let(:pm_name) { "PM name" }

      def join_session_with_pm_name_without_session_name
        mpp.join_session nil, pm_name
      end

      it "MPP indicates that the PM must provide a session name" do
        expect { join_session_with_pm_name_without_session_name }.
          to raise_error(/You must provide a session name/)
      end

      it "MPP does not add PM to the list of active mobsters" do
        join_session_with_pm_name_without_session_name rescue nil

        expect(mpp.active_mobsters(nil)).to_not include(pm_name)
      end
    end

    context "PM does not provide their name" do
      let(:session_name) { "session name" }

      def join_session_with_session_name_without_pm_name
        mpp.join_session session_name, nil
      end

      it "MPP indicates that PM must provide their name" do
        mpp.create_session session_name

        expect { join_session_with_session_name_without_pm_name }.
          to raise_error(/You must provide your name/)
      end

      it "MPP does not add PM to the list of active mobsters" do
        mpp.create_session session_name
        join_session_with_session_name_without_pm_name rescue nil

        expect(mpp.active_mobsters(session_name)).to be_empty
      end
    end

    context "PM provides the name of a session that does not exist" do
      let(:session_name) { "session name" }
      let(:pm_name) { "PM name" }

      def join_nonexistent_session
        mpp.join_session session_name, pm_name
      end

      it "MPP indicates that PM must provide the name of a current session" do
        expect { join_nonexistent_session }.
          to raise_error(/You must provide the name of a current session/)
      end

      it "MPP does not add PM to the list of active mobsters" do
        join_nonexistent_session rescue nil

        expect(mpp.active_mobsters(session_name)).to be_empty
      end
    end

    context "PM joins a session in which they're already participating" do
      let(:session_name) { "session name" }
      let(:pm_name) { "PM name" }

      before { mpp.create_session session_name }

      def join_session
        mpp.join_session session_name, pm_name
      end

      it "MPP indicates that PM may not join the same session twice" do
        join_session

        expect { join_session }.
          to raise_error(/You may not join the same session twice/)
      end

      it "MPP does not modify the list of active mobsters" do
        join_session
        join_session rescue nil

        expect(mpp.active_mobsters(session_name)).
          to eq([pm_name])
      end
    end
  end
end
