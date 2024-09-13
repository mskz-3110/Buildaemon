# frozen_string_literal: true

RSpec.describe Buildaemon do
  context "[OK]" do
    it "date" do
      Buildaemon.Execute('bash -c \'date "+%y/%m/%d %H:%M:%S"\'')
      expect(true).to be true
    end

    it "exit 0" do
      Buildaemon.Execute('exit 0'){|status|
        expect(status.exitstatus).to be 0
      }
    end

    it "exit 1" do
      Buildaemon.Execute('exit 1'){|status|
        expect(status.exitstatus).to be 1
      }
    end
  end

  context "[NG]" do
    it "yield error" do
      Buildaemon.Execute('error'){|status|
        expect(status).to be nil
      }
    end

    it "exit error" do
      Buildaemon.Execute('error')
      expect(true).to be false
    end
  end
end
