describe Fastlane::Actions::OvoOnetrustAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The ovo_onetrust plugin is working!")

      Fastlane::Actions::OvoOnetrustAction.run(nil)
    end
  end
end
