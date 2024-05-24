# frozen_string_literal: true

RSpec.describe Buildaemon do
  it "date command" do
    Buildaemon.Execute('bash -c \'date "+%y/%m/%d %H:%M:%S"\'')
  end
end
