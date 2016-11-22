class FakeTask < Task
end

describe Task do
  # Clear the task from the DB before every test
  before do
    reset_application!
    Timecop.freeze(Time.utc(2016, 2, 17, 20, 59, 0))

    @user = User.create(station_id: "ABC", css_id: "123")
  end

  context ".newest_first" do
    let!(:appeal1) { Appeal.create(vacols_id: "123C") }
    let!(:task1) { EstablishClaim.create(appeal: appeal1) }
    let!(:appeal2) { Appeal.create(vacols_id: "456D") }
    let!(:task2) { EstablishClaim.create(appeal: appeal2) }
    subject { Task.newest_first }
    before do
      task1.update(created_at: 10.days.ago)
      task2.update(created_at: 1.day.ago)
    end

    it "orders correctly" do
      expect(subject).to be_an_instance_of(Task::ActiveRecord_Relation)
      expect(subject.first).to eq(task2)
      expect(subject.last).to eq(task1)
    end
  end

  context ".unassigned" do
    let!(:appeal1) { Appeal.create(vacols_id: "123C") }
    let!(:task1) { EstablishClaim.create(appeal: appeal1) }
    let!(:appeal2) { Appeal.create(vacols_id: "456D") }
    let!(:task2) { EstablishClaim.create(appeal: appeal2) }
    before do
      task1.update(user: User.create(css_id: "111", station_id: "abc"))
    end
    subject { Task.unassigned }

    it "filters by nil user_id" do
      expect(subject).to be_an_instance_of(Task::ActiveRecord_Relation)
      expect(subject.count).to eq(1)
      expect(subject.first).to eq(task2)
    end
  end

  context "Assigning user methods" do
    let!(:appeal) { Appeal.create(vacols_id: "123C") }
    let!(:task) { EstablishClaim.create(appeal: appeal) }
    subject { task }

    context ".assign!" do
      it "correctly assigns a task to a user" do
        task.assign!(@user)
        expect(subject.user.id).to eq(@user.id)
        expect(subject.assigned_at).not_to be_nil
      end

      it "raises error if already assigned" do
        task.assign!(@user)
        expect { task.assign!(@user) }.to raise_error(Task::AlreadyAssignedError)
      end

      it "raises error if object stale" do
        expect(task).to receive(:before_assign) do
          Task.find(task.id).update!(started_at: Time.now.utc)
        end
        expect { task.assign!(@user) }.to raise_error(ActiveRecord::StaleObjectError)
      end
    end

    context ".assigned?" do
      it "assigned is false before assignment" do
        expect(subject.assigned?).to be_falsey
      end

      it "assigned is true after assignment" do
        task.assign!(@user)
        expect(subject.assigned?).to be_truthy
      end
    end
  end

  context ".progress_status" do
    let!(:appeal) { Appeal.create(vacols_id: "123C") }
    let!(:task) { EstablishClaim.create(appeal: appeal) }
    subject { task.progress_status }

    # We start with a blank task and move it task through the various states

    context "starts as unassigned" do
      it { is_expected.to eq("Unassigned") }
    end

    context "task is assigned" do
      before do
        task.assign!(@user)
      end

      it { is_expected.to eq("Not Started") }
    end

    context "task is started" do
      let!(:appeal) { Appeal.create(vacols_id: "123C") }
      let!(:task) { EstablishClaim.create(appeal: appeal) }
      before do
        # TODO(Mark): When we have a method to start a task, this should be updated
        task.started_at = Time.now.utc
      end
      it { is_expected.to eq("In Progress") }
    end

    context "task is completed" do
      before do
        # TODO(Mark): When we have a method to complete a task, this should be updated
        task.completed_at = Time.now.utc
      end

      it { is_expected.to eq("Complete") }
    end
  end

  context ".start!" do
    let!(:appeal) { Appeal.create(vacols_id: "123C") }
    let!(:task) { EstablishClaim.create(appeal: appeal) }
    it "errors if no one is assigned" do
      expect(task.user).to be_nil
      expect { task.start! }.to raise_error(Task::NotAssignedError)
    end

    it "sets started_at value to current timestamp" do
      task.assign!(@user)
      expect(task.started_at).to be_falsey
      task.start!
      expect(task.started_at).to eq(Time.now.utc)
    end
  end

  context ".started?" do
    let!(:appeal) { Appeal.create(vacols_id: "123C") }
    let!(:task) { EstablishClaim.create(appeal: appeal) }
    subject { task.started? }
    before { task.assign!(@user) }

    context "not started" do
      it { is_expected.to be_falsey }
    end

    context "was started" do
      before { task.start! }
      it { is_expected.to be_truthy }
    end
  end

  context ".completed?" do
    let!(:appeal) { Appeal.create(vacols_id: "123C") }
    let!(:task) { EstablishClaim.create(appeal: appeal) }
    subject { task }
    before { task.completed_at = Time.now.utc }
    it { expect(subject.completed_at).to be_truthy }
  end

  context "#completed_today" do
    let!(:appeal) { Appeal.create(vacols_id: "123C") }
    let!(:task) { EstablishClaim.create(appeal: appeal) }
    before do
      task.update_attributes!(completed_at: Time.now.utc)
    end
    it { expect { Task.completed_today.find(task.id) }.not_to raise_error }
  end

  context "#to_complete" do
    let!(:appeal) { Appeal.create(vacols_id: "123C") }
    let!(:task) { EstablishClaim.create(appeal: appeal) }
    it { expect { Task.to_complete.find(task.id) }.not_to raise_error }
  end

  context "#expire!" do
    let!(:appeal) { Appeal.create(vacols_id: "123C") }
    let!(:task) { EstablishClaim.create(appeal: appeal) }

    it "closes unfinished tasks" do
      initial_sum = EstablishClaim.count
      task.expire!
      expect(EstablishClaim.count).to eq(initial_sum + 1)
      expect(task.reload.complete?).to be_truthy
      expect(task.reload.completion_status).to eq(Task.completion_status_code(:expired))
    end
  end

  context "#assigned_not_completed" do
    let!(:appeal) { Appeal.create(vacols_id: "123C") }
    let!(:task) { EstablishClaim.create(appeal: appeal) }
    before do
      task.assign!(@user)
    end
    it { expect { Task.assigned_not_completed.find(task.id) }.not_to raise_error }
  end
end
