require 'spec_helper'

RSpec.describe Prawn::Rtl::Connector do
  let(:initial_codepoints) { [1580, 1576, 1587, 32, 1586, 1585, 1575, 1593, 1609, 32, 45, 32, 1587, 1575, 1574, 1576] }
  let(:initial_string) { initial_codepoints.pack('U*') }
  let(:final_codepoints) { [65168, 65163, 65166, 65203, 32, 45, 32, 65264, 65227, 65165, 65197, 65199, 32, 65202, 65170, 65183] }
  let(:final_string) { final_codepoints.pack('U*') }

  it 'connect arabic string and reverse' do
    expect(Prawn::Rtl::Connector.fix_rtl(initial_string)).to eq(final_string)
  end

  describe '.include_rtl?' do
    context 'stray BiDi formatting controls only (no RTL letter scripts)' do
      it 'returns false for BOM (U+FEFF) alone' do
        expect(described_class.include_rtl?("﻿")).to be false
      end

      it 'returns false for RLM (U+200F) alone' do
        expect(described_class.include_rtl?("‏")).to be false
      end

      it 'returns false for LRM (U+200E) alone' do
        expect(described_class.include_rtl?("‎")).to be false
      end

      it 'returns false for BiDi embedding control (U+202A) alone' do
        expect(described_class.include_rtl?("‪")).to be false
      end

      it 'returns false for BiDi isolate control (U+2066) alone' do
        expect(described_class.include_rtl?("⁦")).to be false
      end

      it 'returns false for plain LTR text with appended BOM (the bug case)' do
        expect(described_class.include_rtl?("Happy birthday!﻿")).to be false
      end
    end

    context 'genuine RTL letter scripts' do
      it 'returns true for Arabic letters' do
        expect(described_class.include_rtl?("مرحبا")).to be true
      end

      it 'returns true for Hebrew letters' do
        expect(described_class.include_rtl?("שלום")).to be true
      end

      it 'returns true for Arabic Presentation Forms (U+FE70 range)' do
        expect(described_class.include_rtl?("ﹰ")).to be true
      end
    end

    context 'mixed RTL letters with embedded BiDi controls' do
      it 'returns true — RTL letters still match even with LRM around digits' do
        # Arabic "price 100 dollar" with LRM markers around "100"
        mixed = "السعر ‎100‎ دولار"
        expect(described_class.include_rtl?(mixed)).to be true
      end
    end
  end

  describe '.fix_rtl' do
    it 'returns the input unchanged when no RTL letters are present (stray BOM case)' do
      input = "Happy birthday!﻿"
      expect(described_class.fix_rtl(input)).to eq(input)
    end
  end
end
