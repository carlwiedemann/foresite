# frozen_string_literal: true

RSpec.describe Foresite::Renderer do
  it "Renders markup as expected" do

    actual = Foresite::Renderer.render("#{TEST_DIR}/fixture/sample_template.rhtml", {
      foo: 'bar'
    })

    expected = "The value of foo is: bar\n"

    expect(actual).to eq(expected)
  end
end
