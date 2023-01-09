#! /usr/bin/env rspec

require_relative "../test_helper"
require_yupdate

describe YUpdate::System do
  let(:file) { "/.packages.initrd" }

  before do
    allow(File).to receive(:exist?).with(file).and_return(false)
    allow(described_class).to receive(:`).with("mount").and_return("")
  end

  describe ".check!" do
    context "when running in an inst-sys" do
      before do
        expect(File).to receive(:exist?).with(file).and_return(true)
      end

      it "does not exit" do
        expect(described_class).to_not receive(:exit)
        described_class.check!
      end
    end

    context "when running on a live medium" do
      before do
        expect(described_class).to receive(:`).with("mount")
          .and_return("LiveOS_rootfs on / type overlay (rw,relatime)")
      end

      it "does not exit" do
        expect(described_class).to_not receive(:exit)
        described_class.check!
      end
    end

    context "when running in a normal system" do
      before do
        allow(described_class).to receive(:exit).with(1)
      end

      it "exits with status 1" do
        expect(described_class).to receive(:exit).with(1)
        # capture the std streams just to not break the rspec output
        capture_stdio { described_class.check! }
      end

      it "prints an error on STDERR" do
        _stdout, stderr = capture_stdio { described_class.check! }
        expect(stderr).to match(/ERROR: .*inst-sys/)
      end
    end
  end
end
